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
Dim strDirWiX
Dim strDBFile
Dim strVerFile
strCurrent   = objfs.GetAbsolutePathName(".")
strPyenvHome = objfs.getParentFolderName(objfs.getParentFolderName(WScript.ScriptFullName))
strPyenvParent = objfs.getParentFolderName(strPyenvHome)
strDirCache  = strPyenvHome & "\install_cache"
strDirVers   = strPyenvHome & "\versions"
strDirLibs   = strPyenvHome & "\libexec"
strDirShims  = strPyenvHome & "\shims"
strDirWiX    = strPyenvHome & "\bin\WiX"
strDBFile    = strPyenvHome & "\.versions_cache.xml"
strVerFile   = "\.python-version"

Function GetCurrentVersionsGlobal()
    ' WScript.echo "kkotari: pyenv-lib.vbs get current versions global..!"
    Dim fname
    Dim objFile
    Dim line
    ReDim versions(-1)
    fname = strPyenvHome & "\version"
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
    End If
    if UBound(versions) >= 0 Then
        GetCurrentVersionsGlobal = versions
    Else
        GetCurrentVersionsGlobal = Null
    End If
End Function

Function GetFirstVersionGlobal()
    ' WScript.echo "kkotari: pyenv-lib.vbs get first version global..!"
    Dim versions
    versions = GetCurrentVersionsGlobal
    if IsNull(versions) Then
        GetFirstVersionGlobal = Null
    Else
        GetFirstVersionGlobal = versions(0)
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

Function GetCurrentVersionsShell()
    ' WScript.echo "kkotari: pyenv-lib.vbs get current versions shell..!"
    Dim ver
    Dim pyenv_version
    ReDim versions(-1)
    pyenv_version = objws.Environment("Process")("PYENV_VERSION")
    If pyenv_version <> "" Then
        For Each ver In Split(pyenv_version)
            ReDim Preserve versions (UBound(versions) + 1)
            versions(UBound(versions)) = Array(ver, "%PYENV_VERSION%")
        Next
    End If
    if UBound(versions) >= 0 Then
        GetCurrentVersionsShell = versions
    Else
        GetCurrentVersionsShell = Null
    End If
End Function

Function GetFirstVersionShell()
    ' WScript.echo "kkotari: pyenv-lib.vbs get first version shell..!"
    Dim versions
    versions = GetCurrentVersionsShell
    if IsNull(versions) Then
        GetFirstVersionShell = Null
    Else
        GetFirstVersionShell = versions(0)
    End If
End Function

Function GetCurrentVersion()
    ' WScript.echo "kkotari: pyenv-lib.vbs get current version..!"
    Dim str
    str = GetCurrentVersionNoError
    If IsNull(str) Then
		WScript.echo "No global/local python version has been set yet. Please set the global/local version by typing:"
		WScript.echo "pyenv global 3.7.4"
        WScript.echo "pyenv local 3.7.4"
    WScript.quit 1
	End If
	GetCurrentVersion = str
End Function

Function GetCurrentVersionNoError()
    ' WScript.echo "kkotari: pyenv-lib.vbs get current version no error..!"
    Dim str
    str = GetFirstVersionShell
    If IsNull(str) Then str = GetFirstVersionLocal(strCurrent)
    If IsNull(str) Then str = GetFirstVersionGlobal
    GetCurrentVersionNoError = str
End Function

Function GetCurrentVersions()
    ' WScript.echo "kkotari: pyenv-lib.vbs get current versions..!"
    Dim versions
    Set versions = GetCurrentVersionsNoError
    If versions.Count = 0 Then
		WScript.echo "No global/local python version has been set yet. Please set the global/local version by typing:"
		WScript.echo "pyenv global 3.7.4"
        WScript.echo "pyenv local 3.7.4"
    WScript.quit 1
	End If
	Set GetCurrentVersions = versions
End Function

Function GetCurrentVersionsNoError()
    ' WScript.echo "kkotari: pyenv-lib.vbs get current version no error..!"
    Dim versions
    Set versions = CreateObject("Scripting.Dictionary")
    Dim str
    Dim v1
    str = GetCurrentVersionsShell
    If Not(IsNull(str)) Then
        For Each v1 in str
            versions.Add v1(0), v1(1)
        Next
    Else
        str = GetCurrentVersionsLocal(strCurrent)
        If Not(IsNull(str)) Then
            For Each v1 in str
                versions.Add v1(0), v1(1)
            Next
        End If
    End If
    If IsNull(str) Then
        str = GetCurrentVersionsGlobal
        If Not(IsNull(str)) Then
            For Each v1 in str
                versions.Add v1(0), v1(1)
            Next
        End If
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
		WScript.Quit 1
	End If
    GetBinDir = str
End Function

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
Sub WriteWinScript(baseName)
    ' WScript.echo "kkotari: pyenv-lib.vbs write win script..!"
    Dim filespec
    filespec = strDirShims &"\"& baseName &".bat"
    If Not objfs.FileExists(filespec) Then
        If InStr(1, baseName, "pip") = 1 Then
            With objfs.CreateTextFile(filespec)
                .WriteLine("@echo off")
                .WriteLine("chcp 1250 > NUL")
                .WriteLine("call pyenv exec %~n0 %*")
                .WriteLine("call pyenv rehash")
                .Close
            End With
        Else
            With objfs.CreateTextFile(filespec)
                .WriteLine("@echo off")
                .WriteLine("chcp 1250 > NUL")
                .WriteLine("call pyenv exec %~n0 %*")
                .Close
            End With
        End If
    End If
End Sub

' pyenv - bin - linux
Sub WriteLinuxScript(baseName)
    ' WScript.echo "kkotari: pyenv-lib.vbs write linux script..!"
    Dim filespec
    filespec = strDirShims &"\"& baseName
    If Not objfs.FileExists(filespec) Then
        If InStr(1, baseName, "pip") = 1 Then
            With objfs.CreateTextFile(filespec)
                .WriteLine("#!/bin/sh")
                .WriteLine("pyenv exec $(basename ""$0"") ""$@""")
                .WriteLine("pyenv rehash")
                .Close
            End With
        Else
            With objfs.CreateTextFile(filespec)
                .WriteLine("#!/bin/sh")
                .WriteLine("pyenv exec $(basename ""$0"") ""$@""")
                .Close
            End With
        End If
        
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
    Dim baseName

    For Each version In GetInstalledVersions()
        winBinDir = strDirVers &"\"& version
        nixBinDir = "/"& Replace(Replace(winBinDir, ":", ""), "\", "/")
        Set exts = GetExtensionsNoPeriod(True)

        For Each file In objfs.GetFolder(winBinDir).Files
            ' WScript.echo "kkotari: pyenv-lib.vbs rehash for winBinDir"
            If exts.Exists(LCase(objfs.GetExtensionName(file))) Then
                baseName = objfs.GetBaseName(file)
                WriteWinScript baseName
                WriteLinuxScript baseName
            End If
        Next

        If objfs.FolderExists(winBinDir & "\Scripts") Then
            For Each file In objfs.GetFolder(winBinDir & "\Scripts").Files
                ' WScript.echo "kkotari: pyenv-lib.vbs rehash for winBinDir\Scripts"
                If exts.Exists(LCase(objfs.GetExtensionName(file))) Then
                    baseName = objfs.GetBaseName(file)
                    WriteWinScript baseName
                    WriteLinuxScript baseName
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
