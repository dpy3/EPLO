## 目标
- 将 `PPLO A Parallel Polarization Learning Optimizer .pdf` 的全部内容逐字转录到 `pplo-elsarticle.tex`，严格遵循 `elsarticle.dtx` 的版式与结构。
- 只做格式标记，不更改任何文字、数字、公式、图表与参考文献的实际内容或顺序。

## 版式与结构（对齐 elsarticle.dtx）
- 文档类：`\documentclass[preprint,12pt]{elsarticle}`；frontmatter 结构与 `natbib` 引用。
- 包：`amssymb`、`amsmath`；如需行号可加 `lineno`（默认关闭）。
- Frontmatter：`\begin{frontmatter} ... \end{frontmatter}` 包含：
  - `\title{...}`：论文题名（逐字填入）
  - `\author{...}` + `\affiliation{organization=..., addressline=..., city=..., postcode=..., state=..., country=...}`：作者与单位（逐字填入），通讯作者与邮箱使用 `\corref{}`、`\ead{}`（若 PDF 给出）
  - `\begin{abstract} ... \end{abstract}`：摘要全文
  - `\begin{keyword} 词1 \sep 词2 \sep 词3 ... \end{keyword}`：关键词逐字
  - 若原文包含：`graphicalabstract` 与 `highlights` 将逐字填充
- 正文层级：按 PDF 标题层级映射到 `\section`、`\subsection`、`\subsubsection`；段落与列表逐字复制。
- 公式：
  - 行内数学用 `$...$`；
  - 展示数学用 `equation` 或 `align`；保持原文编号与内容不变；特殊符号按 LaTeX 录入。
- 图与表：
  - 图：用 `figure` 浮动体，`\includegraphics{...}` + `\caption{...}` + `\label{...}`；从 PDF 无损导出图像资源，不改内容。
  - 表：用 `table` + `tabular`；列格式按原表格版式设置，数据逐字录入。
- 引用与参考文献：
  - 若 PDF 为数字编号：设置 `\bibliographystyle{elsarticle-num}`，正文使用 `\cite{...}`；参考文献逐条照抄到 `thebibliography` 或 `.bib`。
  - 若为著者-年份：切换 `authoryear` 选项与 `\bibliographystyle{elsarticle-harv}` 或 `elsarticle-num-names`，正文使用 `\citet`/`\citep`；内容不变。
- 附录：使用 `\appendix`，按原文附录层级填充。

## 实施步骤
1. 标题页转录：提取并填入题名、作者、单位、邮箱/通讯作者、摘要与关键词。
2. 目录与层级：根据 PDF 目录，创建全部章节结构并逐段复制正文与列表文本。
3. 公式录入：逐个公式用合适环境录入，保持编号；行内/展示数学严格对应原文。
4. 图像提取：从 PDF 导出各图为 `pdf/png`，插入 `\includegraphics`；题注与标签逐字填入，编号保持一致。
5. 表格转录：将表格数据与题注逐字转到 `tabular`；对齐方式按原表设置。
6. 交叉引用：将“图x/表y/式(z)/节”文本转为 `\ref{...}`，标签命名与原编号对应。
7. 参考文献：逐条录入到 `thebibliography` 或 `.bib`；正文引文命令与样式自动匹配原文（数字或著者-年份）。
8. 附录与致谢：在 `\appendix` 后按原文填充。

## 验证
- 编译流程：`pdflatex` → `bibtex`（如用 `.bib`）→ `pdflatex` ×2。
- 检查交叉引用、目录、图表编号与原文一致；仅微调浮动体位置参数，不触及内容。

## 交付物
- 更新后的 `pplo-elsarticle.tex`（完整可编译）。
- 如需：`pplo.bib`（若采用 BibTeX）。
- 导出的图像资源文件（与原编号一致）。

确认后我将开始逐字填充 PDF 全文到 LaTeX，并完成编译验证，确保不改动任何内容。