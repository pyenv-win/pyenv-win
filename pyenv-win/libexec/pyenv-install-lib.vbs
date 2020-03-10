Option Explicit

' Make sure to Import "pyenv-lib.vbs" before this file in a command. (for objfs/objweb variables)

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

' Installation parameters used for clear/extract, extension of LV.
Const IP_InstallPath = 6
Const IP_InstallFile = 7
Const IP_Quiet = 8

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

Function JoinVerString(pieces, x64)
    Dim strVer
    strVer = ""
    If Len(pieces(VRX_Major)) Then strVer = strVer & pieces(VRX_Major)
    If Len(pieces(VRX_Minor)) Then strVer = strVer &"."& pieces(VRX_Minor)
    If Len(pieces(VRX_Patch)) Then strVer = strVer &"."& pieces(VRX_Patch)
    If Len(pieces(VRX_Release)) Then strVer = strVer & pieces(VRX_Release)
    If Len(pieces(VRX_RelNumber)) Then strVer = strVer & pieces(VRX_RelNumber)
    If x64 Then _
        If Len(pieces(VRX_x64)) Then strVer = strVer & pieces(VRX_x64)
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

Function DownloadFile(strUrl, strFile)
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
    If objfs.FolderExists(params(IP_InstallPath)) Then _
        objfs.DeleteFolder params(IP_InstallPath), True

    If objfs.FileExists(params(IP_InstallFile)) Then _
        objfs.DeleteFile params(IP_InstallFile), True
End Sub
