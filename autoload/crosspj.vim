"==========================================================
" File: crosspj.vim (for autoload)
" Author: okayson <okayson1124@gmail.com>
"==========================================================
"----------------------------------------------------------
"if exists("g:loaded_crosspj")
"	call s:DebugOutput("cross project have already loaded.")
"	finish
"endif
"let g:loaded_crosspj = 1
"----------------------------------------------------------
let s:save_cpo = &cpo
set cpo&vim
"----------------------------------------------------------
" Option Variables
"----------------------------------------------------------

"----------------------------------------------------------
" Interface Functions
"----------------------------------------------------------
function! crosspj#initialize(remoteHost, remoteRoot, localRoot) "{{{
	let s:porter = s:NewTransporter(a:remoteHost, s:FormatAsDirectory(a:remoteRoot), s:FormatAsDirectory(a:localRoot))
	let s:ignoreFiles = s:NewIgnoreListForFile()
	let s:ignoreDirs = s:NewIgnoreListForDirectory()
	call s:RegisterAutoCommands()
endfunction "}}}
function! crosspj#finalize() "{{{
	call s:UnregisterAutoCommands()
	unlet! s:porter
	unlet! s:ignoreFiles
	unlet! s:ignoreDirs
endfunction "}}}
function! crosspj#addIgnoreFile(file) "{{{
	call s:ignoreFiles.add(a:file)
endfunction "}}}
function! crosspj#addIgnoreDirectory(directory) "{{{
	call s:ignoreDirs.add(s:FormatAsDirectory(a:directory))
endfunction "}}}
function! crosspj#setUserPass(user, password) "{{{
	call s:porter.setUserPass(a:user, a:password)
endfunction "}}}
function! crosspj#enable() "{{{
	call s:porter.enable()
endfunction "}}}
function! crosspj#disable() "{{{
	call s:porter.disable()
endfunction "}}}
function! crosspj#transfer() "{{{
	call s:porter.transfer()
endfunction "}}}
function! crosspj#display() "{{{
	echo "[CrossPJ Settings]"
	call s:porter.display()
	call s:ignoreFiles.display()
	call s:ignoreDirs.display()
endfunction "}}}

"----------------------------------------------------------
" Auto Commands
"----------------------------------------------------------
function! s:RegisterAutoCommands() "{{{
	augroup Crosspj
		autocmd!
		autocmd BufWritePost * call crosspj#transfer()
	augroup END
endfunction "}}}
function! s:UnregisterAutoCommands() "{{{
	augroup Crosspj
		autocmd!
	augroup END
endfunction "}}}

"----------------------------------------------------------
" Local Objects
"----------------------------------------------------------
function! s:FormatAsDirectory(directory) "{{{
	let formattedDir = a:directory
	let dirLength = len(a:directory)

	if (dirLength != 0) && ("/" != formattedDir[dirLength - 1])
		let formattedDir = formattedDir . "/"
	endif
	return formattedDir
endfunction "}}}

"--- Transporter Object ---
let s:Transporter = {} "{{{
call extend(s:Transporter, {'isEnabled': 1})
call extend(s:Transporter, {'remoteHost': ""})
call extend(s:Transporter, {'remoteRoot': ""})
call extend(s:Transporter, {'localRoot': ""})
"}}}
function! s:NewTransporter(remoteHost, remoteRoot, localRoot) "{{{
	let self = deepcopy(s:Transporter)
	let self.remoteHost	= a:remoteHost
	let self.remoteRoot	= a:remoteRoot
	let self.localRoot	= a:localRoot
	return self
endfunction "}}}
function! s:Transporter.setUserPass(user, password) dict "{{{
	call NetUserPass(a:user, a:password)
endfunction "}}}
function! s:Transporter.enable() dict "{{{
	let self.isEnabled = 1
endfunction "}}}
function! s:Transporter.disable() dict "{{{
	let self.isEnabled = 0
endfunction "}}}
function! s:Transporter.transfer() dict "{{{
	if !self.isEnabled
		return
	endif

	let filePath = expand("%:p")

	let matchIndex = matchend(filePath, self.localRoot)
	if matchIndex == -1
		return
	endif

	let filePath = filePath[matchIndex : -1]

	if s:ignoreFiles.contains(filePath) || s:ignoreDirs.contains(filePath)
		return
	endif

	let writeCommand = "ftp://" . self.remoteHost."/".self.remoteRoot.filePath
	let g:netrw_quiet = 1
	execute "Nwrite " . writeCommand

endfunction "}}}
function! s:Transporter.display() dict "{{{
	echo "RemoteHost ........... " . self.remoteHost
	echo "RemoteRoot ........... " . self.remoteRoot
	echo "LocalRoot ............ " . self.localRoot
	echo "Transfer ............. " . (self.isEnabled ? "Enabled" : "Disabled")
endfunction "}}}

"--- IgnoreList Object ---
let s:IgnoreList= {'list': []} "{{{
"}}}
function! s:IgnoreList.add(item) dict "{{{
	call add(self.list, a:item)
endfunction "}}}

"--- IgnoreListForFile Object ---
function! s:NewIgnoreListForFile() "{{{
	let self = deepcopy(s:IgnoreList)
	let self.contains = function("s:containsFile")
	let self.display = function("s:displayFiles")
	return self
endfunction "}}}
function! s:containsFile(file) dict "{{{
	for item in self.list
		if item ==# a:file
			return 1
		endif
	endfor
	return 0
endfunction "}}}
function! s:displayFiles() dict "{{{
	echo "Ignore Files ......... " . string(self.list)
endfunction "}}}

"--- IgnoreListForDirectory Object ---
function! s:NewIgnoreListForDirectory() "{{{
	let self = deepcopy(s:IgnoreList)
	let self.contains = function("s:containsDirectory")
	let self.display = function("s:displayDirectories")
	return self
endfunction "}}}
function! s:containsDirectory(file) dict "{{{
	for item in self.list
		if (len(item) < len(a:file)) && (item ==# a:file[0 : len(item)-1])
				return 1
		endif
	endfor
	return 0
endfunction "}}}
function! s:displayDirectories() dict "{{{
	echo "Ignore Directories ... " . string(self.list)
endfunction "}}}
"----------------------------------------------------------
let &cpo = s:save_cpo
unlet s:save_cpo
"------------------------------------------------
" vim: foldmethod=marker
