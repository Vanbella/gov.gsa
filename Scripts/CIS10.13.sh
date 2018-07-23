#!/bin/bash
#  10.13.x CIS implementation script.
# Global Variables
##############################################
user=`who|grep console|awk '{print $1}'`
hardwareUUID=$(/usr/sbin/system_profiler SPHardwareDataType | grep "Hardware UUID" | awk -F ": " '{print $2}' | xargs)
##############################################
# 1.2 Enable Auto Update
defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticCheckEnabled -bool TRUE
defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticDownload -bool TRUE
softwareupdate --schedule on
echo $(date) "1.2 Enable Auto Update enabled" >> /var/log/GSAlog
##############################################
# 1.3 Enable App Update Installs
defaults write /Library/Preferences/com.apple.commerce.plist AutoUpdate -bool FALSE
echo $(date) "1.3 Enable App Update Installs completed." >> /var/log/GSAlog
##############################################
# 1.4 Enable system and security installs
defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist ConfigDataInstall -bool TRUE
defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist CriticalUpdateInstall -bool TRUE
echo $(date) "1.4 Enable System & Security installs completed." >> /var/log/GSAlog
##############################################
# 1.5 Enable OS X Update Installs
defaults write /Library/Preferences/com.apple.commerce.plist AutoUpdateRestartRequired -bool FALSE
echo $(date) "1.5 Enable OS X Update Installs completed." >> /var/log/GSAlog
##############################################
# 2.1.1 Turn off Bluetooth, if no paired devices. 
echo $(date) "2.1.1 Turn off Bluetooth, if no paired devices. Currently UBE." >> /var/log/GSAlog
##############################################
# 2.1.3 Show Bluetooth Status in the Menu Bar
# Also exists in "Add Bluetooth to Menu Bar" policy (Once every week/Check-in/All Comp/All User)
btmn=$(grep "Bluetooth.menu" /Users/$user/Library/Preferences/com.apple.systemuiserver.plist -c)
if [ $btmn == 0 ]; then
open '/System/Library/CoreServices/Menu Extras/Bluetooth.menu'
fi
echo $(date) "Show Bluetooth Status in the Menu Bar completed" >> /var/log/GSAlog
##############################################
# 2.2.1 Enable Set time and date automatically
/bin/cat > /etc/ntp.conf << 'NEW_NTP_CONF'
server ent.ds.gsa.gov
server time.nist.gov
server time.apple.com
NEW_NTP_CONF
echo $(date) "2.2.1 Enable Set time and date automatically completed." >> /var/log/GSAlog
##############################################
# 2.2.2 Time set within appropriate limits
# Get the current time drift. We're looking for between -270 and 270 seconds.
# Convert negative to positive numbers for easier processing later.
drift=$( ntpdate -svd time.gsa.gov | egrep offset | sed 's/-//g' )
# Are we out of sync? Use bc as we're dealing with floating point numbers
if (( $(bc <<< "$drift <= 270") )); then
ntpd -g -x -q
fi
echo $(date) "2.2.2 Time set within appropriate limits completed." >> /var/log/GSAlog
##############################################
# 2.2.3 Restrict NTP server to loopback interface - Incomplete
restrictNTP=$(cat /etc/ntp-restrict.conf | grep -c "restrict lo")
if [ "$restrictNTP" = "0" ]; then
cp /etc/ntp-restrict.conf /etc/ntp-restrict_old.conf
echo -n "restrict lo interface ignore wildcard interface listen lo" >> /etc/ntp-restrict.conf
echo $(date) "2.2.3 Restrict NTP server to loopback interface completed" 
##############################################
# 2.3.1 Set an inactivity interval of 20 mins or less for the screen saver (both LoginWindow and UserLand)
screenSaverTime="$(defaults read /Users/"$currentUser"/Library/Preferences/ByHost/com.apple.screensaver."$hardwareUUID" idleTime)"
if [ "$screenSaverTime" -le "1200" ]; then
echo $(date) "2.3.1 Screensaver Inactivity Set" | tee -a "$logFile"; else
defaults write /Users/"$currentUser"/Library/Preferences/ByHost/com.apple.screensaver."$hardwareUUID".plist idleTime -int 1200
echo $(date) "2.3.1 Set an inactivity interval of 20 mins or less for the screen saver (both LoginWindow and UserLand) completed"
##############################################
# 2.3.2 Secure screen saver corners
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
echo $(date) "2.3.3 Verify Display Sleep is set to a value larger than the Screen Saver. Config Profile "Energey Savings" Desktop/Laptop(Bat&AC) 15 mins" >> /var/log/GSAlog
##############################################
# 2.3.4 Set a Screen Corner to Start Screen Saver - Exception, 3 methods provided
# 1. Apple Menu "Lock Screen" 2. Key sequence of ^+command+q 3. Menubar / NoMAD "Lock Screen"
echo $(date) "2.3.4 Set a Screen Corner to Start Screen Saver - Exception, 3 methods provided" >> /var/log/GSAlog
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
screenSharing=$(defaults read /System/Library/LaunchDaemons/com.apple.screensharing Disabled)
if [ "$screenSharing" = "1" ]; then
 echo $(date) "2.4.3 Screen Sharing Disabled"; else
defaults write /System/Library/LaunchDaemons/com.apple.screensharing Disabled -bool true
echo $(date) "2.4.3 Disable Screen Sharing completed"
##############################################
# 2.4.4 Disable the printer sharing service
cupsctl --no-share-printers
# Disable for all installed printer objects
# lpstat -p | awk '{print $2}'| xargs -I{} lpadmin -p {} -o printer-is-shared=false
# Line above does nothing
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
launchctl unload -w /System/Library/LaunchDaemons/com.apple.ODSAgent.plist'
echo $(date) "2.4.6 Disable DVD & CD Sharing completed" >> /var/log/GSAlog
##############################################
# 2.4.7 Disable Bluetooth Sharing
btshr=$(/usr/libexec/PlistBuddy -c "print :PrefKeyServicesEnabled"  /Users/"$user"/Library/Preferences/ByHost/com.apple.Bluetooth."$hardwareUUID".plist)
if [ "$btshr" = "true" ]; then
/usr/libexec/PlistBuddy -c "Delete :PrefKeyServicesEnabled"  /Users/"$user"/Library/Preferences/ByHost/com.apple.Bluetooth."$hardwareUUID".plist
/usr/libexec/PlistBuddy -c "Add :PrefKeyServicesEnabled bool false"  /Users/"$user"/Library/Preferences/ByHost/com.apple.Bluetooth."$hardwareUUID".plist
killall cfprefsd
# Possibly do this at conclusion?
fi
echo $(date) "2.4.7 Disable Bluetooth Sharing completed" >> /var/log/GSAlog
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
echo $(date) "2.5.1 Disable "wake for network access" - Provided via Config Profile - Energy Savings." >> /var/log/GSAlog
##############################################
# 2.5.2 Disable sleeping the computer when connected to power - Config Profile - Energy Savings
echo $(date) "2.5.2 Disable sleeping the computer when connected to power - Config Profile - Energy Savings" >> /var/log/GSAlog
##############################################
# 2.6.1 Enable FileVault - FileVault is enabled via Local Support during provisioning time per the Mac Setup SOP. FV configuration is centrally managed via JAMFPro/JSS. Configuration provided as requested
echo $(date) "2.6.1 Enable FileVault - FileVault is enabled via Local Support during provisioning time per the Mac Setup SOP. FV configuration is centrally managed via JAMFPro/JSS. Configuration provided as requested" >> /var/log/GSAlog
##############################################
# 2.6.2 Enable Gatekeeper - Config Profile - GSA Security
echo $(date) "2.6.2 Enable Gatekeeper - Config Profile - GSA Security" >> /var/log/GSAlog
##############################################
# 2.6.3 Enable Firewall - Config Profile - GSA Security
echo $(date) "2.6.3 Enable Firewall - Config Profile - GSA Security" >> /var/log/GSAlog
##############################################
# 2.6.4 Enable Firewall - Config Profile - GSA Security
echo $(date) "2.6.4 Enable Firewall - Config Profile - GSA Security" >> /var/log/GSAlog
##############################################
# 2.6.5 Review Application Firewall Rules
appsInBnd=`/usr/libexec/ApplicationFirewall/socketfilterfw --listapps|sed '/^$/d'`
echo $(date) "2.6.5 Review Application Firewall Rules" >> /var/log/GSAlog
echo $date $appsInBnd >> /var/log/GSAlog
##############################################
# 2.6.6 Enable Location Services - Disabled via Config Profile - GSA Settings-Custom - Incomplete
# ps -A|grep locationd|grep -v grep|awk '{print $3,$4}'
##############################################
# 2.6.7 Monitor Location Services Access
##############################################
# 2.7.1-5 iCloud Configuration - Config Profile - GSA system preference settings
echo $(date) "2.7.1-5 iCloud Configuration - Config Profile - GSA system preference settings" >> /var/log/GSAlog
##############################################
# 2.8.1 Time Machine Auto-Backup 
/usr/bin/tmutil disable
defaults write /Library/Preferences/com.apple.TimeMachine.plist AutoBackup 0
# defaults write /Library/Preferences/com.apple.TimeMachine.plist DoNotOfferNewDisksForBackup Incomplete
echo $(date) "2.8.1 Time Machine Disabled completed" >> /var/log/GSAlog
##############################################
# 2.9 Pair the remote control infrared receiver if enabled
/usr/bin/defaults write /Library/Preferences/com.apple.driver.AppleIRController DeviceEnabled -bool no
echo $(date) "2.9 Pair the remote control infrared receiver if enabled completed" >> /var/log/GSAlog
##############################################
# 2.10 Enable Secure Keyboard Entry in Terminal.app
defaults write /Users/"$user"/Library/Preferences/com.apple.Terminal SecureKeyboardEntry -bool true
echo $(date) "2.10 Enable Secure Keyboard Entry in Terminal.app completed" >> /var/log/GSAlog
##############################################
# 2.11 Java 6 is not the default Java runtime - Incomplete
##############################################
# 2.12 Securely delete files as needed - Incomplete
##############################################
# 3.1.1 Retain system.log for 90 days or more - GSA requires 180
days="180"
sed -ie 's/ttl=./ttl='$days'/' /etc/asl.conf
killall cfprefsd
echo $(date) "3.1 Configure asl.conf completed." >> /var/log/GSAlog
##############################################
# 3.1.2 Retain appfirewall.log for 90 days or more - GSA requires 180 - Achieved via 3.1.1
##############################################
# 3.1.3 Retain authd.log for 90 days or more - GSA requires 180 - Achieved via 3.1.1
##############################################
# 3.2 Enable security auditing
launchctl load -w /System/Library/LaunchDaemons/com.apple.auditd.plist
echo $(date) "Enable security auditing completed." >> /var/log/GSAlog
##############################################
# 3.3 Configure security auditing flags
flags="lo,ad,fd,fm,-all"
sed -ie 's/^flags\(.*\)/flags:'$flags'/' /etc/security/audit_control
echo $(date) "Configure security auditing flags completed." >> /var/log/GSAlog
##############################################
# 3.4 Enable remote logging for Desktops on trusted networks - Exception allowed line 10
echo $(date) "3.4 Enable remote logging for Desktops on trusted networks - Exception allowed line 10" >> /var/log/GSAlog
##############################################
# 3.5 Retain install.log for 365 or more days - GSA requires 180 - Achieved via 3.1.1
##############################################
# 4.1 Disable Bonjour advertising service
defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool YES
echo $(date) "Disable Bonjour advertising service completed." >> /var/log/GSAlog
##############################################
# 4.2 Enable "Show WiFi Status in Menu Bar"
open /System/Library/CoreServices/Menu\ Extras/AirPort.menu
echo $(date) "Show WiFi Status in Menu Bar completed." >> /var/log/GSAlog
##############################################
# 4.3 Create Network specific locations - Exception allowed
##############################################
# 4.4 Disable HTTP service
apachectl stop
defaults write /System/Library/LaunchDaemons/org.apache.httpd Disabled -bool true
echo $(date) "Disable HTTP service completed." >> /var/log/GSAlog
##############################################
# 4.5 Disable FTP service
launchctl unload -w /System/Library/LaunchDaemons/ftp.plist
echo $(date) "Disable FTP service completed." >> /var/log/GSAlog
##############################################
# 4.6 Disable NFS service
nfsd disable
rm /etc/export
echo $(date) "Disable NFS service completed." >> /var/log/GSAlog
##############################################
# 5.1.1 Secure Home Folders
for userDirs in $( find /Users -mindepth 1 -maxdepth 1 -type d -perm -1 | grep -v "Shared" | grep -v "Guest" ); do chmod -R og-rwx "$userDirs"
	done
 echo $(date) "Secure Home Folders completed." >> /var/log/GSAlog
##############################################
# 5.1.2 Secure System Wide Applications Folder
find /Applications -type d -exec chmod -R 755 {} + 2> /dev/null
find /Applications -type d -exec chown root:wheel {} + 2> /dev/null
echo $(date) "Secure System Wide Applications Folder completed." >> /var/log/GSAlog
##############################################
# 5.1.3 Check System for World Writable Files
for apps in $( find /Applications -iname "*\.app" -type d -perm -2 -ls ); do chmod -R o-w "$apps"
done
echo $(date) "5.1.3 Check System for World Writable Files completed." >> /var/log/GSAlog
##############################################
# 5.1.4 Check Library Folder for World Writable Files
# for libPermissions in $( find /Library -type d -perm -2 -ls | grep -v Caches | grep -v Adobe); do chmod -R o-w "$libPermissions"
done
echo $(date) "Secure Open Library Folders completed." >> /var/log/GSAlog
##############################################
# 5.2.1 Configure Account Lockout Threshold - Incomplete
##############################################
# 5.2.2 Set Minimum Password Length - Incomplete
##############################################
# 5.2.3 Complex Passwords Must Contain an Alphabetic Character - Unscored
##############################################
# 5.2.4 Complex Passwords Must Contain a Numeric Character - Unscored
##############################################
# 5.2.5 Complex Passwords Must Contain a Special Character - Unscored
##############################################
# 5.2.6 Complex Passwords Must Contain Uppercase and Lowercase Letters - Unscored
##############################################
# 5.2.7 Password Age - Incomplete
##############################################
# 5.2.8 Password History - Incomplete
##############################################
# 5.3 Reduce the Sudo Timeout Perios - Incomplete 
##############################################
# 5.4 Automatically Lock the Login Keychain for Inactivity - Exception allowed
##############################################
# 5.5 Ensure Login Keychain is Locked When the Computer Sleeps - Exception allowed
##############################################
# 5.6 Enable OCSP and CRL certificate checking
defaults write com.apple.security.revocation CRLSufficientPerCert -int 1
defaults write com.apple.security.revocation CRLStyle -string RequireIfPresent
defaults write com.apple.security.revocation OCSPSufficientPerCert -int 1
defaults write com.apple.security.revocation OCSPStyle -string RequireIfPresent
defaults write com.apple.security.revocation RevocationFirst -string OCSP
echo $(date) "Enable OCSP and CRL certificate checking complete." >> /var/log/GSAlog
##############################################
#5.7 Do Not Enable the Root account
pwpolicy -disableuser -u root
echo $(date) "5.7 Do Not Enable the Root account completed" >> /var/log/GSAlog
##############################################
#5.8 Disable Automatic Login - Disabled via Config Profile - GSA Login config
##############################################
#5.9 Require Password to Wake the Computer from Sleep or Screensaver - Disabled via Config Profile - GSA Security
##############################################
# 5.10 Require an Administrator Password to Access System-Wide Preferences
adminSysPrefs=$(security authorizationdb read system.preferences 2> /dev/null | grep -A1 shared | grep -E '(true|false)' | grep -c "true")
if [ "$adminSysPrefs" = "1" ]; then
	security authorizationdb read system.preferences > /tmp/system.preferences.plist
	/usr/libexec/PlistBuddy -c "Set :shared false" /tmp/system.preferences.plist
	security authorizationdb write system.preferences < /tmp/system.preferences.plist
 echo $(date) "Require an Administrator Password to Access System-Wide Preferences completed." >> /var/log/GSAlog
##############################################
#5.11 Disable Login to Another User's Active and Locked Session -  "done via profile"???
screensaverGroups=$(grep -c "group=admin,wheel fail_safe" /etc/pam.d/screensaver)
	if [ "$screensaverGroups" = "1" ]; then
			cp /etc/pam.d/screensaver /etc/pam.d/screensaver_old
			sed "s/"group=admin,wheel\ fail_safe"/"group=wheel\ fail_safe"/g" /etc/pam.d/screensaver_old >  /etc/pam.d/screensaver
			chmod 644 /etc/pam.d/screensaver
			chown root:wheel /etc/pam.d/screensaver
echo $(date) "5.11 Disable Login to Another User's Active and Locked Session completed." >> /var/log/GSAlog
##############################################
# 5.12 Create a Custom Mesage for the Login Screen - Provided via Config Profile - GSA Login config
echo $(date) "5.12 Create a Custom Mesage for the Login Screen - Provided via Config Profile - GSA Login config completed." >> /var/log/GSAlog
##############################################
# 5.13 Create a Login Window Banner - 
# Provided via pkg "Policy Banner installer.pkg"
# Provided via policy "Policy Banner"
echo $(date) "5.13 Create a Login Window Banner - Provided via pkg Policy Banner installer.pkg / Provided via policy Policy Banner " >> /var/log/GSAlog
##############################################
# 5.14 Do Not Enter a Password-Related Hint - Disabled via Config Profile - GSA Login config
echo $(date) "5.14 Do Not Enter a Password-Related Hint - Disabled via Config Profile - GSA Login config" >> /var/log/GSAlog
##############################################
#5.15 Disable Fast User Switching - Disabled via Config Profile - GSA Login config
echo $(date) "5.15 Disable Fast User Switching - Disabled via Config Profile - GSA Login config" >> /var/log/GSAlog
##############################################
# 5.16 Secure Individual Keychains and Items - Unscored
##############################################
# 5.18 System Integrity Protection status
csrsts=`csrutil status|awk '{print $5}'`
echo $(date) "System Integrity Protection Status: $csrsts" >> /var/log/GSAlog
##############################################
# 6.1.1 Display Login Window as a Name and Password
echo $(date) "6.1.1 Display Login Window as a Name and Password - Provided via Config Profile - GSA Login config" >> /var/log/GSAlog
##############################################
# 6.1.2 Disable "Show Password Hints"
echo $(date) "6.1.2 Disable Show Password Hints - Provided via Config Profile - GSA Login config" >> /var/log/GSAlog
##############################################
# 6.1.3 Disable Guest Account Login
echo $(date) "6.1.3 Disable Guest Account Login - Disabled via Config Profile - GSA Login config" >> /var/log/GSAlog
##############################################
# 6.1.4 Disable "Allow Guests to Connect to Shared Folders"
afpGuestEnabled=$(defaults read /Library/Preferences/com.apple.AppleFileServer guestAccess)
	smbGuestEnabled=$(defaults read /Library/Preferences/SystemConfiguration/com.apple.smb.server AllowGuestAccess)
	if [ "$afpGuestEnabled" = "0" ] && [ "$smbGuestEnabled" = "0" ]; then
		echo $(date) "6.1.4 Disable Allow Guests to Connect to Shared Folders completed"
	fi
	if [ "$afpGuestEnabled" = "1" ]; then
		defaults write /Library/Preferences/com.apple.AppleFileServer guestAccess -bool no
		echo $(date -u) "6.1.4 remediated" | tee -a "$logFile";
	fi
	if [ "$smbGuestEnabled" = "1" ]; then
		defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server AllowGuestAccess -bool no
		echo $(date -u) "6.1.4 remediated" | tee -a "$logFile";
	fi
echo $(date) "6.1.4 Disable Allow Guests to Connect to Shared Folders completed"
##############################################
# 6.1.5 Remove Guest Home Folder
rm -R /Users/Guest
echo $(date) "6.1.5 Remove Guest Home Folder completed" >> /var/log/GSAlog
##############################################
# 6.2 Turn on Filename Extensions - Exception
echo $(date) "6.2 Turn on Filename Extensions - Exception" >> /var/log/GSAlog
##############################################
# 6.3 Disable safari safe file opening
safariSafe=$(defaults read /Users/"$currentUser"/Library/Preferences/com.apple.Safari AutoOpenSafeDownloads)
if [ "$safariSafe" = "1" ]; then
	defaults write /Users/"$user"/Library/Preferences/com.apple.Safari AutoOpenSafeDownloads -bool false
echo $(date) "6.3 Disable Safari Safe File Opening completed." >> /var/log/GSAlog
##############################################
echo $(date) "10.13 Hardening script has completed." >> /var/log/GSAlog










