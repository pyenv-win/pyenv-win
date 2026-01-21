
If (($Args.Count -ge 2) -and ($Args[0] -eq "shell")) {
    if ($Args[1] -eq "--help") {
        pyenv.bat @Args
        Exit $LastExitCode
    } elseif ($Args[1] -eq "--unset") {
        If (Test-Path Env:PYENV_VERSION) {
            Remove-Item Env:PYENV_VERSION
        }
    } else {
        $Output = (cscript //nologo "$PSScriptRoot\..\libexec\pyenv.vbs" @Args)
        if ($LastExitCode -ne 0) {
            $Output -join [Environment]::NewLine
            Exit $LastExitCode
        }
        $Env:PYENV_VERSION = $Output
    }
} Else {
    pyenv.bat @Args
    Exit $LastExitCode
}
