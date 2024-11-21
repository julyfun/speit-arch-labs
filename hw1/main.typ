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

#set page(header: align(right)[
  Arch Homework 1, Junjie Fang
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

#set text(12pt)
#show heading.where(level: 1): it => {
  it.body
}
#set list(indent: 0.8em)

- 1.11
  - a. $"MTTF" = 10^9 / "FIT" = 10^7 "小时"$
  - b. $"Module availability" = "MTTF" / ("MTTF" + "MTTR") = 10^7 / (10^7 + 24) = 0.9999976$
  - c. $"MTTF" = 10^7 / 1000 = 10^4 "小时"$

- 1.15
  - a. 未升级模式执行时间 $t$，则升级模式执行时间 $t$. 升级前该模式执行时间 $10t$. 故加速比为 $(11t) / (2t) = 5.5$
  - b. 原来时间比例 $(10t) / (11t) = 90.9%$

- 1.17
  - a. $S_1 = 1 / (1 - P + P / S) = 1 / (1 - 0.4 + 0.4 / 2) = 1.25$
  - b. $S_2 = 1 / (1 - P + P / S) = 1 / (1 - 0.99 + 0.99 / 2) tilde.eq 1.98$
  - c. $S = 1 / (1 - P_1 + P_1 / S_1) = 1 / (1 - 0.8 + 0.8 / 1.25) tilde.eq 1.19$
  - d. $S = 1 / (1 - P_2 + P_2 / S_2) = 1 / (1 - 0.2 + 0.2 / 1.98) tilde.eq 1.11$
