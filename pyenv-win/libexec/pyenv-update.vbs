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
    WScript.Echo "Usage: pyenv update [--ignore]"
    WScript.Echo
    WScript.Echo "  --ignore  Ignores any HTTP/VBScript errors that occur during downloads."
    WScript.Echo
    WScript.Echo "Updates the internal database of python installer URL's."
    WScript.Echo
    WScript.Quit 0
End Sub

Sub EnsureBaseURL(ByRef html, ByVal URL)
    Dim head
    Dim base

    Set head = html.getElementsByTagName("head")(0)
    If head Is Nothing Then
        Set head = html.createElement("head")
        html.insertBefore html.body, head
    End If

    Set base = head.getElementsByTagName("base")(0)
    If base Is Nothing Then
        If Len(URL) And Right(URL, 1) <> "/" Then URL = URL &"/"
        Set base = html.createElement("base")
        base.href = URL
        head.appendChild base
    End If
End Sub

Function CollectionToArray(collection) _
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

Function ScanForVersions(URL, optIgnore, ByRef pageCount)
    Dim objHTML
    Dim shell
    Dim cmd
    Dim msg
    Dim result
    Set objHTML = CreateObject("htmlfile")
    Set shell = CreateObject("WScript.Shell")
    Set ScanForVersions = CreateObject("Scripting.Dictionary")

    With objweb
        On Error Resume Next
        .open "GET", URL, False
        .Option(WinHttpRequestSslErrorFlags_SslErrorFlag_Ignore_All) = true
        .send
        If Err.number <> 0 Then
            msg = "HTTP Error downloading on send from mirror page """& URL &""""& vbCrLf &"Error(0x"& Hex(Err.Number) &"): "& Err.Description
            Err.clear
            cmd = "cmd /c curl -L " & URL
            'WScript.Echo "    Failed to download via WinHTTP, attempting cURL"
            'WScript.Echo "    cURL command: """& cmd &""""
            Set result = shell.Exec(cmd)
            If Err.number = 0 Then
                'WScript.Echo "    cURL did not error, using cURL's output"
                'WScript.Echo "    cURL output: "
                'WScript.Echo result.stdOut.ReadAll
                'WScript.Echo "^^^ cURL output ^^^"
                objHTML.write result.StdOut.ReadAll
                'WScript.Echo "    cURL succeeded getting """& objHTML.title &""""
            End If
            If Err.number <> 0 Then
                WScript.Echo msg & ", and attempting to fall back to a system cURL call failed ("& Err.number &"): "& Err.Description
                If optIgnore Then Exit Function
                WScript.Quit 1
            End If
            On Error GoTo 0
        ElseIf .Status <> 200 Then
            WScript.Echo "HTTP Status Error downloading from version page """& URL &""""& vbCrLf &"Error("& .Status &"): "& .StatusText
            If optIgnore Then Exit Function
            WScript.Quit 1
        Else
            objHTML.write .responseText
        End If

        pageCount = pageCount + 1
    End With
    EnsureBaseURL objHTML, URL

    Dim link
    Dim fileName
    Dim matches
    Dim major, minor, patch, rel
    For Each link In objHTML.links
        fileName = Trim(link.innerText)
        Set matches = regexFile.Execute(fileName)
        If matches.Count = 1 Then
            ' Save as a dictionary entry with Key/Value as:
            '  -Key: [filename]
            '  -Value: Array([filename], [url], Array([regex submatches]))
            ScanForVersions.Add fileName, Array(fileName, link.href, CollectionToArray(matches(0).SubMatches))
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

    Dim objHTML
    Dim pageCount
    Dim shell
    Dim cmd
    Dim msg
    Dim result
    Set objHTML = CreateObject("htmlfile")
    Set shell = CreateObject("WScript.Shell")
    pageCount = 0
    With objweb
        On Error Resume Next
        .Open "GET", mirror, False
        If Err.number <> 0 Then
            WScript.Echo "Raw open err != 0 "& Err.number
            WScript.Echo "HTTP Error downloading from mirror """& mirror &""""& vbCrLf &"Error(0x"& Hex(Err.number) &"): "& Err.Description
            If optIgnore Then Exit Sub
            WScript.Quit 1
        End If

        .Option(WinHttpRequestSslErrorFlags_SslErrorFlag_Ignore_All) = true

        .Send
        If Err.number <> 0 Then
            msg = "HTTP Error (send) downloading from mirror """& mirror &""""& vbCrLf &"Error(0x"& Hex(Err.number) &"): "& Err.Description
            Err.clear
            cmd = "cmd /c curl -L " & mirror
            'WScript.Echo "    Failed to update from WinHTTP, attempting cURL"
            'WScript.Echo "    cURL command: """& cmd &""""
            Set result = shell.Exec(cmd)
            If Err.number = 0 Then
                'WScript.Echo "    cURL did not error, using cURL's output"
                'WScript.Echo "    cURL output: "
                'WScript.Echo result.stdOut.ReadAll
                'WScript.Echo "^^^ cURL output ^^^"
                objHTML.write result.StdOut.ReadAll
                WScript.Echo "    cURL succeeded getting """& objHTML.title &""""
            End If
            If Err.number <> 0 Then
                WScript.Echo msg & ", and attempting to fall back to a system cURL call failed ("& Err.number &"): "& Err.Description
                If optIgnore Then Exit Sub
                WScript.Quit 1
            End If
            On Error GoTo 0
        ElseIf .Status <> 200 Then
            WScript.Echo "HTTP Error downloading from mirror """& mirror &""""& vbCrLf &"Error("& .Status &"): "& .StatusText
            If optIgnore Then Exit Sub
            WScript.Quit 1
        Else
            objHTML.write .responseText
        End If

        pageCount = pageCount + 1
    End With

    EnsureBaseURL objHTML, mirror

    Dim link
    Dim version
    Dim matches
    Dim installers1
    Set installers1 = CreateObject("Scripting.Dictionary")
    For Each link In objHTML.links
        version = objfs.GetFileName(link.pathname)
        Set matches = regexVer.Execute(version)
        If matches.Count = 1 Then _
            UpdateDictionary installers1, ScanForVersions(link.href, optIgnore, pageCount)
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
    SymanticQuickSort installArr, LBound(installArr), UBound(installArr)
    SaveVersionsXML strDBFile, installArr
    WScript.Echo ":: [Info] ::  Scanned "& pageCount &" pages and found "& installers2.Count &" installers."

End Sub

main(WScript.Arguments)
