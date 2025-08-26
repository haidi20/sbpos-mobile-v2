@echo off
start wt ^
    new-tab -d "D:\projects\sbpos_mobile_v2" powershell.exe -NoExit -Command "Write-Host ''"; ^
    split-pane -V -d "D:\projects\sbpos_mobile_v2" powershell.exe -NoExit -Command "Write-Host ''" ; ^
    split-pane -V -d "D:\projects\sbpos_mobile_v2" powershell.exe -NoExit -Command "Write-Host ''" ; ^
    split-pane -H -d "D:\projects\sbpos_mobile_v2" powershell.exe -NoExit -Command "Write-Host ''"

start "" "D:\projects\sbpos_mobile_v2\sbpos_mobile_v2.code-workspace"