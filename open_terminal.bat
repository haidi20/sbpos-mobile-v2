@echo off

start wt ^
    new-tab -d "D:\projects\sb-pos-fix" powershell.exe -NoExit -Command "Write-Host 'sb-pos-fix - Pane 1'" ; ^
    split-pane -V -d "D:\projects\sb-pos-fix" powershell.exe -NoExit -Command "Write-Host 'sb-pos-fix - Pane 2'" ; ^
    split-pane -V -d "D:\projects\sb-pos-fix" powershell.exe -NoExit -Command "Write-Host 'sb-pos-fix - Pane 3'" ; ^
    split-pane -H -d "D:\projects\sb-pos-fix" powershell.exe -NoExit -Command "Write-Host 'sb-pos-fix - Pane 4'" ; ^
    new-tab -d "D:\projects\sbpos_mobile_v2" powershell.exe -NoExit -Command "Write-Host 'sbpos_mobile_v2 - Pane 1'" ; ^
    split-pane -V -d "D:\projects\sbpos_mobile_v2" powershell.exe -NoExit -Command "Write-Host 'sbpos_mobile_v2 - Pane 2'" ; ^
    split-pane -V -d "D:\projects\sbpos_mobile_v2" powershell.exe -NoExit -Command "Write-Host 'sbpos_mobile_v2 - Pane 3'" ; ^
    split-pane -H -d "D:\projects\sbpos_mobile_v2" powershell.exe -NoExit -Command "Write-Host 'sbpos_mobile_v2 - Pane 4'"

REM Opsional: buka workspace VS Code (hapus jika tidak diperlukan)
start "" "D:\projects\sbpos_mobile_v2\sbpos_mobile_v2.code-workspace"
start "" "D:\projects\sb-pos-fix\sb-pos-fix.code-workspace"
