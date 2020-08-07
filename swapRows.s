/*
 * File Name: swapRows.s
 * Author: Stephen Montes De Oca
 * Email: deocapaul@gmail.com
 */

@ hardware description for the assembler
	.arch	armv7		@ using armv7 instruction set
	.cpu	cortex-a72	@ cpu type
	.syntax	unified		@ using modern syntax

@ external function declarations
	.global	swapRows	@ declaring function global for linking

@ constants
	.equ	DOUBLE_ALIGN, 3	@ used to align on a n 8-byte word address
	.equ	FP_OFFSET, 12	@ offset to align frame pointer
	.equ	PTR_SIZE, 4	@ sizeof(float *)

@ text region
	.text
	.align	DOUBLE_ALIGN	@ aligning on an 8-byte address
	.type	swapRows, %function	@ declaring swapRows as a function

/*
 * Function Name: swapRows()
 * Function Prototype: void swapRows( int row1, int row2, float ** matrix );
 * Description: Given a matrix, and two indices of rows to swamp, this function
 *              will swap both row in the matrix.
 * Parameters: row1 - index of first row to swap
 *             row2 - index of the second row to swap with
 *             matrix - array of pointers to float arrays
 * Side Effects: matrix is modified
 * Error Conditions: row1 and row2 must be in bounds of matrix, and matrix
 *                   passed cannot be NULL
 * Return Value: void
 * Registers Used:
 *     r0 - arg0 -- contains index of first row to swap
 *     r1 - arg1 -- contains index of other row to swap with
 *     r2 - arg2 -- contains address of matrix in memory
 *     r3 - local var -- used to calculate row location
 *     r4 - local var -- used to store offset of row1
 *     r5 - local arv -- used to store offset of row2
 * Stack Variables: None
 */
swapRows:
	@ prologue
	push	{r4,r5,fp,lr}	@ creating new stack
	add	fp, sp, FP_OFFSET	@ adjusting position of frame pointer

	@ function body
	mov	r3, PTR_SIZE	@ copying sizeof(float *) to r3
	mul	r4, r3, r0	@ calculating offset for address of row1
	mul	r5, r3, r1	@ claculating offset for addres of row2
	ldr	r0, [r2, r4]	@ retrieving address of row1
	ldr	r1, [r2, r5]	@ retrieving address of row2
	str	r0, [r2, r5]	@ storing address of row1 in matrix[row2]
	str	r1, [r2, r4]	@ storing address of row2 in matrix[row1}

	@ epilogue
	sub	sp, fp, FP_OFFSET	@ realigning stack pointer
	pop	{r4,r5,fp,lr}	@ restoring preserved registers
	bx	lr		@ returning to caller function
.end
