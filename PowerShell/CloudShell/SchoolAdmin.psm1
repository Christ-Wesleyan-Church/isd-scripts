# Set substitute passwords of the week
function Set-SubstitutePasswords
{
    $accounts = $env:SUBSTITUTEACCOUNTS.split("|")

    Write-Host ('-'*10)

    foreach($account in $accounts) {

        $password = Get-TempPass
        $password_profile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
        $password_profile.Password = $password
        $password_profile.ForceChangePasswordNextLogin = $false

        $user = Get-AzureADUser -ObjectID $account

        if ($user.Count -ne 1) 
        {
            throw "Couldn't find exactly one user matching '$account'. Terminating."
        }

        $user | Set-AzureADUser -PasswordProfile $password_profile

        Write-Host "Email: $account"
        Write-Host "Password: $password"
        Write-Host ('-'*10)
    }
}

Export-ModuleMember -Function "New-*"
Export-ModuleMember -Function "Set-*"