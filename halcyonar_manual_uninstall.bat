@echo off
Title "HalcyonAR Manual Removal"
cls
pushd "%~dp0"
setlocal

echo [*] Attempting to stop Halcyon services and ui process
echo.
@echo on
sc stop halcyonar
sc stop halcyonagent
taskkill /F /IM halcyonui.exe

@echo off
echo.
echo [*] Waiting 10 seconds for agent service to fully stop
timeout /t 10
echo.
echo -----------------------------------------------------------------------------------------
echo [*] Attempting to delete halcyon services
echo.
@echo on
sc delete halcyonar
sc delete halcyonagent

@echo off
echo.
echo -----------------------------------------------------------------------------------------
echo [*] Attempting to delete Halcyon directories
echo.
@echo on
rmdir "C:\Program Files\Halcyon" /S /Q
rmdir "C:\ProgramData\Halcyon" /S /Q
rmdir "C:\Program Files (x86)\InstallShield Installation Information\{7A334500-AF25-4563-B67D-2F81EB315377}" /S /Q

@echo off
echo.
echo -----------------------------------------------------------------------------------------
echo [*] Attempting to delete Halcyon driver
echo.
@echo on
del "C:\Windows\System32\drivers\halcyondrvr.sys" /S /F /Q

@echo off
echo.
echo -----------------------------------------------------------------------------------------
echo [*] Attempting to rename and schedule deletion of injectors after reboot
echo.
SET hlcn64=%random%%random%
echo [*] Renaming 64 bit injector:>ren "C:\Windows\System32\hlcnuser.dll" "hlcnuser_%hlcn64%.dll"
ren "C:\Windows\System32\hlcnuser.dll" "hlcnuser_%hlcn64%.dll"
echo.
SET hlcn32=%random%%random%
echo [*] Renaming 32 bit injector:>ren "C:\Windows\SysWOW64\hlcnuser.dll" "hlcnuser_%hlcn32%.dll"
ren "C:\Windows\SysWOW64\hlcnuser.dll" "hlcnuser_%hlcn32%.dll"
echo.
echo [*] Scheduling to delete injectors after reboot
@echo on
movefile "C:\Windows\System32\hlcnuser_%hlcn64%.dll" ""
movefile "C:\Windows\SysWOW64\hlcnuser_%hlcn32%.dll" ""

@echo off
echo.
echo -----------------------------------------------------------------------------------------
echo [*] Attempting to delete Halcyon related Registry keys
echo.
@echo on
reg delete HKLM\Software\Halcyon /f
reg delete HKLM\SYSTEM\CurrentControlSet\Services\halcyonAgent /f
reg delete HKLM\SYSTEM\CurrentControlSet\Services\halcyonAR /f

@echo off
echo.
echo [*] Attempting to delete 64 bit uninstall Halcyon registry key
echo.
for /f "tokens=*" %%k in ('reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall') do (
for /f "tokens=3" %%a in ('reg query %%k /V DisplayName  ^|findstr /ri "REG_SZ"') do (if "%%a"=="Halcyon" (set UNINST64=%%k)))
if "%UNINST64%"=="" (goto NO64REG) else (goto DEL64REG)
:DEL64REG
echo [*] Found Halcyon msi 64 bit uninstall [REG %UNINST64%] [DisplayName "Halcyon AR"]
echo.
@echo on 
reg delete "%UNINST64%" /f
@echo off
goto 32REGDEL
:NO64REG
echo [*] No Halcyon msi 64 bit uninstall REG key found

:32REGDEL
@echo off
echo.
echo [*] Attempting to delete 32 bit uninstall Halcyon registry key
echo.
for /f "tokens=*" %%k in ('reg query HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall') do (
for /f "tokens=3" %%a in ('reg query %%k /V DisplayName  ^|findstr /ri "REG_SZ"') do (if "%%a"=="Halcyon" (set UNINST32="%%k")))

if "%UNINST32%"=="" (goto :NO32REG) else (goto DEL32REG)
:DEL32REG
echo [*] Found Halcyon msi 32 bit uninstall [REG "%UNINST32%"] [DisplayName "Halcyon AR"]
echo.
@echo on 
reg delete "%UNINST32%" /f
@echo off
goto :DELUICERT
:NO32REG
echo [*] No Halcyon msi 32 bit uninstall REG key found

REM: DELUICERT
REM: @echo off
REM: echo.
REM: The HalcyonUI certificate thumbprint will need to be updated because it is set to expire at the end of 2022
REM: echo [*] Attempting to delete UI certificate from RootCA
REM: echo.
REM: certutil -delstore Root df11b5b8ce622bc4d8afb7fefe04c5cc5ebc8c45

@echo off
endlocal
REM shutdown /r /t 10