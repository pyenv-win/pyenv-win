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

Import "libs\pyenv-lib.vbs"

Sub ShowHelp()
    WScript.Echo "Usage: pyenv uninstall [-f|--force] <version> [<version> ...]"
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
    Dim optAll
    Dim uninstallVersions

    optForce = False
    optAll = False
    Set uninstallVersions = CreateObject("Scripting.Dictionary")

    For idx = 0 To arg.Count - 1
        Select Case arg(idx)
            Case "--help"  ShowHelp
            Case "-f"      optForce = True
            Case "--force" optForce = True
            Case "-a"      optAll = True
            Case "--all"   optAll = True
            Case Else
                If Not IsVersion(arg(idx)) Then
                    WScript.Echo "pyenv: Unrecognized python version: "& arg(idx)
                    WScript.Quit 1
                End If
                uninstallVersions.Item(arg(idx)) = Empty
        End Select
    Next

    If objfs.GetFolder(strDirVers).SubFolders.Count = 0 Then
        WScript.Echo "pyenv: No valid versions of python installed."
        WScript.Quit
    End If

    Dim folder
    Dim confirm
    Dim delError
    delError = 0

    On Error Resume Next
    If optAll Then
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
                If IsVersion(folder.Name) Then
                    WScript.StdOut.Write "pyenv: Uninstalling version """& folder.Name &"""... "
                    folder.Delete optForce
                    If Err.Number <> 0 Then
                        WScript.StdOut.WriteLine "Error ("& Err.Number &"): "& Err.Description
                        Err.Clear
                        delError = 1
                    Else
                        WScript.StdOut.WriteLine "Done."
                    End If
                End If
            Next
            If Not CBool(delError) Then Rehash
        End If
    ElseIf uninstallVersions.Count > 0 Then
        Dim uninstallPath
        For Each folder In uninstallVersions.Keys
            uninstallPath = strDirVers &"\"& folder
            If IsVersion(folder) And objfs.FolderExists(uninstallPath) Then
                objfs.DeleteFolder uninstallPath, optForce
                If Err.Number <> 0 Then
                    WScript.Echo "pyenv: Error ("& Err.Number &") uninstalling version "& folder.Name &": "& Err.Description
                    Err.Clear
                    delError = 1
                Else
                    WScript.Echo "pyenv: Successfully uninstalled "& folder
                End If
            End If
        Next
        If Not CBool(delError) Then Rehash
    Else
        WScript.Echo "pyenv: version '"& version &"' not installed"
    End If

    WScript.Quit delError
End Sub

main(WScript.Arguments)
