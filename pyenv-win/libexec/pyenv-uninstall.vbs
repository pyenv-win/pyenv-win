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

WScript.Echo ":: [Info] ::  Mirror: "& mirror

Sub ShowHelp()
    WScript.Echo "Usage: pyenv uninstall [-f|--force|--msi] <version>"
    WScript.Echo "       pyenv uninstall [-f|--force] [-a|--all]"
    WScript.Echo ""
    WScript.Echo "   -f/--force  Attempt to remove the specified version without prompting"
    WScript.Echo "               for confirmation. If the version does not exist, do not"
    WScript.Echo "               display an error message."
    WScript.Echo ""
    WScript.Echo "   -a/--all    *Caution* Attempt to remove all installed versions."
    WScript.Echo ""
    WScript.Echo "See `pyenv versions` for a complete list of installed versions."
    WScript.Echo ""
    WScript.Quit
End Sub

Sub main(arg)
    If arg.Count = 0 Then ShowHelp

    Dim idx
    Dim optForce
    Dim version
    Dim optAll

    optForce = False
    optAll = False
    version = ""

    For idx = 0 To arg.Count - 1
        Select Case arg(idx)
           Case "--help"  ShowHelp
           Case "-f"      optForce = True
           Case "--force" optForce = True
           Case "-a"      optAll = True
           Case "--all"   optAll = True
           Case Else
               version = arg(idx)
               Exit For
        End Select
    Next

    Dim uninstallPath
    Dim folder
    Dim confirm
    uninstallPath = strDirVers &"\"& version

    On Error Resume Next
    If optAll Then
        If objfs.GetFolder(strDirVers).SubFolders.Count = 0 Then
            WScript.Echo "pyenv: No versions of python installed."
            WScript.Quit
        End If

        ' Confirm "uninstall all", if not forced.
        If optForce Then
            confirm = "y"
        Else
            confirm = "maybe"
            Do While confirm <> "n" And confirm <> "y"
                WScript.StdOut.Write "pyenv: Confirm uninstall all? (Y/N): "
                confirm = LCase(Left(Trim(WScript.StdIn.ReadLine), 1))
                If Len(confirm) = 0 Then WScript.Quit
            Loop
        End If

        If confirm = "y" Then
            For Each folder In objfs.GetFolder(strDirVers).SubFolders
                WScript.StdOut.Write "pyenv: Uninstalling version """& folder.Name &"""... "
                folder.Delete optForce
                If Err.Number <> 0 Then
                    WScript.StdOut.WriteLine "Error ("& Err.Number &"): "& Err.Description
                    Err.Clear
                Else
                    WScript.StdOut.WriteLine "Done."
                End If
            Next
        End If
    ElseIf IsVersion(version) And objfs.FolderExists(uninstallPath) Then
        objfs.DeleteFolder params(uninstallPath), optForce
        If Err.Number <> 0 Then
            WScript.Echo "pyenv: Error ("& Err.Number &") uninstalling version "& folder.Name &": "& Err.Description
        Else
            WScript.Echo "pyenv: Successfully uninstalled "& folder.Name
        End If
    Else
      WScript.Echo "pyenv: version '"& version &"' not installed"
    End If

End Sub

main(WScript.Arguments)
