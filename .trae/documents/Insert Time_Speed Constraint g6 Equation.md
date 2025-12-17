## 目标
将图片中的时间/速度约束公式加入 pplo-elsarticle.tex，保持与全文风格一致且不与正文冲突。

## 放置位置
- 章节：“Constraints and variable scope”。
- 紧接行文“Time and speed constraints:”之后。

## 一致性规则
- 向量统一使用 `\mathbf{x}`（与文档前文一致）。
- 使用 `\ge 0`；不额外加入说明标签冲突。
- 标签唯一命名为 `eq:clutch-g6`。

## 精确代码片段
```latex
\begin{equation}
 g_{6}(\mathbf{x}) = T \ge 0
 \label{eq:clutch-g6}
\end{equation}
```

## 验证
- 检查标签唯一性并确保双栏版式下无溢出。
- 与前后段落（后续 PLO 段）衔接正常。