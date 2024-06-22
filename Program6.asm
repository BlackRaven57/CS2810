# Program 6

# Print String Macro
.macro prtstr %straddr
	li	$v0, 4
	la	$a0, %straddr
	syscall
.end_macro

# Variables
.data
	welcome:	.ascii	"Welome to this program! You will be able to add a person to a linked list, print\n"
			.asciiz	"the list, or exit this program.\n"
	bye:		.asciiz	"\nThanks for using the program, hope to see you back soon!"
	menu:		.ascii	"\nPlease select one of the following:\n"
			.ascii	"\t1 - print list\n"
			.ascii	"\t2 - add person\n"
			.asciiz	"\t3 - exit\n"
	prompt1:	.asciiz	"What would you like to do? "
	prompt2:	.asciiz "\nPlease enter a name (40 characters max): "
	prompt3:	.asciiz "Please enter an age: "
	llist:		.asciiz	"\n********** List Contents **********\n"
	lname:		.asciiz	"Name: "
	lage:		.asciiz	"Age: "
	lline:		.asciiz	"\n------------------------------\n"
	empty:		.asciiz	"\nThe list is empty.\n"

# Program
.text
main:
	# Print welcome
	prtstr welcome
	
	# Set head, $s7
	li $s7, 0
	
	# Display menu with options
	start: 
	prtstr menu
	# Prompt user for choice
	prtstr prompt1
	# Catch user input
	li $v0, 5
	syscall
	# Load int to $t0
	move $t0, $v0
	
	# Print the list if 1
	beq $t0, 1, printlist
	# Add a user if 2
	beq $t0, 2, adduser
	
	# Goodbye message
	prtstr bye
	# Exit code gracefully
	li $v0, 10
	syscall

# Print the elements in the list or display it is empty	
printlist:
	# If head points to null
	bnez $s7, continue
	prtstr empty
	j start
	
	# If head is not empty
	continue:
	# List Label
	prtstr llist
	# Set temp pointer to head
	move $s6, $s7
	
	# Loop until null pointer
	loop:	
	# Print name label
	prtstr lname
	# Print name
	li $v0, 4
	move $a0, $s6
	li $a1, 40
	syscall
	
	# Print age label
	prtstr lage
	# Print age
	li $v0, 1
	lw $a0, 40($s6)
	syscall
	
	# Print end line for in betwee
	prtstr lline
	
	# Change pointer to next pointer
	lw $s6, 44($s6)
	
	# Check for null pointer
	bnez $s6, loop
	# Branch to start with nothing left
	j start
	
# Add a user to the linked list
adduser:
	# Allocate new element space
	li $v0, 9
	li $a0, 48
	syscall 
	
	# Link new element to list
	sw $s7, 44($v0)
	# Link head to new element
	move $s7, $v0
	
	# Prompt for name
	prtstr prompt2
	# Catch name
	li $v0, 8
	move $a0, $s7
	li $a1, 41
	syscall
	
	# Prompt for age
	prtstr prompt3
	# Catch age in $t0
	li $v0, 5
	syscall
	sw $v0, 40($s7)
	
	# Jump back to menu
	j start
