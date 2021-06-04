function Get-AuthHeader
{

param($C)

$auth=[System.Convert]::ToBase64String([char[]]$C.GetNetworkCredential().Password)

$headers = @{Authorization="Basic $auth"}

return $headers

}

$user=Read-Host Geef uw username 

Read-Host -AsSecureString -Prompt ’token’ | ConvertFrom-SecureString |
Tee-Object .\secret.txt |
ConvertTo-SecureString |
Set-Variable ss_token
$C = New-Object pscredential $user, $ss_token

Set-GitHubAuthentication -SessionOnly `
-Credential $C

$authtable=Get-AuthHeader $C 

$hashtable= Invoke-RestMethod -Headers $authtable https://api.github.com/user
