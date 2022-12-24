@echo off
set FORGE_VERSION=40.1.84
:: To use a specific Java runtime, set an environment variable named ATM7_JAVA to the full path of java.exe.
:: To disable automatic restarts, set an environment variable named ATM7_RESTART to false.
:: To install the pack without starting the server, set an environment variable named ATM7_INSTALL_ONLY to true.

set INSTALLER="%~dp0forge-1.18.2-%FORGE_VERSION%-installer.jar"
set FORGE_URL="http://files.minecraftforge.net/maven/net/minecraftforge/forge/1.18.2-%FORGE_VERSION%/forge-1.18.2-%FORGE_VERSION%-installer.jar"

:JAVA
if not defined ATM7_JAVA (
    set ATM7_JAVA=java
)

"%ATM7_JAVA%" -version 1>nul 2>nul || (
   echo Minecraft 1.18 requires Java 17 - Java not found
   pause
   exit /b 1
)

:FORGE
setlocal
cd /D "%~dp0"
if not exist "libraries" (
    echo Forge not installed, installing now.
    if not exist %INSTALLER% (
        echo No Forge installer found, downloading from %FORGE_URL%
        bitsadmin.exe /rawreturn /nowrap /transfer forgeinstaller /download /priority FOREGROUND %FORGE_URL% %INSTALLER%
    )
    
    echo Running Forge installer.
    "%ATM7_JAVA%" -jar %INSTALLER% -installServer
)

if not exist "server.properties" (
    (
        echo allow-flight=true
        echo motd=All the Mods 7 - To The Sky
        echo level-type=skyblockbuilder\:skyblock
    )> "server.properties"
)

if "%ATM7_INSTALL_ONLY%" == "true" (
    echo INSTALL_ONLY: complete
    goto:EOF
)

for /f tokens^=2-5^ delims^=.-_^" %%j in ('"%ATM7_JAVA%" -fullversion 2^>^&1') do set "jver=%%j"
if not %jver% geq 17  (
    echo Minecraft 1.18 requires Java 17 - found Java %jver%
    pause
    exit /b 1
) 

:START
"%ATM7_JAVA%" @user_jvm_args.txt @libraries/net/minecraftforge/forge/1.18.2-%FORGE_VERSION%/win_args.txt nogui

if "%ATM7_RESTART%" == "false" ( 
    goto:EOF 
)

echo Restarting automatically in 10 seconds (press Ctrl + C to cancel)
timeout /t 10 /nobreak > NUL
goto:START
