@echo off
:: KIM: there's an assumption this is running from the directory containing the scripts

:: populate variables
set service_name=go-blog-distribution-services
set service_location=c:/tmp/go-blog-distribution/
IF NOT [%1] == [] (set service_location=%1)
IF NOT [%2] == [] (set service_name=%2)

:: determine if service already exists
nssm status %service_name%
if %errorlevel%==0 (GOTO uninstall) else (GOTO not_installed)

:not_installed
echo %service_name% not installed
exit /B

:uninstall
:: uninstall service
echo "uninstalling..."
nssm stop %service_name%
if NOT "%errorlevel%"=="0" GOTO error
nssm remove %service_name% confirm
if NOT "%errorlevel%"=="0" GOTO error
:: delete application
echo "removing application..."
rmdir /S /Q %service_location%
if NOT "%errorlevel%"=="0" GOTO error
echo "uninstallation successful"
exit /B

:error
echo "error has occured:"%errorlevel%
exit /B 1
