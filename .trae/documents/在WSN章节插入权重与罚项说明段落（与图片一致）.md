## 插入位置
- 放置在 `\section{Node localization method for three-dimensional wireless sensor networks}` 小节中，紧随 `Eq.~\eqref{eq:wsn-fitness-compact}` 与 `Eq.~\eqref{eq:wsn-penalty-comp}` 之后、`Eq.~\eqref{eq:wsn-ale}` 之前或之后均可；文内已存在同风格段落与 `enumitem` 设置，保持一致。

## 文本风格与兼容性
- 使用普通段落与 `enumerate[label=(\arabic*), leftmargin=*, itemsep=0pt, topsep=2pt]`，不新增宏包。
- 引用现有公式标签（如 `\eqref{eq:wsn-ale}`），避免新增冲突标签。

## 拟插入的LaTeX代码
```latex
% 解释权重与边界罚项的作用（紧跟适应度函数之后）
Here, $\mathbf{x}_{u}$ is the candidate 3-D estimate, $\mathbf{x}_{k}$ are anchor coordinates,
$d_{ku}$ are estimated distances, $w_{ku}$ are anchor weights, $\lambda$ is a penalty coefficient,
and $P(\mathbf{x}_{u})$ penalizes boundary violations. The first term is a weighted squared
relative residual, preventing large absolute distances from dominating the objective; weights
favor more reliable anchors. The penalty term ensures feasible physical solutions within the
predefined search box. Anchor weights are defined as an inverse function of hop count.

% ALE 指标说明（可放在 Eq.~\eqref{eq:wsn-ale} 附近）
The primary performance metric is Average Localization Error (ALE) defined as in
Eq.~\eqref{eq:wsn-ale}. $U$ is the number of unknown nodes, $\hat{x}_{i},\hat{y}_{i},\hat{z}_{i}$
are the estimates, $x_{i},y_{i},z_{i}$ are true coordinates, and $R$ is the communication radius.
ALE normalizes errors by $R$, facilitating comparisons across connectivity regimes. Standard
deviation reflects stability, and convergence curves indicate convergence speed and late-stage
refinement ability.

% 实验设置（统一风格的枚举）
\begin{enumerate}[label=(\arabic*), leftmargin=*, itemsep=0pt, topsep=2pt]
  \item Generate $N=100$ uniformly random nodes inside a $100\times100\times100$ cube and randomly select $M=20$ anchors.
  \item Set communication radius $R=30\,\mathrm{m}$.
  \item For each unknown node, run the optimizer independently to obtain estimated coordinates.
  \item Repeat each algorithm for 30 independent runs with different random initial populations; report ALE mean and standard deviation.
\end{enumerate}
```

## 验证
- 编译时不引入新宏包；仅段落与枚举，保证与 `elsarticle` 和现有 `amsmath` 环境兼容。
- 交叉引用 `\eqref{eq:wsn-ale}` 可正确渲染；若需中文排版，可保持英文术语以匹配当前章节风格。

请确认以上代码片段与插入位置；确认后我将把代码插入到指定位置并再次编译以验证版式与引用正常。