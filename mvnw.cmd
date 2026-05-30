@echo off
setlocal

rem Minimal Maven Wrapper bootstrapper.
rem - Downloads wrapper jar to .mvn\wrapper\maven-wrapper.jar if missing
rem - Then runs org.apache.maven.wrapper.MavenWrapperMain

set "BASEDIR=%~dp0"
rem %~dp0 ends with a trailing backslash; remove it to avoid breaking quoted args (e.g. ...\")
if "%BASEDIR:~-1%"=="\" set "BASEDIR=%BASEDIR:~0,-1%"
set "WRAPPER_DIR=%BASEDIR%\.mvn\wrapper"
set "WRAPPER_JAR=%WRAPPER_DIR%\maven-wrapper.jar"

if not exist "%WRAPPER_DIR%" (
  mkdir "%WRAPPER_DIR%" >nul 2>&1
)

if not exist "%WRAPPER_JAR%" (
  echo Downloading Maven Wrapper...
  powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $propsPath=Join-Path '%WRAPPER_DIR%' 'maven-wrapper.properties'; if (!(Test-Path $propsPath)) { throw 'Missing .mvn/wrapper/maven-wrapper.properties'; } $props=Get-Content $propsPath; $wrapperUrl=($props | Where-Object { $_ -match '^\s*wrapperUrl=' } | Select-Object -First 1) -replace '^\s*wrapperUrl=',''; if ([string]::IsNullOrWhiteSpace($wrapperUrl)) { $wrapperUrl='https://repo.maven.apache.org/maven2/org/apache/maven/wrapper/maven-wrapper/3.3.2/maven-wrapper-3.3.2.jar' } Invoke-WebRequest -Uri $wrapperUrl -OutFile '%WRAPPER_JAR%'"
  if errorlevel 1 (
    echo Failed to download Maven Wrapper jar.
    exit /b 1
  )
)

set "JAVA_EXE="
if defined JAVA_HOME (
  set "JAVA_EXE=%JAVA_HOME%\bin\java.exe"
) else (
  for /f "delims=" %%i in ('where java 2^>nul') do (
    set "JAVA_EXE=%%i"
    goto :java_found
  )
)

:java_found
if not defined JAVA_EXE (
  echo Java not found. Install JDK 21 and ensure JAVA_HOME or PATH is set.
  exit /b 1
)

"%JAVA_EXE%" -Dmaven.multiModuleProjectDirectory="%BASEDIR%" -classpath "%WRAPPER_JAR%" org.apache.maven.wrapper.MavenWrapperMain %*
exit /b %ERRORLEVEL%
