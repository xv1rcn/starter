# 💤 LazyVim

基于 [LazyVim](https://github.com/LazyVim/LazyVim) v16 和 [LazyVim/starter](https://github.com/LazyVim/starter) 的个人 Neovim 配置。

## 仪表盘整合一言

Alpha 仪表盘集成了 [一言](https://hitokoto.cn/) API，每次启动显示一条来自诗词或哲学的语录和出处。

- 首次启动异步获取语录并写入本地缓存，后续启动直接读取缓存实现瞬时显示，后台静默更新下一条
- 仪表盘极简布局：ASCII logo + 居中两行引用 + 底部 `q` 退出，无多余按钮
- 所有逻辑内聚于 `alpha.lua`，与 alpha 主题配置同文件管理

## 收藏配色面板

按 `<leader>uC` 打开，从 10 款精选主题中挑选配色，支持实时预览。

- 每个主题显式标注浅色/深色属性，切换时强制设置 `vim.o.background`，彻底解决跨主题深浅色污染
- 采用双级防抖（60ms + 0ms）避免快速滚动时的竞态闪烁
- 选中配色持久化至本地状态文件，重启自动恢复；`<Esc>` 退出则恢复为打开面板前的配色
- 白名单配置于 `options.lua` 的 `vim.g.favorite_colorschemes`，增删主题只需修改列表

## 常规配置

基于 LazyVim extras 启用，几乎无需手动维护。

| 类别 | 内容 |
|------|------|
| 语言支持 | typescript, vue, python, go, rust, java, kotlin, php, clangd, json, yaml, toml, sql, docker, cmake, markdown, tex, typst, git |
| AI | claudecode (DeepSeek), copilot, copilot-chat |
| 编辑器增强 | illuminate, dial, aerial, inc-rename, refactoring, luasnip, neogen, yanky |
| UI | treesitter-context, mini-indentscope, smear-cursor, edgy, mini-hipatterns |
| 动画 | mini-animate（滚动 100ms / 窗口缩放 250ms / 光标关闭） |
| GitHub | octo, gh, project |
| 调试/测试 | dap.core, test.core |
| 工具 | rest, startuptime, dot, vscode |
| 编辑器选项 | 4 空格缩进、120 列线、自动折行、autoread、按键超时 200ms |

## 文件结构

```
~/.config/nvim/
├── init.lua
├── lazyvim.json                   extras 声明
└── lua/
    ├── config/ 
    │   ├── lazy.lua               引导 + 默认配色
    │   └── options.lua            编辑器选项 + 配色白名单
    └── plugins/
        ├── alpha.lua              仪表盘整合（一言 / logo / 布局）
        ├── colorschemes.lua       收藏配色面板（扫描 / 防抖 / 持久化）
        └── tweaks.lua             AI 模型 / 动画参数 / 列线
```

## 安装

```bash
git clone https://github.com/xv1rcn/starter ~/.config/nvim
nvim
```
