Option Explicit

Dim objfs
Dim objws
Dim objweb

Set objfs = CreateObject("Scripting.FileSystemObject")
Set objws = WScript.CreateObject("WScript.Shell")
Set objweb = CreateObject("MSXML2.XMLHTTP.6.0")

Dim strCurrent
Dim strPyenvHome
Dim strPyenvParent
Dim strDirCache
Dim strDirVers
Dim strDirLibs
Dim strDirShims
Dim strVerFile
strCurrent   = objfs.GetAbsolutePathName(".")
strPyenvHome = objfs.getParentFolderName(objfs.getParentFolderName(WScript.ScriptFullName))
strPyenvParent = objfs.getParentFolderName(strPyenvHome)
strDirCache  = strPyenvHome & "\install_cache"
strDirVers   = strPyenvHome & "\versions"
strDirLibs   = strPyenvHome & "\libexec"
strDirShims  = strPyenvHome & "\shims"
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
