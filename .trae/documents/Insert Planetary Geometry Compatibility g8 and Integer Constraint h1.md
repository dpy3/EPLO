## 目标
将图片中的“Geometry compatibility”约束 g8 与整数约束 h1 按 pplo-elsarticle.tex 的风格插入到行星齿轮数学模型部分，保持符号与版式一致，不与正文冲突且不删减内容。

## 放置位置
- 章节：Planetary Gear Train Design Optimization Problem → Mathematical Model。
- 插入在已添加的 g7 约束之后、TCSD 段落开始之前。

## 一致性规则
- 约束使用 `equation` 环境并采用 `g_{8}(\mathbf{x})` / `h_{1}(\mathbf{x})` 记法。
- 变量与符号：`N_{i}`, `\delta_{35}`, `p`, `\mathbb{Z}`。
- 标签唯一：`eq:planetary-g8`、`eq:planetary-h1`。
- 按图片文案补充相应的说明性文本行，不加标签，避免引用冲突。

## 精确代码片段
```latex
Make sure the planetary gears are correctly installed on the inner ring gear to avoid interference.

Geometry compatibility:
\begin{equation}
 g_{8}(\mathbf{x}) = \big(N_{3}+N_{5}+2+\delta_{35}\big)^{2} - \big(N_{6}-N_{3}\big)^{2} - \big(N_{4}+N_{5}\big)^{2} + 2\big(N_{6}-N_{3}\big)\big(N_{4}+N_{5}\big) \le 0
 \label{eq:planetary-g8}
\end{equation}
Make sure the planetary gears mesh correctly without geometric interference.

Integer constraints:
\begin{equation}
 h_{1}(\mathbf{x}) = \frac{N_{6}-N_{4}}{p} \in \mathbb{Z}
 \label{eq:planetary-h1}
\end{equation}
It can be ensured that the difference in the number of teeth is an integer multiple of the number of poles.
```

## 验证
- 检查标签唯一性，与现有 `eq:planetary-g1..g7` 不冲突。
- 编译确认两栏版式下文本与公式不溢出，并与后续 TCSD 段落衔接自然。