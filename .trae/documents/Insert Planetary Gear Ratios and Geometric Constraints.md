## 目标
将图片中的行星齿轮传动比与几何/装配约束完整插入到行星齿轮小节，保持与 pplo-elsarticle.tex 既有风格一致，且不与正文冲突、不擅自删减。

## 放置位置
- 章节：“Planetary Gear Train Design Optimization Problem”→“Mathematical Model”。
- 插入在该小节标题之后、PLO 段落之前。

## 一致性规则
- 符号：使用 $N_{i}$、$m_{1},m_{3}$、$p$、$\delta_{22},\delta_{33},\delta_{55}$；向量不涉及时不用粗体。
- 版式：每个约束使用 `equation` 环境并赋予唯一标签；传动比使用 `align` 环境统一展示。
- 标签前缀：`eq:planetary-ratios`，`eq:planetary-g1`…`eq:planetary-g7`。

## 精确代码片段
```latex
% Transmission ratios
\begin{align}
 i_{1} &= \frac{N_{6}}{N_{4}},\quad i_{01}=3.11,\\
 i_{2} &= \frac{N_{6}\big(N_{1}N_{3}+N_{2}N_{4}\big)}{N_{1}N_{3}\big(N_{6}-N_{4}\big)},\quad i_{0R}=-3.11,\\
 I_{R} &= -\,\frac{N_{2}N_{6}}{N_{1}N_{3}},\quad i_{02}=1.84.
 \label{eq:planetary-ratios}
\end{align}

Gear diameter limit:
\begin{equation}
 g_{1}(\mathbf{x}) = m_{3}\big(N_{6}+2.5\big) - D_{\max} \le 0
 \label{eq:planetary-g1}
\end{equation}
Outer diameter $D_{\max}=220$, ensure that the outer diameter of the gear does not exceed the maximum allowable value.

Size restrictions for planetary gear sets:
\begin{equation}
 g_{2}(\mathbf{x}) = m_{1}\big(N_{1}+N_{2}\big) + m_{1}\big(N_{2}+2\big) - D_{\max} \le 0
 \label{eq:planetary-g2}
\end{equation}
Limit the size of the planetary gear set so that it can be assembled into the given space $D_{\max}$.

Total width limit of internal gear ring and planetary gear:
\begin{equation}
 g_{3}(\mathbf{x}) = m_{3}\big(N_{4}+N_{5}\big) + m_{3}\big(N_{5}+2\big) - D_{\max} \le 0
 \label{eq:planetary-g3}
\end{equation}
Limit the combined width of the internal gear ring and planetary gears to avoid over-dimensioning.

Tooth number limit:
\begin{equation}
 g_{4}(\mathbf{x}) = \Big\lvert m_{1}\big(N_{1}+N_{2}\big) - m_{3}\big(N_{6}-N_{3}\big) \Big\rvert - m_{1} - m_{3} \le 0
 \label{eq:planetary-g4}
\end{equation}
Make sure the number of teeth matches to ensure the gears can mesh correctly.

Assembly angle limit:
\begin{equation}
 g_{5}(\mathbf{x}) = -\,(N_{1}-N_{2})\sin\!\big(\pi/p\big) + N_{2} + 2 + \delta_{22} \le 0
 \label{eq:planetary-g5}
\end{equation}
\begin{equation}
 g_{6}(\mathbf{x}) = -\,(N_{6}-N_{3})\sin\!\big(\pi/p\big) + N_{3} + 2 + \delta_{33} \le 0
 \label{eq:planetary-g6}
\end{equation}
\begin{equation}
 g_{7}(\mathbf{x}) = -\,(N_{4}+N_{5})\sin\!\big(\pi/p\big) + N_{5} + 2 + \delta_{55} \le 0
 \label{eq:planetary-g7}
\end{equation}
Constrain the pole number $p$ and the assembly angle between the planetary gears to avoid excessive or small angle deviations and ensure correct meshing.
```

## 验证
- 标签唯一、与既有 `eq:gear-min` 等不冲突。
- 双栏版式下文字与公式宽度适配；与后续 PLO 段落连接自然。