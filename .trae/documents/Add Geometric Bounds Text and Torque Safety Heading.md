## 目标
将图片中的约束性文字按 pplo-elsarticle.tex 的风格提供 LaTeX 代码，避免与正文冲突并保持两栏版式美观。

## 放置位置
- 章节：“Constraints and variable scope”。
- 紧跟在几何约束 `g_{3}`、`g_{4}` 之后，作为说明性文本与下一段落标题。

## 一致性规则
- 采用行文句式，不设置公式标签，避免与现有方程引用冲突。
- 单位用 `\mathrm{mm}`；变量记号 `\Delta R` 与 `L_{\max}` 与前文一致。

## 精确代码片段
```latex
The difference between the inner and outer radii $\Delta R \ge 20\,\mathrm{mm}$, and the total axial length $L_{\max} \le 30\,\mathrm{mm}$.

Torque safety constraint:
```

## 验证
- 编译检查两栏下无溢出；与前后段落（热负荷、兼容性或后续约束）无版式冲突。