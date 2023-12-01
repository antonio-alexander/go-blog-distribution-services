@echo off
:: KIM: there's an assumption this is running from the directory containing the scripts

:: populate variables
set service_name=go-blog-distribution-services
set service_location=c:\tmp\go-blog-distribution-services\
set service_artifacts=.\tmp\
IF NOT [%1] == [] (set service_location=%1)
IF NOT [%2] == [] (set service_artifacts=%2)
IF NOT [%3] == [] (set service_name=%3)

:: create service location folder (we don't care if this fails)
mkdir "%service_location%"

:: determine if service already exists
nssm status %service_name%
if %errorlevel%==0 (GOTO update) else (GOTO install)

:update
echo "uninstalling..."
:: stop the service (we don't care if this fails because it could already be stopped)
nssm remove %service_name% confirm
if NOT "%errorlevel%"=="0" GOTO error

:install
echo "installing..."
:: copy the executable into a specified destination (with default) with any artifacts
xcopy %service_artifacts% %service_location% /Y
if NOT "%errorlevel%"=="0" GOTO error
:: install the service
nssm install %service_name% %service_location%sample_application.exe
if NOT "%errorlevel%"=="0" GOTO error
:: set any configuration
nssm set %service_name% Description "A sample application deployed as a windows service"
if NOT "%errorlevel%"=="0" GOTO error
nssm set %service_name% AppEnvironment :HTTP_PORT=8080
if NOT "%errorlevel%"=="0" GOTO error
nssm set %service_name% AppEnvironment :SYSTEMROOT=c:\windows
if NOT "%errorlevel%"=="0" GOTO error
nssm set %service_name% ObjectName LocalSystem
if NOT "%errorlevel%"=="0" GOTO error
nssm set %service_name% DisplayName go-blog-distribution-services
if NOT "%errorlevel%"=="0" GOTO error
nssm set %service_name% AppStdout %service_location%\sample_application.log
if NOT "%errorlevel%"=="0" GOTO error
nssm set %service_name% AppStderr %service_location%\sample_application.log
if NOT "%errorlevel%"=="0" GOTO error
nssm set %service_name% AppDirectory %service_location%
if NOT "%errorlevel%"=="0" GOTO error
nssm set %service_name% AppExit Default Restart
if NOT "%errorlevel%"=="0" GOTO error
nssm set %service_name% Type SERVICE_WIN32_OWN_PROCESS
if NOT "%errorlevel%"=="0" GOTO error
nssm set %service_name% AppParameters --arg
if NOT "%errorlevel%"=="0" GOTO error
nssm set %service_name% Start SERVICE_DEMAND_START
:: wait for some seconds

:: start the service
nssm start %service_name%
if NOT "%errorlevel%"=="0" GOTO error
:: perform a smoke test for the service
:: set the service to automatically run
nssm set %service_name% Start SERVICE_AUTO_START
if NOT "%errorlevel%"=="0" GOTO error
echo "installation successful"
exit /b

:error
echo "error has occured:"%errorlevel%

exit /b 1
