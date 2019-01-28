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


Dim tool7z
Dim strDirDevKit
tool7z = """" & strPyenvHome & "\tools\7z\7zdec.exe"" x "
strDirDevKit  = strPyenvHome & "\tools\DevKit"


Sub ShowHelp()
     Wscript.echo "Usage: rbenv install [-f|-s] <version>"
     Wscript.echo "       rbenv install [-f|-s] <definition-file>"
     Wscript.echo "       rbenv install -l|--list"
     Wscript.echo ""
     Wscript.echo "  -l/--list          List all available versions"
     Wscript.echo "  -f/--force         Install even if the version appears to be installed already"
     Wscript.echo "  -s/--skip-existing Skip if the version appears to be installed already"
     Wscript.echo ""
     Wscript.Quit
End Sub

Dim listDevKit
listDevKit = Array( _
    Array("i386","http://dl.bintray.com/oneclick/rubyinstaller/","DevKit-mingw64-32-4.7.2-20130224-1151-sfx.exe" ),_
    Array("x64" ,"http://dl.bintray.com/oneclick/rubyinstaller/","DevKit-mingw64-64-4.7.2-20130224-1432-sfx.exe" ),_
    Array("tdm" ,"http://dl.bintray.com/oneclick/rubyinstaller/","DevKit-tdm-32-4.5.2-20111229-1559-sfx.exe"     ) _
)

Dim listEnv
Dim listEnv_i386
listEnv = Array(_
    Array("2.6.0-i386"       ,"https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-2.6.0-1/","rubyinstaller-devkit-2.6.0-1-x86.7z" ,"bundled"),_
    Array("2.6.0-x64"        ,"https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-2.6.0-1/","rubyinstaller-devkit-2.6.0-1-x64.7z" ,"bundled"),_
    Array("2.5.3-i386"       ,"https://github.com/oneclick/rubyinstaller2/releases/download/rubyinstaller-2.5.3-1/","rubyinstaller-devkit-2.5.3-1-x86.7z" ,"bundled"),_
    Array("2.5.3-x64"        ,"https://github.com/oneclick/rubyinstaller2/releases/download/rubyinstaller-2.5.3-1/","rubyinstaller-devkit-2.5.3-1-x64.7z" ,"bundled"),_
    Array("2.4.5-i386"       ,"https://github.com/oneclick/rubyinstaller2/releases/download/rubyinstaller-2.4.5-1/","rubyinstaller-devkit-2.4.5-1-x86.7z" ,"bundled"),_
    Array("2.4.5-x64"        ,"https://github.com/oneclick/rubyinstaller2/releases/download/rubyinstaller-2.4.5-1/","rubyinstaller-devkit-2.4.5-1-x64.7z" ,"bundled"),_
    Array("2.3.3-i386"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.3.3-i386-mingw32.7z"      ,"i386"),_
    Array("2.3.3-x64"        ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.3.3-x64-mingw32.7z"       ,"x64" ),_
    Array("2.3.1-i386"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.3.1-i386-mingw32.7z"      ,"i386"),_
    Array("2.3.1-x64"        ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.3.1-x64-mingw32.7z"       ,"x64" ),_
    Array("2.3.0-i386"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.3.0-i386-mingw32.7z"      ,"i386"),_
    Array("2.3.0-x64"        ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.3.0-x64-mingw32.7z"       ,"x64" ),_
    Array("2.2.6-i386"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.2.6-i386-mingw32.7z"      ,"i386"),_
    Array("2.2.6-x64"        ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.2.6-x64-mingw32.7z"       ,"x64" ),_
    Array("2.2.5-i386"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.2.5-i386-mingw32.7z"      ,"i386"),_
    Array("2.2.5-x64"        ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.2.5-x64-mingw32.7z"       ,"x64" ),_
    Array("2.2.4-i386"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.2.4-i386-mingw32.7z"      ,"i386"),_
    Array("2.2.4-x64"        ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.2.4-x64-mingw32.7z"       ,"x64" ),_
    Array("2.2.3-i386"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.2.3-i386-mingw32.7z"      ,"i386"),_
    Array("2.2.3-x64"        ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.2.3-x64-mingw32.7z"       ,"x64" ),_
    Array("2.2.2-i386"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.2.2-i386-mingw32.7z"      ,"i386"),_
    Array("2.2.2-x64"        ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.2.2-x64-mingw32.7z"       ,"x64" ),_
    Array("2.2.1-i386"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.2.1-i386-mingw32.7z"      ,"i386"),_
    Array("2.2.1-x64"        ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.2.1-x64-mingw32.7z"       ,"x64" ),_
    Array("2.1.9-i386"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.1.9-i386-mingw32.7z"      ,"i386"),_
    Array("2.1.9-x64"        ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.1.9-x64-mingw32.7z"       ,"x64" ),_
    Array("2.1.8-i386"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.1.8-i386-mingw32.7z"      ,"i386"),_
    Array("2.1.8-x64"        ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.1.8-x64-mingw32.7z"       ,"x64" ),_
    Array("2.1.7-i386"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.1.7-i386-mingw32.7z"      ,"i386"),_
    Array("2.1.7-x64"        ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.1.7-x64-mingw32.7z"       ,"x64" ),_
    Array("2.1.6-i386"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.1.6-i386-mingw32.7z"      ,"i386"),_
    Array("2.1.6-x64"        ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.1.6-x64-mingw32.7z"       ,"x64" ),_
    Array("2.1.5-i386"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.1.5-i386-mingw32.7z"      ,"i386"),_
    Array("2.1.5-x64"        ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.1.5-x64-mingw32.7z"       ,"x64" ),_
    Array("2.1.4-i386"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.1.4-i386-mingw32.7z"      ,"i386"),_
    Array("2.1.4-x64"        ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.1.4-x64-mingw32.7z"       ,"x64" ),_
    Array("2.1.3-i386"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.1.3-i386-mingw32.7z"      ,"i386"),_
    Array("2.1.3-x64"        ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.1.3-x64-mingw32.7z"       ,"x64" ),_
    Array("2.0.0-p648-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p648-i386-mingw32.7z" ,"i386"),_
    Array("2.0.0-p648-x64"   ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p648-x64-mingw32.7z"  ,"x64" ),_
    Array("2.0.0-p647-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p647-i386-mingw32.7z" ,"i386"),_
    Array("2.0.0-p647-x64"   ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p647-x64-mingw32.7z"  ,"x64" ),_
    Array("2.0.0-p645-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p645-i386-mingw32.7z" ,"i386"),_
    Array("2.0.0-p645-x64"   ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p645-x64-mingw32.7z"  ,"x64" ),_
    Array("2.0.0-p643-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p643-i386-mingw32.7z" ,"i386"),_
    Array("2.0.0-p643-x64"   ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p643-x64-mingw32.7z"  ,"x64" ),_
    Array("2.0.0-p598-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p598-i386-mingw32.7z" ,"i386"),_
    Array("2.0.0-p598-x64"   ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p598-x64-mingw32.7z"  ,"x64" ),_
    Array("2.0.0-p594-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p594-i386-mingw32.7z" ,"i386"),_
    Array("2.0.0-p594-x64"   ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p594-x64-mingw32.7z"  ,"x64" ),_
    Array("2.0.0-p576-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p576-i386-mingw32.7z" ,"i386"),_
    Array("2.0.0-p576-x64"   ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p576-x64-mingw32.7z"  ,"x64" ),_
    Array("2.0.0-p481-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p481-i386-mingw32.7z" ,"i386"),_
    Array("2.0.0-p481-x64"   ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p481-x64-mingw32.7z"  ,"x64" ),_
    Array("2.0.0-p451-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p451-i386-mingw32.7z" ,"i386"),_
    Array("2.0.0-p451-x64"   ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p451-x64-mingw32.7z"  ,"x64" ),_
    Array("2.0.0-p353-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p353-i386-mingw32.7z" ,"i386"),_
    Array("2.0.0-p353-x64"   ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p353-x64-mingw32.7z"  ,"x64" ),_
    Array("2.0.0-p247-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p247-i386-mingw32.7z" ,"i386"),_
    Array("2.0.0-p247-x64"   ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p247-x64-mingw32.7z"  ,"x64" ),_
    Array("2.0.0-p195-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p195-i386-mingw32.7z" ,"i386"),_
    Array("2.0.0-p195-x64"   ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p195-x64-mingw32.7z"  ,"x64" ),_
    Array("2.0.0-p0-i386"    ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p0-i386-mingw32.7z"   ,"i386"),_
    Array("2.0.0-p0-x64"     ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p0-x64-mingw32.7z"    ,"x64" ),_
    Array("1.9.3-p551-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.3-p551-i386-mingw32.7z" ,"tdm" ),_
    Array("1.9.3-p550-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.3-p550-i386-mingw32.7z" ,"tdm" ),_
    Array("1.9.3-p545-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.3-p545-i386-mingw32.7z" ,"tdm" ),_
    Array("1.9.3-p484-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.3-p484-i386-mingw32.7z" ,"tdm" ),_
    Array("1.9.3-p448-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.3-p448-i386-mingw32.7z" ,"tdm" ),_
    Array("1.9.3-p429-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.3-p429-i386-mingw32.7z" ,"tdm" ),_
    Array("1.9.3-p392-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.3-p392-i386-mingw32.7z" ,"tdm" ),_
    Array("1.9.3-p385-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.3-p385-i386-mingw32.7z" ,"tdm" ),_
    Array("1.9.3-p374-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.3-p374-i386-mingw32.7z" ,"tdm" ),_
    Array("1.9.3-p362-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.3-p362-i386-mingw32.7z" ,"tdm" ),_
    Array("1.9.3-p327-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.3-p327-i386-mingw32.7z" ,"tdm" ),_
    Array("1.9.3-p286-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.3-p286-i386-mingw32.7z" ,"tdm" ),_
    Array("1.9.3-p194-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.3-p194-i386-mingw32.7z" ,"tdm" ),_
    Array("1.9.3-p125-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.3-p125-i386-mingw32.7z" ,"tdm" ),_
    Array("1.9.3-p0-i386"    ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.3-p0-i386-mingw32.7z"   ,"tdm" ),_
    Array("1.9.2-p290-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.2-p290-i386-mingw32.7z" ,"tdm" ),_
    Array("1.9.2-p180-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.2-p180-i386-mingw32.7z" ,"tdm" ),_
    Array("1.9.2-p136-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.2-p136-i386-mingw32.7z" ,"tdm" ),_
    Array("1.9.2-p0-i386"    ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.2-p0-i386-mingw32.7z"   ,"tdm" ),_
    Array("1.8.7-p374-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.8.7-p374-i386-mingw32.7z" ,"tdm" ),_
    Array("1.8.7-p371-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.8.7-p371-i386-mingw32.7z" ,"tdm" ),_
    Array("1.8.7-p370-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.8.7-p370-i386-mingw32.7z" ,"tdm" ),_
    Array("1.8.7-p358-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.8.7-p358-i386-mingw32.7z" ,"tdm" ),_
    Array("1.8.7-p357-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.8.7-p357-i386-mingw32.7z" ,"tdm" ),_
    Array("1.8.7-p352-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.8.7-p352-i386-mingw32.7z" ,"tdm" ),_
    Array("1.8.7-p334-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.8.7-p334-i386-mingw32.7z" ,"tdm" ),_
    Array("1.8.7-p330-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.8.7-p330-i386-mingw32.7z" ,"tdm" ),_
    Array("1.8.7-p302-i386"  ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.8.7-p302-i386-mingw32.7z" ,"tdm" ) _
)

listEnv_i386 = Array( _
    Array("2.6.0"            ,"https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-2.6.0-1/","rubyinstaller-2.6.0-1-x86.7z" ,"bundled"),_
    Array("2.6.0-x64"        ,"https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-2.6.0-1/","rubyinstaller-2.6.0-1-x64.7z" ,"bundled"),_
    Array("2.5.3"            ,"https://github.com/oneclick/rubyinstaller2/releases/download/rubyinstaller-2.5.3-1/","rubyinstaller-2.5.3-1-x86.7z" ,"bundled"),_
    Array("2.5.3-x64"        ,"https://github.com/oneclick/rubyinstaller2/releases/download/rubyinstaller-2.5.3-1/","rubyinstaller-2.5.3-1-x64.7z" ,"bundled"),_
    Array("2.4.5"            ,"https://github.com/oneclick/rubyinstaller2/releases/download/rubyinstaller-2.4.5-1/","rubyinstaller-2.4.5-1-x86.7z" ,"bundled"),_
    Array("2.4.5-x64"        ,"https://github.com/oneclick/rubyinstaller2/releases/download/rubyinstaller-2.4.5-1/","rubyinstaller-2.4.5-1-x64.7z" ,"bundled"),_
    Array("2.3.3"            ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.3.3-i386-mingw32.7z"      ,"i386"),_
    Array("2.3.3-x64"        ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.3.3-x64-mingw32.7z"       ,"x64" ),_
    Array("2.3.1"            ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.3.1-i386-mingw32.7z"      ,"i386"),_
    Array("2.3.1-x64"        ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.3.1-x64-mingw32.7z"       ,"x64" ),_
    Array("2.3.0"            ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.3.0-i386-mingw32.7z"      ,"i386"),_
    Array("2.3.0-x64"        ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.3.0-x64-mingw32.7z"       ,"x64" ),_
    Array("2.2.6"            ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.2.6-i386-mingw32.7z"      ,"i386"),_
    Array("2.2.6-x64"        ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.2.6-x64-mingw32.7z"       ,"x64" ),_
    Array("2.2.5"            ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.2.5-i386-mingw32.7z"      ,"i386"),_
    Array("2.2.5-x64"        ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.2.5-x64-mingw32.7z"       ,"x64" ),_
    Array("2.2.4"            ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.2.4-i386-mingw32.7z"      ,"i386"),_
    Array("2.2.4-x64"        ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.2.4-x64-mingw32.7z"       ,"x64" ),_
    Array("2.2.3"            ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.2.3-i386-mingw32.7z"      ,"i386"),_
    Array("2.2.3-x64"        ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.2.3-x64-mingw32.7z"       ,"x64" ),_
    Array("2.2.2"            ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.2.2-i386-mingw32.7z"      ,"i386"),_
    Array("2.2.2-x64"        ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.2.2-x64-mingw32.7z"       ,"x64" ),_
    Array("2.2.1"            ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.2.1-i386-mingw32.7z"      ,"i386"),_
    Array("2.2.1-x64"        ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.2.1-x64-mingw32.7z"       ,"x64" ),_
    Array("2.1.9"            ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.1.9-i386-mingw32.7z"      ,"i386"),_
    Array("2.1.9-x64"        ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.1.9-x64-mingw32.7z"       ,"x64" ),_
    Array("2.1.8"            ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.1.8-i386-mingw32.7z"      ,"i386"),_
    Array("2.1.8-x64"        ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.1.8-x64-mingw32.7z"       ,"x64" ),_
    Array("2.1.7"            ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.1.7-i386-mingw32.7z"      ,"i386"),_
    Array("2.1.7-x64"        ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.1.7-x64-mingw32.7z"       ,"x64" ),_
    Array("2.1.6"            ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.1.6-i386-mingw32.7z"      ,"i386"),_
    Array("2.1.6-x64"        ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.1.6-x64-mingw32.7z"       ,"x64" ),_
    Array("2.1.5"            ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.1.5-i386-mingw32.7z"      ,"i386"),_
    Array("2.1.5-x64"        ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.1.5-x64-mingw32.7z"       ,"x64" ),_
    Array("2.1.4"            ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.1.4-i386-mingw32.7z"      ,"i386"),_
    Array("2.1.4-x64"        ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.1.4-x64-mingw32.7z"       ,"x64" ),_
    Array("2.1.3"            ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.1.3-i386-mingw32.7z"      ,"i386"),_
    Array("2.1.3-x64"        ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.1.3-x64-mingw32.7z"       ,"x64" ),_
    Array("2.0.0-p648"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p648-i386-mingw32.7z" ,"i386"),_
    Array("2.0.0-p648-x64"   ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p648-x64-mingw32.7z"  ,"x64" ),_
    Array("2.0.0-p647"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p647-i386-mingw32.7z" ,"i386"),_
    Array("2.0.0-p647-x64"   ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p647-x64-mingw32.7z"  ,"x64" ),_
    Array("2.0.0-p645"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p645-i386-mingw32.7z" ,"i386"),_
    Array("2.0.0-p645-x64"   ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p645-x64-mingw32.7z"  ,"x64" ),_
    Array("2.0.0-p643"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p643-i386-mingw32.7z" ,"i386"),_
    Array("2.0.0-p643-x64"   ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p643-x64-mingw32.7z"  ,"x64" ),_
    Array("2.0.0-p598"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p598-i386-mingw32.7z" ,"i386"),_
    Array("2.0.0-p598-x64"   ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p598-x64-mingw32.7z"  ,"x64" ),_
    Array("2.0.0-p594"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p594-i386-mingw32.7z" ,"i386"),_
    Array("2.0.0-p594-x64"   ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p594-x64-mingw32.7z"  ,"x64" ),_
    Array("2.0.0-p576"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p576-i386-mingw32.7z" ,"i386"),_
    Array("2.0.0-p576-x64"   ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p576-x64-mingw32.7z"  ,"x64" ),_
    Array("2.0.0-p481"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p481-i386-mingw32.7z" ,"i386"),_
    Array("2.0.0-p481-x64"   ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p481-x64-mingw32.7z"  ,"x64" ),_
    Array("2.0.0-p451"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p451-i386-mingw32.7z" ,"i386"),_
    Array("2.0.0-p451-x64"   ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p451-x64-mingw32.7z"  ,"x64" ),_
    Array("2.0.0-p353"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p353-i386-mingw32.7z" ,"i386"),_
    Array("2.0.0-p353-x64"   ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p353-x64-mingw32.7z"  ,"x64" ),_
    Array("2.0.0-p247"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p247-i386-mingw32.7z" ,"i386"),_
    Array("2.0.0-p247-x64"   ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p247-x64-mingw32.7z"  ,"x64" ),_
    Array("2.0.0-p195"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p195-i386-mingw32.7z" ,"i386"),_
    Array("2.0.0-p195-x64"   ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p195-x64-mingw32.7z"  ,"x64" ),_
    Array("2.0.0-p0"         ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p0-i386-mingw32.7z"   ,"i386"),_
    Array("2.0.0-p0-x64"     ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-2.0.0-p0-x64-mingw32.7z"    ,"x64" ),_
    Array("1.9.3-p551"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.3-p551-i386-mingw32.7z" ,"tdm" ),_
    Array("1.9.3-p550"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.3-p550-i386-mingw32.7z" ,"tdm" ),_
    Array("1.9.3-p545"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.3-p545-i386-mingw32.7z" ,"tdm" ),_
    Array("1.9.3-p484"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.3-p484-i386-mingw32.7z" ,"tdm" ),_
    Array("1.9.3-p448"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.3-p448-i386-mingw32.7z" ,"tdm" ),_
    Array("1.9.3-p429"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.3-p429-i386-mingw32.7z" ,"tdm" ),_
    Array("1.9.3-p392"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.3-p392-i386-mingw32.7z" ,"tdm" ),_
    Array("1.9.3-p385"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.3-p385-i386-mingw32.7z" ,"tdm" ),_
    Array("1.9.3-p374"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.3-p374-i386-mingw32.7z" ,"tdm" ),_
    Array("1.9.3-p362"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.3-p362-i386-mingw32.7z" ,"tdm" ),_
    Array("1.9.3-p327"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.3-p327-i386-mingw32.7z" ,"tdm" ),_
    Array("1.9.3-p286"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.3-p286-i386-mingw32.7z" ,"tdm" ),_
    Array("1.9.3-p194"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.3-p194-i386-mingw32.7z" ,"tdm" ),_
    Array("1.9.3-p125"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.3-p125-i386-mingw32.7z" ,"tdm" ),_
    Array("1.9.3-p0"         ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.3-p0-i386-mingw32.7z"   ,"tdm" ),_
    Array("1.9.2-p290"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.2-p290-i386-mingw32.7z" ,"tdm" ),_
    Array("1.9.2-p180"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.2-p180-i386-mingw32.7z" ,"tdm" ),_
    Array("1.9.2-p136"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.2-p136-i386-mingw32.7z" ,"tdm" ),_
    Array("1.9.2-p0"         ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.9.2-p0-i386-mingw32.7z"   ,"tdm" ),_
    Array("1.8.7-p374"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.8.7-p374-i386-mingw32.7z" ,"tdm" ),_
    Array("1.8.7-p371"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.8.7-p371-i386-mingw32.7z" ,"tdm" ),_
    Array("1.8.7-p370"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.8.7-p370-i386-mingw32.7z" ,"tdm" ),_
    Array("1.8.7-p358"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.8.7-p358-i386-mingw32.7z" ,"tdm" ),_
    Array("1.8.7-p357"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.8.7-p357-i386-mingw32.7z" ,"tdm" ),_
    Array("1.8.7-p352"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.8.7-p352-i386-mingw32.7z" ,"tdm" ),_
    Array("1.8.7-p334"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.8.7-p334-i386-mingw32.7z" ,"tdm" ),_
    Array("1.8.7-p330"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.8.7-p330-i386-mingw32.7z" ,"tdm" ),_
    Array("1.8.7-p302"       ,"http://dl.bintray.com/oneclick/rubyinstaller/","ruby-1.8.7-p302-i386-mingw32.7z" ,"tdm" ) _
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

Sub extractDevKit(cur)
    If Not objfs.FolderExists( strDirDevKit ) Then objfs.CreateFolder(strDirDevKit)
    If Not objfs.FolderExists(    cur(1)    ) Then objfs.CreateFolder(cur(1))

    If Not objfs.FileExists(cur(2)) Then 
        objws.Run "%comspec% /c rmdir /s /q " & cur(1), 0 , true
        objfs.CreateFolder(cur(1))
        If objfs.FileExists(cur(4)) Then
            objfs.CopyFile cur(4), cur(1)&"\", True
        Else
            download(cur)
        End If
    End If
    
    If Not objfs.FileExists(cur(1) & "\dk.rb") Then
        Wscript.echo "extract" & cur(0) & " ..."
        objws.Run """" & cur(2) & """", 1 , true
    End If
End Sub

Sub writeConfigYML(dev,cur)
    Dim ofile
    Set ofile = objfs.CreateTextFile(dev(1) & "\config.yml" , True )
    ofile.WriteLine("- " & cur(1))
    ofile.Close()
End Sub

Sub patchDevKit(dev,cur)
     Wscript.echo "patch " & dev(0) & " to " & cur(0)
     writeConfigYML dev,cur
     objws.CurrentDirectory = dev(1)
     objws.Run """" & cur(1) & "\bin\ruby.exe"" dk.rb install", 1 , true
     objws.CurrentDirectory =strCurrent
End Sub

Sub installDevKit(cur)
    Dim list
    Dim dev
    Dim idx
    If cur(4) = "bundled" Then
        objws.Run """" & cur(1) & "\bin\ridk.cmd"" install", 1 , true
    Else
        For Each list In listDevKit
            If list(0) = cur(4) Then
                dev=Array("DevKit_" & list(0), strDirDevKit&"\"&list(0), strDirDevKit&"\"&list(0)&"\"&list(2), list(1)&list(2),  strDirCache&"\"&list(2))
                extractDevKit dev
                patchDevKit dev,cur
                Exit Sub
            End If
        Next
    End If
End Sub

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
    objws.Run tool7z & " """ & cur(2) & """" , 0 , true
    objfs.MoveFolder strDirCache&"\"&objfs.GetBaseName(cur(2)) , cur(1)

    installDevKit(cur)

    Wscript.echo "comlete! " & cur(0)

End Sub

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
    
    Dim list
    Dim cur
    If optList Then
        For Each list In listEnv_i386
            Wscript.echo list(0)
        Next
        Exit Sub
    ElseIf version <> "" Then
        For Each list In listEnv_i386
            If list(0) = version Then 
                cur=Array(list(0),strDirVers&"\"&list(0),strDirCache&"\"&list(2),list(1)&list(2),list(3))
                If optForce Then  clear(cur)
                extract(cur)
                Exit Sub
            End If
        Next
        Wscript.echo "rbenv-install: definition not found: " & version
        Wscript.echo ""
        Wscript.echo "See all available versions with `rbenv install --list'."
    Else
        ShowHelp
    End If
End Sub

main(WScript.Arguments)