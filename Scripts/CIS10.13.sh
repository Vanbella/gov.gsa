#!/bin/bash
#  10.12.x CIS implementation script.
#  By Ian F Bell 04/17
#  Updated JFG 19.7.2018
##############################################

sw_vers=$(sw_vers -productVersion)
csrstat=$""

# 1.2 Enable Auto Update
defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticCheckEnabled -bool TRUE
defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticDownload -bool TRUE
softwareupdate --schedule on
echo $(date) "1.2 Enable Auto Update enabled" >> /var/log/GSAlog
##############################################
# 1.3 Enable App Update Installs
defaults write /Library/Preferences/com.apple.commerce.plist AutoUpdate -bool FALSE
echo $(date) "1.3 Enable App Update Installs enabled." >> /var/log/GSAlog
##############################################
# 1.4 Enable system and security installs
defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist ConfigDataInstall -bool TRUE
defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist CriticalUpdateInstall -bool TRUE
echo $(date) "1.4 Enable system and security installs enabled." >> /var/log/GSAlog
##############################################
# 1.5 Enable OS X Update Installs
defaults write /Library/Preferences/com.apple.commerce.plist AutoUpdateRestartRequired -bool FALSE
echo $(date) "1.5 Enable OS X Update Installs enabled." >> /var/log/GSAlog
##############################################
# 2.1.1 Bluetooth this is a UBE currently. all bluetooth managent is handled by a specific bluetooth policy
# defaults write com.apple.Bluetooth.plist ControllerPowerState -int 0
# killall -HUP blued
echo $(date) "2.1.1 Bluetooth is a UBE currently." >> /var/log/GSAlog
##############################################
# 2.1.3 Bluetooth Menu Bar
# Moved to "Add Bluetooth to Menu Bar" policy (Once every week/Check-in/All Comp/All User)
##############################################
# 2.2.1 Enable Set time and date automatically
/bin/cat > /etc/ntp.conf << 'NEW_NTP_CONF'
server ent.ds.gsa.gov
server time.nist.gov
server time.apple.com
NEW_NTP_CONF
echo $(date) "2.2.1 Enable Set time and date automatically enabled." >> /var/log/GSAlog
##############################################
# 2.2.2 Time set within appropriate limits
# Get the current time drift. We're looking for between -270 and 270 seconds.
# Convert negative to positive numbers for easier processing later.
drift=$( ntpdate -svd time.gsa.gov | egrep offset | sed 's/-//g' )
# Are we out of sync? Use bc as we're dealing with floating point numbers
if (( $(bc <<< "$drift <= 270") ))
then
	ntpd -g -x -q
fi
echo $(date) "2.2.2 Time set within appropriate limits enabled." >> /var/log/GSAlog
##############################################
# 2.2.3 Restrict NTP server to loopback interface - Incomplete
##############################################
# 2.3.1 Set an inactivity interval of 20 mins or less for the screen saver (both LoginWindow and UserLand) - Not Complete
##############################################
# 2.3.2 Secure screen saver corners
user=`who|grep console|awk '{print $1}'`
tlcorner=$( defaults read /Users/$user/Library/Preferences/com.apple.dock wvous-tl-corner )
trcorner=$( defaults read /Users/$user/Library/Preferences/com.apple.dock wvous-tr-corner )
blcorner=$( defaults read /Users/$user/Library/Preferences/com.apple.dock wvous-bl-corner )
brcorner=$( defaults read /Users/$user/Library/Preferences/com.apple.dock wvous-br-corner )
#
if [ "$tlcorner" = "6" ];
then
sudo -u $user defaults write /Users/$user/Library/Preferences/com.apple.dock wvous-tl-corner -int 1
fi
#
if [ "$trcorner" = "6" ];
then
sudo -u $user defaults write /Users/$user/Library/Preferences/com.apple.dock wvous-tr-corner -int 1	
fi
#
if [ "$blcorner" = "6" ];
then
sudo -u $user defaults write /Users/$user/Library/Preferences/com.apple.dock wvous-bl-corner -int 1
fi
#
if [ "$brcorner" = "6" ];
then
sudo -u $user defaults write /Users/$user/Library/Preferences/com.apple.dock wvous-br-corner -int 1
fi
echo $(date) "2.3.2 hot corner check completed." >> /var/log/GSAlog
##############################################
# 2.3.3 Verify Display Sleep is set to a value larger than the Screen Saver
# Config Profile "Energey Savings" Desktop/Laptop(Bat&AC) 15 mins
##############################################
# 2.3.4 10.13 Exceptions List - 3 methods
# 1. Apple Menu "Lock Screen" 2. Key sequence of ^+command+q 3. Menubar / NoMAD "Lock Screen"
##############################################
# 2.4.1 Disable Remote Apple Events
systemsetup -setremoteappleevents off
echo $(date) "2.4.1 Disable Remote Apple Events completed." >> /var/log/GSAlog
##############################################
# 2.4.2 Disable Internet Sharing
defaults write /Library/Preferences/SystemConfiguration/com.apple.nat NAT -dict-add Enabled -int 0
echo $(date) "2.4.2 Disable Internet Sharing completed." >> /var/log/GSAlog
##############################################
# 2.4.3 Disable Screen Sharing We Need this for Jamf Pro 
#
##############################################
# 2.4.3 Disable the printer sharing service
cupsctl --no-share-printers
# Disable for all installed printer objects
#lpstat -p | awk '{print $2}'| xargs -I{} lpadmin -p {} -o printer-is-shared=false
# Line does nothing
echo $(date) "2.4.4 Disable Print Sharing completed." >> /var/log/GSAlog
##############################################
# 2.4.5 Disable Remote Login
# Remove the existing SSH access group (revert to all user access) not done due to client needs
#dseditgroup -o delete -t group com.apple.access_ssh
# Create the access group again anew
#dseditgroup -o create -q com.apple.access_ssh
# Add the Casper Management account (very important!)
#dseditgroup -o edit -a caspermgt -t user com.apple.access_ssh
# Add the standard local admin management account
#dseditgroup -o edit -a Administrator -t user com.apple.access_ssh
# Make sure that SSH is enabled
#systemsetup -setremotelogin on
# echo $(date) "2.4.5 Disable Remote Login completed." >> /var/log/GSAlog
##############################################
# 2.4.6 Disable DVD or CD Sharing - Incomplete
##############################################
# 2.4.7 Disable Bluetooth Sharing thus is a UBE - Incomplete
##############################################
# 2.4.8 Disable File Sharing - 
launchctl unload -w /System/Library/LaunchDaemons/com.apple.AppleFileServer.plist
launchctl unload -w /System/Library/LaunchDaemons/com.apple.smbd.plist
echo $(date) "2.4.8 Disable AFP File Sharing completed." >> /var/log/GSAlog
##############################################
# 2.4.9 Disable Remote Management
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate -configure -access -off
echo $(date) "2.4.8 Disable ARD remote managment completed." >> /var/log/GSAlog
##############################################
# 2.5.1 Disable "wake for network access" - Config Profile - Energy Savings
# 2.5.2 Disable sleeping the computer when connected to power - Config Profile - Energy Savings
# 2.6.1 Enable FileVault - FileVault is enabled via Local Support during provisioning time per the Mac Setup SOP.
# FV configuration is centrally managed via JAMFPro/JSS. Configuration provided as requested
# 2.6.2 Enable Gatekeeper - Config Profile - GSA Security
# 2.6.3 Enable Firewall - Config Profile - GSA Security
# 2.6.4 Enable Firewall - Config Profile - GSA Security
# 2.6.5 How many apps in the AF this is a simple check only - Incomplete
# 2.6.6 Enable Location Services - Disabled via Config Profile - GSA Settings-Custom
# 2.6.7 Monitor Location Services Access
# 2.7.1-5 iCloud Configuration - Config Profile - GSA system preference settings
##############################################
# 2.8.1 Time Machine Auto-Backup 
/usr/bin/tmutil disable
defaults write /Library/Preferences/com.apple.TimeMachine.plist AutoBackup 0
# defaults write /Library/Preferences/com.apple.TimeMachine.plist DoNotOfferNewDisksForBackup Incomplete
echo $(date) "2.8.1 Time Machine Disabled" >> /var/log/GSAlog
##############################################
# 2.9 Pair the remote control infrared receiver if enabled - Incomplete
##############################################
# 3.1 Configure asl.conf
days="180"
sed -ie 's/ttl=./ttl='$days'/' /etc/asl.conf
killall cfprefsd
echo $(date) "3.1 Configure asl.conf completed." >> /var/log/GSAlog
##############################################
#3.2 Enable security auditing
launchctl load -w /System/Library/LaunchDaemons/com.apple.auditd.plist
echo $(date) "Enable security auditing completed." >> /var/log/GSAlog

#3.3 Configure security auditing flags
flags="lo,ad,fd,fm,-all"
sed -ie 's/^flags\(.*\)/flags:'$flags'/' /etc/security/audit_control
echo $(date) "Configure security auditing flags completed." >> /var/log/GSAlog

#4.1 Disable Bonjour advertising service
defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool YES
echo $(date) "Disable Bonjour advertising service completed." >> /var/log/GSAlog

#4.2 WiFi Menu Bar done via policy in JAMF
#user=$( python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");' )
#defaults write /Users/$user/Library/Preferences/com.apple.systemuiserver.plist menuExtras -array-add "/System/Library/CoreServices/Menu Extras/AirPort.menu"
#echo $(date) "Implemented WiFi Menu Bar." >> /var/log/GSAlog


#4.4 Disable HTTP service
apachectl stop
defaults write /System/Library/LaunchDaemons/org.apache.httpd Disabled -bool true
echo $(date) "Disable HTTP service complete." >> /var/log/GSAlog

#4.5 Disable FTP service
launchctl unload -w /System/Library/LaunchDaemons/ftp.plist
echo $(date) "Disable FTP service complete." >> /var/log/GSAlog

#4.6 Disable NFS service
nfsd disable
rm /etc/export
echo $(date) "Disable NFS service complete." >> /var/log/GSAlog

#5.1.2 Secure System Wide Applications Folder
find /Applications -type d -exec chmod -R 755 {} + 2> /dev/null
find /Applications -type d -exec chown root:wheel {} + 2> /dev/null
echo $(date) "Secure System Wide Applications Folder complete." >> /var/log/GSAlog

#5.1.4 Secure Open Library Folders
# CIS 5.1.4 - Curtesy of Owen Pragel (owen dot pragel @ 74bit dot com)
find /Library -type d -exec chmod -R o-w {} +
echo $(date) "Secure Open Library Folders complete." >> /var/log/GSAlog

#5.6 Enable OCSP and CRL certificate checking
defaults write com.apple.security.revocation CRLSufficientPerCert -int 1
defaults write com.apple.security.revocation CRLStyle -string RequireIfPresent
defaults write com.apple.security.revocation OCSPSufficientPerCert -int 1
defaults write com.apple.security.revocation OCSPStyle -string RequireIfPresent
defaults write com.apple.security.revocation RevocationFirst -string OCSP
echo $(date) "Enable OCSP and CRL certificate checking complete." >> /var/log/GSAlog

#5.7 Disable root user this is off by default and checked by Jamf Pro

#5.8 Disable automatic login done via Profile

#5.9 Require password on wake done via profile

#5.11 Disable Login to Other Active User Sessions done via profile

#5.15 Disable Fast User Switching done via profile

#5.18 Enable SIP on by default
csrutil clear
echo $(date) "Enable SIP on by default complete." >> /var/log/GSAlog

#6.1.3 Disable Guest Account done via profile

#6.1.5 remove guest home folder
 rm -R /Users/Guest
echo $(date) "Removed guest home folder" >> /var/log/GSAlog

#6.3 Disable safari safe file opening
defaults write com.apple.Safari AutoOpenSafeDownloads -boolean no
echo $(date) "Disable safari safe file opening complete." >> /var/log/GSAlog

#7.8 EFI Password Status check via Jamf Pro

# kills auto login for filevault
sudo defaults write /Library/Preferences/com.apple.loginwindow DisableFDEAutoLogin -bool YES

echo $(date) "Hardening script has completed." >> /var/log/GSAlog










