/*
 * File Name: rref.s
 * Author: Stephen Montes De Oca
 * Email: deocapaul@gmail.com
 */

@ hardware description for the assembler
	.arch	armv7		@ using armv7 instruction set
	.cpu	cortex-a72	@ cpu type
	.syntax	unified		@ using modern syntax

@ external function declarations
	.extern	descaleRow
	.extern	reduceRows
	.extern	swapRows
	.global	rref		@ making function global for linking

@ constants
	.equ	DOUBLE_ALIGN, 3	@ used to align on an 8-byte address
	.equ	FP_OFFSET, 12	@ used to set frame pointer
	.equ	LOCAL_SIZE, 16	@ used to make space for local variables
	.equ	REG_SIZE, 16	@ used to store registers before a function call
	.equ	PTR_SIZE, 4	@ sizeof(float *)
	.equ	FLOAT_SIZE, 4	@ sizeof(float)
	.equ	PIVOT_OFF, -16	@ offset for numPivotCols
	.equ	J_OFF, -20	@ offset for j loop index
	.equ	NOZERO_OFF, -24	@ offset for nonZero local var
	.equ	I_OFF, -28	@ offset for i loop index
	.equ	R0_OFF, -32	@ offset for r0
	.equ	R1_OFF, -36	@ offset for r1
	.equ	R2_OFF, -40	@ offset for r2
	.equ	IN_ARG4, -44	@ offset for arg4 of reduceRows

@ text segment
	.text
	.align	DOUBLE_ALIGN	@ aligning on 8-byte memory address
	.type	rref, %function	@ declaring type function for linking

/*
 * Function Name: rref()
 * Function Prototype: int rref( int row, int col, float ** matrix );
 * Description: This function will put a matrix into reduced row echelon form
 * Parameters: row - the number of rows in matrix
 *             col - the number of columns in matrix
 *             matrix - array of pointers to each row (float arrays)
 * Side Effects: The matrix will be in reduced row echelon form
 * Error Conditions: Matrix cannot be NULL, row and col must be within valid
 *                   dimensional boundaries
 * Return Value: number of pivot columns (dimension of matrix)
 * Registers Used:
 *     r0 - arg0 -- # of rows in matrix
 *     r1 - arg1 -- # of cols in matrix
 *     r2 - arg2 -- address of matrix
 *     r3 - local var -- holds index of outer loop (j)
 *     r4 - local var -- holds index of inner loop (i)
 *     r5 - local var -- used for accessing values in matrix
 * Stack Variables:
 *     numPivotCols - [fp, -16] -- keeps track of the number of pivot columns
 *     j - [fp, -20] -- keeps track of outer loop index
 *     nonZero - [fp, -24] -- used for looking for nonZero pivot columns
 *     i - [fp, -28] -- keeps track of inner loop index
 */
rref:
	@ prologue
	push	{r4,r5,fp,lr}	@ preserving registers and creating new stack
	add	fp, sp, FP_OFFSET	@ setting frame pointer
	sub	sp, sp, LOCAL_SIZE	@ making space for local variables

	@ function body
	mov	r3, 0		@ copying zero to r3 for local var init
	str	r3, [fp, PIVOT_OFF]	@ initializing numPivotCols
	str	r3, [fp, J_OFF]	@ initializing j loop index

	@ outer loop start
for1:	cmp	r3, r1		@ checking j loop index
	bge	end1		@ if !(r3 < r1) end loop

	@ outer loop body
	mov	r4, 0		@ copy zero to r4 for local var init
	strb	r4, [fp, NOZERO_OFF]	@ storing r4 in stack as char
	ldr	r4, [fp, PIVOT_OFF]	@ loading numPivotCol in r4
	str	r4, [fp, I_OFF]	@ initializing inner loop index to numPivotCol

	@ inner loop start
for2:	cmp	r4, r0		@ checking i loop index
	bge	end2		@ if !(r4 < r0) end loop

	@ inner loop body
	mov	r5, PTR_SIZE	@ copying sizeof(float *) to r5
	mul	r5, r4, r5	@ calculating offset for ith row
	add	r5, r2, r5	@ retrieving address of matrix[i]
	ldr	r5, [r5]	@ loading matrix[i] from memory
	mov	r4, FLOAT_SIZE	@ copying sizeof(float) into r4
	mul	r4, r3, r4	@ calculating offset for jth col
	add	r4, r5, r4	@ adding offset
	vldr.32	s5, [r4]	@ loading float into r4 (r4 = matrix[i][j])
	vcmp.f32	s5, #0		@ checking if float == 0
	vmrs    APSR_nzcv, FPSCR
	beq	next2		@ continue to next iteration: matrix[i][j] = 0

	mov	r5, 1		@ copying 1 to r5 and loading it to memory
	strb	r5, [fp, NOZERO_OFF]	@ char nonZero = 1;
	ldr	r4, [fp, I_OFF]	@ loading i into r4 from memory
	ldr	r5, [fp, PIVOT_OFF]	@ loading numPivotCols into r5
	cmp	r4, r5		@ checking if i == numPivotCols
	beq	end2		@ breaking from loop if equal

	sub	sp, sp, REG_SIZE	@ loading registers onto stack for call
	str	r0, [fp, R0_OFF]	@ storing row in stack
	str	r1, [fp, R1_OFF]	@ storing col in stack
	str	r2, [fp, R2_OFF]	@ storing matrix in stack
	ldr	r0, [fp, PIVOT_OFF]	@ loading numPivotCols in r0
	ldr	r1, [fp, I_OFF]	@ loading i into r1
	ldr	r2, [fp, R2_OFF]	@ loading matrix into r2
	bl	swapRows	@ calling swapRows(numPivotCols, i, matrix);
	@ restoring registers after function call
	ldr	r0, [fp, R0_OFF]
	ldr	r1, [fp, R1_OFF]
	ldr	r2, [fp, R2_OFF]
	add	sp, sp, REG_SIZE	@ closing space created for registers
	b	end2		@ breaking from loop

next2:	@ setting up for next iteration
	ldr	r3, [fp, J_OFF]	@ loading value of j in r4
	ldr	r4, [fp, I_OFF]	@ loading value of i in r4
	add	r4, r4, 1	@ i++
	str	r4, [fp, I_OFF]	@ storing value of i++ in stack
	b	for2

end2:	@ end of inner loop  (within outer loop body)
	ldrb	r3, [fp, NOZERO_OFF]	@ loading nonZero into r3
	cmp	r3, 0		@ checking if noZero == 0
	beq	next1		@ skip to next iteration: no pivot cols found
	
	sub	sp, sp, REG_SIZE	@ creating space for registers
	@ preserving registers for function call
	str	r0, [fp, R0_OFF]
	str	r1, [fp, R1_OFF]
	str	r2, [fp, R2_OFF]
	@ setting up for function call
	ldr	r0, [fp, J_OFF]
	ldr	r2, [fp, PIVOT_OFF]
	ldr	r3, [fp, R2_OFF]
	bl	descaleRow	@ calling descaleRow(j,col,numPivotCol,matrix);
	@ setting up for next function call
	ldr	r0, [fp, J_OFF]
	ldr	r1, [fp, R1_OFF]
	ldr	r2, [fp, PIVOT_OFF]
	ldr	r3, [fp, R0_OFF]
	@ making space for additional args
	ldr	r4, [fp, R2_OFF]
	str	r4, [fp, IN_ARG4]
	@ calling reduceRows(j, col, numPivotCol, row, matrix);
	bl	reduceRows
	@ restoring registers after function call
	ldr	r0, [fp, R0_OFF]
	ldr	r1, [fp, R1_OFF]
	ldr	r2, [fp, R2_OFF]
	@ closing space made for registers
	add	sp, sp, REG_SIZE
	ldr	r4, [fp, PIVOT_OFF]	@ loading numPivotCols into r4
	add	r4, r4, 1	@ incrementing numPivotCols by 1
	str	r4, [fp, PIVOT_OFF]	@ storing numPivotCols++ in memory

next1:	@ setting up for next iteration
	ldr	r3, [fp, J_OFF]	@ loading j into r3
	add	r3, r3, 1	@ j++
	str	r3, [fp, J_OFF]	@ storing j in the stack
	b	for1

end1:	@ end of outer loop
	ldr	r0, [fp, PIVOT_OFF]	@ loading return value in r0

	@ epilogue
	sub	sp, fp, FP_OFFSET	@ closing stack frame
	pop	{r4,r5,fp,lr}	@ restoring preserved registers
	bx	lr		@ returning to caller function
.end
