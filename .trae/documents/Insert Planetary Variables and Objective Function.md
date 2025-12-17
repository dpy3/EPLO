## 目标
将图片中的变量向量与目标函数按 pplo-elsarticle.tex 风格插入“Planetary Gear Train Design Optimization Problem”小节，保持与现有符号一致，同时不删减图片中的内容。

## 放置位置
- 章节：Planetary Gear Train Design Optimization Problem → 在“Problem Background and Motivation”段落之后、PLO 段之前。
- 新增小节标题：`\subsubsection{Design variables and objective function}`。

## 一致性规则
- 向量使用 `\mathbf{x}`；变量下标用数学体：`N_{1}\sim N_{6}`, `m_{1}`, `m_{2}`, `p`。
- 目标函数使用 `\max\{\}` 与绝对值 `\lvert\cdot\rvert`，不擅自改动图片用语（保留 `m_{2}` 与文本中的 `m_{1}, m_{3}`）。
- 标签唯一：`eq:planetary-obj-max`。

## 精确代码片段
```latex
\subsubsection{Design variables and objective function}
Variable vector $\mathbf{x}=[p,\,N_{6},\,N_{5},\,N_{4},\,N_{3},\,N_{2},\,N_{1},\,m_{2},\,m_{1}]$, where $p$ is the pole number, $N_{1}\sim N_{6}$ is the number of gear teeth, $m_{1}, m_{3}$: module. Minimize the maximum value of the transmission ratio error:
\begin{equation}
 f(\mathbf{x}) = \max\big\{\,\lvert i_{1}-i_{01}\rvert,\;\lvert i_{2}-i_{0R}\rvert,\;\lvert I_{R}-i_{02}\rvert\,\big\}
 \label{eq:planetary-obj-max}
\end{equation}
```

## 验证
- 标签唯一且不与现有 `eq:gear-min` 等冲突。
- 双栏版式下文本与公式不溢出；与后续 PLO 段落衔接正常。