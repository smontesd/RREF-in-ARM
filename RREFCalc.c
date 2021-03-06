/*
 * File Name: RREFCalc.c
 * Author: Stephen Montes De Oca
 * Email: deocapaul@gmail.com
 */

#include "RREFCalc.h"

/*
 * Function Name: main()
 * Function Prototype: int main( int argc, char *argv[]);
 * Description: This function is the main executable for the RREF Calculator
 *              it takes in exactly 2 command line arguments. The first command
 *              line argument is the number of rows in a matrix, and the second
 *              comand line arguments is the number of columns in the matrix.
 *              main will then take in user input to fill in each row with
 *              floating point values and lastly the matrix is printed out after
 *              being converted to RREF form.
 * Parameters: argc - number of command line arguments
 *             argv - array of pointers to command line arguments
 * Side Effects: None
 * Error Conditions: Invalid Number of args, or invalid command line arguments
 * Return Value: int - indicates exit success
 */
int main(int argc, char *argv[] ) {
  // checking for correct number of command line arguments
  if ( argc != VALID_ARGS ) {
    fprintf(stderr, INVALID_ARGS);
    fprintf(stderr, USAGE);
    return EXIT_FAILURE;
  }
  
  // parsing command line arguments
  int row = atoi(argv[INDEX_ROW]);
  int col = atoi(argv[INDEX_COL]);

  // checking for valid values for row and col
  if ( row <= 0 || col <= 0 ) {
    fprintf(stderr, INVALID_PARSE);
    fprintf(stderr, USAGE);
    return EXIT_FAILURE;
  }

  // creating matrix of dimension row x col
  float ** matrix = malloc(row * sizeof(float *));
  
  if ( matrix == NULL ) {
    fprintf(stderr, MALLOC_FAIL);
    return EXIT_FAILURE;
  }

  for (int i = 0; i < row; i++) {
    matrix[i] = calloc(col, sizeof(float));

    if ( matrix[i] == NULL ) {
      fprintf(stderr, MALLOC_FAIL);

      for (int j = 0; j < i; j++) {
        free(matrix[j]);
      }

      free(matrix);
      return EXIT_FAILURE;
    }
  }

  // Filling in matrix row by row via user input
  for (int i = 0; i < row; i++) {
    printf(INPUT_ROW,i);

    char buf[BUFSIZ];

    // waiting for user input for row
    char * result = fgets(buf, BUFSIZ, stdin);
    if ( result == NULL ) {
      continue;
    }

    // parsing each column entry from user's row input
    char * token = strtok(buf, DELIM);
    int j = 0;

    while ( token != NULL && j < col ) {
      matrix[i][j] = strtof(token, NULL);
      token = strtok(NULL, DELIM);
      j++;
    }
  }

  // calling rref function
  int dimension = rref(row, col, matrix);

  // printing out matrix now that it is in reduced row echelon form
  printf(MATRIX_PROMPT);

  for (int i = 0; i < row; i++) {
    for (int j = 0; j < col; j++) {
      printf(FLOAT_STR, matrix[i][j]);

      if (j != col-1) {
        printf(SPACE);
      }
    }

    printf(NEWLINE);
  }

  // freeing matrix from memory
  for (int i = 0; i < row; i++) {
    free(matrix[i]);
  }
  free(matrix);

  return EXIT_SUCCESS;
}
