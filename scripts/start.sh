#! /bin/sh
chown -R $PUID:$PGID /config

GROUPNAME=$(getent group $PGID | cut -d: -f1)
USERNAME=$(getent passwd $PUID | cut -d: -f1)

if [ ! $GROUPNAME ]
then
        groupadd -g $PGID jackett
        GROUPNAME=jackett
fi

if [ ! $USERNAME ]
then
        useradd -m -G $GROUPNAME -u $PUID jackett
        USERNAME=jackett
fi

su $USERNAME -c '/opt/jackett/jackett --NoUpdates'