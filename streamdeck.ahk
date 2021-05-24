; AHK Compiler Directives
;@Ahk2Exe-SetMainIcon icon.ico
;@Ahk2Exe-SetName Sydstarwave's Streamdeck
;@Ahk2Exe-SetDescription Sydstarwave's Streamdeck
;@Ahk2Exe-SetProductName Sydstarwave's Streamdeck
;@Ahk2Exe-UpdateManifest 0, Sydstarwave's Streamdeck, 1.1.0.0, 0
;@Ahk2Exe-SetLanguage 0x0409
;@Ahk2Exe-SetFileVersion 1.1.0.0
;@Ahk2Exe-SetProductVersion 1.1.0.0
;@Ahk2Exe-SetVersion 1.1.0.0
;@Ahk2Exe-SetInternalName streamdeck.exe
;@Ahk2Exe-SetOrigFilename streamdeck.exe
;@Ahk2Exe-SetCompanyName Sydstarwave
;@Ahk2Exe-SetCopyright © 2021 Sydstarwave`, ALL RIGHTS RESERVED
;@Ahk2Exe-SetLegalTrademarks Sydstarwave is a trademark of Sydstarwave

; AHK Studio Defaults
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input   ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Script specific settings
#SingleInstance Force
SetKeyDelay, -1, 50 
SetTitleMatchMode 3
CoordMode Mouse, Client

; setup globals
WS4000Exe := "WS4000v4.exe"
OBSExe := "obs64.exe"
NumlockState := true
StringReplace, IconFile, A_ScriptName, ahk, exe,

init(IconFile)

;@Ahk2Exe-IgnoreBegin
; Quick debug exit hotkey
~*F12:: Gosub, End
;@Ahk2Exe-IgnoreEnd

; Hotkeys+*
~*NumLock::   NumlockStateHandler(IconFile)
*NumpadHome:: NumpadHandler(7, OBSExe, WS4000Exe) ; top-left
*NumpadPgUp:: NumpadHandler(9, OBSExe, WS4000Exe) ; top-right
*NumpadEnd::  NumpadHandler(1, OBSExe, WS4000Exe) ; bottom-left
*NumpadPgDn:: NumpadHandler(3, OBSExe, WS4000Exe) ; bottom-right

*NumpadSub:: NumpadHandler("sub", OBSExe, WS4000Exe) ; ws4000
*NumpadDiv:: NumpadHandler("div", OBSExe, WS4000Exe) ; start
*NumpadDel:: NumpadHandler("del", OBSExe, WS4000Exe) ; end
*NumpadDot:: NumpadHandler("del", OBSExe, WS4000Exe)


; --------------------------------------------------------- Functions

init(iconFileIn) {
	Menu, Tray, NoStandard
	Menu, Tray, Add , Yeet, End
	Menu, Tray, Icon, % iconFileIn, -1, 1
	TrayAndTip("Launched")
	NumlockStateHandler(iconFileIn)
}

NumlockStateHandler(iconFileIn) {
	if (GetKeyState("NumLock", "T")) {
		Menu, Tray, Icon, % iconFileIn, -1, 1
		TrayAndTip("Numlock Activated, facecam hotkeys disabled")
	}
	else {
		Menu, Tray, Icon, % iconFileIn, 0, 1
		TrayAndTip("Numlock Deactivated, facecam hotkeys enabled")
	}
}

NumpadHandler(actionIn, obsExeIn, ws4000ExeIn) {
	if (!FindHandleFromExe(obsExeIn)) {
		TrayAndTip(Format("Unable to find {1}", obsExeIn), "NumpadHandler Preflight", 3, 0x12)
		return
	}
	
	switch actionIn
	{
		case 1: ControlSendParent("+^{F1}", obsExeIn) ; bottom-left:  Ctrl + Shift + F1
		case 3: ControlSendParent("+^{F2}", obsExeIn) ; bottom-right: Ctrl + Shift + F2
		case 7: ControlSendParent("+^{F3}", obsExeIn) ; top-left:     Ctrl + Shift + F3
		case 9: ControlSendParent("+^{F4}", obsExeIn) ; top-right:    Ctrl + Shift + F4
		
		case "div": ControlSendParent("+^{F7}", obsExeIn)  ; starting
		case "del": ControlSendParent("+^{F12}", obsExeIn) ; ending
		case "sub": StartWS4000(obsExeIn, ws4000ExeIn)     ; ws4000 brb
		
		default:
		{
			;@Ahk2Exe-IgnoreBegin
			OutputDebug % Format("NumpadHandler: action {1} unrecognised", actionIn)
			;@Ahk2Exe-IgnoreEnd
			return
		}
	}
}

StartWS4000(obsExeIn, ws4000ExeIn) {
	local ws4000Active   ; Active title for WS4000
	local previousTopApp
	if (!FindHandleFromExe(ws4000ExeIn)) {
		TrayAndTip(Format("Unable to find {1}", ws4000ExeIn), "WS4000 Preflight", 3, 0x12)
		return
	}
	
	if (!FindHandleFromExe(obsExeIn)) {
		TrayAndTip(Format("Unable to find {1}", obsExeIn), "WS4000 Preflight", 3, 0x12)
		return
	}
	
	; transition hotkey - brb
	ControlSendParent("^+{F8}", obsExeIn)
	ControlSendParent("^+1", obsExeIn) ; show ws4000
	WinGet previousTopApp, ID, A
	sleep 1500    ; wait for stinger to finish before potentially switching scenes again
	
	WinActivate % GetHandleString(FindHandleFromExe(ws4000ExeIn))
	WinGetActiveTitle ws4000Active
	MouseClick Left, 80, 30
	sleep 500     ; QT needs about 250ms to register an input, half a second is better
	MouseClick Left, 80, 50
	TrayAndTip("1 - Reactivating PID " . previousTopApp, "WS4000")
	WinActivate % "ahk_id " . previousTopApp
	
	sleep 1000    ; wait a whole second before sending the next tooltip
	TrayAndTip("2 - Waiting for " . ws4000Active . " to change state..", "WS4000")
	WinWaitClose % ws4000Active
	WinGetTitle ws4000Active, % GetHandleString(FindHandleFromExe(ws4000ExeIn))
	
	; transition hotkey - Intermission WS4000
	ControlSendParent("^+{F10}", obsExeIn)
	
	TrayAndTip("3 - Waiting for " . ws4000Active . " to change state again...", "WS4000")
	WinWaitClose % ws4000Active
	ControlSendParent("^+2", obsExeIn) ; hide ws4000
	
	; transition hotkey - brb
	ControlSendParent("^+{F8}", obsExeIn)
	
	TrayAndTip("4 - Done!")
}

ControlSendParent(keyIn, exeIn) {
	; @Ahk2Exe-IgnoreBegin
	OutputDebug % Format("ControlSendParent: Sending {1}", keyIn)
	; @Ahk2Exe-IgnoreEnd
	
	ControlSend, ahk_parent, % keyIn, % GetHandleString(FindHandleFromExe(exeIn))
}

FindHandleFromExe(exeName) {
	handle := WinExist(Format("ahk_exe {1}", exeName))
	if (handle) {
		;@Ahk2Exe-IgnoreBegin
		OutputDebug % Format("FindHandleFromExe: Found handle {1} for {2}", handle, exeName)
		;@Ahk2Exe-IgnoreEnd
	}
	
	;@Ahk2Exe-IgnoreBegin
	OutputDebug % Format("FindHandleFromExe: Could not find handle {1} for {2}", handle, exeName)
	;@Ahk2Exe-IgnoreEnd
	
	return handle
}

GetHandleString(handle) {
	return Format("ahk_id {1}", handle)
}

TrayAndTip(textIn, titleIn:="Sydstarwave Keys", secondsIn:=1, optionsIn:=0x11) {
	Menu, Tray, Tip, % textIn
	TrayTip, % titleIn, % textIn, % secondsIn, % optionsIn
}

End:
{
	ExitApp
}