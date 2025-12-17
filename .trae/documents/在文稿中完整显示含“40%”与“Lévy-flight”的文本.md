## 问题
- LaTeX 中 `%` 是注释符，未转义会导致其后的内容被忽略，出现“显示不完整”。
- “Lévy”需要重音，建议使用 `L\'evy` 以兼容当前字体。

## 插入位置
- 建议放在 `\paragraph{Auroral motion operators (PLO).}` 段落前后均可，或相应算法说明段落内作为一句普通正文。

## 可直接粘贴的 LaTeX 文本
```latex
\noindent L\'evy-flight perturbation is applied to the global best ($gBest$) for random long-range jumps. After 40\% of iterations, introduce L\'evy-flight perturbation for multi-strategy tuning.
```

## 兼容性
- 不引入新宏包；与当前 `elsarticle` + `txfonts` 环境兼容。
- 使用 `\noindent` 防止首行缩进，与现有正文风格一致；如不需要可去掉。

请确认后我将把该文本插入到指定位置并验证编译。