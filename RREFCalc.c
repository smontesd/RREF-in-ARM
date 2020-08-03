#include "RREFCalc.h"

// assembly (with tester)
// error row1 has zero then we will divide by zero
void reduceRows(int start, int end, int rowIndex, 
                int rowEnd, float *matrix[]) {
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
void swapRows(int col, int row1, int row2, float *matrix[]) {
  for (int j = 0; j < col; j++) {
    float temp = matrix[row1][j];

    // swapping rows column by column
    matrix[row1][j] = matrix[row2][j];
    matrix[row2][j] = temp;
  }
}

// assembly (tested via main)
void rref(int row, int col, float *matrix[]) {
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
}

// C
int main(int argc, char *argv[] ) {
  float row1[] = {1.0,-1.0,3.0};
  float row2[] = {2.0,0.52,0.0};
  float row3[] = {0.0,0.0,0.0};
  float row4[] = {3.3,2.0,-4.0};

  float *prince[] = {row1,row2,row3,row4};

  int row = 4;
  int col = 3;

  rref(row, col, prince);

  // instead of printing write it into a file
  for (int i = 0; i < row; i++) {
    for (int j = 0; j < col; j++) {
      printf("%f ",prince[i][j]);
    }

    printf("\n");
  }
  return 0;
}
