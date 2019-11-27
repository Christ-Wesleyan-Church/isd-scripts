<#
.Synopsis
Exports environment variable from the .env file to the current process.

.Description
This function looks for .env file in the current directoty, if present
it loads the environment variable mentioned in the file to the current process.
based on https://github.com/rajivharris/Set-PsEnv. This function is shamelessly
borrowed from: https://gist.github.com/grenzi/82e6cb8215cc47879fdf3a8a4768ec09

.Example
 Set-PsEnv

.Example
 # This is function is called by convention in PowerShell
 # Auto exports the env variable at every prompt change
 function prompt {
     Set-PsEnv
 }
#>
function Set-PsEnv {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    param($localEnvFile = ".\.env")

    #return if no env file
    if (!( Test-Path $localEnvFile)) {
        Throw "could not open $localEnvFile"
    }

    #read the local env file
    $content = Get-Content $localEnvFile -ErrorAction Stop
    Write-Verbose "Parsed .env file"

    #load the content to environment
    foreach ($line in $content) {
        if ($line.StartsWith("#")) { continue };
        if ($line.Trim()) {
            $line = $line.Replace("`"","")
            $kvp = $line -split "=",2
            if ($PSCmdlet.ShouldProcess("$($kvp[0])", "set value $($kvp[1])")) {
                [Environment]::SetEnvironmentVariable($kvp[0].Trim(), $kvp[1].Trim(), "Process") | Out-Null
            }
        }
    }
}

<#
.Synopsis
Generates a temporary password.

.Description
This function generates a temporary password similar in format to those
generated by AzureAD.

.Example
 Get-TempPass
#>
function Get-TempPass
{

    $pass = @()

    foreach($ndx in 0..3)
    {
        if ($ndx % 2 -eq 0)
        {
            $pass += Get-RandConsonant
        }
        else
        {
            $pass += Get-RandVowel
        }
    }
    $pass[0] = $pass[0].ToUpper()

    foreach($ndx in 0..3) {
        $pass += Get-Random -Minimum 0 -Maximum 10
    }

    return $pass -join ""

}

<#
.Synopsis
Generates a random vowel.

.Description
This function generates a random vowel; useful for setting
temporary passwords.

.Example
 Get-RandVowel
#>
function Get-RandVowel
{

    $vowel_ndx = @(97, 101, 105, 111, 117)

    $rand = Get-Random -Minimum 0 -Maximum 5

    $vowel = $vowel_ndx[$rand]

    return [string][char]$vowel

}

<#
.Synopsis
Generates a random consonant.

.Description
This function generates a random consonant; useful for setting
temporary passwords.

.Example
 Get-RandConsonant
#>
function Get-RandConsonant
{

    $consonant_ndx = [System.Collections.ArrayList](97..122)

    foreach($ndx in 97, 101, 105, 111, 117)
    {
        $consonant_ndx.Remove($ndx)
    }

    $rand = Get-Random -Minimum 0 -Maximum $consonant_ndx.Count

    $consonant = $consonant_ndx[$rand]

    return [string][char]$consonant

}

Export-ModuleMember -Function @('Get-*', 'Set-*')

<#
.Synopsis
Conditionally connects to Exchange Online Module.

.Description
Conditionally connects to Exchange Online. Does nothing
if we're already connected.

.Example
Connect-ExchangeConditionally
#>
function Connect-ExchangeConditionally {

    # Only act if Exchange commands aren't available
    if ((Test-CommandExists -Command Get-Mailbox) -eq $false) {

        if ((Test-CommandExists -Command Connect-EXOService)) {
            Connect-EXOService
        }

        if (Test-CommandExists -Command Connect-EXOPSSession) {
            Connect-EXOPSSession
        }

    }

}

Export-ModuleMember -Function Connect-ExchangeConditionally

<#
.Synopsis
Check whether or not the specified command exists.

.Description
Checks to see whether or not the given command exists
in the current session. Inspired by: 
https://devblogs.microsoft.com/scripting/use-a-powershell-function-to-see-if-a-command-exists/

.Example
Test-CommandExists
#>
function Test-CommandExists {
    Param(
        [Parameter(Mandatory=$true,
        ValueFromPipeline=$true)]
        [String]
        $Command
    )

    $oldErrPref = $ErrorActionPreference
    $ErrorActionPreference = 'stop'

    $commandExists = $null

    try {
        Get-Command $Command > $null
        $commandExists = $true
    } Catch {
        $commandExists = $false
    } Finally {
        $ErrorActionPreference = $oldErrPref
    }

    return $commandExists
}

Export-ModuleMember -Function Test-CommandExists