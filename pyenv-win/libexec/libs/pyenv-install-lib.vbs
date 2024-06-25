Option Explicit

' Make sure to Import "pyenv-lib.vbs" before this file in a command. (for objfs/objweb variables)
' WScript.echo "kkotari: pyenv-install-lib.vbs..!"

Dim mirrors()
ReDim mirrors(0)
mirrors(0) = objws.Environment("Process")("PYTHON_BUILD_MIRROR_URL")
If mirrors(0) = "" Then
    ReDim Preserve mirrors(2)
    mirrors(0) = "https://www.python.org/ftp/python"
    mirrors(1) = "https://downloads.python.org/pypy/versions.json"
    mirrors(2) = "https://api.github.com/repos/oracle/graalpython/releases"
End If

Const SFV_FileName = 0
Const SFV_URL = 1
Const SFV_Version = 2

Const VRX_Major = 0
Const VRX_Minor = 1
Const VRX_Patch = 2
Const VRX_Release = 3
Const VRX_RelNumber = 4
Const VRX_x64 = 5
Const VRX_ARM = 6
Const VRX_Web = 7
Const VRX_Ext = 8
Const VRX_Arch = 5
Const VRX_ZipRoot = 9

' Version definition array from LoadVersionsXML.
Const LV_Code = 0
Const LV_FileName = 1
Const LV_URL = 2
Const LV_x64 = 3
Const LV_Web = 4
Const LV_MSI = 5
Const LV_ZipRootDir = 6
' Const LV_ARM = 7 # need to validate what number is this

' Installation parameters used for clear/extract, extension of LV.
Const IP_InstallPath = 7
Const IP_InstallFile = 8
Const IP_Quiet = 9
Const IP_Dev = 10

Dim regexVer
Dim regexVerArch
Dim regexFile
Dim regexJsonUrl
Set regexVer = New RegExp
Set regexVerArch = New RegExp
Set regexFile = New RegExp
Set regexJsonUrl = New RegExp
With regexVer
    .Pattern = "^(\d+)(?:\.(\d+))?(?:\.(\d+))?(?:([a-z]+)(\d*))?$"
    .Global = True
    .IgnoreCase = True
End With
With regexVerArch
    .Pattern = "^(\d+)(?:\.(\d+))?(?:\.(\d+))?(?:([a-z]+)(\d*))?([\.-](?:amd64|arm64|win32))?$"
    .Global = True
    .IgnoreCase = True
End With
With regexFile
    .Pattern = "^python-(\d+)(?:\.(\d+))?(?:\.(\d+))?(?:([a-z]+)(\d*))?([\.-]amd64)?([\.-]arm64)?(-webinstall)?\.(exe|msi)$"
    .Global = True
    .IgnoreCase = True
End With
With regexJsonUrl
    ' example for graalpy: graalpy-24.0.1-windows-amd64.zip
    ' example for pypy: pypy3.7-v7.3.4-win64.zip
    .Pattern = "download_url"": ?""(https://[^\s""]+/(((?:pypy\d+\.\d+-v|graalpy-)(\d+)(?:\.(\d+))?(?:\.(\d+))?-(win64|windows-amd64)?(windows-aarch64)?).zip))"""
    .Global = True
    .IgnoreCase = True
End With

' Adding -win32 as a post fix for x86 Arch
Function JoinWin32String(pieces)
    ' WScript.echo "kkotari: pyenv-install-lib.vbs JoinWin32String..!"
    JoinWin32String = ""
    If Len(pieces(VRX_Major))     Then JoinWin32String = JoinWin32String & pieces(VRX_Major)
    If Len(pieces(VRX_Minor))     Then JoinWin32String = JoinWin32String &"."& pieces(VRX_Minor)
    If Len(pieces(VRX_Patch))     Then JoinWin32String = JoinWin32String &"."& pieces(VRX_Patch)
    If Len(pieces(VRX_Release))   Then JoinWin32String = JoinWin32String & pieces(VRX_Release)
    If Len(pieces(VRX_RelNumber)) Then JoinWin32String = JoinWin32String & pieces(VRX_RelNumber)
    If Len(pieces(VRX_ARM)) Then
        JoinWin32String = JoinWin32String & "-arm"
    ElseIf Len(pieces(VRX_x64)) = 0 Then
        JoinWin32String = JoinWin32String & "-win32"
    End If
End Function

' For x64 Arch
Function JoinInstallString(pieces)
    ' WScript.echo "kkotari: pyenv-install-lib.vbs JoinInstallString..!"
    JoinInstallString = ""
    If Len(pieces(VRX_Major))     Then JoinInstallString = JoinInstallString & pieces(VRX_Major)
    If Len(pieces(VRX_Minor))     Then JoinInstallString = JoinInstallString &"."& pieces(VRX_Minor)
    If Len(pieces(VRX_Patch))     Then JoinInstallString = JoinInstallString &"."& pieces(VRX_Patch)
    If Len(pieces(VRX_Release))   Then JoinInstallString = JoinInstallString & pieces(VRX_Release)
    If Len(pieces(VRX_RelNumber)) Then JoinInstallString = JoinInstallString & pieces(VRX_RelNumber)
    If Len(pieces(VRX_x64))       Then JoinInstallString = JoinInstallString & pieces(VRX_x64)
    If Len(pieces(VRX_ARM))       Then JoinInstallString = JoinInstallString & pieces(VRX_ARM)
    If Len(pieces(VRX_Web))       Then JoinInstallString = JoinInstallString & pieces(VRX_Web)
    If Len(pieces(VRX_Ext))       Then JoinInstallString = JoinInstallString &"."& pieces(VRX_Ext)
End Function

' Download exe file
Function DownloadFile(strUrl, strFile)
    ' WScript.echo "kkotari: pyenv-install-lib.vbs DownloadFile..!"
    On Error Resume Next

    objweb.Open "GET", strUrl, False
    If Err.Number <> 0 Then
        WScript.Echo ":: [ERROR] :: "& Err.Description
        WScript.Quit 1
    End If

    objweb.Send
    If Err.Number <> 0 Then
        WScript.Echo ":: [ERROR] :: "& Err.Description
        WScript.Quit 1
    End If
    On Error GoTo 0

    If objweb.Status <> 200 Then
        WScript.Echo ":: [ERROR] :: "& objweb.Status &" :: "& objweb.StatusText
        WScript.Quit 1
    End If

    With CreateObject("ADODB.Stream")
        .Open
        .Type = 1
        .Write objweb.responseBody
        .SaveToFile strFile, 2
        .Close
    End With
End Function

Sub clear(params)
    ' WScript.echo "kkotari: pyenv-install-lib.vbs clear..!"
    If objfs.FolderExists(params(IP_InstallPath)) Then _
        objfs.DeleteFolder params(IP_InstallPath), True

    If objfs.FileExists(params(IP_InstallFile)) Then _
        objfs.DeleteFile params(IP_InstallFile), True
End Sub

' pyenv python versions DB scheme
Dim strDBSchema
' WScript.echo "kkotari: pyenv-install-lib.vbs DBSchema..!"
strDBSchema = _
"<xs:schema xmlns:xs=""http://www.w3.org/2001/XMLSchema"">"& _
  "<xs:element name=""versions"">"& _
    "<xs:complexType>"& _
      "<xs:sequence>"& _
        "<xs:element name=""version"" maxOccurs=""unbounded"" minOccurs=""0"">"& _
          "<xs:complexType>"& _
            "<xs:sequence>"& _
              "<xs:element name=""code"" type=""xs:string""/>"& _
              "<xs:element name=""file"" type=""xs:string""/>"& _
              "<xs:element name=""URL"" type=""xs:anyURI""/>"& _
              "<xs:element name=""zipRootDir"" type=""xs:string"" minOccurs=""0"" maxOccurs=""1""/>"& _
            "</xs:sequence>"& _
            "<xs:attribute name=""x64"" type=""xs:boolean"" default=""false""/>"& _
            "<xs:attribute name=""webInstall"" type=""xs:boolean"" default=""false""/>"& _
            "<xs:attribute name=""msi"" type=""xs:boolean"" default=""true""/>"& _
          "</xs:complexType>"& _
        "</xs:element>"& _
      "</xs:sequence>"& _
    "</xs:complexType>"& _
  "</xs:element>"& _
"</xs:schema>"

' Load versions xml to pyenv
Function LoadVersionsXML(xmlPath)
    ' WScript.echo "kkotari: pyenv-install-lib.vbs LoadVersionsXML..!"
    Dim dbSchema
    Dim doc
    Dim schemaError
    Set LoadVersionsXML = CreateObject("Scripting.Dictionary")
    Set dbSchema = CreateObject("Msxml2.DOMDocument.6.0")
    Set doc = CreateObject("Msxml2.DOMDocument.6.0")

    If Not objfs.FileExists(xmlPath) Then Exit Function

    With dbSchema
        .validateOnParse = False
        .resolveExternals = False
        .loadXML strDBSchema
    End With

    With doc
        Set .schemas = CreateObject("Msxml2.XMLSchemaCache.6.0")
        .schemas.add "", dbSchema
        .validateOnParse = False
        .load xmlPath
        Set schemaError = .validate
    End With

    With schemaError
        If .errorCode <> 0 Then
            WScript.Echo "Validation error in DB cache(0x"& Hex(.errorCode) & _
            ") on line "& .line &", pos "& .linepos &":"& vbCrLf & .reason
            WScript.Quit 1
        End If
    End With

    Dim versDict
    Dim version
    Dim code
    Dim zipRootDirElement, zipRootDir
    For Each version In doc.documentElement.childNodes
        code = version.getElementsByTagName("code")(0).text
        Set zipRootDirElement = version.getElementsByTagName("zipRootDir")
        If zipRootDirElement.length = 1 Then
            zipRootDir = zipRootDirElement(0).text
        Else
            zipRootDir = ""
        End If
        LoadVersionsXML.Item(code) = Array( _
            code, _
            version.getElementsByTagName("file")(0).text, _
            version.getElementsByTagName("URL")(0).text, _
            CBool(version.getAttribute("x64")), _
            CBool(version.getAttribute("webInstall")), _
            CBool(version.getAttribute("msi")), _
            zipRootDir _
        )
    Next
End Function

' Append xml element
Sub AppendElement(doc, parent, tag, text)
    ' WScript.echo "kkotari: pyenv-install-lib.vbs AppendElement..!"
    Dim elem
    Set elem = doc.createElement(tag)
    elem.text = text
    parent.appendChild elem
End Sub

Function LocaleIndependantCStr(booleanVal)
    If booleanVal Then
        LocaleIndependantCStr = "true"
    Else
        LocaleIndependantCStr = "false"
    End If
End Function

' Append new version to DB
Sub SaveVersionsXML(xmlPath, versArray)
    ' WScript.echo "kkotari: pyenv-install-lib.vbs SaveVersionsXML..!"
    Dim doc
    Set doc = CreateObject("Msxml2.DOMDocument.6.0")
    Set doc.documentElement = doc.createElement("versions")

    Dim versRow
    Dim versElem
    For Each versRow In versArray
        Set versElem = doc.createElement("version")
        doc.documentElement.appendChild versElem

        With versElem
            .setAttribute "x64",        LocaleIndependantCStr(CBool(Len(versRow(SFV_Version)(VRX_x64)) OR Len(versRow(SFV_Version)(VRX_ARM))))
            .setAttribute "webInstall", LocaleIndependantCStr(CBool(Len(versRow(SFV_Version)(VRX_Web))))
            .setAttribute "msi",        LocaleIndependantCStr(LCase(versRow(SFV_Version)(VRX_Ext)) = "msi")
        End With
        If versRow(SFV_Version)(VRX_Ext) = "zip" Then
            AppendElement doc, versElem, "code", versRow(SFV_Version)(VRX_ZipRoot)
        Else
            AppendElement doc, versElem, "code", JoinWin32String(versRow(SFV_Version))
        End If
        AppendElement doc, versElem, "file", versRow(0)
        AppendElement doc, versElem, "URL", versRow(1)
        If versRow(SFV_Version)(VRX_Ext) = "zip" Then
            AppendElement doc, versElem, "zipRootDir", versRow(SFV_Version)(VRX_ZipRoot)
        End If
    Next

    ' Use SAXXMLReader/MXXMLWriter to "pretty print" the XML data.
    Dim writer
    Dim parser
    Dim outXML
    Set writer = CreateObject("Msxml2.MXXMLWriter.6.0")
    Set parser = CreateObject("Msxml2.SAXXMLReader.6.0")
    Set outXML = CreateObject("ADODB.Stream")

    With outXML
        .Open
        .Type = 1
    End With
    With writer
        .encoding = "utf-8"
        .indent = True
        .output = outXML
    End With
    With parser
        Set .contentHandler = writer
        Set .dtdHandler = writer
        Set .errorHandler = writer
        .putProperty "http://xml.org/sax/properties/declaration-handler", writer
        .putProperty "http://xml.org/sax/properties/lexical-handler", writer
        .parse doc
    End With
    With outXML
        .SaveToFile xmlpath, 2
        .Close
    End With
End Sub

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

    ' ARM
    comp1 = ver1(VRX_ARM)
    comp2 = ver2(VRX_ARM)
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

Function JoinVersionString(pieces)
    ' WScript.echo "kkotari: pyenv-install-lib.vbs JoinVersionString..!"
    JoinVersionString = ""
    If Len(pieces(VRX_Major))     Then JoinVersionString = JoinVersionString & pieces(VRX_Major)
    If Len(pieces(VRX_Minor))     Then JoinVersionString = JoinVersionString &"."& pieces(VRX_Minor)
    If Len(pieces(VRX_Patch))     Then JoinVersionString = JoinVersionString &"."& pieces(VRX_Patch)
    If Len(pieces(VRX_Release))   Then JoinVersionString = JoinVersionString & pieces(VRX_Release)
    If Len(pieces(VRX_RelNumber)) Then JoinVersionString = JoinVersionString & pieces(VRX_RelNumber)
    If Len(pieces(VRX_Arch))      Then JoinVersionString = JoinVersionString & pieces(VRX_Arch)
End Function

' Resolves latest python version by given prefix
' known=False to find latest _installed_ version
' See `pyenv latest --help`
Function FindLatestVersion(prefix, known)
    Dim candidates

    if known Then
        Dim cachedVersions
        Set cachedVersions = LoadVersionsXML(strDBFile)

        Dim cachedVersion

        Dim convertor()
        ReDim Preserve convertor(-1)

        For Each cachedVersion In cachedVersions.Keys
            ReDim Preserve convertor(UBound(convertor) + 1)
            convertor(UBound(convertor)) = cachedVersion
        Next

        candidates = convertor
    else
        candidates = GetInstalledVersions()
    end if

    Dim x
    Dim matches

    Dim bestMatch
    Dim arch

    arch = GetArchPostfix()

    For x = 0 To UBound(candidates) Step 1
        ' startswith
        If Left(candidates(x), Len(prefix)) = prefix Then
            ' Full match OR prefix plus '.'
            If candidates(x) = prefix & arch Or Mid(candidates(x), Len(prefix) + 1, 1) = "." Then
                Set matches = regexVerArch.Execute(candidates(x))

                if matches.Count = 1 Then
                    ' Skip dev builds, releases and so on
                    ' Comparing each version by <major>.<minor>.<patch>
                    If matches(0).SubMatches(VRX_Release) = "" And matches(0).SubMatches(VRX_Arch) = arch Then
                        If IsEmpty(bestMatch) Then
                            Set bestMatch = matches(0).SubMatches
                        Else
                            If SymanticCompare(bestMatch, matches(0).SubMatches) Then
                                Set bestMatch = matches(0).SubMatches
                            End If
                        End If
                    End If
                End If
            End If
        End If
    Next

    if IsEmpty(bestMatch) Then
        FindLatestVersion = ""
    else
        FindLatestVersion = JoinVersionString(bestMatch)
    end if
End Function

Function TryResolveVersion(prefix, known)
    Dim resolved

    resolved = FindLatestVersion(prefix, known)

    If resolved = "" Then resolved = prefix

    TryResolveVersion = resolved
End Function
