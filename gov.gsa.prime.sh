#!/bin/sh

#  gov.gsa.prime.sh
#  gov.gsa
#
#  Created by John Graphia on 4/29/18.
#  
for p in {1..100}
do
openssl prime -generate -bits 64
done
exit 0
