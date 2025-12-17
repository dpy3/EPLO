## 目标
- 逐字填入 PDF 的所有表格数值到 LaTeX `table`，不改动任何数值或顺序。
- 逐字填入所有图题到 `figure` 的 `\caption`，并为每幅图添加唯一 `\label`；图片引用使用已导出的 `pplo_figures/*`。
- 从 PDF 文末解析参考文献列表，逐条添加到 `thebibliography`，确保与文内数字编号一致。

## 方法
- 表格：
  - 为 CEC2022 等宽表使用 `\resizebox{\textwidth}{!}{...}` 包裹 `tabular`，按照 F1–F12×(avg/std/rank) + Mean Rank + Win 的列结构搭建；逐条填入 `pplo_extracted.txt` 中对应算法（PPLO、BKA、WOA、FOX、PLO、ALO、BA、GSA、HHO、MFO）的数值。
  - 保持原列标题与行顺序；不做计算或改写。
- 图题：
  - 通过页文本匹配 `Fig.`/`Figure` 获取编号与题注；将相应页的导出图片文件插入 `figure` 并设置 `\caption{原文题注}` 与 `\label{fig:<编号>}`。
  - 若一页多图，分别插入多个 `figure`，保持原编号语义；不修改题注文本。
- 参考文献：
  - 检索 PDF 末页文本；若为图片，进行 OCR 提取文本（或逐条手工录入），按原顺序添加 `\bibitem{ref<n>}`；条目内容逐字不改。
  - 保持 `\bibliographystyle{elsarticle-num}`。

## 验证
- 运行 `pdflatex` → `bibtex`（如用 `.bib`）→ `pdflatex`×2，检查交叉引用、图表编号与目录；确保所有 `\ref{}` 指向正确。

## 交付
- 更新后的 `pplo-elsarticle.tex`（完整表格数值、图题与参考文献）。
- `pplo_figures` 图像资源已就位；如需额外导出将补充。