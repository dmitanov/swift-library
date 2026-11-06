$ErrorActionPreference = "Stop"

$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (Test-Path $vswhere) {
    $vsPath = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
    if ($vsPath) {
        $vcvars = Join-Path $vsPath "VC\Auxiliary\Build\vcvars64.bat"
        if (Test-Path $vcvars) {
            $lines = cmd.exe /c "call `"$vcvars`" >nul && set"
            foreach ($line in $lines) {
                if ($line -match '^([^=]+)=(.*)$') {
                    Set-Item -Path ("Env:" + $matches[1]) -Value $matches[2]
                }
            }
        }
    }
}

swift run --build-system native HabitTracker
