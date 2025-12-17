## 目标
将图片中的说明文本与下一约束标题按 pplo-elsarticle.tex 风格加入文档，避免与正文冲突。

## 放置位置
- 章节：“Constraints and variable scope”。
- 紧接已插入的 `g_{5}` 与 `M_{h}` 公式之后，`\paragraph{Auroral motion operators (PLO).}` 之前。

## 一致性规则
- 使用数学体符号 `M_{h}` 与安全系数 `s=1.5`。
- 作为普通行文与段落标题插入，不添加公式标签与环境，避免引用冲突。

## 精确代码片段
```latex
Ensure that the braking torque $M_{h}$ meets the safety factor $s=1.5$ to avoid overload failure.

Time and speed constraints:
```

## 验证
- 与前后段落衔接良好；双栏版式下行宽正常，无溢出。
- 保持术语与前文一致（$M_{h}$、安全系数 s）。