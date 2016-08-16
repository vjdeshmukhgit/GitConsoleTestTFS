
# Get current directory where the POwershell script exists. This is the one called from the Build definition.
$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path

Write-Host "Path $directorypath" 
$toolkit = $directorypath + "\Xrm.Framework.CI.PowerShell.dll"
 

# get crm solutions folder
$crmfolder = Split-Path -Parent $directorypath  
$crmfolder = $crmfolder + "\CRMSolutions"
Write-Host "CRM Folder Path:  $crmfolder" 

# get file to import. Use the last Updated .zip (solution file)
$fileToImport = "none"
$files = Get-ChildItem -Path $crmfolder | Sort-Object LastWriteTime -Descending
foreach($item in $files)
{
    $fileToImport =$item.FullName
	$writetime = $item.LastWriteTime
    Write-Host "Importing file: $fileToImport; $writetime"
    break

}
# if solution file found then continue.
if($fileToImport -ne "none")
{
    # continue with the build
    Import-Module $toolkit

    Write-Host "Toolkit imported"

    $importJobId = [guid]::NewGuid()
    $connectionString="Url=https://nhtsagmssuat.crm9.dynamics.com; Username=mark.chinstate@usdot.onmicrosoft.com; Password=Kiss12345!; authtype=Office365"
    $import = Import-XrmSolution -ImportAsync $false -ConnectionString $connectionString -PublishWorkflows $true  -SolutionFilePath $fileToImport -WaitForCompletion $true

}
else
{
    Write-Host "No Solution file found to import." -ForegroundColor Red -BackgroundColor White
}
#$fileToImport = $directorypath + "\PostPatch_1_0_0_0.zip"

Write-Host "Import Process completed "