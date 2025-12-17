## 目标
将行星齿轮传动示意图按 pplo-elsarticle.tex 风格插入到刚建立的小节中，保持与现有图片插入方式一致且不与正文冲突，不删减任何内容。

## 放置位置
- 章节：“Planetary Gear Train Design Optimization Problem”→“Problem Background and Motivation”。
- 紧跟背景段落之后，PLO 段落之前。

## 风格与一致性
- 使用 `\begin{center}` + `\includegraphics[width=\columnwidth]{...}` + `\captionof{figure}`。
- 标签唯一：`fig:planetary-gear-variables`。
- 图片路径：`pplo_figures/Planetary Gear Train Design.jpg`（仓库已存在）。

## 代码片段
```latex
\begin{center}
  \includegraphics[width=\columnwidth]{pplo_figures/Planetary Gear Train Design.jpg}
  \captionof{figure}{Planetary gear train variables: teeth numbers $N_{1}$–$N_{6}$, modules $m_{1},m_{2}$ and poles $p$}
  \label{fig:planetary-gear-variables}
\end{center}
```

## 验证
- 确认标签与已有 `fig:gear-train-design`、`fig:avg-convergence-planetary` 不冲突。
- 使用 `\columnwidth` 保证双栏下不溢出。