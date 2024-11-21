.globl main

.data
source:
    .word   3
    .word   1
    .word   4
    .word   1
    .word   5
    .word   9
    .word   0
dest:
    .word   0
    .word   0
    .word   0
    .word   0
    .word   0
    .word   0
    .word   0
    .word   0
    .word   0
    .word   0

.text
fun:
    addi t0, a0, 1
    sub t1, x0, a0
    mul a0, t0, t1 # 结果存储于 a0
    jr ra

main:
    # BEGIN PROLOGUE
    addi sp, sp, -20
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp) # 保护 s 系列寄存器值，程序结束后恢复...
    # t 系列不用恢复
    sw ra, 16(sp)
    # END PROLOGUE
    addi t0, x0, 0
    addi s0, x0, 0
    la s1, source
    la s2, dest # s2: dest
loop:
    slli s3, t0, 2 # s3 = t0 << 2 : 即 k 乘以 4
    add t1, s1, s3 # t1 = s1 + s3
    lw t2, 0(t1) # t2 (:source[k]) = t1[0]
    beq t2, x0, exit # t2 == 0? 即 source[k]
    add a0, x0, t2 # a0 = t2
    addi sp, sp, -8 # 
    sw t0, 0(sp) # 
    sw t2, 4(sp)
    jal fun
    lw t0, 0(sp)
    lw t2, 4(sp) # 恢复 t2 和 t0
    addi sp, sp, 8 # 删除后两个
    add t2, x0, a0 # t2(:fun 结果) = a0
    add t3, s2, s3 # t3 = s2 + s3 (:k)
    sw t2, 0(t3) # t3[0]: desk[k] = t2
    add s0, s0, t2 # s0(:sum) += t2
    addi t0, t0, 1 # t0 += 1
    jal x0, loop
exit:
    add a0, x0, s0
    # BEGIN EPILOGUE
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw ra, 16(sp)
    addi sp, sp, 20
    # END EPILOGUE
    jr ra
