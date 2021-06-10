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

function accept-repositories
{

param(
        [parameter(mandatory)] $Repository,
        [parameter(mandatory)] $OwnerGroup,
        [parameter(mandatory)] $MailDomains,
        $authtable
        )

$api="https://api.github.com/user/repository_invitations"

$invitations=Invoke-RestMethod -Method Get -Headers $authtable -Uri $api

write-host $invitations.inviter.login 'invited you to his repository' $invitations.repository.name 

if($Repository -ne $null -and $Repository -eq $invitations.repository.name)
{

$api2='https://api.github.com/user/repository_invitations/'+ $invitations.id
Invoke-RestMethod -Method Patch -Headers $authtable -Uri $api2
}

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

    $R="PS-misc"
$owner="nicohille"
$mail="nico.hille@student.ap.be"
$invitations=accept-repositories -Repository $R -OwnerGroup $owner -MailDomains $mail $authtable  
