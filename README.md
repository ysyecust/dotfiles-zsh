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

## 安装的组件

| 组件 | 说明 |
|------|------|
| [Zim](https://zimfw.sh/) | 轻量级 Zsh 框架 |
| [Powerlevel10k](https://github.com/romkatv/powerlevel10k) | 高性能 Zsh 主题 |
| [fzf](https://github.com/junegunn/fzf) | 命令行模糊搜索 |
| [fzf-tab](https://github.com/Aloxaf/fzf-tab) | fzf 补全菜单 |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | 智能目录跳转 |
| [eza](https://github.com/eza-community/eza) | 现代化 ls |
| [bat](https://github.com/sharkdp/bat) | 带语法高亮的 cat |
| [fd](https://github.com/sharkdp/fd) | 现代化 find |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | 超快 grep |

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

### fzf 界面操作

| 按键 | 功能 |
|------|------|
| `↑/↓` | 上下选择 |
| `Enter` | 确认选择 |
| `Ctrl+/` | 切换预览窗口 |
| `Ctrl+Y` | 复制到剪贴板 |
| `Tab` | 多选 |
| `Esc` | 退出 |

## 别名

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
mkcd dir    # 创建目录并进入
extract file.tar.gz  # 自动解压各种格式
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

## 卸载

```bash
# 恢复备份的配置文件
mv ~/.zshrc.backup.* ~/.zshrc
mv ~/.zimrc.backup.* ~/.zimrc

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
