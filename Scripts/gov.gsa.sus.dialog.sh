#!/bin/sh

#  gov.gsa.sus.dialog.sh
#  gov.gsa
#
#  Created by John Graphia on 7/12/18.
#  
#################################################################
helper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
bddy=/usr/libexec/PlistBuddy
tgt=/Library/Preferences/com.apple.SoftwareUpdate.plist
sus=/Library/Preferences/gov.gsa.sus.plist
icon="/usr/local/GSAfiles/GSA-logo_blue.icns"
lrua=`$bddy -c "print :LastRecommendedUpdatesAvailable" $tgt`
lua=`$bddy -c "print :LastUpdatesAvailable" $tgt`
#################################################################

#################################################################
show_deferexpired () {
heading="Apple Security Update Deferal Expired"
final="The Software Update deferal period has expired. Apple Security Updates will be installed and your system rebooted in 15 minutes. You may click Install to perform the updates immediately."
result=`"$helper" -windowType hud -lockHUD -title "$heading" -alignHeading center -icon "$icon" -iconSize 96 -description "$final" -button1 "Install" -timeout 900 -countdown -alignCountdown left`
# User clicked Install button1
if [ $result -eq 0 ]; then
echo $(date) "User Clicked Install" >> /var/log/GSAlog
install_updates
echo $(date) "Install Updates" >> /var/log/GSAlog
reboot_timer
echo $(date) "Reboot Timer" >> /var/log/GSAlog
else
echo $(date) "Counter Timed Out" >> /var/log/GSAlog
install_updates
echo $(date) "Install Updates" >> /var/log/GSAlog
reboot_timer
echo $(date) "Reboot Timer" >> /var/log/GSAlog
fi
}
#################################################################

#################################################################
show_userinstall () {
heading="Apple Security Software Updates Available"
description="There are "
updcount=`/usr/bin/defaults read $tgt LastRecommendedUpdatesAvailable `
d2="Apple Security updates for your machine. If you do nothing this window will timeout in 8 hours and will decrement 1 day of deferment."
d3="You can defer for"
d4=`/usr/bin/defaults read $sus DeferDays `
d5="more days. Updates will be force installed on the final day and your machine will be rebooted. Please use Self-Service to perform updates and restart at your convenience."
result=`"$helper" -windowType hud -lockHUD -title "$heading" -alignHeading center -icon "$icon" -iconSize 96 -description "$description$updcount $d2 $d3 $d4 $d5" -button1 "Defer" -button2 "Install" -timeout 28800 -countdown -alignCountdown left`
if [ $result -eq 0 ]; then
# User clicked Defer button1
### Increment Defer Counter
echo $(date) "User Clicked Defer" >> /var/log/GSAlog
modify_counters
echo $(date) "Modify Counters" >> /var/log/GSAlog
elif [ $result -eq 2 ]; then
# User clicked Install button2
echo $(date) "User Clicked Install" >> /var/log/GSAlog
install_updates
echo $(date) "Install Updates" >> /var/log/GSAlog
reboot_timer
echo $(date) "Reboot Timer" >> /var/log/GSAlog
else
echo $(date) "Counter Timed Out" >> /var/log/GSAlog
modify_counters
fi
}
#################################################################
# Install Updates
install_updates () {
heading="Apple Security Updates are being installed"
patch="Install will begin in 30 seconds. Please do not Shutdown, Restart or Sleep your machine. Please save your work and quit all applications."
result=`"$helper" -windowType hud -lockHUD -title "$heading" -alignHeading center -icon "$icon" -iconSize 96 -description "$patch" -timeout 30 -countdown -alignCountdown left `
if [ $result -eq 243 ]; then
#caffeinate -d -i -m
echo $(date) "Install Updates Counter Timed Out" >> /var/log/GSAlog
softwareupdate -i -a
$bddy -c "set :DeferCount 0" $sus &> /dev/null
$bddy -c "set :DeferDays 8" $sus &> /dev/null
fi
}
#################################################################

#################################################################
reboot_timer (){
shutdown -r +16
echo Reboot >> /var/log/GSAlog
heading="Updates Applied, Reboot in 15 minutes"
reboot="Apple Security Updates have been installed. Your machine will automatically reboot in 15 minutes or you may reboot via the Apple Menu. Please save your work and quit all applications in preparation for a full reboot."
result=`"$helper" -windowType hud -lockHUD -title "$heading" -alignHeading center -icon "$icon" -iconSize 96 -description "$reboot" -button1 "Reboot Now" -timeout 900 -countdown -alignCountdown left`
# User clicked Reboot Now button1
if [ $result -eq 0 ]; then
echo $(date) "User Clicked Reboot Now" >> /var/log/GSAlog
shutdown -r now
fi
}
#################################################################
# DeferCount and DeferDays code
#################################################################
modify_counters () {
dfrcnt=`$bddy -c "print :DeferCount" $sus` &> /dev/null
inc=$(($dfrcnt+1))
$bddy -c "set :DeferCount $inc " $sus &> /dev/null
echo $(date) "Increment DeferCount $inc "  >> /var/log/GSAlog
dec=$(($dfrday-1))
$bddy -c "set :DeferDays $dec " $sus &> /dev/null
echo $(date) "Decrement DeferDays $dec " >> /var/log/GSAlog
}
#################################################################
# Start
# If /Library/Preferences/gov.gsa.sus.plist does not exist, create it
if [ ! -f "$sus" ]; then
echo $(date) "Create-gov.gsa.sus" >> /var/log/GSAlog
$bddy -c "add DeferDays integer 8 " $sus &> /dev/null
echo $(date) "DeferDays 8" >> /var/log/GSAlog
# Give the user 8 days to defer update installs
$bddy -c "add DeferCount integer 0 " $sus &> /dev/null
echo $(date) "DeferCount 0" >> /var/log/GSAlog
# Count how many times the user defers
$bddy -c "delete Updates array " $sus &> /dev/null
$bddy -c "delete Updates" $sus &> /dev/null
else
echo $(date) "gov.gsa.sus Exists" >> /var/log/GSAlog
fi
#################################################################
# If there are no updates listed in :LastRecommendedUpdatesAvailable exit
#################################################################
if [[ $lrua -lt 1 ]]; then
echo $(date) "NoUpdatesNeeded" >> /var/log/GSAlog
exit 0
else
echo $(date) "UpdatesNeeded" >> /var/log/GSAlog
fi
#################################################################
# If Defer Day counter is 0 force patch
#################################################################
dfrday=`$bddy -c "print :DeferDays" $sus`
if [[ $dfrday -eq 0 ]] ; then
show_deferexpired
echo $(date) "DeferDaysExpired" >> /var/log/GSAlog
install_updates
reboot_timer
else
echo $(date) "DeferDaysNotExpired" >> /var/log/GSAlog
show_userinstall
#modify_counters
fi
exit 0



