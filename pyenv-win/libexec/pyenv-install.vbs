Option Explicit

Sub Import(importFile)
    Dim fso, libFile
    On Error Resume Next
    Set fso = CreateObject("Scripting.FileSystemObject")
    Set libFile = fso.OpenTextFile(fso.getParentFolderName(WScript.ScriptFullName) &"\"& importFile, 1)
    ExecuteGlobal libFile.ReadAll
    If Err.number <> 0 Then
        WScript.Echo "Error importing library """& importFile &"""("& Err.Number &"): "& Err.Description
        WScript.Quit 1
    End If
    libFile.Close
End Sub

Import "libs\pyenv-lib.vbs"
Import "libs\pyenv-install-lib.vbs"

WScript.Echo ":: [Info] ::  Mirror: " & mirror

Sub ShowHelp()
    ' WScript.echo "kkotari: pyenv-install.vbs..!"
    WScript.Echo "Usage: pyenv install [-s] [-f] <version> [<version> ...] [-r|--register]"
    WScript.Echo "       pyenv install [-f] [--32only|--64only] -a|--all"
    WScript.Echo "       pyenv install [-f] -c|--clear"
    WScript.Echo "       pyenv install -l|--list"
    WScript.Echo ""
    WScript.Echo "  -l/--list              List all available versions"
    WScript.Echo "  -a/--all               Installs all known version from the local version DB cache"
    WScript.Echo "  -c/--clear             Removes downloaded installers from the cache to free space"
    WScript.Echo "  -f/--force             Install even if the version appears to be installed already"
    WScript.Echo "  -s/--skip-existing     Skip the installation if the version appears to be installed already"
    WScript.Echo "  -r/--register          Register version for py launcher"
    WScript.Echo "  -q/--quiet             Install using /quiet. This does not show the UI nor does it prompt for inputs"
    WScript.Echo "  --32only               Installs only 32bit Python using -a/--all switch, no effect on 32-bit windows."
    WScript.Echo "  --64only               Installs only 64bit Python using -a/--all switch, no effect on 32-bit windows."
    WScript.Echo "  --dev                  Installs precompiled standard libraries, debug symbols, and debug binaries (only applies to web installer)."
    WScript.Echo "  --help                 Help, list of options allowed on pyenv install"
    WScript.Echo ""
    WScript.Quit 0
End Sub

Sub EnsureFolder(path)
    ' WScript.echo "kkotari: pyenv-install.vbs EnsureFolder..!"
    Dim stack()
    Dim folder
    ReDim stack(0)
    stack(0) = path

    On Error Resume Next
    Do While UBound(stack) > -1
        folder = stack(UBound(stack))
        If objfs.FolderExists(folder) Then
            ReDim Preserve stack(UBound(stack)-1)
        ElseIf Not objfs.FolderExists(objfs.GetParentFolderName(folder)) Then
            ReDim Preserve stack(UBound(stack)+1)
            stack(UBound(stack)) = objfs.GetParentFolderName(folder)
        Else
            objfs.CreateFolder folder
            If Err.number <> 0 Then Exit Sub
            ReDim Preserve stack(UBound(stack)-1)
        End If
    Loop
End Sub

Sub download(params)
    ' WScript.echo "kkotari: pyenv-install.vbs download..!"
    WScript.Echo ":: [Downloading] ::  " & params(LV_Code) & " ..."
    WScript.Echo ":: [Downloading] ::  From " & params(LV_URL)
    WScript.Echo ":: [Downloading] ::  To   " & params(IP_InstallFile)
    DownloadFile params(LV_URL), params(IP_InstallFile)
End Sub

Function deepExtract(params, web)
    ' WScript.echo "kkotari: pyenv-install.vbs deepExtract..!"
    Dim cachePath
    Dim installPath
    cachePath = strDirCache &"\"& params(LV_Code)
    If web Then
        cachePath = cachePath &"-webinstall"
    End If
    installPath = params(IP_InstallPath)
    deepExtract = -1

    If Not objfs.FolderExists(cachePath) Then
        deepExtract = objws.Run(""""& params(IP_InstallFile) &""" /quiet /layout """& cachePath &"""", 0, True)
        If deepExtract Then
            WScript.Echo ":: [Error] :: error extracting the web portion from the installer."
            Exit Function
        End If
        If Not web Then
            deepExtract = objws.Run(""""& strDirWiX &"\dark.exe"" -x """& cachePath &""" """& params(IP_InstallFile) &"""", 0, True)
            If deepExtract Then
                WScript.Echo ":: [Error] :: error extracting the embedded portion from the installer."
                Exit Function
            End If
            deepExtract = objws.Run("cmd /D /C move """& cachePath &"""\AttachedContainer\*.msi """& cachePath &"""", 0, True)
            If deepExtract Then
                WScript.Echo ":: [Error] :: error extracting the embedded portion from the installer."
                Exit Function
            End If
        End If
    End If

    ' Clean unused install files.
    Dim file
    Dim baseName
    For Each file In objfs.GetFolder(cachePath).Files
        baseName = LCase(objfs.GetBaseName(file))
        If LCase(objfs.GetExtensionName(file)) <> "msi" Or _
           baseName = "appendpath" Or _
           baseName = "launcher" Or _
           baseName = "path" Or _
           baseName = "pip" _
        Then
            objfs.DeleteFile file
        End If
    Next

    For Each file In objfs.GetFolder(cachePath).SubFolders
        file.Delete
    Next

    ' Install the remaining MSI files into our install folder.
    Dim msi
    For Each file In objfs.GetFolder(cachePath).Files
        baseName = LCase(objfs.GetBaseName(file))
        deepExtract = objws.Run("msiexec /quiet /a """& file &""" TargetDir="""& installPath & """", 0, True)
        If deepExtract Then
            WScript.Echo ":: [Error] :: error installing """& baseName &""" component MSI."
            Exit Function
        End If

        ' Delete the duplicate MSI files post-install.
        msi = installPath &"\"& objfs.GetFileName(file)
        If objfs.FileExists(msi) Then objfs.DeleteFile msi
    Next

    ' If the ensurepip Lib exists, call it manually since "msiexec /a" installs don't do this.
    If objfs.FolderExists(installPath &"\Lib\ensurepip") Then
        deepExtract = objws.Run(""""& installPath &"\python"" -E -s -m ensurepip -U --default-pip", 0, True)
        If deepExtract Then
            WScript.Echo ":: [Error] :: error installing pip."
            Exit Function
        End If
    End If

    ' Add pythonX, pythonXY & pythonX.Y exe
    ' pythonX.Y for tox
    ' Windows try to execute pythonX.Y file (considers Y as en extension)
    ' It requires explicit .bat extension to work (pythonX.Y.bat)
    ' That's why we also use the pattern pythonXY
    Dim version, pythonExe, pythonwExe, major, minor, majorMinor, majorDotMinor
    version = params(LV_Code)
    pythonExe = installPath &"\python.exe"
    pythonwExe = installPath &"\pythonw.exe"
    major = Split(version,".")(0)
    minor = Split(version, ".")(1)
    majorMinor = major & minor
    majorDotMinor = major &"."& minor
    objfs.CopyFile pythonExe, installPath &"\python"& major &".exe"
    objfs.CopyFile pythonExe, installPath &"\python"& majorMinor &".exe"
    objfs.CopyFile pythonExe, installPath &"\python"& majorDotMinor &".exe"
    objfs.CopyFile pythonwExe, installPath &"\pythonw"& major &".exe"
    objfs.CopyFile pythonwExe, installPath &"\pythonw"& majorMinor &".exe"
    objfs.CopyFile pythonwExe, installPath &"\pythonw"& majorDotMinor &".exe"
End Function

Function unzip(installFile, installPath, zipRootDir)
    Dim objFso
	Set objFso = WScript.CreateObject("Scripting.FileSystemObject")
    If objFso.FolderExists(installPath) Then
        unzip = 1
    Else
        ' https://docs.microsoft.com/en-us/previous-versions/windows/desktop/sidebar/system-shell-folder-copyhere
        Dim copyOptions, objShell, objZip, objFiles, objDir
        ' 4: Do not display a progress dialog box.
        copyOptions = 4
        Set objShell = CreateObject("Shell.Application")
        Set objZip = objShell.NameSpace(installFile)
        Set objFiles = objZip.Items()
        If zipRootDir = "" Then
            objFso.CreateFolder(installPath)
            Set objDir = objShell.NameSpace(installPath)
            objDir.copyHere objFiles, copyOptions
        Else
            Dim parentDir
            parentDir = objFso.GetParentFolderName(installPath)
            If Not objFso.FolderExists(parentDir) Then objFso.CreateFolder(parentDir)
            Set objDir = objShell.NameSpace(parentDir)
            objDir.copyHere objFiles, copyOptions
            objFso.moveFolder parentDir &"\"& zipRootDir, installPath
        End If
        unzip = 0
    End If
End Function

Sub registerVersion(version, installPath)
    ' WScript.echo "kkotari: pyenv-install.vbs Register..!"

    ' cscript must be running in 64 bits
    ' (C:\Windows\System32\cscript.exe not C:\Windows\SysWOW64\cscript.exe)
    Dim sh, env
    Set sh = CreateObject("WScript.Shell")
    Set env = sh.Environment("Process")
    Dim arch
    arch = env("PROCESSOR_ARCHITECTURE")
    if arch = "x86" Then
        WScript.Echo "Python registration not supported in 32 bits"
        Exit Sub
    End If

    If InStr(version, "pypy") Then
        WScript.Echo "Registering pypy versions is not supported yet"
        ' TODO guess python version for pypy
        Exit Sub
    End If

    Dim fso, fileVersion, parts, sysVersion, featureVersion, key, subKey
    Set fso = CreateObject("Scripting.FileSystemObject")
    fileVersion = fso.GetFileVersion(installPath &"\python.exe")
    parts = Split(fileVersion, ".")
    sysVersion = parts(0) &"."& parts(1)
    featureVersion = parts(0) &"."& parts(1) &"."& parts(2) &".0"

    key = "HKCU\SOFTWARE\Python\PythonCore\"
    ' I prefer not overriding default Python registry values (that might already exist)
    ' Python Software Foundation
    'sh.RegWrite key & "DiplayName","pyenv-win","REG_SZ"
    ' http://www.python.org/
    'sh.RegWrite key & "SupportUrl","https://github.com/pyenv-win/pyenv-win/issues","REG_SZ"
    key = key & version &"\"
    sh.RegWrite key & "DiplayName","Python "& sysVersion &" (64-bit)","REG_SZ"
    sh.RegWrite key & "SupportUrl","https://github.com/pyenv-win/pyenv-win/issues","REG_SZ"
    sh.RegWrite key & "SysArchitecture","64bit","REG_SZ"
    sh.RegWrite key & "SysVersion",sysVersion,"REG_SZ"
    sh.RegWrite key & "Version",version,"REG_SZ"
    ' python only (not pypy)
    subKey = key & "InstalledFeatures\"
    sh.RegWrite subKey & "dev",featureVersion,"REG_SZ"
    sh.RegWrite subKey & "exe",featureVersion,"REG_SZ"
    sh.RegWrite subKey & "lib",featureVersion,"REG_SZ"
    sh.RegWrite subKey & "pip",featureVersion,"REG_SZ"
    sh.RegWrite subKey & "tools",featureVersion,"REG_SZ"
    ' TODO pypy: pypy3.exe & pypy3w.exe
    subKey = key & "InstallPath\"
    sh.RegWrite subKey,installPath &"\","REG_SZ"
    sh.RegWrite subKey & "ExecutablePath",installPath &"\python.exe","REG_SZ"
    sh.RegWrite subKey & "WindowedExecutablePath",installPath &"\pythonw.exe","REG_SZ"
    ' TODO pypy C:\Users\ded\.pyenv\pyenv-win\versions\pypy3.7-v7.3.4\lib_pypy\
    ' TODO pypy C:\Users\ded\.pyenv\pyenv-win\versions\pypy3.7-v7.3.4\lib-python\3\
    subKey = key & "PythonPath\"
    sh.RegWrite subKey,installPath &"\Lib\;"& installPath &"\DLLs\","REG_SZ"
End Sub

Sub extract(params, register)
    ' WScript.echo "kkotari: pyenv-install.vbs Extract..!"
    Dim installFile
    Dim installFileFolder
    Dim installPath
    Dim zipRootDir

    installFile = params(IP_InstallFile)
    installFileFolder = objfs.GetParentFolderName(installFile)
    installPath = params(IP_InstallPath)
    zipRootDir = params(LV_ZipRootDir)

    If Not objfs.FolderExists(installFileFolder) Then _
        EnsureFolder(installFileFolder)

    If Not objfs.FolderExists(objfs.GetParentFolderName(installPath)) Then _
        EnsureFolder(objfs.GetParentFolderName(installPath))

    If objfs.FolderExists(installPath) Then Exit Sub

    If Not objfs.FileExists(installFile) Then download(params)

    WScript.Echo ":: [Installing] ::  "& params(LV_Code) &" ..."
    objws.CurrentDirectory = installFileFolder

    ' Wrap the paths in quotes in case of spaces in the path.
    Dim qInstallFile
    Dim qInstallPath
    qInstallFile = """"& installFile &""""
    qInstallPath = """"& installPath &""""

    Dim exitCode
    Dim file
    If params(LV_MSI) Then
        exitCode = objws.Run("msiexec /quiet /a "& qInstallFile &" TargetDir="& qInstallPath, 9, True)
        If exitCode = 0 Then
            ' Remove duplicate .msi files from install path.
            For Each file In objfs.GetFolder(installPath).Files
                If LCase(objfs.GetExtensionName(file)) = "msi" Then objfs.DeleteFile file
            Next

            ' If the ensurepip Lib exists, call it manually since "msiexec /a" installs don't do this.
            If objfs.FolderExists(installPath &"\Lib\ensurepip") Then
                exitCode = objws.Run(""""& installPath &"\python"" -E -s -m ensurepip -U --default-pip", 0, True)
                If exitCode Then WScript.Echo ":: [Error] :: error installing pip."
            End If
        End If
    ElseIf params(LV_Web) Then
        exitCode = deepExtract(params, True)
    ElseIf objfs.GetExtensionName(installFile) = "zip" Then
        exitCode = unzip(installFile, installPath, zipRootDir)
    Else
        exitCode = deepExtract(params, False)
        ' Dim quiet
        ' Dim dev

        ' If params(IP_Quiet) Then quiet = " /quiet"
        ' If params(IP_Dev) Then dev = " Include_debug=1 Include_symbols=1 Include_dev=1 "

        ' exitCode = objws.Run(qInstallFile & quiet & dev &" InstallAllUsers=0 Include_launcher=0 Include_test=0 SimpleInstall=1 TargetDir="& qInstallPath, 9, True)
    End If

    If exitCode = 0 Then
        WScript.Echo ":: [Info] :: completed! "& params(LV_Code)
        If register Then
            registerVersion params(LV_Code), installPath
        End If
    Else
        WScript.Echo ":: [Error] :: couldn't install "& params(LV_Code)
    End If
End Sub

Sub main(arg)
    ' WScript.echo "kkotari: pyenv-install.vbs Main..!"
    If arg.Count = 0 Then ShowHelp

    Dim idx
    Dim optForce
    Dim optSkip
    Dim optList
    Dim optQuiet
    Dim optAll
    Dim opt32
    Dim opt64
    Dim optDev
    Dim optReg
    Dim optClear
    Dim installVersions

    optForce = False
    optSkip = False
    optList = False
    optQuiet = False
    optAll = False
    opt32 = False
    opt64 = False
    optDev = False
    optReg = False
    Set installVersions = CreateObject("Scripting.Dictionary")

    For idx = 0 To arg.Count - 1
        Select Case arg(idx)
            Case "--help"           ShowHelp
            Case "-l"               optList = True
            Case "--list"           optList = True
            Case "-f"               optForce = True
            Case "--force"          optForce = True
            Case "-s"               optSkip = True
            Case "--skip-existing"  optSkip = True
            Case "-q"               optQuiet = True
            Case "--quiet"          optQuiet = True
            Case "-a"               optAll = True
            Case "--all"            optAll = True
            Case "-c"               optClear = True
            Case "--clear"          optClear = True
            Case "--32only"         opt32 = True
            Case "--64only"         opt64 = True
            Case "--dev"            optDev = True
            Case "-r"               optReg = True
            Case "--register"       optReg = True
            Case Else
                installVersions.Item(Check32Bit(arg(idx))) = Empty
        End Select
    Next
    If Is32Bit Then
        opt32 = False
        opt64 = False
    End If    
    If opt32 And opt64 Then
        WScript.Echo "pyenv-install: only --32only or --64only may be specified, not both."
        WScript.Quit 1
    End If
    If optReg Then
        If opt32 Then
            WScript.Echo "pyenv-install: --register not supported for 32 bits."
            WScript.Quit 1
        End If
        If optAll Then
            WScript.Echo "pyenv-install: --register not supported for all versions."
            WScript.Quit 1
        End If
    End If

    Dim versions
    Dim version
    Set versions = LoadVersionsXML(strDBFile)
    If versions.Count = 0 Then
        WScript.Echo "pyenv-install: no definitions in local database"
        WScript.Echo
        WScript.Echo "Please update the local database cache with `pyenv update'."
        WScript.Quit 1
    End If

    If optList Then
        For Each version In versions.Keys
            WScript.Echo version
        Next
        Exit Sub
    ElseIf optClear Then
        Dim objCache
        Dim delError
        delError = 0

        On Error Resume Next
        For Each objCache In objfs.GetFolder(strDirCache).Files
            objCache.Delete optForce
            If Err.Number <> 0 Then
                WScript.Echo "pyenv: Error ("& Err.Number &") deleting file "& objCache.Name &": "& Err.Description
                Err.Clear
                delError = 1
            End If
        Next
        For Each objCache In objfs.GetFolder(strDirCache).SubFolders
            objCache.Delete optForce
            If Err.Number <> 0 Then
                WScript.Echo "pyenv: Error ("& Err.Number &") deleting folder "& objCache.Name &": "& Err.Description
                Err.Clear
                delError = 1
            End If
        Next
        WScript.Quit delError
    End If

    If optAll Then
        ' Add all versions, but only 32-bit versions for 32-bit platforms.
        ' --32only/--64only is disabled on 32-bit platforms.
        installVersions.RemoveAll
        For Each version In versions.Keys
            version = Check32Bit(version)
            If versions.Exists(version) Then
                If opt64 Then
                    If versions(version)(LV_x64) Then _
                        installVersions(version) = Empty
                ElseIf opt32 Then
                    If Not versions(version)(LV_x64) Then _
                        installVersions(version) = Empty
                Else
                    installVersions(version) = Empty
                End If
            End If
        Next
    Else
        If installVersions.Count = 0 Then
            Dim ary
            ' TODO Should we handle many versions here?
            ary = GetCurrentVersionNoError()
            If Not IsNull(ary) Then
                installVersions.Item(ary(0)) = Empty
            Else
                ShowHelp
            End If    
        End If
    End If

    ' Pre-check if all versions to install exist.
    For Each version In installVersions.Keys
        If Not versions.Exists(version) Then
            WScript.Echo "pyenv-install: definition not found: "& version
            WScript.Echo
            WScript.Echo "See all available versions with `pyenv install --list'."
            WScript.Quit 1
        End If
    Next

    Dim verDef
    Dim installParams
    Dim installed
    Set installed = CreateObject("Scripting.Dictionary")

    For Each version In installVersions.Keys
        If Not installed.Exists(version) Then
            verDef = versions(version)
            installParams = Array( _
                verDef(LV_Code), _
                verDef(LV_FileName), _
                verDef(LV_URL), _
                verDef(LV_x64), _
                verDef(LV_Web), _
                verDef(LV_MSI), _
                verDef(LV_ZipRootDir), _
                strDirVers &"\"& verDef(LV_Code), _
                strDirCache &"\"& verDef(LV_FileName), _
                optQuiet, _
                optDev _
            )
            If optForce Then clear(installParams)
            extract installParams, optReg
            installed(version) = Empty
        End If
    Next
    Rehash
End Sub

main(WScript.Arguments)
