## 目标
为“Experimental process and result analysis”提供与图片一致的段落文本 LaTeX 代码；不使用公式环境与标签，避免与正文冲突。

## 放置位置
- 章节：Planetary Gear Train Design Optimization Problem → \subsubsection{Experimental process and result analysis} 下方。

## 代码片段
```latex
Initially, algorithm parameters are initialized, including defining integer ranges for gear tooth counts ($N_{1}$ to $N_{6}$), predefined discrete sets for module values ($m_{1}$ and $m_{3}$), and the permissible range for pole pairs ($p$). Concurrently, the target gear ratio and associated design constraints (e.g., strength, geometry, and assembly requirements) are defined. Subsequently, suitable optimization algorithms—such as PPLO (Particle Population Learning Optimization) and PSO (Particle Swarm Optimization)—are selected to address the problem. Discrete variables are handled via rounding or index-mapping techniques to ensure integer feasibility. Constraint handling employs either a penalty function approach or a feasibility-first strategy to ensure solution validity. An initial population is randomly generated, and each individual's objective function value and fitness score are computed. The algorithm iteratively updates the best candidate solutions until termination criteria (e.g., maximum iterations or convergence tolerance) are met. To ensure statistical robustness, multiple independent runs are executed to compute the mean best fitness (MBF), standard deviation (STD), and convergence curves. These metrics confirm compliance with all assembly, strength, and geometric constraints in the final solution. Finally, the proposed method is benchmarked against conventional methods to quantify improvements in transmission ratio accuracy and evaluate the feasible solution rate. These metrics further assess algorithmic stability and search efficiency.
```

## 一致性
- 纯行文与行内数学 `$...$`，不含公式环境、编号或标签。
- 变量与缩写与前文统一（$N_{i}$、$m_{i}$、$p$、PPLO、PSO、MBF、STD）。

## 验证
- 与两栏版式自然衔接；无交叉引用，不影响现有结构。