" =============================================================================
"        << 判断操作系统是 Windows 还是 Linux 和判断是终端还是 Gvim >>
" =============================================================================

" -----------------------------------------------------------------------------
"  < 判断操作系统是否是 Windows 还是 Linux >
" -----------------------------------------------------------------------------
let g:iswindows = 0
let g:islinux = 0
if(has("win32") || has("win64") || has("win95") || has("win16"))
    let g:iswindows = 1
    "防止linux终端下无法拷贝
    if has('mouse')
        set mouse=a
    endif
    au GUIEnter * simalt ~x
else
    let g:islinux = 1
    if has('mouse')
        set mouse=v
    endif
endif

" -----------------------------------------------------------------------------
"  < 判断是终端还是 Gvim >
" -----------------------------------------------------------------------------
if has("gui_running")
    let g:isGUI = 1
else
    let g:isGUI = 0
endif

" =============================================================================
"                          << 以下为软件默认配置 >>
" =============================================================================

" -----------------------------------------------------------------------------
"  < Windows Gvim 默认配置> 做了一点修改
" -----------------------------------------------------------------------------
if (g:iswindows && g:isGUI)
    source $VIMRUNTIME/vimrc_example.vim
    source $VIMRUNTIME/mswin.vim
    behave mswin
    set diffexpr=MyDiff()

    function MyDiff()
        let opt = '-a --binary '
        if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
        if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
        let arg1 = v:fname_in
        if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
        let arg2 = v:fname_new
        if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
        let arg3 = v:fname_out
        if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
        let eq = ''
        if $VIMRUNTIME =~ ' '
            if &sh =~ '\<cmd'
                let cmd = '""' . $VIMRUNTIME . '\diff"'
                let eq = '"'
            else
                let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
            endif
        else
            let cmd = $VIMRUNTIME . '\diff'
        endif
        silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
    endfunction
endif

" -----------------------------------------------------------------------------
"  < Linux Gvim/Vim 默认配置>
" -----------------------------------------------------------------------------
if g:islinux
    " Uncomment the following to have Vim jump to the last position when
    " reopening a file
    if has("autocmd")
        au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
    endif

    if g:isGUI
        " Source a global configuration file if available
        if filereadable("/etc/vim/gvimrc.local")
            source /etc/vim/gvimrc.local
        endif
    else
        " This line should not be removed as it ensures that various options are
        " properly set to work with the Vim-related packages available in Debian.
        runtime! debian.vim

        " Vim5 and later versions support syntax highlighting. Uncommenting the next
        " line enables syntax highlighting by default.
        if has("syntax")
            syntax on
        endif

        set mouse=v                    " 在任何模式下启用鼠标
        set t_Co=256                   " 在终端启用256色
        set backspace=2                " 设置退格键可用

        " Source a global configuration file if available
        if filereadable("/etc/vim/vimrc.local")
            source /etc/vim/vimrc.local
        endif
    endif
endif

" =============================================================================
"                          << 以下为用户自定义配置 >>
" =============================================================================

" -----------------------------------------------------------------------------
"  < Vundle 插件管理工具配置 >
" -----------------------------------------------------------------------------
" 用于更方便的管理vim插件，具体用法参考 :h vundle 帮助
" Vundle工具安装方法为在终端输入如下命令
" git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
" 如果想在 windows 安装就必需先安装 `git for window`，可查阅网上资料

set nocompatible "关闭兼容模式, 不要vim模仿vi模式
filetype off

if g:islinux
    set rtp+=~/.vim/bundle/vundle/
    call vundle#begin()
else
    set rtp+=%VIM%/vimfiles/bundle/vundle/
    call vundle#begin('$VIM/vimfiles/bundle/')
endif

" 使用Vundle来管理插件，这个必须要有。
Plugin 'VundleVim/Vundle.vim'
Plugin 'gmarik/vundle'

" 以下为要安装或更新的插件，不同仓库都有（具体书写规范请参考帮助）
Plugin 'scrooloose/nerdtree'                "目录树
Plugin 'taglist.vim'                        "安装完需要在项目文件夹下执行 $ctags -R *
Plugin 'altercation/vim-colors-solarized'   "主题
Plugin 'szw/vim-tags'
"Plugin 'brookhong/cscope.vim'
Plugin 'ag.vim'                             "内容搜索
Plugin 'Valloric/YouCompleteMe'             "代码补全,Ctrl+n
Plugin 'kien/ctrlp.vim'                     "文件快速查找,Ctrl+p
Plugin 'vim-airline/vim-airline'            "状态栏
Plugin 'vim-airline/vim-airline-themes'     "状态栏主题
Plugin 'mattn/emmet-vim'                    "https://raw.githubusercontent.com/mattn/emmet-vim/master/TUTORIAL
Plugin 'majutsushi/tagbar'                  "代码分析
Plugin 'SirVer/ultisnips'                   "Snippets引擎,配合honza/vim-snippets使用
Plugin 'honza/vim-snippets'                 "code snippet
Plugin 'vim-syntastic/syntastic'            "语法检查
Plugin 'scrooloose/nerdcommenter'           "代码注释

call vundle#end()
filetype plugin indent on


" -----------------------------------------------------------------------------
"  < 编码配置 >
" -----------------------------------------------------------------------------
" 注：使用utf-8格式后，软件与程序源码、文件路径不能有中文，否则报错
set encoding=utf-8                                    "设置gvim内部编码，默认不更改
set fileencoding=utf-8                                "设置当前文件编码，可以更改，如：gbk（同cp936）
set fileencodings=ucs-bom,utf-8,gbk,cp936,latin-1     "设置支持打开的文件的编码

" 文件格式，默认 ffs=dos,unix
set fileformat=unix                                   "设置新（当前）文件的<EOL>格式，可以更改，如：dos（windows系统常用）
set fileformats=unix,dos,mac                          "给出文件的<EOL>格式类型

if (g:iswindows && g:isGUI)
    "解决菜单乱码
    source $VIMRUNTIME/delmenu.vim
    source $VIMRUNTIME/menu.vim

    "解决consle输出乱码
    language messages zh_CN.utf-8
endif


" -----------------------------------------------------------------------------
"  < 快捷键配置 >
" -----------------------------------------------------------------------------
" leader键为逗号
let mapleader=","

" jk键为escape
inoremap jk <esc>

" leader+s为保存session
nnoremap <leader>s :mksession<CR>

" Ctrl+S 映射为保存
nnoremap <C-S> :w<CR>
inoremap <C-S> <Esc>:w<CR>a

" Ctrl+C 复制，Ctrl+V 粘贴
inoremap <C-C> y
inoremap <C-V> <Esc>pa
vnoremap <C-C> y
vnoremap <C-V> p

" F3 查找当前高亮的单词
inoremap <F3>*<Esc>:noh<CR>:match Todo /\k*\%#\k*/<CR>v
vnoremap <F3>*<Esc>:noh<CR>:match Todo /\k*\%#\k*/<CR>v

" Ctrl + K 插入模式下光标向上移动
imap <c-k> <Up>
" Ctrl + J 插入模式下光标向下移动
imap <c-j> <Down>
" Ctrl + H 插入模式下光标向左移动
imap <c-h> <Left>
" Ctrl + L 插入模式下光标向右移动
imap <c-l> <Right>


" -----------------------------------------------------------------------------
"  < 编写文件时的配置 >
" -----------------------------------------------------------------------------
filetype on                                           "启用文件类型侦测
filetype plugin on                                    "针对不同的文件类型加载对应的插件
filetype plugin indent on                             "启用缩进
set smartindent                                       "启用智能对齐方式
set expandtab                                         "将Tab键转换为空格
set tabstop=4                                         "设置Tab键的宽度，可以更改，如：宽度为2
set shiftwidth=4                                      "换行时自动缩进宽度，可更改（宽度同tabstop）
set smarttab                                          "指定按一次backspace就删除shiftwidth宽度
"set foldenable                                        "启用折叠
"set foldmethod=indent                                 "indent 折叠方式
"set foldmethod=marker                                 "marker 折叠方式
set showmatch                                         "设置匹配模式,类似当输入一个左括号时会匹配相应的那个右括号
set autoread                                          "当文件在外部被修改，自动更新该文件
set ignorecase                                        "搜索模式里忽略大小写
set smartcase                                         "如果搜索模式包含大写字符，不使用 'ignorecase' 选项，只有在输入搜索模式并且打开 'ignorecase' 选项时才会使用
set hlsearch                                          "高亮搜索关键字
set incsearch                                         "开启实时搜索匹配
"set noincsearch                                       "关闭实时搜索匹配

" 关闭搜索高亮快捷键
nnoremap <leader><space> :nohlsearch<CR>

" 常规模式下用空格键来开关光标行所在折叠（注：zR 展开所有折叠，zM 关闭所有折叠）
nnoremap <space> @=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>

" 常规模式下输入 cS 清除行尾空格
nmap cS :%s/\s\+$//g<CR>:noh<CR>

" 常规模式下输入 cM 清除行尾 ^M 符号
nmap cM :%s/\r$//g<CR>:noh<CR>

" 启用每行超过80列的字符提示（字体变蓝并加下划线），不启用就注释掉
au BufWinEnter * let w:m2=matchadd('Underlined', '\%>' . 80 . 'v.\+', -1)

"快速切换Paste模式，可在状态栏显示Paste
nnoremap <F12> :set invpaste paste?<CR>
imap <F12> <C-O>:set invpaste paste?<CR>
set pastetoggle=<F12>


" -----------------------------------------------------------------------------
"  < 界面配置 >
" -----------------------------------------------------------------------------
set nu!                                               "显示行号
set relativenumber                                    "相对行号
set laststatus=2                                      "启用状态栏信息
set cmdheight=2                                       "设置命令行的高度为2，默认为1
set cursorline                                        "突出显示当前行
set guifont=Monaco:h10                                "设置字体:字号（字体名称空格用下划线代替）
set nowrap                                            "设置不自动换行
set shortmess=atI                                     "去掉欢迎界面
set ruler                                             "右下角显示光标位置的状态行
set cursorcolumn                                      "高亮显示光标列
set showcmd                                           "命令行显示输入的命令
set showmode                                          "命令行显示vim当前模式
set nowrapscan                                        "搜索到文件两端时不重新搜索
"set novisualbell                                      "关闭闪屏警报
"set vb t_vb=                                          "关闭提示音
set hidden                                            "允许在有未保存的修改时切换缓冲区
set visualbell t_vb=
au GuiEnter * set t_vb=

" 设置 gVim 窗口初始位置及大小
if g:isGUI
    au GUIEnter * simalt ~x                           "窗口启动时自动最大化
    winpos 100 10                                     "指定窗口出现的位置，坐标原点在屏幕左上角
    set lines=38 columns=120                          "指定窗口大小，lines为高度，columns为宽度
endif

" 设置代码配色方案
set background=dark
if g:isGUI
    colorscheme solarized                             "Gvim配色方案
else
    colorscheme solarized                             "终端配色方案
endif

" 显示/隐藏菜单栏、工具栏、滚动条，可用 Ctrl + F11 切换
if g:isGUI
		set go="无菜单、工具栏"
    set guioptions-=m
    set guioptions-=T
    set guioptions-=r
    set guioptions-=L
    nmap <silent> <c-F11> :if &guioptions =~# 'm' <Bar>
        \set guioptions-=m <Bar>
        \set guioptions-=T <Bar>
        \set guioptions-=r <Bar>
        \set guioptions-=L <Bar>
    \else <Bar>
        \set guioptions+=m <Bar>
        \set guioptions+=T <Bar>
        \set guioptions+=r <Bar>
        \set guioptions+=L <Bar>
    \endif<CR>
endif


" -----------------------------------------------------------------------------
"  < Taglists 插件配置 >
" -----------------------------------------------------------------------------
if g:iswindows                          "设定windows系统中ctags程序的位置
	let Tlist_Ctags_Cmd='ctags'
elseif g:islinux                        "设定linux系统中ctags程序的位置
	let Tlist_Ctags_Cmd = '/usr/bin/ctags'
endif
let Tlist_Show_One_File=1               "不同时显示多个文件的tag，只显示当前文件的
let Tlist_WinWidt =28                   "设置taglist的宽度
let Tlist_Exit_OnlyWindow=1             "如果taglist窗口是最后一个窗口，则退出vim
let Tlist_Use_Right_Window=1            "在右侧窗口中显示taglist窗口
"let Tlist_Use_Left_Windo =1             "在左侧窗口中显示taglist窗口
"let Tlist_Sort_Type ='name'             "Tag的排序规则，以名字排序。默认是以在文件中出现的顺序排序
let Tlist_File_Fold_Auto_Close = 1      "当同时显示多个文件中的tag时，设置为1，可使taglist只显示当前文件tag，其它文件的tag都被折叠起来
let Tlist_GainFocus_On_ToggleOpen = 1   "Taglist窗口打开时，立刻切换为有焦点状态
"map t :TlistToggle                      "热键设置

"set tags=/home/xxx/myproject/tags       "重要！不同目录下都起作用，绝对路径
set tags=tags;                          "重要！不同目录下都起作用
set autochdir                           "重要！不同目录下都起作用


" -----------------------------------------------------------------------------
"  < NERDTree 插件配置 >
" -----------------------------------------------------------------------------
" 有目录村结构的文件浏览插件
" 常规模式下输入 F2 调用插件
nmap <F2> :NERDTreeToggle<CR>
" Auto enable NERDTreeToggle
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'

" -----------------------------------------------------------------------------
"  < CtrlP 插件配置 >
"  link: https://github.com/kien/ctrlp.vim
" -----------------------------------------------------------------------------
" 快速查找文件插件
let g:ctrlp_map='<c-p>'
let g:ctrlp_cmd='CtrlP'

"忽略查找的文件类型
set wildignore+=*/tmp/*,*.so,*.swp,*.zip     " MacOSX/Linux
set wildignore+=*\\tmp\\*,*.swp,*.zip,*.exe  " Windows

let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn|pyc)$'
unlet g:ctrlp_custom_ignore
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
  \ 'file': '\v\.(exe|so|dll)$',
  \ 'link': 'some_bad_symbolic_links',
  \ }

"用普通文件监听命令
let g:ctrlp_user_command = 'find %s -type f'        " MacOSX/Linux
let g:ctrlp_user_command = 'dir %s /-n /b /s /a-d'  " Windows


" -----------------------------------------------------------------------------
"  < vim-airline 插件配置 >
"  https://github.com/vim-airline/vim-airline
" -----------------------------------------------------------------------------
let g:airline#extensions#tabline#enabled = 1        "开启顶部tab栏
let g:airline#extensions#tabline#buffer_nr_show = 1 "tabline中buffer显示编号

" 映射切换buffer的键位
nnoremap bn :bn<CR>
nnoremap bp :bp<CR>
" 映射<leader>num到num buffer
map <leader>1 :b 1<CR>
map <leader>2 :b 2<CR>
map <leader>3 :b 3<CR>
map <leader>4 :b 4<CR>
map <leader>5 :b 5<CR>
map <leader>6 :b 6<CR>
map <leader>7 :b 7<CR>
map <leader>8 :b 8<CR>
map <leader>9 :b 9<CR>
" 关闭当前buffer
nnoremap <leader>d :bd#<CR>


" -----------------------------------------------------------------------------
"  < tagbar 插件配置 >
"  https://github.com/majutsushi/tagbar/blob/master/doc/tagbar.txt
" -----------------------------------------------------------------------------
if g:iswindows                          "设定windows系统中ctags程序的位置
    let tagbar_ctags_bin = 'ctags'
elseif g:islinux                        "设定linux系统中ctags程序的位置
    let tagbar_ctags_bin = '/usr/bin/ctags'
endif

nmap tb :TagbarToggle<cr>
nmap <F8> :TagbarToggle<cr>

let tagbar_width = 25
let g:tagbar_zoomwidth = 0
let g:tagbar_autoclose = 1
let g:tagbar_autofocus = 1
let g:tagbar_sort = 0
let g:tagbar_indent = 1
let g:tagbar_show_linenumbers = 2
let g:tagbar_autoshowtag = 1

let g:tagbar_iconchars = ['▶', '▼']  "(default on Linux and Mac OS X)
let g:tagbar_iconchars = ['▸', '▾']
let g:tagbar_iconchars = ['▷', '◢']
let g:tagbar_iconchars = ['+', '-']    "(default on Windows)


" -----------------------------------------------------------------------------
"  < vim-snippets 插件配置 >
"  https://github.com/majutsushi/tagbar/blob/master/doc/tagbar.txt
" -----------------------------------------------------------------------------
"if you use https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<leader><tab>"          "展开代码片段的键
let g:UltiSnipsJumpForwardTrigger="<leader><tab>"
let g:UltiSnipsJumpBackwardTrigger="<leader><s-tab>"


" -----------------------------------------------------------------------------
"  < vim-syntastic 插件配置 >
"  https://github.com/vim-syntastic/syntastic
" -----------------------------------------------------------------------------
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0


" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  return (pumvisible() ? "\<C-y>" : "" ) . "\<CR>"
  " For no inserting <CR> key.
  "return pumvisible() ? "\<C-y>" : "\<CR>"
endfunction

"自动缩进
if has("autocmd")
    filetype plugin indent on "根据文件进行缩进
    augroup vimrcEx
        au!
        autocmd FileType text setlocal textwidth=78
        autocmd BufReadPost *
                    \ if line("'\"") > 1 && line("'\"") <= line("$") |
                    \ exe "normal! g`\"" |
                    \ endif
    augroup END
else
    "智能缩进，相应的有cindent，官方说autoindent可以支持各种文件的缩进，但是效果会比只支持C/C++的cindent效果会差一点
    set autoindent " always set autoindenting on
endif " has("autocmd")

"Multi-Language Start
if has("multi_byte")
    " UTF-8 编码
    set encoding=utf-8
    set fileencodings=utf-8,ucs-bom,cp936,gb18030,big5,euc-jp,euc-kr,latin1
    set termencoding=utf-8
    set formatoptions+=mM
    set fencs=utf-8,gbk
    if v:lang =~? '^/(zh/)/|/(ja/)/|/(ko/)'
        set ambiwidth=double
    endif
    if (has("win32") || has("win95") || has("win64") || has("win16"))
        source $VIMRUNTIME/delmenu.vim
        source $VIMRUNTIME/menu.vim
        language messages zh_CN.utf-8
        let g:vimrc_iswindows=1
    endif
else
    let g:vimrc_iswindows=0
    echoerr "Sorry, this version of (g)vim was not compiled with +multi_byte"
endif
autocmd BufEnter * lcd %:p:h
"Multi-Language End
