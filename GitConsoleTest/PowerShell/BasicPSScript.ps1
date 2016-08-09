Write-Host "Hello World! 122"
$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path

Write-Host "Path $directorypath" 
$toolkit = $directorypath + "\Xrm.Framework.CI.PowerShell.dll"

Import-Module $toolkit

Write-Host "Toolkit imported"