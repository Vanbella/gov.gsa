#!/bin/bash
#
bddy=/usr/libexec/PlistBuddy
tgt=/Library/Preferences/gov.gsa.sus.plist
#
$bddy -c "add DeferCount integer 0 " $tgt
$bddy -c "add DeferDays integer 7 " $tgt
$bddy -c "add Updates array " $tgt
#
#
for lst in $(softwareupdate -l|sed -e '1,4 d' -e '/*/d' -e 's/ //g')
do
$bddy -c "add Updates:0 string "$lst"" $tgt
#
done
#
UpdCnt=`defaults read /Library/Preferences/gov.gsa.sus Updates|sed -e 's/(//g' -e 's/)//g' -e '/^$/d'|wc -l`
#
#
$bddy -c "add UpdateCount string '$UpdCnt' " $tgt

