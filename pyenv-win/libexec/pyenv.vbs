Option Explicit

Dim objCmdExec

' WScript.echo "kkotari: pyenv.vbs..!"
' WScript.echo "kkotari: pyenv.vbs Defining Import..!"
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
' WScript.echo "kkotari: pyenv.vbs Import called..!"

Function GetCommandList()
    ' WScript.echo "kkotari: pyenv.vbs get command list..!"
    Dim cmdList
    Set cmdList = CreateObject("Scripting.Dictionary")

    Dim fileRegex
    Dim exts
    Set fileRegex = new RegExp
    Set exts = GetExtensionsNoPeriod(False)
    fileRegex.Pattern = "pyenv-([a-zA-Z_0-9-]+)\."

    Dim file
    Dim matches
    For Each file In objfs.GetFolder(strDirLibs).Files
        Set matches = fileRegex.Execute(objfs.GetFileName(file))
        If matches.Count > 0 And exts.Exists(objfs.GetExtensionName(file)) Then
             cmdList.Add matches(0).SubMatches(0), file
        End If
    Next

    Set GetCommandList = cmdList
End Function

Sub PrintVersion(cmd, exitCode)
    ' WScript.echo "kkotari: pyenv.vbs print version..!"
    Dim help
    help = getCommandOutput("cmd /c """& strDirLibs &"\"& cmd &".bat""")
    WScript.Echo help
    WScript.Quit exitCode
End Sub

Sub PrintHelp(cmd, exitCode)
    ' WScript.echo "kkotari: pyenv.vbs print help..!"
    Dim help
    help = getCommandOutput("cmd /c """& strDirLibs &"\"& cmd &".bat"" --help")
    WScript.Echo help
    WScript.Quit exitCode
End Sub

Function getCommandOutput(theCommand)
    ' WScript.echo "kkotari: pyenv.vbs get command output..!"
    Set objCmdExec = objws.exec(thecommand)
    getCommandOutput = objCmdExec.StdOut.ReadAll
end Function

Sub CommandShims(arg)
    ' WScript.echo "kkotari: pyenv.vbs command shims..!"
     Dim shims_files
     If arg.Count < 2 Then
     ' WScript.Echo join(arg.ToArray(), ", ")
     ' if --short passed then remove /s from cmd
        shims_files = getCommandOutput("cmd /c dir "& strDirShims &"/s /b")
     ElseIf arg(1) = "--short" Then
        shims_files = getCommandOutput("cmd /c dir "& strDirShims &" /b")
     Else
        shims_files = getCommandOutput("cmd /c "& strDirLibs &"\pyenv-shims.bat --help")
     End IF
     WScript.Echo shims_files
End Sub

' NOTE: Exists because of its possible reuse from the original Linux pyenv.
'Function RemoveFromPath(pathToRemove)
'    Dim path_before
'    Dim result

'    result = objws.Environment("Process")("PATH")
'    If Left(result, 1) <> ";" Then result = ";"&result
'    If Right(result, 1) <> ";" Then result = result&";"

'    Do While path_before <> result
'        path_before = result
'        result = Replace(result, ";"& pathToRemove &";", ";")
'    Loop

'    RemoveFromPath = Mid(result, 2, Len(result)-2)
'End Function

Sub CommandWhich(arg)
    ' WScript.echo "kkotari: pyenv.vbs command which..!"
    If arg.Count < 2 Then
        PrintHelp "pyenv-which", 1
    ElseIf arg(1) = "" Then
        PrintHelp "pyenv-which", 1
    End If

    Dim path
    Dim program
    Dim exts
    Dim ext
    Dim version

    program = arg(1)
    If Right(program, 1) = "." Then program = Left(program, Len(program)-1)

    Set exts = GetExtensions(True)

    Dim versions
    Set versions = GetCurrentVersions
    For Each version In versions

        If Not objfs.FolderExists(strDirVers &"\"& version) Then
            WScript.Echo "pyenv: version '"& version &"' is not installed (set by "& version &")"
            WScript.Quit 1
        End If

        If objfs.FileExists(strDirVers &"\"& version &"\"& program) Then
            WScript.Echo objfs.GetFile(strDirVers &"\"& version &"\"& program).Path
            WScript.Quit 0
        End If

        For Each ext In exts.Keys
            If objfs.FileExists(strDirVers &"\"& version &"\"& program & ext) Then
                WScript.Echo objfs.GetFile(strDirVers &"\"& version &"\"& program & ext).Path
                WScript.Quit 0
            End If
        Next

        If objfs.FolderExists(strDirVers &"\"& version & "\Scripts") Then
            If objfs.FileExists(strDirVers &"\"& version &"\Scripts\"& program) Then
                WScript.Echo objfs.GetFile(strDirVers &"\"& version &"\Scripts\"& program).Path
                WScript.Quit 0
            End If

            For Each ext In exts.Keys
                If objfs.FileExists(strDirVers &"\"& version &"\Scripts\"& program & ext) Then
                    WScript.Echo objfs.GetFile(strDirVers &"\"& version &"\Scripts\"& program & ext).Path
                    WScript.Quit 0
                End If
            Next
        End If
    Next

    WScript.Echo "pyenv: "& arg(1) &": command not found"

    version = getCommandOutput("cscript //Nologo """& WScript.ScriptFullName &""" whence "& program)
    If Trim(version) <> "" Then
        WScript.Echo
        WScript.Echo "The '"& arg(1) &"' command exists in these Python versions:"
        WScript.Echo "  "& Replace(version, vbCrLf, vbCrLf &"  ")
    End If

    WScript.Quit 127
End Sub

Sub CommandWhence(arg)
    ' WScript.echo "kkotari: pyenv.vbs command whence..!"
    If arg.Count < 2 Then
        PrintHelp "pyenv-whence", 1
    ElseIf arg(1) = "" Then
        PrintHelp "pyenv-whence", 1
    End If

    Dim program
    Dim exts
    Dim ext
    dim path
    Dim dir
    Dim isPath
    Dim found
    Dim foundAny ' Acts as an exit code: 0=Success, 1=No files/versions found

    If arg(1) = "--path" Then
        If arg.Count < 3 Then PrintHelp "pyenv-whence", 1
        isPath = True
        program = arg(2)
    Else
        program = arg(1)
    End If

    If program = "" Then PrintHelp "pyenv-whence", 1
    If Right(program, 1) = "." Then program = Left(program, Len(program)-1)

    Set exts = GetExtensions(True)
    foundAny = 1

    For Each dir In objfs.GetFolder(strDirVers).subfolders
        found = False

        If objfs.FileExists(dir & "\" & program) Then
            found = True
            foundAny = 0
            If isPath Then
                WScript.Echo objfs.GetFile(dir & "\" & program).Path
            Else
                WScript.Echo objfs.GetFileName( dir )
            End If
        End If

        If Not found Or isPath Then
            For Each ext In exts.Keys
                If objfs.FileExists(dir & "\" & program & ext) Then
                    found = True
                    foundAny = 0
                    If isPath Then
                        WScript.Echo objfs.GetFile(dir & "\" & program & ext).Path
                    Else
                        WScript.Echo objfs.GetFileName( dir )
                    End If
                    Exit For
                End If
            Next
        End If

        If Not found Or isPath And objfs.FolderExists(dir & "\Scripts") Then
            If objfs.FileExists(dir & "\Scripts\" & program) Then
                found = True
                foundAny = 0
                If isPath Then
                    WScript.Echo objfs.GetFile(dir & "\Scripts\" & program).Path
                Else
                    WScript.Echo objfs.GetFileName( dir )
                End If
            End If
        End If

        If Not found Or isPath And objfs.FolderExists(dir & "\Scripts") Then
            For Each ext In exts.Keys
                If objfs.FileExists(dir & "\Scripts\" & program & ext) Then
                    foundAny = 0
                    If isPath Then
                        WScript.Echo objfs.GetFile(dir & "\Scripts\" & program & ext).Path
                    Else
                        WScript.Echo objfs.GetFileName( dir )
                    End If
                    Exit For
                End If
            Next
        End If
    Next

    WScript.Quit foundAny
End Sub

Sub ShowHelp()
    '  WScript.echo "kkotari: pyenv.vbs show help..!"
     WScript.Echo "pyenv " & objfs.OpenTextFile(strPyenvParent & "\.version").ReadAll
     WScript.Echo "Usage: pyenv <command> [<args>]"
     WScript.Echo ""
     WScript.Echo "Some useful pyenv commands are:"
     WScript.Echo "   commands     List all available pyenv commands"
     WScript.Echo "   duplicate    Creates a duplicate python environment"
     WScript.Echo "   local        Set or show the local application-specific Python version"
     WScript.Echo "   global       Set or show the global Python version"
     WScript.Echo "   shell        Set or show the shell-specific Python version"
     WScript.Echo "   install      Install a Python version using python-build"
     WScript.Echo "   uninstall    Uninstall a specific Python version"
     WScript.Echo "   update       Update the cached version DB"
     WScript.echo "   rehash       Rehash pyenv shims (run this after installing executables)"
     WScript.Echo "   vname        Show the current Python version"
     WScript.Echo "   version      Show the current Python version and its origin"
     WScript.Echo "   version-name Show the current Python version"
     WScript.Echo "   versions     List all Python versions available to pyenv"
     WScript.Echo "   exec         Runs an executable by first preparing PATH so that the selected Python"
     WScript.Echo "   which        Display the full path to an executable"
     WScript.Echo "   whence       List all Python versions that contain the given executable"
     WScript.Echo ""
     WScript.Echo "See `pyenv help <command>' for information on a specific command."
     WScript.Echo "For full documentation, see: https://github.com/pyenv-win/pyenv-win#readme"
End Sub

Sub CommandScriptVersion(arg)
    ' WScript.echo "kkotari: pyenv.vbs command script version..!"
    If arg.Count = 1 Then
        Dim list
        Set list = GetCommandList
        If list.Exists(arg(0)) Then
            PrintVersion "pyenv---version", 0
        Else
             WScript.Echo "unknown pyenv command '"& arg(0) &"'"
        End If
    Else
        ShowHelp
    End If
End Sub

Sub CommandHelp(arg)
    ShowHelp
End Sub

Sub CommandRehash(arg)
    ' WScript.echo "kkotari: pyenv.vbs command rehash..!"
    If arg.Count >= 2 Then
        If arg(1) = "--help" Then PrintHelp "pyenv-rehash", 0
    End If

    Dim versions
    versions = GetInstalledVersions()
    If UBound(versions) = 0 Then
        WScript.Echo "No version installed. Please install one with 'pyenv install <version>'."
    Else
        Rehash
    End If
End Sub

Sub CommandGlobal(arg)
    ' WScript.echo "kkotari: pyenv.vbs command global..!"
    Dim ver
    If arg.Count < 2 Then
        Dim currentVersions
        currentVersions = GetCurrentVersionsGlobal
        If IsNull(currentVersions) Then
            WScript.Echo "no global version configured"
        Else
            For Each ver in currentVersions
                WScript.Echo ver(0)
            Next
        End If
    Else
        If arg(1) = "--unset" Then
            ver = ""
            objfs.DeleteFile strPyenvHome &"\version", True
            Exit Sub
        Else
            Dim versionCount
            versionCount = arg.Count - 1
            ReDim globalVersions(versionCount - 1)
            Dim i
            For i = 0 To versionCount - 1
                globalVersions(i) = Check32Bit(arg(i + 1))
                GetBinDir(globalVersions(i))
            Next
        End If

        Dim ofile
        If objfs.FileExists(strPyenvHome &"\version") Then
            Set ofile = objfs.OpenTextFile(strPyenvHome &"\version", 2)
        Else
            Set ofile = objfs.CreateTextFile(strPyenvHome &"\version", True)
        End If
        For Each ver in globalVersions
            ofile.WriteLine(ver)
        Next
        ofile.Close()
    End If
End Sub

Sub CommandLocal(arg)
    ' WScript.echo "kkotari: pyenv.vbs command local..!"
    Dim ver
    If arg.Count < 2 Then
        Dim currentVersions
        currentVersions = GetCurrentVersionsLocal(strCurrent)
        If IsNull(currentVersions) Then
            WScript.Echo "no local version configured for this directory"
        Else
            For Each ver in currentVersions
                WScript.Echo ver(0)
            Next
        End If
    Else
        If arg(1) = "--unset" Then
            ver = ""
            objfs.DeleteFile strCurrent & strVerFile, True
            Exit Sub
        Else
            Dim versionCount
            versionCount = arg.Count - 1
            ReDim localVersions(versionCount - 1)
            Dim i
            For i = 0 To versionCount - 1
                localVersions(i) = Check32Bit(arg(i + 1))
                GetBinDir(localVersions(i))
            Next
        End If

        Dim ofile
        If objfs.FileExists(strCurrent & strVerFile) Then
            Set ofile = objfs.OpenTextFile(strCurrent & strVerFile, 2)
        Else
            Set ofile = objfs.CreateTextFile(strCurrent & strVerFile, True)
        End If
        For Each ver in localVersions
            ofile.WriteLine(ver)
        Next
        ofile.Close()
    End If
End Sub

Sub CommandShell(arg)
    ' WScript.echo "kkotari: pyenv.vbs command shell..!"
    Dim ver
    If arg.Count < 2 Then
        WScript.Echo "Not enough parameters passed to pyenv.vbs shell"
    Else
        If arg(1) = "--unset" Then
            Exit Sub
        Else
            Dim versionCount
            versionCount = arg.Count - 1
            ReDim shellVersions(versionCount - 1)
            Dim i
            For i = 0 To versionCount - 1
                shellVersions(i) = Check32Bit(arg(i + 1))
                GetBinDir(shellVersions(i))
            Next
        End If

        WScript.Echo Join(shellVersions, " ")
    End If
End Sub

Sub CommandVersion(arg)
    ' WScript.echo "kkotari: pyenv.vbs command version..!"
    If Not objfs.FolderExists(strDirVers) Then objfs.CreateFolder(strDirVers)

    Dim curVer
    Dim versions
    Set versions = GetCurrentVersions
    For Each curVer In versions
        WScript.Echo curVer &" (set by "& versions(curVer) &")"
    Next
End Sub

Sub CommandVersionName(arg)
    ' WScript.echo "kkotari: pyenv.vbs command version-name..!"
    If Not objfs.FolderExists(strDirVers) Then objfs.CreateFolder(strDirVers)

    Dim ver, versions
    Set versions = GetCurrentVersions
    For Each ver in versions
        WScript.Echo ver
    Next
End Sub

Sub CommandVersionNameShort(arg)
    ' WScript.echo "kkotari: pyenv.vbs command vname..!"
    If Not objfs.FolderExists(strDirVers) Then objfs.CreateFolder(strDirVers)

    Dim ver, versions
    Set versions = GetCurrentVersions
    For Each ver in versions
        WScript.Echo ver
    Next
End Sub

Sub CommandVersions(arg)
    ' WScript.echo "kkotari: pyenv.vbs command versions..!"
    Dim isBare
    isBare = False
    If arg.Count >= 2 Then
        If arg(1) = "--bare" Then isBare = True
    End If

    If Not objfs.FolderExists(strDirVers) Then objfs.CreateFolder(strDirVers)

    Dim versions
    Set versions = GetCurrentVersionsNoError

    Dim dir
    Dim ver
    For Each dir In objfs.GetFolder(strDirVers).subfolders
        ver = objfs.GetFileName(dir)
        If isBare Then
            WScript.Echo ver
        ElseIf versions.Exists(ver) Then
            WScript.Echo "* "& ver &" (set by "& versions(ver) &")"
        Else
            WScript.Echo "  "& ver
        End If
    Next
End Sub

Sub CommandCommands(arg)
    ' WScript.echo "kkotari: pyenv.vbs command commands..!"
    Dim cname

    For Each cname In GetCommandList()
        WScript.Echo cname
    Next
End Sub

Sub Dummy()
     WScript.Echo "command not implement"
End Sub


Sub main(arg)
    ' WScript.echo "kkotari: pyenv.vbs main..!"
    ' WScript.echo "kkotari: "&arg(0)
    If arg.Count = 0 Then
        ShowHelp
    Else
        Select Case arg(0)
           Case "--version"    CommandScriptVersion(arg)
           Case "rehash"       CommandRehash(arg)
           Case "global"       CommandGlobal(arg)
           Case "local"        CommandLocal(arg)
           Case "shell"        CommandShell(arg)
           Case "version"      CommandVersion(arg)
           Case "vname"        CommandVersionNameShort(arg)
           Case "version-name" CommandVersionName(arg)
           Case "versions"     CommandVersions(arg)
           Case "commands"     CommandCommands(arg)
           Case "shims"        CommandShims(arg)
           Case "which"        CommandWhich(arg)
           Case "whence"       CommandWhence(arg)
           Case "help"         CommandHelp(arg)
           Case "--help"       CommandHelp(arg)
           ' Case Else           WScript.Echo "main Case Else"
        End Select
    End If
End Sub

main(WScript.Arguments)
