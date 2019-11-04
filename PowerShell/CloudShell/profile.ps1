# Set an env var for the isdscripts dir
[Environment]::SetEnvironmentVariable("ISDSCRIPTS", "$env:HOME/clouddrive/isd-scripts", "Process")

# Pull most recent code
Push-Location
Set-Location -Path $env:HOME/clouddrive/isd-scripts
git pull origin master
Pop-Location

# Import general PS utilities
Import-Module "$env:ISDSCRIPTS/PowerShell/General/ISDUtilities"

# Get env vars
Set-PsEnv -localEnvFile $env:ISDSCRIPTS/PowerShell/CloudShell/.env

# Import modules for this environment
$modules = $env:CSMODULES.split("|")
foreach($module in $modules)
{
    Import-Module "$env:ISDSCRIPTS/PowerShell/CloudShell/$module"
}