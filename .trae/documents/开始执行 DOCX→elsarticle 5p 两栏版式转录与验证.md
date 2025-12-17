## 执行步骤
- 切换版式：将 `pplo-elsarticle.tex` 改为 `\documentclass[final,5p,times,twocolumn]{elsarticle}`。
- 题名页逐字转录：标题、作者与单位、通讯作者/邮箱（如有）、摘要、关键词。
- 正文逐字转录：按照 DOCX 的章/节/小节，逐段填入 `\section/\subsection/\subsubsection`，不改文字与顺序。
- 公式映射：行内 `$...$`，展示 `equation/align`，保留编号；需跨栏的用 `figure*`/`table*` 作为容器，不改公式文本。
- 图与表：从 DOCX 导出图片按编号插入；图用 `figure`（两栏 `\columnwidth`，跨栏 `figure*`），表用 `table+tabular`（宽表 `table*` 或 `\resizebox{\columnwidth}{!}{...}`），题注与 `\label` 逐字与编号对应。
- 参考文献：保持 `elsarticle-num`；在 `thebibliography` 中逐条添加文末参考条目，确保与文内 `[n]` 对应，条目逐字不改。
- 编译验证：`pdflatex/xelatex` → `bibtex`（如用 `.bib`）→ `pdflatex`×2，检查两栏版式下图表宽度、浮动体位置、交叉引用与编号，仅做版式微调。

## 交付物
- 更新后的 `pplo-elsarticle.tex`（5p 两栏，全文逐字转录）。
- 从 DOCX 导出的图片目录（编号一致）。
- 完整参考文献条目（`thebibliography` 或 `.bib`）。