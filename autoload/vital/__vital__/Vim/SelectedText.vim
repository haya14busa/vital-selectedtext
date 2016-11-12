"=============================================================================
" FILE: autoload/vital/__vital__/Vim/SelectedText.vim
" AUTHOR: haya14busa
" License: MIT license
"=============================================================================

" text() returns selected text from begin to end.
"
" @param {'char'|'line'|'block'} wise
" @return selected text
function! s:text(wise, begin, end) abort
  let begin = a:begin
  let end = a:end
  if len(begin) > 3
    let begin = begin[1:2]
  endif
  if len(end) > 3
    let end = end[1:2]
  endif
  if s:_is_exclusive() && begin[1] !=# end[1]
    " Decrement column number for :set selection=exclusive
    let end[1] -= 1
  endif
  if a:wise !=# 'line' && begin ==# end
    let lines = [s:_get_pos_char(begin)]
  elseif a:wise ==# 'block'
    let [min_c, max_c] = s:_sort_num([begin[1], end[1]])
    let lines = map(range(begin[0], end[0]), '
    \   getline(v:val)[min_c - 1 : max_c - 1]
    \ ')
  elseif a:wise ==# 'line'
    let lines = getline(begin[0], end[0])
  else
    if begin[0] ==# end[0]
      let lines = [getline(begin[0])[begin[1]-1 : end[1]-1]]
    else
      let lines = [getline(begin[0])[begin[1]-1 :]]
      \         + (end[0] - begin[0] < 2 ? [] : getline(begin[0]+1, end[0]-1))
      \         + [getline(end[0])[: end[1]-1]]
    endif
  endif
  return join(lines, "\n") . (a:wise ==# 'line' ? "\n" : '')
endfunction

" @return Boolean
function! s:_is_exclusive() abort
    return &selection is# 'exclusive'
endfunction

"" Return character at given position with multibyte handling.
"
" @arg [Number, Number] as coordinate
" @return String
function! s:_get_pos_char(pos) abort
    let [line, col] = a:pos
    return matchstr(getline(line), '.', col - 1)
endfunction

" 7.4.341
" http://ftp.vim.org/vim/patches/7.4/7.4.341
if v:version > 704 || v:version == 704 && has('patch341')
  function! s:_sort_num(xs) abort
    return sort(a:xs, 'n')
  endfunction
else
  function! s:_sort_num_func(x, y) abort
    return a:x - a:y
  endfunction
  function! s:_sort_num(xs) abort
    return sort(a:xs, 's:_sort_num_func')
  endfunction
endif

" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
