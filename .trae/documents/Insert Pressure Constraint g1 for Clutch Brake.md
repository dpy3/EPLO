## 目标
为图片中的压力约束公式提供与 pplo-elsarticle.tex 风格一致的 LaTeX 代码，且不与现有正文冲突。

## 放置位置
- 章节：“Multiple disk clutch brake design problem”→“Constraints and variable scope”。
- 紧跟在行文“Pressure Constraints:”之后插入该约束公式。

## 一致性规则
- 向量统一使用 `\mathbf{x}`（与文档变量向量写法一致）。
- 使用 `\operatorname` 不必；直接函数记号 `g_{1}(\mathbf{x})`。
- 使用 `\le 0`，括号使用 `\big(...)`，在乘除项之间使用 `\,`。
- 标签唯一，命名为 `eq:clutch-g1`。

## 精确代码片段
```latex
\begin{equation}
 g_{1}(\mathbf{x}) = -\,p_{\max} + \frac{x_{4}}{\pi\,\big(x_{2}^{2}-x_{1}^{2}\big)} \le 0
 \label{eq:clutch-g1}
\end{equation}
```

## 验证
- 检查是否存在同名标签（当前仅有 `eq:clutch-mass-3`）。
- 编译确认两栏版式下无溢出、与周围文本不冲突。