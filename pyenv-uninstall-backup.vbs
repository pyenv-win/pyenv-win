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
        ans="y"
        If Not optForce Then 
            Wscript.StdOut.Write "pyenv: remove "&str&"? "
            ans=WScript.StdIn.ReadLine
        End If
    Else
        If Not optForce Then Wscript.echo "pyenv: version `"&version&"' not installed"
        Wscript.Quit
    End If

    If ans="y" Or ans="Y" Then objfs.DeleteFolder str , True
End Sub

main(WScript.Arguments)