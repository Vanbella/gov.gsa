#!/bin/sh

#  gov.gsa.baselineprovision.sh
#  gov.gsa
#
#  Created by John Graphia on 5/31/18.
#  Logging
LOGPATH='/private/var/log/GSALog'
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
$jbinpth policy -id 36 --forceNoRecon # Jabber
$jbinpth policy -id 105--forceNoRecon # VLC
$jbinpth policy -id 292 --forceNoRecon # VMWare Horizon
#
# Install CDM/SEC components
$jbinpth policy -id 63 --forceNoRecon # Policy Banner
$jbinpth policy -id 282 --forceNoRecon # FireEye HX
$jbinpth policy -id 283 --forceNoRecon # ForeScout Secure Connector
$jbinpth policy -id 285 --forceNoRecon # Nessus
$jbinpth policy -id 180 --forceNoRecon # Cylance
$jbinpth policy -id 284 --forceNoRecon # BigFix
#
exit 0
#


