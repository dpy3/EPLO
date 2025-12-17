## 目标与范围
- 依据 `e:\postgraduate\first year\PPLO\elsarticle` 提供的官方模板，将 `PPLO A Parallel Polarization Learning Optimizer .pdf` 的全文内容转成 `elsarticle` LaTeX。
- 只调整排版与版式，不改动任何文字、公式、图表、参考文献的实际内容与顺序。
- 交付一个可编译的 `.tex` 文件（必要时附 `.bib` 与图像资源），编译后版式符合 Elsevier 期刊通用格式。

## 模板与样式选择
- 文档类：`\documentclass[preprint,12pt]{elsarticle}`（对照 `elsarticle-template-num.tex`）。
- 字体/数学：启用 `\usepackage{amssymb}`、`\usepackage{amsmath}`，与模板保持一致。
- 版心：默认单栏 `preprint`。若需期刊版心，可切换 `1p/3p/5p` 或两栏选项（例如 `5p,twocolumn`）。
- 引用样式：优先按论文现状选择
  - 若参考文献为数字编号式：使用 `elsarticle-num`（数字型）
  - 若为著者-年份：使用 `elsarticle-harv` 或 `elsarticle-num-names`

## 结构映射规则（保持内容不改）
- Frontmatter（题名页）
  - 标题 → `\title{...}`
  - 作者列表 → 多个 `\author{...}`；通讯作者加 `\corref{...}`；邮箱用 `\ead{...}`
  - 作者单位 → 用 `\affiliation{organization=..., addressline=..., city=..., postcode=..., state=..., country=...}` 精确填充
  - 摘要 → `\begin{abstract}...\end{abstract}`（原文逐字放入）
  - 关键词 → `\begin{keyword} 词1 \sep 词2 \sep 词3 \end{keyword}`（原文逐字放入）
  - 期刊占位 → `\journal{...}` 可留空或填写目标期刊名
- 正文层级
  - 原 PDF 中的章/节/小节 → 依次映射为 `\section`、`\subsection`、`\subsubsection`
  - 段落与列表保持原有顺序与内容；编号、项目符号照抄
- 公式与符号
  - 行内公式 → `$ ... $`
  - 独立公式 → 使用 `equation` 或 `align`；按原编号保留，公式内容逐字录入
- 图与表
  - 图：`\begin{figure}[t] \centering \includegraphics{...} \caption{...} \label{...} \end{figure}`
  - 表：`\begin{table}[t] ... \caption{...} \label{...} \end{table}`
  - 图表题注、编号、交叉引用全部保持原文；必要时从 PDF 导出图片素材（无内容更改）
- 参考文献
  - 数字型：`\bibliographystyle{elsarticle-num}` + `.bib` 或 `thebibliography`；逐条照抄
  - 著者-年份型：`\bibliographystyle{elsarticle-harv}` 或 `elsarticle-num-names`；逐条照抄
  - 引文文本的样式通过 `natbib` 自动控制，内容不变
- 附录
  - 以 `\appendix` 开始，附录标题与内容照抄

## 详细改动清单（仅版式与结构）
- 文档类替换为 `elsarticle`，选项统一为 `preprint,12pt`
- 增加 `amssymb`、`amsmath` 以匹配模板数学环境
- 新增并规范化 `frontmatter` 区块（`title`/`author`/`affiliation`/`abstract`/`keyword`）
- 章节标题统一改为 `\section`/`\subsection`/`\subsubsection` 结构
- 公式环境统一为 `equation`/`align`，保留原编号与内容
- 图表统一为 LaTeX 浮动体格式，`\caption`/`\label` 衔接交叉引用
- 引文命令统一使用 `natbib`（数字型或著者-年份），`\bibliographystyle` 切换为对应 `elsarticle-*`
- 去除非模板自定义的页眉页脚/行距/字体等，以类文件默认控制为准
- 不改动任何正文词句、图表数据、公式与参考文献条目的文本

## 交付物
- `pplo-elsarticle.tex`（完整 LaTeX 主文件）
- 若参考文献采用 BibTeX：`pplo.bib`（由 PDF 参考文献逐条转录）
- 图像资源：从 PDF 无损导出（如 `fig1.pdf/png`），仅用于 `\includegraphics`，不改内容

## 验证与编译
- 使用 `pdflatex`/`bibtex` 编译：`pdflatex` → `bibtex` → `pdflatex` ×2，确保交叉引用与参考文献正确
- 检查编译告警（标签、引用、浮动体），必要时只做版式微调，不触及内容

## 需要您的偏好（无则按默认执行）
- 引用样式：数字编号 或 著者-年份
- 版式：是否需要两栏（如 `5p,twocolumn`）
- 期刊占位：`\journal{...}` 是否填写目标期刊名

## 示例骨架（内容将逐字粘贴到占位处）
```tex
\documentclass[preprint,12pt]{elsarticle}
\usepackage{amssymb}
\usepackage{amsmath}
\journal{}
\begin{document}
\begin{frontmatter}
\title{PPLO: A Parallel Polarization Learning Optimizer}
\author{<作者1>}
\affiliation{organization={<单位1>}, addressline={<地址>}, city={<城市>}, postcode={<邮编>}, state={<省州>}, country={<国家>}}
\author{<作者2>}
\affiliation{organization={<单位2>}, addressline={<地址>}, city={<城市>}, postcode={<邮编>}, state={<省州>}, country={<国家>}}
\begin{abstract}
<摘要原文逐字>
\end{abstract}
\begin{keyword}
<关键词1> \sep <关键词2> \sep <关键词3>
\end{keyword}
\end{frontmatter}
\section{<原文一级标题>}
<正文逐字>
\subsection{<原文二级标题>}
<正文逐字>
% ... 其余章节、图表、公式逐一按原文填充
\bibliographystyle{elsarticle-num}
\begin{thebibliography}{00}
% 逐条照抄参考文献或改用 .bib
\end{thebibliography}
\end{document}
```

——请确认以上方案与偏好（尤其是“引用样式”和“是否两栏”）。确认后我将开始录入 PDF 内容，生成可编译的 `pplo-elsarticle.tex` 并进行验证。