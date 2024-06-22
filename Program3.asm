# Program 3 guide:

# For this programming assignment, we are tyring to display a value contained in a two byte field, in human readable form.
# The old FAT file system was used by MicroSoft until Windows NT came out. It was the primary file system till Windows XP came out in 2001. 
# It is also the primary file system for most SD cards that digital cameras, and now phones, use.

# We are going to decode a date given the 16 bit (2-byte) value used to encode it. If we were to use a hexadecimal disk editor to 
# look a the entries, we would see the value of this field. In all Intel x86 family of processors, the representation of information 
# on disk and in main memory is in Little Endian form (least significant byte first).  

# Unfortunately, Microsoft made their documentation for FAT as a Big-Endian definition of the contents of data. The result is we:
	# Read in the 2-byte hexadecimal value
	# Convert the Little Endian byte order to Big Endian
	# Use the data about the FAT date field to determine the date

# FAT data entry (2 bytes in Big Endian order):
	# Leftmost 7 bits - year offset from 1980
	# Middle 4 bits - month number, 1 to 12
	# Rightmost 5 bits - day number, 1 to 31

# Once we have the date in Big Endian order, we can shift and mask to get the numeric values
# Year - shift right logical (srl) 9, then "mask" with hex 0x07F (or mask with 0x0FE00 and then srl (shift right logical) 9)
# Month - shift right logical 5, then mask with 0x0F
# Day - mask with 0x01F

# A mask is simply a bit pattern. Use the and operation to select the bits that are set to '1' in the mask.  
# Value:        0 0 1 1   0 1 1 0   1 0 0 1   0 1 1 1 
# hex 0x01F     0 0 0 0   0 0 0 0   0 0 0 1   1 1 1 1
# and result:   0 0 0 0   0 0 0 0   0 0 0 1   0 1 1 1  = 23  so day 23

# Each 4-bit value is a hex digit
# Binary   0000  0001  0010  0011  0100  0101  0110  0111  1000  1001  1010  1011  1100  1101  1110  1111 
# Hex        0     1     2     3     4     5     6     7     8     9   A=10  B=11  C=12  D=13  E=14  F=15

# To Convert from Little Endian to Big Endian, we won't worry about the general case, just swap the two low order bytes of a register
# If $t0 has the Little Endian value return from the readhex function:
		#srl	$t1, $t0, 8		# shift $t0 right 8 bits, and save in $t1
		#sll	$t2, $t0, 8		# shift $t0 left 8 bits, save in $t2
		#and $t2, $t2, 0x0FF00 		# take only the next to last byte of $t2
		#or  $t0, $t2, $t1		# save the Big Endian valule into $t0
# Now $t0 will have the value we get the year, month, and day from.

# Arrays: We need an array of strings to print the month. To address an array, we need each element to be the same size. We form the array 
# by creating strings for each month name, then we use an offset from the array equal to (month_number -1) * size_of_each_string
     
# In the data area, our string array (first part only) looks like:
#months:	.ascii	"January \0  "  
		#.ascii	"February \0 "	
			
		#.ascii	"September \0"

# We list all 12 months. September is the longest. The '\0' is a NULL, a single character, so each string is 11 characters long. Put the 
# NULL one space after the name so we can get April 25, 2020. The space before the day is printed with the month name.  

# Suppose $t4 has the number of the month in it. We need to load the address of that correct string into $a0 to print it.  
			#sub	$t4, $t4, 1	# or add $t4, $t4, -1
			#mul	$t4, $t4, 11	# multiply by string length
			#la	$a0, months
			#add	$a0, $a0, $t4	# $a0 is the address of the correct month
			
###### REQUIREMENTS ######
# For this assignment:
# - print a welcome |
# - prompt for the 2-byte hex date entry from the disk |
# - use the readhex function to get the value into $v0 |
# - save to another register so we can use it |
# - convert the register value to Big Endian |
# - use a procedure (function) to print the month |
# - use a procedure to print the day |
# - use a procedure to print the year (1980 plus the year in the FAT entry) |
# - print a goodbye message |

# To make a procedure:
	# Give it a name, just like a jump address = domonth:
	# Then write the code for the procedure 
	# Return to where called with jump register to return address
			#jr	$ra	
	# To call a procedure use the jal (jump and link) instruction with the procedure name as the argument. 
	# It will load the return address into $ra
			#jal	domonth

###### CODE ######
.macro prtstr %straddr
	li	$v0, 4
	la	$a0, %straddr
	syscall
.end_macro

.data
	welcome:	.ascii 	"Welcome! This assignment will take a 2-byte\n"		
			.asciiz "hex date and convert it in to a reable date.\n\n"
	prompt: 	.asciiz "Please enter the date field: "
	prompt2:	.asciiz "The entered value converted to big endian is: "
	prompt3:	.asciiz "\nThe date of the entered value is: "
	comma:		.asciiz	", "
	bye: 		.asciiz	"\n\nThanks for using this program!\n"
	hex:		.space	32
	months: 	.ascii 	"January \0  "
			.ascii 	"February \0 "
			.ascii 	"March \0    "
			.ascii 	"April \0    "
			.ascii 	"May \0      "
			.ascii 	"June \0     "
			.ascii 	"July \0     "
			.ascii 	"August \0   "
			.ascii 	"September \0"
			.ascii 	"October \0  "
			.ascii 	"November \0 "
			.ascii 	"December \0 "
	year: 		.word	0
	day:		.word	0
	
.text	
main:
	# Print the welcome message
	prtstr welcome
	
	# Prompt for the date field
	prtstr prompt
	jal readhex
	# Save result of readhex
	move $t0, $v0
	
	# Print little endian value
	prtstr prompt2
	
	# Convert to big endian
	srl	$t1, $t0, 8		# Shift $t0 right 8 bits, and save in $t1
	sll	$t2, $t0, 8		# Shift $t0 left 8 bits, save in $t2
	and $t2, $t2, 0x0FF00 		# Take only the next to last byte of $t2
	or  $t0, $t2, $t1		# Save the Big Endian value into $t0
	
	# Print big endian value
#	prtstr prompt2
#	li $v0, 4
#	move $a0, $t0
#	syscall
	
	# Figure out each piece of the date
	# Year - shift right logical (srl) 9, then "mask" with hex 0x07F
	srl $t1, $t0, 9
	and $t1, $t1, 0x07F

	# Month - shift right logical 5, then mask with 0x0F
	srl $t2, $t0, 5
	and $t2, $t2, 0x0F
	
	# Day - mask with 0x01F
	and $t0, $t0, 0x01F
	
	# Print prompt
	prtstr prompt3
	jal pmonth
	jal pday
	jal pyear
				
	# Print bye message
	prtstr bye	
	# Exit code gracefully
	li $v0, 10
	syscall
	
	# Read a Hex value
	readhex:   
		addi $sp, $sp, -8   # make room for 2 registers on the stack
		sw   $t0, 4($sp)    # save $t0 on stack, used to accum6ulate
		sw   $t1, 0($sp)    # save $t1 on stack, used to count
		li   $t1, 8         # We will read up to 8 characters
		move $t0, $zero     # Initialize hex value to zero
	
	# Beginning of loop to read a character
	rdachr: 
		li   $v0, 12         
		syscall              # syscall 12 reads a character into $v0
		blt  $v0, 32, hexend # Read a non-printable character so done
		blt  $v0, 48, hexend # Non-hex value entered (special char)
		blt  $v0, 58, ddigit # A digit 0-9 was entered
		blt  $v0, 65, hexend # A special character was entered so done
		blt  $v0, 71, uphex  # A hex A-F was entered so handle that
		blt  $v0, 97, hexend # A non-hex letter or special, so done
		blt  $v0, 103, lhex  # A hex a-f was entered so handle that
		j    hexend          # Not a hex so finish up
	ddigit:	
		addi $v0, $v0, -48   # Subtract the ASCII value of 0 to get num
	        j    digitdone       # value to OR is now in $v0 so OR
	uphex:	
		addi $v0, $v0, -55   # Subtract 65 and add 10 so A==10
		j    digitdone       # hex value determined, so put in 
	lhex:	
		addi $v0, $v0, -87   # Subtract 97 and add 10 so a==10
	digitdone:
		sll  $t0, $t0, 4     # New value will fill the 4 low order bits
	        or   $t0, $t0, $v0   # Bitwise OR $t0 and $v0 to enter hex digit
        	addi $t1, $t1, -1    # Count down for digits read at zero, done
        	beqz $t1, hexend     # If $t0 is zero, we've read 8 hex digits
   	     	j    rdachr          # Loop back to read the next character
	hexend:	
		move $v0, $t0        # Set $v0 to the return value
		lw   $t1, 0($sp)     # pop $t1 from the stack
		lw   $t0, 4($sp)     # pop $t0 from the stack
		addi $sp, $sp, 8     # free the stack by changing the stack pointer
		jr   $ra             # Return to where called
	
	# Procedure to print month
	pmonth: 
		# Take month number and subtrack 1 to get index value
		sub	$t2, $t2, 1	# or add $t4, $t4, -1
		mul	$t2, $t2, 11	# multiply by string length
		la	$a0, months
		add	$a0, $a0, $t2	# $a0 is the address of the correct month
		# Print month
		li $v0, 4
		syscall
		# Return
		jr $ra
	
	# Procedure to print day
	pday:
		# Save day
		sw $t0, day
		# Print number
		li $v0, 1 
		lw $a0, day
		syscall
		# Print comma
		prtstr comma
		# Return
		jr $ra
	
	# Procedure to print year
	pyear:
		# Add 1980
		add $t1, $t1, 1980
		# Save year
		sw $t1, year
		# Print number
		li $v0, 1
		lw $a0, year
		syscall
		# Return
		jr $ra