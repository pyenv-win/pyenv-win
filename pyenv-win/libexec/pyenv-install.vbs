Option Explicit

Sub Import(importFile)
    Dim fso, libFile
    On Error Resume Next
    Set fso = CreateObject("Scripting.FileSystemObject")
    Set libFile = fso.OpenTextFile(fso.getParentFolderName(WScript.ScriptFullName) &"\"& importFile, 1)
    ExecuteGlobal libFile.ReadAll
    If Err.number <> 0 Then
        WScript.Echo "Error importing library """& importFile &"""("& Err.Number &"): "& Err.Description
        WScript.Quit 1
    End If
    libFile.Close
End Sub

Import "pyenv-lib.vbs"
Import "pyenv-install-lib.vbs"

WScript.Echo ":: [Info] ::  Mirror: " & mirror

Sub ShowHelp()
    WScript.Echo "Usage: pyenv install [-f|-s] <version>"
    WScript.Echo "       pyenv install [-f|-s] <definition-file>"
    WScript.Echo "       pyenv install -l|--list"
    WScript.Echo ""
    WScript.Echo "  -l/--list          List all available versions"
    WScript.Echo "  -f/--force         Install even if the version appears to be installed already"
    WScript.Echo "  -s/--skip-existing Skip if the version appears to be installed already"
    WScript.Echo "  -q/--quiet         Install using /quiet. This does not show the UI nor does it prompt for inputs"
    WScript.Echo ""
    WScript.Quit
End Sub

Dim listEnv
listEnv = Array(_
    Array("2.0.1", mirror&"/2.0.1/", "Python-2.0.1.exe", "i386"),_
    Array("2.1.3", mirror&"/2.1.3/", "Python-2.1.3.exe", "i386"),_
    Array("2.2", mirror&"/2.2/", "Python-2.2.exe", "i386"),_
    Array("2.2.1", mirror&"/2.2.1/", "Python-2.2.1.exe", "i386"),_
    Array("2.2.2", mirror&"/2.2.2/", "Python-2.2.2.exe", "i386"),_
    Array("2.2.3", mirror&"/2.2.3/", "Python-2.2.3.exe", "i386"),_
    Array("2.3", mirror&"/2.3/", "Python-2.3.exe", "i386"),_
    Array("2.3.1", mirror&"/2.3.1/", "Python-2.3.1.exe", "i386"),_
    Array("2.3.2-1", mirror&"/2.3.2/", "Python-2.3.2-1.exe", "i386"),_
    Array("2.3.3", mirror&"/2.3.3/", "Python-2.3.3.exe", "i386"),_
    Array("2.3.4", mirror&"/2.3.4/", "Python-2.3.4.exe", "i386"),_
    Array("2.3.5", mirror&"/2.3.5/", "Python-2.3.5.exe", "i386"),_
    Array("2.4", mirror&"/2.4/", "python-2.4.msi", "i386"),_
    Array("2.4.1", mirror&"/2.4.1/", "python-2.4.1.msi", "i386"),_
    Array("2.4.2", mirror&"/2.4.2/", "python-2.4.2.msi", "i386"),_
    Array("2.4.3", mirror&"/2.4.3/", "python-2.4.3.msi", "i386"),_
    Array("2.4.4", mirror&"/2.4.4/", "python-2.4.4.msi", "i386"),_
    Array("2.5", mirror&"/2.5/", "python-2.5.msi", "i386"),_
    Array("2.5.amd64", mirror&"/2.5/", "python-2.5.amd64.msi", "x64"),_
    Array("2.5.1", mirror&"/2.5.1/", "python-2.5.1.msi", "i386"),_
    Array("2.5.1.amd64", mirror&"/2.5.1/", "python-2.5.1.amd64.msi", "x64"),_
    Array("2.5.2", mirror&"/2.5.2/", "python-2.5.2.msi", "i386"),_
    Array("2.5.2.amd64", mirror&"/2.5.2/", "python-2.5.2.amd64.msi", "x64"),_
    Array("2.5.3", mirror&"/2.5.3/", "python-2.5.3.msi", "i386"),_
    Array("2.5.3.amd64", mirror&"/2.5.3/", "python-2.5.3.amd64.msi", "x64"),_
    Array("2.5.4", mirror&"/2.5.4/", "python-2.5.4.msi", "i386"),_
    Array("2.5.4.amd64", mirror&"/2.5.4/", "python-2.5.4.amd64.msi", "x64"),_
    Array("2.6", mirror&"/2.6/", "python-2.6.msi", "i386"),_
    Array("2.6.amd64", mirror&"/2.6/", "python-2.6.amd64.msi", "x64"),_
    Array("2.6.1", mirror&"/2.6.1/", "python-2.6.1.msi", "i386"),_
    Array("2.6.1.amd64", mirror&"/2.6.1/", "python-2.6.1.amd64.msi", "x64"),_
    Array("2.6.2", mirror&"/2.6.2/", "python-2.6.2.msi", "i386"),_
    Array("2.6.2.amd64", mirror&"/2.6.2/", "python-2.6.2.amd64.msi", "x64"),_
    Array("2.6.3", mirror&"/2.6.3/", "python-2.6.3.msi", "i386"),_
    Array("2.6.3.amd64", mirror&"/2.6.3/", "python-2.6.3.amd64.msi", "x64"),_
    Array("2.6.4", mirror&"/2.6.4/", "python-2.6.4.msi", "i386"),_
    Array("2.6.4.amd64", mirror&"/2.6.4/", "python-2.6.4.amd64.msi", "x64"),_
    Array("2.6.5", mirror&"/2.6.5/", "python-2.6.5.msi", "i386"),_
    Array("2.6.5.amd64", mirror&"/2.6.5/", "python-2.6.5.amd64.msi", "x64"),_
    Array("2.6.6", mirror&"/2.6.6/", "python-2.6.6.msi", "i386"),_
    Array("2.6.6.amd64", mirror&"/2.6.6/", "python-2.6.6.amd64.msi", "x64"),_
    Array("2.7", mirror&"/2.7/", "python-2.7.msi", "i386"),_
    Array("2.7.amd64", mirror&"/2.7/", "python-2.7.amd64.msi", "x64"),_
    Array("2.7.1", mirror&"/2.7.1/", "python-2.7.1.msi", "i386"),_
    Array("2.7.1.amd64", mirror&"/2.7.1/", "python-2.7.1.amd64.msi", "x64"),_
    Array("2.7.2", mirror&"/2.7.2/", "python-2.7.2.msi", "i386"),_
    Array("2.7.2.amd64", mirror&"/2.7.2/", "python-2.7.2.amd64.msi", "x64"),_
    Array("2.7.3", mirror&"/2.7.3/", "python-2.7.3.msi", "i386"),_
    Array("2.7.3.amd64", mirror&"/2.7.3/", "python-2.7.3.amd64.msi", "x64"),_
    Array("2.7.4", mirror&"/2.7.4/", "python-2.7.4.msi", "i386"),_
    Array("2.7.4.amd64", mirror&"/2.7.4/", "python-2.7.4.amd64.msi", "x64"),_
    Array("2.7.5", mirror&"/2.7.5/", "python-2.7.5.msi", "i386"),_
    Array("2.7.5.amd64", mirror&"/2.7.5/", "python-2.7.5.amd64.msi", "x64"),_
    Array("2.7.6", mirror&"/2.7.6/", "python-2.7.6.msi", "i386"),_
    Array("2.7.6.amd64", mirror&"/2.7.6/", "python-2.7.6.amd64.msi", "x64"),_
    Array("2.7.7rc1", mirror&"/2.7.7/", "python-2.7.7rc1.msi", "i386"),_
    Array("2.7.7rc1.amd64", mirror&"/2.7.7/", "python-2.7.7rc1.amd64.msi", "x64"),_
    Array("2.7.7", mirror&"/2.7.7/", "python-2.7.7.msi", "i386"),_
    Array("2.7.7.amd64", mirror&"/2.7.7/", "python-2.7.7.amd64.msi", "x64"),_
    Array("2.7.8", mirror&"/2.7.8/", "python-2.7.8.msi", "i386"),_
    Array("2.7.8.amd64", mirror&"/2.7.8/", "python-2.7.8.amd64.msi", "x64"),_
    Array("2.7.9rc1", mirror&"/2.7.9/", "python-2.7.9rc1.msi", "i386"),_
    Array("2.7.9rc1.amd64", mirror&"/2.7.9/", "python-2.7.9rc1.amd64.msi", "x64"),_
    Array("2.7.9", mirror&"/2.7.9/", "python-2.7.9.msi", "i386"),_
    Array("2.7.9.amd64", mirror&"/2.7.9/", "python-2.7.9.amd64.msi", "x64"),_
    Array("2.7.10rc1", mirror&"/2.7.10/", "python-2.7.10rc1.msi", "i386"),_
    Array("2.7.10rc1.amd64", mirror&"/2.7.10/", "python-2.7.10rc1.amd64.msi", "x64"),_
    Array("2.7.10", mirror&"/2.7.10/", "python-2.7.10.msi", "i386"),_
    Array("2.7.10.amd64", mirror&"/2.7.10/", "python-2.7.10.amd64.msi", "x64"),_
    Array("2.7.11rc1", mirror&"/2.7.11/", "python-2.7.11rc1.msi", "i386"),_
    Array("2.7.11rc1.amd64", mirror&"/2.7.11/", "python-2.7.11rc1.amd64.msi", "x64"),_
    Array("2.7.11", mirror&"/2.7.11/", "python-2.7.11.msi", "i386"),_
    Array("2.7.11.amd64", mirror&"/2.7.11/", "python-2.7.11.amd64.msi", "x64"),_
    Array("2.7.12rc1", mirror&"/2.7.12/", "python-2.7.12rc1.msi", "i386"),_
    Array("2.7.12rc1.amd64", mirror&"/2.7.12/", "python-2.7.12rc1.amd64.msi", "x64"),_
    Array("2.7.12", mirror&"/2.7.12/", "python-2.7.12.msi", "i386"),_
    Array("2.7.12.amd64", mirror&"/2.7.12/", "python-2.7.12.amd64.msi", "x64"),_
    Array("2.7.13rc1", mirror&"/2.7.13/", "python-2.7.13rc1.msi", "i386"),_
    Array("2.7.13rc1.amd64", mirror&"/2.7.13/", "python-2.7.13rc1.amd64.msi", "x64"),_
    Array("2.7.13", mirror&"/2.7.13/", "python-2.7.13.msi", "i386"),_
    Array("2.7.13.amd64", mirror&"/2.7.13/", "python-2.7.13.amd64.msi", "x64"),_
    Array("2.7.14rc1", mirror&"/2.7.14/", "python-2.7.14rc1.msi", "i386"),_
    Array("2.7.14rc1.amd64", mirror&"/2.7.14/", "python-2.7.14rc1.amd64.msi", "x64"),_
    Array("2.7.14", mirror&"/2.7.14/", "python-2.7.14.msi", "i386"),_
    Array("2.7.14.amd64", mirror&"/2.7.14/", "python-2.7.14.amd64.msi", "x64"),_
    Array("2.7.15rc1", mirror&"/2.7.15/", "python-2.7.15rc1.msi", "i386"),_
    Array("2.7.15rc1.amd64", mirror&"/2.7.15/", "python-2.7.15rc1.amd64.msi", "x64"),_
    Array("2.7.15", mirror&"/2.7.15/", "python-2.7.15.msi", "i386"),_
    Array("2.7.15.amd64", mirror&"/2.7.15/", "python-2.7.15.amd64.msi", "x64"),_
    Array("2.7.16", mirror&"/2.7.16/", "python-2.7.16.msi", "i386"),_
    Array("2.7.16.amd64", mirror&"/2.7.16/", "python-2.7.16.amd64.msi", "x64"),_
    Array("2.7.17", mirror&"/2.7.17/", "python-2.7.17.msi", "i386"),_
    Array("2.7.17.amd64", mirror&"/2.7.17/", "python-2.7.17.amd64.msi", "x64"),_
    Array("3.0", mirror&"/3.0/", "python-3.0.msi", "i386"),_
    Array("3.0.amd64", mirror&"/3.0/", "python-3.0.amd64.msi", "x64"),_
    Array("3.0.1", mirror&"/3.0.1/", "python-3.0.1.msi", "i386"),_
    Array("3.0.1.amd64", mirror&"/3.0.1/", "python-3.0.1.amd64.msi", "x64"),_
    Array("3.1", mirror&"/3.1/", "python-3.1.msi", "i386"),_
    Array("3.1.amd64", mirror&"/3.1/", "python-3.1.amd64.msi", "x64"),_
    Array("3.1.1", mirror&"/3.1.1/", "python-3.1.1.msi", "i386"),_
    Array("3.1.1.amd64", mirror&"/3.1.1/", "python-3.1.1.amd64.msi", "x64"),_
    Array("3.1.2", mirror&"/3.1.2/", "python-3.1.2.msi", "i386"),_
    Array("3.1.2.amd64", mirror&"/3.1.2/", "python-3.1.2.amd64.msi", "x64"),_
    Array("3.1.3", mirror&"/3.1.3/", "python-3.1.3.msi", "i386"),_
    Array("3.1.3.amd64", mirror&"/3.1.3/", "python-3.1.3.amd64.msi", "x64"),_
    Array("3.1.4", mirror&"/3.1.4/", "python-3.1.4.msi", "i386"),_
    Array("3.1.4.amd64", mirror&"/3.1.4/", "python-3.1.4.amd64.msi", "x64"),_
    Array("3.2", mirror&"/3.2/", "python-3.2.msi", "i386"),_
    Array("3.2.amd64", mirror&"/3.2/", "python-3.2.amd64.msi", "x64"),_
    Array("3.2.1", mirror&"/3.2.1/", "python-3.2.1.msi", "i386"),_
    Array("3.2.1.amd64", mirror&"/3.2.1/", "python-3.2.1.amd64.msi", "x64"),_
    Array("3.2.2", mirror&"/3.2.2/", "python-3.2.2.msi", "i386"),_
    Array("3.2.2.amd64", mirror&"/3.2.2/", "python-3.2.2.amd64.msi", "x64"),_
    Array("3.2.3", mirror&"/3.2.3/", "python-3.2.3.msi", "i386"),_
    Array("3.2.3.amd64", mirror&"/3.2.3/", "python-3.2.3.amd64.msi", "x64"),_
    Array("3.2.4", mirror&"/3.2.4/", "python-3.2.4.msi", "i386"),_
    Array("3.2.4.amd64", mirror&"/3.2.4/", "python-3.2.4.amd64.msi", "x64"),_
    Array("3.2.5", mirror&"/3.2.5/", "python-3.2.5.msi", "i386"),_
    Array("3.2.5.amd64", mirror&"/3.2.5/", "python-3.2.5.amd64.msi", "x64"),_
    Array("3.3.0", mirror&"/3.3.0/", "python-3.3.0.msi", "i386"),_
    Array("3.3.0.amd64", mirror&"/3.3.0/", "python-3.3.0.amd64.msi", "x64"),_
    Array("3.3.1", mirror&"/3.3.1/", "python-3.3.1.msi", "i386"),_
    Array("3.3.1.amd64", mirror&"/3.3.1/", "python-3.3.1.amd64.msi", "x64"),_
    Array("3.3.2", mirror&"/3.3.2/", "python-3.3.2.msi", "i386"),_
    Array("3.3.2.amd64", mirror&"/3.3.2/", "python-3.3.2.amd64.msi", "x64"),_
    Array("3.3.3", mirror&"/3.3.3/", "python-3.3.3.msi", "i386"),_
    Array("3.3.3.amd64", mirror&"/3.3.3/", "python-3.3.3.amd64.msi", "x64"),_
    Array("3.3.4", mirror&"/3.3.4/", "python-3.3.4.msi", "i386"),_
    Array("3.3.4.amd64", mirror&"/3.3.4/", "python-3.3.4.amd64.msi", "x64"),_
    Array("3.3.5rc1", mirror&"/3.3.5/", "python-3.3.5rc1.msi", "i386"),_
    Array("3.3.5rc1.amd64", mirror&"/3.3.5/", "python-3.3.5rc1.amd64.msi", "x64"),_
    Array("3.3.5rc2", mirror&"/3.3.5/", "python-3.3.5rc2.msi", "i386"),_
    Array("3.3.5rc2.amd64", mirror&"/3.3.5/", "python-3.3.5rc2.amd64.msi", "x64"),_
    Array("3.3.5", mirror&"/3.3.5/", "python-3.3.5.msi", "i386"),_
    Array("3.3.5.amd64", mirror&"/3.3.5/", "python-3.3.5.amd64.msi", "x64"),_
    Array("3.4.0rc3", mirror&"/3.4.0/", "python-3.4.0rc3.msi", "i386"),_
    Array("3.4.0rc3.amd64", mirror&"/3.4.0/", "python-3.4.0rc3.amd64.msi", "x64"),_
    Array("3.4.0", mirror&"/3.4.0/", "python-3.4.0.msi", "i386"),_
    Array("3.4.0.amd64", mirror&"/3.4.0/", "python-3.4.0.amd64.msi", "x64"),_
    Array("3.4.1rc1", mirror&"/3.4.1/", "python-3.4.1rc1.msi", "i386"),_
    Array("3.4.1rc1.amd64", mirror&"/3.4.1/", "python-3.4.1rc1.amd64.msi", "x64"),_
    Array("3.4.1", mirror&"/3.4.1/", "python-3.4.1.msi", "i386"),_
    Array("3.4.1.amd64", mirror&"/3.4.1/", "python-3.4.1.amd64.msi", "x64"),_
    Array("3.4.2rc1", mirror&"/3.4.2/", "python-3.4.2rc1.msi", "i386"),_
    Array("3.4.2rc1.amd64", mirror&"/3.4.2/", "python-3.4.2rc1.amd64.msi", "x64"),_
    Array("3.4.2", mirror&"/3.4.2/", "python-3.4.2.msi", "i386"),_
    Array("3.4.2.amd64", mirror&"/3.4.2/", "python-3.4.2.amd64.msi", "x64"),_
    Array("3.4.3rc1", mirror&"/3.4.3/", "python-3.4.3rc1.msi", "i386"),_
    Array("3.4.3rc1.amd64", mirror&"/3.4.3/", "python-3.4.3rc1.amd64.msi", "x64"),_
    Array("3.4.3", mirror&"/3.4.3/", "python-3.4.3.msi", "i386"),_
    Array("3.4.3.amd64", mirror&"/3.4.3/", "python-3.4.3.amd64.msi", "x64"),_
    Array("3.4.4rc1", mirror&"/3.4.4/", "python-3.4.4rc1.msi", "i386"),_
    Array("3.4.4rc1.amd64", mirror&"/3.4.4/", "python-3.4.4rc1.amd64.msi", "x64"),_
    Array("3.4.4", mirror&"/3.4.4/", "python-3.4.4.msi", "i386"),_
    Array("3.4.4.amd64", mirror&"/3.4.4/", "python-3.4.4.amd64.msi", "x64"),_
    Array("3.5.0a1", mirror&"/3.5.0/", "python-3.5.0a1.exe", "i386"),_
    Array("3.5.0a1-amd64", mirror&"/3.5.0/", "python-3.5.0a1-amd64.exe", "x64"),_
    Array("3.5.0a2", mirror&"/3.5.0/", "python-3.5.0a2.exe", "i386"),_
    Array("3.5.0a2-amd64", mirror&"/3.5.0/", "python-3.5.0a2-amd64.exe", "x64"),_
    Array("3.5.0a3", mirror&"/3.5.0/", "python-3.5.0a3.exe", "i386"),_
    Array("3.5.0a3-amd64", mirror&"/3.5.0/", "python-3.5.0a3-amd64.exe", "x64"),_
    Array("3.5.0a4", mirror&"/3.5.0/", "python-3.5.0a4.exe", "i386"),_
    Array("3.5.0a4-amd64", mirror&"/3.5.0/", "python-3.5.0a4-amd64.exe", "x64"),_
    Array("3.5.0b1", mirror&"/3.5.0/", "python-3.5.0b1.exe", "i386"),_
    Array("3.5.0b1-amd64", mirror&"/3.5.0/", "python-3.5.0b1-amd64.exe", "x64"),_
    Array("3.5.0b2", mirror&"/3.5.0/", "python-3.5.0b2.exe", "i386"),_
    Array("3.5.0b2-amd64", mirror&"/3.5.0/", "python-3.5.0b2-amd64.exe", "x64"),_
    Array("3.5.0b3", mirror&"/3.5.0/", "python-3.5.0b3.exe", "i386"),_
    Array("3.5.0b3-amd64", mirror&"/3.5.0/", "python-3.5.0b3-amd64.exe", "x64"),_
    Array("3.5.0b4", mirror&"/3.5.0/", "python-3.5.0b4.exe", "i386"),_
    Array("3.5.0b4-amd64", mirror&"/3.5.0/", "python-3.5.0b4-amd64.exe", "x64"),_
    Array("3.5.0rc1", mirror&"/3.5.0/", "python-3.5.0rc1.exe", "i386"),_
    Array("3.5.0rc1-amd64", mirror&"/3.5.0/", "python-3.5.0rc1-amd64.exe", "x64"),_
    Array("3.5.0rc2", mirror&"/3.5.0/", "python-3.5.0rc2.exe", "i386"),_
    Array("3.5.0rc2-amd64", mirror&"/3.5.0/", "python-3.5.0rc2-amd64.exe", "x64"),_
    Array("3.5.0rc3", mirror&"/3.5.0/", "python-3.5.0rc3.exe", "i386"),_
    Array("3.5.0rc3-amd64", mirror&"/3.5.0/", "python-3.5.0rc3-amd64.exe", "x64"),_
    Array("3.5.0rc4", mirror&"/3.5.0/", "python-3.5.0rc4.exe", "i386"),_
    Array("3.5.0rc4-amd64", mirror&"/3.5.0/", "python-3.5.0rc4-amd64.exe", "x64"),_
    Array("3.5.0", mirror&"/3.5.0/", "python-3.5.0.exe", "i386"),_
    Array("3.5.0-amd64", mirror&"/3.5.0/", "python-3.5.0-amd64.exe", "x64"),_
    Array("3.5.1rc1", mirror&"/3.5.1/", "python-3.5.1rc1.exe", "i386"),_
    Array("3.5.1rc1-amd64", mirror&"/3.5.1/", "python-3.5.1rc1-amd64.exe", "x64"),_
    Array("3.5.1", mirror&"/3.5.1/", "python-3.5.1.exe", "i386"),_
    Array("3.5.1-amd64", mirror&"/3.5.1/", "python-3.5.1-amd64.exe", "x64"),_
    Array("3.5.2rc1", mirror&"/3.5.2/", "python-3.5.2rc1.exe", "i386"),_
    Array("3.5.2rc1-amd64", mirror&"/3.5.2/", "python-3.5.2rc1-amd64.exe", "x64"),_
    Array("3.5.2", mirror&"/3.5.2/", "python-3.5.2.exe", "i386"),_
    Array("3.5.2-amd64", mirror&"/3.5.2/", "python-3.5.2-amd64.exe", "x64"),_
    Array("3.5.3rc1", mirror&"/3.5.3/", "python-3.5.3rc1.exe", "i386"),_
    Array("3.5.3rc1-amd64", mirror&"/3.5.3/", "python-3.5.3rc1-amd64.exe", "x64"),_
    Array("3.5.3", mirror&"/3.5.3/", "python-3.5.3.exe", "i386"),_
    Array("3.5.3-amd64", mirror&"/3.5.3/", "python-3.5.3-amd64.exe", "x64"),_
    Array("3.5.4rc1", mirror&"/3.5.4/", "python-3.5.4rc1.exe", "i386"),_
    Array("3.5.4rc1-amd64", mirror&"/3.5.4/", "python-3.5.4rc1-amd64.exe", "x64"),_
    Array("3.5.4", mirror&"/3.5.4/", "python-3.5.4.exe", "i386"),_
    Array("3.5.4-amd64", mirror&"/3.5.4/", "python-3.5.4-amd64.exe", "x64"),_
    Array("3.6.0a1", mirror&"/3.6.0/", "python-3.6.0a1.exe", "i386"),_
    Array("3.6.0a1-amd64", mirror&"/3.6.0/", "python-3.6.0a1-amd64.exe", "x64"),_
    Array("3.6.0a2", mirror&"/3.6.0/", "python-3.6.0a2.exe", "i386"),_
    Array("3.6.0a2-amd64", mirror&"/3.6.0/", "python-3.6.0a2-amd64.exe", "x64"),_
    Array("3.6.0a3", mirror&"/3.6.0/", "python-3.6.0a3.exe", "i386"),_
    Array("3.6.0a3-amd64", mirror&"/3.6.0/", "python-3.6.0a3-amd64.exe", "x64"),_
    Array("3.6.0a4", mirror&"/3.6.0/", "python-3.6.0a4.exe", "i386"),_
    Array("3.6.0a4-amd64", mirror&"/3.6.0/", "python-3.6.0a4-amd64.exe", "x64"),_
    Array("3.6.0b1", mirror&"/3.6.0/", "python-3.6.0b1.exe", "i386"),_
    Array("3.6.0b1-amd64", mirror&"/3.6.0/", "python-3.6.0b1-amd64.exe", "x64"),_
    Array("3.6.0b2", mirror&"/3.6.0/", "python-3.6.0b2.exe", "i386"),_
    Array("3.6.0b2-amd64", mirror&"/3.6.0/", "python-3.6.0b2-amd64.exe", "x64"),_
    Array("3.6.0b3", mirror&"/3.6.0/", "python-3.6.0b3.exe", "i386"),_
    Array("3.6.0b3-amd64", mirror&"/3.6.0/", "python-3.6.0b3-amd64.exe", "x64"),_
    Array("3.6.0b4", mirror&"/3.6.0/", "python-3.6.0b4.exe", "i386"),_
    Array("3.6.0b4-amd64", mirror&"/3.6.0/", "python-3.6.0b4-amd64.exe", "x64"),_
    Array("3.6.0rc1", mirror&"/3.6.0/", "python-3.6.0rc1.exe", "i386"),_
    Array("3.6.0rc1-amd64", mirror&"/3.6.0/", "python-3.6.0rc1-amd64.exe", "x64"),_
    Array("3.6.0rc2", mirror&"/3.6.0/", "python-3.6.0rc2.exe", "i386"),_
    Array("3.6.0rc2-amd64", mirror&"/3.6.0/", "python-3.6.0rc2-amd64.exe", "x64"),_
    Array("3.6.0", mirror&"/3.6.0/", "python-3.6.0.exe", "i386"),_
    Array("3.6.0-amd64", mirror&"/3.6.0/", "python-3.6.0-amd64.exe", "x64"),_
    Array("3.6.1rc1", mirror&"/3.6.1/", "python-3.6.1rc1.exe", "i386"),_
    Array("3.6.1rc1-amd64", mirror&"/3.6.1/", "python-3.6.1rc1-amd64.exe", "x64"),_
    Array("3.6.1", mirror&"/3.6.1/", "python-3.6.1.exe", "i386"),_
    Array("3.6.1-amd64", mirror&"/3.6.1/", "python-3.6.1-amd64.exe", "x64"),_
    Array("3.6.2rc1", mirror&"/3.6.2/", "python-3.6.2rc1.exe", "i386"),_
    Array("3.6.2rc1-amd64", mirror&"/3.6.2/", "python-3.6.2rc1-amd64.exe", "x64"),_
    Array("3.6.2rc2", mirror&"/3.6.2/", "python-3.6.2rc2.exe", "i386"),_
    Array("3.6.2rc2-amd64", mirror&"/3.6.2/", "python-3.6.2rc2-amd64.exe", "x64"),_
    Array("3.6.2", mirror&"/3.6.2/", "python-3.6.2.exe", "i386"),_
    Array("3.6.2-amd64", mirror&"/3.6.2/", "python-3.6.2-amd64.exe", "x64"),_
    Array("3.6.3rc1", mirror&"/3.6.3/", "python-3.6.3rc1.exe", "i386"),_
    Array("3.6.3rc1-amd64", mirror&"/3.6.3/", "python-3.6.3rc1-amd64.exe", "x64"),_
    Array("3.6.3", mirror&"/3.6.3/", "python-3.6.3.exe", "i386"),_
    Array("3.6.3-amd64", mirror&"/3.6.3/", "python-3.6.3-amd64.exe", "x64"),_
    Array("3.6.4rc1", mirror&"/3.6.4/", "python-3.6.4rc1.exe", "i386"),_
    Array("3.6.4rc1-amd64", mirror&"/3.6.4/", "python-3.6.4rc1-amd64.exe", "x64"),_
    Array("3.6.4", mirror&"/3.6.4/", "python-3.6.4.exe", "i386"),_
    Array("3.6.4-amd64", mirror&"/3.6.4/", "python-3.6.4-amd64.exe", "x64"),_
    Array("3.6.5rc1", mirror&"/3.6.5/", "python-3.6.5rc1.exe", "i386"),_
    Array("3.6.5rc1-amd64", mirror&"/3.6.5/", "python-3.6.5rc1-amd64.exe", "x64"),_
    Array("3.6.5", mirror&"/3.6.5/", "python-3.6.5.exe", "i386"),_
    Array("3.6.5-amd64", mirror&"/3.6.5/", "python-3.6.5-amd64.exe", "x64"),_
    Array("3.6.6rc1", mirror&"/3.6.6/", "python-3.6.6rc1.exe", "i386"),_
    Array("3.6.6rc1-amd64", mirror&"/3.6.6/", "python-3.6.6rc1-amd64.exe", "x64"),_
    Array("3.6.6", mirror&"/3.6.6/", "python-3.6.6.exe", "i386"),_
    Array("3.6.6-amd64", mirror&"/3.6.6/", "python-3.6.6-amd64.exe", "x64"),_
    Array("3.6.7rc1", mirror&"/3.6.7/", "python-3.6.7rc1.exe", "i386"),_
    Array("3.6.7rc1-amd64", mirror&"/3.6.7/", "python-3.6.7rc1-amd64.exe", "x64"),_
    Array("3.6.7rc2", mirror&"/3.6.7/", "python-3.6.7rc2.exe", "i386"),_
    Array("3.6.7rc2-amd64", mirror&"/3.6.7/", "python-3.6.7rc2-amd64.exe", "x64"),_
    Array("3.6.7", mirror&"/3.6.7/", "python-3.6.7.exe", "i386"),_
    Array("3.6.7-amd64", mirror&"/3.6.7/", "python-3.6.7-amd64.exe", "x64"),_
    Array("3.6.8rc1", mirror&"/3.6.8/", "python-3.6.8rc1.exe", "i386"),_
    Array("3.6.8rc1-amd64", mirror&"/3.6.8/", "python-3.6.8rc1-amd64.exe", "x64"),_
    Array("3.6.8", mirror&"/3.6.8/", "python-3.6.8.exe", "i386"),_
    Array("3.6.8-amd64", mirror&"/3.6.8/", "python-3.6.8-amd64.exe", "x64"),_
    Array("3.6.9", mirror&"/3.6.9/", "python-3.6.9.exe", "i386"),_
    Array("3.6.9-amd64", mirror&"/3.6.9/", "python-3.6.9-amd64.exe", "x64"),_
    Array("3.6.10", mirror&"/3.6.10/", "python-3.6.10.exe", "i386"),_
    Array("3.6.10-amd64", mirror&"/3.6.10/", "python-3.6.10-amd64.exe", "x64"),_
    Array("3.7.0a1", mirror&"/3.7.0/", "python-3.7.0a1.exe", "i386"),_
    Array("3.7.0a1-amd64", mirror&"/3.7.0/", "python-3.7.0a1-amd64.exe", "x64"),_
    Array("3.7.0a2", mirror&"/3.7.0/", "python-3.7.0a2.exe", "i386"),_
    Array("3.7.0a2-amd64", mirror&"/3.7.0/", "python-3.7.0a2-amd64.exe", "x64"),_
    Array("3.7.0a3", mirror&"/3.7.0/", "python-3.7.0a3.exe", "i386"),_
    Array("3.7.0a3-amd64", mirror&"/3.7.0/", "python-3.7.0a3-amd64.exe", "x64"),_
    Array("3.7.0a4", mirror&"/3.7.0/", "python-3.7.0a4.exe", "i386"),_
    Array("3.7.0a4-amd64", mirror&"/3.7.0/", "python-3.7.0a4-amd64.exe", "x64"),_
    Array("3.7.0b1", mirror&"/3.7.0/", "python-3.7.0b1.exe", "i386"),_
    Array("3.7.0b1-amd64", mirror&"/3.7.0/", "python-3.7.0b1-amd64.exe", "x64"),_
    Array("3.7.0b2", mirror&"/3.7.0/", "python-3.7.0b2.exe", "i386"),_
    Array("3.7.0b2-amd64", mirror&"/3.7.0/", "python-3.7.0b2-amd64.exe", "x64"),_
    Array("3.7.0b3", mirror&"/3.7.0/", "python-3.7.0b3.exe", "i386"),_
    Array("3.7.0b3-amd64", mirror&"/3.7.0/", "python-3.7.0b3-amd64.exe", "x64"),_
    Array("3.7.0b4", mirror&"/3.7.0/", "python-3.7.0b4.exe", "i386"),_
    Array("3.7.0b4-amd64", mirror&"/3.7.0/", "python-3.7.0b4-amd64.exe", "x64"),_
    Array("3.7.0b5", mirror&"/3.7.0/", "python-3.7.0b5.exe", "i386"),_
    Array("3.7.0b5-amd64", mirror&"/3.7.0/", "python-3.7.0b5-amd64.exe", "x64"),_
    Array("3.7.0rc1", mirror&"/3.7.0/", "python-3.7.0rc1.exe", "i386"),_
    Array("3.7.0rc1-amd64", mirror&"/3.7.0/", "python-3.7.0rc1-amd64.exe", "x64"),_
    Array("3.7.0", mirror&"/3.7.0/", "python-3.7.0.exe", "i386"),_
    Array("3.7.0-amd64", mirror&"/3.7.0/", "python-3.7.0-amd64.exe", "x64"),_
    Array("3.7.1rc1", mirror&"/3.7.1/", "python-3.7.1rc1.exe", "i386"),_
    Array("3.7.1rc1-amd64", mirror&"/3.7.1/", "python-3.7.1rc1-amd64.exe", "x64"),_
    Array("3.7.1rc2", mirror&"/3.7.1/", "python-3.7.1rc2.exe", "i386"),_
    Array("3.7.1rc2-amd64", mirror&"/3.7.1/", "python-3.7.1rc2-amd64.exe", "x64"),_
    Array("3.7.1", mirror&"/3.7.1/", "python-3.7.1.exe", "i386"),_
    Array("3.7.1-amd64", mirror&"/3.7.1/", "python-3.7.1-amd64.exe", "x64"),_
    Array("3.7.2rc1", mirror&"/3.7.2/", "python-3.7.2rc1.exe", "i386"),_
    Array("3.7.2rc1-amd64", mirror&"/3.7.2/", "python-3.7.2rc1-amd64.exe", "x64"),_
    Array("3.7.2", mirror&"/3.7.2/", "python-3.7.2.exe", "i386"),_
    Array("3.7.2-amd64", mirror&"/3.7.2/", "python-3.7.2-amd64.exe", "x64"),_
    Array("3.7.3", mirror&"/3.7.3/", "python-3.7.3.exe", "i386"),_
    Array("3.7.3-amd64", mirror&"/3.7.3/", "python-3.7.3-amd64.exe", "x64"),_
    Array("3.7.4", mirror&"/3.7.4/", "python-3.7.4.exe", "i386"),_
    Array("3.7.4-amd64", mirror&"/3.7.4/", "python-3.7.4-amd64.exe", "x64"),_
    Array("3.7.5", mirror&"/3.7.5/", "python-3.7.5.exe", "i386"),_
    Array("3.7.5-amd64", mirror&"/3.7.5/", "python-3.7.5-amd64.exe", "x64"),_
    Array("3.7.6", mirror&"/3.7.6/", "python-3.7.6.exe", "i386"),_
    Array("3.7.6-amd64", mirror&"/3.7.6/", "python-3.7.6-amd64.exe", "x64"),_
    Array("3.8.0a1", mirror&"/3.8.0/", "python-3.8.0a1.exe", "i386"),_
    Array("3.8.0a1-amd64", mirror&"/3.8.0/", "python-3.8.0a1-amd64.exe", "x64"),_
    Array("3.8.0a2", mirror&"/3.8.0/", "python-3.8.0a2.exe", "i386"),_
    Array("3.8.0a2-amd64", mirror&"/3.8.0/", "python-3.8.0a2-amd64.exe", "x64"),_
    Array("3.8.0a3", mirror&"/3.8.0/", "python-3.8.0a3.exe", "i386"),_
    Array("3.8.0a3-amd64", mirror&"/3.8.0/", "python-3.8.0a3-amd64.exe", "x64"),_
    Array("3.8.0a4", mirror&"/3.8.0/", "python-3.8.0a4.exe", "i386"),_
    Array("3.8.0a4-amd64", mirror&"/3.8.0/", "python-3.8.0a4-amd64.exe", "x64"),_
    Array("3.8.0b1", mirror&"/3.8.0/", "python-3.8.0b1.exe", "i386"),_
    Array("3.8.0b1-amd64", mirror&"/3.8.0/", "python-3.8.0b1-amd64.exe", "x64"),_
    Array("3.8.0b2", mirror&"/3.8.0/", "python-3.8.0b2.exe", "i386"),_
    Array("3.8.0b2-amd64", mirror&"/3.8.0/", "python-3.8.0b2-amd64.exe", "x64"),_
    Array("3.8.0b3", mirror&"/3.8.0/", "python-3.8.0b3.exe", "i386"),_
    Array("3.8.0b3-amd64", mirror&"/3.8.0/", "python-3.8.0b3-amd64.exe", "x64"),_
    Array("3.8.0b4", mirror&"/3.8.0/", "python-3.8.0b4.exe", "i386"),_
    Array("3.8.0b4-amd64", mirror&"/3.8.0/", "python-3.8.0b4-amd64.exe", "x64"),_
    Array("3.8.0rc1", mirror&"/3.8.0/", "python-3.8.0rc1.exe", "i386"),_
    Array("3.8.0rc1-amd64", mirror&"/3.8.0/", "python-3.8.0rc1-amd64.exe", "x64"),_
    Array("3.8.0", mirror&"/3.8.0/", "python-3.8.0.exe", "i386"),_
    Array("3.8.0-amd64", mirror&"/3.8.0/", "python-3.8.0-amd64.exe", "x64"),_
    Array("3.8.1", mirror&"/3.8.1/", "python-3.8.1.exe", "i386"),_
    Array("3.8.1-amd64", mirror&"/3.8.1/", "python-3.8.1-amd64.exe", "x64")_
)

Sub download(cur)
    WScript.Echo ":: [Downloading] ::  " & cur(0) & " ..."
    WScript.Echo ":: [Downloading] ::  From " & cur(3)
    WScript.Echo ":: [Downloading] ::  To   " & cur(2)
    DownloadFile cur(3), cur(2)
End Sub

Sub extract(cur)
    If Not objfs.FolderExists(strDirCache) Then objfs.CreateFolder(strDirCache)
    If Not objfs.FolderExists(strDirVers) Then objfs.CreateFolder(strDirVers)

    If objfs.FolderExists(cur(1)) Then Exit Sub

    If Not objfs.FileExists(cur(2)) Then download(cur)

    WScript.Echo ":: [Installing] ::  "& cur(0) &" ..."

    objws.CurrentDirectory = strDirCache
    Dim exe_file
    Dim target_location
    exe_file = """"& cur(2) &""""
    target_location = """"& cur(1) &""""
    If cur(5) Then
        objws.Run exe_file &" /quiet InstallAllUsers=0 Include_launcher=0 Include_test=0 SimpleInstall=1 TargetDir="& target_location, 0, True
    Else
        objws.Run exe_file &" InstallAllUsers=0 Include_launcher=0 Include_test=0 SimpleInstall=1 TargetDir="& target_location, 0, True
    End If

    If objfs.FolderExists(cur(1)) Then
        objws.Run "pyenv rehash "& cur(0), 0, False
        WScript.Echo ":: [Info] :: completed! "& cur(0)
    Else
        WScript.Echo ":: [Error] :: couldn't install .. "& cur(0)
    End If
End Sub

Sub main(arg)
    If arg.Count = 0 Then ShowHelp

    Dim idx
    Dim optForce
    Dim optSkip
    Dim optList
    Dim optQuiet
    Dim version

    optForce = False
    optSkip = False
    optList = False
    optQuiet = False
    version = ""

    For idx = 0 To arg.Count - 1
        Select Case arg(idx)
            Case "--help"          ShowHelp
            Case "-l"              optList = True
            Case "--list"          optList = True
            Case "-f"              optForce = True
            Case "--force"         optForce = True
            Case "-s"              optSkip = True
            Case "--skip-existing" optSkip = True
            Case "-q"              optQuiet = True
            Case "--quiet"         optQuiet = True
            Case Else
                version = arg(idx)
                Exit For
        End Select
    Next

    If version = "" Then
        Dim ary
        ary = GetCurrentVersionNoError()
        If Not IsNull(ary) Then version = ary(0)
    End If

    Dim list
    Dim cur
    If optList Then
        For Each list In listEnv
            WScript.Echo list(0)
        Next
        Exit Sub
    ElseIf version <> "" Then
        For Each list In listEnv
            If list(0) = version Then
                cur = Array( _
                    list(0), _
                    strDirVers &"\"& list(0), _
                    strDirCache &"\"& list(2), _
                    list(1) & list(2), _
                    list(3), _
                    optQuiet _
                )
                If optForce Then clear(cur)
                extract(cur)
                Exit Sub
            End If
        Next
        WScript.Echo "pyenv-install: definition not found: "& version
        WScript.Echo
        WScript.Echo "See all available versions with `pyenv install --list'."
    Else
        ShowHelp
    End If
End Sub

main(WScript.Arguments)
