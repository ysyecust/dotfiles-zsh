# Zsh Terminal Enhancement

一键配置现代化、高效的 Zsh 终端环境。

![Shell](https://img.shields.io/badge/Shell-Zsh-green)
![Platform](https://img.shields.io/badge/Platform-macOS-blue)
![License](https://img.shields.io/badge/License-MIT-yellow)

## 特性

- **极速启动** - 优化配置，启动时间 < 100ms
- **智能补全** - fzf-tab 模糊搜索补全
- **智能跳转** - zoxide 学习你的使用习惯
- **现代化工具** - eza、bat、fd、ripgrep 替代传统命令
- **美观主题** - Powerlevel10k 高度可定制
- **Git 增强** - lazygit + fzf-git 强大的 Git 操作
- **文件管理** - yazi 现代终端文件管理器
- **终端复用** - tmux 多窗口、会话管理
- **版本管理** - mise 统一管理 Node/Python/Go 版本
- **AI 集成** - Claude CLI 无头模式快捷命令

## 安装的组件

| 组件 | 说明 |
|------|------|
| [Zim](https://zimfw.sh/) | 轻量级 Zsh 框架 |
| [Powerlevel10k](https://github.com/romkatv/powerlevel10k) | 高性能 Zsh 主题 |
| [fzf](https://github.com/junegunn/fzf) | 命令行模糊搜索 |
| [fzf-tab](https://github.com/Aloxaf/fzf-tab) | fzf 补全菜单 |
| [fzf-git.sh](https://github.com/junegunn/fzf-git.sh) | Git 操作增强 |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | 智能目录跳转 |
| [eza](https://github.com/eza-community/eza) | 现代化 ls |
| [bat](https://github.com/sharkdp/bat) | 带语法高亮的 cat |
| [fd](https://github.com/sharkdp/fd) | 现代化 find |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | 超快 grep |
| [lazygit](https://github.com/jesseduffield/lazygit) | 终端 Git UI |
| [yazi](https://github.com/sxyazi/yazi) | 终端文件管理器 |
| [tmux](https://github.com/tmux/tmux) | 终端复用器 |
| [mise](https://github.com/jdx/mise) | 多语言版本管理 |

## 快速安装

```bash
# 克隆仓库
git clone https://github.com/ysyecust/dotfiles-zsh.git ~/dotfiles-zsh

# 运行安装脚本
cd ~/dotfiles-zsh
chmod +x install.sh
./install.sh

# 重启终端或执行
source ~/.zshrc
```

## 快捷键

### fzf 快捷键

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+T` | 模糊搜索文件并插入路径 |
| `Ctrl+R` | 模糊搜索命令历史 |
| `Alt+C` | 模糊搜索目录并跳转 |

### fzf-git 快捷键 (需要在 Git 仓库中)

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+G Ctrl+F` | 搜索 Git 文件 |
| `Ctrl+G Ctrl+B` | 搜索分支 |
| `Ctrl+G Ctrl+T` | 搜索标签 |
| `Ctrl+G Ctrl+H` | 搜索提交历史 |
| `Ctrl+G Ctrl+R` | 搜索远程仓库 |
| `Ctrl+G Ctrl+S` | 搜索 Stash |

### tmux 快捷键 (前缀键: Ctrl+A)

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+A \|` | 垂直分割窗口 |
| `Ctrl+A -` | 水平分割窗口 |
| `Ctrl+A h/j/k/l` | 在窗格间导航 |
| `Ctrl+A g` | 打开 lazygit 弹窗 |
| `Ctrl+A y` | 打开 yazi 弹窗 |
| `Ctrl+A r` | 重新加载配置 |

## 别名

### 工具快捷方式

```bash
lg          # lazygit - 终端 Git UI
y           # yazi - 文件管理器（退出时 cd 到所在目录）
help        # tldr - 简化版 man
```

### 文件列表 (eza)

```bash
ls      # 基本列表，带图标
ll      # 详细列表，带 git 状态
la      # 详细列表，包含隐藏文件
lt      # 树形显示（2层）
lta     # 树形显示（3层，含隐藏）
```

### 文件查看 (bat)

```bash
cat     # 语法高亮（无行号）
catn    # 语法高亮（带行号）
```

### Git

```bash
gs      # git status -sb
gd      # git diff
gds     # git diff --staged
gl      # git log --oneline -20
gla     # git log --all --graph
```

### 导航

```bash
..      # cd ..
...     # cd ../..
....    # cd ../../..
```

### 工具

```bash
reload  # 重新加载 .zshrc
path    # 显示 PATH（每行一个）
ports   # 显示监听的端口
```

## Claude CLI 集成

需要先安装 Claude CLI：
```bash
npm install -g @anthropic-ai/claude-code
```

### 快捷命令

```bash
# 直接问问题
ask "how to reverse a string in python"

# 带文件上下文提问
askf main.py "explain this code"

# 生成代码
gen "create a python script that downloads images from a URL"

# 解释命令
explain "find . -name '*.py' -exec grep -l 'import os' {} +"

# 修复错误
fix "ModuleNotFoundError: No module named 'requests'"

# 管道分析
cat error.log | ask-pipe "analyze these errors"

# 生成 Git 提交信息
git add .
gcm   # 自动分析 staged 更改并生成提交信息

# 代码审查
review main.py
```

## 自定义函数

### zoxide - 智能跳转

```bash
z foo       # 跳转到包含 "foo" 的常用目录
z foo bar   # 跳转到包含 "foo" 和 "bar" 的目录
zi          # 交互式选择目录
```

### fzf 增强函数

```bash
fe          # 搜索文件并用编辑器打开
fcd         # 搜索目录并进入
fbr         # 切换 git 分支
fkill       # 选择并杀死进程
```

### 实用函数

```bash
mkcd dir              # 创建目录并进入
extract file.tar.gz   # 自动解压各种格式
```

## mise 版本管理

mise 替代 nvm、pyenv、goenv 等工具，统一管理多种语言版本：

```bash
# 安装 Node.js
mise use node@20

# 安装 Python
mise use python@3.12

# 安装 Go
mise use go@1.22

# 查看已安装版本
mise list

# 在项目中固定版本（创建 .mise.toml）
mise use node@20 --pin
```

## 自定义配置

### 本地配置

创建 `~/.zshrc.local` 文件添加机器特定的配置，不会被覆盖：

```bash
# ~/.zshrc.local
export MY_CUSTOM_VAR="value"
alias myalias='my-command'
```

### 修改主题

```bash
p10k configure
```

### 添加 Zim 模块

编辑 `~/.zimrc`，然后运行：

```bash
zimfw install
```

## 目录结构

```
dotfiles-zsh/
├── install.sh          # 安装脚本
├── README.md           # 说明文档
└── config/
    ├── .zimrc          # Zim 框架配置
    ├── .zshrc          # Zsh 主配置
    ├── .tmux.conf      # Tmux 配置
    ├── fzf-git.sh      # fzf-git 脚本
    └── .p10k.zsh       # Powerlevel10k 配置（可选）
```

## 故障排除

### 字体图标显示异常

安装 Nerd Font 字体：

```bash
brew tap homebrew/cask-fonts
brew install --cask font-meslo-lg-nerd-font
```

然后在终端设置中选择 "MesloLGS NF" 字体。

### zoxide 不工作

zoxide 需要学习你的目录使用习惯。多使用 `cd` 命令访问目录后，`z` 才会记住它们。

### fzf 快捷键不工作

确保 fzf 正确安装：

```bash
brew reinstall fzf
$(brew --prefix)/opt/fzf/install
```

### tmux 颜色显示异常

确保终端支持 256 色，并在终端设置中启用 "Report Terminal Type" 为 `xterm-256color`。

## 卸载

```bash
# 恢复备份的配置文件
mv ~/.zshrc.backup.* ~/.zshrc
mv ~/.zimrc.backup.* ~/.zimrc
mv ~/.tmux.conf.backup.* ~/.tmux.conf

# 或者删除 Zim
rm -rf ~/.zim
```

## License

MIT

## 致谢

- [Zim](https://zimfw.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [fzf](https://github.com/junegunn/fzf)
- [zoxide](https://github.com/ajeetdsouza/zoxide)
- [lazygit](https://github.com/jesseduffield/lazygit)
- [yazi](https://github.com/sxyazi/yazi)
- [mise](https://github.com/jdx/mise)
