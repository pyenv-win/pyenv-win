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
    WScript.Echo "Usage: pyenv install [-f] <version> [<version> ...]"
    WScript.Echo "       pyenv install [-f] [--32only|--64only] -a|--all"
    WScript.Echo "       pyenv install [-f] -c|--clear"
    WScript.Echo "       pyenv install -l|--list"
    WScript.Echo ""
    WScript.Echo "  -l/--list   List all available versions"
    WScript.Echo "  -a/--all    Installs all known version from the local version DB cache"
    WScript.Echo "  -c/--clear  Removes downloaded installers from the cache to free space"
    WScript.Echo "  -f/--force  Install even if the version appears to be installed already"
    WScript.Echo "  -q/--quiet  Install using /quiet. This does not show the UI nor does it prompt for inputs"
    WScript.Echo "  --32only    Installs only 32bit Python using -a/--all switch, no effect on 32-bit windows."
    WScript.Echo "  --64only    Installs only 64bit Python using -a/--all switch, no effect on 32-bit windows."
    WScript.Echo "  --help      Help, list of options allowed on pyenv install"
    WScript.Echo ""
    WScript.Quit
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

Function deepExtract(params)
    ' WScript.echo "kkotari: pyenv-install.vbs deepExtract..!"
    Dim webCachePath
    Dim installPath
    webCachePath = strDirCache &"\"& params(LV_Code) &"-webinstall"
    installPath = params(IP_InstallPath)
    deepExtract = -1

    If Not objfs.FolderExists(webCachePath) Then
        deepExtract = objws.Run(""""& params(IP_InstallFile) &""" /quiet /layout """& webCachePath &"""", 0, True)
        If deepExtract Then
            WScript.Echo ":: [Error] :: error using web installer."
            Exit Function
        End If
    End If

    ' Clean unused install files.
    Dim file
    Dim baseName
    For Each file In objfs.GetFolder(webCachePath).Files
        baseName = LCase(objfs.GetBaseName(file))
        If LCase(objfs.GetExtensionName(file)) <> "msi" Or _
           Right(baseName, 2) = "_d" Or _
           Right(baseName, 4) = "_pdb" Or _
           baseName = "launcher" Or _
           baseName = "path" Or _
           baseName = "pip" _
        Then
            objfs.DeleteFile file
        End If
    Next

    ' Install the remaining MSI files into our install folder.
    Dim msi
    For Each file In objfs.GetFolder(webCachePath).Files
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
End Function

Sub extract(params)
    ' WScript.echo "kkotari: pyenv-install.vbs Extract..!"
    Dim installFile
    Dim installFileFolder
    Dim installPath
    Dim quiet

    installFile = params(IP_InstallFile)
    installFileFolder = objfs.GetParentFolderName(installFile)
    installPath = params(IP_InstallPath)
    If params(IP_Quiet) Then quiet = " /quiet"

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
        exitCode = deepExtract(params)
    Else
        exitCode = objws.Run(qInstallFile & quiet &" InstallAllUsers=0 Include_launcher=0 Include_test=0 SimpleInstall=1 TargetDir="& qInstallPath, 9, True)
    End If

    If exitCode = 0 Then
        WScript.Echo ":: [Info] :: completed! "& params(LV_Code)
        ' SetGlobalVersion params(LV_Code)
    Else
        WScript.Echo ":: [Error] :: couldn't install .. "& params(LV_Code)
    End If
End Sub

Sub main(arg)
    ' WScript.echo "kkotari: pyenv-install.vbs Main..!"
    If arg.Count = 0 Then ShowHelp

    Dim idx
    Dim optForce
    Dim optList
    Dim optQuiet
    Dim optAll
    Dim opt32
    Dim opt64
    Dim optClear
    Dim installVersions

    optForce = False
    optList = False
    optQuiet = False
    optAll = False
    opt32 = False
    opt64 = False
    Set installVersions = CreateObject("Scripting.Dictionary")

    For idx = 0 To arg.Count - 1
        Select Case arg(idx)
            Case "--help"   ShowHelp
            Case "-l"       optList = True
            Case "--list"   optList = True
            Case "-f"       optForce = True
            Case "--force"  optForce = True
            Case "-q"       optQuiet = True
            Case "--quiet"  optQuiet = True
            Case "-a"       optAll = True
            Case "--all"    optAll = True
            Case "-c"       optClear = True
            Case "--clear"  optClear = True
            Case "--32only" opt32 = True
            Case "--64only" opt64 = True
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
                strDirVers &"\"& verDef(LV_Code), _
                strDirCache &"\"& verDef(LV_FileName), _
                optQuiet _
            )
            If optForce Then clear(installParams)
            extract(installParams)
            installed(version) = Empty
        End If
    Next
    Rehash
End Sub

main(WScript.Arguments)
