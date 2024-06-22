# For this program, the biggest thing we are doing, is learning to use the co-processor. Floating point operations can't be computed the 
# same way integer operations can. The result is, that we use a co-processor, or a different functional unit, to perform floating 
# point computations.

# For this assignment you can use either single precision or double precision floats to do your computations. The only differences will 
# be the specific instructions you use and the registers that hold the values.

# Declaring a float is similar to any other variable, we create a lable, then use a directive to specify the date, and finally provide 
# an initial value. For example, we will need to place the value 1.0 in the register that we will use to compute the exponent. The easiest way 
# to do this is to simply declare a variable of the appropriate type and load it into the register.

# For single precision:
# one:	.float	1.0
# For double precision:
# one:	.double	1.0

# A single precision value is 32-bits, while double precision is 64-bits.

# To load a value into a register, we use the same command, where the first argument is the register to load a value into, and the second is an 
# address, where the value is.  We don't have any floating point equivalent to the load immediate command (li) for integers. To load our variables 
# into the floating point co-processor, we use one of the following depending on how many bits we are working with:
# Single precision:
		#lwc1	$f1, myfloat	# load a single, can use an odd register
# Double precision:
		#ldc1	$f0, mydoub	# load a double, must use even register
		
# This is the Load word/double into Co-processor 1 (the number 1).

# When reading a float from the keyboard, we need to be aware where the typed in number will be. We also need to know where a number must be to 
# be printed out.

# System call 6 reads in a float and puts the result into $f0
# System call 7 reads in a double and puts it into register $f0 (and $f1)
# System call 2 prints a single precision float, from $f12
# System call 3 prints a double precision float from $f12 (and $f13)

#The only other thing left to do is describe how to compute the floating point raised to an integer power.

# The algorithm I recommend is:
# 1. Place the value 1.0 into the $f12 register (we print from there)
# 2. if the exponent is negative (bltz branch less than zero) branch to step 4
# 3. Label this line, it is the non-zero exponent
#	a. branch if the exponent is zero, to step 5
#	b. multiply $f12 by the float read in ($f0)  use mul.s  or mul.d
#	c. subtract one from the exponent (addi  -1  or   subi   1)
#	d. jump to step 3a
# 4. Label this line so you can jump to it from step 2
#	a. branch if the exponent equals zero (beqz)  to step 5
#	b. divide $f12 by the float read in ($f0)    use div.s  or  div.d
#	c. add one to the exponent  (addi  1)
#	d. jump to step 4
# 5. At this point, the result of the float raised to the integer exponent is in register $f12 and can be printed or used in another computation
# You can put all of that into a procedure

###### CODE ######
# Print string macro
.macro prtstr %straddr
	li	$v0, 4
	la	$a0, %straddr
	syscall
.end_macro

# Variables
.data
	welcome:	.ascii	"Hello and welcome! In this program you will be able to calculate the values\n"
			.asciiz	"of floating point numbers to an exponent. Good luck!\n"
	bye:		.asciiz "\n\nThanks for using this program!"
	continue:	.asciiz "\n\nWould you like to continue (Y/y = yes): "
	prompt1:	.asciiz	"\n\nPlease enter a floating point value: "
	prompt2:	.asciiz	"Please enter an integer: "
	answer:		.asciiz "\nYour floating point value is now: "
	ucontinue:	.space	4
	startfloat: 	.float	1.0

# Running code
.text
main:
	# Print a welcome message
	prtstr welcome
	
	# Prompt the user to enter a floating point
	start: 
	prtstr prompt1
	# Catch user input stored in $f0
	li $v0, 6
	syscall
	
	# Prompt the user for the integer power
	prtstr prompt2
	# Catch user input
	li $v0, 5
	syscall
	# Save integer
	move $t2, $v0
	
	# Compute using procedure
	jal float2int
	
	# Ask if they want to continue
	prtstr continue
	# Catch user input
	li $v0, 8
	la $a0, ucontinue
	li $a1, 2
	syscall
	# Loop back to start if yes or continue if anything else
	la $t0, ucontinue
	lb $t1, 0($t0)
	beq $t1, 89, start
	beq $t1, 121, start
	
	# Goodbye message
	prtstr bye
	# Exit code gracefully
	li $v0, 10
	syscall

# This procedure computes the result of a float raised to an integer exponent (positive or negative). The result is in $f12. It requires
# a declared memory location named one, containing a ___ precision value of 1. The floating point number should be in $f0 and the integer 
# exponent should be in ___.
float2int: 
	# Set $f12 to 1.0
	lwc1 $f12, startfloat
	# If exponent is negative branch to negative
	bltz $t2, negative
	# Non-zero exponent
	nonzero:
		# Branch to zero if the exponent is zero
		beqz $t2, zero
		# Multiply $f12 by $f0 use mul.s  or mul.d
		mul.s $f12, $f12, $f0
		# Subtract one from the exponent
		addi $t2, $t2, -1
		# Jump back to nonzero start
		j nonzero
	# Negative exponent
	negative:
		# Branch to zero if the exponent is zero
		beqz $t2, zero
		# Divide $f12 by $f0
		div.s $f12, $f12, $f0
		# Add one to the exponent
		addi $t2, $t2, 1
		# Jump back to negative start
		j negative
	# When computation is finished and time to print
	zero:
	# Print answer string
	prtstr answer
	# Print value
	li $v0, 2
	syscall
	
	# Return
	jr $ra
