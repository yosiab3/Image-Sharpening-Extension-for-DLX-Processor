#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdint.h>
#include <stdbool.h>

#define LINE_MAX_LEN  4096

// ---------- enums & opcode tables ----------

typedef enum {
    OP_LW   = 0b100011,
    OP_SW   = 0b101011,
    OP_ADDI = 0b001011,
    OP_SGTI = 0b011001,
    OP_SEQI = 0b011010,
    OP_SGEI = 0b011011,
    OP_SLTI = 0b011100,
    OP_SNEI = 0b011101,
    OP_SLEI = 0b011110,
    OP_BEQZ = 0b000100,
    OP_BNEZ = 0b000101,
    OP_JR   = 0b010110,
    OP_JALR = 0b010111
} ITypeOpcode;

typedef enum {
    F_SLLI    = 0b000000,
    F_SRLI    = 0b000010,
    F_ADD     = 0b100011,
    F_SUB     = 0b100010,
    F_AND     = 0b100110,
    F_OR      = 0b100101,
    F_XOR     = 0b100100,
    F_SHARPEN = 0b100000
} RTypeFunct;

typedef struct { const char *name; int value; } NameVal;

static const NameVal I_OPS[] = {
    {"lw",   OP_LW},   {"sw",   OP_SW},   {"addi", OP_ADDI},
    {"sgti", OP_SGTI}, {"seqi", OP_SEQI}, {"sgei", OP_SGEI},
    {"slti", OP_SLTI}, {"snei", OP_SNEI}, {"slei", OP_SLEI},
    {"beqz", OP_BEQZ}, {"bnez", OP_BNEZ}, {"jr",   OP_JR},
    {"jalr", OP_JALR},
};
static const size_t I_OPS_N = sizeof(I_OPS)/sizeof(I_OPS[0]);

static const NameVal R_FUNCTS[] = {
    {"slli", F_SLLI}, {"srli", F_SRLI}, {"add", F_ADD}, {"sub", F_SUB},
    {"and",  F_AND},  {"or",   F_OR},   {"xor", F_XOR}, {"sharpen", F_SHARPEN},
};
static const size_t R_FUNCTS_N = sizeof(R_FUNCTS)/sizeof(R_FUNCTS[0]);

// ---------- tiny dynamic arrays ----------

typedef struct {
    char **items;
    size_t size, cap;
} StrList;

static void sl_init(StrList *l) { l->items=NULL; l->size=0; l->cap=0; }
static void sl_free(StrList *l) {
    for (size_t i=0;i<l->size;i++) free(l->items[i]);
    free(l->items); l->items=NULL; l->size=l->cap=0;
}
static void sl_push(StrList *l, const char *s) {
    if (l->size==l->cap) {
        l->cap = l->cap? l->cap*2 : 16;
        l->items = (char**)realloc(l->items, l->cap*sizeof(char*));
        if (!l->items) { perror("realloc"); exit(1); }
    }
    l->items[l->size++] = strdup(s?s:"");
    if (!l->items[l->size-1]) { perror("strdup"); exit(1); }
}

typedef struct {
    char **keys;
    int   *vals;
    size_t size, cap;
} SymTab;

static void st_init(SymTab *t){ t->keys=NULL; t->vals=NULL; t->size=0; t->cap=0; }
static void st_free(SymTab *t){
    for (size_t i=0;i<t->size;i++) free(t->keys[i]);
    free(t->keys); free(t->vals);
    t->keys=NULL; t->vals=NULL; t->size=t->cap=0;
}
static int st_find(const SymTab *t, const char *key){
    for (size_t i=0;i<t->size;i++){
        if (strcmp(t->keys[i], key)==0) return (int)i;
    }
    return -1;
}
static void st_set(SymTab *t, const char *key, int val){
    int idx = st_find(t, key);
    if (idx>=0){ t->vals[idx]=val; return; }
    if (t->size==t->cap){
        t->cap = t->cap? t->cap*2 : 32;
        t->keys=(char**)realloc(t->keys,t->cap*sizeof(char*));
        t->vals=(int*)realloc(t->vals,t->cap*sizeof(int));
        if(!t->keys||!t->vals){ perror("realloc"); exit(1); }
    }
    t->keys[t->size]=strdup(key);
    if(!t->keys[t->size]){ perror("strdup"); exit(1); }
    t->vals[t->size]=val;
    t->size++;
}
static bool st_get(const SymTab *t, const char *key, int *out){
    int idx = st_find(t,key);
    if (idx<0) return false;
    *out = t->vals[idx]; return true;
}

// ---------- helpers ----------

static char *str_dup_trim(const char *s){
    char *p = strdup(s?s:"");
    if(!p){ perror("strdup"); exit(1); }
    // remove non-ASCII
    size_t n = strlen(p), j=0;
    for(size_t i=0;i<n;i++){
        unsigned char c = (unsigned char)p[i];
        if (c < 128) p[j++] = (char)c;
    }
    p[j]='\0';
    // trim spaces
    char *start = p;
    while(isspace((unsigned char)*start)) start++;
    char *end = p + strlen(p);
    while(end>start && isspace((unsigned char)end[-1])) end--;
    *end = '\0';
    if (start!=p) {
        char *q=strdup(start);
        if(!q){ perror("strdup"); exit(1); }
        free(p); p=q;
    }
    return p;
}

static void strip_inline_comments(char *line){
    const char *seps[] = {"//", "#", "##", "/"};
    for (int i=0;i<4;i++){
        char *pos = strstr(line, seps[i]);
        if(!pos) continue;
        *pos = '\0';
        size_t L = strlen(line);
        while(L>0 && isspace((unsigned char)line[L-1])) { line[L-1]='\0'; L--; }
    }
}

static void trim_inplace(char *s){
    if(!s) return;
    size_t i=0;
    while(s[i] && isspace((unsigned char)s[i])) i++;
    if(i>0) memmove(s, s+i, strlen(s+i)+1);
    size_t L=strlen(s);
    while(L>0 && isspace((unsigned char)s[L-1])) { s[L-1]='\0'; L--; }
}

static bool starts_with(const char *s, const char *pfx){
    return strncmp(s,pfx,strlen(pfx))==0;
}

static int name_to_iopcode(const char *mn, int *out){
    for(size_t i=0;i<I_OPS_N;i++){
        if(strcmp(mn,I_OPS[i].name)==0){ *out=I_OPS[i].value; return 1; }
    }
    return 0;
}
static int name_to_rfunct(const char *mn, int *out){
    for(size_t i=0;i<R_FUNCTS_N;i++){
        if(strcmp(mn,R_FUNCTS[i].name)==0){ *out=R_FUNCTS[i].value; return 1; }
    }
    return 0;
}

static int reg_to_num(const char *r){
    if (r==NULL || (r[0]!='R' && r[0]!='r')) {
        fprintf(stderr, "Invalid register syntax: %s\n", r?r:"(null)");
        return -1;
    }
    char *end=NULL;
    long v = strtol(r+1, &end, 10);
    if (end==r+1 || *end!='\0' || v<0 || v>31) {
        fprintf(stderr, "Invalid register number: %s\n", r);
        return -1;
    }
    return (int)v;
}

static int parse_immediate(const char *tok, const SymTab *st, int *out){
    if (!tok) return 0;
    char *end=NULL;
    long v = strtol(tok, &end, 0); // auto base
    if (end && *end=='\0') { *out=(int)v; return 1; }
    int addr;
    if (st_get(st, tok, &addr)) { *out=addr; return 1; }
    return 0;
}

// NEW: detect numeric literal for branch offsets
static bool is_number_literal(const char *s){
    if (!s || !*s) return false;
    if (*s=='+' || *s=='-') s++;
    if (!*s) return false;
    if (s[0]=='0' && (s[1]=='x' || s[1]=='X')){
        s+=2; if (!*s) return false;
        while (*s){ if(!isxdigit((unsigned char)*s)) return false; s++; }
        return true;
    } else {
        while (*s){ if(!isdigit((unsigned char)*s)) return false; s++; }
        return true;
    }
}

static char *replace_ext(const char *path, const char *from, const char *to){
    size_t Lp=strlen(path), Lf=strlen(from);
    if (Lp>=Lf && strcmp(path+Lp-Lf, from)==0) {
        size_t Ln = Lp - Lf + strlen(to);
        char *out=(char*)malloc(Ln+1);
        if(!out){ perror("malloc"); exit(1); }
        memcpy(out, path, Lp-Lf);
        memcpy(out+(Lp-Lf), to, strlen(to));
        out[Ln]='\0';
        return out;
    }
    size_t Ln = Lp + strlen(to);
    char *out=(char*)malloc(Ln+1);
    if(!out){ perror("malloc"); exit(1); }
    memcpy(out, path, Lp);
    memcpy(out+Lp, to, strlen(to));
    out[Ln]='\0';
    return out;
}

// Tokenize by whitespace only
static int tokenize(char *line, char *tokens[], int max_tokens){
    int n=0;
    char *p=line;
    while (*p && n<max_tokens){
        while(isspace((unsigned char)*p)) p++;
        if(!*p) break;
        char *start=p;
        while(*p && !isspace((unsigned char)*p)) p++;
        size_t len = (size_t)(p-start);
        char *tok=(char*)malloc(len+1);
        if(!tok){ perror("malloc"); exit(1); }
        memcpy(tok,start,len); tok[len]='\0';
        tokens[n++]=tok;
    }
    return n;
}
static void free_tokens(char *tokens[], int n){
    for (int i=0;i<n;i++) free(tokens[i]);
}

// ---------- Assembler state ----------

typedef struct {
    char *input_file;
    SymTab symbols;
    StrList instructions;
    StrList data_defs;
    StrList machine_codes;
    int instruction_address;
    int data_address;
    enum { MODE_INSTRUCTIONS, MODE_DATA } mode;
} Assembler;

static void as_init(Assembler *a, const char *input){
    a->input_file = strdup(input);
    st_init(&a->symbols);
    sl_init(&a->instructions);
    sl_init(&a->data_defs);
    sl_init(&a->machine_codes);
    a->instruction_address=0;
    a->data_address=0;
    a->mode=MODE_INSTRUCTIONS;
}
static void as_free(Assembler *a){
    free(a->input_file);
    st_free(&a->symbols);
    sl_free(&a->instructions);
    sl_free(&a->data_defs);
    sl_free(&a->machine_codes);
}

// ---------- First pass ----------

static void first_pass(Assembler *a){
    FILE *fp = fopen(a->input_file, "rb");
    if(!fp){ perror(a->input_file); exit(1); }

    a->instructions.size = a->data_defs.size = a->machine_codes.size = 0;
    a->instruction_address = 0;
    a->data_address = 0;
    a->mode = MODE_INSTRUCTIONS;
    st_free(&a->symbols);
    st_init(&a->symbols);

    char raw[LINE_MAX_LEN];
    while (fgets(raw, sizeof(raw), fp)){
        char *line = str_dup_trim(raw);
        if (line[0]=='\0' || line[0]=='/' || line[0]=='#') { free(line); continue; }
        strip_inline_comments(line);
        trim_inplace(line);
        if (line[0]=='\0'){ free(line); continue; }

        char *label=NULL;
        char *colon = strchr(line, ':');
        if (colon){
            *colon = '\0';
            trim_inplace(line);
            label = strdup(line);
            char *rest = colon+1;
            while(isspace((unsigned char)*rest)) rest++;
            char *tmp = strdup(rest);
            free(line);
            line = tmp;
        }

        if (starts_with(line, "dc") || starts_with(line, "ds")){
            a->mode = MODE_DATA;
        }

        if (a->mode == MODE_INSTRUCTIONS){
            if (label) st_set(&a->symbols, label, a->instruction_address);
            if (line[0]!='\0'){
                sl_push(&a->instructions, line);
                a->instruction_address += 1;
            }
        } else {
            if (label) st_set(&a->symbols, label, a->instruction_address + a->data_address);
            if (line[0]!='\0'){
                sl_push(&a->data_defs, line);
                char *tmp = strdup(line);
                char *toks[4]={0};
                int nt = tokenize(tmp, toks, 4);
                if (nt >= 1){
                    if (strcmp(toks[0],"dc")==0){
                        a->data_address += 1;
                    } else if (strcmp(toks[0],"ds")==0 && nt>=2){
                        long cnt = strtol(toks[1], NULL, 0);
                        if (cnt<0) cnt=0;
                        a->data_address += (int)cnt;
                    }
                }
                free_tokens(toks, nt);
                free(tmp);
            }
        }

        free(label);
        free(line);
    }

    fclose(fp);
}

// ---------- Second pass: encode ----------

static void u32_to_hex(uint32_t v, char out[9]){
    static const char *digits = "0123456789ABCDEF";
    for (int i=7;i>=0;i--){ out[i] = digits[v & 0xF]; v >>= 4; }
    out[8]='\0';
}

static void encode_instruction(Assembler *a, const char *line, int idx){
    char *dup = strdup(line);
    if(!dup){ perror("strdup"); exit(1); }

    char *toks[8]={0};
    int nt = tokenize(dup, toks, 8);

    if (nt<=0){ sl_push(&a->machine_codes, "????????"); free(dup); return; }

    const char *mn = toks[0];

    if (strcmp(mn, "halt")==0){
        sl_push(&a->machine_codes, "FC000000");
        free_tokens(toks, nt); free(dup); return;
    }

    int iop;
    uint32_t code = 0;

    if (strcmp(mn,"jalr")==0){
        if (!name_to_iopcode("jalr",&iop)) goto unknown;
        int rs1=0, rd=31;
        if (nt==3){
            rd = reg_to_num(toks[1]);
            rs1 = reg_to_num(toks[2]);
            if (rd<0||rs1<0) goto fail;
        } else if (nt==2){
            rs1 = reg_to_num(toks[1]);
            if (rs1<0) goto fail;
        } else goto fail;
        int imm = 0;
        code = ((uint32_t)iop<<26) | ((uint32_t)rs1<<21) | ((uint32_t)rd<<16) | ((uint32_t)(imm & 0xFFFF));
        char hex[9]; u32_to_hex(code, hex); sl_push(&a->machine_codes, hex);
        free_tokens(toks, nt); free(dup); return;
    }

    if (strcmp(mn,"jr")==0){
        if (!name_to_iopcode("jr",&iop)) goto unknown;
        if (nt!=2) goto fail;
        int rs1 = reg_to_num(toks[1]); if (rs1<0) goto fail;
        int rd = 0, imm=0;
        code = ((uint32_t)iop<<26) | ((uint32_t)rs1<<21) | ((uint32_t)rd<<16) | ((uint32_t)(imm & 0xFFFF));
        char hex[9]; u32_to_hex(code, hex); sl_push(&a->machine_codes, hex);
        free_tokens(toks, nt); free(dup); return;
    }

    if (strcmp(mn,"beqz")==0 || strcmp(mn,"bnez")==0){
        if (!name_to_iopcode(mn,&iop)) goto unknown;
        if (nt!=3) goto fail;
        int rs1 = reg_to_num(toks[1]); if (rs1<0) goto fail;

        // NEW: accept numeric relative offset OR label
        int offset = 0;
        if (is_number_literal(toks[2])) {
            long off = strtol(toks[2], NULL, 0);
            if (off < -32768L || off > 32767L) {
                fprintf(stderr, "[Line %d] Branch offset out of 16-bit range: %ld\n", idx+1, off);
                sl_push(&a->machine_codes, "????????");
                free_tokens(toks, nt); free(dup); return;
            }
            offset = (int)off;
        } else {
            int target_pc;
            if (!st_get(&a->symbols, toks[2], &target_pc)){
                fprintf(stderr, "[Line %d] Error parsing instruction '%s': Unknown label: %s\n",
                        idx+1, line, toks[2]);
                sl_push(&a->machine_codes, "????????");
                free_tokens(toks, nt); free(dup); return;
            }
            offset = target_pc - (idx + 1);
            if (offset < -32768 || offset > 32767) {
                fprintf(stderr, "[Line %d] Branch offset to label out of 16-bit range: %d\n", idx+1, offset);
                sl_push(&a->machine_codes, "????????");
                free_tokens(toks, nt); free(dup); return;
            }
        }

        int rd = 0;
        code = ((uint32_t)iop<<26) | ((uint32_t)rs1<<21) | ((uint32_t)rd<<16) | ((uint32_t)(offset & 0xFFFF));
        char hex[9]; u32_to_hex(code, hex); sl_push(&a->machine_codes, hex);
        free_tokens(toks, nt); free(dup); return;
    }

    if (name_to_iopcode(mn,&iop)){
        if (nt!=4) goto fail;
        int rd  = reg_to_num(toks[1]); if (rd<0) goto fail;
        int rs1 = reg_to_num(toks[2]); if (rs1<0) goto fail;
        int imm;
        if (!parse_immediate(toks[3], &a->symbols, &imm)) {
            fprintf(stderr, "[Line %d] Error parsing instruction '%s': Invalid immediate or label not found: %s\n",
                    idx+1, line, toks[3]);
            sl_push(&a->machine_codes, "????????");
            free_tokens(toks, nt); free(dup); return;
        }
        code = ((uint32_t)iop<<26) | ((uint32_t)rs1<<21) | ((uint32_t)rd<<16) | ((uint32_t)(imm & 0xFFFF));
        char hex[9]; u32_to_hex(code, hex); sl_push(&a->machine_codes, hex);
        free_tokens(toks, nt); free(dup); return;
    }

    {
        int funct;
        if (name_to_rfunct(mn, &funct)){
            if (nt<2) goto fail;
            int rd = reg_to_num(toks[1]); if (rd<0) goto fail;
            int rs1 = (nt>2) ? reg_to_num(toks[2]) : 0; if (rs1<0) goto fail;
            int rs2 = (nt>3) ? reg_to_num(toks[3]) : 0; if (rs2<0) goto fail;
            code = ((uint32_t)0<<26) | ((uint32_t)rs1<<21) | ((uint32_t)rs2<<16) |
                   ((uint32_t)rd<<11) | ((uint32_t)0<<6) | ((uint32_t)funct);
            char hex[9]; u32_to_hex(code, hex); sl_push(&a->machine_codes, hex);
            free_tokens(toks, nt); free(dup); return;
        }
    }

unknown:
    fprintf(stderr, "[Line %d] Error parsing instruction '%s': Unknown instruction\n", idx+1, line);
    sl_push(&a->machine_codes, "????????");
    free_tokens(toks, nt); free(dup); return;

fail:
    fprintf(stderr, "[Line %d] Error parsing instruction '%s': Syntax error\n", idx+1, line);
    sl_push(&a->machine_codes, "????????");
    free_tokens(toks, nt); free(dup); return;
}

static void second_pass(Assembler *a){
    for (size_t i=0;i<a->machine_codes.size;i++) free(a->machine_codes.items[i]);
    a->machine_codes.size=0;

    for (size_t i=0;i<a->instructions.size;i++){
        encode_instruction(a, a->instructions.items[i], (int)i);
    }
}

// ---------- Writers ----------

static void write_cod_file(Assembler *a){
    char *out = replace_ext(a->input_file, ".txt", ".cod");
    FILE *fp = fopen(out, "wb");
    if(!fp){ perror(out); free(out); exit(1); }

    fprintf(fp, ".CODE\n");
    fprintf(fp, "0x00000000\n");
    fprintf(fp, "0x%08X\n", (unsigned int)a->machine_codes.size);
    for (size_t i=0;i<a->machine_codes.size;i++){
        fprintf(fp, "0x%s\n", a->machine_codes.items[i]);
    }

    fprintf(fp, ".DATA\n");
    fprintf(fp, "0x%08X\n", (unsigned int)a->machine_codes.size);
    fprintf(fp, "0x%08X\n", (unsigned int)a->data_address);

    for (size_t i=0;i<a->data_defs.size;i++){
        const char *line = a->data_defs.items[i];
        char *dup = strdup(line);
        char *toks[4]={0};
        int nt = tokenize(dup, toks, 4);
        if (nt>=1 && strcmp(toks[0],"ds")==0 && nt>=2){
            long cnt = strtol(toks[1], NULL, 0);
            if (cnt<0) cnt=0;
            for (long k=0;k<cnt;k++) fprintf(fp, "0x00000000\n");
        } else if (nt>=2 && strcmp(toks[0],"dc")==0){
            long v = strtol(toks[1], NULL, 0);
            fprintf(fp, "0x%08lX\n", v & 0xFFFFFFFFL);
        }
        free_tokens(toks, nt);
        free(dup);
    }

    fprintf(fp, ".DS\n");
    fprintf(fp, "0x100 XML file date: XML file date: Wed 20/6/2012 6:49:12\n");

    fclose(fp);
    free(out);
}

static void write_data_file(Assembler *a){
    char *out = replace_ext(a->input_file, ".txt", ".data");
    FILE *fp = fopen(out, "wb");
    if(!fp){ perror(out); free(out); exit(1); }

    for (size_t i=0;i<a->instructions.size;i++){
        const char *hex = (i<a->machine_codes.size)? a->machine_codes.items[i] : "????????";
        fprintf(fp, "%s //\t%s\n", hex, a->instructions.items[i]);
    }

    for (size_t i=0;i<a->data_defs.size;i++){
        const char *line = a->data_defs.items[i];
        char *dup = strdup(line);
        char *toks[4]={0};
        int nt = tokenize(dup, toks, 4);
        if (nt>=1 && strcmp(toks[0],"ds")==0 && nt>=2){
            long cnt = strtol(toks[1], NULL, 0); if (cnt<0) cnt=0;
            for (long k=0;k<cnt;k++){
                fprintf(fp, "00000000 //\t%s\n", line);
            }
        } else if (nt>=2 && strcmp(toks[0],"dc")==0){
            long v = strtol(toks[1], NULL, 0);
            fprintf(fp, "%08lX //\t%s\n", v & 0xFFFFFFFFL, line);
        }
        free_tokens(toks, nt);
        free(dup);
    }

    fclose(fp);
    free(out);
}

// ---------- Top-level flow ----------

static void assemble(Assembler *a){
    first_pass(a);
    second_pass(a);
    write_cod_file(a);
    write_data_file(a);
}

int main(int argc, char **argv){
    const char *in = (argc>=2)? argv[1] : "old_sharpen.txt";
    Assembler A; as_init(&A, in);
    assemble(&A);
    printf("Success.\n");
    as_free(&A);
    return 0;
}