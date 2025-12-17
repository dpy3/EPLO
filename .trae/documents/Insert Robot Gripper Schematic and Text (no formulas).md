## 目标
按 pplo-elsarticle.tex 风格插入机械手夹持器示意图，并以行文（非公式）说明图中标注变量；避免与现有正文冲突与重复标签。

## 放置位置
- 章节：“Robot Gripper Design”或对应设计小节的开头（若未建立，可置于相关设计问题章节的图示位置）。

## 图片插入代码
```latex
\begin{center}
  \includegraphics[width=\columnwidth]{pplo_figures/Robot Gripper Design.jpg}
  \captionof{figure}{Robotic gripper linkage schematic with annotated variables}
  \label{fig:gripper-schematic}
\end{center}
```

## 变量说明（行文，非公式）
```latex
The schematic annotates the key parameters used in the gripper design: $a$, $b$, $c$ (link segment lengths), $e$ (vertical spacing), $f$ (horizontal spacing), $l$ (overall reach/spacing scale), $z$ (intermediate joint axis), $\delta$ (rotation angle at the top joint), and $p$ (actuation point). These textual definitions mirror the labels in Figure~\ref{fig:gripper-schematic} and are used consistently in subsequent analysis.
```

## 一致性
- 使用 `\columnwidth` 保证双栏版式不溢出。
- 标签 `fig:gripper-schematic` 保持唯一，不与现有图标签冲突。
- 变量说明仅为行文（行内数学），不采用公式环境。

## 验证
- 插入后编译检查图片与文本在两栏中对齐且无溢出。