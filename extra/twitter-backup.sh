#!/bin/sh
# Simple Twitter backup script
# http://blog.jphpsf.com/2012/05/07/backing-up-your-twitter-account-with-t/

json_key() {
    python -c '
import json
import sys

data = json.load(sys.stdin)

for key in sys.argv[1:]:
    try:
        data = data[key]
    except TypeError:  # This is a list index
        data = data[int(key)]

print(data)' "$@"
}

DROPBOX_PATH=$(json_key personal path < ~/.dropbox/info.json)

export DAY=`date +'%Y-%m-%d'`

echo "Backing up tweets..."
t timeline @paxperscientiam --csv --number 11000 > $DROPBOX_PATH/tweets-$DAY.csv
echo "Backing up retweets..."
t retweets --csv --number 3000 > $DROPBOX_PATH/retweets-$DAY.csv
echo "Backing up favorites..."
t favorites --csv --number 3000 > $DROPBOX_PATH/favorites-$DAY.csv
echo "Backing up DM received..."
t direct_messages --csv --number 3000 > $DROPBOX_PATH/dm_received-$DAY.csv
echo "Backing up DM sent..."
t direct_messages_sent --csv --number 3000 > $DROPBOX_PATH/dm_sent-$DAY.csv
echo "Backing up followings..."
t followings --csv > $DROPBOX_PATH/followings-$DAY.csv

echo -e "\nBacked up the following:"
echo -e "- "`wc -l $DROPBOX_PATH/tweets-$DAY.csv|cut -d" " -f 1`" tweets"
echo -e "- "`wc -l $DROPBOX_PATH/retweets-$DAY.csv|cut -d" " -f 1`" retweets"
echo -e "- "`wc -l $DROPBOX_PATH/favorites-$DAY.csv|cut -d" " -f 1`" favorites"
echo -e "- "`wc -l $DROPBOX_PATH/dm_received-$DAY.csv|cut -d" " -f 1`" DM received"
echo -e "- "`wc -l $DROPBOX_PATH/dm_sent-$DAY.csv|cut -d" " -f 1`" DM sent"
echo -e "- "`wc -l $DROPBOX_PATH/followings-$DAY.csv|cut -d" " -f 1`" followings"

echo -e "\nDone\n"
