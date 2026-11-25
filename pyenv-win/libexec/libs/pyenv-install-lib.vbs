Option Explicit

' Make sure to Import "pyenv-lib.vbs" before this file in a command. (for objfs/objweb variables)
' WScript.echo "kkotari: pyenv-install-lib.vbs..!"

Dim mirrors()
ReDim mirrors(2)
On Error Resume Next
Dim mirrorUrl
mirrorUrl = objws.Environment("Process")("PYTHON_BUILD_MIRROR_URL")
If Err.Number <> 0 Or mirrorUrl = "" Then
    Err.Clear
    mirrors(0) = "https://www.python.org/ftp/python"
    mirrors(1) = "https://downloads.python.org/pypy/versions.json"
    mirrors(2) = "https://api.github.com/repos/oracle/graalpython/releases"
Else
    ReDim mirrors(0)
    mirrors(0) = mirrorUrl
End If
On Error GoTo 0

Dim mirror
mirror = mirrors(0)

Const SFV_FileName = 0
Const SFV_URL = 1
Const SFV_Version = 2

Const VRX_Major = 0
Const VRX_Minor = 1
Const VRX_Patch = 2
Const VRX_Release = 3
Const VRX_RelNumber = 4
Const VRX_Embeddable = 5
Const VRX_Embed = 6
Const VRX_Test = 7
Const VRX_x64 = 8
Const VRX_ARM = 9
Const VRX_Win32 = 10
Const VRX_Web = 11
Const VRX_Ext = 12
Const VRX_Arch = 8
Const VRX_ZipRoot = 13

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
    .Pattern = "^(\d+)\.(\d+)(?:\.(\d+))?([a-z]+(\d*))?$"
    .Global = True
    .IgnoreCase = True
End With
With regexVerArch
    .Pattern = "^(\d+)\.(\d+)(?:\.(\d+))?([a-z]+(\d*))?([\.-](?:amd64|arm64|win32))?$"
    .Global = True
    .IgnoreCase = True
End With
With regexFile
    .Pattern = "^python-(\d+)(?:\.(\d+))?(?:\.(\d+))?(?:([a-z]+)(\d*))?(?:(-embeddable)|(-embed)|(-test))?([\.-]amd64)?([\.-]arm64)?([\.-]win32)?(-webinstall)?\.(exe|msi|zip)$"
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
    JoinWin32String = ""
    If Not IsArray(pieces) Or UBound(pieces) < 0 Then Exit Function
    On Error Resume Next
    If UBound(pieces) >= VRX_Major And Len(pieces(VRX_Major)) Then JoinWin32String = JoinWin32String & pieces(VRX_Major)
    If UBound(pieces) >= VRX_Minor And Len(pieces(VRX_Minor)) Then JoinWin32String = JoinWin32String &"."& pieces(VRX_Minor)
    If UBound(pieces) >= VRX_Patch And Len(pieces(VRX_Patch)) Then JoinWin32String = JoinWin32String &"."& pieces(VRX_Patch)
    If UBound(pieces) >= VRX_Release And Len(pieces(VRX_Release)) Then JoinWin32String = JoinWin32String & pieces(VRX_Release)
    If UBound(pieces) >= VRX_RelNumber And Len(pieces(VRX_RelNumber)) Then JoinWin32String = JoinWin32String & pieces(VRX_RelNumber)
    If UBound(pieces) >= VRX_ARM And Len(pieces(VRX_ARM)) Then
        JoinWin32String = JoinWin32String & "-arm"
    ElseIf UBound(pieces) >= VRX_x64 And Len(pieces(VRX_x64)) = 0 Then
        JoinWin32String = JoinWin32String & "-win32"
    End If
    If Err.Number <> 0 Then Err.Clear
    On Error GoTo 0
End Function

' For x64 Arch
Function JoinInstallString(pieces)
    JoinInstallString = ""
    If Not IsArray(pieces) Or UBound(pieces) < 0 Then Exit Function
    On Error Resume Next
    If UBound(pieces) >= VRX_Major And Len(pieces(VRX_Major)) Then JoinInstallString = JoinInstallString & pieces(VRX_Major)
    If UBound(pieces) >= VRX_Minor And Len(pieces(VRX_Minor)) Then JoinInstallString = JoinInstallString &"."& pieces(VRX_Minor)
    If UBound(pieces) >= VRX_Patch And Len(pieces(VRX_Patch)) Then JoinInstallString = JoinInstallString &"."& pieces(VRX_Patch)
    If UBound(pieces) >= VRX_Release And Len(pieces(VRX_Release)) Then JoinInstallString = JoinInstallString & pieces(VRX_Release)
    If UBound(pieces) >= VRX_RelNumber And Len(pieces(VRX_RelNumber)) Then JoinInstallString = JoinInstallString & pieces(VRX_RelNumber)
    If UBound(pieces) >= VRX_Embeddable And Len(pieces(VRX_Embeddable)) Then JoinInstallString = JoinInstallString & pieces(VRX_Embeddable)
    If UBound(pieces) >= VRX_Embed And Len(pieces(VRX_Embed)) Then JoinInstallString = JoinInstallString & pieces(VRX_Embed)
    If UBound(pieces) >= VRX_Test And Len(pieces(VRX_Test)) Then JoinInstallString = JoinInstallString & pieces(VRX_Test)
    If UBound(pieces) >= VRX_x64 And Len(pieces(VRX_x64)) Then JoinInstallString = JoinInstallString & pieces(VRX_x64)
    If UBound(pieces) >= VRX_ARM And Len(pieces(VRX_ARM)) Then JoinInstallString = JoinInstallString & pieces(VRX_ARM)
    If UBound(pieces) >= VRX_Win32 And Len(pieces(VRX_Win32)) Then JoinInstallString = JoinInstallString & pieces(VRX_Win32)
    If UBound(pieces) >= VRX_Web And Len(pieces(VRX_Web)) Then JoinInstallString = JoinInstallString & pieces(VRX_Web)
    If UBound(pieces) >= VRX_Ext And Len(pieces(VRX_Ext)) Then JoinInstallString = JoinInstallString &"."& pieces(VRX_Ext)
    If UBound(pieces) >= VRX_ZipRoot And Len(pieces(VRX_ZipRoot)) Then JoinInstallString = JoinInstallString & pieces(VRX_ZipRoot)
    If Err.Number <> 0 Then Err.Clear
    On Error GoTo 0
End Function

' Download exe file
Function DownloadFile(strUrl, strFile)
    ' WScript.echo "kkotari: pyenv-install-lib.vbs DownloadFile..!"
    On Error Resume Next

    ' Try using PowerShell first (most reliable)
    Dim psCmd
    psCmd = "powershell -ExecutionPolicy Bypass -Command ""$ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri '" & strUrl & "' -OutFile '" & strFile & "' -UserAgent 'pyenv-win'"""
    objws.Run psCmd, 0, True

    If Err.Number = 0 And objfs.FileExists(strFile) Then
        Dim fileSize
        fileSize = objfs.GetFile(strFile).Size
        If fileSize > 1000 Then
            Exit Function
        End If
    End If

    ' Fallback to bitsadmin
    Err.Clear
    Dim bitsCmd
    bitsCmd = "bitsadmin /transfer python /priority high /timeout 300 """ & strUrl & """ """ & strFile & """"
    objws.Run bitsCmd, 0, True

    If Err.Number = 0 And objfs.FileExists(strFile) Then
        fileSize = objfs.GetFile(strFile).Size
        If fileSize > 1000 Then
            Exit Function
        End If
    End If

    ' Last resort: VBS HTTP
    Err.Clear
    Dim webObj
    Set webObj = CreateObject("MSXML2.XMLHTTP")
    webObj.Open "GET", strUrl, False
    webObj.SetRequestHeader "User-Agent", "Mozilla/5.0 (compatible; pyenv-win)"
    webObj.SetRequestHeader "Accept", "*/*"
    webObj.Send
    If webObj.Status <> 200 Then
        WScript.Echo ":: [ERROR] :: HTTP "& webObj.Status &" :: "& webObj.StatusText
        WScript.Quit 1
    End If

    With CreateObject("ADODB.Stream")
        .Open
        .Type = 1
        .Write webObj.responseBody
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
    Dim doc
    Set doc = CreateObject("Msxml2.DOMDocument.6.0")
    Set doc.documentElement = doc.createElement("versions")

    Dim versRow
    Dim versElem
    On Error Resume Next
    For Each versRow In versArray
        Set versElem = doc.createElement("version")
        doc.documentElement.appendChild versElem

        With versElem
            If UBound(versRow(SFV_Version)) >= VRX_Ext Then
                .setAttribute "x64",        LocaleIndependantCStr(CBool(Len(versRow(SFV_Version)(VRX_x64)) OR Len(versRow(SFV_Version)(VRX_ARM))))
                .setAttribute "webInstall", LocaleIndependantCStr(CBool(Len(versRow(SFV_Version)(VRX_Web))))
                .setAttribute "msi",        LocaleIndependantCStr(LCase(versRow(SFV_Version)(VRX_Ext)) = "msi")
            End If
        End With
        If UBound(versRow(SFV_Version)) >= VRX_Ext Then
            If versRow(SFV_Version)(VRX_Ext) = "zip" Then
                ' For zip files, if ZipRoot is set use it, otherwise use JoinWin32String
                If UBound(versRow(SFV_Version)) >= VRX_ZipRoot And Len(versRow(SFV_Version)(VRX_ZipRoot)) > 0 Then
                    AppendElement doc, versElem, "code", versRow(SFV_Version)(VRX_ZipRoot)
                Else
                    AppendElement doc, versElem, "code", JoinWin32String(versRow(SFV_Version))
                End If
            Else
                AppendElement doc, versElem, "code", JoinWin32String(versRow(SFV_Version))
            End If
        End If
        AppendElement doc, versElem, "file", versRow(0)
        AppendElement doc, versElem, "URL", versRow(1)
        If UBound(versRow(SFV_Version)) >= VRX_Ext Then
            If versRow(SFV_Version)(VRX_Ext) = "zip" Then
                If UBound(versRow(SFV_Version)) >= VRX_ZipRoot Then
                    AppendElement doc, versElem, "zipRootDir", versRow(SFV_Version)(VRX_ZipRoot)
                End If
            End If
        End If
        If Err.Number <> 0 Then Err.Clear
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
    On Error Resume Next
    ' Delete old file first to avoid any conflicts
    If objfs.FileExists(xmlPath) Then
        objfs.DeleteFile xmlPath, True
        If Err.Number <> 0 Then Err.Clear
    End If

    With outXML
        .SaveToFile xmlPath, 2
        If Err.Number <> 0 Then
            Err.Clear
            ' Try alternative: save directly from doc
            doc.save xmlPath
            If Err.Number <> 0 Then
                WScript.Echo ":: [Error] :: Failed to save database: "& Err.Description
                Err.Clear
            End If
        End If
        .Close
    End With
    On Error GoTo 0
End Sub

' Test if ver1 < ver2
Function SymanticCompare(ver1, ver2)
    Dim comp1, comp2

    ' Safety check for empty arrays
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

    ' ARM
    If UBound(ver1) >= VRX_ARM And UBound(ver2) >= VRX_ARM Then
        comp1 = ver1(VRX_ARM)
        comp2 = ver2(VRX_ARM)
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
    If Not IsArray(pieces) Or UBound(pieces) < 0 Then Exit Function
    If UBound(pieces) >= VRX_Major And Len(pieces(VRX_Major)) Then JoinVersionString = JoinVersionString & pieces(VRX_Major)
    If UBound(pieces) >= VRX_Minor And Len(pieces(VRX_Minor)) Then JoinVersionString = JoinVersionString &"."& pieces(VRX_Minor)
    If UBound(pieces) >= VRX_Patch And Len(pieces(VRX_Patch)) Then JoinVersionString = JoinVersionString &"."& pieces(VRX_Patch)
    If UBound(pieces) >= VRX_Release And Len(pieces(VRX_Release)) Then JoinVersionString = JoinVersionString & pieces(VRX_Release)
    If UBound(pieces) >= VRX_RelNumber And Len(pieces(VRX_RelNumber)) Then JoinVersionString = JoinVersionString & pieces(VRX_RelNumber)
    If UBound(pieces) >= VRX_Arch And Len(pieces(VRX_Arch)) Then JoinVersionString = JoinVersionString & pieces(VRX_Arch)
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

    On Error Resume Next
    arch = GetArchPostfix()
    If Err.Number <> 0 Then
        Err.Clear
        ' If GetArchPostfix is not available, use default value
        Dim archEnv
        archEnv = objws.Environment("Process")("PYENV_FORCE_ARCH")
        If archEnv = "" Then archEnv = objws.Environment("System")("PROCESSOR_ARCHITECTURE")
        If UCase(archEnv) = "AMD64" Then
            arch = ""
        ElseIf UCase(archEnv) = "X86" Then
            arch = "-win32"
        ElseIf UCase(archEnv) = "ARM64" Then
            arch = "-arm64"
        Else
            arch = ""
        End If
    End If
    On Error GoTo 0

    For x = 0 To UBound(candidates) Step 1
        ' startswith
        If Left(candidates(x), Len(prefix)) = prefix Then
            ' Full match OR prefix plus '.'
            If (candidates(x) = prefix & arch) Or (Mid(candidates(x), Len(prefix) + 1, 1) = ".") Then
                Set matches = regexVerArch.Execute(candidates(x))

                if matches.Count = 1 Then
                    ' Skip dev builds, releases and so on
                    ' Comparing each version by <major>.<minor>.<patch>
                    If matches(0).SubMatches.Count > VRX_Arch Then
                        If matches(0).SubMatches.Count > VRX_Release Then
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

' Error handler for the library
On Error Resume Next
If Err.Number <> 0 Then
    WScript.Echo "Library Error ("& Err.Number &"): "& Err.Description
End If
