# Title: q3		Filename: q3
# Author: Dor Pascal	Date: 14th of August 2022
# Description:	The program finds the most common letter in a saved string and delet its occurrences
# Input: non
# Output:	1) Printing the most common letter and its number of occurrnces.
#		2) The string - printed in a lexicographic order
#		3) A dialog box that enables the user to restart the program on the shorten string.
################# Data segment #####################
.data
	CharStr: .asciiz "AEZKLBXWZXYALKFKWZRYLAKWLQLEK"
	ResultArray: .byte 0:26
	task2_message1: .asciiz "The character: \""
	task2_message2: .asciiz "\" is saved "
	task2_message3: .asciiz " times.\n"
	repeat_quastion:.asciiz "Delete is complete. Would you like to start again with the new string?"
################# Code segment #####################
.text
.globl main
main:
	la $a0, CharStr 	# CahrStr is in $a0
	la $a1, ResultArray	# Results is in $a1
	jal char_occurrences	# calling the procedure
	add $s0,$v0,$0		# save the returned hasccii val in $s1		
	add $s1,$v1,$0		# save the returned occurences value in $s0

	# print the char and its occurrences num:
	li $v0, 4       	# system call code for print_str
	la $a0, task2_message1  # address of string to print
	syscall			
	li $v0, 11       	# system call code for print_char
	add $a0,$s0,$0    	# $a0 has the hascii value of the letter
	syscall
	li $v0, 4       	
	la $a0, task2_message2  
	syscall			
	li $v0,1		# system call code for print_int
	add $a0,$s1,$0 		# integer to print (number of occurrences) is in s0
	syscall			
	li $v0, 4       	
	la $a0, task2_message3  
	syscall	
	
	la $a1, ResultArray	
	jal print_Char_by_occurrences 

	la $a0,CharStr
	add $a1,$s0,$0
	jal delete
	
	add $t0,$a0,1		# address of CharStr[1] is in $t0
	lbu $t1, 0($t0)		# $t1 = CharStr[1]	
	beq $t1, $zero,exit 	# CharStr[1] == '\0' <=> only one char - at CharStr[0]
	li $v0, 50       	# system call code for print_str
	la $a0, repeat_quastion  # address of string to print
	syscall
	bne $a0, $0, exit	# go to exit if user chose so
	la $t0, ResultArray
	add $t3, $0, $0
reset_results_loop:
	sb $0,0($t0)		#reset word = 2 byte
	addi $t0, $t0, 1
	add $t3,$t3,1
	bne $t3,26,reset_results_loop
	j main
exit:
	li $v0,10		# Exit program
	syscall

char_occurrences:
	addiu $sp, $sp, -12 	# adjust stack for 3 item
	sw $ra, 8($sp)		# save return address
	sw $a0, 4($sp)		# save register $a0 for use afterwards
	sw $a1, 0($sp)		# save register $a1 for use afterwards
	add $t0,$zero,$zero 	# initialize i = CharStrt index to 0 (i is in $t0)
	add $t5,$zero,$zero 	# initialize k - Results index to 0 (k is in $t5)
	add $t9,$zero,$zero 	# initialize MAX occurences to 0 (MAX is in $t9)
string_pass:
	add $t1,$t0,$a0		# address of CharStr[i] is in $t1 
	lbu $t2, 0($t1)		# $t2 = CharStr[i]	
	beq $t2, $zero,result_pass # CharStr[i] == '\0' <=> end of CharStr	
	add $t8, $t2, $0	#save CharStr[i] address in $t8 for later
	addi $t2, $t2, -65	# t2 is now the hascii of value CharStr[i] - 65 -> the Char number in the ABC (A=0, Z=25)
	add $t3, $a1, $t2	# adress of RsultArray[$t2] in $t3
	lbu $t4, 0($t3)		# load the last occurences number of CharStr[i]
	addi, $t4,$t4,1		# update the occurrences number of CharStr[i]
	sb $t4,($t3)		# save the new occurrences number in ResultArray[$t2]
	addi $t0, $t0,1 	# i++ ($t0 = i)
	bne $t8,$zero,string_pass 	#if CharStr[i] == 0, go to string_pass
result_pass:
	add  $t1,$a1,$t5	# address of ResultArray[k] in $t1 
	lbu $t2,0($t1)		# load num in ResultArray[k] into $t2	
	addi $t5, $t5,1 	# k++ ($t5 = k)
	bgt $t9,$t2 after_update #  if ResultArray[k] < current MAX skip update
	add $t9, $t2, $0	# MAX occurence updated in $t9
	addi $t3, $t5, -1	# last index saved in $t3 (will be used to print the letter)
after_update:
	bne $t5,26,result_pass # not end of ResultArray -> move to next slot in ResultArray	
	add $v0,$t3,65    	# $v0 has the hascii value of the letter
	add $v1,$t9,$0
	lw $ra, 8($sp)
	lw $a1, 4($sp)		# restore register a1 for caller
	lw $a0, 0($sp)		# restore register a0 for caller
	addiu $sp,$sp,12 	# adjust stack to delete 3 items
	jr $ra


print_Char_by_occurrences:
	addi $sp, $sp, -4 	
	sw $a1, 0($sp)		
	add $t5,$zero,$zero 	# i = Results index. initialize i to 0 (i is in $t5)
	add $t6,$zero,$zero	# index for remainig prints in $t6
print_line:
	add  $t1,$a1,$t5	# address of ResultArray[i] in $t1 
	lbu $t2,0($t1)		# load num in ResultArray[i] into $t2	
	beq $t2,$0,next_line 	# $t2 != 0 <=> at least one occurence to print
	li $v0, 11       	# system call code for print_char
	addi $a0,$t5,65   	# $a0 has the hascii value of the letter
	syscall
	addiu $t6, $t6, 1	# occurencess--
	bne $t6,$t2,print_line	# print again
	addi $a0,$0,10		# 10 -> hascii val of '\n'
	syscall
next_line:
	addi $t5,$t5,1 		# i++ ($t5 = i)
	add $t6,$zero,$zero	# reset index for remainig prints in $t6
	blt $t5,26,print_line  # not end of ResultArray -> move to next slot in ResultArray	
	lw $a1, 0($sp)		
	addi $sp,$sp,4	
	jr $ra


delete:
	addiu $sp, $sp, -12 	# adjust stack for 2 item
	sw $ra, 8($sp)
	sw $a0, 4($sp)		# save register $a0 for use afterwards
	sw $a1, 0($sp)		# save register $a1 for use afterwards
	add $t0,$zero,$zero 	# initialize i = CharStrt index to 0 (i is in $t0)
	add $t5,$a0,$0		# save CharStr original adress
delete_next:
	add $a0,$t5,$t0		# address of CharStr[i] is in $a0
	lbu $t1, 0($a0)		# $t1 = CharStr[i]	
	bne $t1,$a1,after_reduction   # mathc -> go to reduction (address to delete on $a0)
	addi $sp, $sp, -4 	# adjust stack for 2 item
	sw $a0, 0($sp)		# save register $a0 for use afterwards
	jal reduction
	lw $a0, 0($sp)		# restore register a0 for caller
	addiu $sp,$sp,4 		# adjust stack to delete 2 items
after_reduction:
	lbu $t2, 0($a0)		# $t2 = new CharStr[i]	
	beq $t2,$a1,skip_index_update
	addiu $t0, $t0,1 	# i++ ($t0 = i)
skip_index_update:
	bne $t2, $zero,delete_next # CharStr[i] == '\0' <=> end of CharStr
	lw $a1, 0($sp)		# restore register a1 for caller
	lw $a0, 4($sp)		# restore register a0 for caller
	lw $ra, 8($sp)
	addi $sp,$sp,8 		# adjust stack to delete 2 items
	jr $ra

reduction:
	add $t3, $a0,1		# address of CharStr[i+1] is in $t3
	lbu $t4, 0($t3)		# $t4 = CharStr[i]
	sb $t4,0($a0)		# overright the letter to delete
	add $a0, $t3, $0	# a0 is now CharStr[i+1]
	add $t3, $t3,1		# t3 is now CarStr[i+2]
	bne $t4, $zero,reduction # a stop conditin - moved the terminating '\0'
	jr $ra
	
		
	


	




	 


	
	
	

	
