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
strCurrent   = objfs.GetAbsolutePathName(".")
strPyenvHome = objfs.getParentFolderName(objfs.getParentFolderName(WScript.ScriptFullName))
strDirCache  = strPyenvHome & "\install_cache"
strDirVers   = strPyenvHome & "\versions"
strDirLibs   = strPyenvHome & "\libexec"


Sub ShowHelp()
     Wscript.echo "Usage: pyenv install [-f|-s] <version>"
     Wscript.echo "       pyenv install [-f|-s] <definition-file>"
     Wscript.echo "       pyenv install -l|--list"
     Wscript.echo ""
     Wscript.echo "  -l/--list          List all available versions"
     Wscript.echo "  -f/--force         Install even if the version appears to be installed already"
     Wscript.echo "  -s/--skip-existing Skip if the version appears to be installed already"
     Wscript.echo ""
     Wscript.Quit
End Sub

Dim listEnv
listEnv = Array(_
    Array("3.7.2-x64",  "https://www.python.org/ftp/python/3.7.2/", "python-3.7.2-amd64.exe","x64"),_
    Array("3.7.2",      "https://www.python.org/ftp/python/3.7.2/", "python-3.7.2.exe",      "i386"),_
    Array("3.6.8-x64",  "https://www.python.org/ftp/python/3.6.8/", "python-3.6.8-amd64.exe","x64"),_
    Array("3.6.8",      "https://www.python.org/ftp/python/3.6.8/", "python-3.6.8.exe",      "i386" )_
)

Function DownloadFile(strUrl,strFile)
    Dim objHttp
    Dim httpProxy
    Set objHttp = Wscript.CreateObject("Msxml2.ServerXMLHTTP")
    on error resume next
    Call objHttp.Open("GET", strUrl, False )
    if Err.Number <> 0 then
        Wscript.Echo Err.Description
        Wscript.Quit
    end if
    httpProxy = objws.ExpandEnvironmentStrings("%http_proxy%")
    if httpProxy <> "" AND httpProxy <> "%http_proxy%" Then
        objHttp.setProxy 2, httpProxy
    end if
    objHttp.Send

    if Err.Number <> 0 then
        Wscript.Echo Err.Description
        Wscript.Quit
    end if
    on error goto 0
    if objHttp.status = 404 then
        Wscript.Echo "404:file not found"
        Wscript.Quit
    end if

    Dim Stream
    Set Stream = Wscript.CreateObject("ADODB.Stream")
    Stream.Open
    Stream.Type = 1
    Stream.Write objHttp.responseBody
    Stream.SaveToFile strFile, 2
    Stream.Close
End Function

Sub clear(cur)
    If objfs.FolderExists(cur(1)) Then objfs.DeleteFolder cur(1),True 
    If objfs.FileExists(  cur(2)) Then objfs.DeleteFile   cur(2),True 
End Sub

Sub download(cur)
    Wscript.echo "download " & cur(0) & " ..."
    DownloadFile cur(3) , cur(2)
End Sub

Sub extract(cur)
    If Not objfs.FolderExists( strDirCache ) Then objfs.CreateFolder(strDirCache)
    If Not objfs.FolderExists( strDirVers  ) Then objfs.CreateFolder(strDirVers )

    If objfs.FolderExists(cur(1)) Then Exit Sub

    If Not objfs.FileExists(cur(2)) Then download(cur)

     Wscript.echo "install " & cur(0) & " ..."

    objws.CurrentDirectory = strDirCache
    objws.Run cur(2) & " InstallAllUsers=0 Include_launcher=0 Include_test=0 SimpleInstall=1 TargetDir=" & cur(1), 0, true

    Wscript.echo "complete! " & cur(0)

End Sub

Function GetCurrentVersionGlobal()
    GetCurrentVersionGlobal = Null

    Dim fname
    Dim objFile
    fname = strRbenvHome & "\version"
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
        fname = path & "\.rbenv_version"
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
    str=objws.ExpandEnvironmentStrings("%RBENV_VERSION%")
    If str <> "%RBENV_VERSION%" Then
        GetCurrentVersionShell = Array(str,"%RBENV_VERSION%")
    End If
End Function

Function GetCurrentVersionNoError()
    Dim str
    str=GetCurrentVersionShell
    If IsNull(str) Then str = GetCurrentVersionLocal(strCurrent)
    If IsNull(str) Then str = GetCurrentVersionGlobal
    GetCurrentVersionNoError = str
End Function

Sub main(arg)
    If arg.Count = 0 Then ShowHelp

    Dim idx
    Dim optForce
    Dim optSkip
    Dim optList
    Dim version

    optForce=False
    optSkip=False
    optList=False
    version=""

    For idx = 0 To arg.Count - 1
        Select Case arg(idx)
           Case "--help"          ShowHelp
           Case "-l"              optList=True
           Case "--list"          optList=True
           Case "-f"              optForce=True
           Case "--force"         optForce=True
           Case "-s"              optSkip=True
           Case "--skip-existing" optSkip=True
           Case Else
               version = arg(idx)
               Exit For
        End Select
    Next

    If version = "" Then
        version=GetCurrentVersionNoError()(0)
    End If

    Dim list
    Dim cur
    If optList Then
        For Each list In listEnv
            Wscript.echo list(0)
        Next
        Exit Sub
    ElseIf version <> "" Then
        For Each list In listEnv
            If list(0) = version Then
                cur=Array(list(0),strDirVers&"\"&list(0),strDirCache&"\"&list(2),list(1)&list(2),list(3))
                If optForce Then  clear(cur)
                extract(cur)
                Exit Sub
            End If
        Next
        Wscript.echo "pyenv-install: definition not found: " & version
        Wscript.echo ""
        Wscript.echo "See all available versions with `pyenv install --list'."
    Else
        ShowHelp
    End If
End Sub

main(WScript.Arguments)

