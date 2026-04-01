@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
set "REPO_ROOT=%SCRIPT_DIR%.."
set "PACKAGE_DIR=%REPO_ROOT%\features\product"
set "QUEUE_FILE=%SCRIPT_DIR%product_test_queue.txt"
set "NEXT_FILE=%SCRIPT_DIR%product_test_queue.next.txt"

if not exist "%QUEUE_FILE%" (
  echo Queue file not found: "%QUEUE_FILE%"
  exit /b 1
)

set "NEXT_TEST="
break > "%NEXT_FILE%"

for /f "usebackq delims=" %%L in ("%QUEUE_FILE%") do (
  if not defined NEXT_TEST (
    if not "%%L"=="" (
      set "NEXT_TEST=%%L"
    )
  ) else (
    >> "%NEXT_FILE%" echo %%L
  )
)

if not defined NEXT_TEST (
  del "%NEXT_FILE%" >nul 2>nul
  echo No remaining product tests in queue.
  exit /b 0
)

echo Running !NEXT_TEST!
pushd "%PACKAGE_DIR%"
call flutter test "!NEXT_TEST!"
set "EXIT_CODE=%ERRORLEVEL%"
popd

if "%EXIT_CODE%"=="0" (
  move /y "%NEXT_FILE%" "%QUEUE_FILE%" >nul
  exit /b 0
)

del "%NEXT_FILE%" >nul 2>nul
exit /b %EXIT_CODE%
