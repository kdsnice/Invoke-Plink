@echo Installer for Invoke-Plink PowerShell module
@SET CurrentDir=%CD%
@SET DestDir=%ProgramFiles%\WindowsPowerShell\Modules\Invoke-Plink
@md "%DestDir%"
@xcopy "%CurrentDir%" "%DestDir%" /T /Y /Q
@xcopy "%CurrentDir%"\Invoke-Plink.psd1 "%DestDir%" /Y /Q
@xcopy "%CurrentDir%"\Invoke-Plink.psm1 "%DestDir%" /Y /Q
@xcopy "%CurrentDir%"\README.md "%DestDir%" /Y /Q
@xcopy "%CurrentDir%"\PuttyFiles "%DestDir%"\PuttyFiles /Y /Q
@powershell -Command "Invoke-WebRequest http://the.earth.li/~sgtatham/putty/latest/x86/plink.exe -OutFile ""%DestDir%\PuttyFiles\plink.exe"""
@powershell -Command "Unblock-File -Path ""%DestDir%\Invoke-Plink.psd1"""
@powershell -Command "Unblock-File -Path ""%DestDir%\Invoke-Plink.psm1"""
@powershell -Command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser"
@powershell -Command "Set-ExecutionPolicy RemoteSigned"