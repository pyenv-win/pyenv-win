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
    Set objHTML = CreateObject("htmlfile")
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

        objHTML.write .responseText
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
    Set objHTML = CreateObject("htmlfile")
    pageCount = 0

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

        objHTML.write .responseText
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

    ' Now remove any duplicate versions that have the web installer (it's prefered)
    Dim minVers
    Dim fileName, fileNonWeb
    Dim versPieces
    Dim installers2
    Set installers2 = CopyDictionary(installers1) ' Use a copy because "For Each" and .Remove don't play nice together.
    minVers = Array("2", "4", "", "", "", "", "", "")
    For Each fileName In installers1.Keys()
        ' Array([filename], [url], Array([major], [minor], [path], [rel], [rel_num], [x64], [webinstall], [ext]))
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
