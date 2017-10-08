" File Name:   utime.vim
"
" Author: 	   tangjunxing <mrytsr@gmail.com>
"			   			
" Last Modified: Sun Oct  8 14:46:30 CST 2017
"
" Description:  
" sets the last modification time of the current file.
" time related version
" automatic change template time
"              the modification time is truncated to the last hour.  and the
"              next time the time stamp is changed, it is checked against the
"              time already stamped. this ensures that the time-stamp is
"              changed only once every hour, ensuring that the undo buffer is
"              not screwed around with every time we save.
"              To force the time stamp to be not updated, use the command:
"              		:NOMOD
"              To change it back, use
"              		:MOD
"
" Usage:  a> Change the variable 's:timeStampLeader' to the string
" 						 which you use in your code (by default which is 'Last
" 						 Modified')
" 					   b> Change the variable 'timeStampFormat'. Put an example
" 					     of the time format you want.
" 					   c> Change the variable 'timeStampString'. Change it to
" 					     get the proper time stamp. Read the comments in the
" 					     code to change the variable.


let s:timeStampLeader = 'Last Modified'
if exists('g:timeStampLeader')
	let s:timeStampLeader = g:timeStampLeader
endif

let s:timeStampFormat = "19 Dec 2005"
if exists('g:timeStampFormat')
	let s:timeStampFormat = g:timeStampFormat
endif

let s:timeStampString = "%d %b %Y"
if exists('g:timeStampString')
	let s:timeStampString = g:timeStampString
endif

function! UpdateWithLastMod()
	if exists('b:nomod') && b:nomod
		return
	end
	let pos = line('.').' | normal! '.virtcol('.').'|'
	0
	let searchPos = search(s:timeStampLeader)
	if searchPos <= 20 && searchPos > 0 && &modifiable

        let totalLine = getline('.')
        let lastdate  = matchstr(totalLine, s:timeStampLeader.'.*=\zs.*')
        let timePos   = match(totalLine, lastdate)
        let crFirst   = strpart(totalLine, 0, timePos)

		" The format of the time stamp 
		" please change the two variables according to the format you want
		"
		" syntax - format  - example
		" %a	 - Day	   - Sat
		" %Y     - YYYY    - 2005
		" %b	 - Mon	   - Sep (3 digit month)
		" %m	 - mm	   - 09 (2 digit month)
		" %d	 - dd	   - 10
		" %H	 - HH	   - 15 (hour upto 24)
		" %I	 - HH	   - 12 (hour upto 12)
		" %M	 - MM	   - 50 (minute)
		" %X	 - HH:MM:SS-12:29:34)
		" %p	 - AM/PM
		"
		let timeStampFormat = s:timeStampFormat
		let timeStampString = s:timeStampString

		let timeStampFormatLength = strlen(timeStampFormat)

		let newdate  = strftime(timeStampString)
		let prefix   = ""
		let spaceLength = 0

		" Determines the space or tab before the time stamp
		while 1
			if match(lastdate, " ") == 0
				let lastdate= strpart(lastdate, 1)
				let prefix = prefix.' '
			elseif match(lastdate, '	') == 0
				let lastdate = strpart(lastdate, 1)
				let prefix = prefix.'	'
			else
				break
			end
		endwhile

		let spaceIndex = 0

		" Checks whether the time format is same or not
		while spaceIndex <= timeStampFormatLength
			let spaceIndex1 = match(lastdate, " ", spaceIndex)
			let spaceIndex2 = match(timeStampFormat, " ", spaceIndex)
			if spaceIndex1 == -1
				let spaceIndex1 = strlen(lastdate)
			end
			if spaceIndex2 == -1
				let spaceIndex2 = strlen(timeStampFormat)
			end

			if spaceIndex1 != spaceIndex2
				echohl WarningMsg | echo "The time format is different" lastdate spaceIndex1 timeStampFormat spaceIndex2 | echoh None
				exe pos
				return
			else
				let spaceIndex = spaceIndex1 + 1
			end
		endwhile

		let newdate = newdate.strpart(lastdate, spaceIndex - 1)
		if lastdate == newdate
			exe pos
			return
		end

		"let newdate = prefix.newdate
		exe 's/'.lastdate.'/'.newdate.'/e'
		call s:RemoveLastHistoryItem()
	else
		echo 'no change'
		exe pos
		return
	end

	exe pos
endfunction

augroup LastChange
	au!
	au BufWritePre * :call UpdateWithLastMod()
augroup END

" Remove history:
function! <SID>RemoveLastHistoryItem()
  call histdel("/", -1)
  let @/ = histget("/", -1)
endfunction


" Modify the commands: 
com! -nargs=0 NOMOD :let b:nomod = 1
com! -nargs=0 MOD   :let b:nomod = 0

" vim:ts=4:sw=4:noet fdm=marker
