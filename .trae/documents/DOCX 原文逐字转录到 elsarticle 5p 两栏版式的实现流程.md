## 输入与目标
- 输入：`e:\postgraduate\first year\PPLO\PPLO A Parallel Polarization Learning Optimizer .docx`
- 目标：逐字转录到 `pplo-elsarticle.tex`，切换 `\documentclass[final,5p,times,twocolumn]{elsarticle}`，只做格式标记，不改任何文字、公式、图表、参考条目的内容与顺序。

## 版式切换
- 将现有 TeX 顶部类选项改为：`final,5p,times,twocolumn`。
- 保留/启用包：`amssymb`、`amsmath`；如 DOCX 含大段中文，则用 XeLaTeX（`fontspec`/`xeCJK`）以保证字符集。

## 数据提取（DOCX → 原文块）
- 题名页：提取标题、作者、单位（含地址、城市、邮编、省州、国家）、通讯作者与邮箱（如有）。
- 摘要与关键词：逐字获取；关键词按原顺序记录。
- 正文：读取所有层级标题与段落、列表、引文、脚注。
- 公式：识别行内与展示公式的文本与编号（含希腊字母、上下标、数学符号）。
- 图表：枚举图（Fig./Figure/图）与表（Table/表）的编号与题注原文；导出 DOCX 内嵌图片。
- 参考文献：文末参考列表逐条抓取（若为图片则 OCR 或人工逐字录入）。

## LaTeX 映射规则
- Frontmatter：
  - `\title{…}` 填标题；多位作者使用多个 `\author{…}`；对应 `\affiliation{organization=…, addressline=…, city=…, postcode=…, state=…, country=…}`。
  - `\begin{abstract}…\end{abstract}`；`\begin{keyword} 词1 \sep 词2 … \end{keyword}`。
- 正文层级：DOCX 的章/节/小节分别映射 `\section`、`\subsection`、`\subsubsection`；段落、列表逐字复制。
- 公式：
  - 行内：用 `$…$`；
  - 展示：用 `equation` 或 `align`，保留编号与式子文本；如需跨两栏，用 `equation*` 或 `figure*` 包裹，仅作版式容器。
- 图：
  - `figure`（两栏下用 `\columnwidth`）或 `figure*`（跨栏）；`\includegraphics{导出的图片路径}`；题注 `\caption{原文题注}`；标签 `\label{fig:<编号>}`。
- 表：
  - `table` + `tabular`；宽表用 `\resizebox{\columnwidth}{!}{…}` 或 `table*`（跨栏）；题注与标签同图。
- 引用与参考文献：
  - 保持数字型 `\bibliographystyle{elsarticle-num}`；`thebibliography` 中按原顺序添加 `\bibitem{ref<n>}`，条目逐字不改，与文内 `[n]` 对应。

## 交叉引用与标签
- 给每个图/表设置唯一 `\label`；文中“图 x/表 y/公式 (z)”统一用 `\ref{}` 引用（文本不改、仅加标签引用）。

## 验证与微调（不改文本）
- 编译：`pdflatex/xelatex` → `bibtex`（如用 `.bib`）→ `pdflatex` ×2。
- 两栏版式核查：
  - 处理 `overfull/underfull` 仅通过图表宽度与浮动体位置微调（`[t]`、`[!ht]`、`\columnwidth`/`figure*`），不改动正文。
  - 检查交叉引用与编号（图表、公式、节）。

## 交付物
- 更新的 `pplo-elsarticle.tex`（5p 两栏，全文逐字转录）。
- 从 DOCX 导出的图片目录（与编号对应）。
- 完整 `thebibliography` 或 `.bib`（若采用 BibTeX）。

## 说明
- 若 DOCX 含不可解析对象或扫描页，使用无损导出与占位符，人工逐字录入后替换；始终不更改原文内容，仅做结构化标记与版式容器选择。