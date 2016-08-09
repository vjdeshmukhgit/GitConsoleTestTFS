Write-Host "Hello World! 123"
$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path

Write-Host "Path $directorypath" 