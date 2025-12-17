## 目标
将图片中的几何约束公式按 pplo-elsarticle.tex 的风格插入文档，避免与正文冲突。

## 放置位置
- 章节：“Constraints and variable scope”。
- 紧跟在已插入的压力约束 `g_{1}`、`g_{2}` 后面；若存在“小节标题”，可在其后添加“Geometric Constraints:”行，再插入公式。

## 一致性规则
- 向量统一为 `\mathbf{x}`。
- 使用 `\le 0`；在乘除与括号处使用 `\,` 和 `\big(...)`。
- 变量写法：`\Delta R`、`\delta`、`L_{\max}`。
- 标签唯一：`eq:clutch-g3`、`eq:clutch-g4`。

## 精确代码片段
```latex
% Geometric Constraints:
\begin{equation}
 g_{3}(\mathbf{x}) = \Delta R + x_{1} - x_{2} \le 0
 \label{eq:clutch-g3}
\end{equation}
\begin{equation}
 g_{4}(\mathbf{x}) = -\,L_{\max} + \big(x_{5}+1\big)\,\big(x_{3}+\delta\big) \le 0
 \label{eq:clutch-g4}
\end{equation}
```

## 验证
- 检查标签唯一性与与前文 `g_{1}`、`g_{2}` 的排版连续性。
- 编译确认双栏下不溢出。