# Pseudocoode for Program 1

# 1. Declare all strings to print and variables this goes in the ".data" section
.data
welcome:	.ascii	"Hello, welcome to the basic\n"
		.ascii	"You will enter two integers and\n"
		.ascii	"I will compute the sum, product, \n"
		.asciiz	"difference, quotient, and remainder\n\n"
num1:	.word	0
num2:	.word	0
sum:	.word	0
diff:	.word	0
prod:	.word	0
quot:	.word	0
remain:	.word	0
prmpt1:	.asciiz	"Please enter the first integer: "
prmpt2:	.asciiz	"Please enter the second integer: "
label1:	.asciiz	"\nThe sum is: "
label2:	.asciiz	"\nThe difference is: "
label3:	.asciiz	"\nThe product  is: "
label4:	.asciiz	"\nThe quotient is: "
label5:	.asciiz	"\nThe remainder is: "
bye:	.asciiz	"\n\nThanks for computing with us!!\n"
endln:	.asciiz	"\n"

# 2. All code goes in the .text section
.text
# Print the welcome message
li $v0, 4
la $a0, welcome   
syscall		# This has the system print the welcome
# Prompt for the first integer
li $v0, 4
la $a0, prmpt1
syscall
# Read the integer
li $v0, 5
syscall		# $v0 will have the integer read
# Optional save the number to memory  NOT optional move from $v0
# Save the number to $s0
move	$s0, $v0	# Alternate method    add $s0, $v0, $zero
	
# Repeat the above for the second number, save in $s1
li $v0, 4
la $a0, prmpt2
syscall
# Read integer
li $v0, 5
syscall
# Save number
move $s1, $v0

# Compute the sum
add	$t0, $s0, $s1   #  temp0 = num1 + num2
# Save the result to memory
sw	$t0, sum

# Compute the differnce
sub	$t0, $s0, $s1   # temp0 = num1 - num2
# Save to memory
sw $t0, diff

# Multiply uses mul   
mul	$t0, $s0, $s1	# temp0 = num1 * num2
# Save to prod
sw $t0, prod

# Quotient and remainder are the result of integer division
# Remainder in "High"  and Quotient in "Low"
div	$s0, $s1	# divides num1 by num2 putting into Hi and Lo
mfhi	$t0		# $t0 will be the remainder
mflo	$t1		# $t1 will be the quotient
		
# Now save them
sw $t0, remain
sw $t1, quot
			
# 3. Print the results.... lots of li $v0, 4   la $a0.   
# Print the sum
# Print the label
li $v0, 4
la $a0, label1
syscall
# Now print the number
li $v0, 1
lw $a0, sum
syscall

# Print the difference
# Print the label
li $v0, 4
la $a0, label2
syscall
# Now print the number
li $v0, 1
lw $a0, diff
syscall

# Print the product
# Print the label
li $v0, 4
la $a0, label3
syscall
# Now print the number
li $v0, 1
lw $a0, prod
syscall

# Print the quotient
# Print the label
li $v0, 4
la $a0, label4
syscall
# Now print the number
li $v0, 1
lw $a0, quot
syscall

# Print the remainder
# Print the label
li $v0, 4
la $a0, label5
syscall
# Now print the number
li $v0, 1
lw $a0, remain
syscall
				
# Once all five values are printed, print the "bye" message
li $v0, 4
la $a0, bye
syscall
	
# Exit the program gracefully
li $v0, 10
syscall
