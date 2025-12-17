## 目标
- 从 `e:\postgraduate\first year\PPLO\PPLO A Parallel Polarization Learning Optimizer .pdf` 逐字转录全部内容到 `pplo-elsarticle.tex`。
- 严格遵循 `elsarticle.dtx` 定义的版式与结构，仅做格式标记，不更改任何文字、公式、图表、参考文献内容或顺序。

## 格式与类文件规范（elsarticle.dtx）
- 文档类：`\documentclass[preprint,12pt]{elsarticle}`（遵循 frontmatter 结构与 natbib 引用，参照模板与 dtx 实现）。
- 必备包：`amssymb`、`amsmath`；行号如需可启用 `lineno`。
- Frontmatter：使用 `\begin{frontmatter} ... \end{frontmatter}` 包裹标题页元素：
  - `\title{...}` 放置原文题名
  - 多个 `\author{...}` 定义作者；通信作者可加 `\corref{...}` 与 `\ead{...}`（若 PDF 有）
  - `\affiliation{organization=..., addressline=..., city=..., postcode=..., state=..., country=...}` 精确填单位信息
  - `\begin{abstract} ... \end{abstract}` 摘要原文逐字
  - `\begin{keyword} 词1 \sep 词2 \sep 词3 \end{keyword}` 关键词逐字
  - 可选：`\journal{...}`、`graphicalabstract`、`highlights` 按 PDF 是否给出填充
- 正文层级：统一映射 `\section` / `\subsection` / `\subsubsection`，按 PDF 层级落位；列表与编号原样保持。
- 公式：
  - 行内：`$...$`；
  - 独立：`equation` 或 `align`；保留原编号与文本；特殊符号按 LaTeX 对应录入（不改内容）。
- 图与表：
  - 图：`figure` 浮动体，`\includegraphics{...}` + `\caption{...}` + `\label{...}`；从 PDF 导出对应图像资源（无内容更改）。
  - 表：`table` + `tabular`，保留题注与标签；表格数据逐字转录。
- 参考文献与引用：
  - 默认数字编号：`\bibliographystyle{elsarticle-num}`；引用命令 `\cite{...}`；参考文献条目逐字转录为 `thebibliography` 或 `.bib`。
  - 若原文为著者-年份：切换 `\documentclass[...,authoryear]{elsarticle}` + `\bibliographystyle{elsarticle-harv}` 或 `elsarticle-num-names`，引用命令 `\citet`/`\citep`；内容不变。
- 附录：使用 `\appendix` 后接各附录章节。

## 逐段映射与填充步骤
1. 提取 PDF 标题、作者、单位、摘要、关键词，填入 frontmatter 对应字段。
2. 按原文目录/层级建立章节结构：为每个一级、二级、三级标题创建 `\section`/`\subsection`/`\subsubsection`，将段落与列表逐字复制。
3. 公式录入：逐个公式用合适环境录入，保留编号与内容；确保符号与上下标一致。
4. 图表处理：
   - 从 PDF 无损导出各图为 `pdf/png`；插入为 `\includegraphics`；题注与标签原文照抄。
   - 表格转为 `tabular`；对齐与列格式根据原样式设置（不改数据）。
5. 交叉引用：将文中“图x/表y/式(z)/章节引用”替换为 `\ref{...}`，标签命名与原编号一致。
6. 参考文献：逐条转录为 `thebibliography` 或 `.bib`；文中引文命令对应切换（数字或著者-年份）。
7. 附录与致谢：按原文放入 `\appendix` 后的章节或 `Acknowledgements` 段落。

## 详细修改项（仅版式，不改内容）
- 替换/统一文档类为 `elsarticle`，选项 `preprint,12pt`；剔除非模板自定义页眉页脚/行距/字体。
- 新增并规范化 frontmatter：`title`、`author`、`affiliation`、`abstract`、`keyword`。
- 章节标题统一为 LaTeX 结构化命令；不调整标题文字。
- 公式统一使用 `equation`/`align`/行内数学；内容与编号完全保持。
- 图表统一为浮动体，`\caption`/`\label` 与交叉引用规范化。
- 引用统一由 `natbib` 驱动（数字或著者-年份），`\bibliographystyle` 切换为 `elsarticle-*`；条目逐字不改。
- 附录使用 `\appendix` 开始，层级结构不变。

## 交付物
- `pplo-elsarticle.tex`：完整可编译的 LaTeX 主文件。
- 如采用 BibTeX：`pplo.bib`（逐字转录 PDF 参考文献）。
- 图像资源：从 PDF 导出的图片文件（命名与编号对应）。

## 验证
- 编译流程：`pdflatex` → `bibtex`（如用 `.bib`）→ `pdflatex` ×2；确保交叉引用、目录与参考文献正常。
- 版式核查：检查浮动体、行距、页边距与 dtx 定义一致；如需仅微调版式参数，不触及文本内容。

## 默认假设
- 引用风格默认为数字编号；如原文为著者-年份，我将自动切换相应选项与样式。
- 版式默认为单栏 `preprint`；若需两栏版心可改为 `5p,twocolumn`（不改内容）。

确认后我将开始逐字转录 PDF，并完成全部填充与编译验证，交付完整的 `pplo-elsarticle.tex`。