function Get-AuthHeader
{

param($C)

$auth=[System.Convert]::ToBase64String([char[]]$C.GetNetworkCredential().Password)

$headers = @{Authorization="Basic $auth"}

return $headers

}

function Add-GitHubCollaborator
{
$repo=read-host Aan welke repository wil je de collaborator aan toevoegen
$collaborator=read-host Geef de user die je wil toevoegen

$C = New-Object System.Management.Automation.PSCredential($collaborator , $ss_token)

Set-GitHubAuthentication -SessionOnly `
-Credential $C

$authcollab=Get-AuthHeader -Credential $C
$permission=@{permission = "pull"} | ConvertTo-Json;

$api= "https://api.github.com/repos/$repo/collaborators/$collaborator";

Invoke-RestMethod -Uri $api -Headers $authcollab -ContentType "application/json" -Method Put -Body $permission

}



$user = "nico.hille@student.ap.be" 

Read-Host -AsSecureString -Prompt ’token’ | ConvertFrom-SecureString |
Tee-Object .\secret.txt |
ConvertTo-SecureString |
Set-Variable ss_token
$C = New-Object System.Management.Automation.PSCredential('user' , $ss_token)

Set-GitHubAuthentication -SessionOnly `
-Credential $C

$authtable=Get-AuthHeader $C 

$hashtable= Invoke-RestMethod -Headers $authtable https://api.github.com/user

$addcoll= Read-Host Wil je een collaborator toevoegen

if($addcoll -eq "Ja")
    {
        Add-GitHubCollaborator
    }


