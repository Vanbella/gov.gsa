#!/bin/sh

#  gov.gsa.sus.resetcounters.sh
#  gov.gsa
#
#  Created by John Graphia on 5/25/18.
#  
#################################################################
bddy=/usr/libexec/PlistBuddy
tgt=/Library/Preferences/gov.gsa.sus.plist
#################################################################
# Reset Counters
##############################
$bddy -c "delete DeferCount" $tgt &> /dev/null
$bddy -c "delete DeferDays" $tgt &> /dev/null
##############################
