' Kitten Studio Pro - silent launcher.
' Double-click this instead of the .bat. No console window appears.
' If first-time setup has not been done yet, it opens the .bat visibly so you can watch it.
Option Explicit
Dim sh, fso, here, bat, mark, q
Set sh  = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
here = fso.GetParentFolderName(WScript.ScriptFullName)
sh.CurrentDirectory = here
bat  = here & "\kitten_pro.bat"
mark = here & "\venv\.setup_ok"
q = Chr(34)

If Not fso.FileExists(bat) Then
    MsgBox "kitten_pro.bat was not found next to this file.", 16, "Kitten Studio Pro"
    WScript.Quit 1
End If

If fso.FileExists(mark) Then
    ' setup finished before: run the bat hidden (window style 0)
    sh.Run "cmd /c " & q & q & bat & q & " quiet" & q, 0, False
Else
    ' first run: show the setup window (window style 1)
    sh.Run "cmd /c " & q & q & bat & q & q, 1, False
End If
