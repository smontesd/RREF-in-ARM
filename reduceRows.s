/*
 * Filename: reduceRows.s
 * Author: Stephen Montes De Oca
 * Email: deocapaul@gmail.com
 */

@ hardware details for assembler
	.arch	armv7		@ using armv7 instruction set
	.cpu	cortex-a72	@ cpu type
	.syntax	unified		@ using modern syntax

@ external function declarations
	.global	reduceRows	@ declaring function global for linking

@ constants
	.equ	DOUBLE_ALIGN, 3	@ used to align on an 8-byte memory address
	.equ	FP_OFFSET, 20	@ offset to set frame pointer
	.equ	LOCAL_SIZE, 16	@ offset to create space for local variables
	.equ	ARG0, -24	@ offset to access arg0
	.equ	ARG1, -28	@ offset to access arg1
	.equ	ARG2, -32	@ offset to access arg2
	.equ	ARG3, -36	@ offset to access arg3
	.equ	IN_ARG4, 4	@ offset to retrieve arg4 using frame pointer

@ text segment
	.text
	.align	DOUBLE_ALIGN	@ aligns stack pointer to be double word aligned
	.type	reduceRows, %function	@ for linking

/*
 * Function Name: reduceRows()
 * Function Prototype: reduceRows(int colStart, int colEnd, int row,
 *                                int rowEnd, float ** matrix );
 * Description: This function takes in a matrix of floats and using a given row
 *              it will reduce the other rows at the same column so that the
 *              pivot column is the only non zero entry (a condition to be
 *              met in order for a matrix to be in Reduced Row Echelon Form).
 * Parameters: colStart - the index of the pivot column
 *             colEnd - the last column that is needeed to be reduced
 *             row - the index of the row to be used to reduce the other rows
 *             rowEnd - the index of the last row to be reduced
 * Side Effects: the function will modify the matrix given to it
 * Error Conditions: if matrix is NULL a segmentation fault will occur, indices
 *                   must be within valid boundaries of the matrix.
 * Return Value: void
 * Registers Used:
 *
 * Stack Variables:
 *     matrix - [fp + 4] -- address of matrix (arg4)
 *     colStart - [fp - 24] -- index of pivot column
 *     colEnd - [fp - 28] -- index of last column
 *     row - [fp - 32] -- index of the row to reduce other rows with
 *     rowEnd - [fp - 36] -- number of rows in the matrix
 */
reduceRows:
	@ prologue
	push	{r4-r7,fp,lr}	@ creating new stack frame
	add	fp, sp, FP_OFFSET	@ setting frame pointer
	sub	sp, sp, LOCAL_SIZE	@ making room for local variables

	@ function body
	str	r0, [fp, ARG0]	@ storing first argument in stack
	str	r1, [fp, ARG1]	@ storing second argument in stack
	str	r2, [fp, ARG2]	@ storing third argument in stack
	str	r3, [fp, ARG3]	@ storing fourth argument in stack

	mov	r0, 0		@ r0 now holds the index of the first element	
for1:	cmp	r0, r3	

	@ epilogue
	sub	sp, fp, FP_OFFSET	@ closing stack frame
	pop	{r4-r7,fp,lr}	@ restoring push registers
	bx	lr		@ returning to caller function
.end
