# Program 5

# Print String Macro
.macro prtstr %straddr
	li	$v0, 4
	la	$a0, %straddr
	syscall
.end_macro

# Macro for creating array
.macro arr %index %value
	addi $t6, $zero, %index
	mul $t6, $t6, 4
	addi $s7, $zero, %value
	sw $s7, array($t6)
.end_macro 

# Variables
.data
	welcome:	.ascii	"Hello and welcome! This program will decode an MP3 header for the version,\n"
			.asciiz "layter, and bit rate.\n"
	bye:		.asciiz	"\n\nThanks for using the program!"
	prompt:		.asciiz	"\nPlease enter the MP3 header: "
	lversion:	.asciiz "\n\tVersion "
	version:	.word	0
	verindex:	.word	3
	llayer:		.asciiz "\n\tLayer "
	layer:		.word 	0
	layindex:	.word	0
	one:		.asciiz "1"
	two:		.asciiz	"2"
	twofive:	.asciiz "2.5"
	three:		.asciiz	"3"
	reserved:	.asciiz "reserved"
	lbitrate:	.asciiz	"\n\tBit Rate: "
	bitvalue:	.word 	0
	rateunit:	.asciiz	" kbps"
			.align  4
	array:		.space	2560

# Program 
.text
main:
	# Print welcome
	prtstr welcome
	
	# Prompt for MP3 header
	prtstr prompt
	# Catch user input
	jal readhex
	# Move input value to $t0
	move $t0, $v0
	
	# Store bit rate table as an array
	# We are assumming 0 = free and -1 = bad
	arr 5 32
	arr 6 32
	arr 7 32
	arr 8 32
	arr 9 8
	arr 10 64
	arr 11 48
	arr 12 40
	arr 13 48
	arr 14 16
	arr 15 96
	arr 16 56
	arr 17 48
	arr 18 56
	arr 19 24
	arr 20 128
	arr 21 64
	arr 22 56
	arr 23 64
	arr 24 32
	arr 25 160
	arr 26 80
	arr 27 64
	arr 28 80
	arr 29 40
	arr 30 192
	arr 31 96
	arr 32 80
	arr 33 96
	arr 34 48 
	arr 35 224
	arr 36 112
	arr 37 96
	arr 38 112
	arr 39 56 
	arr 40 256
	arr 41 128
	arr 42 112
	arr 43 128
	arr 44 64
	arr 45 288
	arr 46 160
	arr 47 128
	arr 48 144
	arr 49 80
	arr 50 320
	arr 51 192
	arr 52 160
	arr 53 160
	arr 54 96
	arr 55 352
	arr 56 224
	arr 57 192
	arr 58 176
	arr 59 112
	arr 60 384
	arr 61 256
	arr 62 224
	arr 63 192
	arr 64 128
	arr 65 416
	arr 66 320
	arr 67 256
	arr 68 224
	arr 69 144
	arr 70 448
	arr 71 384
	arr 72 320
	arr 73 256
	arr 74 160
	arr 75 -1
	arr 76 -1
	arr 77 -1
	arr 78 -1
	arr 79 -1
	
	# Extract version - shift right 19, mask with 0x03
	srl $t1, $t0, 19
	not $t1, $t1
	and $t1, $t1, 0x03
	sw $t1, version
	prtstr lversion
	
	# Version index
	bne $t1, 2, gver
	j verdone
	gver:
	bnez $t1, not1
	prtstr one
	sw $zero, verindex
	j verdone
	not1:
	bne, $t1, 1, v25
	prtstr two
	j set42
	v25:
	prtstr twofive
	set42:
	addi $t7, $zero, 3
	sw $t7, verindex
	verdone:
	
	# Extract layer - shift right 17, mask with 0x03
	srl $t2, $t0, 17
	not $t2, $t2
	and $t2, $t2, 0x03
	sw $t2, layer
	prtstr llayer
	
	# Layer index
	sw $t2, layindex
	# Layer is reserved
	blt $t2, 3, glay
	prtstr reserved
	j dorow
	# Layer is 1
	glay:
	bnez $t2, v2
	prtstr one
	j dorow
	# Layer is 2
	v2:
	bne, $t2, 1, not12
	prtstr two
	# Layer is 3
	not12:
	bne $t1, 3, do3
	addi $t4, $zero, 0
	add $t4, $t4, 1
	sw $t4, layindex
	do3:
	prtstr three
	dorow:
	
	# Extract bit number - shift right 12, mask with 0x0F
	srl $t3, $t0, 12
	and $t3, $t3, 0x0F
	
	# Find index
	# Set $s0 to column index
	lw $s0, verindex
	lw $s1, layindex
	add $s0, $s0, $s1
	# Set $t3 to row index
	mul $t3, $t3, 5
	# Set $s0 to index value 
	add $s0, $s0, $t3
	# Multiply $s0 by 4
	mul $s0, $s0, 4
	
	# Read table
	lw $s7, array($s0)
	
	# Print Bit Rate
	prtstr lbitrate
	li $v0, 1
	move $a0, $s7
	syscall
	prtstr rateunit
	
	# Goodbye message
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