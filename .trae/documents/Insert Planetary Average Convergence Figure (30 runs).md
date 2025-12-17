## 目标
在“Planetary Gear Train Design Optimization Problem”→“Experimental process and result analysis”中插入平均收敛曲线图（30 runs），与文档图片样式一致，避免与现有标签冲突。

## 放置位置
- 紧随该小节标题后或段落说明后。

## 样式与一致性
- 使用 `\begin{center}` + `\includegraphics[width=\columnwidth]{...}` + `\captionof{figure}`。
- 选择仓库现有图片：`pplo_figures/Convergence Curve of the Average Optimal Fitness Value after 30 Runs of Planetary Gear Train Design.png`。
- 标签唯一：`fig:avg-convergence-planetary-2`。

## 代码片段
```latex
\begin{center}
  \includegraphics[width=\columnwidth]{pplo_figures/Convergence Curve of the Average Optimal Fitness Value after 30 Runs of Planetary Gear Train Design.png}
  \captionof{figure}{Average Convergence (30 runs) for planetary gear train design across algorithms}
  \label{fig:avg-convergence-planetary-2}
\end{center}
```

## 验证
- 标签与现有 `fig:avg-convergence-planetary` 不冲突。
- 两栏模式下使用 `\columnwidth` 防止溢出。