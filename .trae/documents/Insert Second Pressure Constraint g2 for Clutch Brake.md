## 目标
为图片中的第二个压力相关约束公式提供与 pplo-elsarticle.tex 风格一致的 LaTeX 代码，并避免与正文冲突。

## 放置位置
- 章节：“Constraints and variable scope”。
- 紧跟在已插入的 `g_{1}(\mathbf{x})` 公式之后，仍归属在 “Pressure Constraints:” 段内。

## 一致性规则
- 向量写法统一使用 `\mathbf{x}`。
- 使用 `\le 0`，分数使用 `\frac{\,}{\,}`，在乘除项之间加入 `\,` 间距，括号使用 `\big(...)`。
- 标签唯一，命名为 `eq:clutch-g2`。

## 精确代码片段
```latex
\begin{equation}
 g_{2}(\mathbf{x}) = \frac{x_{4}\,\pi\,\big(x_{2}+x_{1}\big)\,n}{30} - v_{sr,\max}\,P_{\max} \le 0
 \label{eq:clutch-g2}
\end{equation}
```

## 验证
- 检查是否存在同名标签或重复项；保持与 `eq:clutch-g1` 相邻且不影响后续段落。
- 编译确认双栏版式下无溢出。