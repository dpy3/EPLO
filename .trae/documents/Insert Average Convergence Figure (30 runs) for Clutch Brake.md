## 目标
将图片（Average Convergence（30 runs））以与 pplo-elsarticle.tex 一致的方式插入多盘离合器制动器章节，避免与正文冲突。

## 放置位置
- 章节：“Multiple disk clutch brake design problem”→“Constraints and variable scope”。
- 紧接变量范围与速度限制说明文本之后、PLO 段落之前。

## 风格与一致性
- 使用 `\begin{center}` + `\includegraphics[width=\columnwidth]{...}` + `\captionof{figure}`，与文档中齿轮图的插入方式一致。
- 标签唯一，命名为 `fig:avg-convergence-clutch`。

## 代码片段
```latex
\begin{center}
  \includegraphics[width=\columnwidth]{pplo_figures/The convergence curve of the average optimal fitness value after 30 operational cycles for the design issues of multi-disc clutch braking.png}
  \captionof{figure}{Average Convergence (30 runs) for multi-disc clutch brake design across algorithms}
  \label{fig:avg-convergence-clutch}
\end{center}
```

## 验证
- 检查与现有标签（如 `fig:avg-convergence-planetary`）不冲突。
- 保证两栏下宽度用 `\columnwidth`，防止溢出。