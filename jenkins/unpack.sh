#!/bin/bash

USER=$1
TARFILE=$2
PATH=$3

echo -n "Unpack "$TARFILE
/bin/su - $USER -c "tar xzf $PATH/$TARFILE -C $PATH"
/bin/su - $USER -c "rm $PATH/$TARFILE"
echo " OK!"
