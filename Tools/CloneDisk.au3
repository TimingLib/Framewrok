#include <GUIConstants.au3>
#include <Msgboxconstants.au3>
#include <FontConstants.au3>
#include <ColorConstants.au3>
#include <WindowsConstants.au3>
#include <GuiButton.au3>
#include <File.au3>
#include <FileConstants.au3>
#include <StringConstants.au3>
#include <ProcessConstants.au3>
#include <Process.au3>
#include <WinNet.au3>

#RequireAdmin

FileInstall(@WorkingDir&"\Capture2.JPG",@TempDir&"\",1)
FileInstall(@WorkingDir&"\grub_disk.cfg",@TempDir&"\",1)
FileInstall@WorkingDir&"\grub_partion.cfg",@TempDir&"\",1)

#cs
If Not FileExists(@HomeDrive&"\clonezilla\filesystem.squashfs") Or Not FileExists(@HomeDrive&"\clonezilla\initrd.img") Or Not FileExists(@HomeDrive&"\clonezilla\vmlinuz") Then
   DirCreate(@HomeDrive&"\clonezilla")
   FileInstall("C:\Users\yliu3\Desktop\RemoteWin\Clonezilla\filesystem.squashfs",@HomeDrive&"\clonezilla\",1)
   FileInstall("C:\Users\yliu3\Desktop\RemoteWin\Clonezilla\initrd.img",@HomeDrive&"\clonezilla\",1)
   FileInstall("C:\Users\yliu3\Desktop\RemoteWin\Clonezilla\vmlinuz",@HomeDrive&"\clonezilla\",1)
EndIf
#ce

;Disable the 64bit OS library function
DllCall("kernel32.dll", "int", "Wow64DisableWow64FsRedirection", "int", 1)

;Func CreateGui()
Global $W_table = GUICreate("Clone the machine",350,250,-1,-1,-1,$WS_EX_ACCEPTFILES)
Local  $backimg = @TempDir&"\Capture2.JPG"
GUICtrlCreatePic($backimg,0,0,350,200)
GUICtrlSetState(-1,$GUI_DISABLE)
Local $i_Start = GUICtrlCreateButton("Start",270,200,60,25)
Local $i_Menu = GUICtrlCreateMenu("Setting")
Local $i_server = GUICtrlCreateMenuItem("Server",$i_Menu)
Local $i_image = GUICtrlCreateMenuItem("Image",$i_Menu)
GUISetState(@SW_show, $W_table)

Global $server = "10.144.168.48"
Global $image = ""

Func _Server_Gui()
Global $S_list = GUICreate("Select the Server",250,100,20,20,-1,$WS_EX_MDICHILD,$W_table)
$i_Input = GUICtrlCreateInput("10.144.168.48",25,40,150,20,-1,$WS_EX_OVERLAPPEDWINDOW)
$i_OK = GUICtrlCreateButton("OK",190,40,45,20,$BS_NOTIFY)
GUISetState(@SW_show,$S_list)
While 1
   Switch GUIGetMsg()
	  Case $GUI_EVENT_CLOSE
		 $server = GUICtrlRead($i_Input)
		 GUIDelete($S_list)
		 ExitLoop
	  Case $i_OK
		 $server = GUICtrlRead($i_Input)
		 GUIDelete($S_list)
		 ExitLoop
   EndSwitch
WEnd
EndFunc


Func _Image_Gui()
	  $img_server = '\\' & $server & '\Images'
	  Ping($server,1000)
	  If @error > 0 Then
		 MsgBox(0+48,""," " & $server & " is unreachable")
		 Return False
	  EndIf
	  _WinNet_AddConnection2("",$img_server,"RFSTS-TESTER01\lvadmin","labview===")
	  $images = _FileListToArray($img_server,"*",2)
	  _WinNet_CancelConnection2($server)
	  $num = UBound($images)
	  $I_list = GUICreate("Image List",280,$num*25,20,20,-1,$WS_EX_MDICHILD,$W_table)
	  $I_listview = GUICtrlCreateListView("                                                     |",20,15,180,($num-1)*22,$LVS_NOCOLUMNHEADER + $LVS_SINGLESEL,$LVS_EX_FULLROWSELECT)
	  For $i = 1 To ($num - 1) Step 1
		 GUICtrlCreateListViewItem($images[$i],$I_listview)
	  Next
	  $I_button = GUICtrlCreateButton("OK",220,$num*30-50,45,20)
	  GUISetState(@SW_show,$I_list)
	  While 1
		 Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
			   $image = GUICtrlRead(GUICtrlRead($I_listview))
			   GUIDelete($I_list)
			   ExitLoop
			Case $I_button
			   $image = GUICtrlRead(GUICtrlRead($I_listview))
			   GUIDelete($I_list)
			   ExitLoop
		 EndSwitch
	  WEnd

EndFunc

Func _SetBoolSequence()
   Local $identifier_grub
   $i_File = Run(@ComSpec & " /c " & ' bcdedit /enum all ',@SystemDir,@SW_HIDE,$STDERR_CHILD + $STDOUT_CHILD)
   ProcessWaitClose($i_File)
   $i_Text = StdoutRead($i_File)
   $i_match2 = StringRegExp($i_Text,'identifier(.*)\r\n(.*)\r\n(.*)\r\n(.*)Grub 2 For Windows',$STR_REGEXPARRAYMATCH)
   If Not @error Then
	  $identifier_grub = $i_match2[0]
	  Run(@ComSpec & " /c " & 'bcdedit /bootsequence '& $identifier_grub,"",@SW_HIDE)
	  MsgBox(0+48,""," Machine will reboot   5s...  ",6)
	  Shutdown($SD_REBOOT)
	  Exit
   Else
	  MsgBox(0+16,""," Exception was found when executing the 'BCDEDIT'")
   EndIf
EndFunc

Dim $Machine = Null

While 1
	  Switch GUIGetMsg()
		 Case $GUI_EVENT_CLOSE
			   Exit
		 Case $i_server
			   _Server_Gui()
		 Case $i_image
			   _Image_Gui()
		 Case $i_Start
			   If $image == "" Or $image == 0 Then
				  MsgBox(48+0,"","   Please Select the Image  ",5)
				  ContinueLoop
			   Else
				  $grub_server = $server
				  $grub_image = StringSplit($image,"|",$STR_NOCOUNT )[0]
			   EndIf
			   If Not FileExists(@HomeDrive&"\grub2\i386-pc") Then
					 MsgBox(16+0,"","    Please Install the GRUB2  ",5)
					 ContinueLoop
			   Else
					 $ispartion = StringInStr($grub_image,"Disk")
					 If Not $ispartion = 0 Then
						FileCopy(@TempDir&"\grub_partion.cfg",@HomeDrive&"\grub2\grub.cfg",1)
						_ReplaceStringInFile(@HomeDrive&"\grub2\grub.cfg","SERVER",$grub_server,1)
						_ReplaceStringInFile(@HomeDrive&"\grub2\grub.cfg","IMAGE",$grub_image,1)
						_SetBoolSequence()
					 Else
						FileCopy(@TempDir&"\grub_partion.cfg",@HomeDrive&"\grub2\grub.cfg",1)
						_ReplaceStringInFile(@HomeDrive&"\grub2\grub.cfg","SERVER",$grub_server,1)
						_ReplaceStringInFile(@HomeDrive&"\grub2\grub.cfg","IMAGE",$grub_image,1)
						_SetBoolSequence()
					 EndIf
			   EndIf
	  EndSwitch
   WEnd
