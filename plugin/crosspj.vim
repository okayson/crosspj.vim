"==========================================================
" File: crosspj.vim (for plugin)
" Author: okayson <okayson1124@gmail.com>
"==========================================================
"----------------------------------------------------------
" Commands
"----------------------------------------------------------
command! -nargs=1 -complete=file
	\    CrosspjAddIgnoreFile		:call crosspj#addIgnoreFile(<f-args>)
command! -nargs=1 -complete=dir 
	\    CrosspjAddIgnoreDirectory	:call crosspj#addIgnoreDirectory(<f-args>)
command! -nargs=+
	\    CrosspjUserPass			:call crosspj#setUserPass(<f-args>)
command! CrosspjEnable				:call crosspj#enable()
command! CrosspjDisable				:call crosspj#disable()
command! CrosspjTransfer			:call crosspj#transfer()
command! CrosspjDisplay				:call crosspj#display()

"----------------------------------------------------------
" Key Mappings
"----------------------------------------------------------
nnoremap <Plug>(crosspj_enable)		:<C-u>CrosspjEnable<CR>
nnoremap <Plug>(crosspj_disable)	:<C-u>CrosspjDisable<CR>
nnoremap <Plug>(crosspj_transfer)	:<C-u>CrosspjTransfer<CR>
nnoremap <Plug>(crosspj_display)	:<C-u>CrosspjDisplay<CR>

"----------------------------------------------------------
" vim: foldmethod=marker
