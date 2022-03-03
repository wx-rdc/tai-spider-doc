#!/bin/sh

copyAndUnpackFile() {
	SOURCE=$1
	ARGS=$2
	
	params=(${ARGS//:/ })
	HOST=${params[0]}
	PORT="22"
	USER=${params[1]}
	TARGETPATH=${params[2]}

	hostParams=(${HOST//@/ })
	if [ ! -z ${hostParams[1]} ]; then
		HOST=${hostParams[0]}
		PORT=${hostParams[1]}
	fi

	echo "Host: $HOST"
	echo "Port: $PORT"
	echo "User: $USER"
	echo "Path: $TARGETPATH"

	scp -P $PORT $SOURCE root@$HOST:$TARGETPATH

    ssh -Tq -p $PORT root@$HOST 'bash -s' < ./jenkins/unpack.sh $USER $SOURCE $TARGETPATH
}

restart() {
    ARGS=$1

	params=(${ARGS//:/ })
	HOST=${params[0]}
	PORT="22"
	USER=${params[1]}
	TARGETPATH=${params[2]}

	hostParams=(${HOST//@/ })
	if [ ! -z ${hostParams[1]} ]; then
		HOST=${hostParams[0]}
		PORT=${hostParams[1]}
	fi

	echo "Host: $HOST"
	echo "Port: $PORT"
	echo "User: $USER"
	echo "Path: $TARGETPATH"

    ssh -Tq -p $PORT root@$HOST 'bash -s' < ./jenkins/restart.sh $USER $TARGETPATH
}

