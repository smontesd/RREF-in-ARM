/*
 * Filename: descaleRow.s
 * Author: Stephen P. Montes De Oca
 * Email: deocapaul@gmail.com
 */

@ hardware description for the assembler
	.arch	armv7		@ armv7 instruction set
	.cpu	cortex-a72	@ cpu type
	.syntax	unified		@ using modern syntax

@ external function declarations
	.global	descaleRow	@ declaring function global for linking

@ constants
	.equ	DOUBLE_ALIGN, 3	@ used to align on an 8 byte memory address
	.equ	FP_OFFSET, 20	@ used to set frame pointer after push
	.equ	PTR_SIZE, 4	@ used to retrieve row at index from address
	.equ	FLOAT_SIZE, 4	@ used to retrieve value in row from address

@ text segment
	.text			@ start of text region
	.align	DOUBLE_ALIGN	@ starting on an 8 byte memory address
	.type	descaleRow, %function	@ for linking

/*
 * Function Name: descaleRow()
 * Function Prototype: void descaleRow( int colIndex, int colEnd, int rowIndex,
 *                     float *matrix[] );
 * Description: Given an array of pointers to each row in an m x n matrix, this
 *              function will start at a given column and descale the row so
 *              that the leading coefficient in the row is one. This function
 *              is intended to be used strictly as a help function for rref
 * Parameters: colIndex - index of a pivot in a matrix
 *             colEnd - index of the last column in the matrix
 *             rowIndex - index of row in matrix to descale
 *             matrix - array of pointers to each row in our matrix
 * Side Effects: matrix will be modified at the given row
 * Error Conditons: If matrix is NULL it will create a segmentation fault. The
 *                  indexes of each parameter must within matrix's range. The
 *                  pivot column of the given row (colIndex) must have a non
 *                  zero entry, else a divide by zero error occurs.
 * Return Value: void
 * Registers used:
 *     r0 - arg0 -- keeps track of loop var and is initialized
 *     r1 - arg1 -- keeps track of loop end index
 *     r2 - arg2 -- indicates which row to descale
 *     r3 - arg3 -- holds the address of our matrix
 *     r4 - local var -- holds the address the given row
 *     r5 - local var -- holds the value of the pivot column (float)
 *     r6 - local var -- used by loop to hold value of float at given row,col
 * Stack Variables: None
 */
descaleRow:
	@ prologue
	push	{r4-r7,fp,lr}	@ creating a new stack frame
	add	fp, sp, FP_OFFSET	@ setting top of stack frame

	@ function body
	mov	r6, PTR_SIZE	@ r6 = 4
	mul	r2, r2, r6	@ calculating row index offset in memory
	add	r3, r3, r2	@ adding offset to r3
	ldr	r4, [r3]	@ setting value of matrix[rowIndex] in r4

	mov	r6, FLOAT_SIZE	@ copying 4 to register 6
	mul	r5, r0, r6	@ calculating col index offset in memory
	add	r4, r4, r5	@ adding colIndex offset to r4
	vldr.32	s5, [r4]	@ assinging matrix[rowIndex][colIndex] into r5

	@ condition check: r0 < r1 >= loop will continue
for:	cmp	r0, r1		@ comparing colIndex with colEnd
	bge	done		@ if colIndex >= colEnd: end loop

	@ loop body
	vldr.32	s6, [r4]	@ r6 = matrix[rowIndex][colIndex]
	vdiv.f32 s6, s6, s5	@ r6 = r6 / r5
	vstr.32	s6, [r4]	@ stores r6 into r4

	@ incrementing loop
	add	r0, r0, 1	@ colIndex++
	add	r4, r4, FLOAT_SIZE	@ r4 incrementing address to next float
	b	for		@ checking condition again
done:

	@ epilogue
	sub	sp, fp, FP_OFFSET	@ closing stack frame
	pop	{r4-r7,fp,lr}	@ restoring preserved registers
	bx	lr		@ returning to caller function
.end
