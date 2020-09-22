@ECHO OFF

SETLOCAL
SET SCENARIONAME=DB_Upgrade_Pre

IF "%1"=="" (
  @ECHO Warning: SQLSERVER env var undefined - assuming a default SQL instance. 
  SET SQLSERVER=.\SQL2017
) ELSE (
  SET SQLSERVER=%1
)

REM ========== Setup ========== 
@ECHO %date% %time% - Starting scenario %SCENARIONAME%...
CALL ..\common\Cleanup.cmd %SQLSERVER%
IF "%ERRORLEVEL%" NEQ "0" GOTO :eof
@ECHO %date% %time% - %SCENARIONAME% setup...
sqlcmd.exe -S%SQLSERVER% -E -dAdventureWorksDW2012  -iCleanup.sql %NULLREDIRECT%
sqlcmd.exe -S%SQLSERVER% -E -dAdventureWorksDW2012 -ooutput\PreSetup.out -iPreSetup.sql %NULLREDIRECT%

REM ========== Start ========== 
REM Start expensive query
@ECHO %date% %time% - Starting foreground queries...
SET /A NUMTHREADS=%NUMBER_OF_PROCESSORS%
REM CALL ..\common\StartN.cmd /N %NUMTHREADS% /C ..\common\loop.cmd sqlcmd.exe -S%SQLSERVER% -E -iWorkload.sql -dAdventureWorksDW2012  2^> output\Workload.err > NUL
.\ostress -E -iWorkload.sql -n%NUMTHREADS% -r25 -q -S%SQLSERVER%

REM @ECHO %date% %time% - Press ENTER to end the scenario. 
REM pause %NULLREDIRECT%
@ECHO %date% %time% - Shutting down...


REM ========== Cleanup ========== 
REM sqlcmd.exe -S%SQLSERVER% -E -dAdventureWorksDW2012  -iCleanup.sql %NULLREDIRECT%
REM CALL ..\common\Cleanup.cmd %SQLSERVER%

