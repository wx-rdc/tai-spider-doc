#!/bin/bash

USER=$1
PATH=$2

echo -n "Restart Tai Server"
/bin/su - $USER -c "cd $PATH; npm run stop"
/bin/su - $USER -c "cd $PATH; npm run start"
echo " OK!"
