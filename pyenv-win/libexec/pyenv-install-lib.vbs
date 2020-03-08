Option Explicit

' Make sure to Import "pyenv-lib.vbs" before this file in a command. (for objfs variable)

Dim mirror
mirror = objws.Environment("Process")("PYTHON_BUILD_MIRROR_URL")
If mirror = "" Then mirror = "https://www.python.org/ftp/python"

Function DownloadFile(strUrl, strFile)
    Dim objHttp
    Dim httpProxy
    Dim proxyArr
    Set objHttp = WScript.CreateObject("WinHttp.WinHttpRequest.5.1")

    On Error Resume Next
    httpProxy = objws.Environment("Process")("http_proxy")
    If httpProxy <> "" Then
        If InStr(1, httpProxy, "@") > 0 Then
            ' The http_proxy environment variable is set with basic authentication
            ' WinHttp seems to work fine without the credentials, so we should be
            ' okay with just the hostname/port part
            proxyArr = Split(httpProxy, "@")
            objHttp.setProxy 2, proxyArr(1)
        Else
            objHttp.setProxy 2, httpProxy
        End If
    End If

    Call objHttp.Open("GET", strUrl, False)
    If Err.Number <> 0 Then
        WScript.Echo ":: [ERROR] :: "& Err.Description
        WScript.Quit 1
    End If

    objHttp.Send
    If Err.Number <> 0 Then
        WScript.Echo ":: [ERROR] :: "& Err.Description
        WScript.Quit 1
    End If
    On Error GoTo 0
    If objHttp.Status <> 200 Then
        WScript.Echo ":: [ERROR] :: "& objHttp.Status &" :: "& objHttp.StatusText
        WScript.Quit 1
    End If

    Dim Stream
    Set Stream = CreateObject("ADODB.Stream")
    Stream.Open
    Stream.Type = 1
    Stream.Write objHttp.responseBody
    Stream.SaveToFile strFile, 2
    Stream.Close
End Function

Sub clear(cur)
    If objfs.FolderExists(cur(1)) Then objfs.DeleteFolder cur(1), True
    If objfs.FileExists(cur(2))   Then objfs.DeleteFile   cur(2), True
End Sub
