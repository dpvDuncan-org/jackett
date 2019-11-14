#! /bin/sh
chown -R $PUID:$PGID /config

GROUPNAME=$(getent group $PGID | cut -d: -f1)
USERNAME=$(getent passwd $PUID | cut -d: -f1)

if [ ! $GROUPNAME ]
then
        addgroup -g $PGID jackett
        GROUPNAME=jackett
fi

if [ ! $USERNAME ]
then
        adduser -G $GROUPNAME -u $PUID -D jackett
        USERNAME=jackett
fi

su - $USERNAME -c '/opt/jackett/jackett --NoUpdates'