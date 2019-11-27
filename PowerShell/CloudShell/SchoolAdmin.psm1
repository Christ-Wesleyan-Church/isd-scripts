<#
.Synopsis
Rotates substitute passwords.

.Description
Rotates substitute passwords. Pulls list of accounts
for which passwords should be rotated from the "SUBSTITUTEACCOUNTS"
environment variable.

.Example
Set-SubstitutePasswords
#>
function Set-SubstitutePasswords
{

    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="High"
    )]
    Param()

    $accounts = $env:SUBSTITUTEACCOUNTS.split("|")

    Write-Host ('-'*10)

    foreach($account in $accounts) {

        $password = Get-TempPass
        $password_profile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
        $password_profile.Password = $password
        $password_profile.ForceChangePasswordNextLogin = $false

        if ($PSCmdlet.ShouldProcess($account)) {

            $user = Get-AzureADUser -ObjectID $account
            if ($user.Count -ne 1) {
                throw "Couldn't find exactly one user matching '$account'. Terminating."
            }
            $user | Set-AzureADUser -PasswordProfile $password_profile

        }

        Write-Host "Email: $account"
        Write-Host "Password: $password"
        Write-Host ('-'*10)
    }
}

<#
.Synopsis
Performs initialization for student email accounts.

.Description
Performs initialization for student email accounts that's easiest
to perform at a PowerShell prompt. Forwards student email and
disables checking mail in O365. 

.Example
Initialize-StudentEmail -Email darth.vader55@domain.com
#>
function Initialize-StudentEmail {

    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="High"
    )]
    Param(
        [Parameter(Mandatory=$true,
        ValueFromPipeline=$true)]
        [String]
        $Email
    )

    Connect-ExchangeConditionally

    try {
        $cas_mbx = Get-CasMailbox -Identity $Email -ErrorAction Stop
        $mbx = Get-Mailbox -Identity $Email -ErrorAction Stop
    } Catch {
        throw "Couldn't find mailbox for $Email. The user's mailbox probably hasn't been created yet. Check groups, wait a few mins, and try again."
    }

    $split = $Email.split('@')
    $prefix = $split[0]
    $domain = $split[1]
    $forwardingAddress = "$prefix+students@$domain"

    if($PSCmdlet.ShouldProcess($Email)) {
        $cas_mbx | Set-CASMailbox -ActiveSyncEnabled $false -OWAEnabled $false -PopEnabled $false -ImapEnabled $false -MAPIEnabled $false -OWAforDevicesEnabled $false
        $mbx | Set-Mailbox -ForwardingSmtpAddress $forwardingAddress -DeliverToMailboxAndForward $false
    }

    return [PSCustomObject]@{
        'Email' = $Email
        'Prefix' = $prefix
        'ForwardingAddress' = $forwardingAddress
    }

}

Export-ModuleMember -Function "New-*"
Export-ModuleMember -Function "Set-*"
Export-ModuleMember -Function "Initialize-*"