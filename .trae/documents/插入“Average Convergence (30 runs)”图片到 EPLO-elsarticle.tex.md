## 插入目标
- 将收敛曲线图片插入到 `e:\postgraduate\first year\PPLO\pplo-elsarticle.tex`，不与正文冲突，遵循 5p 双栏版式。
- 推荐位置：在 CEC2022 结果表（`tab:cec2022-10d` 与 `tab:cec2022-20d`）之后或对应收敛分析段落中。

## 文件与路径
- 目录已有相关图片文件，例如 `pplo_figures/Convergence curve comparison chart.png`；若您要使用本消息的图片，请将其保存到 `pplo_figures` 并命名为 `avg_convergence.png`（或沿用现有文件名），下面代码可直接替换文件名。

## 方案 A：紧随正文的非浮动插入（位置最稳定）
```latex
\begin{center}
  \includegraphics[width=\columnwidth]{pplo_figures/avg_convergence.png}% 替换为实际文件名
  \captionof{figure}{Average convergence over 30 runs across algorithms}
  \label{fig:avg-convergence}
\end{center}
```
- 优点：图片严格出现在插入点；不与其他正文冲突。
- 依赖：`capt-of` 已在导言区加载，可使用 `\captionof{figure}`。

## 方案 B：标准浮动体（期刊风格，位置可能上移/下移）
```latex
\begin{figure}[t]
  \centering
  \includegraphics[width=\columnwidth]{pplo_figures/avg_convergence.png}% 替换为实际文件名
  \caption{Average convergence over 30 runs across algorithms}
  \label{fig:avg-convergence}
\end{figure}
```
- 优点：符合常规浮动体排版；自动编号与引用。
- 注意：浮动体可能漂移到页顶/页底；若需跨两栏，用 `figure*` 并将宽度改为 `\textwidth`。

## 跨两栏（可选）
```latex
\begin{figure*}[t]
  \centering
  \includegraphics[width=\textwidth]{pplo_figures/avg_convergence.png}% 替换为实际文件名
  \caption{Average convergence over 30 runs across algorithms}
  \label{fig:avg-convergence-wide}
\end{figure*}
```

## 标签与引用
- 在正文中引用：`Figure~\ref{fig:avg-convergence}`。
- 保持与现有文档一致的英文标题与标签前缀（`fig:`）。

## 后续验证
- 保存图片到 `pplo_figures` 并按需替换文件名。
- 插入代码后编译，确认无缺图警告，位置与版式正常。

确认后我将采用方案 A 在结果表之后插入并验证编译；如需改为方案 B/跨栏请说明。