## 位置与风格
- 位置：继续追加在抓取器数学模型小节已插入内容之后，保持同一段落层级。
- 风格：使用 `equation`+`aligned`，粗体向量 `\mathbf{x}`，标签前缀 `eq:gripper-*` 保证不与现有正文冲突。

## 插入代码
```latex
% Stroke limit and variable bounds for gripper
\paragraph{Stroke limit and target force.}
\begin{equation}
\begin{aligned}
 g_{7}(\mathbf{x}) &= Z_{\max} - l \le 0
\end{aligned}
 \label{eq:gripper-g7}
\end{equation}
$Y_{c}=150\,\mathrm{N}$ limits the maximum stroke and ensures the clamping force reaches the target value $Y_{c}$ at zero displacement.

\paragraph{Variable bounds.}
\begin{equation}
\begin{aligned}
 10 \le a,b,f \le 150,\quad 0 \le e \le 50,\\
 100 \le c \le 200,\quad 100 \le l \le 300,\\
 1 \le \delta \le \pi
\end{aligned}
 \label{eq:gripper-domain}
\end{equation}
```

## 确认后执行
- 将代码追加到当前数学模型小节末尾；编译检查标签唯一与自动编号。