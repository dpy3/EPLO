## 将进行的具体改动
- 切换 `pplo-elsarticle.tex` 到两栏紧凑版心：`\documentclass[final,5p,times,twocolumn]{elsarticle}`。
- 题名页逐字填入 DOCX：`title`、`author`、`affiliation`、`abstract`、`keyword`，不改任何文本与顺序。
- 正文逐字转录：将 DOCX 的全部章节/小节/段落映射到 `\section/\subsection/\subsubsection`，保留文内 `[n]`。
- 公式：行内 `$...$`、展示 `equation/align`；必要跨栏仅换容器（`figure*`/`table*`），不改公式文本与编号。
- 图：从 DOCX/已导出的图目录按编号插入 `figure`（两栏用 `\columnwidth`，跨栏 `figure*`），逐字填 `\caption`，添加唯一 `\label{fig:<编号>}`。
- 表：逐字填入所有表头/数据/题注；宽表用 `\resizebox{\columnwidth}{!}{...}` 或 `table*`，保留原列顺序与数值。
- 参考文献：保持 `elsarticle-num`，在 `thebibliography` 中逐条添加 DOCX 文末条目，确保与文内编号一致。

## 编译与验证
- 运行编译流程（LaTeX → 文献 → LaTeX×2），检查两栏下图表宽度、浮动体位置、交叉引用与编号；如有 `overfull/underfull` 仅做容器/宽度微调，不触及正文与题注文本。

## 交付
- 更新后的 `pplo-elsarticle.tex`（5p 两栏，全文逐字转录）。
- 从 DOCX 导出的图片目录（编号一致）。
- 完整的参考文献条目。