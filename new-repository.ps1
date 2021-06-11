function create-privateRepo
{

param($authtable, $Repo)

$parameters= @{name=$Repo;private=$true} | ConvertTo-Json

$api="https://api.github.com/user/repos"

Invoke-RestMethod  -Method POST -Headers $authtable -uri $api -Body $parameters

}

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

$Repo="nieuwRepo"

create-privateRepo $authtable $Repo



Add-GitHubCollaborator -Collaborator "dieter-ap" -Repository $Repo $authtable


cd C:\Users\nicoh\repos\MorePowerShellForGithub

git clone https://github.com/nicohille/nieuwRepo.git

Copy-Item C:\Users\nicoh\repos\MorePowerShellForGithub\MoreOfPowershell\new-repository.ps1 -Destination C:\Users\nicoh\repos\MorePowerShellForGithub\$Repo

cd C:\Users\nicoh\repos\MorePowerShellForGithub\$Repo

git add new-repository.ps1

git commit -m "This is a commit comming from powershell script new-repository"

git push