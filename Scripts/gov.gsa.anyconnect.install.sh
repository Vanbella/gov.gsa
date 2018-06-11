#!/bin/sh

#  gov.gsa.anyconnect.install.sh
#  gov.gsa
#
#  Created by John Graphia on 6/11/18.
#  
# Install components
installer -applyChoiceChangesXML /usr/local/GSAFiles/Cisco_AnyConnect_4.6.01098_06062018/GSA-CAC_choices.xml -pkg /usr/local/GSAFiles/Cisco_AnyConnect_4.6.01098_06062018/AnyConnect.pkg -target /
#
# take a breath
sleep 15
#
# log the install
echo $(date) "Installed Cisco AnyConnect 4.6.01098_06062018" >> /var/log/GSAlog
#
# remove the leftovers
rm -rf /usr/local/GSAFiles/Cisco_AnyConnect_4.6.01098_06062018
#
exit 0

