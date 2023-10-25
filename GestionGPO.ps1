param(
    [string]$pathFondEcran
)

Import-Module ActiveDirectory
Import-Module GroupPolicy
Install-Module -Name GroupPolicy -Force -SkipPublisherCheck
Import-Module -Name GroupPolicy


#GPO Fond Ecran
$nomGPO = "GPO_FondEcran"
New-GPO -Name $nomGPO -Domain "NovaTechMMMR.local"
New-GPLink -Name $nomGPO -Target "dc=NovaTechMMMR,dc=local"
// Set-GPRegistryValue -Name $nomGPO -Key "HKCU\Control Panel\Desktop" -ValueName Wallpaper -Type String -Value $pathFondEcran

# Mettre à jour pour éviter problème
// Set-GPRegistryValue -Name $nomGPO -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Group Policy" -ValueName "GroupPolicyRefreshTime" -Type DWORD -Value 1800 
// Set-GPRegistryValue -Name $nomGPO -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Group Policy" -ValueName "GroupPolicyRefreshTimeOffset" -Type DWORD -Value 300

Write-Output "Le GPO $($nomGPO) créé et lié au utilisateur du domaine"


# GPO installation application

$nomApplication = "Bloc-Note"
$cheminPartage = "C:/Windows/System32/notpad.exe"

New-GPO -Name "GPO_Installation_$nomApplication" -Comment "GPO pour l'installation automatique de $nomApplication"
$gpo = Get-GPO -Name "GPO_Installation_$nomApplication"

# Configurez l'installation automatique de l'application
// Set-GPRegistryValue -Name $gpo.DisplayName -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\$nomApplication" -ValueName "DisplayName" -Type String -Value "$nomApplication"
// Set-GPRegistryValue -Name $gpo.DisplayName -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\$nomApplication" -ValueName "UninstallString" -Type String -Value "msiexec /i $cheminPartage /quiet"
$GPOPath = "OU=userOu,DC=NovaTechMMMR,DC=local"
New-GPLink -Name $gpo.DisplayName -Target $GPOPath
Write-Output "GPO '$($gpo)' a été créé avec succès et l'installation automatique de $($nomApplication)"


# GPO bloquer port USB sauf le groupe nommé Tech
$nomGPOForUSB = "GPO_USB_Access"
$getAllGroup = Get-ADGroup -Filter *
New-GPO -Name $nomGPOForUSB -Comment "Ce Gpo permet d'ajouter un accès restreinte à tout les goupes dans le domaine NovaTechMMMR.local sauf le group Tech pour avoir accès au port USB"  
$groupName = $group.DisplayName
// Set-GPRegistryValue -Name $nomGPOForUSB -Key "HKLM\SYSTEM\CurrentControlSet\Services\USBSTOR" -ValueName "Start" -Type DWord -Value 4 -Context Machine -PropertyType Registry
Write-Host "USB ports blocked for $($groupName)"

        

#GPO accès panneu et invite de commande
New-GPO -Name "GPO_Bloquer_PanneauDeConfiguration" -Comment "GPO pour bloquer l'accès au Panneau de configuration"
$GPO_PanneauConfig = Get-GPO -Name "GPO_Bloquer_PanneauDeConfiguration"
// Set-GPRegistryValue -Name $GPO_PanneauConfig.DisplayName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "NoControlPanel" -Type DWord -Value 1


New-GPO -Name "GPO_Bloquer_InviteDeCommande" -Comment "GPO pour bloquer l'accès à l'Invite de commande"
$GPO_InviteCommande = Get-GPO -Name "GPO_Bloquer_InviteDeCommande"
// Set-GPRegistryValue -Name $gpoBloquerInviteDeCommande.DisplayName -Key "HKCU\Software\Policies\Microsoft\Windows\System" -ValueName "DisableCMD" -Type DWord -Value 2


$Chemin_GPO = "OU=userOu,DC=NovaTechMMMR,DC=local"
New-GPLink -Name $GPO_PanneauConfig.DisplayName -Target $Chemin_GPO
New-GPLink -Name $GPO_InviteCommande.DisplayName -Target $Chemin_GPO

Write-Output "Les GPO pour bloquer l'accès au Panneau de configuration et à l'Invite de commande ont été créées avec succès"
