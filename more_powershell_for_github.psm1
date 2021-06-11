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
        [parameter(ValueFromPipeline=$true)]$RepositoryName,
        [parameter(ValueFromPipeline=$true)]$Collaborator,
        [parameter(ValueFromPipeline=$true)]$Auth
        )

$owner="nicohille"


$api= 'https://api.github.com/repos/'+ $owner + '/' + $RepositoryName + '/collaborators/' + $Collaborator;



Invoke-RestMethod  -Method PUT -uri $api -Header $Auth

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



$invites=Invoke-RestMethod -Method Get -Headers $authtable -Uri $api

$aantal=$invites | Measure

if($Repository -ne $null)
{

    for($i=0;$i -lt $aantal.count;$i++)
    {
        if($Repository -eq $invites[$i].repository.name)
        {
            write-host $invites[$i].inviter.login 'invited you to his repository' $invites[$i].repository.name. 'you have succesfully joined this repo'
            $api2='https://api.github.com/user/repository_invitations/'+ $invites[$i].id
            Invoke-RestMethod -Method Patch -Headers $authtable -Uri $api2
        }
    }
        
}




}

if($OwnerGroup -ne $null)
{

    for($i=0;$i -lt $aantal.count;$i++)
    {
        $inviteUserO[$i]=$invites[$i] | select -Property invitee
        $inviteduser[$i]=($inviteUserO[$i].invitee).login
        

        $inviteO[$i]=$invites[$i] | select -Property inviter
        $inviter[$i]=($inviteO[$i].inviter).login


        $bioinviteduser[$i] = (Get-GitHubUser -UserName $inviter[$i] | Select-Object -Property bio).bio

        $domein="student.ap.be"

        $bioinviter[$i] = (Get-GitHubUser -UserName $inviter[$i] | Select-Object -Property bio).bio
            

        if($bioinviteduser[$i] -eq $bioinviter[$i])
        {
                $api2='https://api.github.com/user/repository_invitations/'+ $invites[$i].id
                Invoke-RestMethod -Method Patch -Headers $authtable -Uri $api2
        }
            
        
    }
        
}

if($MailDomains -ne $null)
{

    for($i=0;$i -lt $aantal.count;$i++)
    {
        $inviteO[$i]=$invites[$i] | select -Property inviter
        $inviter[$i]=($inviteO[$i].inviter).login


        $email[$i] = (Get-GitHubUser -UserName $inviter[$i] | Select-Object -Property email).email

        $domein="student.ap.be"

            

        if(($email[$i] -match $domein) -eq "True")
        {
                $api2='https://api.github.com/user/repository_invitations/'+ $invites[$i].id
                Invoke-RestMethod -Method Patch -Headers $authtable -Uri $api2
        }
            
        
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
        
    $R="MoreCode4Testing"
    $U="kaelhille"
       New-GitHubRepository -RepositoryName $R | Add-GitHubCollaborator  -Collaborator $U  -Auth $authtable
    }

    
$mail="kael.hille@student.ap.be"
$invitations=accept-repositories -Repository $R -OwnerGroup $owner -MailDomains $mail $authtable  
