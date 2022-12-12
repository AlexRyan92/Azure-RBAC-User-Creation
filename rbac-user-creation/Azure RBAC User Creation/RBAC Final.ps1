# Requires Azure Resource Manager and Azure Active Directory Cmdlets
# Install-Module AzureRM
# Install-Module AzureADPreview


#Install-Module -Name AzureRM -AllowClobber

#Install-Module -Name AzureADPreview -AllowClob

#Login-AzureRmAccount

#$TenantId = (Get-AzSubscription).TenantId

#Import-Module Az.Resources

Connect-AzureAD -TenantId "45ec1535-0489-4d7a-8e8a-b113b61e0a7e"

$ResourceGroupName = Read-Host -Prompt "What is the Resource Groups name?"
#$Location = "eastus"
#$StorageAccountBaseName = -join ((97..122) | Get-Random -Count 19 | % {[char]$_})

$ResourceGroup = Get-AzureRmResourceGroup -Name $ResourceGroupName

$StopWatch = New-Object -TypeName System.Diagnostics.Stopwatch 
$StopWatch.Start()

$GroupName = Read-Host -Prompt "Type a name for the group"
$ADGroup = New-AzureADGroup -DisplayName $GroupName -MailEnabled $False -SecurityEnabled $True -MailNickName "NotSet"


$Domain = (Get-AzureADDomain).Name
$UserName = Read-Host -Prompt "Type in a username"
$UserPrincipalName = "$UserName@microsharding.com"
$Password = "Password"
$PasswordPolicy = "DisablePasswordExpiration, DisableStrongPassword"
$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$PasswordProfile.Password = $Password 
$PasswordProfile.ForceChangePasswordNextLogin = $False
$PasswordProfile.EnforceChangePasswordPolicy = $False
$ADUser = New-AzureADUser -AccountEnabled $True -DisplayName $UserName -MailNickName $UserName -UserPrincipalName $UserPrincipalName `
                          -UserType "Member" -PasswordProfile $PasswordProfile -PasswordPolicies $PasswordPolicy

Add-AzureADGroupMember -ObjectId $ADGroup.ObjectId -RefObjectId $ADUser.ObjectId

$RbacFile = $env:TEMP + "\rbac.json"
@"
{
  "Name": "ShardSecureContributor",
  "Id": null,
  "IsCustom": true,
  "Description": "Allows for read and write access to Azure storage",
  "Actions": [
    "Microsoft.Storage/*/read",
    "Microsoft.Resources/subscriptions/resourceGroups/write",
    "Microsoft.Resources/subscriptions/resourceGroups/read",
    "Microsoft.Resources/subscriptions/resourceGroups/delete"
  ],
  "NotActions": [
    "Microsoft.Authorization/*/Delete",
    "Microsoft.Authorization/*/Write",
    "Microsoft.Authorization/elevateAccess/Action",
    "Microsoft.Blueprint/blueprintAssignments/write",
    "Microsoft.Blueprint/blueprintAssignments/delete",
    "Microsoft.Compute/galleries/share/action"
  ],
  "AssignableScopes": [
    "/subscriptions/48a6f837-b38c-4107-aef8-cb4a4423990d/resourceGroups/RBACTesting"    
  ]
}
"@ > $RbacFile


#$RoleDefinition = New-AzureRmRoleDefinaition -InputFile $RbacFile
New-AzureRmRoleAssignment -ResourceGroupName $ResourceGroupName -SignInName $UserPrincipalName -RoleDefinitionName ShardSecureContributor

<# $role = Get-AzureRmRoleDefinition -Name "Contributor" 
          $role.Id = $null
          $role.Name = "Contributor"
          $role.Description = "Can monitor, start, and restart virtual machines."
          $role.Actions.RemoveRange(0,$role.Actions.Count)
          $role.Actions.Add("Microsoft.Compute/*/read")
          $role.Actions.Add("Microsoft.Compute/virtualMachines/start/action")
          $role.Actions.Add("Microsoft.Compute/virtualMachines/restart/action")
          $role.Actions.Add("Microsoft.Compute/virtualMachines/downloadRemoteDesktopConnectionFile/action")
          $role.Actions.Add("Microsoft.Network/*/read")
          $role.Actions.Add("Microsoft.Storage/*/read")
          $role.Actions.Add("Microsoft.Authorization/*/read")
          $role.Actions.Add("Microsoft.Resources/subscriptions/resourceGroups/read")
          $role.Actions.Add("Microsoft.Resources/subscriptions/resourceGroups/resources/read")
          $role.Actions.Add("Microsoft.Insights/alertRules/*")
          $role.Actions.Add("Microsoft.Support/*")
          $role.AssignableScopes.Clear()
          $role.AssignableScopes.Add("/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx")

          New-AzureRmRoleDefinition -Role $role

$RoleTarget = $ADUser.ObjectId #> 

#Get-AzRoleDefinition -Name Reader

#New-AzRoleAssignment -SignInName $UserPrincipalName `


<# $AssignRoleAttempt = 0
While ($True)
{
    $AssignRoleAttempt++
    Try 
    {
        New-AzureRmRoleAssignment -ObjectId $RoleTarget -RoleDefinitionId $RoleDefinition.Id -Scope $ResourceGroup.Id -ErrorAction "Stop"
    }
    Catch
    {
        "Exception on assign role attempt #$AssignRoleAttempt"
        Start-Sleep -Seconds 1
        Continue
    }
    Break
}
"Assigned Role on attempt #$AssignRoleAttempt" #> 


$StopWatch.Stop()
" User Created, User Added to Group, Role Created, Group Assigned to Role in:"
$StopWatch.Elapsed.TotalSeconds

<# RbacUserTest.txt
Displaying RbacUserTest.txt. #>
