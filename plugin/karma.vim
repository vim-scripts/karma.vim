" Vim plugin -- for a given script karma, print the range of possible user
"		votes
" File:         karma.vim
" Created:      2007 Aug 29
" Last Change:  2007 Sep 04
" Author:	Andy Wokula <anwoku@yahoo.de>
" Vim Version:	5.7 or higher
" Version:	3

" Installation:
"   Put the file into your ~/.vim/plugin/ folder (:h 'rtp').
"   Vim 5.7: create this folder if it doesn't exist and add the line
"	source ~/.vim/plugin/karma.vim
"   to your .vimrc
"
" Usage:
"   :Karma {score} {votes}
"
" More Info:
"	http://vim.sourceforge.net/karma.php
"   script karma    Rating {score}/{votes}, Downloaded by ...
"
" Note: the math is derived from an example, not proven; the ":Karma -1 1"
"   bug is fixed; currently I'm not aware of wrong calculations

" Vim 5.7 limits hit:
"   - no script local functions
"   - no '\zs', '\ze' patterns
"   - no numbered function arguments (a:1, a:2, ...)
"   - no :finish command

" Credits:
"   vimscript #936
"   Karma Decompiler : Makes statistics based on Karma

if exists("loaded_karma") && v:version>=600
    finish
endif
let loaded_karma = 1

function! Karma_Votes(cargs)
    let argpat = '^\(-\=\d\+\)  *\(\d\+\) *$'
    if a:cargs !~ argpat
	echo "Usage is  :Karma {score} {votes}"
	return
    endif
    let score = substitute(a:cargs, argpat, '\1', '')+0	" 2155
    let votes = substitute(a:cargs, argpat, '\2', '')+0	" 659

    echo "Karma:" score."/".votes

    let pm = score / 4    " 538, close to score, still missing votes (p)
    let mv = votes - pm   " 121, number of missing votes
    let sth = pm * 4 + mv  " 2273, score too high, votes ok (p, q)
    let sd = (sth - score)/3 " 39, score diff
    let p = pm - sd	    " 499, lower bound for Life Changing
    let q = mv + sd	    " 160, upper bound for Helpful
    let r = 0		    " 0, min for Unfulfilling
    let s = p*4 + q - r	    " 2156 = 499*4 + 160 - 0
    if (score-s)%2
	" adjusting with q and r requires an even difference
	let p = p + 1	    " 500
	let q = q - 1	    " 159
    endif
    let sd = (p*4 + q - r - score)/2    " adjust with q and r
    let q = q - sd	    " 157
    let r = r + sd	    " 2

    " :Karma 15 19  vs.  :Karma 15 21
    if p < 0
	let sd = -p / 2 + -p % 2
	let p = p + 2*sd
	let q = q - 5*sd
	let r = r + 3*sd
    endif

    echo "   1. Life Changing:" p "  Helpful:" q "  Unfulfilling:" r
    " echo "      Check:  Score =" 4*p+q-r "  Votes =" p+q+r
    if p < 0 || q < 0 || r < 0
	echohl WarningMsg
	echo "This score is not possible, typo?"
	echohl none
	return
    endif

    let p = p + 2
    let q = q - 5
    let r = r + 3
    if q < 0
	return
    endif
    echo "   2. Life Changing:" p "  Helpful:" q "  Unfulfilling:" r
    " echo "      Check:  Score =" 4*p+q-r "  Votes =" p+q+r

    let bm = q/5
    let p = p + bm*2
    let q = q - bm*5
    let r = r + bm*3
    if bm==0
	return
    endif
    if bm>1
	echo "      ..."
    endif
    let nth = substitute("    ".(bm+2), ' *\(....\)', '\1', "")
    echo nth.". Life Changing:" p "  Helpful:" q "  Unfulfilling:" r
    " echo "      Check:  Score =" 4*p+q-r "  Votes =" p+q+r
endfunction

command! -nargs=* Karma call Karma_Votes(<q-args>)

" vim:set ts=8 sts=4 noet:
