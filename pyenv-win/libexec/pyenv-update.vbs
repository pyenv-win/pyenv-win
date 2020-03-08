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

Import "pyenv-lib.vbs"
Import "pyenv-install-lib.vbs"

WScript.Echo ":: [Info] ::  Mirror: " & mirror

Dim regexVer
Dim regexFile
Const VRX_Major = 0
Const VRX_Minor = 1
Const VRX_Patch = 2
Const VRX_Release = 3
Const VRX_RelNumber = 4
Const VRX_x64 = 5
Const VRX_Web = 6
Const VRX_Ext = 7

Set regexVer = New RegExp
Set regexFile = New RegExp
With regexVer
    .Pattern = "^(\d+)(?:\.(\d+))?(?:\.(\d+))?(?:([a-z]+)(\d*))?$"
    .Global = True
    .IgnoreCase = True
End With
With regexFile
    .Pattern = "^python-(\d+)(?:\.(\d+))?(?:\.(\d+))?(?:([a-z]+)(\d*))?([\.-]amd64)?(-webinstall)?\.(exe|msi)$"
    .Global = True
    .IgnoreCase = True
End With

Sub ShowHelp()
    WScript.Echo "Usage: pyenv update [--ignore]"
    WScript.Echo
    WScript.Echo "  --ignore  Ignores any HTTP/VBScript errors that occur during downloads."
    WScript.Echo
    WScript.Echo "Updates the internal database of python installer URL's."
    WScript.Echo
    WScript.Quit
End Sub

Function JoinVerString(pieces)
    Dim strVer
    strVer = ""
    If Len(pieces(VRX_Major)) Then strVer = strVer & pieces(VRX_Major)
    If Len(pieces(VRX_Minor)) Then strVer = strVer &"."& pieces(VRX_Minor)
    If Len(pieces(VRX_Patch)) Then strVer = strVer &"."& pieces(VRX_Patch)
    If Len(pieces(VRX_Release)) Then strVer = strVer & pieces(VRX_Release)
    If Len(pieces(VRX_RelNumber)) Then strVer = strVer & pieces(VRX_RelNumber)
    JoinVerString = strVer
End Function

Function JoinInstallString(pieces)
    Dim strInstall
    strInstall = ""
    If Len(pieces(VRX_Major)) Then     strInstall = strInstall & pieces(VRX_Major)
    If Len(pieces(VRX_Minor)) Then     strInstall = strInstall &"."& pieces(VRX_Minor)
    If Len(pieces(VRX_Patch)) Then     strInstall = strInstall &"."& pieces(VRX_Patch)
    If Len(pieces(VRX_Release)) Then   strInstall = strInstall & pieces(VRX_Release)
    If Len(pieces(VRX_RelNumber)) Then strInstall = strInstall & pieces(VRX_RelNumber)
    If Len(pieces(VRX_x64)) Then       strInstall = strInstall & pieces(VRX_x64)
    If Len(pieces(VRX_Web)) Then       strInstall = strInstall & pieces(VRX_Web)
    If Len(pieces(VRX_Ext)) Then       strInstall = strInstall &"."& pieces(VRX_Ext)
    JoinInstallString = strInstall
End Function

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

Const SFV_FileName = 0
Const SFV_URL = 1
Const SFV_Version = 2
Function ScanForVersions(URL, optIgnore)
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
    comp1 = ver1(0)
    comp2 = ver2(0)
    If Len(comp1) = 0 Then comp1 = 0: Else comp1 = CLng(comp1)
    If Len(comp2) = 0 Then comp2 = 0: Else comp2 = CLng(comp2)
    SymanticCompare = comp1 < comp2
    If comp1 <> comp2 Then Exit Function

    ' Minor
    comp1 = ver1(1)
    comp2 = ver2(1)
    If Len(comp1) = 0 Then comp1 = 0: Else comp1 = CLng(comp1)
    If Len(comp2) = 0 Then comp2 = 0: Else comp2 = CLng(comp2)
    SymanticCompare = comp1 < comp2
    If comp1 <> comp2 Then Exit Function

    ' Patch
    comp1 = ver1(2)
    comp2 = ver2(2)
    If Len(comp1) = 0 Then comp1 = 0: Else comp1 = CLng(comp1)
    If Len(comp2) = 0 Then comp2 = 0: Else comp2 = CLng(comp2)
    SymanticCompare = comp1 < comp2
    If comp1 <> comp2 Then Exit Function

    ' Release
    comp1 = ver1(3)
    comp2 = ver2(3)
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
    comp1 = ver1(4)
    comp2 = ver2(4)
    If Len(comp1) = 0 Then comp1 = 0: Else comp1 = CLng(comp1)
    If Len(comp2) = 0 Then comp2 = 0: Else comp2 = CLng(comp2)
    SymanticCompare = comp1 < comp2
    If comp1 <> comp2 Then Exit Function

    ' x64
    comp1 = ver1(5)
    comp2 = ver2(5)
    SymanticCompare = comp1 < comp2
    If comp1 <> comp2 Then Exit Function

    ' webinstall
    comp1 = ver1(6)
    comp2 = ver2(6)
    SymanticCompare = comp1 < comp2
    If comp1 <> comp2 Then Exit Function

    ' ext
    comp1 = ver1(7)
    comp2 = ver2(7)
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
    Set objHTML = CreateObject("htmlfile")    

    With objweb
        .open "GET", mirror, False
        On Error Resume Next
        .send
        If Err.number <> 0 Then
            WScript.Echo "HTTP Error downloading from mirror """& mirror &""""& vbCrLf &"Error(0x"& Hex(Err.number) &"): "& Err.Description
            If optIgnore Then Exit Sub
            WScript.Quit 1
        End If
        On Error GoTo 0
        If .status <> 200 Then
            WScript.Echo "HTTP Error downloading from mirror """& mirror &""""& vbCrLf &"Error("& .status &"): "& .statusText
            If optIgnore Then Exit Sub
            WScript.Quit 1
        End If

        objHTML.write .responseText 
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
            UpdateDictionary installers1, ScanForVersions(link.href, optIgnore)
    Next

    ' Now remove any duplicate versions that have the web installer (it's prefered)
    Dim fileName, fileNonWeb
    Dim filePieces
    Dim installers2
    Set installers2 = CopyDictionary(installers1) ' Use a copy because "For Each" and .Remove don't play nice together.
    For Each fileName In installers1.Keys()
        ' Array([url], Array([major], [minor], [path], [rel], [rel_num], [x64], [webinstall], [ext]))
        filePieces = installers1(fileName)(2)
        If Len(filePieces(6)) Then
            fileNonWeb = "python-"& JoinInstallString(Array(_
                filePieces(0),_
                filePieces(1),_
                filePieces(2),_
                filePieces(3),_
                filePieces(4),_
                filePieces(5),_
                Empty,_
                filePieces(7)_
            ))
            If installers2.Exists(fileNonWeb) Then _
                installers2.Remove fileNonWeb
        End If
    Next

    ' Now sort by semantic version
    Dim installArr
    installArr = installers2.Items
    SymanticQuickSort installArr, LBound(installArr), UBound(installArr)
    For Each version In installArr
        WScript.Echo version(0)
    Next

End Sub

main(WScript.Arguments)
