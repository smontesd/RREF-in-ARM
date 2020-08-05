/*
 * Filename: RREFCalc.h
 * Author: Stephen Montes De Oca
 * Email: deocapaul@gmail.com
 * Description: This header file contains prototype and constants for RREFCalc.c
 */

#ifndef RREFCALC_H
#define RREFCALC_H
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Constants and strings */
#define DELIM " "
#define INDEX_ROW 1
#define INDEX_COL 2
#define INPUT_ROW "ROW %d: "
#define FLOAT_STR "%f"
#define MATRIX_PROMPT "Printing Matrix in RREF...\n"
#define NEWLINE "\n"
#define SPACE " "
#define STR_FORMAT "%s"

/* Error checking */
#define VALID_ARGS 3
#define INVALID_ARGS "Invalid number of command line arguments passed.\n"
#define INVALID_PARSE "Values passed in are not properly formatted.\n"
#define MALLOC_FAIL "Memory allocation failure.\n"
#define USAGE "\n"\
	"Usage: ./RREFCalc {# of rows} {# of columns}\n" \
	"\n\n"

// External function protypes
void descaleRow( int colIndex, int colEnd, int rowIndex, float ** matrix );


#endif
