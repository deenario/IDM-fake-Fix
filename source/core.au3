#RequireAdmin

#include <Date.au3>
#include <String.au3>



FileInstall("idm_reset.reg",@TempDir & "\idm_reset.reg",1)
FileInstall("idm_trial.reg",@TempDir & "\idm_trial.reg",1)
FileInstall("idm_reg.reg",@TempDir & "\idm_reg.reg",1)
FileInstall("SetACLx32.exe",@TempDir & "\SetACLx32.exe",1)
FileInstall("SetACLx64.exe",@TempDir & "\SetACLx64.exe",1)

Global $setacl = (@OSArch = "X86") ? '"' & @TempDir & "\SetACLx32.exe" & '"' : '"' & @TempDir & "\SetACLx64.exe" & '"'

Global $version = 20
Global $urlForum = "http://bit.ly/IDMresetTrialForum"
Global $urlDownload = "http://bit.ly/IDMresetTrial"

Global $isAuto = isAuto()

Global $allkey[6]
$allkey[0] = '{6DDF00DB-1234-46EC-8356-27E7B2051192}'
$allkey[1] = '{7B8E9164-324D-4A2E-A46D-0165FB2000EC}'
$allkey[2] = '{D5B91409-A8CA-4973-9A0B-59F713D25671}'
$allkey[3] = '{5ED60779-4DE2-4E07-B862-974CA4FF2E9C}'
$allkey[4] = '{55694430-6f08-d8a4-801d-e6489132f3eb}'
$allkey[5] = '{07999AC3-058B-40BF-984F-69EB1E554CA7}'

Func SetOwner($owner)
   ; $owner : everyone or nobody
   Switch $owner
   case "everyone"
	  $owner = "S-1-1-0"
   case "nobody"
	  $owner = "S-1-0-0"
   EndSwitch

   For $i=0 To UBound($allkey)-1 Step 1
	  RunWait($setacl & ' -on HKCU\Software\Classes\CLSID\' & $allkey[$i] & ' -ot reg -actn setowner -ownr "n:' & $owner & '" -silent',"",@SW_HIDE)
	  RunWait($setacl & ' -on HKCU\Software\Classes\Wow6432Node\CLSID\' & $allkey[$i] & ' -ot reg -actn setowner -ownr "n:' & $owner & '" -silent',"",@SW_HIDE)
	  RunWait($setacl & ' -on HKLM\Software\Classes\CLSID\' & $allkey[$i] & ' -ot reg -actn setowner -ownr "n:' & $owner & '" -silent',"",@SW_HIDE)
	  RunWait($setacl & ' -on HKLM\Software\Classes\Wow6432Node\CLSID\' & $allkey[$i] & ' -ot reg -actn setowner -ownr "n:' & $owner & '" -silent',"",@SW_HIDE)
   Next
EndFunc

Func SetPermission($permission)
   ; $permission : read or full
   For $i=0 To UBound($allkey)-1 Step 1
	  RunWait($setacl & ' -on HKCU\Software\Classes\CLSID\' & $allkey[$i] & ' -ot reg -actn ace -ace "n:everyone;p:' & $permission & '" -actn setprot -op "dacl:p_nc;sacl:p_nc" -silent',"",@SW_HIDE)
	  RunWait($setacl & ' -on HKCU\Software\Classes\Wow6432Node\CLSID\' & $allkey[$i] & ' -ot reg -actn ace -ace "n:everyone;p:' & $permission & '" -actn setprot -op "dacl:p_nc;sacl:p_nc" -silent',"",@SW_HIDE)
	  RunWait($setacl & ' -on HKLM\Software\Classes\CLSID\' & $allkey[$i] & ' -ot reg -actn ace -ace "n:everyone;p:' & $permission & '" -actn setprot -op "dacl:p_nc;sacl:p_nc" -silent',"",@SW_HIDE)
	  RunWait($setacl & ' -on HKLM\Software\Classes\Wow6432Node\CLSID\' & $allkey[$i] & ' -ot reg -actn ace -ace "n:everyone;p:' & $permission & '" -actn setprot -op "dacl:p_nc;sacl:p_nc" -silent',"",@SW_HIDE)
   Next
EndFunc

Func Reset()
   Local $DOS, $Message = '' ;; added "= ''" for show only.
   $DOS = Run("reg query hkcr\clsid /f cDTvBFquXk0 /d /s", "", @SW_HIDE, 0x8)
   ProcessWaitClose($DOS)
   $Message = StdoutRead($DOS)
   If StringInStr($Message,"{") Then
	  $allkey[4] = "{" & _StringBetween(BinaryToString($Message),"{","}")[0] & "}"
   EndIf

   SetOwner("everyone")
   SetPermission("full")
   ; reset everything
   RunWait('reg import "' & @TempDir & "\idm_reset.reg" & '"',"",@SW_HIDE)

   RegDelete("HKEY_CURRENT_USER\Software\Classes\CLSID\" & $allkey[4])
   RegDelete("HKEY_CURRENT_USER\Software\Classes\Wow6432Node\CLSID\" & $allkey[4])
   RegDelete("HKEY_LOCAL_MACHINE\Software\Classes\CLSID\" & $allkey[4])
   RegDelete("HKEY_LOCAL_MACHINE\Software\Classes\Wow6432Node\CLSID\" & $allkey[4])
EndFunc

Func autorun($s)
   Switch $s
	  ; Disable autorun
	  Case "off"
		 RunWait('reg delete "HKCU\Software\DownloadManager" /v "auto_reset_trial" /f',"",@SW_HIDE)
		 RunWait('reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "IDM trial reset" /f',"",@SW_HIDE)
	  ; Enable autorun
	  Case "trial"
		 RunWait('reg add "HKCU\Software\DownloadManager" /v "auto_reset_trial" /t "REG_SZ" /d "' & _DateAdd("D",15,@YEAR & "/" & @MON & "/" & @MDAY) & '" /f',"",@SW_HIDE)
		 RunWait('reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "IDM trial reset" /t "REG_SZ" /d "\"' & @ScriptFullPath & '\" /trial" /f',"",@SW_HIDE)
   EndSwitch
EndFunc

Func Trial()
   Reset()
   RunWait('reg import "' & @TempDir & "\idm_trial.reg" & '"',"",@SW_HIDE)
   SetPermission("read")
   SetOwner("nobody")
EndFunc

Func TrialSilent()
   Local $auto_reset_trial = RegRead("HKCU\Software\DownloadManager","auto_reset_trial")
   Local $day_to_reset = _DateDiff("D",@YEAR & "/" & @MON & "/" & @MDAY,$auto_reset_trial)
   If $day_to_reset <= 0 Then
	  Trial()
	  autorun("trial")
	  If GotUpdate() Then
		 $Download = (MsgBox(1,"IDM trial reset","Update me now?")==1)
		 If $Download Then ShellExecute($urlDownload)
	  EndIf
   EndIf
EndFunc

Func Register($FName = "IDM trial reset")
   Reset()
   autorun("off")
   RunWait('reg import "' & @TempDir & "\idm_reg.reg" & '"',"",@SW_HIDE)

   RegWrite("HKEY_CURRENT_USER\Software\Classes\CLSID\" & $allkey[4])
   RegWrite("HKEY_CURRENT_USER\Software\Classes\Wow6432Node\CLSID\" & $allkey[4])
   RegWrite("HKEY_LOCAL_MACHINE\Software\Classes\CLSID\" & $allkey[4])
   RegWrite("HKEY_LOCAL_MACHINE\Software\Classes\Wow6432Node\CLSID\" & $allkey[4])

   RunWait('reg add "HKCU\Software\DownloadManager" /v "FName" /t "REG_SZ" /d "' & $FName & '" /f',"",@SW_HIDE)
   SetPermission("read")
   SetOwner("nobody")
EndFunc

Func GotUpdate()
   Local $info = InetRead("http://pastebin.com/raw.php?i=uYr0cstV",1)
   If $info <> "" Then
	  Local $latest = _StringBetween(BinaryToString($info),"<version>","</version>")[0]
	  Return ($latest > $version)
   Else
	  Return 0
   EndIf
EndFunc

Func isAuto()
   Local $checkTime = _DateIsValid(RegRead("HKCU\Software\DownloadManager","auto_reset_trial"))
   Local $Autorun = FileExists("""" & _StringBetween("" & RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Run","IDM trial reset"),"""","""") & """")
   return $Autorun*$checkTime
EndFunc

Func clearTemp()
   ; Delete temp file

   FileDelete(@TempDir & "\idm_reset.reg")
   FileDelete(@TempDir & "\idm_trial.reg")
   FileDelete(@TempDir & "\idm_reg.reg")
   FileDelete(@TempDir & "\SetACLx32.exe")
   FileDelete(@TempDir & "\SetACLx64.exe")

EndFunc