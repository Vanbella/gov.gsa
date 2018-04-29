#!/bin/sh

###############################################################################
#
# Name: all-provisioning-base.sh
# Version: 1.4
# Date:  30 Jul 2017
# Modified: 24 Aug 2017 - adding Caffeine to stay awake
#           21 Sep 2017 - removing Google Voice & Video per CISO request
# Author:  Steve Wood (steve.wood@omnicomgroup.com)
# Purpose:  provisioning script used to put base layer of apps on a machine.
#
###############################################################################

## Set global variables

LOGPATH='/private/var/omc/logs'
LOGFILE=$LOGPATH/all-base-provisioning-$(date +%Y%m%d-%H%M).log
VERSION=1.4

## Setup logging
mkdir /private/var/omc
mkdir $LOGPATH
set -xv; exec 1> $LOGFILE 2>&1

#let's stay away
/bin/echo "Loads of Coffee Now!!"
/bin/date
caffeinate -d -i -m -u &
caffeinatepid=$!

######################################################################################
#
#         Tasks that do not require access to the JSS
#
######################################################################################

####
# grab the OS version and Model, we may need it later
####

modelName=`system_profiler SPHardwareDataType | awk -F': ' '/Model Name/{print $NF}'`

######################################################################################
# Dummy package with image date and computer Model
# - this can be used with an ExtensionAttribute to tell us when the machine was last imaged
######################################################################################
/bin/echo "Creating provisioning receipt..."
/bin/date
TODAY=`date +"%Y-%m-%d"`
#touch /Library/Application\ Support/JAMF/Receipts/$modelName_born_on_$TODAY.pkg
defaults write /private/var/omc/com.omnicomgroup.provisioning.plist ProvisionDate -string ${TODAY}

###############################################################################
#
#   S Y S T E M   P R E F E R E N C E S
#
# This section deals with system preference tweaks
#
###############################################################################
/bin/echo "Setting system preferences"
/bin/date

# Disable Time Machine's pop-up message whenever an external drive is plugged in

defaults write /Library/Preferences/com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

### Enable Location Services to set time based on location

## Unload locationd
launchctl unload /System/Library/LaunchDaemons/com.apple.locationd.plist

## Write enabled value to locationd plist
defaults write /var/db/locationd/Library/Preferences/ByHost/com.apple.locationd LocationServicesEnabled -int 1

## Fix Permissions for the locationd folder
chown -R _locationd:_locationd /var/db/locationd

## Reload locationd
launchctl load /System/Library/LaunchDaemons/com.apple.locationd.plist

# enable network time
systemsetup -setusingnetworktime on

# set the time server
systemsetup -setnetworktimeserver time.apple.com

# disable the save window state at logout
/usr/bin/defaults write com.apple.loginwindow 'TALLogoutSavesState' -bool false

###########
#  AFP
###########

# enforce clear text passwords in AFP
/bin/echo "Setting AFP clear text to disabled"
/bin/date
/usr/bin/defaults write com.apple.AppleShareClient "afp_cleartext_allow" 0

# Turn off DS_Store file creation on network volumes
/bin/echo "Turn off DS_Store"
/bin/date
defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.desktopservices \
DSDontWriteNetworkStores true

### time machine off
/bin/echo "Disable Time Machine"
/bin/date
/usr/bin/defaults write com.apple.TimeMachine 'AutoBackup' -bool false

###  Expanded print dialog by default
# <http://hints.macworld.com/article.php?story=20071109163914940>
#
/bin/echo "Expanded print dialog by default"
/bin/date
# expand the print window
defaults write /Library/Preferences/.GlobalPreferences PMPrintingExpandedStateForPrint2 -bool TRUE

##########################################
# /etc/authorization changes
##########################################

security authorizationdb write system.preferences allow
security authorizationdb write system.preferences.datetime allow
security authorizationdb write system.preferences.printing allow
security authorizationdb write system.preferences.energysaver allow
security authorizationdb write system.preferences.network allow
security authorizationdb write system.services.systemconfiguration.network allow

# check for jamf binary
/bin/echo "Checking for JAMF binary"
/bin/date

if [[ "$jamf_binary" == "" ]] && [[ -e "/usr/sbin/jamf" ]] && [[ ! -e "/usr/local/bin/jamf" ]]; then
jamf_binary="/usr/sbin/jamf"
elif [[ "$jamf_binary" == "" ]] && [[ ! -e "/usr/sbin/jamf" ]] && [[ -e "/usr/local/bin/jamf" ]]; then
jamf_binary="/usr/local/bin/jamf"
elif [[ "$jamf_binary" == "" ]] && [[ -e "/usr/sbin/jamf" ]] && [[ -e "/usr/local/bin/jamf" ]]; then
jamf_binary="/usr/local/bin/jamf"
fi

${jamf_binary} flushPolicyHistory
${jamf_binary} recon

sleep 5

### Installing base image software

## Common Resources
/bin/echo "Installing Common Resources"
/bin/date
${jamf_binary} policy -id 24 --forceNoRecon # AnyConnect, dockutil, cocoaDialog, VLC
${jamf_binary} policy -id 120 --forceNoRecon # SwapNetwork



## Internet Plug-Ins
/bin/echo "Installing Internet Plug-ins"
/bin/date
${jamf_binary} policy -id 36 --forceNoRecon #Java, Silverlight

## Printer Drivers
/bin/echo "Installing Printer Drivers"
/bin/date
${jamf_binary} policy -id 94 --forceNoRecon # HP & Xerox drivers from Apple
${jamf_binary} policy -id 623 --forceNoRecon # Canon PS Driver

## Web Browsers
/bin/echo "Installing Web Browsers"
/bin/date
${jamf_binary} policy -id 55 --forceNoRecon # Firefox
${jamf_binary} policy -id 10 --forceNoRecon # Chrome

## Office 2016
/bin/echo "Installing Office 2016"
/bin/date
${jamf_binary} policy -id 104 --forceNoRecon # Full Office Suite

## Skype
/bin/echo "Installing Skype & Skype for Business"
/bin/date
${jamf_binary} policy -id 49 --forceNoRecon # Skype for Biz

#/bin/echo "Installing Apple SWU"
#/bin/date
#/bin/rm /Library/Preferences/com.apple.SoftwareUpdate.plist
#softwareupdate --clear-catalog
#softwareupdate -ia

jamf recon -department "IT"

/bin/echo "Evacuating coffee"
/bin/date
kill "$caffeinatepid"
#shutdown -r now
