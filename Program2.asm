# CS 2810 Program 2 guide:

# Define any macros we want to use. These are assembler directives that perform string replacements in our code, making repeated tasks easier.
# We usually place them at the start of our file. Once defined, a macro can be used inside of other macros.

# Another way to think of assembly language macros is like a function or named sequence of assembly statements with variables where we can replace
# the variables with registers or labels and simplify our code. The easiest one is simply to print a string

# Macros begin with the ".macro" directive to the assembler, where we give the macro a name and a list of parameters. Here we have a macro named
# "ptrstr" that will print a string, and one parameter called %straddr which will contain the label 
#(NOTE: if the address is in a register we need a different macro)
.macro prtstr %straddr
	li	$v0, 4
	la	$a0, %straddr
	syscall
.end_macro

# to use the macro, we might type: prtstr  welcome in our code in place of the three instructions to print the welcome message

##################################################################
# Declare appropriate variables in the .data section
.data
welcome:	.ascii	"Hello, and welcome to the string length program.\n"
		.ascii 	"You will enter a string, and I'll tell you how many \n"
		.asciiz "characters are in it. Let's begin!\n\n"
prompt: 	.asciiz	"Please enter your string: "
# We use the space directive to save room for a string, no initialization we only save 4 bytes for something.
urstring:	.space	64
label1:		.asciiz	"The string: "  # we have to break the string into pieces
crlf:		.asciiz	" "            # to be able to format our output
label2:		.asciiz	"is "           # usually the compiler does this for us
label3:		.asciiz	" bytes in length"
bye:		.asciiz	"\nHope you had fun, tah tah!!!\n"  # end message
number: 		.word 	0

# Declare any other variables or constants that you want to use, here.

##################################################################
# Finally write your code. NOTE: later we will be writing subroutines, which are simply labeled pieces of code that we can call on to perform 
# computations and that may or may not return values for us.

.text  # This directive tells the assembler that what comes next is code
# Print a welcome message
	prtstr	welcome		# This uses the macro above to print the welcome message
	
# Prompt for the input and read in a string
	prtstr	prompt
	# now read in a string... $v0 == 8, $a0 is the address to fill, $a1 is size
	li	$v0, 8
	la	$a0, urstring   # any address can go here, but we will overwrite $a1 bytes
	li	$a1, 64         # $a1 is the max size of the string (including a NULL)
	syscall             # this is where the string is actually read from keyboard
	
# To determine the length, we will use one register as a counter, one as an index, to get to individual characters, and a third so we can check 
# the character at the index. Start with index = 0, counter = 0
# Loop from the start of the string (address is urstring) and as long as the character at the index is "printable" 
# (i.e., a space or greater in ASCII) go to the next character.
	# Initialize the index and counter registers to zero
	li $t0, 0
	li $t1, 0
	# Label a line, i.e., give it a name like a variable
	# read a byte at the index position of the string (lb  $t2, urstring($t0)
	loop: lb $t2, urstring($t0)
	# branch if the byte is less than space (blt $t2, 32, endlen) to a label
        blt $t2, 32, endlen	
	# Increment index
	addi $t0, $t0, 1
	# Increment count
	addi $t1, $t1, 1
        # Jump to the start of the while loop, the label where we read a byte 
        j loop
        # This is the label after the loop, called "endlen" for end length
        # We need to clean up, by removing any newline in the string. We do this by writing a NULL (zero) character to urstring at the
        # given by the index, only write one byte... sb $zero, urstring($t0)
        endlen: sb $zero, urstring($t0)
        sw $t1, number
# The pseudcode for this loop is:
#        i = 0
#        count = 0
#        while (urstring[i] >= 32) {
#            i++;
#            count++;
#        }
#        urstring[i] = '\0'

# Now all we have to do is print out are results. Just like program 1
# Labels
prtstr label1
prtstr urstring
prtstr crlf
prtstr label2
# Counter Variable
li $v0, 1
lw $a0, number
syscall
# Final label
prtstr label3

# Print goodbye message
prtstr bye

# Exit code gracefully
li $v0, 10
syscall