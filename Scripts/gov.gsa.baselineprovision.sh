#!/bin/sh

#  gov.gsa.baselineprovision.sh
#  gov.gsa
#
#  Created by John Graphia on 5/31/18.
#  Logging
LOGPATH='/private/var/log'
LOGFILE=$LOGPATH/GSA-Provision$(date +%m.%d.%Y.%H:%M).log
VERSION=.1
#
# Variables
jbinpth=/usr/local/bin/jamf
#
# $jbinpth policy -id 00 --forceNoRecon
#
# 10.12 CIS Benchmark
$jbinpth policy -id 93 --forceNoRecon #
# Install Baseline Applications
$jbinpth policy -id 37 --forceNoRecon # AnyConnect
echo "Any Connect Installed" >> $logfile
#
$jbinpth policy -id 38 --forceNoRecon # Apple HP Print Drivers
echo "Apple HP Print Drivers Installed" >> $logfile
$jbinpth policy -id 289 --forceNoRecon # Chrome
echo "Chrome Installed" >> $logfile
$jbinpth policy -id 36 --forceNoRecon # Jabber
echo "Jabber Installed" >> $logfile
$jbinpth policy -id 105--forceNoRecon # VLC
echo "VLC Installed" >> $logfile
$jbinpth policy -id 292 --forceNoRecon # VMWare Horizon
echo "VMWare Horizon Installed" >> $logfile
#
# Install CDM/SEC components
$jbinpth policy -id 63 --forceNoRecon # Policy Banner
echo "Policy Banner Installed" >> $logfile
$jbinpth policy -id 282 --forceNoRecon # FireEye HX
echo "FireEye HX Installed" >> $logfile
$jbinpth policy -id 283 --forceNoRecon # ForeScout Secure Connector
echo "ForeScout Secure Connector Installed" >> $logfile
$jbinpth policy -id 285 --forceNoRecon # Nessus
echo "Nessus Installed" >> $logfile
$jbinpth policy -id 180 --forceNoRecon # Cylance
echo "Cylance Installed" >> $logfile
$jbinpth policy -id 284 --forceNoRecon # BigFix
echo "BigFix Installed" >> $logfile
#
exit 0
#


