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
set cursorlineopt=number           " 只高亮行号列，不污染整行背景
" set cursorcolumn                 " 垂直标尺（大多数人用不上）
set background=dark                " 暗色背景
colorscheme retrobox               " 内置配色, (sorbet/retrobox 相对较好）
" 内置配色候选(共27个): blue, darkblue, default, delek, desert, elflord, evening, habamax, industry, koehler, lists, lunaperche, morning, murphy, pablo, peachpuff, quiet, retrobox, ron, shine, slate, sorbet, tools, torte, wildcharm, zaibatsu, zellner

" === 光标形状 ===
" NORMAL/REPLACE: 块  |  INSERT: 竖线  |  VISUAL: 块
let &t_SI = "\e[6 q"                 " 进入 Insert 模式 → |
let &t_SR = "\e[4 q"                 " 进入 Replace 模式 → _
let &t_EI = "\e[2 q"                 " 回到 Normal 模式 → 块

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

" === 补全 ===
" Insert 模式: Ctrl-F 触发文件名补全 (手动备用)
inoremap <C-f> <C-x><C-f>

" Insert 模式: 检测到 / (输入或删除到达) 自动弹文件补全
" 补全到目录后自动链式弹下一层 (因末尾仍是 /,TextChangedI 再次触发)
" 不区分注释/正则等,纯按 / 判定
" completeopt=noselect,noinsert,menuone: 弹窗不预选,需手动 Down+Enter 确认
augroup AutoPathComplete
    autocmd!
    autocmd TextChangedI * call s:auto_path_on_slash()
augroup END
set completeopt+=noselect,noinsert,menuone

function! s:auto_path_on_slash() abort
    if &buftype !=# '' | return | endif                " 跳过特殊 buffer
    let l:col = col('.')
    if l:col < 2 | return | endif
    if getline('.')[l:col-2] !=# '/' | return | endif " 光标前是 / 才触发
    call feedkeys("\<C-x>\<C-f>", 'nt')
endfunction

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
