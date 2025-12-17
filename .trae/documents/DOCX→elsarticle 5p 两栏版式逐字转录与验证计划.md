## 目标
- 将 `PPLO A Parallel Polarization Learning Optimizer .docx` 全文逐字转录到 `pplo-elsarticle.tex`，仅做版式与结构标记，不改任何文字、公式、图表、参考条目或顺序。
- 版式切换为 `\documentclass[final,5p,times,twocolumn]{elsarticle}`，与 `elstest-5p.pdf` 对齐。

## 提取与映射
- 标题/作者/单位：从 DOCX 标题页提取，映射至 `\title{}`、多个 `\author{}` 与 `\affiliation{organization=..., addressline=..., city=..., postcode=..., state=..., country=...}`。
- 摘要/关键词：`\begin{abstract}...\end{abstract}`；`\begin{keyword} 词1 \sep 词2 ... \end{keyword}`，关键词逐字录入。
- 正文层级：DOCX 的章/节/小节映射为 `\section`、`\subsection`、`\subsubsection`；段落与列表逐字复制。
- 公式：行内 `$...$`；展示用 `equation/align`，保留编号与格式；确需跨栏时用 `figure*`/`table*` 或合适环境，仅做版式包裹不改文本。
- 图与表：
  - 从 DOCX 导出所有图片，按编号插入 `figure`，题注放入 `\caption{原文题注}`，添加唯一 `\label{fig:<编号>}`；宽度使用 `\columnwidth`（跨栏用 `figure*`）。
  - 表格转为 `table+tabular`，逐字录入表头/数据/题注；宽表用 `\resizebox{\columnwidth}{!}{...}` 或 `table*` 跨栏。
- 引用与参考文献：保持数字型风格 `\bibliographystyle{elsarticle-num}`；文末 `thebibliography` 中按原顺序逐条添加 `\bibitem{...}` 并确保与文中 `[n]` 对应。

## 版式与编译
- 切换类选项为 `final,5p,times,twocolumn`；保留 `amssymb`、`amsmath`。
- 编译验证：运行 `pdflatex`（或 `xelatex`）→ `bibtex`（如使用 `.bib`）→ `pdflatex`×2；检查两栏下图表宽度、交叉引用、页数与浮动体位置。

## 交付
- 更新的 `pplo-elsarticle.tex`（两栏 5p 版式，逐字转录）。
- 从 DOCX 导出的图片资源目录（与编号一致）。
- 完整 `thebibliography` 或 `.bib` 文件（若使用 BibTeX）。

## 说明
- 全过程不更改任何文字、公式、图表数据与参考文献条目，仅做 LaTeX 版式与结构标记。
- 若 DOCX 中存在未能自动解析的元素（如嵌入对象或扫描页），将采用无损导出+占位标记并人工逐字录入，仍不改文本。