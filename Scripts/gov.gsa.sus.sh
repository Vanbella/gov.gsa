#!/bin/bash
###############################
bddy=/usr/libexec/PlistBuddy
sus=/Library/Preferences/gov.gsa.sus.plist
tgt=/Library/Preferences/com.apple.SoftwareUpdate.plist
###############################
# Cleanup
##############################
$bddy -c "delete Updates array " $sus &> /dev/null
$bddy -c "delete Updates" $sus &> /dev/null
##############################
$bddy -c "add DeferDays integer 8 " $sus &> /dev/null
# Give the user 8 days to defer update installs
$bddy -c "add DeferCount integer 0 " $sus &> /dev/null
# Init DeferCount to 0
exit 0
