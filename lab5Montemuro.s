@ Filename: lab5Montemuro.s
@ Author:   Tony Montemuro
@ Email:    aam0036@uah.edu
@ Class:    CS 309-01 Fall 2021
@ Purpose:  Complete the Lab 5 ARM Advance Program assingment.
@ Date: 11/8/2021
@ 
@ History: 
@    Date       Purpose of change
@    ----       ----------------- 
@   4-Jul-2019  Changed this code from using the stack pointer to a 
@               locally declared variable. 
@  15-Sep-2019  Moved some code around to make it clearer on how to 
@               get the input value into a register. 
@   1-Oct-2019  Added code to check for user input errors from the 
@               scanf call.   
@  21-Feb-2019  Added comments about "%c" vs " %c" related to scanf.
@   8-Nov-2021  Completely rewrote this file in order to complete
@               the Lab 5 ARM Advance Program assignment.
@
@ Use these commands to assemble, link, run and debug this program:
@    as -o lab5Montemuro.o lab5Montemuro.s
@    gcc -o lab5Montemuro lab5Montemuro.o
@    ./lab5Montemuro ;echo $?
@    gdb --args ./lab5Montemuro 

@ ***********************************************************************
@ The = (equal sign) is used in the ARM Assembler to get the address of a
@ label declared in the .data section. This takes the place of the ADR
@ instruction used in the textbook. 
@ ***********************************************************************

.equ READERROR, 0 @Used to check for scanf read error. 
.equ MAX, 200 @Max value a user can withdraw at once
.equ MAX_TRANS, 10 @Max number of transactions that can occur
.equ SECRET_CODE, -9 @Secret code user can enter to see info about system

.global main @ Have to use main because of C library uses. 

main:

@*******************
introduction:
@*******************

@ Introduce the customer to the Teller Machine. The rules for withdraw are:
@ 1.) A customer can complete one withdraw at a time.
@ 2.) The customer must withdraw more than $0.
@ 3.) This withdraw must be less than or equal to $200. However, if the amount of
@     money left in the system is less than $200, then the withdraw must be less
@     than or equal to this value.
@ 4.) The withdraw also must be a multiple of $10.

   ldr r0, =strIntro       @ Put the address of intro string into r0. This value will be printed.
   bl printf               @ Call the C printf to display intro text.
   ldr r0, =strIntro2      @ Put the address of the second intro string into r0. This value
                           @ will be printed.
   bl printf               @ Call the C printf to display the intro text.

@ Update the value of totalMoney and maxMoney. This allows program to be more dynamic.

   ldr r2, =num10s         @ Load the address of num10s (number of 10 dollar bills in system) into r2
   ldr r2, [r2]            @ Load the value of num10s (number of 10 dollar bills in system) into r2
   mov r3, #10             @ Move the literal value 10 into r3.
   mul r0, r2, r3          @ Multiply number of 10s times 10, and store in r0
   ldr r2, =num20s         @ Load the address of num20s (number of 20 dollar bills in system) into r2
   ldr r2, [r2]            @ Load the value of num20s (number of 20 dollar bills in system) into r2
   mov r3, #20             @ Load the literal value 20 into r3
   mul r1, r2, r3          @ Multiply the number of 20s times 20, and store in r1
   add r0, r0, r1          @ Take the sum of r0 and r1 (total amount of money) and store result in r0
   ldr r1, =totalMoney     @ Load the totalMoney memory address in r1
   str r0, [r1]            @ Store the total amount of money in variable totalMoney
   ldr r1, =maxMoney       @ Load the maxMoney memory address in r1
   str r0, [r1]            @ Store the total amount of money in varaible maxMoney

@*******************
prompt:
@*******************

@ Ask the user to enter a number.
 
   ldr r0, =strPrompt      @ Put the address of prompt string into r0. This value will be printed.
   bl  printf              @ Call the C printf to display withdraw prompt. 

@*******************
get_input:
@*******************

@ Set up r0 with the address of input pattern.
@ scanf puts the input value at the address stored in r1. We are going
@ to use the address for our declared variable in the data section - userInput. 
@ After the call to scanf the input is at the address pointed to by r1 which 
@ in this case will be userInput. 

   ldr r0, =numInputPattern @ Setup to read in one number.
   ldr r1, =userInput       @ load r1 with the address of where the
                            @ input value will be stored. 
   bl  scanf                @ scan the keyboard.

@ Now, we must perform different comparisons to see if userInput is valid.
@ First, check for a read error. This is true if r0 is 0 after scanf is called.

   cmp r0, #READERROR       @ Check for a read error.
   ldreq r0, =errorType     @ Load the string errorType into r0 if a readerror is detected
                            @ This will inform user that the input was not of correct type
   beq inputResult          @ Branch to inputResult, where user will be notified of misinput

@ Next, check if user inputed the secret code '-9'. If so, data is printed about the system.

   ldr r1, =userInput       @ Have to reload r1 because it gets wiped out. 
   ldr r1, [r1]             @ Read the contents of userInput and store in r1 so that
                            @ it can be compared.
   cmp r1, #SECRET_CODE     @ Compare userInput to SECRET_CODE
   beq printSecretData      @ Branch to code that will print all the secret information

@ Next, check if user inputed a number greater than 0

   cmp r1, #0               @ Compare userInput to literal value #0
   ldrle r0, =errorSize1    @ Load the string errorSize1 into r0 if input is less than or equal to #0
                            @ This will inform the user that the input is too small
   ble inputResult          @ Branch to inputResult, where user will be notified of misinput

@ Next, check if user inputed a number less than or equal to 200.

   cmp r1, #MAX             @ Compare userInput to max withdraw value (200)
   ldrgt r0, =errorSize2    @ Load the string errorSize2 into r0 if input is greater than 200
                            @ This will inform user that the input is too large.
   bgt inputResult          @ Branch to inputResult, where user will be notified of misinput

@ Next, in the event the system has less than $200, check if user inputed a number less than or equal to
@ the total money supply left.

   ldr r2, =totalMoney      @ Load the adddress of total amount of money left in the system into r2
   ldr r2, [r2]             @ Read the contents of totalMoney and store in r2 so that it can be compared
   cmp r1, r2               @ Compare user input with totalMoney
   movgt r1, r2             @ If the userInput is greater than the total money supply, move the address
                            @ stored in r2 into r1
   ldrgt r0, =errorSize3    @ Load the string errorSize3 into r0 if input is greater than totalMoney
   bgt inputResult          @ Branch to inputResult, where user will be notified of misinput

@ Finally, check to see if user inputed a multiple of 10

   mov r0, #10              @ Move literal value #10 into r0: this is the divisor in getModulo function
   push {r1}                @ Push r1 onto stack memory, as it is modified in getModulo subroutine
   bl getModulo             @ Call a function that calculate r1 mod 10 (r1 = userInput)
   pop {r1}                 @ Pop value from stack back into r1
   cmp r2, #0               @ Compare r2 to 0. This is userInput (mod 10)
   ldrgt r0, =errorVal      @ Load the string errorVal into r1 if input is not a multiple of 10
                            @ This will inform user that the input is  
   bgt inputResult          @ Branch to inputResult, where user will be notified of misinput

@***********
completeWithdraw:
@***********
@ In this section of code, the actual withdraw will take place. Here are the rules of withdraw:
@ 1.) When filling a withdraw request, first disperse $20 bills.
@ 2.) Once all $20 are gone, disperse $10 bills to fulfill the request.

@ First, load the total money supply, number of 10s, number of 20s, and userInput into registers

   ldr r0, =totalMoney      @ Load the address of total amount of money left in the system into r0
   ldr r0, [r0]             @ Read the contents of total amount of money and store in r0
   ldr r1, =num10s          @ Load the address of number of 10s left in the system into r1
   ldr r1, [r1]             @ Read the contents of number of 10s left in the system into r1
   ldr r2, =num20s          @ Load the address of number of 20s left in the system into r2
   ldr r2, [r2]             @ Read the contents of number of 20s left in the system into r2
   ldr r3, =userInput       @ Load the address of the user input into r0
   ldr r3, [r3]             @ Load the contents of the user input into r0
   
@ Next, intitialize r4 and r5 to 0.
@ r4 will store the number of 10s dispensed in the transaction.
@ r5 will store the number of 20s dispensed in the transaction.

   mov r4, #0               @ Move the literal value #0 into r4
   mov r5, #0               @ Move the literal value #0 into r5

@ Next, dispense $20 dollar bills. If withdraw is not complete, dispense $10 dollar bills.

   bl dispense20s           @ Call a function that will dispense 20s.
   cmp r3, #0               @ Compare the user input to literal value #0
   blgt dispense10s         @ Call a function that will dispense 10s if any money is left

@ Next, print the transaction information to the user.

@ First, store the values of total money, num10s, and num20s in memory.

   ldr r3, =totalMoney      @ Load the address of totalMoney into r3
   str r0, [r3]             @ Update the total money value in memory
   ldr r3, =num10s          @ Load the address of number of 10s into r3
   str r1, [r3]             @ Update the number of 10s value in memory
   ldr r3, =num20s          @ Load the address of number of 20s into r3
   str r2, [r3]             @ Update the number of 20s value in memory 

@ Then, print to screen that the transaction has completed

   ldr r0, =withdrawDone    @ Load the adress of the string to be printed to screen
                            @ Will tell the user that the withdraw has finished
   ldr r1, =userInput       @ Load the address of the userInput value into r1
   ldr r1, [r1]             @ Load the contents of the userInput value into r1 
   bl printf                @ Call the print function

@ Next, print to screen how many 10s were dispensed

   ldr r0, =strNum10s       @ Load the adress of the string to be printed to screen
                            @ Will tell the user how many 10s were dispensed
   mov r1, r4               @ Move the value in r4 (number of 10s dispensed) into r1
   bl printf                @ Make call to print function

@ Next, print to screen how many 20s were dispensed

   ldr r0, =strNum20s       @ Load the address of the string to be printed to screen
                            @ Will tell the user how many 20s were dispensed
   mov r1, r5               @ Move the value in r5 (number of 20s dispensed) into r1
   bl printf                @ Make a call to the print function  

@ Next, increment numTransactions by 1

   ldr r0, =numTransactions @ Load the address of numTransactions into r0
   mov r1, r0               @ Move the address of numTransactions into r1
   ldr r1, [r1]             @ Load the contents of numTransactions into r1
   add r1, r1, #1           @ Increment numTransactions by 1
   str r1, [r0]             @ Update the value in memory

@ Finally, decide if program can continue. There are two conditions that will exit program
@ 1.) If the number of transactions has reached 10, exit the program.
@ 2.) If the total money in the system has reached 0, exit the program.

   cmp r1, #MAX_TRANS       @ Compare the number of transactions to literal #MAX_TRANS (10)
   ldreq r0, =strMaxTrans   @ Load the address of strMaxTrans into r0 if number of transactions
                            @ is equal to #10. This will be printed to screen in myexit.
   beq myexit               @ If number of transactions is equal to 10, exit the program
   ldr r0, =totalMoney      @ Load the address of totalMoney into r1
   ldr r0, [r0]             @ Load the contents of totalMoney into r1
   cmp r0, #0               @ Compare the total money of the system to literal value #0
   ldr r0, =strNoMoney      @ Load the address of strNoMoney into r0 if no money is left
                            @ on hand (totalMoney = 0). This will be printed to screen in myexit.
   beq myexit               @ If total money of the system is 0, exit the program
   b prompt                 @ Otherwise, prompt user for another transaction         

@*******************
dispense10s:
@*******************
@ This subroutine will dispense 10s until
@ a.) The withdraw has been completed.

@LOOP BEGIN

   SUB r3, r3, #10          @ Subtract 10 from the user input
   SUB r0, r0, #10          @ Subtract the total money supply by 10
   SUB r1, r1, #1           @ Subtract 1 from the number of 20s
   ADD r4, #1               @ Increase the 10s dispensed counter by 1
   cmp r3, #10              @ Compare the user input with literal value #10
   movlt pc, lr             @ Return to main routine if user input is less than 10
   b dispense10s            @ Otherwise, continue the loop

@LOOP END

@*******************
dispense20s:
@*******************
@ This subroutine will dispense 20s until
@ a.) The withdraw has been completed.
@ b.) Until all $20s have been dispensed.
@ c.) If the user entered a number that is a multiple of 10 but not 20, there will be 10 dollars remaining
@     that must be taken care of.

@LOOP BEGIN

   cmp r2, #0               @ Compare the number of 20s left with literal value #0
   moveq pc, lr             @ If these values are equal, return to main routine
   cmp r3, #20              @ Compare the user input with literal value #20
   movlt pc, lr             @ Return to main routine if user input is less than 20
   SUB r3, r3, #20          @ Subtract 20 from the user input
   SUB r0, r0, #20          @ Subtract the total money supply by 20
   SUB r2, r2, #1           @ Subtract 1 from the number of 20s
   ADD r5, #1               @ Increase the 20s dispensed counter by 1
   b dispense20s            @ Otherwise, continue the loop

@LOOP END

@***********
printNumTransactions:
@***********
@ This function simply prints the number of transactions the user has made so far.

   push {lr}                 @ Push the address in the link register to the stack, since
                             @ a bl call is made in this subroutine
   ldr r0, =strNumTrans      @ Load the address of the string to be printed to the user
                             @ This will tell user how many transactions were completed
   ldr r1, =numTransactions  @ Load the address of numTransactions into r1
   ldr r1, [r1]              @ Load the contents of numTransactions into r1
   bl printf                 @ Make a call to the print function
   pop {lr}                  @ Pop the address of the link register back into the subroutine
   mov pc, lr                @ Return to the main routine

@***********
printRemainingBalance:
@***********
@ This function simply prints the remaining total money left in the system.

   push {lr}                 @ Push the address in the link register to the stack, since
                             @ a bl call is made in this subroutine
   ldr r0, =strTotalMoney    @ Load the address of the string to be printed to the user
                             @ This will tell the user how much money in total is left
   ldr r1, =totalMoney       @ Load the address of the total money supply
   ldr r1, [r1]              @ Load the value of the total money supply
   bl printf                 @ Make a call to the print function
   pop {lr}                  @ Pop the address of the link register back into the subroutine
   mov pc, lr                @ Return to the main routine

@***********
printTotalDistribution:
@***********
@ This function simply prints the total amount of money distributed so far.

   push {lr}                 @ Push the address in the link register to the stack, since
                             @ a bl call is made in this subroutine
   ldr r0, =strTotalDistributed @ Load the address of the string to be printed to the user
                             @ This will tell the user how much money has been dispensed total
   ldr r1, =totalMoney       @ Load the address of the total money supply
   ldr r1, [r1]              @ Load the value of the total money supply
   ldr r2, =maxMoney         @ Load the address of the max amount of money in the system
   ldr r2, [r2]              @ Load the contents of the max amount of money address
   sub r1, r2, r1            @ Compute the total money distributed (1500 - totalMoney)
                             @ NOTE: 1500 = 20 * 50 + 10 * 50
   bl printf                 @ Make a call to the print function
   pop {lr}                  @ Pop the address of the link register back into the subroutine
   mov pc, lr                @ Return to the main routine

@***********
printSecretData:
@***********
@ This segment of code is only accesible if user knows secret code. It will print the following:
@ 1.) Inventory of 20 dollar bills
@ 2.) Inventory of 10 dollar bills
@ 3.) Remaining balance on hand
@ 4.) Current number of transactions
@ 5.) Total distributions so far

@ First, print the inventory of 10 dollar bills remaining

   ldr r0, =strNum10sRemain  @ Load the address of the string to be printed to the user
                             @ This will tell the user how many 10s are left in the system
   ldr r1, =num10s           @ Load the address of the number of 10s left
   ldr r1, [r1]              @ Load the value of the number of 10s left
   bl printf                 @ Make a call to the print function

@ Next, print the inventory of 20 dollar bills remaining

   ldr r0, =strNum20sRemain  @ Load the address of the string to be printed to the user
                             @ This will tell the user how many 20s are left in the system
   ldr r1, =num20s           @ Load the address of the number of 20s left
   ldr r1, [r1]              @ Load the value of the number of 20s left
   bl printf                 @ Make a call to the print function

@ Next, print the total amount of money left in on hand in the system

   bl printRemainingBalance  @ Make a call to printRemainingBalance: will print the total
                             @ amount of money remaining on hand in the system

@ Next, print the number of transactions to the user

   bl printNumTransactions   @ Make a call to printNumTransactions: will print the total
                             @ number of transactions

@ Finally, print the total amount of money distributed

   bl printTotalDistribution @ Make a call to printTotalDistribution: will print the total
                             @ amount of money distributed

@ Now, branch back to prompt

   b prompt                  @ Bring user back to prompting them for an input

@***********
getModulo:
@***********

@ By performing multiple subtractions, this function returns the modulo of a dividend divided by
@ a divisor
@ r0: contains the divisor
@ r1: contains the dividend

@LOOP BEGIN

   SUB r1, r1, r0            @ Subtract the value in r1 by the literal value 10
   cmp r1, #0                @ Compare r1 to literal value 0
   movlt pc, lr              @ If the value in r1 is negative, return to main routine
   mov r2, r1                @ Otherwise, store the value of r1 in r2
   b getModulo               @ Branch back to beginning of subroutine

@LOOP END

@***********
inputResult:
@***********
@ The user entered an invalid input. First, print the type of error to the user.
@ Then, since an invalid entry was made we now have to clear out the input buffer.
@ We can do this by calling the clearBuffer subroutine.

   bl printf                 @ Call the printf function
   bl clearBuffer            @ Call the clearBuffer function

   b prompt                  @ Branch back to prompt

@***********
clearBuffer:
@***********
@ This subroutine clears the input buffer. Should be called before scanf everytime.
@ Done by reading with this format %[^\n] which will read the buffer until the user 
@ presses the CR. 

   push {lr}                 @ Push the value of the link register to the stack. This
                             @ allows this subroutine to return back to main routine.
   ldr r0, =strInputPattern  @ Load the string "%[^\n]"
   ldr r1, =strInputError    @ Put address into r1 for read.
   bl scanf                  @ scan the keyboard.
@  Not going to do anything with the input. This just cleans up the input buffer.  
@  The input buffer should now be clear so get another input.

   pop {lr}                  @ Pop back the value of link register back into lr.
   mov pc, lr                @ Return to main routine

@*******************
myexit:
@*******************
@ End of code. 
@ First, information about transactions and system.
@ Then, force the exit and return control to OS

@ First, print to the user why the system is shutting down. There are two possibilities:
@ 1.) The user has completed 10 transactions.
@ 2.) The teller machine has run out of money to withdraw.

   bl printf                 @ Make a call to the print function. The value of r0 is
                             @ taken care of in completeWithdraw section

@ Next, print the number of transactions to the user

   bl printNumTransactions   @ Make a call to printNumTransactions: will print the total
                             @ number of transactions

@ Next, print the total number of 10s distributed

   ldr r0, =strTotalNum10s   @ Load the address of the string to be printed to the user
                             @ This will tell user how many 10s were dispersed total
   ldr r1, =num10s           @ Load the address of the number of 10s left in the system
   ldr r1, [r1]              @ Load the content of the number of 10s left in the system
   rsb r1, r1, #50           @ Compute the total number of 10s dispensed (50 - num10s)
   bl printf                 @ Make a call to the print function

@ Next, print the total number of 20s distributed
   
   ldr r0, =strTotalNum20s   @ Load the address of the string to be printed to the user
                             @ This will tell user how many 20s were dispersed total
   ldr r1, =num20s           @ Load the address of the number of 20s left in the system
   ldr r1, [r1]              @ Load the content of the number of 20s left in the system
   RSB r1, r1, #50           @ Compute the total number of 20s dispensed (50 - num20s)
   bl printf                 @ Make a call to the print function 

@ Next, print the total amount of money distributed

   bl printTotalDistribution @ Make a call to printTotalDistribution: will print the total
                             @ amount of money distributed

@ Next, print the total amount of money left in on hand in the system

   bl printRemainingBalance  @ Make a call to printRemainingBalance: will print the total
                             @ amount of money remaining on hand in the system

@ Finally, force exit of program, and return control to the OS

   mov r7, #0x01             @ SVC call to exit
   svc 0                     @ Make the system call. 

.data

@ Declare the strings and data needed

.balign 4
strIntro: .asciz "Welcome to the Teller Machine!\nIn order to withdraw, simply enter the amount you wish to withdraw.\n"

.balign 4
strIntro2: .asciz "Your amount must be a multiple of $10, and it cannot exceed $200.\nIf the machine has less than $200, your input must be no greater than this amount.\n\n"

.balign 4
strPrompt: .asciz "Please enter an amount to withdraw: $"

.balign 4
errorType: .asciz "Invalid withdraw! Please make sure you enter a number.\n\n"

.balign 4
errorSize1: .asciz "Invalid withdraw! Please enter a value greater than 0.\n\n"

.balign 4
errorSize2: .asciz "Invalid withdraw! Please enter a value less than 200.\n\n"

.balign 4
errorSize3: .asciz "Invalid withdraw! The system only has $%d left.\n\n"

.balign 4
errorVal: .asciz "Invalid withdraw! Please enter a multiple of 10.\n\n"

.balign 4
withdrawDone: .asciz "\nWithdraw Complete! You requested to withdraw: $%d\n"

.balign 4
strNum10s: .asciz "You received: %d $10 dollar bills\n"

.balign 4
strNum20s: .asciz "You received: %d $20 dollar bills\n\n"

.balign 4
strNum10sRemain: .asciz "\nInventory of $10 Dollar Bills: %d\n"

.balign 4
strNum20sRemain: .asciz "Inventory of $20 Dollar Bills: %d\n"

.balign 4
strNumTrans: .asciz "Number of Transactions: %d\n"

.balign 4
strTotalNum10s: .asciz "Total Number of $10 Dollar Bills Distributed: %d\n"

.balign 4
strTotalNum20s: .asciz "Total Number of $20 Dollar Bills Distributed: %d\n"

.balign 4
strTotalDistributed: .asciz "Total Money Distributed: $%d\n"

.balign 4
strTotalMoney: .asciz "Total Amount of Money Left on Hand: $%d\n"

.balign 4
strMaxTrans: .asciz "Max Transactions Completed! Machine Shutting Down...\n\n"

.balign 4
strNoMoney: .asciz "Machine Out of Money! Machine Shutting Down...\n\n"

.balign 4
num10s: .word 50

.balign 4
num20s: .word 50

.balign 4
totalMoney: .word 0 @ This value will be updated at run-time: depends on the number of 10s and 20s in the system.

.balign 4
numTransactions: .word 0 @ This value will be incremented by 1 after each transaction

.balign 4
maxMoney: .word 0 @ This value will contain the total amount of money the system has at start $(10 * 50 + 20 * 10)

@ Format pattern for scanf call.

.balign 4
numInputPattern: .asciz "%d"  @ integer format for read. 

.balign 4
strInputPattern: .asciz "%[^\n]" @ Used to clear the input buffer for invalid input. 

.balign 4
strInputError: .skip 100*4  @ User to clear the input buffer for invalid input. 

.balign 4
userInput: .word 0   @ Location used to store the user input. 

@ Let the assembler know these are the C library functions. 

.global printf
@  To use printf:
@     r0 - Contains the starting address of the string to be printed. The string
@          must conform to the C coding standards.
@     r1 - If the string contains an output parameter i.e., %d, %c, etc. register
@          r1 must contain the value to be printed. 
@ When the call returns registers: r0, r1, r2, r3 and r12 are changed. 

.global scanf
@  To use scanf:
@      r0 - Contains the address of the input format string used to read the user
@           input value. In this example it is numInputPattern.  
@      r1 - Must contain the address where the input value is going to be stored.
@           In this example memory location userInput declared in the .data section
@           is being used.  
@ When the call returns registers: r0, r1, r2, r3 and r12 are changed.
@ Important Notes about scanf:
@   If the user entered an input that does NOT conform to the input pattern, 
@   then register r0 will contain a 0. If it is a valid format
@   then r0 will contain a 1. The input buffer will NOT be cleared of the invalid
@   input so that needs to be cleared out before attempting anything else.
@
@ Additional notes about scanf and the input patterns:
@    1. If the pattern is %s or %c it is not possible for the user input to generate
@       and error code. Anything that can be typed by the user on the keyboard
@       will be accepted by these two input patterns. 
@    2. If the pattern is %d and the user input 12.123 scanf will accept the 12 as
@       valid input and leave the .123 in the input buffer. 
@    3. If the pattern is "%c" any white space characters are left in the input
@       buffer. In most cases user entered carrage return remains in the input buffer
@       and if you do another scanf with "%c" the carrage return will be returned. 
@       To ignore these "white" characters use " $c" as the input pattern. This will
@       ignore any of these non-printing characters the user may have entered.
@

@ End of code and end of file. Leave a blank line after this.
