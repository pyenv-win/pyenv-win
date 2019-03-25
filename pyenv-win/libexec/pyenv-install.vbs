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
     WScript.echo "Usage: pyenv install [-f|-s] <version>"
     WScript.echo "       pyenv install [-f|-s] <definition-file>"
     WScript.echo "       pyenv install -l|--list"
     WScript.echo ""
     WScript.echo "  -l/--list          List all available versions"
     WScript.echo "  -f/--force         Install even if the version appears to be installed already"
     WScript.echo "  -s/--skip-existing Skip if the version appears to be installed already"
     WScript.echo ""
     WScript.Quit
End Sub

Dim listEnv
listEnv = Array(_
    Array("3.7.2", "https://www.python.org/ftp/python/3.7.2/", "python-3.7.2.exe", "i386"),_
    Array("3.7.2-amd64", "https://www.python.org/ftp/python/3.7.2/", "python-3.7.2-amd64.exe", "x64"),_
    Array("3.6.8", "https://www.python.org/ftp/python/3.6.8/", "python-3.6.8.exe", "i386"),_
    Array("3.6.8-amd64", "https://www.python.org/ftp/python/3.6.8/", "python-3.6.8-amd64.exe", "x64"),_
    Array("3.7.2rc1", "https://www.python.org/ftp/python/3.7.2/", "python-3.7.2rc1.exe", "i386"),_
    Array("3.7.2rc1-amd64", "https://www.python.org/ftp/python/3.7.2/", "python-3.7.2rc1-amd64.exe", "x64"),_
    Array("3.6.8rc1", "https://www.python.org/ftp/python/3.6.8/", "python-3.6.8rc1.exe", "i386"),_
    Array("3.6.8rc1-amd64", "https://www.python.org/ftp/python/3.6.8/", "python-3.6.8rc1-amd64.exe", "x64"),_
    Array("3.7.1", "https://www.python.org/ftp/python/3.7.1/", "python-3.7.1.exe", "i386"),_
    Array("3.7.1-amd64", "https://www.python.org/ftp/python/3.7.1/", "python-3.7.1-amd64.exe", "x64"),_
    Array("3.6.7", "https://www.python.org/ftp/python/3.6.7/", "python-3.6.7.exe", "i386"),_
    Array("3.6.7-amd64", "https://www.python.org/ftp/python/3.6.7/", "python-3.6.7-amd64.exe", "x64"),_
    Array("3.7.1rc2", "https://www.python.org/ftp/python/3.7.1/", "python-3.7.1rc2.exe", "i386"),_
    Array("3.7.1rc2-amd64", "https://www.python.org/ftp/python/3.7.1/", "python-3.7.1rc2-amd64.exe", "x64"),_
    Array("3.6.7rc2", "https://www.python.org/ftp/python/3.6.7/", "python-3.6.7rc2.exe", "i386"),_
    Array("3.6.7rc2-amd64", "https://www.python.org/ftp/python/3.6.7/", "python-3.6.7rc2-amd64.exe", "x64"),_
    Array("3.7.1rc1", "https://www.python.org/ftp/python/3.7.1/", "python-3.7.1rc1.exe", "i386"),_
    Array("3.7.1rc1-amd64", "https://www.python.org/ftp/python/3.7.1/", "python-3.7.1rc1-amd64.exe", "x64"),_
    Array("3.6.7rc1", "https://www.python.org/ftp/python/3.6.7/", "python-3.6.7rc1.exe", "i386"),_
    Array("3.6.7rc1-amd64", "https://www.python.org/ftp/python/3.6.7/", "python-3.6.7rc1-amd64.exe", "x64"),_
    Array("3.7.0", "https://www.python.org/ftp/python/3.7.0/", "python-3.7.0.exe", "i386"),_
    Array("3.7.0-amd64", "https://www.python.org/ftp/python/3.7.0/", "python-3.7.0-amd64.exe", "x64"),_
    Array("3.6.6", "https://www.python.org/ftp/python/3.6.6/", "python-3.6.6.exe", "i386"),_
    Array("3.6.6-amd64", "https://www.python.org/ftp/python/3.6.6/", "python-3.6.6-amd64.exe", "x64"),_
    Array("3.6.6rc1", "https://www.python.org/ftp/python/3.6.6/", "python-3.6.6rc1.exe", "i386"),_
    Array("3.6.6rc1-amd64", "https://www.python.org/ftp/python/3.6.6/", "python-3.6.6rc1-amd64.exe", "x64"),_
    Array("3.7.0rc1", "https://www.python.org/ftp/python/3.7.0/", "python-3.7.0rc1.exe", "i386"),_
    Array("3.7.0rc1-amd64", "https://www.python.org/ftp/python/3.7.0/", "python-3.7.0rc1-amd64.exe", "x64"),_
    Array("3.7.0b5", "https://www.python.org/ftp/python/3.7.0/", "python-3.7.0b5.exe", "i386"),_
    Array("3.7.0b5-amd64", "https://www.python.org/ftp/python/3.7.0/", "python-3.7.0b5-amd64.exe", "x64"),_
    Array("3.7.0b4", "https://www.python.org/ftp/python/3.7.0/", "python-3.7.0b4.exe", "i386"),_
    Array("3.7.0b4-amd64", "https://www.python.org/ftp/python/3.7.0/", "python-3.7.0b4-amd64.exe", "x64"),_
    Array("2.7.15", "https://www.python.org/ftp/python/2.7.15/", "python-2.7.15.msi", "i386"),_
    Array("2.7.15.amd64", "https://www.python.org/ftp/python/2.7.15/", "python-2.7.15.amd64.msi", "x64"),_
    Array("2.7.15rc1", "https://www.python.org/ftp/python/2.7.15/", "python-2.7.15rc1.msi", "i386"),_
    Array("2.7.15rc1.amd64", "https://www.python.org/ftp/python/2.7.15/", "python-2.7.15rc1.amd64.msi", "x64"),_
    Array("3.7.0b3", "https://www.python.org/ftp/python/3.7.0/", "python-3.7.0b3.exe", "i386"),_
    Array("3.7.0b3-amd64", "https://www.python.org/ftp/python/3.7.0/", "python-3.7.0b3-amd64.exe", "x64"),_
    Array("3.6.5", "https://www.python.org/ftp/python/3.6.5/", "python-3.6.5.exe", "i386"),_
    Array("3.6.5-amd64", "https://www.python.org/ftp/python/3.6.5/", "python-3.6.5-amd64.exe", "x64"),_
    Array("3.6.5rc1", "https://www.python.org/ftp/python/3.6.5/", "python-3.6.5rc1.exe", "i386"),_
    Array("3.6.5rc1-amd64", "https://www.python.org/ftp/python/3.6.5/", "python-3.6.5rc1-amd64.exe", "x64"),_
    Array("3.7.0b2", "https://www.python.org/ftp/python/3.7.0/", "python-3.7.0b2.exe", "i386"),_
    Array("3.7.0b2-amd64", "https://www.python.org/ftp/python/3.7.0/", "python-3.7.0b2-amd64.exe", "x64"),_
    Array("3.7.0b1", "https://www.python.org/ftp/python/3.7.0/", "python-3.7.0b1.exe", "i386"),_
    Array("3.7.0b1-amd64", "https://www.python.org/ftp/python/3.7.0/", "python-3.7.0b1-amd64.exe", "x64"),_
    Array("3.7.0a4", "https://www.python.org/ftp/python/3.7.0/", "python-3.7.0a4.exe", "i386"),_
    Array("3.7.0a4-amd64", "https://www.python.org/ftp/python/3.7.0/", "python-3.7.0a4-amd64.exe", "x64"),_
    Array("3.6.4", "https://www.python.org/ftp/python/3.6.4/", "python-3.6.4.exe", "i386"),_
    Array("3.6.4-amd64", "https://www.python.org/ftp/python/3.6.4/", "python-3.6.4-amd64.exe", "x64"),_
    Array("3.6.4rc1", "https://www.python.org/ftp/python/3.6.4/", "python-3.6.4rc1.exe", "i386"),_
    Array("3.6.4rc1-amd64", "https://www.python.org/ftp/python/3.6.4/", "python-3.6.4rc1-amd64.exe", "x64"),_
    Array("3.7.0a3", "https://www.python.org/ftp/python/3.7.0/", "python-3.7.0a3.exe", "i386"),_
    Array("3.7.0a3-amd64", "https://www.python.org/ftp/python/3.7.0/", "python-3.7.0a3-amd64.exe", "x64"),_
    Array("3.7.0a2", "https://www.python.org/ftp/python/3.7.0/", "python-3.7.0a2.exe", "i386"),_
    Array("3.7.0a2-amd64", "https://www.python.org/ftp/python/3.7.0/", "python-3.7.0a2-amd64.exe", "x64"),_
    Array("3.6.3", "https://www.python.org/ftp/python/3.6.3/", "python-3.6.3.exe", "i386"),_
    Array("3.6.3-amd64", "https://www.python.org/ftp/python/3.6.3/", "python-3.6.3-amd64.exe", "x64"),_
    Array("3.7.0a1", "https://www.python.org/ftp/python/3.7.0/", "python-3.7.0a1.exe", "i386"),_
    Array("3.7.0a1-amd64", "https://www.python.org/ftp/python/3.7.0/", "python-3.7.0a1-amd64.exe", "x64"),_
    Array("3.6.3rc1", "https://www.python.org/ftp/python/3.6.3/", "python-3.6.3rc1.exe", "i386"),_
    Array("3.6.3rc1-amd64", "https://www.python.org/ftp/python/3.6.3/", "python-3.6.3rc1-amd64.exe", "x64"),_
    Array("2.7.14", "https://www.python.org/ftp/python/2.7.14/", "python-2.7.14.msi", "i386"),_
    Array("2.7.14.amd64", "https://www.python.org/ftp/python/2.7.14/", "python-2.7.14.amd64.msi", "x64"),_
    Array("2.7.14rc1", "https://www.python.org/ftp/python/2.7.14/", "python-2.7.14rc1.msi", "i386"),_
    Array("2.7.14rc1.amd64", "https://www.python.org/ftp/python/2.7.14/", "python-2.7.14rc1.amd64.msi", "x64"),_
    Array("3.5.4", "https://www.python.org/ftp/python/3.5.4/", "python-3.5.4.exe", "i386"),_
    Array("3.5.4-amd64", "https://www.python.org/ftp/python/3.5.4/", "python-3.5.4-amd64.exe", "x64"),_
    Array("3.5.4rc1", "https://www.python.org/ftp/python/3.5.4/", "python-3.5.4rc1.exe", "i386"),_
    Array("3.5.4rc1-amd64", "https://www.python.org/ftp/python/3.5.4/", "python-3.5.4rc1-amd64.exe", "x64"),_
    Array("3.6.2", "https://www.python.org/ftp/python/3.6.2/", "python-3.6.2.exe", "i386"),_
    Array("3.6.2-amd64", "https://www.python.org/ftp/python/3.6.2/", "python-3.6.2-amd64.exe", "x64"),_
    Array("3.6.2rc2", "https://www.python.org/ftp/python/3.6.2/", "python-3.6.2rc2.exe", "i386"),_
    Array("3.6.2rc2-amd64", "https://www.python.org/ftp/python/3.6.2/", "python-3.6.2rc2-amd64.exe", "x64"),_
    Array("3.6.2rc1", "https://www.python.org/ftp/python/3.6.2/", "python-3.6.2rc1.exe", "i386"),_
    Array("3.6.2rc1-amd64", "https://www.python.org/ftp/python/3.6.2/", "python-3.6.2rc1-amd64.exe", "x64"),_
    Array("3.6.1", "https://www.python.org/ftp/python/3.6.1/", "python-3.6.1.exe", "i386"),_
    Array("3.6.1-amd64", "https://www.python.org/ftp/python/3.6.1/", "python-3.6.1-amd64.exe", "x64"),_
    Array("3.6.1rc1", "https://www.python.org/ftp/python/3.6.1/", "python-3.6.1rc1.exe", "i386"),_
    Array("3.6.1rc1-amd64", "https://www.python.org/ftp/python/3.6.1/", "python-3.6.1rc1-amd64.exe", "x64"),_
    Array("3.5.3", "https://www.python.org/ftp/python/3.5.3/", "python-3.5.3.exe", "i386"),_
    Array("3.5.3-amd64", "https://www.python.org/ftp/python/3.5.3/", "python-3.5.3-amd64.exe", "x64"),_
    Array("3.5.3rc1", "https://www.python.org/ftp/python/3.5.3/", "python-3.5.3rc1.exe", "i386"),_
    Array("3.5.3rc1-amd64", "https://www.python.org/ftp/python/3.5.3/", "python-3.5.3rc1-amd64.exe", "x64"),_
    Array("3.6.0", "https://www.python.org/ftp/python/3.6.0/", "python-3.6.0.exe", "i386"),_
    Array("3.6.0-amd64", "https://www.python.org/ftp/python/3.6.0/", "python-3.6.0-amd64.exe", "x64"),_
    Array("2.7.13", "https://www.python.org/ftp/python/2.7.13/", "python-2.7.13.msi", "i386"),_
    Array("2.7.13.amd64", "https://www.python.org/ftp/python/2.7.13/", "python-2.7.13.amd64.msi", "x64"),_
    Array("3.6.0rc2", "https://www.python.org/ftp/python/3.6.0/", "python-3.6.0rc2.exe", "i386"),_
    Array("3.6.0rc2-amd64", "https://www.python.org/ftp/python/3.6.0/", "python-3.6.0rc2-amd64.exe", "x64"),_
    Array("3.6.0rc1", "https://www.python.org/ftp/python/3.6.0/", "python-3.6.0rc1.exe", "i386"),_
    Array("3.6.0rc1-amd64", "https://www.python.org/ftp/python/3.6.0/", "python-3.6.0rc1-amd64.exe", "x64"),_
    Array("2.7.13rc1", "https://www.python.org/ftp/python/2.7.13/", "python-2.7.13rc1.msi", "i386"),_
    Array("2.7.13rc1.amd64", "https://www.python.org/ftp/python/2.7.13/", "python-2.7.13rc1.amd64.msi", "x64"),_
    Array("3.6.0b4", "https://www.python.org/ftp/python/3.6.0/", "python-3.6.0b4.exe", "i386"),_
    Array("3.6.0b4-amd64", "https://www.python.org/ftp/python/3.6.0/", "python-3.6.0b4-amd64.exe", "x64"),_
    Array("3.6.0b3", "https://www.python.org/ftp/python/3.6.0/", "python-3.6.0b3.exe", "i386"),_
    Array("3.6.0b3-amd64", "https://www.python.org/ftp/python/3.6.0/", "python-3.6.0b3-amd64.exe", "x64"),_
    Array("3.6.0b2", "https://www.python.org/ftp/python/3.6.0/", "python-3.6.0b2.exe", "i386"),_
    Array("3.6.0b2-amd64", "https://www.python.org/ftp/python/3.6.0/", "python-3.6.0b2-amd64.exe", "x64"),_
    Array("3.6.0b1", "https://www.python.org/ftp/python/3.6.0/", "python-3.6.0b1.exe", "i386"),_
    Array("3.6.0b1-amd64", "https://www.python.org/ftp/python/3.6.0/", "python-3.6.0b1-amd64.exe", "x64"),_
    Array("3.6.0a4", "https://www.python.org/ftp/python/3.6.0/", "python-3.6.0a4.exe", "i386"),_
    Array("3.6.0a4-amd64", "https://www.python.org/ftp/python/3.6.0/", "python-3.6.0a4-amd64.exe", "x64"),_
    Array("3.6.0a3", "https://www.python.org/ftp/python/3.6.0/", "python-3.6.0a3.exe", "i386"),_
    Array("3.6.0a3-amd64", "https://www.python.org/ftp/python/3.6.0/", "python-3.6.0a3-amd64.exe", "x64"),_
    Array("3.5.2", "https://www.python.org/ftp/python/3.5.2/", "python-3.5.2.exe", "i386"),_
    Array("3.5.2-amd64", "https://www.python.org/ftp/python/3.5.2/", "python-3.5.2-amd64.exe", "x64"),_
    Array("2.7.12", "https://www.python.org/ftp/python/2.7.12/", "python-2.7.12.msi", "i386"),_
    Array("2.7.12.amd64", "https://www.python.org/ftp/python/2.7.12/", "python-2.7.12.amd64.msi", "x64"),_
    Array("3.6.0a2", "https://www.python.org/ftp/python/3.6.0/", "python-3.6.0a2.exe", "i386"),_
    Array("3.6.0a2-amd64", "https://www.python.org/ftp/python/3.6.0/", "python-3.6.0a2-amd64.exe", "x64"),_
    Array("2.7.12rc1", "https://www.python.org/ftp/python/2.7.12/", "python-2.7.12rc1.msi", "i386"),_
    Array("2.7.12rc1.amd64", "https://www.python.org/ftp/python/2.7.12/", "python-2.7.12rc1.amd64.msi", "x64"),_
    Array("3.5.2rc1", "https://www.python.org/ftp/python/3.5.2/", "python-3.5.2rc1.exe", "i386"),_
    Array("3.5.2rc1-amd64", "https://www.python.org/ftp/python/3.5.2/", "python-3.5.2rc1-amd64.exe", "x64"),_
    Array("3.6.0a1", "https://www.python.org/ftp/python/3.6.0/", "python-3.6.0a1.exe", "i386"),_
    Array("3.6.0a1-amd64", "https://www.python.org/ftp/python/3.6.0/", "python-3.6.0a1-amd64.exe", "x64"),_
    Array("3.4.4", "https://www.python.org/ftp/python/3.4.4/", "python-3.4.4.msi", "i386"),_
    Array("3.4.4.amd64", "https://www.python.org/ftp/python/3.4.4/", "python-3.4.4.amd64.msi", "x64"),_
    Array("3.5.1", "https://www.python.org/ftp/python/3.5.1/", "python-3.5.1.exe", "i386"),_
    Array("3.5.1-amd64", "https://www.python.org/ftp/python/3.5.1/", "python-3.5.1-amd64.exe", "x64"),_
    Array("3.4.4rc1", "https://www.python.org/ftp/python/3.4.4/", "python-3.4.4rc1.msi", "i386"),_
    Array("3.4.4rc1.amd64", "https://www.python.org/ftp/python/3.4.4/", "python-3.4.4rc1.amd64.msi", "x64"),_
    Array("2.7.11", "https://www.python.org/ftp/python/2.7.11/", "python-2.7.11.msi", "i386"),_
    Array("2.7.11.amd64", "https://www.python.org/ftp/python/2.7.11/", "python-2.7.11.amd64.msi", "x64"),_
    Array("3.5.1rc1", "https://www.python.org/ftp/python/3.5.1/", "python-3.5.1rc1.exe", "i386"),_
    Array("3.5.1rc1-amd64", "https://www.python.org/ftp/python/3.5.1/", "python-3.5.1rc1-amd64.exe", "x64"),_
    Array("2.7.11rc1", "https://www.python.org/ftp/python/2.7.11/", "python-2.7.11rc1.msi", "i386"),_
    Array("2.7.11rc1.amd64", "https://www.python.org/ftp/python/2.7.11/", "python-2.7.11rc1.amd64.msi", "x64"),_
    Array("3.5.0", "https://www.python.org/ftp/python/3.5.0/", "python-3.5.0.exe", "i386"),_
    Array("3.5.0-amd64", "https://www.python.org/ftp/python/3.5.0/", "python-3.5.0-amd64.exe", "x64"),_
    Array("3.5.0rc4", "https://www.python.org/ftp/python/3.5.0/", "python-3.5.0rc4.exe", "i386"),_
    Array("3.5.0rc4-amd64", "https://www.python.org/ftp/python/3.5.0/", "python-3.5.0rc4-amd64.exe", "x64"),_
    Array("3.5.0rc3", "https://www.python.org/ftp/python/3.5.0/", "python-3.5.0rc3.exe", "i386"),_
    Array("3.5.0rc3-amd64", "https://www.python.org/ftp/python/3.5.0/", "python-3.5.0rc3-amd64.exe", "x64"),_
    Array("3.5.0rc2", "https://www.python.org/ftp/python/3.5.0/", "python-3.5.0rc2.exe", "i386"),_
    Array("3.5.0rc2-amd64", "https://www.python.org/ftp/python/3.5.0/", "python-3.5.0rc2-amd64.exe", "x64"),_
    Array("3.5.0rc1", "https://www.python.org/ftp/python/3.5.0/", "python-3.5.0rc1.exe", "i386"),_
    Array("3.5.0rc1-amd64", "https://www.python.org/ftp/python/3.5.0/", "python-3.5.0rc1-amd64.exe", "x64"),_
    Array("3.5.0b4", "https://www.python.org/ftp/python/3.5.0/", "python-3.5.0b4.exe", "i386"),_
    Array("3.5.0b4-amd64", "https://www.python.org/ftp/python/3.5.0/", "python-3.5.0b4-amd64.exe", "x64"),_
    Array("3.5.0b3", "https://www.python.org/ftp/python/3.5.0/", "python-3.5.0b3.exe", "i386"),_
    Array("3.5.0b3-amd64", "https://www.python.org/ftp/python/3.5.0/", "python-3.5.0b3-amd64.exe", "x64"),_
    Array("3.5.0b2", "https://www.python.org/ftp/python/3.5.0/", "python-3.5.0b2.exe", "i386"),_
    Array("3.5.0b2-amd64", "https://www.python.org/ftp/python/3.5.0/", "python-3.5.0b2-amd64.exe", "x64"),_
    Array("3.5.0b1", "https://www.python.org/ftp/python/3.5.0/", "python-3.5.0b1.exe", "i386"),_
    Array("3.5.0b1-amd64", "https://www.python.org/ftp/python/3.5.0/", "python-3.5.0b1-amd64.exe", "x64"),_
    Array("2.7.10", "https://www.python.org/ftp/python/2.7.10/", "python-2.7.10.msi", "i386"),_
    Array("2.7.10.amd64", "https://www.python.org/ftp/python/2.7.10/", "python-2.7.10.amd64.msi", "x64"),_
    Array("2.7.10rc1", "https://www.python.org/ftp/python/2.7.10/", "python-2.7.10rc1.msi", "i386"),_
    Array("2.7.10rc1.amd64", "https://www.python.org/ftp/python/2.7.10/", "python-2.7.10rc1.amd64.msi", "x64"),_
    Array("3.5.0a4", "https://www.python.org/ftp/python/3.5.0/", "python-3.5.0a4.exe", "i386"),_
    Array("3.5.0a4-amd64", "https://www.python.org/ftp/python/3.5.0/", "python-3.5.0a4-amd64.exe", "x64"),_
    Array("3.5.0a3", "https://www.python.org/ftp/python/3.5.0/", "python-3.5.0a3.exe", "i386"),_
    Array("3.5.0a3-amd64", "https://www.python.org/ftp/python/3.5.0/", "python-3.5.0a3-amd64.exe", "x64"),_
    Array("3.5.0a2", "https://www.python.org/ftp/python/3.5.0/", "python-3.5.0a2.exe", "i386"),_
    Array("3.5.0a2-amd64", "https://www.python.org/ftp/python/3.5.0/", "python-3.5.0a2-amd64.exe", "x64"),_
    Array("3.4.3", "https://www.python.org/ftp/python/3.4.3/", "python-3.4.3.msi", "i386"),_
    Array("3.4.3.amd64", "https://www.python.org/ftp/python/3.4.3/", "python-3.4.3.amd64.msi", "x64"),_
    Array("3.5.0a1", "https://www.python.org/ftp/python/3.5.0/", "python-3.5.0a1.exe", "i386"),_
    Array("3.5.0a1-amd64", "https://www.python.org/ftp/python/3.5.0/", "python-3.5.0a1-amd64.exe", "x64"),_
    Array("3.4.3rc1", "https://www.python.org/ftp/python/3.4.3/", "python-3.4.3rc1.msi", "i386"),_
    Array("3.4.3rc1.amd64", "https://www.python.org/ftp/python/3.4.3/", "python-3.4.3rc1.amd64.msi", "x64"),_
    Array("2.7.9", "https://www.python.org/ftp/python/2.7.9/", "python-2.7.9.msi", "i386"),_
    Array("2.7.9.amd64", "https://www.python.org/ftp/python/2.7.9/", "python-2.7.9.amd64.msi", "x64"),_
    Array("2.7.9rc1", "https://www.python.org/ftp/python/2.7.9/", "python-2.7.9rc1.msi", "i386"),_
    Array("2.7.9rc1.amd64", "https://www.python.org/ftp/python/2.7.9/", "python-2.7.9rc1.amd64.msi", "x64"),_
    Array("3.4.2", "https://www.python.org/ftp/python/3.4.2/", "python-3.4.2.msi", "i386"),_
    Array("3.4.2.amd64", "https://www.python.org/ftp/python/3.4.2/", "python-3.4.2.amd64.msi", "x64"),_
    Array("3.4.2rc1", "https://www.python.org/ftp/python/3.4.2/", "python-3.4.2rc1.msi", "i386"),_
    Array("3.4.2rc1.amd64", "https://www.python.org/ftp/python/3.4.2/", "python-3.4.2rc1.amd64.msi", "x64"),_
    Array("2.7.8", "https://www.python.org/ftp/python/2.7.8/", "python-2.7.8.msi", "i386"),_
    Array("2.7.8.amd64", "https://www.python.org/ftp/python/2.7.8/", "python-2.7.8.amd64.msi", "x64"),_
    Array("2.7.7", "https://www.python.org/ftp/python/2.7.7/", "python-2.7.7.msi", "i386"),_
    Array("2.7.7.amd64", "https://www.python.org/ftp/python/2.7.7/", "python-2.7.7.amd64.msi", "x64"),_
    Array("3.4.1", "https://www.python.org/ftp/python/3.4.1/", "python-3.4.1.msi", "i386"),_
    Array("3.4.1.amd64", "https://www.python.org/ftp/python/3.4.1/", "python-3.4.1.amd64.msi", "x64"),_
    Array("2.7.7rc1", "https://www.python.org/ftp/python/2.7.7/", "python-2.7.7rc1.msi", "i386"),_
    Array("2.7.7rc1.amd64", "https://www.python.org/ftp/python/2.7.7/", "python-2.7.7rc1.amd64.msi", "x64"),_
    Array("3.4.1rc1", "https://www.python.org/ftp/python/3.4.1/", "python-3.4.1rc1.msi", "i386"),_
    Array("3.4.1rc1.amd64", "https://www.python.org/ftp/python/3.4.1/", "python-3.4.1rc1.amd64.msi", "x64"),_
    Array("3.4.0", "https://www.python.org/ftp/python/3.4.0/", "python-3.4.0.msi", "i386"),_
    Array("3.4.0.amd64", "https://www.python.org/ftp/python/3.4.0/", "python-3.4.0.amd64.msi", "x64"),_
    Array("3.4.0rc3", "http://www.python.org/ftp/python/3.4.0/", "python-3.4.0rc3.msi", "i386"),_
    Array("3.4.0rc3.amd64", "http://www.python.org/ftp/python/3.4.0/", "python-3.4.0rc3.amd64.msi", "x64"),_
    Array("3.3.5", "http://www.python.org/ftp/python/3.3.5/", "python-3.3.5.msi", "i386"),_
    Array("3.3.5.amd64", "http://www.python.org/ftp/python/3.3.5/", "python-3.3.5.amd64.msi", "x64"),_
    Array("3.3.5rc2", "http://www.python.org/ftp/python/3.3.5/", "python-3.3.5rc2.msi", "i386"),_
    Array("3.3.5rc2.amd64", "http://www.python.org/ftp/python/3.3.5/", "python-3.3.5rc2.amd64.msi", "x64"),_
    Array("3.3.5rc1", "http://www.python.org/ftp/python/3.3.5/", "python-3.3.5rc1.msi", "i386"),_
    Array("3.3.5rc1.amd64", "http://www.python.org/ftp/python/3.3.5/", "python-3.3.5rc1.amd64.msi", "x64"),_
    Array("3.3.5rc1", "https://www.python.org/ftp/python/3.3.5/", "python-3.3.5rc1.msi", "i386"),_
    Array("3.3.5rc1.amd64", "https://www.python.org/ftp/python/3.3.5/", "python-3.3.5rc1.amd64.msi", "x64"),_
    Array("3.3.4", "http://www.python.org/ftp/python/3.3.4/", "python-3.3.4.msi", "i386"),_
    Array("3.3.4.amd64", "http://www.python.org/ftp/python/3.3.4/", "python-3.3.4.amd64.msi", "x64"),_
    Array("3.3.3", "https://www.python.org/ftp/python/3.3.3/", "python-3.3.3.msi", "i386"),_
    Array("3.3.3.amd64", "https://www.python.org/ftp/python/3.3.3/", "python-3.3.3.amd64.msi", "x64"),_
    Array("2.7.6", "https://www.python.org/ftp/python/2.7.6/", "python-2.7.6.msi", "i386"),_
    Array("2.7.6.amd64", "https://www.python.org/ftp/python/2.7.6/", "python-2.7.6.amd64.msi", "x64"),_
    Array("3.2.5", "https://www.python.org/ftp/python/3.2.5/", "python-3.2.5.msi", "i386"),_
    Array("3.2.5.amd64", "https://www.python.org/ftp/python/3.2.5/", "python-3.2.5.amd64.msi", "x64"),_
    Array("3.3.2", "https://www.python.org/ftp/python/3.3.2/", "python-3.3.2.msi", "i386"),_
    Array("3.3.2.amd64", "https://www.python.org/ftp/python/3.3.2/", "python-3.3.2.amd64.msi", "x64"),_
    Array("2.7.5", "https://www.python.org/ftp/python/2.7.5/", "python-2.7.5.msi", "i386"),_
    Array("2.7.5.amd64", "https://www.python.org/ftp/python/2.7.5/", "python-2.7.5.amd64.msi", "x64"),_
    Array("3.3.1", "https://www.python.org/ftp/python/3.3.1/", "python-3.3.1.msi", "i386"),_
    Array("3.3.1.amd64", "https://www.python.org/ftp/python/3.3.1/", "python-3.3.1.amd64.msi", "x64"),_
    Array("3.2.4", "https://www.python.org/ftp/python/3.2.4/", "python-3.2.4.msi", "i386"),_
    Array("3.2.4.amd64", "https://www.python.org/ftp/python/3.2.4/", "python-3.2.4.amd64.msi", "x64"),_
    Array("2.7.4", "https://www.python.org/ftp/python/2.7.4/", "python-2.7.4.msi", "i386"),_
    Array("2.7.4.amd64", "https://www.python.org/ftp/python/2.7.4/", "python-2.7.4.amd64.msi", "x64"),_
    Array("3.3.0", "https://www.python.org/ftp/python/3.3.0/", "python-3.3.0.msi", "i386"),_
    Array("3.3.0.amd64", "https://www.python.org/ftp/python/3.3.0/", "python-3.3.0.amd64.msi", "x64"),_
    Array("3.2.3", "https://www.python.org/ftp/python/3.2.3/", "python-3.2.3.msi", "i386"),_
    Array("3.2.3.amd64", "https://www.python.org/ftp/python/3.2.3/", "python-3.2.3.amd64.msi", "x64"),_
    Array("2.7.3", "https://www.python.org/ftp/python/2.7.3/", "python-2.7.3.msi", "i386"),_
    Array("2.7.3.amd64", "https://www.python.org/ftp/python/2.7.3/", "python-2.7.3.amd64.msi", "x64"),_
    Array("3.2.2", "https://www.python.org/ftp/python/3.2.2/", "python-3.2.2.msi", "i386"),_
    Array("3.2.2.amd64", "https://www.python.org/ftp/python/3.2.2/", "python-3.2.2.amd64.msi", "x64"),_
    Array("3.2.1", "https://www.python.org/ftp/python/3.2.1/", "python-3.2.1.msi", "i386"),_
    Array("3.2.1.amd64", "https://www.python.org/ftp/python/3.2.1/", "python-3.2.1.amd64.msi", "x64"),_
    Array("2.7.2", "https://www.python.org/ftp/python/2.7.2/", "python-2.7.2.msi", "i386"),_
    Array("2.7.2.amd64", "https://www.python.org/ftp/python/2.7.2/", "python-2.7.2.amd64.msi", "x64"),_
    Array("3.1.4", "https://www.python.org/ftp/python/3.1.4/", "python-3.1.4.msi", "i386"),_
    Array("3.1.4.amd64", "https://www.python.org/ftp/python/3.1.4/", "python-3.1.4.amd64.msi", "x64"),_
    Array("3.2", "https://www.python.org/ftp/python/3.2/", "python-3.2.msi", "i386"),_
    Array("3.2.amd64", "https://www.python.org/ftp/python/3.2/", "python-3.2.amd64.msi", "x64"),_
    Array("2.7.1", "https://www.python.org/ftp/python/2.7.1/", "python-2.7.1.msi", "i386"),_
    Array("2.7.1.amd64", "https://www.python.org/ftp/python/2.7.1/", "python-2.7.1.amd64.msi", "x64"),_
    Array("3.1.3", "https://www.python.org/ftp/python/3.1.3/", "python-3.1.3.msi", "i386"),_
    Array("3.1.3.amd64", "https://www.python.org/ftp/python/3.1.3/", "python-3.1.3.amd64.msi", "x64"),_
    Array("2.6.6", "https://www.python.org/ftp/python/2.6.6/", "python-2.6.6.msi", "i386"),_
    Array("2.6.6.amd64", "https://www.python.org/ftp/python/2.6.6/", "python-2.6.6.amd64.msi", "x64"),_
    Array("2.7", "https://www.python.org/ftp/python/2.7/", "python-2.7.msi", "i386"),_
    Array("2.7.amd64", "https://www.python.org/ftp/python/2.7/", "python-2.7.amd64.msi", "x64"),_
    Array("3.1.2", "https://www.python.org/ftp/python/3.1.2/", "python-3.1.2.msi", "i386"),_
    Array("3.1.2.amd64", "https://www.python.org/ftp/python/3.1.2/", "python-3.1.2.amd64.msi", "x64"),_
    Array("2.6.5", "https://www.python.org/ftp/python/2.6.5/", "python-2.6.5.msi", "i386"),_
    Array("2.6.5.amd64", "https://www.python.org/ftp/python/2.6.5/", "python-2.6.5.amd64.msi", "x64"),_
    Array("2.6.4", "https://www.python.org/ftp/python/2.6.4/", "python-2.6.4.msi", "i386"),_
    Array("2.6.4.amd64", "https://www.python.org/ftp/python/2.6.4/", "python-2.6.4.amd64.msi", "x64"),_
    Array("2.6.3", "https://www.python.org/ftp/python/2.6.3/", "python-2.6.3.msi", "i386"),_
    Array("2.6.3.amd64", "https://www.python.org/ftp/python/2.6.3/", "python-2.6.3.amd64.msi", "x64"),_
    Array("3.1.1", "https://www.python.org/ftp/python/3.1.1/", "python-3.1.1.msi", "i386"),_
    Array("3.1.1.amd64", "https://www.python.org/ftp/python/3.1.1/", "python-3.1.1.amd64.msi", "x64"),_
    Array("3.1", "https://www.python.org/ftp/python/3.1/", "python-3.1.msi", "i386"),_
    Array("3.1.amd64", "https://www.python.org/ftp/python/3.1/", "python-3.1.amd64.msi", "x64"),_
    Array("2.6.2", "https://www.python.org/ftp/python/2.6.2/", "python-2.6.2.msi", "i386"),_
    Array("2.6.2.amd64", "https://www.python.org/ftp/python/2.6.2/", "python-2.6.2.amd64.msi", "x64"),_
    Array("3.0.1", "https://www.python.org/ftp/python/3.0.1/", "python-3.0.1.msi", "i386"),_
    Array("3.0.1.amd64", "https://www.python.org/ftp/python/3.0.1/", "python-3.0.1.amd64.msi", "x64"),_
    Array("2.5.4", "https://www.python.org/ftp/python/2.5.4/", "python-2.5.4.msi", "i386"),_
    Array("2.5.4.amd64", "https://www.python.org/ftp/python/2.5.4/", "python-2.5.4.amd64.msi", "x64"),_
    Array("2.5.3", "https://www.python.org/ftp/python/2.5.3/", "python-2.5.3.msi", "i386"),_
    Array("2.5.3.amd64", "https://www.python.org/ftp/python/2.5.3/", "python-2.5.3.amd64.msi", "x64"),_
    Array("2.6.1", "https://www.python.org/ftp/python/2.6.1/", "python-2.6.1.msi", "i386"),_
    Array("2.6.1.amd64", "https://www.python.org/ftp/python/2.6.1/", "python-2.6.1.amd64.msi", "x64"),_
    Array("3.0", "https://www.python.org/ftp/python/3.0/", "python-3.0.msi", "i386"),_
    Array("3.0.amd64", "https://www.python.org/ftp/python/3.0/", "python-3.0.amd64.msi", "x64"),_
    Array("2.6", "https://www.python.org/ftp/python/2.6/", "python-2.6.msi", "i386"),_
    Array("2.6.amd64", "https://www.python.org/ftp/python/2.6/", "python-2.6.amd64.msi", "x64"),_
    Array("2.5.2", "https://www.python.org/ftp/python/2.5.2/", "python-2.5.2.msi", "i386"),_
    Array("2.5.2.amd64", "https://www.python.org/ftp/python/2.5.2/", "python-2.5.2.amd64.msi", "x64"),_
    Array("2.5.1", "https://www.python.org/ftp/python/2.5.1/", "python-2.5.1.msi", "i386"),_
    Array("2.5.1.amd64", "https://www.python.org/ftp/python/2.5.1/", "python-2.5.1.amd64.msi", "x64"),_
    Array("2.4.4", "https://www.python.org/ftp/python/2.4.4/", "python-2.4.4.msi", "i386"),_
    Array("2.5", "https://www.python.org/ftp/python/2.5/", "python-2.5.msi", "i386"),_
    Array("2.5.amd64", "https://www.python.org/ftp/python/2.5/", "python-2.5.amd64.msi", "x64"),_
    Array("2.4.3", "https://www.python.org/ftp/python/2.4.3/", "python-2.4.3.msi", "i386"),_
    Array("2.4.2", "https://www.python.org/ftp/python/2.4.2/", "python-2.4.2.msi", "i386"),_
    Array("2.4.1", "https://www.python.org/ftp/python/2.4.1/", "python-2.4.1.msi", "i386"),_
    Array("2.3.5", "https://www.python.org/ftp/python/2.3.5/", "Python-2.3.5.exe", "i386"),_
    Array("2.4", "https://www.python.org/ftp/python/2.4/", "python-2.4.msi", "i386"),_
    Array("2.3.4", "https://www.python.org/ftp/python/2.3.4/", "Python-2.3.4.exe", "i386"),_
    Array("2.3.3", "https://www.python.org/ftp/python/2.3.3/", "Python-2.3.3.exe", "i386"),_
    Array("2.3.2-1", "https://www.python.org/ftp/python/2.3.2/", "Python-2.3.2-1.exe", "i386"),_
    Array("2.3.1", "https://www.python.org/ftp/python/2.3.1/", "Python-2.3.1.exe", "i386"),_
    Array("2.3", "https://www.python.org/ftp/python/2.3/", "Python-2.3.exe", "i386"),_
    Array("2.2.3", "https://www.python.org/ftp/python/2.2.3/", "Python-2.2.3.exe", "i386"),_
    Array("2.2.2", "https://www.python.org/ftp/python/2.2.2/", "Python-2.2.2.exe", "i386"),_
    Array("2.2.1", "https://www.python.org/ftp/python/2.2.1/", "Python-2.2.1.exe", "i386"),_
    Array("2.1.3", "https://www.python.org/ftp/python/2.1.3/", "Python-2.1.3.exe", "i386"),_
    Array("2.2", "https://www.python.org/ftp/python/2.2/", "Python-2.2.exe", "i386"),_
    Array("2.0.1", "https://www.python.org/ftp/python/2.0.1/", "Python-2.0.1.exe", "i386")_
)

Function DownloadFile(strUrl,strFile)
    Dim objHttp
    Dim httpProxy
    Set objHttp = WScript.CreateObject("Msxml2.ServerXMLHTTP")
    on error resume next
    Call objHttp.Open("GET", strUrl, False )
    if Err.Number <> 0 then
        WScript.Echo Err.Description
        WScript.Quit
    end if
    httpProxy = objws.ExpandEnvironmentStrings("%http_proxy%")
    if httpProxy <> "" AND httpProxy <> "%http_proxy%" Then
        objHttp.setProxy 2, httpProxy
    end if
    objHttp.Send

    if Err.Number <> 0 then
        WScript.Echo Err.Description
        WScript.Quit
    end if
    on error goto 0
    if objHttp.status = 404 then
        WScript.Echo ":: [ERROR] :: 404 :: file not found"
        WScript.Quit
    end if

    Dim Stream
    Set Stream = WScript.CreateObject("ADODB.Stream")
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
    WScript.echo ":: [Downloading] ::  " & cur(0) & " ..."
    DownloadFile cur(3) , cur(2)
End Sub

Sub extract(cur)
	If Not objfs.FolderExists( strDirCache ) Then objfs.CreateFolder(strDirCache)
    If Not objfs.FolderExists( strDirVers  ) Then objfs.CreateFolder(strDirVers )

    If objfs.FolderExists(cur(1)) Then Exit Sub

    If Not objfs.FileExists(cur(2)) Then download(cur)

      WScript.echo ":: [Installing] ::  " & cur(0) & " ..."

    objws.CurrentDirectory = strDirCache
	Dim exe_file
	Dim target_location
	exe_file = """" & cur(2) & """"
    target_location = """" & cur(1) & """"
    objws.Run exe_file & " InstallAllUsers=0 Include_launcher=0 Include_test=0 SimpleInstall=1 TargetDir=" & target_location, 0, true
    
    If objfs.FolderExists(cur(1)) Then
        objws.Run "pyenv rehash " & cur(0), 0, false
        WScript.echo ":: [Info] :: completed! " & cur(0)
    Else
        WScript.echo ":: [Error] :: couldn't install .. " & cur(0)
    End If
End Sub

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
        Dim ary
        ary=GetCurrentVersionNoError()
        If Not IsNull(ary) Then version=ary(0)
    End If

    Dim list
    Dim cur
    If optList Then
        For Each list In listEnv
            WScript.echo list(0)
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
        WScript.echo "pyenv-install: definition not found: " & version
        WScript.echo ""
        WScript.echo "See all available versions with `pyenv install --list'."
    Else
        ShowHelp
    End If
End Sub

main(WScript.Arguments)

