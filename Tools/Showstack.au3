#include <FileConstants.au3>
#include <Process.au3>
#include <File.au3>

#NoTrayIcon

Showstack()
Exit (0)

Func Showstack()
   $branchfolder = _FileListToArrayRec("C:\rfstsp4root\MI\RFSTS\Tests\", "installer.log",1, $FLTAR_RECUR)
   If @error Then
	  MsgBox(16, "","An error occurred when reading the file.")
	  Exit (1)
   Else
	  $installerfile = "C:\rfstsp4root\MI\RFSTS\Tests\" & $branchfolder[1]
   EndIf
   If $cmdline[0] <> 0 and FileExists($cmdline[1]) Then
	  $installerfile = $cmdline[1]
   EndIf
   Local $hFileRead = FileOpen($installerfile, $FO_READ)
   Local $installers = FileRead($hFileRead)
   Const $Path = @WindowsDir & "\Sysnative\StikyNot.exe"
   Const $hSticky = "[CLASS:Sticky_Notes_Note_Window]"
   if WinExists($hSticky,"") Then
	  WinClose($hSticky,"")
   EndIf
   ShellExecute($Path )
   WinWait($hSticky,"",2)
   ControlSetText($hSticky,"","",$installers & @CRLF)
EndFunc








