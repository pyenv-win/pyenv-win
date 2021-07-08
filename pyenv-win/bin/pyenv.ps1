
If ($Args.Count -eq 2) {
    $Command = $Args[0]
    $Option = $Args[1]
    pyenv.bat $Command $Option | Tee-Object -Variable Output
    If ($Output.length -eq 0) {
        If ($Option -eq "--unset") {
            If (Test-Path Env:PYENV_VERSION) {
                Remove-Item Env:PYENV_VERSION
            }
        } Else {
            $Env:PYENV_VERSION = $Option
        }
    }
} Else {
    pyenv.bat $Args
}
