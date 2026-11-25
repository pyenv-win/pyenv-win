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

'— setup a regex to pull HREF+link-text out of raw HTML — 
Dim regexLink  
Set regexLink = New RegExp  
With regexLink  
    .Pattern     = "<a\s+[^>]*?href\s*=\s*[""']([^""']+)[""'][^>]*?>([^<>]+)</a>"  
    .Global      = True  
    .IgnoreCase  = True  
End With

WScript.Echo ":: [Info] ::  Mirror: " & mirror

Sub ShowHelp()
    WScript.Echo "Usage: pyenv update [--ignore]"
    WScript.Echo
    WScript.Echo "  --ignore  Ignores any HTTP/VBScript errors that occur during downloads."
    WScript.Echo
    WScript.Echo "Updates the internal database of python installer URL's."
    WScript.Echo
    WScript.Quit
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
    Dim htmlText, linkMatches, m, href, fileName
    
    ' fetch the page
    With objweb
        .Open "GET", URL, False
        .Send
        If Err.Number <> 0 Then
            WScript.Echo "HTTP Error downloading " & URL & ": " & Err.Description
            If optIgnore Then Exit Function Else WScript.Quit 1
        End If
        If .Status <> 200 Then
            WScript.Echo "HTTP Error (" & .Status & ") downloading " & URL & ": " & .StatusText
            If optIgnore Then Exit Function Else WScript.Quit 1
        End If
        htmlText = .responseText
        pageCount = pageCount + 1
    End With

    Set ScanForVersions = CreateObject("Scripting.Dictionary")
    ' run our anchor regex
    Set linkMatches = regexLink.Execute(htmlText)
    For Each m In linkMatches
        href     = m.SubMatches(0)
        fileName = Trim(m.SubMatches(1))
        
        ' resolve relative URLs
        If LCase(Left(href,4)) <> "http" Then
            href = Left(URL, InStrRev(URL,"/")) & href
        End If
        
        ' only keep the ones matching your version‐regex
        Dim matches
        Set matches = regexFile.Execute(fileName)
        If matches.Count = 1 Then
            ScanForVersions.Add fileName, _
                Array(fileName, href, CollectionToArray(matches(0).SubMatches))
        End If
    Next
End Function


' Test if ver1 < ver2
Function SymanticCompare(ver1, ver2)
    Dim comp1, comp2

    ' Major
    comp1 = ver1(VRX_Major)
    comp2 = ver2(VRX_Major)
    If Len(comp1) = 0 Then comp1 = 0: Else comp1 = CLng(comp1)
    If Len(comp2) = 0 Then comp2 = 0: Else comp2 = CLng(comp2)
    SymanticCompare = comp1 < comp2
    If comp1 <> comp2 Then Exit Function

    ' Minor
    comp1 = ver1(VRX_Minor)
    comp2 = ver2(VRX_Minor)
    If Len(comp1) = 0 Then comp1 = 0: Else comp1 = CLng(comp1)
    If Len(comp2) = 0 Then comp2 = 0: Else comp2 = CLng(comp2)
    SymanticCompare = comp1 < comp2
    If comp1 <> comp2 Then Exit Function

    ' Patch
    comp1 = ver1(VRX_Patch)
    comp2 = ver2(VRX_Patch)
    If Len(comp1) = 0 Then comp1 = 0: Else comp1 = CLng(comp1)
    If Len(comp2) = 0 Then comp2 = 0: Else comp2 = CLng(comp2)
    SymanticCompare = comp1 < comp2
    If comp1 <> comp2 Then Exit Function

    ' Release
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

    ' Release Number
    comp1 = ver1(VRX_RelNumber)
    comp2 = ver2(VRX_RelNumber)
    If Len(comp1) = 0 Then comp1 = 0: Else comp1 = CLng(comp1)
    If Len(comp2) = 0 Then comp2 = 0: Else comp2 = CLng(comp2)
    SymanticCompare = comp1 < comp2
    If comp1 <> comp2 Then Exit Function

    ' x64
    comp1 = ver1(VRX_x64)
    comp2 = ver2(VRX_x64)
    SymanticCompare = comp1 < comp2
    If comp1 <> comp2 Then Exit Function

    ' webinstall
    comp1 = ver1(VRX_Web)
    comp2 = ver2(VRX_Web)
    SymanticCompare = comp1 < comp2
    If comp1 <> comp2 Then Exit Function

    ' ext
    comp1 = ver1(VRX_Ext)
    comp2 = ver2(VRX_Ext)
    SymanticCompare = comp1 < comp2
    If comp1 <> comp2 Then Exit Function
End Function

' Modified from code by "Reverend Jim" at:
' https://www.daniweb.com/programming/code/515601/vbscript-implementation-of-quicksort
Sub SymanticQuickSort(arr, arrMin, arrMax)
    Dim middle  ' value of the element in the middle of the range
    Dim swap    ' temporary item for the swapping of two elements
    Dim arrFrst ' index of the first element in the range to check
    Dim arrLast ' index of the last element in the range to check
    Dim arrMid  ' index of the element in the middle of the range
    If arrMax <= arrMin Then Exit Sub

    ' Start the checks at the lower and upper limits of the Array
    arrFrst = arrMin
    arrLast = arrMax

    ' Find the midpoint of the region to sort and the value of that element
    arrMid = (arrMin + arrMax) \ 2
    middle = arr(arrMid)
    Do While (arrFrst <= arrLast)
        ' Find the first element > the element at the midpoint
        Do While SymanticCompare(arr(arrFrst)(SFV_Version), middle(SFV_Version))
            arrFrst = arrFrst + 1
            If arrFrst = arrMax Then Exit Do
        Loop

        ' Find the last element < the element at the midpoint
        Do While SymanticCompare(middle(SFV_Version), arr(arrLast)(SFV_Version))
            arrLast = arrLast - 1
            If arrLast = arrMin Then Exit Do
        Loop

        ' Pivot the two elements around the midpoint if they are out of order
        If (arrFrst <= arrLast) Then
            swap = arr(arrFrst)
            arr(arrFrst) = arr(arrLast)
            arr(arrLast) = swap
            arrFrst = arrFrst + 1
            arrLast = arrLast - 1
        End If
    Loop

    ' Sort sub-regions (recurse) if necessary
    If arrMin  < arrLast Then SymanticQuickSort arr, arrMin,  arrLast
    If arrFrst < arrMax  Then SymanticQuickSort arr, arrFrst, arrMax
End Sub

Sub main(arg)
    Dim optIgnore, pageCount
    Dim htmlText, linkMatches, m, href, fileName, versionName, matches
    Dim installers1

    '— parse command-line flags —
    optIgnore = False
    If arg.Count >= 1 Then
        If arg(0) = "--help" Then ShowHelp
        If arg(0) = "--ignore" Then optIgnore = True
    End If

    '— fetch the mirror index page —
    With objweb
        .Open "GET", mirror, False
        .Send
        If Err.Number <> 0 Then
            WScript.Echo "HTTP Error downloading mirror: " & Err.Description
            If optIgnore Then Exit Sub Else WScript.Quit 1
        End If
        If .Status <> 200 Then
            WScript.Echo "HTTP Error (" & .Status & ") at mirror: " & .StatusText
            If optIgnore Then Exit Sub Else WScript.Quit 1
        End If
        htmlText = .responseText
    End With

    pageCount = 1
    Set installers1 = CreateObject("Scripting.Dictionary")

    '— extract every <a href=…>link-text</a> —
    Set linkMatches = regexLink.Execute(htmlText)
    For Each m In linkMatches
        href     = m.SubMatches(0)
        fileName = Trim(m.SubMatches(1))
        
        ' skip the parent-directory link
        If fileName <> "../" And fileName <> ".." Then

            ' strip trailing slash for version matching
            versionName = fileName
            If Right(versionName,1) = "/" Then
                versionName = Left(versionName, Len(versionName) - 1)
            End If

            ' if that name matches your version‐regex, recurse into it
            Set matches = regexVer.Execute(versionName)
            If matches.Count = 1 Then
                Dim maj, min
                maj = CLng(matches(0).SubMatches(0))
                min = CLng(matches(0).SubMatches(1))
                ' only process Python ≥ 2.4:
                If maj > 2 Or (maj = 2 And min >= 4) Then
                    ' rebuild href correctly:
                    If LCase(Left(href,4)) <> "http" Then
                        href = mirror & "/" & fileName
                    End If
                    UpdateDictionary installers1, ScanForVersions(href, optIgnore, pageCount)
                End If
            End If


        End If
    Next

    '— now dedupe (<2.4) and non-web vs web installers as before —
    Dim minVers, fileNonWeb, versPieces, installers2, installArr
    Set installers2 = CopyDictionary(installers1)
    minVers = Array("2","4","","","","","","")
    For Each fileName In installers1.Keys
        versPieces = installers1(fileName)(SFV_Version)
        If SymanticCompare(versPieces, minVers) Then
            installers2.Remove fileName
        ElseIf Len(versPieces(VRX_Web)) Then
            fileNonWeb = "python-" & JoinInstallString(Array( _
                versPieces(VRX_Major), _
                versPieces(VRX_Minor), _
                versPieces(VRX_Patch), _
                versPieces(VRX_Release), _
                versPieces(VRX_RelNumber), _
                versPieces(VRX_x64), _
                Empty, _
                versPieces(VRX_Ext) _
            ))
            If installers2.Exists(fileNonWeb) Then installers2.Remove fileNonWeb
        End If
    Next

    '— sort and write out the XML database —
    installArr = installers2.Items
    SymanticQuickSort installArr, LBound(installArr), UBound(installArr)
    SaveVersionsXML strDBFile, installArr

    WScript.Echo ":: [Info] :: Scanned " & pageCount & " pages and found " & installers2.Count & " installers."

End Sub

main(WScript.Arguments)