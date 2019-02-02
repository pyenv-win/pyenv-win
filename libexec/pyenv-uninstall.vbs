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

Sub ShowHelp()
     Wscript.echo "Usage: pyenv uninstall [-f|--force] <version>"
     Wscript.echo ""
     Wscript.echo "   -f  Attempt to remove the specified version without prompting"
     Wscript.echo "       for confirmation. If the version does not exist, do not"
     Wscript.echo "       display an error message."
     Wscript.echo ""
     Wscript.echo "See `pyenv versions` for a complete list of installed versions."
     Wscript.echo ""
     Wscript.Quit
End Sub

Dim listEnv
listEnv = Array(_
    Array("3.7.2",  "https://www.python.org/ftp/python/3.7.2/", "python-3.7.2-amd64.exe", "x64"),_
    Array("3.7.2-x86",      "https://www.python.org/ftp/python/3.7.2/", "python-3.7.2.exe", "i386"),_
    Array("3.6.8",  "https://www.python.org/ftp/python/3.6.8/", "python-3.6.8-amd64.exe", "x64"),_
    Array("3.6.8-x86",      "https://www.python.org/ftp/python/3.6.8/", "python-3.6.8.exe", "i386" )_
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
        Wscript.Echo ":: [ERROR] :: 404 :: file not found"
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
    If objfs.FileExists(cur(2)) Then objfs.DeleteFile   cur(2),True 
End Sub

Sub download(cur)
    Wscript.echo ":: [Downloading] ::  " & cur(0) & " ..."
    DownloadFile cur(3) , cur(2)
End Sub

Sub extract(cur)
    If Not objfs.FolderExists( strDirCache ) Then objfs.CreateFolder(strDirCache)
    If Not objfs.FolderExists( strDirVers  ) Then objfs.CreateFolder(strDirVers )

    If objfs.FolderExists(cur(1)) Then Exit Sub

    If Not objfs.FileExists(cur(2)) Then download(cur)

      Wscript.echo ":: [Un-installing] ::  " & cur(0) & " ..."

    objws.CurrentDirectory = strDirCache
    objws.Run cur(2) & " /uninstall ", 0, true

    Wscript.echo ":: [Info] :: completed! " & cur(0)

End Sub

Function IsVersion(version)
    Dim re
    Set re = new regexp
    re.Pattern = "^[a-zA-Z_0-9-.]+$"
    IsVersion = re.Test(version)
End Function

Sub main(arg)
    If arg.Count = 0 Then ShowHelp

    Dim idx
    Dim optForce
    Dim version

    optForce=False
    version=""

    For idx = 0 To arg.Count - 1
        Select Case arg(idx)
           Case "--help"          ShowHelp
           Case "-f"              optForce=True
           Case "--force"         optForce=True
           Case Else
               version = arg(idx)
               Exit For
        End Select
    Next

    Dim str,ans
    ans=""
    str=strDirVers&"\"&version
    If IsVersion(version) And objfs.FolderExists(str) Then
        For Each list In listEnv
            If list(0) = version Then
                cur=Array(list(0),strDirVers&"\"&list(0),strDirCache&"\"&list(2),list(1)&list(2),list(3))
                If optForce Then  clear(cur)
                extract(cur)
                Exit Sub
            End If
        Next
    Else
      Wscript.echo "pyenv: version '"&version&"' not installed"
    End If

End Sub

main(WScript.Arguments)

