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
	.equ	DOUBLE_ALIGN, 3	@ to align on an 8-byte address
	.equ	FP_OFFSET, 20	@ offset to set frame pointer
	.equ	LOCAL_SIZE, 16	@ offset to create space for local variables
	.equ	I_OFF, -24	@ offset of loop index i on stack
	.equ	J_OFF, -28	@ offset of inner loop index j on stack
	.equ	SCALAR, -32	@ offset of scalar local var
	.equ	IN_ARG4, 4	@ offset to retrieve arg4 using frame pointer
	.equ	PTR_SIZE, 4	@ size of a pointer
	.equ	FLOAT_SIZE, 4	@ size of a float

@ text segment
	.text
	.align	DOUBLE_ALIGN
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
 *     r0 - arg0 -- index of which column to start reducing rows with
 *     r1 - arg1 -- number of columns (index to end loop over columns)
 *     r2 - arg2 -- index of the row being used to reduce the other rows
 *     r3 - arg3 -- number of rows (index to end loop over rows)
 *     r4 - local var -- keeps track of index of outer loop
 *     r5 - local var -- keeps track of index of inner loop
 *     r6 - arg4 -- matrix to row reduce
 *     r7 - local var -- used to store floats and retrive addresses
 * Stack Variables:
 *     i - [fp, -24] -- index of outer loop
 *     j - [fp - 28] -- index of ineer loop
 *     scalar - [fp, -32] -- a temporary variable keeping value of pivot columnn
 */
reduceRows:
	@ prologue
	push	{r4-r7,fp,lr}	@ creating new stack frame
	add	fp, sp, FP_OFFSET	@ setting frame pointer
	sub	sp, sp, LOCAL_SIZE	@ making room for local variables

	@ start of function body
	mov	r4, 0		@ initializing outer loop index (int i = 0)
	str	r4, [fp, I_OFF]	@ storing initial value for loop

	@ outer loop condition check
for1:	cmp	r4, r3		@ checking if r4 >= r3 (i < rowEnd)
	bge	end1		@ exiting outer for loop if so

	@ outer loop body
	cmp	r4, r2		@ checking if r4 == r2 (i == rowIndex)
	beq	next1		@ continue to next iteration

	ldr	r6, [fp, IN_ARG4]	@ loading arg4 into r6 (r6 = matrix)
	mov	r5, PTR_SIZE	@ copying the size of a pointer to r5
	mul	r5, r4, r5	@ calculating offset for ith row retrieval
	add	r6, r6, r5	@ adding offset to reach correct row value
	ldr	r7, [r6]	@ loading address of matrix[i] into r7
	mov	r5, FLOAT_SIZE	@ copying the size of a float to r5
	mul	r5, r0, r5	@ calculating offset for colStart'th col
	add	r7, r7, r5	@ adding offset address of matrix[i][colStart]
	vldr.32	s5, [r7]	@ loading float into r5 from address in r7
	vstr.32	s5, [fp, SCALAR]	@ storing scalar in stack

	vcmp.f32 s5, 0		@ if scalar = 0 skip to next iteration
	vmrs    APSR_nzcv, FPSCR	@ updating current program status reg
	beq	next1		@ continue to next row

	mov	r5, r0		@ copying loop index to r5 (r5 = colStart)
	str	r5, [fp, J_OFF]	@ storing loop index in stack

	@ inner loop condition check
for2:	cmp	r5, r1		@ checking if r5 >= r1 (j < colEnd)
	bge	end2		@ ending inner loop if so

	@ inner loop body
	ldr	r6, [fp,IN_ARG4]	@ loading arg4 into r6 (r6 = matrix)
	mov	r7, PTR_SIZE	@ copying ptr size into r7
	mul	r7, r2, r7	@ calculating offset for rowIndex'th row
	add	r7, r6, r7	@ adding offset to r6 and storing in r7
	ldr	r4, [r7]	@ retrieving address of rowIndex'th row
	mov	r7, FLOAT_SIZE	@ copying sizeof(float) into r7
	mul	r7, r5, r7	@ calculating offset for matrix[rowIndex][j]
	add	r7, r4, r7	@ adding offset to r4 and storing it into r7
	vldr.32	s4, [r7]	@ loading matrix[rowIndex][j] into r4
	vldr.32	s7, [fp, SCALAR]	@ loading scalar into r7
	vmul.f32	s7, s4, s7	@ r7 = scalar * matrix[rowIndex][j]
	ldr	r4, [fp, I_OFF]	@ loading outer loop index in r4 from stack
	mov	r5, PTR_SIZE	@ copying ptr size into r5
	mul	r5, r4, r5	@ calculating offset for ith row
	add	r6, r6, r5	@ adding offset to r6
	ldr	r6, [r6]	@ getting address of matrix[i]
	mov	r4, FLOAT_SIZE	@ copying sizeof(float) to r4
	ldr	r5, [fp, J_OFF]	@ loading index of inner loop
	mul	r5 , r4, r5	@ calculating offset for jth col
	add	r6, r6, r5	@ adding offset
	vldr.32	s4, [r6]	@ loading value of matrix[i][j]
	vsub.f32 s4, s4, s7	@ s4 = matrix[i][j] - scalar*matrix[rowIndex][j]
	vstr.32 s4, [r6]	@ storing matrix[i][j] = s4
	ldr	r4, [fp, I_OFF]		@ retrieving r4 value for next iteration

next2:	@ setting up for next iteration of inner loop
	ldr	r5, [fp, J_OFF]	@ loading inner loop index into r5 (r5 = j)
	add	r5, r5, 1	@ incrementing inner loop index (j++)
	str	r5, [fp, J_OFF]	@ storing inner loop index
	b	for2		@ jumping to inner loop start
end2:	@ end of inner for loop

next1:	@ setting up for next iteration of outer loop
	ldr	r4, [fp, I_OFF]	@ loading outer loop index into r4
	add	r4, r4, 1	@ incrementing outer loop index (i++)
	str	r4, [fp, I_OFF]	@ storing outer loop index
	b	for1		@ jumping to loop start
end1:
	@ epilogue
	sub	sp, fp, FP_OFFSET	@ closing stack frame
	pop	{r4-r7,fp,lr}	@ restoring push registers
	bx	lr		@ returning to caller function
.end
