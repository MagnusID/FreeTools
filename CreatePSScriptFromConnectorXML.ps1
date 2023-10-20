<#
  .SYNOPSIS
  Create a PS1 Script from the custom commands of an One Identity Manager(c) Powershell Connector XML

  .DESCRIPTION
  The script reads the ConnectorXML and parses, reads the custom commands and appends them to a defined ps1 script

  .PARAMETER PathConnectorXML
  Specifies the path to the XML-based Connector Config file.

  .PARAMETER OutputPath
  Specifies in which directory the output shall be saved.

  .PARAMETER OutPutFilename
  Specifies the filename of the script.

  .PARAMETER AppendToFile
  Default value is false
  If the outputfile already exists by default it is made empty upfront. If set to false any output will be appended. 
  Please note: this can cause errors in the Powershell Syntax

  .INPUTS
  None. You cannot pipe objects to CreatePSScriptFromConnectorXML.ps1.

  .OUTPUTS
  None. CreatePSScriptFromConnectorXML.ps1 does not generate any output.

  .EXAMPLE
  PS> .\CreatePSScriptFromConnectorXML.ps1 -PathConnectorXML "C:\temp\Posh_Config.xml" -OutPutPath "C:\temp" -OutPutFilename "Posh_Config.ps1"

  .EXAMPLE
  PS> .\CreatePSScriptFromConnectorXML.ps1 -PathConnectorXML "C:\temp\Posh_Config.xml" -OutPutPath "C:\temp" -OutPutFilename "Posh_Config.ps1" -AppendToFile $true


#>


param(
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$PathConnectorXML,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$OutPutPath,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$OutPutFilename,
        [parameter(Mandatory=$false)]
        [bool]$AppendToFile = $false
    )


function Get-ConnectorXML {
    param(
        [string]$Path
    )

    [xml]$XMLSchema = Get-Content $Path

    $XMLSchema

}

function Write-FunctionsToFile {
        param(
            [xml]$ConnectorXML,
            [string]$OutputScript
        )

$functions = Select-Xml -Xml $ConnectorXML -XPath "/PowershellConnectorDefinition/Initialization/CustomCommands/CustomCommand"

foreach($f in $functions) {

     "`n#Function '{0}'" -f $f.Node.Name | Add-Content $OutputScript
     "`nfunction {0}`n" -f $f.Node.Name | Add-Content $OutputScript
     " {`n" | Add-Content $OutputScript
     $f.Node.'#cdata-section' | Add-Content $OutputScript
     "`n}`n`n"  | Add-Content $OutputScript

     #function
     

    }
}


function Main {
    $OutputScript = "{0}\{1}" -f $OutPutPath, $OutPutFilename
    if((Test-Path $OutputScript) -and -not $AppendToFile) {
        "" > $OutputScript
    }
[xml]$connectorxml = Get-ConnectorXML -Path $PathConnectorXML
Write-FunctionsToFile -ConnectorXML $connectorxml -OutputScript $OutputScript




}
Main


