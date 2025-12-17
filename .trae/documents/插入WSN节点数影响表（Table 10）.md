## 放置位置
- 插入于 WSN 小节（ALE 说明与实验设置之后），保持与现有表格风格一致；标签唯一避免冲突。

## 版式与兼容性
- 使用现有包：tabularx、caption；不新增宏包。
- 样式：\footnotesize、\setlength{\tabcolsep}{5pt}、\renewcommand{\arraystretch}{1.12}、\tabularx 的自适应列。
- 用分组行展示 Unimodal/Multimodal 两类拓扑，列头与数值与图片一致。

## 待插入 LaTeX 代码
```latex
\begin{table}[t]
\caption{Impact of total number of nodes}
\label{tab:wsn-impact-nodes}
\footnotesize
\setlength{\tabcolsep}{5pt}
\renewcommand{\arraystretch}{1.12}
\begin{tabularx}{\columnwidth}{@{}l c c c c@{}}
\hline
\textbf{Communication radius} & \textbf{DV-Hop} & \textbf{WOA-DV-Hop} & \textbf{GWO-DV-Hop} & \textbf{PPLO-DV-Hop} \\
\hline
\multicolumn{5}{l}{\textbf{Unimodal Topology:}} \\
50  & 5.709  & 2.038  & 3.2324 & 1.5956 \\
100 & 7.5531 & 2.0378 & 3.0522 & 1.7516 \\
150 & 5.835  & 1.9447 & 3.208  & 1.5446 \\
200 & 5.6407 & 1.9696 & 3.1872 & 1.9767 \\
250 & 5.8036 & 1.9609 & 3.1065 & 1.5321 \\
300 & 5.5286 & 2.1312 & 3.141  & 1.8856 \\
\hline
\multicolumn{5}{l}{\textbf{Multimodal Topology:}} \\
50  & 5.5268 & 2.3306 & 2.8219 & 1.8584 \\
100 & 5.0363 & 2.0204 & 2.6663 & 1.8688 \\
150 & 4.7087 & 2.4078 & 2.7273 & 1.634 \\
200 & 4.9253 & 2.4551 & 2.6133 & 2.4605 \\
250 & 4.7581 & 2.3468 & 2.6906 & 1.7416 \\
300 & 5.2584 & 2.1695 & 2.9279 & 1.7403 \\
\hline
\end{tabularx}
\end{table}
```

## 验证
- 仅插入表格环境，不更改宏包或全局设置；编译应正常。
- 通过唯一 `\label{tab:wsn-impact-nodes}` 避免与现有标签冲突；可在文中用 `Table~\ref{tab:wsn-impact-nodes}` 引用。

如确认，我将把上述代码插入到指定位置并进行版式检查。