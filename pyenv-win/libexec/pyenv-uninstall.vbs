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
    WScript.Quit 0
End Sub

Sub unregister(version)
    Dim sh, key
    Set sh = CreateObject("WScript.Shell")
    key = "HKCU\SOFTWARE\Python\PythonCore\"& version &"\"
    ' No problem removing keys that do not exist
    sh.RegDelete key & "InstallPath\"
    sh.RegDelete key & "InstalledFeatures\"
    sh.RegDelete key & "PythonPath\"
    sh.RegDelete key
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
        WScript.Quit 1
    End If

    Dim folder
    Dim confirm
    Dim delError
    delError = 0

    If optAll Then
        ' Confirm "uninstall all", if not forced.
        If optForce Then
            confirm = "y"
        Else
            confirm = "maybe"
            Do While confirm <> "n" And confirm <> "y"
                WScript.StdOut.Write "pyenv: Confirm uninstall all? (Y/N): "
                confirm = LCase(Left(Trim(WScript.StdIn.ReadLine), 1))
                If Len(confirm) = 0 Then Exit Sub
            Loop
        End If
        If confirm <> "y" Then Exit Sub

        uninstallVersions.RemoveAll
        For Each folder In objfs.GetFolder(strDirVers).SubFolders
            If IsVersion(folder.Name) Then _
                uninstallVersions(folder.Name) = Empty
        Next
    End If

    If uninstallVersions.Count = 1 Then
        folder = Check32Bit(uninstallVersions.Keys()(0))
        If Not objfs.FolderExists(strDirVers &"\"& folder) Then
            WScript.Echo "pyenv: version '"& folder &"' not installed"
            Exit Sub
        End If
    End If

    Dim uninstalled
    Dim uninstallPath
    Set uninstalled = CreateObject("Scripting.Dictionary")

    On Error Resume Next
    For Each folder In uninstallVersions.Keys
        folder = Check32Bit(folder)

        If Not uninstalled.Exists(folder) Then
            uninstallPath = strDirVers &"\"& folder
            If IsVersion(folder) And objfs.FolderExists(uninstallPath) Then
                objfs.DeleteFolder uninstallPath, optForce
                If Err.Number <> 0 Then
                    WScript.Echo "pyenv: Error ("& Err.Number &") uninstalling version "& folder.Name &": "& Err.Description
                    Err.Clear
                    delError = 1
                Else
                    unregister folder
                    WScript.Echo "pyenv: Successfully uninstalled "& folder
                    uninstalled(folder) = Empty
                End If
            End If
        End If
    Next
    If Not CBool(delError) Then Rehash

    WScript.Quit delError
End Sub

main(WScript.Arguments)
