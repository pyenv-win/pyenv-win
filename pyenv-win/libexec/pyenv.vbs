Option Explicit

Dim objws
Dim objfs
Set objws = WScript.CreateObject("WScript.Shell")
Set objfs = CreateObject("Scripting.FileSystemObject")

Dim strCurrent
Dim strPyenvHome
Dim strDirCache
Dim strDirVers
Dim strDirLibs
Dim strVerFile
strCurrent   = objfs.GetAbsolutePathName(".")
strPyenvHome = objfs.getParentFolderName(objfs.getParentFolderName(WScript.ScriptFullName))
strDirCache  = strPyenvHome & "\install_cache"
strDirVers   = strPyenvHome & "\versions"
strDirLibs   = strPyenvHome & "\libexec"
strVerFile   = "\.python-version"

Function IsVersion(version)
    Dim re
    Set re = new regexp
    re.Pattern = "^[a-zA-Z_0-9-.]+$"
    IsVersion = re.Test(version)
End Function

Function GetCurrentVersionGlobal()
    GetCurrentVersionGlobal = Null

    Dim fname
    Dim objFile
    fname = strPyenvHome & "\version"
    If objfs.FileExists( fname ) Then
        Set objFile = objfs.OpenTextFile(fname)
        If objFile.AtEndOfStream <> True Then
           GetCurrentVersionGlobal = Array(objFile.ReadLine,fname)
        End If
        objFile.Close
    End If
End Function

Function GetCurrentVersionLocal(path)
    GetCurrentVersionLocal = Null

    Dim fname
    Dim objFile
    Do While path <> ""
        fname = path & strVerFile
        If objfs.FileExists( fname ) Then
            Set objFile = objfs.OpenTextFile(fname)
            If objFile.AtEndOfStream <> True Then
               GetCurrentVersionLocal = Array(objFile.ReadLine,fname)
            End If
            objFile.Close
            Exit Function
        End If
        path = objfs.getParentFolderName(path)
    Loop
End Function

Function GetCurrentVersionShell()
    GetCurrentVersionShell = Null

    Dim str
    str=objws.ExpandEnvironmentStrings("%PYENV_VERSION%")
    If str <> "%PYENV_VERSION%" Then
        GetCurrentVersionShell = Array(str,"%PYENV_VERSION%")
    End If
End Function

Function GetCurrentVersion()
    Dim str
    str=GetCurrentVersionShell
    If IsNull(str) Then str = GetCurrentVersionLocal(strCurrent)
    If IsNull(str) Then str = GetCurrentVersionGlobal
    If IsNull(str) Then 
		WScript.echo "No global python version has been set yet. Please set the global version by typing:"
		WScript.echo "pyenv global 3.7.2"
		WScript.quit
	End If
	GetCurrentVersion = str
End Function

Function GetCurrentVersionNoError()
    Dim str
    str=GetCurrentVersionShell
    If IsNull(str) Then str = GetCurrentVersionLocal(strCurrent)
    If IsNull(str) Then str = GetCurrentVersionGlobal
    GetCurrentVersionNoError = str
End Function

Function GetBinDir(ver)
    Dim str
    str=strDirVers & "\" & ver & "\" 
    If Not(IsVersion(ver) And objfs.FolderExists(str)) Then 
		WScript.echo "pyenv specific python requisite didn't meet. Project is using different version of python."
		WScript.echo "Install python '"&ver&"' by typing: 'pyenv install "&ver&"'"
		WScript.quit
	End If
    GetBinDir = str
End Function

Function GetCommandList()
    Dim cmdList
    Set cmdList = CreateObject("Scripting.Dictionary")'"System.Collections.SortedList"

    Dim re
    Set re = new regexp
    re.Pattern = "\\pyenv-([a-zA-Z_0-9-]+)\.(bat|vbs)$"

    Dim file
    Dim mts
    For Each file In objfs.GetFolder(strDirLibs).Files
        Set mts=re.Execute(file)
        If mts.Count > 0 Then
             cmdList.Add mts(0).submatches(0), file
        End If
    Next

    Set GetCommandList = cmdList
End Function

Sub ExecCommand(str)
    Dim ofile
    Set ofile = objfs.CreateTextFile(strPyenvHome & "\exec.bat" , True )
    ofile.WriteLine(str)
    ofile.Close()
End Sub

Sub ShowHelp()
	 WScript.echo "pyenv 1.2.2"
     WScript.echo "Usage: pyenv <command> [<args>]"
     WScript.echo ""
     WScript.echo "Some useful pyenv commands are:"
     WScript.echo "   commands    List all available pyenv commands"
     WScript.echo "   local       Set or show the local application-specific Python version"
     WScript.echo "   global      Set or show the global Python version"
     WScript.echo "   shell       Set or show the shell-specific Python version"
     WScript.echo "   install     Install a Python version using python-build"
     WScript.echo "   uninstall   Uninstall a specific Python version"
     WScript.echo "   rehash      Rehash pyenv shims (run this after installing executables)"
     WScript.echo "   version     Show the current Python version and its origin"
     WScript.echo "   versions    List all Python versions available to pyenv"
     WScript.echo "   exec        Runs an executable by first preparing PATH so that the selected Python"
     WScript.echo ""
     WScript.echo "See `pyenv help <command>' for information on a specific command."
     WScript.echo "For full documentation, see: https://github.com/pyenv-win/pyenv-win#readme"
     Exit Sub


     WScript.echo "   which       Display the full path to an executable"
     WScript.echo "   whence      List all Python versions that contain the given executable"
End Sub

Sub CommandHelp(arg)
    If arg.Count > 1 Then
        Dim list
        Set list=GetCommandList
        If list.Exists(arg(1)) Then
            ExecCommand(list(arg(1)) & " --help")
        Else
             WScript.echo "unknown pyenv command '"&arg(1)&"'"
        End If
    Else
        ShowHelp
    End If
End Sub


Sub CommandRehash(arg)
    Dim strDirShims
    strDirShims= strPyenvHome & "\shims"
    If Not objfs.FolderExists( strDirShims ) Then objfs.CreateFolder(strDirShims)

    Dim ofile
    Dim file
    For Each file In objfs.GetFolder(strDirShims).Files
        objfs.DeleteFile file, True
    Next
    For Each file In objfs.GetFolder(GetBinDir(GetCurrentVersion()(0))).Files
        If objfs.GetExtensionName(file) = "exe" or objfs.GetExtensionName(file) = "bat" or objfs.GetExtensionName(file) = "cmd" Then
          Set ofile = objfs.CreateTextFile(strDirShims & "\" & objfs.GetBaseName( file ) & ".bat" )
          ofile.WriteLine("@echo off")
          ofile.WriteLine("pyenv exec %~n0 %*")
          ofile.Close()
          Set ofile = objfs.CreateTextFile(strDirShims & "\" & objfs.GetBaseName( file ) )
          ofile.WriteLine("#!/bin/sh")
          ofile.WriteLine("pyenv exec $(basename ""$0"") $*")
          ofile.Close()
        End If
    Next
    
    For Each file In objfs.GetFolder(GetBinDir(GetCurrentVersion()(0)) & "\Scripts").Files
        If objfs.GetExtensionName(file) = "exe" or objfs.GetExtensionName(file) = "bat" or objfs.GetExtensionName(file) = "cmd" Then
          Set ofile = objfs.CreateTextFile(strDirShims & "\" & objfs.GetBaseName( file ) & ".bat" )
          ofile.WriteLine("@echo off")
          ofile.WriteLine("pyenv exec Scripts/%~n0 %*")
          ofile.Close()
          Set ofile = objfs.CreateTextFile(strDirShims & "\" & objfs.GetBaseName( file ) )
          ofile.WriteLine("#!/bin/sh")
          ofile.WriteLine("pyenv exec Scripts/$(basename ""$0"") $*")
          ofile.Close()
        End If
    Next
End Sub

Sub CommandExecute(arg)
    Dim str
    Dim dstr
    dstr=GetBinDir(GetCurrentVersion()(0))
    str="set PATH=" & dstr & ";%PATH:&=^&%" & vbCrLf
    If arg.Count > 1 Then  
      str=str & """" & dstr & "\" & arg(1) & """"
      Dim idx
      If arg.Count > 2 Then  
        For idx = 2 To arg.Count - 1 
          str=str & " """& arg(idx) &""""
        Next
      End If
    End If
    ExecCommand(str)
End Sub

Sub CommandGlobal(arg)
    If arg.Count < 2 Then  
        Dim ver
        ver=GetCurrentVersionGlobal()
        If IsNull(ver) Then
            WScript.echo "no global version configured"
        Else
            WScript.echo ver(0)
        End If
    Else
        GetBinDir(arg(1))
        Dim ofile
        Set ofile = objfs.CreateTextFile( strPyenvHome & "\version" , True )
        ofile.WriteLine(arg(1))
        ofile.Close()
    End If
End Sub

Sub CommandLocal(arg)
    Dim ver
    If arg.Count < 2 Then  
        ver=GetCurrentVersionLocal(strCurrent)
        If IsNull(ver) Then
            WScript.echo "no local version configured for this directory"
        Else
            WScript.echo ver(0)
        End If
    Else
        ver=arg(1)
        If ver = "--unset" Then
            ver = ""
            objfs.DeleteFile strCurrent & strVerFile, True
            Exit Sub
        Else
            GetBinDir(ver)
        End If
        Dim ofile
        Set ofile = objfs.CreateTextFile( strCurrent & strVerFile , True )
        ofile.WriteLine(ver)
        ofile.Close()
    End If
End Sub

Sub CommandShell(arg)
    Dim ver
    If arg.Count < 2 Then  
        ver=GetCurrentVersionShell
        If IsNull(ver) Then
            WScript.echo "no shell-specific version configured"
        Else
            WScript.echo ver(0)
        End If
    Else
        ver=arg(1)
        If ver = "--unset" Then
            ver = ""
        Else
            GetBinDir(ver)
        End If
        ExecCommand("endlocal"&vbCrLf&"set PYENV_VERSION=" & ver)
    End If
End Sub

Sub CommandVersion(arg)
    If Not objfs.FolderExists( strDirVers ) Then objfs.CreateFolder(strDirVers)

    Dim curVer
    curVer=GetCurrentVersion
    WScript.echo curVer(0) & " (set by " &curVer(1)&")"
End Sub

Sub CommandVersions(arg)
    Dim isBare

    isBare=False
    If arg.Count > 2 Then
        If arg(1) = "--bare" Then isBare=True
    End If

    If Not objfs.FolderExists( strDirVers ) Then objfs.CreateFolder(strDirVers)

    Dim curVer
    curVer=GetCurrentVersionNoError
    If IsNull(curVer) Then
        curVer=Array("","")
    End If

    Dim dir
    Dim ver
    For Each dir In objfs.GetFolder(strDirVers).subfolders
        ver=objfs.GetFileName( dir )
        If isBare Then
            WScript.echo ver
        ElseIf ver = curVer(0) Then
            WScript.echo "* " & ver & " (set by " &curVer(1)&")"
        Else
            WScript.echo "  " & ver
        End If
    Next
End Sub

Sub PlugIn(arg)
    Dim fname
    Dim idx
    Dim str
    fname = strDirLibs & "\pyenv-" & arg(0)
    If objfs.FileExists( fname & ".bat" ) Then
        str="""" & fname & ".bat"""
    ElseIf objfs.FileExists( fname & ".vbs" ) Then
        str="cscript //nologo """ & fname & ".vbs"""
    Else
       WScript.echo "pyenv: no such command `"&arg(0)&"'"
       WScript.Quit
    End If

    For idx = 1 To arg.Count - 1 
      str=str & " """& arg(idx) &""""
    Next

    ExecCommand(str)
End Sub

Sub CommandCommands(arg)
    Dim cname
    For Each cname In GetCommandList()
        WScript.echo cname
    Next
End Sub

Sub Dummy()
     WScript.echo "command not implement"
End Sub


Sub main(arg)
    If arg.Count = 0 Then
        ShowHelp
    Else
        Select Case arg(0)
           Case "exec"        CommandExecute(arg)
           Case "rehash"      CommandRehash(arg)
           Case "global"      CommandGlobal(arg)
           Case "local"       CommandLocal(arg)
           Case "shell"       CommandShell(arg)
           Case "version"     CommandVersion(arg)
           Case "versions"    CommandVersions(arg)
           Case "commands"    CommandCommands(arg)
           Case "help"        CommandHelp(arg)
           Case "--help"        CommandHelp(arg)
           Case Else          PlugIn(arg)
        End Select
    End If
End Sub



main(WScript.Arguments)
