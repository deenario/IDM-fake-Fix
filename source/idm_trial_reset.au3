#include <core.au3>
#include <GUIConstantsEx.au3>

AutoItSetOption("TrayMenuMode",1)

If $CmdLine[0] = 0 Then
   GUI()
Else
   Switch $CmdLine[1]
	  Case "/trial"
		 TrialSilent()
		 clearTemp()
	  Case Else
		 GUI()
   EndSwitch
EndIf

Func GUI()
   #Region ### START Koda GUI section ###
   $GUI = GUICreate("IDM trial reset", 325, 112, -1, -1)
   $tabMain = GUICtrlCreateTab(1, 0, 325, 112)
   $tabTrialReset = GUICtrlCreateTabItem("Trial reset")
   $btReset = GUICtrlCreateButton("Reset the IDM trial now", 78, 40, 180, 35)
   $cbAutorun = GUICtrlCreateCheckbox("Automatically", 128, 80, 80, 20)
   $tabRegister = GUICtrlCreateTabItem("Register")
   $btReg = GUICtrlCreateButton("Register IDM now", 78, 40, 180, 35)
   $lbReg = GUICtrlCreateLabel("If IDM will be blocked then Register again or use Trial reset", 27, 80, 282, 17)
   $tabHelp = GUICtrlCreateTabItem("Help")
   GUICtrlSetState(-1,$GUI_SHOW)
   $lbHelp = GUICtrlCreateLabel("", 15, 35, 308, 50)
   GUICtrlSetData(-1, StringFormat("Trial reset ---> Reset the IDM trial, fix blocked, fake serial...\r\nRegister -----> Register IDM"))
   $btForum = GUICtrlCreateButton("Chat about this tool", 56, 80, 105, 25)
   $btUpdate = GUICtrlCreateButton("Check for update", 166, 80, 105, 25)
   GUICtrlCreateTabItem("")
   GUICtrlSetState($cbAutorun,$isAuto ? 1 : 4)
   GUISetState(@SW_SHOW)
   #EndRegion ### END Koda GUI section ###

   While 1
	  $nMsg = GUIGetMsg()
	  Switch $nMsg
		 Case $GUI_EVENT_CLOSE
			clearTemp()
			Exit
		 Case $btReset
			GUICtrlSetData($btReset,"Please wait...")
			Trial()
			GUICtrlSetData($btReset,"Reset the IDM trial now")
			MsgBox(0,"Reset IDM trial","You have 30 day trial now!")
		 Case $cbAutorun
			If GUICtrlRead($cbAutorun) = 1 Then
			   GUICtrlSetData($btReset,"Please wait...")
			   Trial()
			   autorun("trial")
			   GUICtrlSetData($btReset,"Reset the IDM trial now")
			   MsgBox(0,"Auto reset","The IDM trial will be reset automatically.")
			Else
			   autorun("off")
			   MsgBox(0,"Auto reset","The IDM trial will NOT be reset automatically.")
			EndIf
		 Case $btReg
			$Name = InputBox("Register IDM","Type your name here: ","IDM trial reset","","","130")
			If @error <> 1 Then
			   If StringLen($Name) = 0 Then $Name = "IDM trial reset"
			   GUICtrlSetData($btReg,"Please wait...")
			   Register($Name)
			   GUICtrlSetState($cbAutorun,4)
			   GUICtrlSetData($btReg,"Register IDM now")
			   MsgBox(0,"Register IDM","IDM is registered now!")
			EndIf
		 Case $btForum
			ShellExecute($urlForum)
		 Case $btUpdate
			GUICtrlSetData($btUpdate,"Please wait...")
			If GotUpdate() Then
			   $Download = (MsgBox(1,"IDM trial reset","Update me now?")==1)
			   If $Download Then ShellExecute($urlDownload)
			Else
			   MsgBox(0,"IDM trial reset","No update was found!")
			EndIf
			GUICtrlSetData($btUpdate,"Check for update")
	  EndSwitch
   WEnd
EndFunc
