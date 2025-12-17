## 位置与风格
- 位置：在 `Robot Gripper Design Optimization Problem → Mathematical model` 小节的空行处（约 791 行）插入。
- 保持文档风格：使用 `amsmath` 已加载环境，变量向量用 `\mathbf{x}`，分段标题用 `\paragraph{...}`，方程统一编号并添加唯一 `\label`，不引入新宏或包。

## 不与正文冲突的约束
- 所有 `\label` 采用前缀 `eq:gripper-*`，避免与现有标签重复。
- 使用已存在的符号风格（粗体向量、`equation`+`aligned`）。
- 文案为英文以匹配整篇论文主体。

## 插入代码
```latex
% Gripper mathematical model (insert below line ~791)
\paragraph{Decision variables.}
Variable vector $\mathbf{x}=[a,b,c,e,f,l,\delta]$, where $a$ and $b$ are the lengths of the active and driven arms (mm), $c$ is the gripper connecting rod length (mm), $e$ and $f$ are geometric offsets (mm), $l$ is the gripper stroke (mm), and $\delta$ is the transmission angle offset (rad).

\paragraph{Objective.}
Minimize the difference between the maximum and minimum clamping force:
\begin{equation}
\begin{aligned}
 f(\mathbf{x}) &= \max_{z\in[0,\,Z_{\max}]}\, F_{k}(\mathbf{x}, z)\; -\; \min_{z\in[0,\,Z_{\max}]}\, F_{k}(\mathbf{x}, z)
\end{aligned}
 \label{eq:gripper-obj}
\end{equation}
Where $F_{k}$ is the transmission relationship function between input force and clamping force, and $Z_{\max}=100\,\mathrm{mm}$ is the maximum stroke.

\paragraph{Lower-limit constraint.}
\begin{equation}
\begin{aligned}
 g_{1}(\mathbf{x}) &= -Y_{\min} + y(\mathbf{x}, Z_{\max}) \le 0
\end{aligned}
 \label{eq:gripper-g1}
\end{equation}
Here $Y_{\min}=50\,\mathrm{N}$ ensures the clamping force does not fall below the lower limit at maximum displacement.

\paragraph{Upper-limit constraint.}
\begin{equation}
\begin{aligned}
 g_{4}(\mathbf{x}) &= y(\mathbf{x}, 0) - Y_{c} \le 0
\end{aligned}
 \label{eq:gripper-g4}
\end{equation}
At zero displacement (fully closed), the gripping force $y(\mathbf{x},0)$ should not exceed the preset target $Y_{c}=50\,\mathrm{N}$.

\paragraph{Geometric compatibility.}
\begin{equation}
\begin{aligned}
 g_{5}(\mathbf{x}) &= l^{2} + e^{2} - (a + b)^{2} \le 0
\end{aligned}
 \label{eq:gripper-g5}
\end{equation}

\paragraph{Kinematic closure and complementarity.}
\begin{equation}
\begin{aligned}
 g_{6}(\mathbf{x}) &= b^{2} - (a - e)^{2} - (l - Z_{\max})^{2} \le 0
\end{aligned}
 \label{eq:gripper-g6}
\end{equation}
```

## 确认后执行
- 将上述代码插入到指定位置。
- 编译检查：确保方程自动编号、引用不报错，标签唯一。
- 若有单位或符号需与图注统一，可在插入后微调文字说明但不改公式。