@echo off
REM Add all changes
git add .

REM Commit with a message
set /p commitMsg="Enter commit message: "
git commit -m "%commitMsg%"

git push origin master
