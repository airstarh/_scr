#Requires AutoHotkey v2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; region EXAMPLES

;; How to include another AHK script:
; #Include ./inc.ahk

;; !	Alt
;; ^	Control
;; +	Shift
;; #	Win

;; hotstrings - expand 'btw' to 'By the way' as you type
::btw::By the way

;; hotkeys - press winkey-z to go to Google
; #z:: Run "http://google.com"

;; endregion EXAMPLES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; region Zoom

F1:: Send "#{NumpadAdd}"
!F1:: Send "#{NumpadSub}"
^F1:: Send "#{Esc}"
#F1::
{
	Send "#{NumpadSub 5}"
}

ScrollLock::
{
	Send "^!{Right}"
	return
}

!ScrollLock::
{
	Send "^!{Left}"
	return
}
;; endregion Zoom
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
