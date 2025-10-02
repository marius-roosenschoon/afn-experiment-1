[CmdletBinding()]
param (
	$deploymentName,
	$workResourceGroup,
	$buildName,
	$parametersFileName,
	$deploymentDir
)

# -deploymentName "$(Build.BuildNumber)" -workResourceGroup "$(workResourceGroup)" -buildName "$(buildName)" -parametersFileName "$(parametersFileName)"
# -deploymentName "$(Build.BuildNumber)" -workResourceGroup "$(workResourceGroup)" -buildName "$(buildName)" -parametersFileName "$(parametersFileName)" -deploymentDir "$(deploymentDir)"

if ([string]::IsNullOrWhiteSpace($workResourceGroup) -Or [string]::IsNullOrEmpty($workResourceGroup))
{
	Write-Output "The 'workResourceGroup' parameter must be supplied!"
	[Environment]::Exit(1)
}

if ([string]::IsNullOrWhiteSpace($buildName) -Or [string]::IsNullOrEmpty($buildName))
{
	Write-Output "The 'buildName' parameter must be supplied!"
	[Environment]::Exit(2)
}

if ([string]::IsNullOrWhiteSpace($parametersFileName) -Or [string]::IsNullOrEmpty($parametersFileName))
{
	Write-Output "The 'parametersFileName' parameter must be supplied!"
	[Environment]::Exit(3)
}

$usingDefaultDeploy="FALSE"
if ([string]::IsNullOrWhiteSpace($deploymentDir) -Or [string]::IsNullOrEmpty($deploymentDir))
{
    $deploymentDir = "Deployment"
    $usingDefaultDeploy="TRUE"
}

Write-Output "deploymentName: $deploymentName"
Write-Output "workResourceGroup: $workResourceGroup"
Write-Output "buildName: $buildName"
Write-Output "parametersFileName: $parametersFileName"
Write-Output "deploymentDir (Default=$usingDefaultDeploy): $deploymentDir"

az deployment group create `
  --name $deploymentName `
  --resource-group $workResourceGroup `
  --template-file "./$buildName/drop/$deploymentDir/Main.bicep" `
  --parameters "./$buildName/drop/$deploymentDir/$parametersFileName"
