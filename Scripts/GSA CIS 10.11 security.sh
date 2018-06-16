#!/bin/bash

## created by Ian F Bell 090916  ##
## Modified by IFB  160916  	 ##
## Modified by IFB  101216       ##
## Modified by IFB   0617	 ##
## Modified by IFB 0817      ##
## Last Modified by JFG 06162018 ##
###################################

echo $(date) "Started GSA security script" >> /var/log/GSAlog
# Remove old error log and create a new one.
 rm -f /var/log/GSAlogerrors

echo $(date) >> /var/log/GSAlogerrors
# redirect stderr to a GSA errorlog
2> /var/log/GSAlogerrors
#command 2> /dev/null

sw_vers=$(sw_vers -productVersion)
csrstat=$""
# halt run on anything but 10.11 or higher
if [[ $sw_vers < 10.11.* ]]; then 
osascript -e 'tell app "System Events" to display alert "This script is for OS versions higher than 10.10.x only!"'; exit 1
fi

#Software updates

defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticCheckEnabled -bool TRUE
defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticDownload -bool FALSE

softwareupdate --schedule on

defaults write /Library/Preferences/com.apple.commerce.plist AutoUpdate -bool FALSE

defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist ConfigDataInstall -bool TRUE

defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist CriticalUpdateInstall -bool TRUE

defaults write /Library/Preferences/com.apple.commerce.plist AutoUpdateRestartRequired -bool FALSE

echo $(date) "Software updates set" >> /var/log/GSAlog


# Bluetooth this is a UBE currently. all bluetooth managent is handled by a specific bluetooth policy

#defaults write /Library/Preferences/com.apple.Bluetooth.plist ControllerPowerState -int 0

#killall -HUP blued

#user=$( python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");' )


#user=$( python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");' )
#uuid=$( ioreg -rd1 -c IOPlatformExpertDevice | grep UUID | awk '{ print $3 }' | sed -e s/\"//g )

#defaults write /Users/$user/Library/Preferences/ByHost/com.apple.Bluetooth.$uuid.plist PrefKeyServicesEnabled -int 0
#killall cfprefsd
#echo $(date) "Bluetooth menu bar enabled." >> /var/log/GSAlog

#Screen saver settings
user=$( python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");' )

tlcorner=$( defaults read /Users/$user/Library/Preferences/com.apple.dock wvous-tl-corner )
trcorner=$( defaults read /Users/$user/Library/Preferences/com.apple.dock wvous-tr-corner )
blcorner=$( defaults read /Users/$user/Library/Preferences/com.apple.dock wvous-bl-corner )
brcorner=$( defaults read /Users/$user/Library/Preferences/com.apple.dock wvous-br-corner )

if [ "$tlcorner" = "6" ];
then
sudo -u $user defaults write /Users/$user/Library/Preferences/com.apple.dock wvous-tl-corner -int 1
fi

if [ "$trcorner" = "6" ];
then
sudo -u $user defaults write /Users/$user/Library/Preferences/com.apple.dock wvous-tr-corner -int 1	
fi

if [ "$blcorner" = "6" ];
then
sudo -u $user defaults write /Users/$user/Library/Preferences/com.apple.dock wvous-bl-corner -int 1
fi

if [ "$brcorner" = "6" ];
then
sudo -u $user defaults write /Users/$user/Library/Preferences/com.apple.dock wvous-br-corner -int 1
fi
echo $(date) "Screen Saver Settings completed." >> /var/log/GSAlog

# Disable Remote Apple Events

#systemsetup -setremoteappleevents off

echo $(date) "Remote Apple events set" >> /var/log/GSAlog

# Disable Internet Sharing

defaults write /Library/Preferences/SystemConfiguration/com.apple.nat NAT -dict-add Enabled -int 0

echo $(date) "Internet sharing disabled." >> /var/log/GSAlog

# Disable Screen Sharing

# Check for the Casper casperscreensharing user
echo $(date) " Casper is being used screen sharing is on." >> /var/log/GSAlog

# Kill the service, turned off because of casper being used

#launchctl unload -w /System/Library/LaunchDaemons/com.apple.screensharing.plist 


# Disable the printer sharing service

cupsctl --no-share-printers

echo $(date) "Printer Sharing is turned off " >> /var/log/GSAlog

# Disable for all installed printer objects

lpstat -p | awk ‘{print $2}’| xargs -I{} lpadmin -p {} -o printer-is-shared=false
echo $(date) "Disable for all installed printer objects " >> /var/log/GSAlog


# Remove the existing SSH access group (revert to all user access)
#dseditgroup -o delete -t group com.apple.access_ssh
#echo $(date) " Removed the existing SSH access group " >> /var/log/GSAlog

# Create the access group again anew
#dseditgroup -o create -q com.apple.access_ssh


# Add the Casper Management account (very important!)
#dseditgroup -o edit -a gsajssmanage -t user com.apple.access_ssh

# Add the standard local admin management account
dseditgroup -o edit -a gsa_x -t user com.apple.access_ssh

# Make sure that SSH is enabled
systemsetup -setremotelogin on
echo $(date) " SSH settings complete" >> /var/log/GSAlog

# Script to disable file sharing services

launchctl unload -w /System/Library/LaunchDaemons/com.apple.AppleFileServer.plist
#launchctl unload -w /System/Library/LaunchDaemons/com.apple.smbd.plist #SMB required for the JSS
#echo $(date) " Disabled file services " >> /var/log/GSAlog

# Script to disable Remote Management, we need this for Casper

#/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate -configure -access -off
#echo $(date) " Remote Management disabled " >> /var/log/GSAlog

#gate keeper enable set via profiles 

#cpctl --master-enable
#echo $(date) " Gate keeper set. " >> /var/log/GSAlog

# Enable System Firewall 

/usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
/usr/libexec/ApplicationFirewall/socketfilterfw --setallowsigned on

echo $(date) " Firewall set " >> /var/log/GSAlog

# Enable Firewall Stealth Mode

/usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
echo $(date) " Stealth mode set " >> /var/log/GSAlog

#Disable Bonjour

defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool YES
echo $(date) " Bonjour disabled. " >> /var/log/GSAlog


#Set WiFi menu bar

user=$( python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");' )

#defaults write /Users/$user/Library/Preferences/com.apple.systemuiserver.plist menuExtras -array-add "/System/Library/CoreServices/Menu Extras/AirPort.menu"
#echo $(date) " WiFi menu bar added " >> /var/log/GSAlog

#Disable HTTP service
apachectl stop
defaults write /System/Library/LaunchDaemons/org.apache.httpd Disabled -bool true
echo $(date) " Disabled HTTP services " >> /var/log/GSAlog

#Disable FTP service
launchctl unload -w /System/Library/LaunchDaemons/ftp.plist
echo $(date) " Disabled FTP services " >> /var/log/GSAlog

# NFS Disable
nfsd disable
rm /etc/export
echo $(date) " Disabled NFS services " >> /var/log/GSAlog

#Secure System Wide folders
find /Applications -type d -exec chmod -R 755 {} + 2> /dev/null
find /Applications -type d -exec chown root:wheel {} + 2> /dev/null
echo $(date) " Secured System folders " >> /var/log/GSAlog

# Secure Open Library Folders
find /Library -type d -exec chmod -R o-w {} +
echo $(date) " Secured open folders " >> /var/log/GSAlog

# Disable root user. Send admin password from Casper Policy to make this work.
#dsenableroot -d -u Administrator -p $4 -r $4
#echo $(date) " Disabled root " >> /var/log/GSAlog

# Script to disable Auto Logging In handled by profile
#defaults delete /Library/Preferences/com.apple.loginwindow autoLoginUser
#echo $(date) " Disabled Auto Login " >> /var/log/GSAlog

#Require Password on Wake
####This is done by Policy not by script

#Disable Admin login to user session handled by policy
#security authorizationdb write system.login.screensaver authenticate-session-user
#echo $(date) " Disabled Admin login to user session " >> /var/log/GSAlog

# Disable fast user switching handled by policy
#defaults write /Library/Preferences/.GlobalPreferences MultipleSessionEnabled -bool NO
#echo $(date) " Disable fast user switching " >> /var/log/GSAlog

#System Integrity Protection status check
if [[ $sw_vers > *10.10* ]]; then csrstat=$( csrutil status ); fi

if [ "$csrstat" = "System Integrity Protection status: enabled." ]; then 
echo $(date) $csrstat >> /var/log/GSAlog
fi

#Check for PIV tokend
check=$(ls -l /Library/Security/tokend | awk  '$9 ~ /PIV/ {print $9}')
if [ "$check" = "PIV.tokend" ]; then 
	echo $(date) $check "was found." >> /var/log/GSAlog
else 
	echo $(date) "No PIV tokend was found." >> /var/log/GSAlog
fi	
# Disable Guest User account login done with a Policy 

#defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool NO
#echo $(date) " Guest user login disabled " >> /var/log/GSAlog

# Disable Safari's automatic opening of "safe" files
defaults write com.apple.Safari AutoOpenSafeDownloads -boolean no
echo $(date) " Disabled Safari's automatic opening of "safe" files " >> /var/log/GSAlog

# set time server 
systemsetup -setnetworktimeserver time.gsa.gov

#EFI Firmware password check.

check=$( /usr/sbin/firmwarepasswd -mode )

if [ "$check" = "Mode: none" ]; then
	echo $(date) " EFI firmware password = Disabled " >> /var/log/GSAlog
elif [ "$check" = "Mode: command" ]; then
	echo $(date) " EFI firmware password = Command " >> /var/log/GSAlog
elif [ "$check" = "Mode: full" ]; then
	echo $(date) " EFI firmware password = Full " >> /var/log/GSAlog
fi
# kills auto login for filevault
sudo defaults write /Library/Preferences/com.apple.loginwindow DisableFDEAutoLogin -bool YES

echo $(date) " Finished applying security scripts. " >> /var/log/GSAlog
