#!/bin/bash

source "./jenkins/main.sh"

echo $PATH
which sudo

echo "Deliver Package"
while read line || [[ -n ${line} ]]; do
    if [[ ! "$line" =~ ^#.* ]]; then
        echo $line
		set -x
		cd _book
		tar czf ../build.tar.gz *
		cd ..
		copyAndUnpackFile "build.tar.gz" $line
		rm build.tar.gz
    fi
done < ./jenkins/deploy.conf
echo "Done!"
