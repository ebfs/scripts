:: if in path run backup FILENAME

@echo off

if "%1"=="" (
    echo Usage: %~n0 [FileName]
    exit /b 1
)

:: edit accordingly!
set "source=C:\Users\YOURUSERNAME\Zomboid\Saves\Sandbox\%1"
set "baseDest=C:\Users\YOURUSERNAME\Zomboid\zomboid-snapshots"

set "counter=1"

:loop
if exist "%baseDest%\%counter%" (
    set /a counter+=1
    goto loop
)

set "destination=%baseDest%\%counter%"
mkdir "%destination%"

set "start=%time%"

robocopy "%source%" "%destination%" /MIR

if %errorlevel% geq 8 (
    echo Robocopy encountered an error. Exit code: %errorlevel%
) else (
    echo Backup completed successfully!
)

set "end=%time%"

for /f "tokens=1-4 delims=:.," %%a in ("%start%") do set /a startH=1%%a-100, startM=1%%b-100, startS=1%%c-100, startMS=1%%d-100
for /f "tokens=1-4 delims=:.," %%a in ("%end%") do set /a endH=1%%a-100, endM=1%%b-100, endS=1%%c-100, endMS=1%%d-100

set /a elapsedH=endH-startH, elapsedM=endM-startM, elapsedS=endS-startS, elapsedMS=endMS-startMS

if %elapsedMS% lss 0 set /a elapsedMS+=1000 & set /a elapsedS-=1
if %elapsedS% lss 0 set /a elapsedS+=60 & set /a elapsedM-=1
if %elapsedM% lss 0 set /a elapsedM+=60 & set /a elapsedH-=1

echo Total time taken: %elapsedH% hours, %elapsedM% minutes, %elapsedS%.%elapsedMS% seconds
