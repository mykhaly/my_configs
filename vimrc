" {{{ evim compat

if v:progname =~? "evim"
  finish
endif

" }}}

" {{{ Load global vimrc

if filereadable("/etc/vim/vimrc")
  source /etc/vim/vimrc
elseif filereadable("/etc/vimrc")
  source /etc/vimrc
endif

" }}}

colorscheme slate
" koehler, pablo, ron, slate, zellner

" {{{ Highlight

" colorcolumn
set cc=80,120
highlight ColorColumn ctermbg = 238 guibg = DarkGrey

" Spell checker
hi SpellBad ctermfg = 255 ctermbg = 088

" http://vim.wikia.com/wiki/Highlight_unwanted_spaces
hi ExtraWhitespace ctermbg = red guibg = red
autocmd BufWinEnter * match ExtraWhitespace /\(\t\|\s\)\+$/ " tabs, trailing whitespace

" }}}

" GUI font
set gfn=Monospace\ 9,5

" Allow backspacing over everything in insert mode
set backspace=indent,eol,start

set gdefault		" default /g for %s
set ic			" ignorecase
set scs			" smartcase
set modeline		" in-file vim setup (e.g., to specify syntax)
set nobackup		" don't keep a backup file
set showcmd		" display incomplete commands
set incsearch		" do incremental searching
set noai		" no autoindent
set textwidth=0		" do not break lines automatically
set shiftwidth=0	" for >> and <<; when 0, 'tabstop' will be used
let g:leave_my_textwidth_alone = 1

" Reconfigure autoindent depending on filetype
"filetype plugin indent on

" {{{ Mouse

if has("mouse")
  set mouse=nrc
endif

" }}}

" {{{ Filetype-specific

" au: AutoCommand
" ai: AutoIndent
" cc: ColorColumn
" ai: AutoIndent
" et: ExpandTab: spaces instead of tabs)
" ts: TabStop: Number of spaces in <Tab>
au FileType lua		set ai et ts=2
au FileType org         set ai et ts=2
"au FileType python	compiler pylint
au FileType python	set ai et ts=4 commentstring=#%s
au FileType robot	set ai et ts=2 commentstring=#%s
au FileType yaml	set ai et ts=4
" * In Git commits:
au FileType gitcommit set tw=72 cc=50,72 noai
au FileType gitcommit setlocal spell spelllang=en,uk

" }}}

" {{{ Bindings and aliases

" {{{ Arrows
noremap <Up> :echo "Use k, lazy shit!"<CR>
noremap <Down> :echo "Use j, lazy shit!"<CR>
noremap <Left> :echo "Use h, lazy shit!"<CR>
noremap <Right> :echo "Use l, lazy shit!"<CR>
" }}}

" {{{ Clear search highlight when pressing escape
nnoremap <C-h> :noh<CR>
inoremap <C-h> <C-o>:noh<CR>
" }}}

" {{{ Tab navigation
"nnoremap <C-S-Tab> :tabprevious<CR>
"nnoremap <C-Tab>   :tabnext<CR>
"nnoremap <C-t>     :tabnew<CR>
"inoremap <C-S-Tab> <C-o>:tabprevious<CR>
"inoremap <C-Tab>   <C-o>:tabnext<CR>
"inoremap <C-t>     <C-o>:tabnew<CR>
" }}}

" {{{ <C-PageUp>/<C-PageDown> for Vim + urxvt + tmux
"nnoremap ^[5 :tabp<CR>
"inoremap ^[5 <C-o>:tabp<CR>
"nnoremap ^[6 :tabn<CR>
"inoremap ^[6 <C-o>:tabn<CR>
" }}}

" {{{ Smart Home/End
noremap <expr> <Home> (col('.') == matchend(getline('.'), '^\s*')+1 ? '0' : '^')
noremap <expr> <End> (col('.') == match(getline('.'), '\s*$') ? '$' : 'g_')
imap <Home> <C-o><Home>
imap <End> <C-o><End>
" Compatibility with Vim + urxvt + tmux
if v:progname == "vim"
  noremap [1~ <Home>
  noremap [4~ <End>
  imap [1~ <C-o><Home>
  imap [4~ <C-o><End>
endif
" }}}

" {{{ Comment out the line with <C-/>
function! CommentOut() range
  let comstr = &commentstring
  " TODO: Only simple prefixes are supported at the moment.
  " I can't (yet) handle other types of syntax, such as /* this */.
  if comstr == "/*%s*/" " By the way, this is the default value for unknown
    let comstr = "//%s" " filetypes. Let's use more common double slash instead.
  endif

  for lineno in range(a:firstline, a:lastline)
    let line = getline(lineno)
    " First check if we're not in a comment already (Vim Tip #218)
    if synIDattr(synIDtrans(synID(line("."), col("."), 0)), "name") != "Comment"
      " If not processing a comment, add a comment prefix
      " TODO: Avoid writing whitespace after a prefix if there already was some
      let commLine = printf(comstr, line)
    else
      " Else remove a comment prefix
      " TODO: Detect and correctly process strings that don't begin with a
      " comment prefix.
      let regex = '^'.printf(comstr, '')
      let commLine = substitute(line, regex, '', '')
    endif
    call setline(lineno, commLine)
  endfor
endfunction

inoremap  <C-o>:call CommentOut()<CR>
noremap  :call CommentOut()<CR>
" }}}

" {{{ DiffOrig
" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
          \ | wincmd p | diffthis
endif
" }}}

" Write file with sudo
cnoremap w!! w !sudo tee > /dev/null %

" }}}

" {{{ Plugins

if $USER != "root" " Don't use if root

  runtime plugins.vim
  "runtime bundle/vim-pathogen/autoload/pathogen.vim
  "execute pathogen#infect()

  " {{{ Powerline / Airline
    " python from powerline.vim import setup as powerline_setup
    " python powerline_setup()
    " python del powerline_setup
    set laststatus=2	" Always display the statusline in all windows
    set showtabline=2	" Always display the tabline, even if there is only one tab
    set noshowmode	" Hide the default mode text (e.g. -- INSERT -- below the statusline)
    set timeoutlen=50	" Refresh the statusline more quickly
    let g:airline_powerline_fonts = 1
    let g:airline_theme = 'wombatish' " badwold wombat bubblegum murmur powerlineish papercolor
    let g:airline#extensions#tabline#enabled = 1
    let g:airline#extensions#tabline#show_tab_nr = 0
    "let g:airline#extensions#tabline#tab_nr_type = 2
  " }}} Powerline / Airline

  " {{{ GitGutter
    let g:gitgutter_enabled = 1
  " }}} GitGutter

endif " no root

" }}} Plugins

" {{{ Theme patching

"let g:airline_theme_patch_func = 'AirlineThemePatch'
"function! AirlineThemePatch(palette)
"  if g:airline_theme == 'wombatish'
"   let g:airline#themes#luna#palette.tabline = {
"      \ 'airline_tabsel':  Selected tab
"      \ 'airline_tab': Any tab
"      \ 'airline_tabmod': Modified tab
"      \ 'airline_tabtype': Tab type
"      \ 'airline_tabfill': Tabline background
"      \ }
"  endif
"endfunction

" }}}

" {{{ Netrw
" hide netrw top message
let g:netrw_banner = 0
" tree listing by default
let g:netrw_liststyle = 3
" hide vim swap files
let g:netrw_list_hide = '.*\.swp$'
" open files in right window by default
let g:netrw_chgwin    = 2
let g:netrw_winsize   = 80
let g:netrw_altv      = 1
" }}}

" vim: set fenc=utf-8 tw=80 sw=2 sts=2 et foldmethod=marker :
