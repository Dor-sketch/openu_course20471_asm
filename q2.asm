# Title: q2		Filename: q2
# Author: Dor Pascal	Date: 14th of August 2022
# Description:	The program sums numbers from a pre-deifined linked-linst of integers.
# Input: non
# Output:	1) The sum of the numbers in the given list.
#		2) The sum of only the positive numbers - which are also divided by 4.
#		3) All the numbers stored in the list - printed in Quaternary numeral system.
################# Data segment #####################
.data
num1: .word -8 , num3
num2: .word 1988 , 0
num3: .word -9034 , num5
num4: .word -100 , num2
num5: .word 1972 , num4
first_output: .asciiz "First  output: "
second_output: .asciiz "\nSecond output: "
third_output: .asciiz "\nThird  output: "
comma: .asciiz "\,"
minus: .asciiz "-"
################# Code segment #####################
.text
.globl main
main: # main program entry
	la $a1,num1	# load num1 adress to a0
	lw $a2,4($a1)	# a2 now has the adress of the next word. assumed at least 2 numbers in the list
	lw $a1,0($a1)	# s1 now has the value of num1
	add $s0,$0,$0	# s0 will be used as current sum of positve numbers divded by 4
	add $s1,$0,$0	# s1 will be used as current sum of other numbers
	add $s2,$0,$0	# s2 will be used ad index
	add $t0,$0,$0	# t0 to copy MSB - for sign cheking	
	add $t1,$0,$0	# t1 to copy the 2 LSB - for 4 division
	add $t3,$0,$0	# t3  for 00...0011 patern

maybe_positive_four:	
	andi $t0,$a1,0x80000000		# mask MSB
	bne $t0,$0,add_to_other_sum 	# t0 != 0 => a negative number -> save to other sum
	andi $t3,$a1,3 			# mask 2 bit in index 0 ,1
	bne $t3,$0,add_to_other_sum	# not diviede by 4
	bne $t4,$0,four_print
	add $s0,$s0,$a1			# add to four sum
	j next_word

add_to_other_sum:
	bne $t4,$0,four_print
	add $s1,$s1,$a1			# add to other sum
	
next_word:
	beq $a2,$0,print_resutls	#check if it's the end of the list
	lw $a1, 0($a2)			#a1 now has the value of the next word
	lw $a2,4($a2)			#a2 now has the address of the next word in the list
	j maybe_positive_four
	
print_resutls:
	beq $t4,1,exit
	li $v0, 4       	# system call code for print_str
	la $a0, first_output    # address of string to print
	syscall			
	li $v0,1		# system call code for print_int
	add $a0,$s0,$s1 	# intiger to print - combine the two sums
	syscall			
	li $v0, 4       	
	la $a0, second_output   
	syscall			
	li $v0,1		# system call for print_int
	add $a0,$s0,$0		# intiger to print - get the 4th positive sum
	syscall			# print it
	li $v0, 4       	# system call code for print_str
	la $a0, third_output    # address of string to print
	syscall
	
	li $t4,1		# t4 used as a printing flag
	j main

four_print:
	add $t1,$a1,$0		#copy num to a1
	beq $t0,$0,load_stack 	#not a negative number -> start loading
	li $v0,4       		# system call code for print_str
	la $a0, minus    	# address of string to print
	syscall			# print "-" sign
	abs $t1,$t1 		# t1 is the absulute value of the number (sign is reversed)

load_stack:
	rem $t2,$t1,4		# t2 holds the remaider of t1 deivided by 4
	div $t1,$t1,4		#divide t1 by 4
	addi $sp, $sp, -4 	#adjust stack for 1 item
	sw $t2, 0($sp)
	addi $t8, $t8, 1 	# t8 as stack index
	bne $t1,$0,load_stack 	# keep loading until num = 0

print_stack:
	li $v0,1		# system call for print_int
	lw $a0,0($sp)		# intiger to print - get the 4th positive sum
	addi $sp,$sp,4		# update stack pointer
	addi $t8, $t8, -1
	syscall			# print it
	bne $t8,$0, print_stack
	beq $a2,$0,print_resutls	#check if it's the end of the list
	li $v0,4       		# system call code for print_str
	la $a0, comma    	# address of string to print
	syscall			# print "," sign
	j next_word
	
exit:
	li $v0,10		# Exit program
	syscall
