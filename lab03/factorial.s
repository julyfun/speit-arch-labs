.globl factorial

.data
n: .word 8

.text
main:
    la t0, n
    lw a0, 0(t0) # a0 = n
    jal ra, factorial

    addi a1, a0, 0 # a1 = a0
    addi a0, x0, 1 # a0 = 1
    ecall # Print Result

    addi a1, x0, '\n' # a1 = '\n'
    addi a0, x0, 11 # a = 11
    ecall # Print newline

    addi a0, x0, 10
    ecall # Exit

factorial:
    # YOUR CODE HERE
    addi a1, x0, 1 # a1 = 1
    addi t0, x0, 1 # t0 = 1
loop:
    mul a1, a1, t0
    beq t0, a0, exit # if t0 == n exit
    addi t0, t0, 1
    jal x0, loop
exit:
    add a0, a1, x0
    jr ra

