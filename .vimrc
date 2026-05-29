" === 插件管理 (vim-plug) ===
call plug#begin('~/.vim/plugged')

Plug 'tpope/vim-commentary'          " gc 一键注释
Plug 'airblade/vim-gitgutter'        " 行号左侧显示 git 改动标记
Plug 'itchyny/lightline.vim'         " 轻量状态栏

call plug#end()

" === 基础显示 ===
syntax on                          " 语法高亮
set number                         " 行号
set ruler                          " 右下角显示光标位置
set showmatch                      " 高亮匹配的括号
set cursorline                     " 高亮当前行
set cursorcolumn                   " 高亮当前列

" === 搜索 ===
set hlsearch                       " 高亮所有匹配结果
set incsearch                      " 边输入边搜索
set ignorecase                     " 搜索忽略大小写
set smartcase                      " 有大写字母时自动区分大小写

" === 缩进 ===
set expandtab                      " tab 转空格
set tabstop=4                      " tab 显示为 4 个空格
set shiftwidth=4                   " 缩进宽度 4 个空格
set autoindent                     " 自动缩进

" === 操作体验 ===
set mouse=a                        " 鼠标支持：点击定位、滚轮翻页
set clipboard=unnamedplus          " 与系统剪贴板互通
set backspace=indent,eol,start     " 退格键正常删除
set undofile                       " 持久撤销（关文件后还能撤销）
set undodir=~/.vim/undo            " 撤销文件存放目录

" === 杂项 ===
set encoding=utf-8                 " UTF-8 编码
set noswapfile                     " 不生成 .swp 文件
set updatetime=300                 " 写入 swap 的延迟（默认 4 秒太长）

" === lightline（轻量状态栏） ===
set laststatus=2                    " 总显示状态栏
let g:lightline = {
  \ 'active': {
  \   'left': [['mode'], ['filename']],
  \   'right': [['lineinfo'], ['percent']]
  \ }
  \ }
