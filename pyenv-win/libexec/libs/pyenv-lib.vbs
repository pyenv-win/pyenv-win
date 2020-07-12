Option Explicit

Dim objfs
Dim objws
Dim objweb

Set objfs = CreateObject("Scripting.FileSystemObject")
Set objws = WScript.CreateObject("WScript.Shell")
Set objweb = CreateObject("WinHttp.WinHttpRequest.5.1")

' Set proxy settings, called on library import for objweb.
Sub SetProxy()
    Dim httpProxy
    Dim proxyArr

    httpProxy = objws.Environment("Process")("http_proxy")
    If httpProxy <> "" Then
        If InStr(1, httpProxy, "@") > 0 Then
            ' The http_proxy environment variable is set with basic authentication
            ' WinHttp seems to work fine without the credentials, so we should be
            ' okay with just the hostname/port part
            proxyArr = Split(httpProxy, "@")
            objweb.setProxy 2, proxyArr(1)
        Else
            objweb.setProxy 2, httpProxy
        End If
    End If
End Sub
SetProxy

Dim strCurrent
Dim strPyenvHome
Dim strPyenvParent
Dim strDirCache
Dim strDirVers
Dim strDirLibs
Dim strDirShims
Dim strDBFile
Dim strVerFile
strCurrent   = objfs.GetAbsolutePathName(".")
strPyenvHome = objfs.getParentFolderName(objfs.getParentFolderName(WScript.ScriptFullName))
strPyenvParent = objfs.getParentFolderName(strPyenvHome)
strDirCache  = strPyenvHome & "\install_cache"
strDirVers   = strPyenvHome & "\versions"
strDirLibs   = strPyenvHome & "\libexec"
strDirShims  = strPyenvHome & "\shims"
strDBFile    = strPyenvHome & "\.versions_cache.xml"
strVerFile   = "\.python-version"

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
    str = objws.ExpandEnvironmentStrings("%PYENV_VERSION%")
    If str <> "%PYENV_VERSION%" Then
        GetCurrentVersionShell = Array(str,"%PYENV_VERSION%")
    End If
End Function

Function GetCurrentVersion()
    Dim str
    str = GetCurrentVersionShell
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
    str = GetCurrentVersionShell
    If IsNull(str) Then str = GetCurrentVersionLocal(strCurrent)
    If IsNull(str) Then str = GetCurrentVersionGlobal
    GetCurrentVersionNoError = str
End Function

Function IsVersion(version)
    Dim re
    Set re = new regexp
    re.Pattern = "^[a-zA-Z_0-9-.]+$"
    IsVersion = re.Test(version)
End Function

Function GetBinDir(ver)
    Dim str
    str = strDirVers &"\"& ver
    If Not(IsVersion(ver) And objfs.FolderExists(str)) Then
		WScript.Echo "pyenv specific python requisite didn't meet. Project is using different version of python."
		WScript.Echo "Install python '"& ver &"' by typing: 'pyenv install "& ver &"'"
		WScript.Quit
	End If
    GetBinDir = str
End Function

Sub SetGlobalVersion(ver)
    GetBinDir(ver)

    With objfs.CreateTextFile(strPyenvHome &"\version" , True)
        .WriteLine(ver)
        .Close
    End With
End Sub

Function GetExtensions(addPy)
    Dim exts
    exts = ";"& objws.Environment("Process")("PATHEXT") &";"
    Set GetExtensions = CreateObject("System.Collections.ArrayList")

    If addPy Then
        If InStr(1, exts, ";.PY;", 1) = 0 Then exts = exts &".PY;"
        If InStr(1, exts, ";.PYW;", 1) = 0 Then exts = exts &".PYW;"
    End If
    exts = Mid(exts, 2, Len(exts)-2)

    Do While InStr(1, exts, ";;", 1) <> 0
        exts = Replace(exts, ";;", ";")
    Loop

    Dim ext
    For Each ext In Split(exts, ";")
        GetExtensions.Add ext
    Next
End Function

Function GetExtensionsNoPeriod(addPy)
    Dim exts
    Dim i
    Set exts = GetExtensions(addPy)
    For i = 0 To exts.Count - 1
        If Left(exts(i), 1) = "." Then
            exts(i) = LCase(Mid(exts(i), 2))
        Else
            exts(i) = LCase(exts(i))
        End If
    Next
    Set GetExtensionsNoPeriod = exts
End Function

Sub WriteWinScript(baseName, strDirBin)
    With objfs.CreateTextFile(strDirShims &"\"& baseName &".bat")
        .WriteLine("@echo off")
        .WriteLine("chcp 1250 > NUL")
        .WriteLine("set ""PATH="& strDirBin &"\Scripts;"& strDirBin &";%PATH%""")
        .WriteLine(baseName &" %*")
        .Close
    End With
End Sub

Sub WriteLinuxScript(baseName, strDirBin)
    With objfs.CreateTextFile(strDirShims &"\"& baseName)
        .WriteLine("#!/bin/sh")
        .WriteLine("export PATH="& strDirBin &"/Scripts:"& strDirBin &":$PATH")
        .WriteLine(baseName &" $*")
        .Close
    End With
End Sub

Sub Rehash()
    Dim file

    If Not objfs.FolderExists(strDirShims) Then objfs.CreateFolder(strDirShims)
    For Each file In objfs.GetFolder(strDirShims).Files
        file.Delete True
    Next

    Dim winBinDir, nixBinDir
    Dim exts
    Dim baseName
    winBinDir = GetBinDir(GetCurrentVersion()(0))
    nixBinDir = "/"& Replace(Replace(winBinDir, ":", ""), "\", "/")
    Set exts = GetExtensionsNoPeriod(True)

    For Each file In objfs.GetFolder(winBinDir).Files
        If exts.Contains(LCase(objfs.GetExtensionName(file))) Then
            baseName = objfs.GetBaseName(file)
            WriteWinScript baseName, winBinDir
            WriteLinuxScript baseName, nixBinDir
        End If
    Next

    If objfs.FolderExists(winBinDir & "\Scripts") Then
        For Each file In objfs.GetFolder(winBinDir & "\Scripts").Files
            If exts.Contains(LCase(objfs.GetExtensionName(file))) Then
                baseName = objfs.GetBaseName(file)
                WriteWinScript baseName, winBinDir
                WriteLinuxScript baseName, nixBinDir
            End If
        Next
    End If
End Sub
