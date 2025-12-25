$path = 'HKCU:\Software\Microsoft\Windows\Windows Error Reporting\LocalDumps\sbpos_v2.exe'
New-Item -Path $path -Force | Out-Null
New-ItemProperty -Path $path -Name 'DumpFolder' -Value 'D:\projects\sbpos_mobile_v2\diagnostics\dumps' -PropertyType ExpandString -Force | Out-Null
New-ItemProperty -Path $path -Name 'DumpType' -Value 2 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $path -Name 'DumpCount' -Value 10 -PropertyType DWord -Force | Out-Null
Get-ItemProperty -Path $path | Format-List
Write-Output "Configured LocalDumps for sbpos_v2.exe"
