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
Import "libs\pyenv-install-lib.vbs"

Sub ShowHelp(exitcode)
    ' WScript.echo "kkotari: pyenv-latest.vbs..!"
    WScript.Echo "Usage: pyenv latest [-k|--known] [-q|--quiet] <prefix>"
    WScript.Echo ""
    WScript.Echo "  -k/--known      Select from all known versions instead of installed"
    WScript.Echo "  -q/--quiet      Do not print an error message on resolution failure"
    WScript.Echo ""
    WScript.Quit exitcode
End Sub

Sub main(arg)
    ' WScript.echo "kkotari: pyenv-latest.vbs Main..!"

    Dim optKnown
    Dim optQuiet
    Dim optPrefix

    optKnown = False
    optQuiet = False
    optPrefix = ""

    Dim idx

    For idx = 0 To arg.Count - 1
        Select Case arg(idx)
            Case "--help"           ShowHelp 0
            Case "-k"               optKnown = True
            Case "--known"          optKnown = True
            Case "-q"               optQuiet = True
            Case "--quiet"          optQuiet = True
            Case Else
                optPrefix = arg(idx)
        End Select
    Next

    If arg.Count = 0 Then
        If optQuiet <> True Then
            ShowHelp 1
        End If
    End If

    If optPrefix = "" Then
        If optQuiet <> True Then
            WScript.Echo "pyenv-latest: missing <prefix> argument"
        End If

        WScript.Quit 1
    End If

    Dim latest
    latest = FindLatestVersion(optPrefix, optKnown)

    If latest <> "" Then
        WScript.Echo latest
    Else
        If optQuiet <> True Then
            if optKnown Then
                WScript.Echo "pyenv-latest: no known versions match the prefix '" & optPrefix & "'."
            else
                WScript.Echo "pyenv-latest: no installed versions match the prefix '" & optPrefix & "'."
            end if
        End If

        WScript.Quit 1
    End If
End Sub

main(WScript.Arguments)
