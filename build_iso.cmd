@echo off
@echo Script version 2019_11_29

goto start


# Docs
https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/winpe-intro
https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/winpe-mount-and-customize
https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/winpe-add-packages--optional-components-reference
https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/winpeshlini-reference-launching-an-app-when-winpe-starts

# Architectures
amd64     The 64-bit version can boot 64-bit UEFI and 64-bit BIOS PCs.
x86       The 32-bit version of WinPE can boot 32-bit UEFI, 32-bit BIOS, and 64-bit BIOS PCs.

# Enable/disable feature
Dism /Image:"%work_dir%\mount" /Get-Features
Dism /Quiet /Image:"%work_dir%\mount" /Enable-Feature /FeatureName:TFTP /All
Dism /Quiet /Image:"%work_dir%\mount" /Disable-Feature /FeatureName:TFTP /All

# Network and firewall
wpeutil InitializeNetwork
wpeutil EnableFirewall
wpeutil DisableFirewall

# Power
wpeutil Shutdown
wpeutil Reboot

# Load/unload offline registry
reg load HKLM\offline_system C:\windows\system32\config\system
reg load HKLM\offline_software C:\windows\system32\config\software
reg unload HKLM\offline_system
reg unload HKLM\offline_software


:start
cls
@echo "Select architecture:"
@echo "1 - amd64 stable"
@echo "2 - x86 stable"
@echo "3 - amd64 dev"
@echo "4 - x86 dev"
set /p arch= "[1/2/3/4]: "

IF "%arch%"=="1" (
set arch=amd64
set type=stable
) else if "%arch%"=="2" (
set arch=x86
set type=stable
) else if "%arch%"=="3" (
set arch=amd64
set type=dev
) else if "%arch%"=="4" (
set arch=x86
set type=dev
) else (
@echo "Unknown option"
exit
)

@echo Using architecture: %arch% %type%

set lang=en-us

set work_dir=C:\winpe_%arch%
set soft_dir=\\10.1.0.3\data\soft\winpe\winpe_soft_%arch%_%type%
set out_iso=C:\winpe_%arch%_%type%.iso

set WinPE_OCs=%ProgramFiles(x86)%\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\%arch%\WinPE_OCs

@echo Cleaning up
Dism /Quiet /Cleanup-Mountpoints /MountDir:"%work_dir%\mount" >null
Dism /Quiet /Unmount-Image /MountDir:"%work_dir%\mount" /Discard >null
rmdir /S /Q "%work_dir%"

@echo Copying files
call copype %arch% %work_dir%

@echo Mounting WinPE image
Dism /Quiet /Mount-Image /ImageFile:"%work_dir%\media\sources\boot.wim" /index:1 /MountDir:"%work_dir%\mount"

@echo Adding optional component into WinPE:
@echo WinPE-HTA
Dism /Quiet /Add-Package /Image:"%work_dir%\mount" /PackagePath:"%WinPE_OCs%\WinPE-HTA.cab"
Dism /Quiet /Add-Package /Image:"%work_dir%\mount" /PackagePath:"%WinPE_OCs%\%lang%\WinPE-HTA_%lang%.cab"

@echo WinPE-WMI
Dism /Quiet /Add-Package /Image:"%work_dir%\mount" /PackagePath:"%WinPE_OCs%\WinPE-WMI.cab"
Dism /Quiet /Add-Package /Image:"%work_dir%\mount" /PackagePath:"%WinPE_OCs%\%lang%\WinPE-WMI_%lang%.cab"

@echo WinPE-NetFX
Dism /Quiet /Add-Package /Image:"%work_dir%\mount" /PackagePath:"%WinPE_OCs%\WinPE-NetFX.cab"
Dism /Quiet /Add-Package /Image:"%work_dir%\mount" /PackagePath:"%WinPE_OCs%\%lang%\WinPE-NetFX_%lang%.cab"

@echo Network/WinPE-PPPoE
Dism /Quiet /Add-Package /Image:"%work_dir%\mount" /PackagePath:"%WinPE_OCs%\WinPE-PPPoE.cab"
Dism /Quiet /Add-Package /Image:"%work_dir%\mount" /PackagePath:"%WinPE_OCs%\%lang%\WinPE-PPPoE_%lang%.cab"

@echo Network/WinPE-RNDIS
Dism /Quiet /Add-Package /Image:"%work_dir%\mount" /PackagePath:"%WinPE_OCs%\WinPE-RNDIS.cab"
Dism /Quiet /Add-Package /Image:"%work_dir%\mount" /PackagePath:"%WinPE_OCs%\%lang%\WinPE-RNDIS_%lang%.cab"

@echo WinPE-Scripting
Dism /Quiet /Add-Package /Image:"%work_dir%\mount" /PackagePath:"%WinPE_OCs%\WinPE-Scripting.cab"
Dism /Quiet /Add-Package /Image:"%work_dir%\mount" /PackagePath:"%WinPE_OCs%\%lang%\WinPE-Scripting_%lang%.cab"

@echo WinPE-PowerShell
Dism /Quiet /Add-Package /Image:"%work_dir%\mount" /PackagePath:"%WinPE_OCs%\WinPE-PowerShell.cab"
Dism /Quiet /Add-Package /Image:"%work_dir%\mount" /PackagePath:"%WinPE_OCs%\%lang%\WinPE-PowerShell_%lang%.cab"

@echo WinPE-StorageWMI
Dism /Quiet /Add-Package /Image:"%work_dir%\mount" /PackagePath:"%WinPE_OCs%\WinPE-StorageWMI.cab"
Dism /Quiet /Add-Package /Image:"%work_dir%\mount" /PackagePath:"%WinPE_OCs%\%lang%\WinPE-StorageWMI_%lang%.cab"

@echo WinPE-WinReCfg
Dism /Quiet /Add-Package /Image:"%work_dir%\mount" /PackagePath:"%WinPE_OCs%\WinPE-WinReCfg.cab"
Dism /Quiet /Add-Package /Image:"%work_dir%\mount" /PackagePath:"%WinPE_OCs%\%lang%\WinPE-WinReCfg_%lang%.cab"

@echo WinPE-SecureStartup
Dism /Quiet /Add-Package /Image:"%work_dir%\mount" /PackagePath:"%WinPE_OCs%\WinPE-SecureStartup.cab"
Dism /Quiet /Add-Package /Image:"%work_dir%\mount" /PackagePath:"%WinPE_OCs%\%lang%\WinPE-SecureStartup_%lang%.cab"

@echo WinPE-EnhancedStorage
Dism /Quiet /Add-Package /Image:"%work_dir%\mount" /PackagePath:"%WinPE_OCs%\WinPE-EnhancedStorage.cab"
Dism /Quiet /Add-Package /Image:"%work_dir%\mount" /PackagePath:"%WinPE_OCs%\%lang%\WinPE-EnhancedStorage_%lang%.cab"

@echo Copying files into the "%work_dir%\mount"
xcopy /E /C /Q /H /R /Y "%soft_dir%" "%work_dir%\mount"

@echo This process marks files that can be removed during the export process
Dism /Quiet /Cleanup-Image /Image="%work_dir%\mount" /StartComponentCleanup /ResetBase

@echo Add temporary storage (valid values are 32, 64, 128, 256, or 512)
Dism /Quiet /Set-ScratchSpace:512 /Image:"%work_dir%\mount"

@echo Unmounting WinPE image
Dism /Quiet /Unmount-Image /MountDir:"%work_dir%\mount" /Commit

@echo Building ISO / writing USB
MakeWinPEMedia /ISO /f "%work_dir%" "%out_iso%"

@echo Done

