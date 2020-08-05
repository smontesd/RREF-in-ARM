/*
 * File Name: RREFCalc.c
 * Author: Stephen Montes De Oca
 * Email: deocapaul@gmail.com
 */

#include "RREFCalc.h"

// assembly (with tester)
// error row1 has zero then we will divide by zero
void reduceRows(int start, int end, int rowIndex, 
                int rowEnd, float **matrix) {
  for (int i = 0; i < rowEnd; i++) {
    if (i == rowIndex || matrix[i][start] == 0) {
      continue;
    }

    float scalar = matrix[i][start];
    
    // reducing each row column by column
    for (int j = start; j < end; j++) {
      matrix[i][j] -= scalar * matrix[rowIndex][j];
    }
  }
}

// assembly (with tester)
void swapRows(int col, int row1, int row2, float ** matrix) {
  for (int j = 0; j < col; j++) {
    float temp = matrix[row1][j];

    // swapping rows column by column
    matrix[row1][j] = matrix[row2][j];
    matrix[row2][j] = temp;
  }
}

// assembly (tested via main)
int rref(int row, int col, float ** matrix) {
  // counting the number of pivot columns
  int numPivotCols = 0;
  
  for (int j = 0; j < col; j++) {
    // searching for non zero column entry
    char nonZero = 0;

    for (int i = numPivotCols; i < row; i++) {
      if (matrix[i][j] == 0) {
        continue;
      }
      else {
        nonZero = 1;

        if (i == numPivotCols) {
          break;
        } else {
          swapRows(col, numPivotCols, i, matrix);
          break;
        }
      }
    }
      // checking if we have a pivot column
    if (!nonZero) {
      continue;
    }

    // making row w/ pivot col have a leading coefficient of 1
    descaleRow(j,col,numPivotCols,matrix);

    // reducing each row
    reduceRows(j, col, numPivotCols, row, matrix);

    // updating the number of pivot columns
    numPivotCols++;
  }

  return numPivotCols;
}

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

  for (int i = 0; i < row; i++) {
    // Taking in user input
    printf(INPUT_ROW,i);

    char buf[BUFSIZ];
    int indicator = scanf(STR_FORMAT, buf);

    // if string is improperly formatted then the row is all 0's
    if ( indicator <= 0 ) {
      continue; 
    }

    // extracting row and setting columns
    char * token = strtok(buf, DELIM);
    int j = 0;

    while ( token != NULL ) {
      matrix[i][j] = strtof(token, NULL);
      token = strtok(NULL, DELIM);
      j++;
    }
  }
  printf(NEWLINE);

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
