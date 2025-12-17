## 目标
- 对 `e:\postgraduate\first year\PPLO\pplo_figures\Multiple disk clutch brake design.png` 进行高清化与可读性增强，保证标注数据（x1~x5、T）清晰、不遮挡结构。
- 生成 600 DPI 的修复版图片，并保存到 `pplo_figures`，供 LaTeX 单栏插图清晰显示。

## 修复方案
- 图像增强：
  1. 2× Lanczos 超采样（如长边<2000px则 2×，否则 1.5×），提升像素密度
  2. 自动对比度（cutoff=1%）与轻微色彩校正（+5%）
  3. 锐化（UnsharpMask: radius=1.4, percent=130, threshold=3）
- 标注清晰化：
  1. 为 `x1..x5`、`T` 添加半透明白底与黑色外描边文字，避免与深色背景冲突
  2. 调整标注位置与字号，确保单栏缩放后仍可读
- 导出：
  - 保存为 `multiple_disk_clutch_brake_fixed.png`（600 DPI, optimize, compress_level=9）

## LaTeX 引用建议
- 在文中使用：
```latex
\begin{center}
  \includegraphics[width=\columnwidth]{pplo_figures/multiple_disk_clutch_brake_fixed.png}
  \captionof{figure}{Multiple disk clutch brake design (enhanced)}
  \label{fig:clutch-brake-enhanced}
\end{center}
```

## 验证
- 编译一次 PDF，检查单栏清晰度与无漂移；如仍偏紧，可将宽度设为 `0.95\columnwidth`。

确认后我将自动修复图片、写入新文件并更新引用（或保留原引用名覆盖）。