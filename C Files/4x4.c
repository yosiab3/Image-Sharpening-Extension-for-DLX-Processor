#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define ROWS 4
#define COLS 4

// Save matrix as PGM image
void save_pgm(const char *filename, int matrix[ROWS][COLS]) {
    FILE *file = fopen(filename, "w");
    if (!file) {
        perror("Error creating PGM file");
        exit(EXIT_FAILURE);
    }

    fprintf(file, "P2\n");
    fprintf(file, "%d %d\n", COLS, ROWS);
    fprintf(file, "255\n");

    for (int i = 0; i < ROWS; i++) {
        for (int j = 0; j < COLS; j++) {
            fprintf(file, "%d ", matrix[i][j]);
        }
        fprintf(file, "\n");
    }

    fclose(file);
}

// Save matrix as TXT file
void save_txt(const char *filename, int matrix[ROWS][COLS]) {
    FILE *file = fopen(filename, "w");
    if (!file) {
        perror("Error creating TXT file");
        exit(EXIT_FAILURE);
    }

    for (int i = 0; i < ROWS; i++) {
        for (int j = 0; j < COLS; j++) {
            fprintf(file, "%d ", matrix[i][j]);
        }
        fprintf(file, "\n");
    }

    fclose(file);
}

// Save matrix as CSV file
void save_csv(const char *filename, int matrix[ROWS][COLS]) {
    FILE *file = fopen(filename, "w");
    if (!file) {
        perror("Error creating CSV file");
        exit(EXIT_FAILURE);
    }

    for (int i = 0; i < ROWS; i++) {
        for (int j = 0; j < COLS; j++) {
            fprintf(file, "%d", matrix[i][j]);
            if (j < COLS - 1) {
                fprintf(file, ",");
            }
        }
        fprintf(file, "\n");
    }

    fclose(file);
}

// Save matrix in RESA-style memory dump format
void save_resa_format_csv(const char *filename, int matrix[ROWS][COLS]) {
    FILE *file = fopen(filename, "w");
    if (!file) {
        perror("Error creating RESA CSV file");
        exit(EXIT_FAILURE);
    }

    int flat[ROWS * COLS];
    int idx = 0;

    // Flatten into 1D array
    for (int i = 0; i < ROWS; i++) {
        for (int j = 0; j < COLS; j++) {
            flat[idx++] = matrix[i][j];
        }
    }

    int word_count = ROWS * COLS;
    unsigned int address = 0;

    for (int i = 0; i < word_count; i++) {
        if (i % 8 == 0) { // 8 words per line
            if (i != 0) fprintf(file, "\n");
            fprintf(file, "0x%08X ", address);
            address += 8; // Address increases by 8
        }

        fprintf(file, "0x%08X", flat[i]);

        if ((i + 1) % 8 != 0 && (i + 1) != word_count) {
            fprintf(file, " ");
        }
    }

    fprintf(file, "\n");
    fclose(file);
}

int main() {
    int image[ROWS][COLS];
    int output_reflection[ROWS][COLS] = {0};

    int center_x = ROWS / 2;
    int center_y = COLS / 2;
    double radius = ROWS / 3.0;

// Bright diagonal shape
for (int i = 0; i < ROWS; i++) {
    for (int j = 0; j < COLS; j++) {
        if (i == j) {
            image[i][j] = 200;  // bright diagonal
        } else {
            image[i][j] = 50;    // dark elsewhere
        }
    }
}

    // Sharpen filter
    int sharpen[3][3] = {
        {  0, -1,  0 },
        { -1,  5, -1 },
        {  0, -1,  0 }
    };

    // Apply sharpen convolution (your original reflection handling kept)
    for (int i = 0; i < ROWS; i++) {
        for (int j = 0; j < COLS; j++) {
            int sum = 0;
            for (int row = 0; row < 3; row++) {
                for (int col = 0; col < 3; col++) {
                    int ni = i + (row - 1);
                    int nj = j + (col - 1);

                    if (ni < 0) ni = -ni;
                    if (ni >= ROWS) ni = ROWS - 2;
                    if (nj < 0) nj = -nj;
                    if (nj >= COLS) nj = COLS - 2;

                    int pixel = image[ni][nj];
                    sum += pixel * sharpen[row][col];
                }
            }
            if (sum < 0) sum = 0;
            if (sum > 255) sum = 255;
            output_reflection[i][j] = sum;
        }
    }

    // Save files
    save_pgm("input.pgm", image);   
    save_pgm("output_reflection.pgm", output_reflection);

    save_txt("input_matrix.txt", image);
    save_txt("output_matrix.txt", output_reflection);

    save_csv("input_matrix.csv", image);
    save_csv("output_matrix.csv", output_reflection);

    save_resa_format_csv("input_matrix_resa.csv", image);
    save_resa_format_csv("output_matrix_resa.csv", output_reflection);

    printf("\nGenerated 4x4 input/output and saved PGM/TXT/CSV/RESA files.\n");
    return 0;
}