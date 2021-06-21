Option Explicit

Dim objfs
Dim objws
Dim objweb

' WScript.echo "kkotari: pyenv-lib.vbs..!"
Set objfs = CreateObject("Scripting.FileSystemObject")
Set objws = WScript.CreateObject("WScript.Shell")
Set objweb = CreateObject("WinHttp.WinHttpRequest.5.1")

' Set proxy settings, called on library import for objweb.
Sub SetProxy()
    ' WScript.echo "kkotari: pyenv-lib.vbs proxy..!"
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
    ' WScript.echo "kkotari: pyenv-lib.vbs get current version global..!"
    GetCurrentVersionGlobal = Null

    Dim fname
    Dim objFile
    fname = strPyenvHome & "\version"
    If objfs.FileExists(fname) Then
        Set objFile = objfs.OpenTextFile(fname)
        If objFile.AtEndOfStream <> True Then
           GetCurrentVersionGlobal = Array(objFile.ReadLine, fname)
        End If
        objFile.Close
    End If
End Function

Function GetCurrentVersionsLocal(path)
    ' WScript.echo "kkotari: pyenv-lib.vbs get current versions local..!"
    Dim fname
    Dim objFile
    Dim line
    ReDim versions(-1)
    Do While path <> ""
        fname = path & strVerFile
        If objfs.FileExists(fname) Then
            Set objFile = objfs.OpenTextFile(fname)
            Do While objFile.AtEndOfStream <> True
                line = objFile.ReadLine
                If line <> "" Then
                    ReDim Preserve versions (UBound(versions) + 1)
                    versions(UBound(versions)) = Array(line, fname)
                End If
            Loop
            objFile.Close
            Exit Do
        End If
        path = objfs.GetParentFolderName(path)
    Loop
    if UBound(versions) >= 0 Then
        GetCurrentVersionsLocal = versions
    Else
        GetCurrentVersionsLocal = Null
    End If
End Function

Function GetFirstVersionLocal(path)
    ' WScript.echo "kkotari: pyenv-lib.vbs get first version local..!"
    Dim versions
    versions = GetCurrentVersionsLocal(path)
    if IsNull(versions) Then
        GetFirstVersionLocal = Null
    Else
        GetFirstVersionLocal = versions(0)
    End If
End Function

Function GetCurrentVersionShell()
    ' WScript.echo "kkotari: pyenv-lib.vbs get current version shell..!"
    GetCurrentVersionShell = Null
    Dim str
    str = objws.Environment("Process")("PYENV_VERSION")
    If str <> "" Then _
        GetCurrentVersionShell = Array(str, "%PYENV_VERSION%")
End Function

Function GetCurrentVersion()
    ' WScript.echo "kkotari: pyenv-lib.vbs get current version..!"
    Dim str
    str = GetCurrentVersionNoError
    If IsNull(str) Then
		WScript.echo "No global python version has been set yet. Please set the global version by typing:"
		WScript.echo "pyenv global 3.7.2"
		WScript.quit
	End If
	GetCurrentVersion = str
End Function

Function GetCurrentVersionNoError()
    ' WScript.echo "kkotari: pyenv-lib.vbs get current version no error..!"
    Dim str
    str = GetCurrentVersionShell
    If IsNull(str) Then str = GetFirstVersionLocal(strCurrent)
    If IsNull(str) Then str = GetCurrentVersionGlobal
    GetCurrentVersionNoError = str
End Function

Function GetCurrentVersions()
    ' WScript.echo "kkotari: pyenv-lib.vbs get current versions..!"
    Dim versions
    Set versions = GetCurrentVersionsNoError
    If versions.Count = 0 Then
		WScript.echo "No global python version has been set yet. Please set the global version by typing:"
		WScript.echo "pyenv global 3.7.2"
		WScript.quit
	End If
	Set GetCurrentVersions = versions
End Function

Function GetCurrentVersionsNoError()
    ' WScript.echo "kkotari: pyenv-lib.vbs get current version no error..!"
    Dim versions
    Set versions = CreateObject("Scripting.Dictionary")
    Dim str
    str = GetCurrentVersionShell
    If Not(IsNull(str)) Then
        versions.Add str(0), str(1)
    Else
        str = GetCurrentVersionsLocal(strCurrent)
        If Not(IsNull(str)) Then
            Dim v1
            For Each v1 in str
                versions.Add v1(0), v1(1)
            Next
        End If
    End If
    If IsNull(str) Then
        str = GetCurrentVersionGlobal
        If Not(IsNull(str)) Then versions.Add str(0), str(1)
    End If
    Set GetCurrentVersionsNoError = versions
End Function

Function GetInstalledVersions()
    ' WScript.echo "kkotari: pyenv-lib.vbs get installed versions..!"
    Dim rootBinDir, winBinDir, version, versions()
    ReDim Preserve versions(0)
    If objfs.FolderExists(strDirVers) Then
        Set rootBinDir = objfs.GetFolder(strDirVers)
        For Each winBinDir in rootBinDir.SubFolders
            version = winBinDir.Name
            ReDim Preserve versions(UBound(versions) + 1)
            versions(UBound(versions)) = version
        Next
    End If
    GetInstalledVersions = versions
End Function

Function IsVersion(version)
    ' WScript.echo "kkotari: pyenv-lib.vbs is version..!"
    Dim re
    Set re = new regexp
    re.Pattern = "^[a-zA-Z_0-9-.]+$"
    IsVersion = re.Test(version)
End Function

Function GetBinDir(ver)
    ' WScript.echo "kkotari: pyenv-lib.vbs get bin dir..!"
    Dim str
    str = strDirVers &"\"& ver
    If Not(IsVersion(ver) And objfs.FolderExists(str)) Then
		WScript.Echo "pyenv specific python requisite didn't meet. Project is using different version of python."
		WScript.Echo "Install python '"& ver &"' by typing: 'pyenv install "& ver &"'"
		WScript.Quit
	End If
    GetBinDir = str
End Function

' pyenv set global python version 
Sub SetGlobalVersion(ver)
    ' WScript.echo "kkotari: pyenv-lib.vbs set global version..!"
    GetBinDir(ver)

    With objfs.CreateTextFile(strPyenvHome &"\version" , True)
        .WriteLine(ver)
        .Close
    End With
End Sub

Function GetExtensions(addPy)
    ' WScript.echo "kkotari: pyenv-lib.vbs get extensions..!"
    Dim exts
    exts = ";"& objws.Environment("Process")("PATHEXT") &";"
    Set GetExtensions = CreateObject("Scripting.Dictionary")

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
        GetExtensions.Item(ext) = Empty
    Next
End Function

Function GetExtensionsNoPeriod(addPy)
    ' WScript.echo "kkotari: pyenv-lib.vbs get extension no period..!"
    Dim key
    Set GetExtensionsNoPeriod = GetExtensions(addPy)
    For Each key In GetExtensionsNoPeriod.Keys
        If Left(key, 1) = "." Then
            GetExtensionsNoPeriod.Key(key) = LCase(Mid(key, 2))
        Else
            GetExtensionsNoPeriod.Key(key) = LCase(key)
        End If
    Next
End Function

' pyenv - bin - windows
Sub WriteWinScript(baseName, extension, strDirBin)
    ' WScript.echo "kkotari: pyenv-lib.vbs write win script..!"
    Dim filespec
    filespec = strDirShims &"\"& baseName &".bat"
    If Not objfs.FileExists(filespec) Then
        With objfs.CreateTextFile(filespec)
            .WriteLine("@echo off")
            .WriteLine("chcp 1250 > NUL")
            .WriteLine("call pyenv exec "&strDirBin&baseName&"."&extension&" %*")
            .Close
        End With
    End If
End Sub

' pyenv - bin - linux
Sub WriteLinuxScript(baseName, strDirBin)
    ' WScript.echo "kkotari: pyenv-lib.vbs write linux script..!"
    Dim filespec
    filespec = strDirShims &"\"& baseName
    If Not objfs.FileExists(filespec) Then
        With objfs.CreateTextFile(filespec)
            .WriteLine("#!/bin/sh")
            .WriteLine("pyenv exec "&strDirBin&"$(basename ""$0"") ""$@""")
            .Close
        End With
    End If
End Sub

' pyenv rehash
Sub Rehash()
    ' WScript.echo "kkotari: pyenv-lib.vbs pyenv rehash..!"
    Dim file

    If Not objfs.FolderExists(strDirShims) Then objfs.CreateFolder(strDirShims)
    For Each file In objfs.GetFolder(strDirShims).Files
        file.Delete True
    Next

    Dim version
    Dim winBinDir, nixBinDir
    Dim exts
    Dim baseName, extension

    For Each version In GetInstalledVersions()
        winBinDir = strDirVers &"\"& version
        nixBinDir = "/"& Replace(Replace(winBinDir, ":", ""), "\", "/")
        Set exts = GetExtensionsNoPeriod(True)

        For Each file In objfs.GetFolder(winBinDir).Files
            ' WScript.echo "kkotari: pyenv-lib.vbs rehash for winBinDir"
            If exts.Exists(LCase(objfs.GetExtensionName(file))) Then
                baseName = objfs.GetBaseName(file)
                extension = objfs.GetExtensionName(file)
                WriteWinScript baseName, extension, ""
                WriteLinuxScript baseName, ""
            End If
        Next

        If objfs.FolderExists(winBinDir & "\Scripts") Then
            For Each file In objfs.GetFolder(winBinDir & "\Scripts").Files
                ' WScript.echo "kkotari: pyenv-lib.vbs rehash for winBinDir\Scripts"
                If exts.Exists(LCase(objfs.GetExtensionName(file))) Then
                    baseName = objfs.GetBaseName(file)
                    extension = objfs.GetExtensionName(file)
                    WriteWinScript baseName, extension, "Scripts/"
                    WriteLinuxScript baseName, "Scripts/"
                End If
            Next
        End If
    Next
End Sub

' SYSTEM:PROCESSOR_ARCHITECTURE = AMD64 on 64-bit computers. (even when using 32-bit cmd.exe)
Function Is32Bit()
    ' WScript.echo "kkotari: pyenv-lib.vbs is32bit..!"
    Dim arch
    arch = objws.Environment("Process")("PYENV_FORCE_ARCH")
    If arch = "" Then arch = objws.Environment("System")("PROCESSOR_ARCHITECTURE")
    Is32Bit = (UCase(arch) = "X86")
End Function

' If on a 32bit computer, default to -win32 versions.
Function Check32Bit(version)
    ' WScript.echo "kkotari: pyenv-lib.vbs check32bit..!"
    If Is32Bit And Right(LCase(version), 6) <> "-win32" Then _
        version = version & "-win32"
    Check32Bit = version
End Function
