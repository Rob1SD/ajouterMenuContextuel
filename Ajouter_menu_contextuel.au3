#cs ----------------------------------------------------------------------------
 AutoIt Version: 3.3.14.2
 Author:         Rsolde
 Script Function:
	Template AutoIt script.
#ce ----------------------------------------------------------------------------
#include <MsgBoxConstants.au3>
#include <Constants.au3>
#include <File.au3>
#include <Array.au3>
#include <Process.au3>
#include <FTPEx.au3>
#include <ProgressConstants.au3>
#include <ComboConstants.au3>
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <StaticConstants.au3>
#include <GuiEdit.au3>
#include <GuiStatusBar.au3>
#include <ScrollBarsConstants.au3>
#RequireAdmin
Opt("GUIOnEventMode", 1)

local $argc = UBound($CmdLine)
local $pwd="manager"
If $argc = 3 and $CmdLine[1] = "-src" Then
   if $CmdLine[2] <> $pwd Then
	  MsgBox(0,0,"Mauvais mdp")
	  exit
   EndIf
   $SrcDir = @ScriptDir & "\Sources"
   DirCreate($SrcDir)
   ConsoleWrite("script : " & @ScriptName & @crlf)
   ; Extraction du/des fichier(s) source. Attention le nom du script doit etre une chaine de caractere, pas une variable car execution a la compilation
   FileInstall(".\Ajouter_menu_contextuel.au3", $SrcDir & "\",1)
   MsgBox(0,0,"Les sources ont été extraites dans /Sources")
   exit
EndIf

local $main = GUICreate( "Ajout menu", 300, 200)
GUISetOnEvent($GUI_EVENT_CLOSE, "Form2Close")
GUISetOnEvent($GUI_EVENT_MINIMIZE, "Form2Minimize")
GUISetOnEvent($GUI_EVENT_MAXIMIZE, "Form2Maximize")
GUISetOnEvent($GUI_EVENT_RESTORE, "Form2Restore")
GUISetState(@SW_SHOW)
local $Radd = GUICtrlCreateRadio("Ajouter menu", 20, 0)
GUICtrlSetOnEvent($Radd, "RaddClick")
GUICtrlSetState($Radd,$gui_checked)
local $Rdel = GUICtrlCreateRadio("Supprimer menu", 120, 0)
GUICtrlSetOnEvent($Rdel, "RdelClick")
local $input = GUICtrlCreateInput("Chemin du programe à ajouter", 10,30,200)
local $input2 = GUICtrlCreateInput("Nom du raccourci", 10,52,200)
GUICtrlSetOnEvent( $input2, "clearInput")
local $but1 = GUICtrlCreateButton("Parcourir", 210,30,50,21)
GUICtrlSetOnEvent($but1, "parcourir")
local $label = GUICtrlCreateLabel("Type de menu contextuel:", 10,75)
local $check1 = GUICtrlCreateCheckbox("Racine", 10, 90)
local $check4 = GUICtrlCreateCheckbox("Supprimer tous les menus", 110, 90)
GUICtrlSetOnEvent($check4, "check4Click")
local $check2 = GUICtrlCreateCheckbox("Repertoire", 10, 110)
local $check3 = GUICtrlCreateCheckbox("Ficher", 10, 130)
local $check5 = GUICtrlCreateCheckbox("Ouvrir le Repertoire ?", 110, 110)
local $check6 = GUICtrlCreateCheckbox("Ouvrir le fichier ?", 110, 130)
local $but2 = GUICtrlCreateButton("Go", 120,150,50,21)
GUICtrlSetOnEvent($but2, "Go")
RaddClick()
GUICtrlSetState($Radd,$gui_checked)
while 1
   sleep(50)
WEnd


func Go()
   if GUICtrlRead($Radd) = $gui_checked then
	  if FileExists(GUICtrlRead($input)) = 0 Then
		 MsgBox(1, "Erreur", "Choisir un programme")
		 return
	  ElseIf StringInStr(GUICtrlRead($input2), StringReplace(Stringmid(GUICtrlRead($input), StringInStr( GUICtrlRead($input),"\",0,-1)+1),".exe","")) = 0 Then

		 MsgBox(1, "Erreur", "Le menu doit contenir le nom du programme")

		 return
	  EndIf
	  GUICtrlSetState($input,$gui_disable)
	  GUICtrlSetState($input2,$gui_disable)
	  GUICtrlSetState($check1,$gui_disable)
	  GUICtrlSetState($check2,$gui_disable)
	  GUICtrlSetState($check3,$gui_disable)
	  local $prg = GUICtrlRead($input)
	  local $name = GUICtrlRead($input2)
	  addMenu($prg, $name)
	  local $resp = MsgBox(4, "GG WP", "Vos menus ont été ajoutés" & @CRLF & @CRLF & "Voulez-vous ajouter un autre menu ?")
	  if $resp = $IDNO Then
		 Exit
	  EndIf
	  GUICtrlSetState($input,$gui_enable)
	  GUICtrlSetState($input2,$gui_enable)
	  GUICtrlSetState($check1,$gui_enable)
	  GUICtrlSetState($check2,$gui_enable)
	  GUICtrlSetState($check3,$gui_enable)
	  return
   endif

;~    ce qui suit n'est executé qu'en mode suppresion----------

   delete(GUICtrlRead($input2))


EndFunc
func delete($name)
   local $envMenu = RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", "MenuContextuels")
   if StringLen($envMenu) = 0 Then
	  MsgBox(1,"Erreur", "Pas de menu à supprimer")
	  return
   EndIf

   local $envMenuTAB = StringSplit($envMenu,";")
   local $size = UBound($envMenuTAB)

   for $i = 1  to $size-2
	  local $tmpname = StringLeft($envMenuTAB[$i], StringInStr($envMenuTAB[$i], ':')-1)
	  local $tmp = StringSplit(stringmid($envMenuTAB[$i],StringInStr($envMenuTAB[$i], ':') + 1, 3),"")

	  local $tmproot = $tmp[1]
	  local $tmpdir = $tmp[2]
	  local $tmpfile = $tmp[3]
	  if $tmpname=$name or GUICtrlRead($check4) = $gui_checked Then
		 if (GUICtrlRead($check4) = $gui_checked or GUICtrlRead($check1) = $gui_checked) and $tmproot=1 Then
			RegDelete("HKEY_CLASSES_ROOT\Directory\Background\shell\"&$name)
			$tmproot=0
		 EndIf
		 if (GUICtrlRead($check4) = $gui_checked or GUICtrlRead($check2) = $gui_checked) and $tmpdir=1 Then
			RegDelete("HKEY_CLASSES_ROOT\Directory\shell\"&$name)
			$tmpdir=0
		 EndIf
		 if (GUICtrlRead($check4) = $gui_checked or GUICtrlRead($check3) = $gui_checked) and $tmpfile=1 Then
			RegDelete("HKEY_CLASSES_ROOT\*\shell\"&$name)
			$tmpfile=0
		 EndIf
		 $envMenu = StringReplace($envMenu,$envMenuTAB[$i]&";","")
		 if $tmproot<>0 or $tmpdir<>0 or $tmpfile<>0 Then
			$envMenu = $name&':'&$tmproot&$tmpdir&$tmpfile&';'&$envMenu

		 EndIf
		 RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", "MenuContextuels", "REG_SZ", $envMenu)
	  EndIf

   Next
   local $resp = MsgBox(4, "GG WP", "Vos menus ont été supprimés" & @CRLF & @CRLF & "Voulez-vous ajouter un autre menu ?")
   if $resp = $IDNO Then
	  Exit
   EndIf
EndFunc

func parcourir()
   local $exe = FileOpenDialog("Choisir le programme", "C:\", "EXE (*.exe)")
   GUICtrlSetData($input, $exe)
EndFunc

func addMenu($prg,$name)
   local $RootMenu = 0
   local $DirMenu = 0
   local $FileMenu = 0
   if GUICtrlRead($check1) = $gui_checked then
	  addMenuRoot($prg,$name)
	  $RootMenu = 1
   endif
   if GUICtrlRead($check2) = $gui_checked then
	  addMenuDir($prg,$name)
	  $DirMenu = 1
   endif
   if GUICtrlRead($check3) = $gui_checked then
	  addMenuFile($prg,$name)
	  $FileMenu = 1
   endif
   local $envMenu = RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", "MenuContextuels")
   $envMenu = $name&':'&$RootMenu&$DirMenu&$FileMenu&';'&$envMenu
   RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", "MenuContextuels", "REG_SZ", $envMenu)
EndFunc

;~ ajout menu contextextuel quand click droit a la RACINE des dossier----------------------------------
func addMenuRoot($prg,$name)
;~    msgbox(1,"","RACINE")
;~    return
   RegWrite("HKEY_CLASSES_ROOT\Directory\Background\shell", $name)
   RegWrite("HKEY_CLASSES_ROOT\Directory\Background\shell\"&$name, "command")
   RegWrite("HKEY_CLASSES_ROOT\Directory\Background\shell\"&$name&"\command", "","REG_SZ", $prg)
   RegWrite("HKEY_CLASSES_ROOT\Directory\Background\shell\"&$name&"\command", "canSupp","REG_SZ", "oui")
EndFunc
;~ -----------------------------------------------------------------------------------------------------



;~ ajout menu contextextuel quand click droit sur fichier----------------------------------
func addMenuFile($prg,$name)
;~     msgbox(1,"","FICHIER")
;~    return
   local $param = ""
   if GUICtrlRead($check6) = $gui_checked then
	  $param &= " %1"
   EndIf
   RegWrite("HKEY_CLASSES_ROOT\*\shell", $name)
   RegWrite("HKEY_CLASSES_ROOT\*\shell\"&$name, "command")
   RegWrite("HKEY_CLASSES_ROOT\*\shell\"&$name&"\command", "","REG_EXPAND_SZ", $prg & $param)
   RegWrite("HKEY_CLASSES_ROOT\*\shell\"&$name&"\command", "canSupp","REG_SZ", "oui")
EndFunc
;~ -------------------------------------------------------------------------------------------



;~ ajout menu contextextuel quand click droit sur un dossier----------------------------------
func addMenuDir($prg,$name)
;~     msgbox(1,"","DOSSIER")
;~    return
   local $param = ""
   if GUICtrlRead($check5) = $gui_checked then
	  $param &= " %1"
   EndIf
   RegWrite("HKEY_CLASSES_ROOT\Directory\shell", $name)
   RegWrite("HKEY_CLASSES_ROOT\Directory\shell\"&$name, "command")
   RegWrite("HKEY_CLASSES_ROOT\Directory\shell\"&$name&"\command", "","REG_EXPAND_SZ", $prg & $param)
   RegWrite("HKEY_CLASSES_ROOT\Directory\shell\"&$name&"\command", "canSupp","REG_SZ", "oui")
EndFunc
;~ ----------------------------------------------------------------------------------------------



















func Form2Close()
   exit
EndFunc
;~ --------------------------------fonctions d'affichages des elements en fonction des options-------------------------------------------
func RaddClick()
   GUICtrlSetState($input,$gui_enable)
   GUICtrlSetState($but1,$gui_enable)
   GUICtrlSetState($input2,$gui_enable)
   GUICtrlSetState($check1,$gui_enable)
   GUICtrlSetState($check2,$gui_enable)
   GUICtrlSetState($check3,$gui_enable)
   GUICtrlSetState($check5,$gui_enable)
   GUICtrlSetState($check6,$gui_enable)
   GUICtrlSetState($check4,$gui_disable)
   GUICtrlSetState($check4,$gui_unchecked)

EndFunc

func RdelClick()
   GUICtrlSetState($but1,$gui_disable)
   GUICtrlSetState($input,$gui_disable)
   GUICtrlSetState($input2,$gui_enable)
   GUICtrlSetState($check1,$gui_enable)
   GUICtrlSetState($check2,$gui_enable)
   GUICtrlSetState($check3,$gui_enable)
   GUICtrlSetState($check5,$gui_disable)
   GUICtrlSetState($check6,$gui_disable)
   GUICtrlSetState($check4,$gui_unchecked)
   GUICtrlSetState($check4,$gui_enable)

EndFunc
func check4Click()
    GUICtrlSetState($check1,$gui_unchecked)
    GUICtrlSetState($check2,$gui_unchecked)
    GUICtrlSetState($check3,$gui_unchecked)
    GUICtrlSetState($check5,$gui_unchecked)
    GUICtrlSetState($check6,$gui_unchecked)
   if GUICtrlRead($check4) = $gui_checked then
	  GUICtrlSetState($but1,$gui_disable)
	  GUICtrlSetState($input,$gui_disable)
	  GUICtrlSetState($input2,$gui_disable)
	  GUICtrlSetState($check1,$gui_disable)
	  GUICtrlSetState($check2,$gui_disable)
	  GUICtrlSetState($check3,$gui_disable)
	  GUICtrlSetState($check5,$gui_disable)
	  GUICtrlSetState($check6,$gui_disable)
	  GUICtrlSetState($check4,$gui_enable)
   Else
	  GUICtrlSetState($but1,$gui_disable)
	  GUICtrlSetState($input,$gui_disable)
	  GUICtrlSetState($input2,$gui_enable)
	  GUICtrlSetState($check1,$gui_enable)
	  GUICtrlSetState($check2,$gui_enable)
	  GUICtrlSetState($check3,$gui_enable)
	  GUICtrlSetState($check5,$gui_enable)
	  GUICtrlSetState($check6,$gui_enable)
	  GUICtrlSetState($check4,$gui_enable)
   EndIf

EndFunc
;~ FIN-----------------------------fonctions d'affichage des element en fonction des options-------------------------------------------