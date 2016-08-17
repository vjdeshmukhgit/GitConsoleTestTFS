
# Get current directory where the POwershell script exists. This is the one called from the Build definition.
$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path

Write-Host "Script Path $directorypath" 
$toolkit = $directorypath + "\Xrm.Framework.CI.PowerShell.dll"
 

# get crm solutions folder
$crmfolder = Split-Path -Parent $directorypath  
$crmfolder = $crmfolder + "\CRMSolutions"
$crmfolderSolutionFiles = $crmfolder + "\*.zip"

Write-Host "CRM Folder Path:  $crmfolder" 

# get file to import. Use the last Updated .zip (solution file)
$FullPathOffileToImport = "none"
$importFileName = ""
$files = Get-ChildItem -Path $crmfolderSolutionFiles | Sort-Object LastWriteTime -Descending
foreach($item in $files)
{
    $FullPathOffileToImport =$item.FullName
    $importFileName = $item.Name

	$writetime = $item.LastWriteTime
    Write-Host "Importing file: $FullPathOffileToImport; $importFileName"
    break

}
# if solution file found then continue.
if($fileToImport -ne "none")
{
    # continue with the build
    Import-Module $toolkit

    Write-Host "Toolkit imported"

    $importJobId = [guid]::NewGuid()
	$solutionInfo = Get-XrmSolutionInfoFromZip -SolutionFilePath $FullPathOffileToImport
    
    $connectionString="Url=https://nhtsagmssuat.crm9.dynamics.com; Username=mark.chinstate@usdot.onmicrosoft.com; Password=Kiss12345!; authtype=Office365"
    $import = Import-XrmSolution -ImportAsync $false -ConnectionString $connectionString -ImportJobId $importJobId -PublishWorkflows $true  -SolutionFilePath $FullPathOffileToImport -WaitForCompletion $true

    #read import log
    $logFile = $importFileName.Replace(".zip", "_" + [System.DateTime]::Now.ToString("yyyyMMdd_HH_mm"))
    $importLogFile = $crmfolder + "\" + $logFile + "_Info.xml" 
    $importJob = Get-XrmSolutionImportLog -ImportJobId $importJobId -ConnectionString $connectionString -OutputFile $importLogFile

    $importProgress = $importJob.Progress
    $importResult = (Select-Xml -Content $importJob.Data -XPath "//solutionManifest/result/@result").Node.Value
    $importErrorText = (Select-Xml -Content $importJob.Data -XPath "//solutionManifest/result/@errortext").Node.Value

    if (($importResult -ne "success") -or ($importProgress -ne 100))
    {
        throw "Import Failed. Error Text: $importErrorText"
    }
    else
    {
        Write-Host "Solution Imported"

        #publish
        Write-Host "Publishing..."
        Publish-XrmCustomizations -ConnectionString $connectionString
        Write-Host "Publishing complete"
    }
   
    # Write the import results in xml

    # this is where the document will be saved:
    $xmlFile = $crmfolder + "\" + $logFile + "_ImportResult.xml"
 

    # get an XMLTextWriter to create the XML
    $XmlWriter = New-Object System.XMl.XmlTextWriter($xmlFile,$Null)
 
    # choose a pretty formatting:
    $xmlWriter.Formatting = 'Indented'
    $xmlWriter.Indentation = 1
    $XmlWriter.IndentChar = "`t"
 
    # write the header
    $xmlWriter.WriteStartDocument()
    # set XSL statements
    #$xmlWriter.WriteProcessingInstruction("xml-stylesheet", "type='text/xsl' href='style.xsl'")
 
    # create root element "machines" and add some attributes to it
    $XmlWriter.WriteComment('Imported Solution File Log')
    $xmlWriter.WriteStartElement('Import')
    $XmlWriter.WriteElementString('RunResult',$importResult)
    $XmlWriter.WriteElementString('Error',$importErrorText)

    $xmlWriter.WriteEndElement()
 
     # finalize the document:
    $xmlWriter.WriteEndDocument()
    $xmlWriter.Flush()
    $xmlWriter.Close()

}
else
{
    Write-Host "No Solution file found to import." -ForegroundColor Red -BackgroundColor White
}

Write-Host "Import Process completed "