# RREF in ARM
My first project! Source code written using 32 Bit ARM Assembly Language on my raspberry pi 4.
This project was created to familiarize myself with floating point registers, and functions with multiple parameters.

# Introduction to Reduced Row Echelon Form (RREF)
A matrix is said to be in reduce row echelon form if it satisfies the following conditions:
  1. All rows consisting of only zero's are at the bottom
  2. The leading coefficient of a non-zero row is strictly to the right of the leading coefficient above it
  3. The leading entry in a non-zero row is 1
  4. Each column with a leading coefficient has 1 in all of its rows

# Description
This program will take in two command line arguments which determine the dimension of a matrix (row, col respectively).
This program will then ask the user to pass in each row to fill the matrix, and lastly the passed in matrix will be printed
to stdout in reduced row echelon form.

# How to Compile
Make sure you compile on a cpu that supports an ARM assembly instruction set. To compile make sure all source files are in the
same directory. Then finally type `make RREFCalc` into the shell terminal.

# How to Run
To run the program type the executable's name followed by the number of rows you want the matrix to have, and then the number of columns. For example:

  ./RREFCalc 4 5

# Normal Output
Normal output is printed to stdout. An example of normal output would be the following:

[pi@raspberrypi]:RREF-in-ARM$ ./RREFCalc 3 3\n
ROW 0: 1 2.5 3\n
ROW 1: 2 0 3.14\n
ROW 2: 0 0 -5\n
Printing Matrix in RREF...\n
1.000000 0.000000 0.0000000\n
0.000000 1.000000 0.0000000\n
0.000000 0.000000 1.0000000\n

# Abnormal Output
Abnormal output is printed to stderr. This can occur if an invalid number of command line arguments are passed, or if invalid values for row and col are passed.
