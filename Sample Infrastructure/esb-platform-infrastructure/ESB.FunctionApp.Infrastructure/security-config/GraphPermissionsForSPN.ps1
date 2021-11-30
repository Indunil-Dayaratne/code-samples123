#This script to be run in PowerShell with an Azure AD admin login

if (!(Get-Module -ListAvailable -Name AzureAD)) {
    Install-Module -Name AzureAD
} 

Import-Module AzureAD

Connect-AzureAD

#PrincipalId and ObjectId are the ApplicationId of the AAD Application that handles AAD Authentication for the function App

#If the below line gives an "Insufficient privileges" error even when logged in to PowerShell as an Azure AD admin, 
#execute this line again and it should give a "Bad Request" error. However, the roles are created even after the "Bad Request" error.
New-AzureADServiceAppRoleAssignment -Id df021288-bdef-4463-88db-98f22de89214 -PrincipalId c6d9b5bb-0341-4566-b203-975c5614ff20 -ObjectId c6d9b5bb-0341-4566-b203-975c5614ff20 -ResourceId 31bb1ca4-cc66-4f04-9b80-cc9806bd5268

#If the below line gives an "Insufficient privileges" error even when logged in to PowerShell as an Azure AD admin, 
#execute this line again and it should give a "Bad Request" error. However, the roles are created even after the "Bad Request" error.
New-AzureADServiceAppRoleAssignment -Id 5b567255-7703-4780-807c-7be8301ae99b -PrincipalId c6d9b5bb-0341-4566-b203-975c5614ff20 -ObjectId c6d9b5bb-0341-4566-b203-975c5614ff20 -ResourceId 31bb1ca4-cc66-4f04-9b80-cc9806bd5268 

#If the below line gives an "Insufficient privileges" error even when logged in to PowerShell as an Azure AD admin, 
#execute this line again and it should give a "Bad Request" error. However, the roles are created even after the "Bad Request" error.
New-AzureADServiceAppRoleAssignment -Id 7ab1d382-f21e-4acd-a863-ba3e13f7da61 -PrincipalId c6d9b5bb-0341-4566-b203-975c5614ff20 -ObjectId c6d9b5bb-0341-4566-b203-975c5614ff20 -ResourceId 31bb1ca4-cc66-4f04-9b80-cc9806bd5268 
