Write-Host "Hello World! 122"
$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path

Write-Host "Path $directorypath" 
$toolkit = $directorypath + "\Xrm.Framework.CI.PowerShell.dll"
$fileToImport = $directorypath + "\PatchFollowUnfollow_1_0_0_0.zip"
Import-Module $toolkit

Write-Host "Toolkit imported"

$importJobId = [guid]::NewGuid()


$connectionString="Url=https://nhtsagmssdev.crm9.dynamics.com; Username=mark.chinstate@usdot.onmicrosoft.com; Password=Kiss12345!; authtype=Office365"


$import = Import-XrmSolution -ImportAsync $false -ConnectionString $connectionString -PublishWorkflows $true  -SolutionFilePath $fileToImport -WaitForCompletion $true

Write-Host "Import Process completed "