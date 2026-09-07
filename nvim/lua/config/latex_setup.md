# LaTeX 数学公式渲染配置

## 概述

由于 LaTeX Treesitter parser 编译复杂，采用 `render-markdown.nvim` 来渲染 LaTeX 公式。

## 配置位置

- **主配置文件**: `~/.config/lvim/nvim/lua/plugins/markdown-extra.lua`
- **启用选项**:
  - `latex.enabled = true` - 启用 LaTeX 渲染
  - `latex.inline = true` - 渲染行内公式 `$...$`
  - `latex.block = true` - 渲染块级公式 `$$...$$`

## 使用方法

### 1. 打开 Markdown 文件
```bash
nvim your_file.md
```

### 2. 启用/禁用渲染
```
<leader>rm
```

或执行命令:
```vim
:RenderMarkdown toggle
```

### 3. LaTeX 公式语法

**行内公式**:
```markdown
E = mc^2 is written as $E = mc^2$
```

**块级公式**:
```markdown
$$
\sum_{i=1}^{n} i = \frac{n(n+1)}{2}
$$
```

**代码块**:
````markdown
```latex
\frac{1}{2}
```
````

## 特性

✓ 自动转换 LaTeX 公式为可读的 Unicode 字符
✓ 支持行内和块级公式
✓ 实时切换显示/隐藏
✓ 不需要 Treesitter parser
✓ 轻量级，性能好

## 支持的公式

- 基础: `$a + b$`, `$x^2$`, `$\sqrt{x}$`
- 分数: `$\frac{1}{2}$`
- 求和/积分: `$\sum$`, `$\int$`
- 矩阵: `$\begin{matrix}...\end{matrix}$`
- 希腊字母: `$\alpha$`, `$\beta$`, `$\gamma$`

## 示例

创建测试文件:
```bash
nvim /tmp/latex_demo.md
```

文件内容会自动渲染 LaTeX 公式。

## 快捷键

| 按键 | 功能 |
|------|------|
| `<leader>rm` | 切换 Markdown 渲染 |

## 更多选项

详见 render-markdown.nvim 文档:
https://github.com/MeanderingProgrammer/render-markdown.nvim

或在 Neovim 中查看配置:
```vim
:help render-markdown
```
