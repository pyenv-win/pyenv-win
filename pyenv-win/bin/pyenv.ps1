
If (($Args.Count -ge 2) -and ($Args[0] -eq "shell")) {
    pyenv.bat $Args | Tee-Object -Variable Output
    if (-not $?) {
        Exit $LastExitCode
    }
    If ($Output.length -eq 0) {
        If ($Args[1] -eq "--unset") {
            If (Test-Path Env:PYENV_VERSION) {
                Remove-Item Env:PYENV_VERSION
            }
        } Else {
            $Env:PYENV_VERSION = $Args[1..$Args.Count]
        }
    }
} Else {
    pyenv.bat $Args
    if (-not $?) {
        Exit $LastExitCode
    }
}
