#include <GUIConstants.au3>
#include <MsgBoxConstants.au3>
#include <WindowsConstants.au3>
#include <FontConstants.au3>
#include <ColorConstants.au3>
#include <StringConstants.au3>
#include <StaticConstants.au3>
#include <GuiImageList.au3>
#include <GuiButton.au3>
#include <Process.au3>
#include <File.au3>
#Include <String.au3>
#include <FontConstants.au3>
#include <ColorConstants.au3>
#include <StringConstants.au3>
#include <StaticConstants.au3>
#include <GuiButton.au3>
#include <GuiImageList.au3>
#RequireAdmin

;#NoTrayIcon

DllCall("kernel32.dll", "int", "Wow64DisableWow64FsRedirection", "int", 1) ; This disables 32bit applications from being redirected to syswow64 instead of system32 by default ;
FileInstall(@WorkingDir&"\Capture3.JPG",@TempDir&"\",1)
FileInstall(@WorkingDir&"\48X48.ico",@TempDir&"\",1)
FileInstall(@WorkingDir&"\48_48.ico",@TempDir&"\",1)

$i_Icon = @TempDir&"\48x48.ico"
$i_IconP = @TempDir&"\48_48.ico"

;Func Create GUI
Global $W_table = GUICreate("Boot Switch",380,250,-1,-1,-1,$WS_EX_ACCEPTFILES)
Local  $backimg = @TempDir&"\Capture3.JPG"
GUICtrlCreatePic($backimg,0,0,380,250)
GUICtrlSetState(-1,$GUI_DISABLE)
Local $Lable_7 = GUICtrlCreateLabel("Boot To Win7",25,130,120,20)
GUICtrlSetBkColor($Lable_7, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor($Lable_7,0xb87333)
GUICtrlSetFont($Lable_7,12,1200)
GUICtrlCreateGroup("",20,30,180,120)
Global $button_7 = GUICtrlCreateButton("START",80,75,70,40)
GUICtrlSetFont($button_7,6,200)
_SetIcon($button_7,$i_Icon,0,0,30,30)
GUICtrlCreateGroup("",160,100,200,120)
Local $Lable_10 = GUICtrlCreateLabel("Boot To Win10",165,200,120,20)
GUICtrlSetBkColor($Lable_10, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor($Lable_10,0xfa8c35)
GUICtrlSetFont($Lable_10,12,1200)
Global $button_10 = GUICtrlCreateButton("START",250,145,70,40)
GUICtrlSetFont($button_10,6,200)
_SetIcon($button_10,$i_Icon,0,0,30,30)
GUISetState(@SW_show,$W_table)


;Func Set the Icon of button
Func _SetIcon($hWnd,$iFile,$iIndex = 0,$nAlign = 0,$iWidth = 70,$iHeight = 30)
   $hImage = _GUIImageList_Create($iWidth,$iHeight,5,1,0)
   _GUIImageList_AddIcon($hImage,$iFile,$iIndex,True)
   _GUICtrlButton_SetImageList($hWnd,$hImage,$nAlign)
EndFunc


;Func Show Timeout
Func _SetTimeout_7()
   GUICtrlSetData($button_7,$i)
   $i -= 1
   Select
	  Case $i < 0
		 _SetBoolSequence("Win7")
		 Return AdlibUnRegister("_SetTimeout_7")
   EndSelect
EndFunc


;Func Show Timeout
Func _SetTimeout_10()
   GUICtrlSetData($button_10,$i)
   $i -= 1
   Select
	  Case $i < 0
		 _SetBoolSequence("Win10")
		 Return AdlibUnRegister("_SetTimeout_10")
   EndSelect
EndFunc

;Func Switch the boot of OS
Func _SetBoolSequence($OS)
   Local $identifier_7,$identifier_10 ,$identifier_2
   $i_File = Run(@ComSpec & " /c " & 'bcdedit /enum all',@SystemDir,@SW_HIDE,$STDERR_CHILD + $STDOUT_CHILD )
   ProcessWaitClose($i_File)
   $i_Text = StdoutRead($i_File)
   $i_match7 = StringRegExp($i_Text,'identifier(.*)\r\n(.*)\r\n(.*)\r\n(.*)Windows 7',$STR_REGEXPARRAYMATCH)
   If Not @error Then
	  $identifier_7 = $i_match7[0]
   EndIf
   $i_match10 = StringRegExp($i_Text,'identifier(.*)\r\n(.*)\r\n(.*)\r\n(.*)Windows 10',$STR_REGEXPARRAYMATCH)
   If Not @error Then
	  $identifier_10 = $i_match10[0]
   EndIf

   Switch $OS
	  Case "Win7"
		 If $identifier_7 = "" Then
			MsgBox($MB_ICONERROR,"ERROR"," No Specified Boot Loader Exist",5)
		 Else
			Run(@ComSpec & " /c " & 'bcdedit /Default '& $identifier_7,"",@SW_HIDE)
			Sleep(1000)
			Shutdown($SD_REBOOT)
			Exit
		 EndIf
	  Case "Win10"
		 If $identifier_10 = "" Then
			MsgBox($MB_ICONERROR,"ERROR"," No Specified Boot Loader Exist",5)
		 Else
			Run(@ComSpec & " /c " & 'bcdedit /Default '& $identifier_10,"",@SW_HIDE)
			Sleep(1000)
			Shutdown($SD_REBOOT)
			Exit
		 EndIf

   EndSwitch
EndFunc


;Main Func
While True
   Dim $i_Msg = GUIGetMsg()
   Select
		 Case $i_Msg == $GUI_EVENT_CLOSE
			ExitLoop
		 Case $i_Msg == $button_7
			Dim $i = 5
			_SetIcon($button_7,$i_IconP,0,0,30,30)
			GUICtrlSetState($button_7,$GUI_DISABLE)
			AdlibRegister('_SetTimeout_7',1000)
		 Case $i_Msg == $button_10
			Dim $i = 5
			_SetIcon($button_10,$i_IconP,0,0,30,30)
			GUICtrlSetState($button_10,$GUI_DISABLE)
			AdlibRegister('_SetTimeout_10',1000)
   EndSelect
WEnd
GUIDelete($W_table)
Exit


