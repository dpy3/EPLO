## 目标
将图片中的扭矩安全约束公式与制动扭矩定义插入 pplo-elsarticle.tex，保持与全文风格一致且不与正文冲突。

## 放置位置
- 章节：“Constraints and variable scope”。
- 紧接在已添加的文本行 “Torque safety constraint:” 之后、`\paragraph{Auroral motion operators (PLO).}` 之前。

## 一致性规则
- 向量统一使用 `\mathbf{x}`。
- 使用 `\le 0`；在乘法项之间使用 `\,` 以优化间距。
- 变量记号：`s`（安全系数）、`M_{g}`（允许扭矩）、`M_{h}`（制动扭矩）、`\mu`（摩擦系数）。
- 标签唯一：`eq:clutch-g5`、`eq:clutch-Mh`。

## 精确代码片段
```latex
\begin{equation}
 g_{5}(\mathbf{x}) = s\,M_{g} - M_{h} \le 0
 \label{eq:clutch-g5}
\end{equation}
\begin{equation}
 M_{h} = \frac{2}{3}\,\mu\,x_{4}\,x_{5}\,\frac{x_{2}^{3}-x_{1}^{3}}{x_{2}^{2}-x_{1}^{2}}
 \label{eq:clutch-Mh}
\end{equation}
```

## 验证
- 检查标签唯一性并确保与周围段落衔接良好。
- 编译确认双栏版式下无溢出。