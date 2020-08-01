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
    help = getCommandOutput("cmd /c "& strDirLibs &"\"& cmd &".bat")
    WScript.Echo help
    WScript.Quit exitCode
End Sub

Sub PrintHelp(cmd, exitCode)
    ' WScript.echo "kkotari: pyenv.vbs print help..!"
    Dim help
    help = getCommandOutput("cmd /c "& strDirLibs &"\"& cmd &".bat --help")
    WScript.Echo help
    WScript.Quit exitCode
End Sub

Sub ExecCommand(str)
    ' WScript.echo "kkotari: pyenv.vbs exec command..!"
    Dim utfStream
    Dim outStream
    Set utfStream = CreateObject("ADODB.Stream")
    Set outStream = CreateObject("ADODB.Stream")
    With utfStream
        .CharSet = "utf-8"
        .Mode = 3 ' adModeReadWrite
        .Open
        .WriteText("chcp 1250 > NUL" & vbCrLf)
        .WriteText(str & vbCrLf)
        .Position = 3
    End With
    With outStream
        .Type = 1 ' adTypeBinary
        .Mode = 3 ' adModeReadWrite
        .Open
        utfStream.CopyTo outStream
        .SaveToFile strPyenvHome & "\exec.bat", 2
        .Close
    End With
    utfStream.Close
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
    ElseIf arg(1) = "--help" Or arg(1) = "" Then
        PrintHelp "pyenv-which", Abs(arg(1) = "")
    End If

    Dim path
    Dim program
    Dim exts
    Dim ext
    Dim version

    program = arg(1)
    version = objws.Environment("Process")("PYENV_VERSION")

    If program = "" Then PrintHelp "pyenv-which", 1
    If version = "" Then version = GetCurrentVersion()(0)
    If Right(program, 1) = "." Then program = Left(program, Len(program)-1)

    Set exts = GetExtensions(True)

    If Not objfs.FolderExists(strDirVers &"\"& version) Then
        WScript.Echo "pyenv: version `"& version &"' is not installed (set by "& version &")"
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
    WScript.Echo "pyenv: "& arg(1) &": command not found"

    version = getCommandOutput("cscript //Nologo "& WScript.ScriptFullName &" whence "& program)
    If Trim(version) <> "" Then
        WScript.Echo
        WScript.Echo "The `"& arg(1) &"' command exists in these Python versions:"
        WScript.Echo "  "& Replace(version, vbCrLf, vbCrLf &"  ")
    End If

    WScript.Quit 127
End Sub

Sub CommandWhence(arg)
    ' WScript.echo "kkotari: pyenv.vbs command whence..!"
    If arg.Count < 2 Then
        PrintHelp "pyenv-whence", 1
    ElseIf arg(1) = "--help" Or arg(1) = "" Then
        PrintHelp "pyenv-whence", Abs(arg(1) = "")
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
    If arg.Count >= 2 Then
        If arg(1) = "--help" Then PrintHelp "pyenv---version", 0
    End If

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
    ' WScript.echo "kkotari: pyenv.vbs command help..!"
    If arg.Count > 1 Then
        Dim list
        Set list = GetCommandList
        If list.Exists(arg(1)) Then
            ExecCommand(list(arg(1)) & " --help")
        Else
             WScript.Echo "unknown pyenv command '"& arg(1) &"'"
        End If
    Else
        ShowHelp
    End If
End Sub

Sub CommandRehash(arg)
    ' WScript.echo "kkotari: pyenv.vbs command rehash..!"
    If arg.Count >= 2 Then
        If arg(1) = "--help" Then PrintHelp "pyenv-rehash", 0
    End If

    Rehash
End Sub

Sub CommandExecute(arg)
    ' WScript.echo "kkotari: pyenv.vbs command exec..!"
    If arg.Count >= 2 Then
        If arg(1) = "--help" Then PrintHelp "pyenv-exec", 0
    End If

    Dim str
    Dim dstr
    dstr = GetBinDir(GetCurrentVersion()(0))
    str = "set PATH="& dstr &";%PATH:&=^&%"& vbCrLf
    If arg.Count > 1 Then
        str = str &""""& dstr &"\"& arg(1) &""""
        Dim idx
        If arg.Count > 2 Then
            For idx = 2 To arg.Count - 1
                str = str &" """& arg(idx) &""""
            Next
        End If
    End If
    ExecCommand(str)
End Sub

Sub CommandGlobal(arg)
    ' WScript.echo "kkotari: pyenv.vbs command global..!"
    If arg.Count >= 2 Then
        If arg(1) = "--help" Then PrintHelp "pyenv-global", 0
    End If

    Dim ver
    If arg.Count < 2 Then
        ver = GetCurrentVersionGlobal()
        If IsNull(ver) Then
            WScript.Echo "no global version configured"
        Else
            WScript.Echo ver(0)
        End If
    Else
        ver = Check32Bit(arg(1))
        SetGlobalVersion ver
    End If
End Sub

Sub CommandLocal(arg)
    ' WScript.echo "kkotari: pyenv.vbs command local..!"
    If arg.Count >= 2 Then
        If arg(1) = "--help" Then PrintHelp "pyenv-local", 0
    End If

    Dim ver
    If arg.Count < 2 Then
        ver = GetCurrentVersionLocal(strCurrent)
        If IsNull(ver) Then
            WScript.Echo "no local version configured for this directory"
        Else
            WScript.Echo ver(0)
        End If
    Else
        If arg(1) = "--unset" Then
            ver = ""
            objfs.DeleteFile strCurrent & strVerFile, True
            Exit Sub
        Else
            ver = Check32Bit(arg(1))
            GetBinDir(ver)
        End If

        Dim ofile
        If objfs.FileExists(strCurrent & strVerFile) Then
            Set ofile = objfs.OpenTextFile(strCurrent & strVerFile, 2)
        Else
            Set ofile = objfs.CreateTextFile(strCurrent & strVerFile, True)
        End If
        ofile.WriteLine(ver)
        ofile.Close()
    End If
End Sub

Sub CommandShell(arg)
    ' WScript.echo "kkotari: pyenv.vbs command shell..!"
    If arg.Count >= 2 Then
        If arg(1) = "--help" Then PrintHelp "pyenv-shell", 0
    End If

    Dim ver
    If arg.Count < 2 Then
        ver = GetCurrentVersionShell
        If IsNull(ver) Then
            WScript.Echo "no shell-specific version configured"
        Else
            WScript.Echo ver(0)
        End If
    Else
        If arg(1) = "--unset" Then
            ver = ""
        Else
            ver = Check32Bit(arg(1))
            GetBinDir(ver)
        End If
        ExecCommand("endlocal"& vbCrLf &"set PYENV_VERSION="& ver)
    End If
End Sub

Sub CommandVersion(arg)
    ' WScript.echo "kkotari: pyenv.vbs command version..!"
    If arg.Count >= 2 Then
        If arg(1) = "--help" Then PrintHelp "pyenv-version", 0
    End If

    If Not objfs.FolderExists(strDirVers) Then objfs.CreateFolder(strDirVers)

    Dim curVer
    curVer = GetCurrentVersion
    WScript.Echo curVer(0) &" (set by "& curVer(1) &")"
End Sub

Sub CommandVersionName(arg)
    ' WScript.echo "kkotari: pyenv.vbs command version-name..!"
    If arg.Count >= 2 Then
        If arg(1) = "--help" Then PrintHelp "pyenv-vname", 0
    End If

    If Not objfs.FolderExists(strDirVers) Then objfs.CreateFolder(strDirVers)

    WScript.Echo GetCurrentVersion()(0)
End Sub

Sub CommandVersions(arg)
    ' WScript.echo "kkotari: pyenv.vbs command versions..!"
    If arg.Count >= 2 Then
        If arg(1) = "--help" Then PrintHelp "pyenv-versions", 0
    End If

    Dim isBare
    isBare = False
    If arg.Count >= 2 Then
        If arg(1) = "--bare" Then isBare = True
    End If

    If Not objfs.FolderExists(strDirVers) Then objfs.CreateFolder(strDirVers)

    Dim curVer
    curVer = GetCurrentVersionNoError
    If IsNull(curVer) Then
        curVer = Array("", "")
    End If

    Dim dir
    Dim ver
    For Each dir In objfs.GetFolder(strDirVers).subfolders
        ver = objfs.GetFileName(dir)
        If isBare Then
            WScript.Echo ver
        ElseIf ver = curVer(0) Then
            WScript.Echo "* "& ver &" (set by "& curVer(1) &")"
        Else
            WScript.Echo "  "& ver
        End If
    Next
End Sub

Sub PlugIn(arg)
    ' WScript.echo "kkotari: pyenv.vbs plugin..!"

    Dim fname
    Dim idx
    Dim str
    fname = strDirLibs &"\pyenv-"& arg(0)
    If objfs.FileExists(fname &".bat" ) Then
        str = """"& fname &".bat"""
    ElseIf objfs.FileExists(fname &".vbs" ) Then
        str = "cscript //nologo """& fname &".vbs"""
    Else
       WScript.Echo "pyenv: no such command `"& arg(0) &"'"
       WScript.Quit
    End If

    For idx = 1 To arg.Count - 1
      str = str &" """& arg(idx) &""""
    Next

    ExecCommand(str)
End Sub

Sub CommandCommands(arg)
    ' WScript.echo "kkotari: pyenv.vbs command commands..!"
    Dim cname

    If arg.Count >= 2 Then
        If arg(1) = "--help" Then PrintHelp "pyenv-commands", 0
    End If

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
           Case "exec"         CommandExecute(arg)
           Case "rehash"       CommandRehash(arg)
           Case "global"       CommandGlobal(arg)
           Case "local"        CommandLocal(arg)
           Case "shell"        CommandShell(arg)
           Case "version"      CommandVersion(arg)
           Case "vname"        CommandVersionName(arg)
           Case "versions"     CommandVersions(arg)
           Case "commands"     CommandCommands(arg)
           Case "shims"        CommandShims(arg)
           Case "which"        CommandWhich(arg)
           Case "whence"       CommandWhence(arg)
           Case "help"         CommandHelp(arg)
           Case "--help"       CommandHelp(arg)
           Case Else           PlugIn(arg)
        End Select
    End If
End Sub

main(WScript.Arguments)
