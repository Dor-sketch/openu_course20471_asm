# Author: Dor Pascal    Date: 17th of December 2023
# Description:  The program sums numbers from a user-input list of integers.
# Input: User inputted integers
# Output:   1) The sum of the numbers in the given list.
#           2) The sum of negative numbers.
#           3) All the numbers stored in the list - printed in Quaternary numeral system.

################# Data segment #####################
.data
num_list: .space 400 # Allocate space for 100 integers
list_size: .word 0   # Counter for the number of elements in the list
input_prompt: .asciiz "Enter an integer (or -9999 to end): "
first_output: .asciiz "Sum: "
second_output: .asciiz "\nSum of negative numbers: "
third_output: .asciiz "\nNumbers in quaternary system (base-4): "
comma: .asciiz ", "
minus: .asciiz "-"

################# Code segment #####################
.text
.globl main
main:
    # Initialize list counter to 0
    li $t6, 0
    la $t7, list_size

    # Input loop
    input_loop:
        # Display input prompt
        li $v0, 4
        la $a0, input_prompt
        syscall

        # Read user input
        li $v0, 5
        syscall
        move $t0, $v0

        # Check for end condition (-9999)
        li $t1, -9999
        beq $t0, $t1, process_list

        # Store input into list
        sll $t2, $t6, 2    # Calculate offset (4 bytes per integer)
        la $t3, num_list
        add $t3, $t3, $t2    # Calculate address for storing the input



        sw $t0, 0($t3)       # Store the input value in the list at the calculated address

        # Increment counter
        addi $t6, $t6, 1

        j input_loop


     process_list:
        # Update list size
        sw $t6, 0($t7)

        # Reset index for processing
        li $t6, 0

        # Initialize sums
        li $s0, 0 # Sum of all numbers
        li $s1, 0 # Sum of negative numbers

    sum_loop:
        # Check if end of list
        lw $t5, list_size
        beq $t6, $t5, display_results

        # Load number from list
        sll $t2, $t6, 2
        la $t3, num_list
        add $t3, $t3, $t2
        lw $t0, 0($t3)

        # Add to sum of all numbers
        add $s0, $s0, $t0

        # Check if number is negative
        bltz $t0, add_to_negative_sum
        j continue_sum_loop

        add_to_negative_sum:
        # Add to sum of negative numbers
        add $s1, $s1, $t0

        continue_sum_loop:
        addi $t6, $t6, 1
        j sum_loop

    display_results:
        # Display first output - Sum
        li $v0, 4
        la $a0, first_output
        syscall
        li $v0, 1
        move $a0, $s0
        syscall

        # Display second output - Negatives Sum
        li $v0, 4
        la $a0, second_output
        syscall
        li $v0, 1
        move $a0, $s1
        syscall

        # Display third output (numbers in quaternary system)
        li $v0, 4
        la $a0, third_output
        syscall

        # Reset index for quaternary display
        li $t6, 0

    quaternary_loop:
        # Check if end of list
        lw $t5, list_size
        beq $t6, $t5, exit_program

        # Load number from list
        sll $t2, $t6, 2
        la $t3, num_list
        add $t3, $t3, $t2
        lw $t0, 0($t3)

        # Convert and display number in quaternary
        move $t1, $t0           # Copy the number to $t1 for conversion
        li $t8, 0               # Initialize counter for stack depth

        # Check if number is negative
        bltz $t1, number_is_negative
        j convert_to_quaternary

        number_is_negative:
            li $v0, 4           # System call for print_str
            la $a0, minus       # Print minus sign for negative number
            syscall
            negu $t1, $t1       # Make number positive for conversion


        convert_to_quaternary:
            li $t2, 4          # Set divisor to 4
            div $t1, $t2       # Divide $t1 by 4
            mflo $t1           # Lower part of division result (quotient)
            mfhi $t9           # Higher part of division result (remainder)

            # Push remainder onto stack
            addi $sp, $sp, -4  # Adjust stack pointer
            sw $t9, 0($sp)     # Push remainder onto stack
            addi $t8, $t8, 1   # Increment stack depth counter

            # Check if division is complete
            bnez $t1, convert_to_quaternary

        print_quaternary:
            beqz $t8, end_quaternary_print # If stack is empty, end print

            # Pop from stack and print
            lw $t9, 0($sp)     # Pop top of stack
            addi $sp, $sp, 4   # Adjust stack pointer
            addi $t8, $t8, -1  # Decrement stack depth counter

            li $v0, 1          # System call for print_int
            move $a0, $t9      # Move number to print to $a0
            syscall
            j print_quaternary # Continue printing until stack is empty

        end_quaternary_print:
            # Print comma
            li $v0, 4
            la $a0, comma
            syscall

            # Increment index and continue loop
            addi $t6, $t6, 1
            j quaternary_loop

    exit_program:
        li $v0, 10
        syscall
