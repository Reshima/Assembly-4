# who:  Rachael Shima
# what:  Lab4
		 # Lab4.asm
# why: Lab4 for cs264 
		 # This program searches through a predefined array using binary searches
		 # The user will input a value and the program will determine if it is in the stack
# When: 13 May 2017
		 # 18 May 2017
		 
	.data

		Integers: .asciiz "How many integers would you like to store?: "
		line: 	  .asciiz "\n"
		space: 	  .asciiz " "
		Stack:    .asciiz "Please enter an integer: "
		sort:     .asciiz "Sorted Stack:"
		find:     .asciiz "What integer would you like to find?: "
		loc:	  .asciiz "That integer is in the stack. "
		missing:  .asciiz "That integer is not in the stack. "
		
		.text
		 .globl main

main:
			move $s8, $sp				#store stack
		
			li $t0, 8					#store the user integer in $t0
			li $t1, 0					#initialize loop counter
				
			sll $t2, $t0, 2				#create array size
			subu $sp, $sp, $t2			#create space in the stack
			li $t2, 4					#create first value
			move $t3, $s8				#initiallize array pointer
stack:
			beq $t1, $t0, print			#branch if stack is full
			sw $t2, 0($t3)				#store value in stack
			addi $t3, $t3, -4			#decriment stack pointer
			addi $t2, $t2, -1			#create new value
			addi $t1, $t1, 1			#incriment loop counter
			b stack						#loop
			
print:
			la $a0, sort				#display sorted message
			li $v0, 4					#print string
			syscall
			
			move $t2, $s8				#move $t2 to top of the stack
printloop:
			la $a0, line				#start new line
			li $v0, 4					#print string
			syscall
			
			lw $a0, 0($t2)				#grab int from stack at index
			li $v0, 1					#print int
			syscall
			
			addi $t1, $t1, -1			#decremint counter
			addi $t2, $t2, -4			#decremint stack pointer
			beq $t1, 0, Find			#branch if stack is empty
			b printloop					#loop

Find:							
			move $t5, $sp				#move $t5 to point at the bottom of the stack
			move $t2, $s8				#move $t2 to point at the top of the stack

			la $a0, line				#start new line
			li $v0, 4					#print string
			syscall

			la $a0, find				#load message
			li $v0, 4					#print string
			syscall
			
			li $v0, 5					#read user int
			syscall
			
			move $t6, $v0				#store user int for reference
			jal Search					#jump and save address to return to
			
			beq $t1, 1, found			#branch if integer was found

			la $a0, missing				#load missing message
			li $v0, 4					#print string
			syscall
			
			b finish					#end program
			
Search:									#int binSearchRec(int val, uint &s, int low, int high) 
			addi $sp, $sp, -4			#make room to store $ra
			sw $ra, 0($sp)				#store the value of $ra for reference
			bgt $t5, $t2, miss			#if (low > high)
			subu $t8, $t2, $t5			#int mid = (low + high) for space
			srl $t8, $t8, 3				#divide by 4 for number of ints, divide by 2 for mid
			sll $t8, $t8, 2				#retrieve address
			addu $t8, $t8, $t5			#find address in stack 
			lw $t7, 0($t8)				#load integer at index for comparison
			blt $t7, $t6, plus			#else if (s[mid] < val)
			bgt $t7, $t6, minus			#else if (s[mid] > val)
			li $t1, 1					#load true value
		    lw $t3, 0($sp)				#load the value at index into $t3
			addi $sp, $sp, 4			#incriment $sp for next $ra value
			jr $t3						#return the latest $ra value
			
minus:									
			addi $t8, $t8, -4
			move $t2, $t8				#move high up to mid
			jal Search					#return binSearchRec(val, s, low, mid - 1);
			lw $t3, 0($sp)				#load the value of $sp into $t3
			addi $sp, $sp, 4			#incriment $sp for the next $ra value
			jr $t3						#return to the latest $ra value
			
plus:
			addi $t8, $t8, 4
			move $t5, $t8				#move low to mid 
			jal Search					#return binSearchRec(val, s, mid + 1, high)
			lw $t3, 0($sp)				#load the next $ra value into $t3
			addi $sp, $sp, 4			#incriment $sp for the next $ra value
			jr $t3						#return the latest $ra value

miss:
			lw $t3, 0($sp)				#load the next $ra value into $t3
			addi $sp, $sp, 4			#incriment $sp for the next $ra value
			jr $t3						#return the latest $ra value

found:
			la $a0, loc 				#display found message
			li $v0, 4					#print string
			syscall

finish:
			move $sp, $s8				#reset stack
			li $v0, 10					#terminate
			syscall