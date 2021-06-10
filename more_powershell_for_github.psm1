function Get-AuthHeader
{

param(
 [parameter(mandatory)] $Credential)

$auth=[System.Convert]::ToBase64String([char[]]$C.GetNetworkCredential().Password)

$headers = @{Authorization="Basic $auth"}

return $headers

}

function Add-GitHubCollaborator
{

param(
        [parameter(mandatory)] $Repository,
        [parameter(mandatory)] $Collaborator,
        $authtable
        )

$owner="nicohille"

$api= 'https://api.github.com/repos/'+ $owner + '/' + $Repository + '/collaborators/' + $Collaborator;


Invoke-RestMethod  -Method PUT -Headers $authtable -uri $api

}



$user = "nico.hille@student.ap.be" 

Read-Host -AsSecureString -Prompt ’token’ | ConvertFrom-SecureString |
Tee-Object .\secret.txt |
ConvertTo-SecureString |
Set-Variable ss_token
$C = New-Object pscredential $user, $ss_token

Set-GitHubAuthentication -SessionOnly `
-Credential $C

$authtable=Get-AuthHeader -Credential $C 

$hashtable= Invoke-RestMethod -Headers $authtable https://api.github.com/user

$addcoll= Read-Host Wil je een collaborator toevoegen

if($addcoll -eq "Ja")
    {
    $R="test-from-pwsh"
    $U="kaelhille"
        Add-GitHubCollaborator  -Repository $R -Collaborator $U $authtable
    }


