## 目标
将图片中的约束与说明（g7、g8、“Limit braking time:”、效率公式 η 及变量范围文字）以与 pplo-elsarticle.tex 风格一致的 LaTeX 形式插入，并避免与正文冲突。

## 放置位置
- 章节：“Constraints and variable scope”。
- 紧接 `g_{6}(\mathbf{x})` 之后、`\paragraph{Auroral motion operators (PLO).}` 之前。

## 一致性规则
- 向量统一使用 `\mathbf{x}`；在乘除项之间使用 `\,`，括号使用 `\big(...)`。
- 标签唯一：`eq:clutch-g7`、`eq:clutch-g8`、`eq:clutch-eta`。
- 单位使用 `\mathrm{m/s}`；文本说明不加公式标签。

## 精确代码片段
```latex
\begin{equation}
 g_{7}(\mathbf{x}) = -\,v_{sr,\max} + v_{sr} \le 0
 \label{eq:clutch-g7}
\end{equation}
\begin{equation}
 g_{8}(\mathbf{x}) = T - T_{\max} \le 0
 \label{eq:clutch-g8}
\end{equation}

Limit braking time:
\begin{equation}
 \eta = \frac{I_{w}}{M_{h}+M_{f}}
 \label{eq:clutch-eta}
\end{equation}

$\eta \le 15$, sliding speed $v_{sr} \le 10\,\mathrm{m/s}$. The variable range is $60 \le x_{1} \le 80$, $90 \le x_{2} \le 110$, $1 \le x_{3} \le 3.0$, $0 \le x_{4} \le 1000$, $2 \le x_{5} \le 9$, and $x_{1},x_{2},x_{3},x_{4}$ are integers.
```

## 验证
- 检查标签唯一性（与现有 eq:clutch-* 系列不重复）。
- 编译检查双栏版式无溢出，与后续段落衔接正常。