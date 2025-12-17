## 目标
- 提供与稿件现有样式一致的 LaTeX 公式代码清单（已在下方给出）。
- 后续将这些公式按 1.2/1.3/1.4 的结构插入到 `pplo-elsarticle.tex`，并在两栏 5p 规范下验证无溢出、编号与引用正确。

## 插入与验证步骤
1. 在 `Problem formulation` 小节：插入初始化、Sobol 初始化、投影、归一化/罚项/综合适应度等式，给关键等式添加 `\label`。
2. 在 `Update rules of PPLO` 小节：插入速度/位置更新、参数调度、对立候选与接受准则、精英迁移；统一使用 `align` 或 `equation+aligned` 以分行与对齐。
3. 在 `Learning strategies and enhancements` 小节：插入 Lévy 扰动、有限差分梯度与范数、高斯噪声、PLO 的极光缩放与碰撞干扰、螺旋局部搜索等式。
4. 双次编译并检查日志中的 `Overfull/Underfull`，对长式调整换行位置；检查交叉引用与编号顺序；与符号表保持一致。

## 交付
- 完成插入后，提供编译通过的 PDF，并列出公式编号与所在页/段位置，确保与 PDF 原意一致。