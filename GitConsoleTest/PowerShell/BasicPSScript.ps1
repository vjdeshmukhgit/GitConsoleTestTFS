Write-Host "Hello World!"
$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path

Write-Host "Path $directorypath" 