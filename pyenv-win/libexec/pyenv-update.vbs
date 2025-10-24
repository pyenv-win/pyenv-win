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

Dim mirror
For Each mirror In mirrors
    WScript.Echo ":: [Info] ::  Mirror: " & mirror
Next

Sub ShowHelp()
    WScript.Echo "Usage: pyenv update [--ignore]"
    WScript.Echo
    WScript.Echo "  --ignore  Ignores any HTTP/VBScript errors that occur during downloads."
    WScript.Echo
    WScript.Echo "Updates the internal database of python installer URL's."
    WScript.Echo
    WScript.Quit 0
End Sub

Function ResolveUrl(ByVal baseUrl, ByVal href)
    Dim lhref
    lhref = LCase(href)
    If Left(lhref, 7) = "http://" Or Left(lhref, 8) = "https://" Then
        ResolveUrl = href
        Exit Function
    End If

    If Right(baseUrl, 1) <> "/" Then baseUrl = baseUrl & "/"

    If Left(href, 1) = "/" Then
        Dim re, matches
        Set re = New RegExp
        re.Pattern = "^(https?://[^/]+)"
        re.IgnoreCase = True
        Set matches = re.Execute(baseUrl)
        If matches.Count > 0 Then
            ResolveUrl = matches(0).SubMatches(0) & href
        Else
            ResolveUrl = baseUrl & Mid(href, 2)
        End If
    Else
        ResolveUrl = baseUrl & href
    End If
End Function

Function CollectionToArray(collection)
    Dim i
    Dim arr()
    ReDim arr(collection.Count-1)
    For i = 0 To collection.Count-1
        If IsObject(collection.Item(i)) Then
            Set arr(i) = collection.Item(i)
        Else
            arr(i) = collection.Item(i)
        End If
    Next
    CollectionToArray = arr
End Function

Function CopyDictionary(dict)
    Dim key
    Set CopyDictionary = CreateObject("Scripting.Dictionary")
    For Each key In dict.Keys
        CopyDictionary.Add key, dict(key)
    Next
End Function

Sub UpdateDictionary(dict1, dict2)
    Dim key
    For Each key In dict2.Keys
        If IsObject(dict2(key)) Then
            Set dict1(key) = dict2(key)
        Else
            dict1(key) = dict2(key)
        End If
    Next
End Sub

Function ExtractHrefs(text)
    Dim re, m, arr()
    Set re = New RegExp
    re.Pattern = "href\s*=\s*""([^""]+)"""
    re.Global = True
    re.IgnoreCase = True
    Set m = re.Execute(text)
    ReDim arr(m.Count-1)
    Dim i
    For i = 0 To m.Count-1
        arr(i) = m(i).SubMatches(0)
    Next
    ExtractHrefs = arr
End Function

Function LastPathSegment(path)
    Dim p
    p = Split(path, "?")(0)
    If Right(p, 1) = "/" Then p = Left(p, Len(p)-1)
    Dim idx
    idx = InStrRev(p, "/")
    If idx > 0 Then
        LastPathSegment = Mid(p, idx+1)
    Else
        LastPathSegment = p
    End If
End Function

Function EnsureTrailingSlash(url)
    If Right(url, 1) <> "/" Then
        EnsureTrailingSlash = url & "/"
    Else
        EnsureTrailingSlash = url
    End If
End Function

Function URLExists(u)
    On Error Resume Next
    Dim req
    Set req = CreateObject("WinHttp.WinHttpRequest.5.1")
    req.Open "GET", u, False
    req.setRequestHeader "Range", "bytes=0-0"
    req.Send
    If Err.Number <> 0 Then
        URLExists = False
        Err.Clear
        Exit Function
    End If
    On Error GoTo 0
    URLExists = (req.Status = 200 Or req.Status = 206)
End Function

Sub TryAddDirectInstaller(ByRef dict, ByVal baseUrl, ByVal versionStr, ByVal arch)
    Dim fileName, url, m
    If arch = "" Then
        fileName = "python-" & versionStr & ".exe"
    Else
        fileName = "python-" & versionStr & "-" & arch & ".exe"
    End If
    baseUrl = EnsureTrailingSlash(baseUrl)
    url = baseUrl & fileName
    If URLExists(url) Then
        Set m = regexFile.Execute(fileName)
        If m.Count = 1 Then
            dict(fileName) = Array(fileName, url, CollectionToArray(m(0).SubMatches))
        End If
    End If
End Sub

Sub AddDirectInstallersForVersion(ByRef dict, ByVal versionUrl, ByVal versionStr)
    Dim m
    Set m = regexVer.Execute(versionStr)
    If m.Count = 1 Then
        If CLng(m(0).SubMatches(0)) >= 3 Then
            TryAddDirectInstaller dict, versionUrl, versionStr, "amd64"
            TryAddDirectInstaller dict, versionUrl, versionStr, "arm64"
            TryAddDirectInstaller dict, versionUrl, versionStr, ""
        End If
    End If
End Sub

Sub AugmentCPythonSpan(ByRef dict, ByVal startMinor, ByVal endMinor, ByVal maxPatch)
    Dim base, minor, patch, ver, verUrl, misses
    base = "https://www.python.org/ftp/python/3."
    For minor = startMinor To endMinor
        misses = 0
        For patch = 0 To maxPatch
            ver = "3." & CStr(minor) & "." & CStr(patch)
            verUrl = base & CStr(minor) & "." & CStr(patch) & "/"
            If URLExists(verUrl) Then
                AddDirectInstallersForVersion dict, verUrl, ver
                misses = 0
            Else
                misses = misses + 1
                If misses >= 5 Then Exit For
            End If
        Next
    Next
End Sub

Function ScanForVersions(URL, optIgnore, ByRef pageCount)
    ' Parse using regex over the response, no DOM dependency.
    Set ScanForVersions = CreateObject("Scripting.Dictionary")

    With objweb
        .open "GET", URL, False
        On Error Resume Next
        .send
        If Err.number <> 0 Then
            WScript.Echo "HTTP Error downloading from mirror page """& URL &""""& vbCrLf &"Error(0x"& Hex(Err.Number) &"): "& Err.Description
            If optIgnore Then Exit Function
            WScript.Quit 1
        End If
        On Error GoTo 0
        If .status <> 200 Then
            WScript.Echo "HTTP Error downloading from mirror page """& URL &""""& vbCrLf &"Error("& .status &"): "& .statusText
            If optIgnore Then Exit Function
            WScript.Quit 1
        End If

        Dim pageText
        pageText = .responseText
        pageCount = pageCount + 1
    End With
    ' Base resolution handled by ResolveUrl; no DOM base tag needed.

    Dim hrefs, href
    Dim fileName
    Dim matches
    hrefs = ExtractHrefs(pageText)
    For Each href In hrefs
        fileName = LastPathSegment(href)
        Set matches = regexFile.Execute(fileName)
        If matches.Count = 1 Then
            ScanForVersions.Add fileName, Array(fileName, ResolveUrl(URL, href), CollectionToArray(matches(0).SubMatches))
        End If
    Next

    ' Handle per-architecture subdirectories introduced in newer releases (amd64/arm64/win32)
    Dim archHref
    For Each href In hrefs
        archHref = LCase(href)
        If Right(archHref, 1) = "/" Then archHref = Left(archHref, Len(archHref) - 1)
        If archHref = "amd64" Or archHref = "arm64" Or archHref = "win32" Then
            UpdateDictionary ScanForVersions, ScanForVersions(ResolveUrl(URL, href), optIgnore, pageCount)
        End If
    Next
End Function

Sub main(arg)
    Dim optIgnore
    optIgnore = False

    If arg.Count >= 1 then
        If arg(0) = "--help" then
            ShowHelp
        ElseIf arg(0) = "--ignore" Then
            optIgnore = True
        End If
    End If

    ' No DOM usage; parse text only.
    Dim pageCount
    pageCount = 0

    Dim installers1
    Set installers1 = CreateObject("Scripting.Dictionary")

    For Each mirror In mirrors
        ' No DOM usage here.
        With objweb
            On Error Resume Next
            .Open "GET", mirror, False
            If Err.number <> 0 Then
                WScript.Echo "HTTP Error downloading from mirror """& mirror &""""& vbCrLf &"Error(0x"& Hex(Err.number) &"): "& Err.Description
                If optIgnore Then Exit Sub
                WScript.Quit 1
            End If

            .Send
            If Err.number <> 0 Then
                WScript.Echo "HTTP Error downloading from mirror """& mirror &""""& vbCrLf &"Error(0x"& Hex(Err.number) &"): "& Err.Description
                If optIgnore Then Exit Sub
                WScript.Quit 1
            End If
            On Error GoTo 0

            If .Status <> 200 Then
                WScript.Echo "HTTP Error downloading from mirror """& mirror &""""& vbCrLf &"Error("& .Status &"): "& .StatusText
                If optIgnore Then Exit Sub
                WScript.Quit 1
            End If

            Dim pageText
            pageText = .responseText
            pageCount = pageCount + 1
        End With
        ' Base resolution handled by ResolveUrl; no DOM base tag needed.

        Dim version
        Dim matches
        ' Try JSON (PyPy/GraalPy) directly on the raw text
        Dim match
        Set matches = regexJsonUrl.Execute(pageText)
        If matches.Count > 0 Then
            For Each match in matches
                installers1(match.SubMatches(1)) = Array( _
                    match.SubMatches(1), _
                    match.SubMatches(0), _
                    Array(match.SubMatches(3), match.SubMatches(4), match.SubMatches(5), "", "", match.SubMatches(6), match.SubMatches(7), "", "zip", match.SubMatches(2)) _
                )
            Next
        Else
            ' HTML directory listing: extract hrefs and recurse into version directories
            Dim hrefs2, href2, relHref
            hrefs2 = ExtractHrefs(pageText)
            For Each href2 In hrefs2
                relHref = href2
                If Right(relHref, 1) = "/" Then relHref = Left(relHref, Len(relHref)-1)
                version = LastPathSegment(relHref)
                Set matches = regexVer.Execute(version)
                If matches.Count = 1 Then
                    UpdateDictionary installers1, ScanForVersions(ResolveUrl(mirror, href2), optIgnore, pageCount)
                    ' Also synthesize direct installer URLs if present
                    AddDirectInstallersForVersion installers1, ResolveUrl(mirror, href2), version
                End If
            Next
        End If
    Next

    ' Now remove any duplicate versions that have the offline installer (it's prefered)
    Dim minVers
    Dim fileName, fileNonWeb
    Dim versPieces
    Dim installers2
    Set installers2 = CopyDictionary(installers1) ' Use a copy because "For Each" and .Remove don't play nice together.
    minVers = Array("2", "4", "", "", "", "", "", "", "")
    For Each fileName In installers1.Keys()
        ' Array([filename], [url], Array([major], [minor], [path], [rel], [rel_num], [x64], [ARM], [webinstall], [ext]))
        versPieces = installers1(fileName)(SFV_Version)

        ' Ignore versions <2.4, Wise Installer's command line is unusable.
        If SymanticCompare(versPieces, minVers) Then
            installers2.Remove fileName
        ' Drop non-CPython distributions (PyPy/GraalPy)
        ElseIf LCase(Left(fileName, 4)) = "pypy" Or LCase(Left(fileName, 7)) = "graalpy" Then
            installers2.Remove fileName
        ' Drop release candidates (rc)
        ElseIf LCase(versPieces(VRX_Release)) = "rc" Then
            installers2.Remove fileName
        ElseIf LCase(versPieces(VRX_Release)) = "a" Then
            installers2.Remove fileName
        ElseIf LCase(versPieces(VRX_Release)) = "b" Then
            installers2.Remove fileName
        ElseIf Len(versPieces(VRX_Web)) Then
            fileNonWeb = "python-"& JoinInstallString(Array( _
                versPieces(VRX_Major), _
                versPieces(VRX_Minor), _
                versPieces(VRX_Patch), _
                versPieces(VRX_Release), _
                versPieces(VRX_RelNumber), _
                versPieces(VRX_x64), _
                versPieces(VRX_ARM), _
                Empty, _
                versPieces(VRX_Ext) _
            ))
            If installers2.Exists(fileNonWeb) Then _
                installers2.Remove fileName
        End If
    Next

    ' Now sort by semantic version and save
    Dim installArr
    installArr = installers2.Items
    ' Augment explicitly for current stable series to ensure presence
    ' Cover 3.9 up to 3.30, patches 0..30 (stable only)
    AugmentCPythonSpan installers2, 9, 30, 30
    installArr = installers2.Items
    SymanticQuickSort installArr, LBound(installArr), UBound(installArr)
    SaveVersionsXML strDBFile, installArr
    WScript.Echo ":: [Info] ::  Scanned "& pageCount &" pages and found "& installers2.Count &" installers."

End Sub

main(WScript.Arguments)
