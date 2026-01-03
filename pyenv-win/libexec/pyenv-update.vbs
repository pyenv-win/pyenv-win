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

Sub ShowHelp()
    WScript.Echo "Usage: pyenv update [--ignore]"
    WScript.Echo
    WScript.Echo "  --ignore  Ignores any HTTP/VBScript errors that occur during downloads."
    WScript.Echo
    WScript.Echo "Updates the internal database of python installer URL's."
    WScript.Echo
    WScript.Quit 0
End Sub

Sub LoadHTMLIntoDoc(ByRef doc, ByVal htmlContent)
    Dim docType
    docType = TypeName(doc)

    If docType = "HTMLDocument" Or docType = "htmlfile" Then
        ' Use htmlfile's write method
        On Error Resume Next
        doc.write htmlContent
        If Err.Number <> 0 Then
            ' Silently ignore write errors
        End If
        On Error GoTo 0
    Else
        ' MSXML2.DOMDocument path - but HTML is malformed, so use regex parsing
        ' We'll parse HTML using regex in the main function
        ' No need to load into DOMDocument
    End If
End Sub

' Function to parse links from raw HTML using regex
Function ParseLinksFromHTML(ByVal htmlContent)
    Dim regex
    Dim matches
    Dim links
    Set links = CreateObject("Scripting.Dictionary")

    Set regex = New RegExp
    regex.Pattern = "<a\s+[^>]*href\s*=\s*[""']([^""']+)[""'][^>]*>([^<]*)</a>"
    regex.IgnoreCase = True
    regex.Global = True

    Set matches = regex.Execute(htmlContent)

    Dim i
    For i = 0 To matches.Count - 1
        ' Store link info as an array [href, text]
        links.Add i, Array(matches(i).SubMatches(0), matches(i).SubMatches(1))
    Next

    Set ParseLinksFromHTML = links
End Function

Function GetLinksCollection(ByRef doc)
    On Error Resume Next
    ' Check if doc is htmlfile (has .write method)
    doc.write ""
    If Err.Number = 0 Then
        Err.Clear
        ' It's htmlfile, use .links property
        Set GetLinksCollection = doc.links
    Else
        Err.Clear
        ' It's MSXML2.DOMDocument, get <a> elements
        Set GetLinksCollection = doc.getElementsByTagName("a")
        ' Also try uppercase <A> in case HTML is in uppercase
        If GetLinksCollection.Length = 0 Then
            Set GetLinksCollection = doc.getElementsByTagName("A")
        End If
        ' Also check for <link> elements
        If GetLinksCollection.Length = 0 Then
            Set GetLinksCollection = doc.getElementsByTagName("link")
        End If
    End If
    On Error GoTo 0
End Function

Function GetLinkHref(ByRef link)
    On Error Resume Next
    ' Try to use .href property (for htmlfile)
    GetLinkHref = link.href
    If Err.Number <> 0 Then
        Err.Clear
        ' For XML elements, get href attribute
        GetLinkHref = link.getAttribute("href")
    End If
    On Error GoTo 0
End Function

Function GetLinkPathname(ByRef link)
    On Error Resume Next
    ' Try to use .pathname property (for htmlfile)
    GetLinkPathname = link.pathname
    If Err.Number <> 0 Then
        Err.Clear
        ' For XML elements, extract from href
        GetLinkPathname = GetLinkHref(link)
    End If
    On Error GoTo 0
End Function

Function GetLinkText(ByRef link)
    On Error Resume Next
    ' Try to use .innerText property (for htmlfile)
    GetLinkText = link.innerText
    If Err.Number <> 0 Then
        Err.Clear
        ' For XML elements, use .text
        GetLinkText = link.text
    End If
    On Error GoTo 0
End Function

Sub EnsureBaseURL(ByRef html, ByVal URL)
    Dim head
    Dim base

    On Error Resume Next
    Set head = html.getElementsByTagName("head")(0)
    If Err.Number <> 0 Then
        Err.Clear
        Exit Sub
    End If
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
    On Error GoTo 0
End Sub

Function CollectionToArray(collection)
    Dim i
    Dim arr()
    ReDim arr(13)
    If Not IsObject(collection) Or IsNull(collection) Then
        For i = 0 To 13
            arr(i) = ""
        Next
        CollectionToArray = arr
        Exit Function
    End If
    On Error Resume Next
    For i = 0 To collection.Count-1
        If i <= 13 Then
            If IsObject(collection.Item(i)) Then
                Set arr(i) = collection.Item(i)
            Else
                arr(i) = collection.Item(i)
            End If
        End If
        If Err.Number <> 0 Then
            arr(i) = ""
            Err.Clear
        End If
    Next
    For i = collection.Count To 13
        arr(i) = ""
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
    On Error Resume Next
    For Each key In dict2.Keys
        If IsObject(dict2(key)) Then
            Set dict1(key) = dict2(key)
        Else
            dict1(key) = dict2(key)
        End If
        If Err.Number <> 0 Then Err.Clear
    Next
    On Error GoTo 0
End Sub

Function ScanForVersions(URL, optIgnore)
    Set ScanForVersions = CreateObject("Scripting.Dictionary")

    On Error Resume Next
    objweb.Open "GET", URL, False
    ' Add User-Agent header for compatibility
    objweb.SetRequestHeader "User-Agent", "Mozilla/5.0 (compatible; pyenv-win)"
    objweb.SetRequestHeader "Accept", "*/*"
    objweb.Send
    If Err.number <> 0 Then
        WScript.Echo "HTTP Error downloading from mirror page """& URL &""""& vbCrLf &"Error(0x"& Hex(Err.Number) &"): "& Err.Description
        If optIgnore Then
            Err.Clear
            Exit Function
        End If
        WScript.Quit 1
    End If
    On Error GoTo 0
    If objweb.status <> 200 Then
        WScript.Echo "HTTP Error downloading from mirror page """& URL &""""& vbCrLf &"Error("& objweb.status &"): "& objweb.statusText
        If optIgnore Then Exit Function
        WScript.Quit 1
    End If

    On Error GoTo 0

    ' Check if response is JSON format
    Dim responseText
    responseText = objweb.responseText
    Dim isJSON
    isJSON = False
    On Error Resume Next
    ' Check for JSON array or object at the start
    If Left(Trim(responseText), 1) = "[" Or Left(Trim(responseText), 1) = "{" Then
        isJSON = True
    End If
    On Error GoTo 0

    If isJSON Then
        ' For JSON format, only parse files (not directories)
        ' This is called only for version directories, not the root
        On Error Resume Next
        Set ScanForVersions = ParseFilesFromJSON(responseText, URL)
        If Err.Number <> 0 Then
            WScript.Echo ":: [Error] :: ParseFilesFromJSON failed for """& URL &""" - Error " & Err.Number & ": " & Err.Description
            Err.Clear
        End If
        On Error GoTo 0
        ' Note: Do NOT call ScanForVersions recursively for JSON
    Else
        ' Use regex to parse links directly from HTML
        Dim regexLinks
        Set regexLinks = ParseLinksFromHTML(responseText)

        ' Check if regexFile is available
        If regexFile Is Nothing Then
            WScript.Echo ":: [Error] :: regexFile is not initialized in HTML parsing"
            Exit Function
        End If

        ' Debug: show first few files found
        Dim foundCount
        foundCount = 0
        Dim linkKey
        For Each linkKey In regexLinks.Keys
            Dim linkInfo
            linkInfo = regexLinks(linkKey)

            Dim fileName
            Dim href
            Dim fullFileURL
            fileName = Trim(linkInfo(1))
            href = linkInfo(0)

            ' Build the full URL for the file
            ' href could be relative (e.g., "python-3.13.7-amd64.exe") or absolute
            If InStr(href, "://") > 0 Then
                ' href is already a full URL
                fullFileURL = href
            Else
                ' href is relative - need to construct full URL
                Dim baseURL
                baseURL = URL

                ' If href starts with "/", it's absolute from domain root
                If Left(href, 1) = "/" Then
                    ' Extract protocol and domain from base URL
                    Dim protoDomain
                    Dim pos
                    pos = InStr(baseURL, "/")
                    pos = InStr(pos + 2, baseURL, "/")
                    If pos > 0 Then
                        protoDomain = Left(baseURL, pos - 1)
                        fullFileURL = protoDomain & href
                    Else
                        ' Fallback: just append
                        fullFileURL = baseURL & href
                    End If
                Else
                    ' Relative path - combine base URL with href
                    If Right(baseURL, 1) = "/" Then
                        fullFileURL = baseURL & href
                    Else
                        fullFileURL = baseURL & "/" & href
                    End If
                End If
            End If

            Dim matches
            Set matches = regexFile.Execute(fileName)
            If matches.Count = 1 Then
                ' Store the FULL URL instead of just the href
                ScanForVersions.Add fileName, Array(fileName, fullFileURL, CollectionToArray(matches(0).SubMatches))
                foundCount = foundCount + 1
            End If
        Next
    End If
End Function

' Parse files from JSON response (files only)
Function ParseFilesFromJSON(jsonText, baseURL)
    Set ParseFilesFromJSON = CreateObject("Scripting.Dictionary")

    ' Parse only files (not directories) - use simple approach
    On Error Resume Next

    ' First, check if response contains file type entries
    Dim checkStr
    checkStr = Replace(jsonText, " ", "")
    checkStr = Replace(checkStr, vbCrLf, "")
    checkStr = Replace(checkStr, vbTab, "")
    If InStr(checkStr, Chr(34) & "type" & Chr(34) & ":" & Chr(34) & "file" & Chr(34)) = 0 Then
        Exit Function
    End If

    Dim regex
    Dim pattern
    Set regex = New RegExp
    ' VBScript-friendly pattern for JSON file entries
    ' Match content between { and } where type is "file"
    pattern = "name" & Chr(34) & ":\s*" & Chr(34) & "([^" & Chr(34) & "]+)" & Chr(34) & "[^}]*?" & "type" & Chr(34) & ":\s*" & Chr(34) & "file" & Chr(34)
    regex.Pattern = pattern
    regex.Global = True
    regex.IgnoreCase = True
    regex.Multiline = True

    Dim matches
    Set matches = regex.Execute(jsonText)
    If Err.Number <> 0 Then
        Err.Clear
        Exit Function
    End If

    ' Check if regexFile is available
    If regexFile Is Nothing Then
        WScript.Echo ":: [Error] :: regexFile is not initialized"
        Exit Function
    End If

    Dim i
    For i = 0 To matches.Count - 1
        On Error Resume Next
        Dim fileName
        fileName = matches(i).SubMatches(0)

        ' Check if it's a Python installer file
        Dim fileMatches
        Set fileMatches = regexFile.Execute(fileName)
        If Err.Number <> 0 Then
            WScript.Echo ":: [Error] :: regexFile.Execute failed for """& fileName &""" - Error " & Err.Number & ": " & Err.Description
            Err.Clear
        ElseIf fileMatches.Count = 1 Then
            ' Construct full URL
            Dim fullFileURL
            If Right(baseURL, 1) = "/" Then
                fullFileURL = baseURL & fileName
            Else
                fullFileURL = baseURL & "/" & fileName
            End If

            On Error Resume Next
            ParseFilesFromJSON.Add fileName, Array(fileName, fullFileURL, CollectionToArray(fileMatches(0).SubMatches))
            If Err.Number <> 0 Then
                WScript.Echo ":: [Error] :: Failed to add file """& fileName &""" to dictionary - Error " & Err.Number & ": " & Err.Description
                Err.Clear
            End If
            On Error GoTo 0
        End If

        If Err.Number <> 0 Then
            Err.Clear
        End If
        On Error GoTo 0
    Next
End Function

' Test if ver1 < ver2
Function SymanticCompare(ver1, ver2)
    Dim comp1, comp2

    If Not IsArray(ver1) Or Not IsArray(ver2) Then
        SymanticCompare = False
        Exit Function
    End If
    If UBound(ver1) < 0 Or UBound(ver2) < 0 Then
        SymanticCompare = False
        Exit Function
    End If

    ' Major
    If UBound(ver1) >= VRX_Major And UBound(ver2) >= VRX_Major Then
        comp1 = ver1(VRX_Major)
        comp2 = ver2(VRX_Major)
        If Len(comp1) = 0 Then comp1 = 0: Else comp1 = CLng(comp1)
        If Len(comp2) = 0 Then comp2 = 0: Else comp2 = CLng(comp2)
        SymanticCompare = comp1 < comp2
        If comp1 <> comp2 Then Exit Function
    End If

    ' Minor
    If UBound(ver1) >= VRX_Minor And UBound(ver2) >= VRX_Minor Then
        comp1 = ver1(VRX_Minor)
        comp2 = ver2(VRX_Minor)
        If Len(comp1) = 0 Then comp1 = 0: Else comp1 = CLng(comp1)
        If Len(comp2) = 0 Then comp2 = 0: Else comp2 = CLng(comp2)
        SymanticCompare = comp1 < comp2
        If comp1 <> comp2 Then Exit Function
    End If

    ' Patch
    If UBound(ver1) >= VRX_Patch And UBound(ver2) >= VRX_Patch Then
        comp1 = ver1(VRX_Patch)
        comp2 = ver2(VRX_Patch)
        If Len(comp1) = 0 Then comp1 = 0: Else comp1 = CLng(comp1)
        If Len(comp2) = 0 Then comp2 = 0: Else comp2 = CLng(comp2)
        SymanticCompare = comp1 < comp2
        If comp1 <> comp2 Then Exit Function
    End If

    ' Release
    If UBound(ver1) >= VRX_Release And UBound(ver2) >= VRX_Release Then
        comp1 = ver1(VRX_Release)
        comp2 = ver2(VRX_Release)
        If Len(comp1) = 0 And Len(comp2) Then
            SymanticCompare = False
            Exit Function
        ElseIf Len(comp1) And Len(comp2) = 0 Then
            SymanticCompare = True
            Exit Function
        Else
            SymanticCompare = comp1 < comp2
        End If
        If comp1 <> comp2 Then Exit Function
    End If

    ' Release Number
    If UBound(ver1) >= VRX_RelNumber And UBound(ver2) >= VRX_RelNumber Then
        comp1 = ver1(VRX_RelNumber)
        comp2 = ver2(VRX_RelNumber)
        If Len(comp1) = 0 Then comp1 = 0: Else comp1 = CLng(comp1)
        If Len(comp2) = 0 Then comp2 = 0: Else comp2 = CLng(comp2)
        SymanticCompare = comp1 < comp2
        If comp1 <> comp2 Then Exit Function
    End If

    ' x64
    If UBound(ver1) >= VRX_x64 And UBound(ver2) >= VRX_x64 Then
        comp1 = ver1(VRX_x64)
        comp2 = ver2(VRX_x64)
        SymanticCompare = comp1 < comp2
        If comp1 <> comp2 Then Exit Function
    End If

    ' webinstall
    If UBound(ver1) >= VRX_Web And UBound(ver2) >= VRX_Web Then
        comp1 = ver1(VRX_Web)
        comp2 = ver2(VRX_Web)
        SymanticCompare = comp1 < comp2
        If comp1 <> comp2 Then Exit Function
    End If

    ' ext
    If UBound(ver1) >= VRX_Ext And UBound(ver2) >= VRX_Ext Then
        comp1 = ver1(VRX_Ext)
        comp2 = ver2(VRX_Ext)
        SymanticCompare = comp1 < comp2
        If comp1 <> comp2 Then Exit Function
    End If
End Function

Sub SymanticQuickSort(arr, arrMin, arrMax)
    Dim middle
    Dim swap
    Dim arrFrst
    Dim arrLast
    Dim arrMid
    If arrMax <= arrMin Then Exit Sub

    arrFrst = arrMin
    arrLast = arrMax
    arrMid = (arrMin + arrMax) \ 2
    On Error Resume Next
    middle = arr(arrMid)
    If Err.Number <> 0 Then
        Err.Clear
        Exit Sub
    End If
    Do While (arrFrst <= arrLast)
        Do While True
            On Error Resume Next
            If SymanticCompare(arr(arrFrst)(SFV_Version), middle(SFV_Version)) Then
                If Err.Number <> 0 Then
                    Err.Clear
                    Exit Do
                End If
                arrFrst = arrFrst + 1
                If arrFrst = arrMax Then Exit Do
            Else
                Exit Do
            End If
            On Error GoTo 0
        Loop

        Do While True
            On Error Resume Next
            If SymanticCompare(middle(SFV_Version), arr(arrLast)(SFV_Version)) Then
                If Err.Number <> 0 Then
                    Err.Clear
                    Exit Do
                End If
                arrLast = arrLast - 1
                If arrLast = arrMin Then Exit Do
            Else
                Exit Do
            End If
            On Error GoTo 0
        Loop

        If (arrFrst <= arrLast) Then
            swap = arr(arrFrst)
            arr(arrFrst) = arr(arrLast)
            arr(arrLast) = swap
            arrFrst = arrFrst + 1
            arrLast = arrLast - 1
        End If
    Loop
    On Error GoTo 0

    If arrMin  < arrLast Then SymanticQuickSort arr, arrMin,  arrLast
    If arrFrst < arrMax  Then SymanticQuickSort arr, arrFrst, arrMax
End Sub

Sub main(arg)
    Dim optIgnore
    optIgnore = False

    If arg.Count >= 1 then
        If arg(0) = "--help" then
            ShowHelp
        ElseIf arg(0) = "--ignore" Then
            optIgnore = True
            WScript.Echo ":: [Info] :: Using --ignore flag to skip HTTP errors"
        End If
    End If

    WScript.Echo ":: [Info] :: Using mirror: " & mirror

    Dim objHTML
    Dim pageCount
    On Error Resume Next
    Set objHTML = CreateObject("MSXML2.DOMDocument")
    If Err.Number <> 0 Then
        Err.Clear
        Set objHTML = CreateObject("htmlfile")
    End If
    On Error GoTo 0
    pageCount = 0

    WScript.Echo ":: [Info] :: Fetching version list..."

    On Error Resume Next
    objweb.Open "GET", mirror, False
    ' Add User-Agent header for compatibility
    objweb.SetRequestHeader "User-Agent", "Mozilla/5.0 (compatible; pyenv-win)"
    objweb.SetRequestHeader "Accept", "*/*"
    If Err.number <> 0 Then
        WScript.Echo "HTTP Error (Open) from mirror """& mirror &""""& vbCrLf &"Error(0x"& Hex(Err.number) &"): "& Err.Description
        If optIgnore Then Exit Sub
        WScript.Quit 1
    End If

    objweb.Send
    If Err.number <> 0 Then
        WScript.Echo "HTTP Error (Send) from mirror """& mirror &""""& vbCrLf &"Error(0x"& Hex(Err.number) &"): "& Err.Description
        If optIgnore Then Exit Sub
        WScript.Quit 1
    End If
    On Error GoTo 0

    If objweb.Status <> 200 Then
        WScript.Echo "HTTP Error downloading from mirror """& mirror &""""& vbCrLf &"Error("& objweb.Status &"): "& objweb.StatusText
        If optIgnore Then Exit Sub
        WScript.Quit 1
    End If

    LoadHTMLIntoDoc objHTML, objweb.responseText
    pageCount = pageCount + 1

    ' Check if response is JSON format
    Dim responseText
    responseText = objweb.responseText
    Dim isJSON
    isJSON = False
    On Error Resume Next
    If Left(Trim(responseText), 1) = "[" Or Left(Trim(responseText), 1) = "{" Then
        isJSON = True
    End If
    On Error GoTo 0

    Dim version
    Dim matches
    Dim installers1
    Set installers1 = CreateObject("Scripting.Dictionary")
    Dim versionCount
    versionCount = 0

    If isJSON Then
        ' For JSON mirrors, parse version directories directly in main function
        WScript.Echo ":: [Info] :: Detected JSON format mirror, parsing..."

        ' Use regex to extract version directories from JSON
        Dim regex
        Dim versionPattern
        Set regex = New RegExp
        ' Build pattern using Chr(34) for double quotes
        versionPattern = Chr(34) & "name" & Chr(34) & ":\s*" & Chr(34)
        versionPattern = versionPattern & "((\d+)\.(\d+)(?:\.(\d+))?)/" & Chr(34)
        versionPattern = versionPattern & ".*?" & Chr(34) & "type" & Chr(34) & ":\s*" & Chr(34) & "dir" & Chr(34)
        regex.Pattern = versionPattern
        regex.Global = True
        regex.IgnoreCase = True

        Set matches = regex.Execute(responseText)

        versionCount = matches.Count
        WScript.Echo ":: [Info] :: Found " & versionCount & " versions"

        Dim i
        For i = 0 To matches.Count - 1
            ' Extract the full version number (submatch 0 contains the full version)
            Dim versionNum
            versionNum = matches(i).SubMatches(0)

            ' Remove trailing slash if present
            If Right(versionNum, 1) = "/" Then
                versionNum = Left(versionNum, Len(versionNum) - 1)
            End If

            ' Construct version URL
            Dim versionURL
            If Right(mirror, 1) = "/" Then
                versionURL = mirror & versionNum & "/"
            Else
                versionURL = mirror & "/" & versionNum & "/"
            End If

            WScript.Echo ":: [Info] :: Scanning version: " & versionNum

            ' Scan this version directory
            On Error Resume Next
            Dim versionResults
            Set versionResults = ScanForVersions(versionURL, optIgnore)

            If Err.Number <> 0 Then
                WScript.Echo ":: [Error] :: Failed to scan version " & versionNum & " - Error " & Err.Number & ": " & Err.Description
                WScript.Echo ":: [Error] :: Error Source: " & Err.Source
                WScript.Echo ":: [Error] :: Help File: " & Err.HelpFile
                WScript.Echo ":: [Error] :: Help Context: " & Err.HelpContext
                Err.Clear
            Else
                ' Merge results
                Dim key
                For Each key In versionResults.Keys
                    installers1.Add key, versionResults(key)
                Next
            End If
            On Error GoTo 0
        Next
    Else
        ' Parse links using regex for HTML mirrors
        Dim regexLinks
        Set regexLinks = ParseLinksFromHTML(responseText)

        WScript.Echo ":: [Info] :: Scanning version directories..."

        Dim linkKey
        For Each linkKey In regexLinks.Keys
            ' regexLinks stores arrays [href, text]
            Dim linkInfo
            linkInfo = regexLinks(linkKey)

            ' Extract version from href
            Dim href
            href = linkInfo(0)

            version = objfs.GetFileName(href)
            Set matches = regexVer.Execute(version)
            If matches.Count = 1 Then
                versionCount = versionCount + 1
                WScript.Echo ":: [Info] :: Scanning version: " & version

                ' Scan all versions
                On Error Resume Next
                ' Build full URL
                Dim fullURL
                If Right(mirror, 1) = "/" And Left(href, 1) = "/" Then
                    fullURL = Left(mirror, Len(mirror) - 1) & href
                ElseIf Right(mirror, 1) <> "/" And Left(href, 1) <> "/" Then
                    fullURL = mirror & "/" & href
                Else
                    fullURL = mirror & href
                End If
                pageCount = pageCount + 1
                UpdateDictionary installers1, ScanForVersions(fullURL, optIgnore)
                If Err.Number <> 0 Then
                    Err.Clear
                End If
            End If
        Next

    End If

    Dim versionCountMsg
    versionCountMsg = CStr(versionCount)
    WScript.Echo ":: [Info] :: Found " & installers1.Count & " installers from " & versionCountMsg & " versions"

    ' Remove duplicate versions and filter out zip files (only keep exe/msi installers)
    Dim minVers
    Dim fileName, fileNonWeb
    Dim versPieces
    Dim installers2
    Set installers2 = CopyDictionary(installers1)
    minVers = Array("2", "4", "", "", "", "", "", "")

    For Each fileName In installers1.Keys()
        On Error Resume Next
        versPieces = installers1(fileName)(SFV_Version)
        If Err.Number <> 0 Then
            Err.Clear
            installers2.Remove fileName
        Else
            ' Filter out all zip files - only keep exe and msi installers
            If IsArray(versPieces) And UBound(versPieces) >= VRX_Ext Then
                If LCase(versPieces(VRX_Ext)) = "zip" Then
                    installers2.Remove fileName
                End If
            End If

            If installers2.Exists(fileName) Then
                If SymanticCompare(versPieces, minVers) Then
                    installers2.Remove fileName
                ElseIf IsArray(versPieces) And UBound(versPieces) >= VRX_Web Then
                    If UBound(versPieces) >= VRX_Web And Len(versPieces(VRX_Web)) Then
                        If UBound(versPieces) >= VRX_Ext Then
                            On Error Resume Next
                            Dim arrMajor, arrMinor, arrPatch, arrRel, arrRelNum, arrEmbeddable, arrEmbed, arrTest, arrX64, arrARM, arrWin32, arrWeb, arrExt, arrZipRoot
                            If UBound(versPieces) >= VRX_Major Then arrMajor = versPieces(VRX_Major) Else arrMajor = ""
                            If UBound(versPieces) >= VRX_Minor Then arrMinor = versPieces(VRX_Minor) Else arrMinor = ""
                            If UBound(versPieces) >= VRX_Patch Then arrPatch = versPieces(VRX_Patch) Else arrPatch = ""
                            If UBound(versPieces) >= VRX_Release Then arrRel = versPieces(VRX_Release) Else arrRel = ""
                            If UBound(versPieces) >= VRX_RelNumber Then arrRelNum = versPieces(VRX_RelNumber) Else arrRelNum = ""
                            If UBound(versPieces) >= VRX_Embeddable Then arrEmbeddable = versPieces(VRX_Embeddable) Else arrEmbeddable = ""
                            If UBound(versPieces) >= VRX_Embed Then arrEmbed = versPieces(VRX_Embed) Else arrEmbed = ""
                            If UBound(versPieces) >= VRX_Test Then arrTest = versPieces(VRX_Test) Else arrTest = ""
                            If UBound(versPieces) >= VRX_x64 Then arrX64 = versPieces(VRX_x64) Else arrX64 = ""
                            If UBound(versPieces) >= VRX_ARM Then arrARM = versPieces(VRX_ARM) Else arrARM = ""
                            If UBound(versPieces) >= VRX_Win32 Then arrWin32 = versPieces(VRX_Win32) Else arrWin32 = ""
                            If UBound(versPieces) >= VRX_Web Then arrWeb = versPieces(VRX_Web) Else arrWeb = ""
                            If UBound(versPieces) >= VRX_Ext Then arrExt = versPieces(VRX_Ext) Else arrExt = ""
                            If UBound(versPieces) >= VRX_ZipRoot Then arrZipRoot = versPieces(VRX_ZipRoot) Else arrZipRoot = ""
                            fileNonWeb = "python-"& JoinInstallString(Array(arrMajor, arrMinor, arrPatch, arrRel, arrRelNum, arrEmbeddable, arrEmbed, arrTest, arrX64, arrARM, arrWin32, arrWeb, arrExt, arrZipRoot))
                            If Err.Number <> 0 Then
                                Err.Clear
                                fileNonWeb = ""
                            Else
                                On Error GoTo 0
                                If Len(fileNonWeb) > 0 And installers2.Exists(fileNonWeb) Then
                                    installers2.Remove fileName
                                End If
                            End If
                        End If
                    End If
                End If
            End If
        End If
        On Error GoTo 0
    Next

    WScript.Echo ":: [Info] :: Processing " & installers2.Count & " unique installers..."

    Dim installArr
    installArr = installers2.Items

    WScript.Echo ":: [Info] :: Sorting versions..."

    On Error Resume Next
    SymanticQuickSort installArr, LBound(installArr), UBound(installArr)
    If Err.Number <> 0 Then
        WScript.Echo ":: [Error] :: Sorting failed: "& Err.Description
        Err.Clear
    Else
        WScript.Echo ":: [Info] :: Saving to database..."
        Dim dbDir
        dbDir = objfs.getParentFolderName(strDBFile)
        If Not objfs.FolderExists(dbDir) Then
            objfs.CreateFolder(dbDir)
        End If
        SaveVersionsXML strDBFile, installArr
        If Err.Number <> 0 Then
            WScript.Echo ":: [Error] :: Failed to save database: "& Err.Description
            Err.Clear
        End If
    End If
    On Error GoTo 0

    WScript.Echo ":: [Info] :: Done! Scanned " & pageCount & " pages, found " & installers2.Count & " installers."
End Sub

On Error Resume Next
main(WScript.Arguments)
If Err.Number <> 0 Then
    WScript.Echo "Runtime Error ("& Err.Number &"): "& Err.Description
    WScript.Echo "Error Source: "& Err.Source
End If
