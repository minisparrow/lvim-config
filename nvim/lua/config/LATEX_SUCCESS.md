# ✅ LaTeX 数学公式渲染 - 成功配置记录

## 最终解决方案

**日期**: 2026-09-05
**状态**: ✅ 正常工作

### 安装步骤

最简单的方法就是在 Neovim 中直接运行:

```vim
:TSInstall latex
```

这会自动:
1. 下载 tree-sitter-latex 源码
2. 生成 parser.c
3. 编译生成 .so 文件
4. 安装到 Neovim 的 parser 目录

### 现在的配置

**Snacks 配置** (`~/.config/lvim/nvim/lua/plugins/snacks.lua`):
```lua
image = {
  enabled = true,
},
```

**Treesitter 配置** (`~/.config/lvim/nvim/lua/plugins/example.lua`):
```lua
ensure_installed = {
  "bash", "c", "cpp", "dockerfile", "html", "javascript", "json",
  "lua", "markdown", "markdown_inline", "python", "rust",
  "toml", "tsx", "typescript", "vim", "vimdoc", "yaml",
}
```

**Options 配置** (`~/.config/lvim/nvim/lua/config/options.lua`):
```lua
vim.opt.conceallevel = 0
vim.opt.concealcursor = ""
```

### 使用方法

在 Markdown 文件中写 LaTeX 公式：

**行内公式**:
```markdown
这是行内公式: $E = mc^2$
```

**块级公式**:
```markdown
$$
\sum_{i=1}^{n} i = \frac{n(n+1)}{2}
$$
```

Snacks 会自动渲染这些公式为图片！

### 验证安装

在 Neovim 中执行:
```vim
:checkhealth snacks
```

应该看到:
```
- ✅ OK The `latex` treesitter parser is installed
```

### 关键要点

1. **不需要** 手动编译 tree-sitter-latex
2. **不需要** 安装额外的 Python 工具
3. **不需要** 修改 conceallevel（Snacks 不需要）
4. **只需要** 一条命令: `:TSInstall latex`

### 历程

之前的尝试都太复杂了:
- ❌ 手动 make 编译 (缺少头文件)
- ❌ Homebrew tree-sitter (不完整)
- ❌ render-markdown (需要额外工具)
- ❌ Nabla.nvim (不适合)

✅ **最终方案**: 直接用 `:TSInstall latex`

这就是最简单、最直接的方法！

---

**记录者**: 经过长时间调试后发现的最优解决方案
**更新日期**: 2026-09-05
