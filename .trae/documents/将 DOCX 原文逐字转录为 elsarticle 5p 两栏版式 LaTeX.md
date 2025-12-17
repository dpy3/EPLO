## 目标与约束
- 依据 `elstest-5p.pdf` 的期刊紧凑版心，切换为 `\documentclass[final,5p,times,twocolumn]{elsarticle}`。
- 从 `PPLO A Parallel Polarization Learning Optimizer .docx` 逐字转录全文到 `pplo-elsarticle.tex` 对应区块：标题、作者与单位、摘要、关键词、正文、图表题注、参考文献。
- 只做格式标记，不更改任何文字、公式、图表与参考文献条目的实际内容或顺序。

## 数据提取
- 从 DOCX 提取：
  - 题名、作者名单、单位、通讯作者/邮箱（若有）、摘要、关键词。
  - 正文各级标题与段落、列表、公式文本/编号。
  - 图题（Figure/Fig./图）、表题（Table/表）的原文说明与编号；关联的图文件从 DOCX 中导出。
  - 文末参考文献列表条目及其顺序（若 DOCX 为图片则 OCR 或手工录入）。

## LaTeX 版式与骨架
- 文档类：`final,5p,times,twocolumn`，与 `elstest-5p.pdf` 对齐。
- 必备包：`amssymb`、`amsmath`；如存在中文大段文本，优先用 XeLaTeX（`fontspec`/`xeCJK`）编译以保证字符集正确；若坚持 pdfLaTeX，则用 `CJK` 环境包裹中文。
- Frontmatter：
  - `\begin{frontmatter}` 包含 `\title{}`、若干 `\author{}` 与对应 `\affiliation{organization=..., addressline=..., city=..., postcode=..., state=..., country=...}`。
  - `\begin{abstract}...\end{abstract}` 与 `\begin{keyword} 词1 \sep 词2 ... \end{keyword}`；保留原文关键词。
  - `\journal{}` 可留空或填目标期刊名（若有）。

## 正文结构映射
- 按 DOCX 的层级映射为 `\section`、`\subsection`、`\subsubsection`；段落与列表逐字复制。
- 公式：
  - 行内公式用 `$...$`；展示数学用 `equation` 或 `align`；保留原编号及公式文本。
  - 两栏环境下跨栏展示的公式，必要时用 `equation*` + `\begin{figure*}` 宽度策略，但不更改内容。

## 图与表
- 图：
  - 从 DOCX 导出图片文件，插入 `\begin{figure}[t]`；题注 `\caption{原文题注}`；标签 `\label{fig:<编号>}`。
  - 两栏下宽度用 `\columnwidth`；若需跨栏，使用 `figure*`，但不修改题注。
- 表：
  - 用 `table` + `tabular`，逐字填入表头、数据与题注；宽表使用 `\resizebox{\columnwidth}{!}{...}`（跨栏表使用 `table*`）。
  - 保持原列顺序与数值，不做计算或合并。

## 引用与参考文献
- 保持 `elsarticle-num` 数字型引用：`\bibliographystyle{elsarticle-num}`。
- 文内引用文本若已是 `[n]` 形式，保持原样；同时在文末 `thebibliography` 中逐条添加对应 `\bibitem`，保证编号与顺序一致。
- 若 DOCX 为著者-年份形式，切换为 `authoryear` 选项与相应样式，同时逐字保留条目文本不改。

## 验证
- 编译流程：`pdflatex`（或 `xelatex`）→ `bibtex`（如用 `.bib`）→ `pdflatex` ×2，检查交叉引用、目录与图表编号。
- 两栏版式核查：调整图宽与表宽以避免 overfull/underfull，仅做版式微调（不触及文本内容）。

## 交付物
- 更新后的 `pplo-elsarticle.tex`（两栏 5p 版心，全文逐字转录）。
- 导出的图像资源目录（与编号对应）。
- 参考文献条目（`thebibliography` 或 `.bib`）。

若确认以上方案，我将立即开始从 DOCX 提取与逐字填充，并切换到 `final,5p,times,twocolumn` 版式，完成编译与版式验证后交付完整 LaTeX。