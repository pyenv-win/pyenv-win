Option Explicit

' Make sure to Import "pyenv-lib.vbs" before this file in a command. (for objfs/objweb variables)
' WScript.echo "kkotari: pyenv-install-lib.vbs..!"

Dim mirror
mirror = objws.Environment("Process")("PYTHON_BUILD_MIRROR_URL")
If mirror = "" Then mirror = "https://www.python.org/ftp/python"

Const SFV_FileName = 0
Const SFV_URL = 1
Const SFV_Version = 2

Const VRX_Major = 0
Const VRX_Minor = 1
Const VRX_Patch = 2
Const VRX_Release = 3
Const VRX_RelNumber = 4
Const VRX_x64 = 5
Const VRX_Web = 6
Const VRX_Ext = 7

' Version definition array from LoadVersionsXML.
Const LV_Code = 0
Const LV_FileName = 1
Const LV_URL = 2
Const LV_x64 = 3
Const LV_Web = 4
Const LV_MSI = 5
Const LV_ZipRootDir = 6

' Installation parameters used for clear/extract, extension of LV.
Const IP_InstallPath = 7
Const IP_InstallFile = 8
Const IP_Quiet = 9
Const IP_Dev = 10

Dim regexVer
Dim regexFile
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

' Adding -win32 as a post fix for x86 Arch
Function JoinWin32String(pieces)
    ' WScript.echo "kkotari: pyenv-install-lib.vbs JoinWin32String..!"
    JoinWin32String = ""
    If Len(pieces(VRX_Major))     Then JoinWin32String = JoinWin32String & pieces(VRX_Major)
    If Len(pieces(VRX_Minor))     Then JoinWin32String = JoinWin32String &"."& pieces(VRX_Minor)
    If Len(pieces(VRX_Patch))     Then JoinWin32String = JoinWin32String &"."& pieces(VRX_Patch)
    If Len(pieces(VRX_Release))   Then JoinWin32String = JoinWin32String & pieces(VRX_Release)
    If Len(pieces(VRX_RelNumber)) Then JoinWin32String = JoinWin32String & pieces(VRX_RelNumber)
    If Len(pieces(VRX_x64)) = 0   Then JoinWin32String = JoinWin32String & "-win32"
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
            .setAttribute "x64",        LocaleIndependantCStr(CBool(Len(versRow(SFV_Version)(VRX_x64))))
            .setAttribute "webInstall", LocaleIndependantCStr(CBool(Len(versRow(SFV_Version)(VRX_Web))))
            .setAttribute "msi",        LocaleIndependantCStr(LCase(versRow(SFV_Version)(VRX_Ext)) = "msi")
        End With
        AppendElement doc, versElem, "code", JoinWin32String(versRow(SFV_Version))
        AppendElement doc, versElem, "file", versRow(0)
        AppendElement doc, versElem, "URL", versRow(1)
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
