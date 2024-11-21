#set page(paper: "us-letter")
#set heading(numbering: "1.1.")
#set figure(numbering: "1")

#show strong: set text(weight: 900)  // Songti SC 700 不够粗
#show heading: set text(weight: 900)

#set text(
  font: ("New Computer Modern", "FZKai-Z03S")
)

#import "@preview/codelst:2.0.0": sourcecode
#show raw.where(block: true): it => {
  set text(size: 10pt)
  sourcecode(it)
}

// 这是注释
#figure(image("sjtu.png", width: 50%), numbering: none) \ \ \

#align(center, text(17pt)[
  计算机体系结构 Lab03 \ \
  #table(
      columns: 2,
      stroke: none,
      rows: (2.5em),
      // align: (x, y) =>
      //   if x == 0 { right } else { left },
      align: (right, left),
      [Name:], [Junjie Fang (Florian)],
      [Student ID:], [521260910018],
      [Date:], [#datetime.today().display()],
    )
])

#pagebreak()

#set page(header: align(right)[
  DB Lab1 Report - Junjie FANG
], numbering: "1")

#show outline.entry.where(
  level: 1
): it => {
  v(12pt, weak: true)
  strong(it)
}

// [lib]
#import "@preview/tablem:0.1.0": tablem

#let three-line-table = tablem.with(
  render: (columns: auto, ..args) => {
    table(
      columns: columns,
      stroke: none,
      align: center + horizon,
      table.hline(y: 0),
      table.hline(y: 1, stroke: .5pt),
      table.hline(y: 4, stroke: .5pt),
      table.hline(y: 7, stroke: .5pt),
      ..args,
      table.hline(),
    )
  }
)

#outline(indent: 1.5em)

#set text(12pt)
#show heading.where(level: 1): it => {
  it.body
}
#set list(indent: 0.8em)

= Ex 1

== 实验目的

- 区分常用汇编命令如 lw 和 addi 的用处。
- 弄清 RISC-V 寄存器和内存操作规范。

== 实验步骤

- 理解初始化部分，通过调试器观察发现第一个数组起始地址为 `0x1000808C`
- 检查代码错误，如非保留寄存器存储，混淆 `addi` 和 `lw la` 等错误并修改。

== 实验分析

- 除了 map 函数以外没什么问题。
- map 函数具体错误列表见下。

== 问题回答

- 错误项目
  + `add t1, s0, x0`
    - 这里 `s0` 存储的是 node 实例的地址，而 `t1` 应该获得 node 实例的第一个元素（数组地址）
    - 改为 `lw t1, 0(s0)`
  + `add t1, t1, t0`
    - 这里试图偏移 `t1`，但是每个元素都是 `int` 所以偏移量需要乘 4
    - 改为 `slli t3, t0, 2` 后再 `add t1, t1, t3`
  + `jalr` 前没有存储非保留寄存器
    - 需要 `sw` 保存 `t0, t1, t2` 于栈上
  + `jalr` 跳转前没有记录将下一条地址存储
    - 改为 `jalr ra, s1, 0`
  + `lw a1, 0(s1)` 这里 `s1` 存储的就是函数指针，直接赋值即可
    - 改为 `addi a1, s1, 0`
- 正确做法如下:

```assembly
map:
    addi sp, sp, -12 # a0: head, a1: f
    sw ra, 0(sp)
    sw s1, 4(sp)
    sw s0, 8(sp)

    beq a0, x0, done    # if we were given a null pointer, we're done.

    add s0, a0, x0      # save address of this node in s0
    add s1, a1, x0      # save address of function in s1
    add t0, x0, x0      # t0 is a counter

    # remember that each node is 12 bytes long:
    # - 4 for the array pointer
    # - 4 for the size of the array
    # - 4 more for the pointer to the next node

    # also keep in mind that we should not make ANY assumption on which registers
    # are modified by the callees, even when we know the content inside the functions 
    # we call. this is to enforce the abstraction barrier of calling convention.
mapLoop:
    # s0: * node
    # s1: * f
    # t0: counter
    # t1: * arr
    # t2: size

    # [x1]
    # add t1, s0, x0      # load the address of the array of current node into t1
    lw t1, 0(s0)
    lw t2, 4(s0)        # load the size of the node's array into t2

    # [+1]
    slli t3, t0, 2

    # [x1] add t1, t1, t0      # offset the array address by the count
    add t1, t1, t3

    lw a0, 0(t1)        # load the value at that address into a0

    # 此后 t0, t1, t2 还需要用
    # [+4]
    addi sp, sp, -12
    sw t0, 0(sp)
    sw t1, 4(sp)
    sw t2, 8(sp)

    # [x1] jalr s1             # call the function on that value.
    jalr ra, s1, 0
    # pass a0, returned in a0

    # [+4]
    lw t0, 0(sp)
    lw t1, 4(sp)
    lw t2, 8(sp)
    addi sp, sp, 12

    sw a0, 0(t1)        # store the returned value back into the array
    addi t0, t0, 1      # increment the count
    bne t0, t2, mapLoop # repeat if we haven't reached the array size yet

    lw a0, 8(s0)        # load the address of the next node into a0
    # [x1] lw a1, 0(s1)        # put the address of the function back into a1 to prepare for the recursion
    # 递归函数将 a1 当作回调指针。此函数无需保存任何上下文
    addi a1, s1, 0

    jal  map            # recurse
done:
    lw s0, 8(sp)
    lw s1, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 12
    jr ra
```

== Testing

#figure(image("img/image.png"))

= Ex 2

== 实验目的

- 了解如何用汇编和地址映射模拟函数调用。

== 实验步骤

- 确定调用形式和参数定义域。
- 观察 `output` 偏移地址于对应参数的关系。
- 编写 `f` 函数将 `output` 内存偏移一个量后将一个 `word` 存入 `a0`.

== 实验分析

- 调用形式通过已经写好答案的内存地址 + 偏移量返回.
- `output` 偏移 0 的位置存储参数为 `-3` 时候的值，其后每偏移 4 个地址，对应原始参数值加 1.
- 先用一个寄存器计算加 3 后 4 倍偏移量，获取相应地址并 `lw` 它.

== 问题回答

```assembly
f:
    # YOUR CODE GOES HERE!
    addi a0, a0, 3
    slli t0, a0, 2
    add a1, a1, t0
    lw a0, 0(a1)

    jr ra               # Always remember to jr ra after your function!
```

== Testing

#figure(image("img/image copy.png"))
