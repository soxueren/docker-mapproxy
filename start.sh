#!/bin/bash
USER_ID=`ls -lahn / | grep mapproxy | awk '{print $3}'`
GROUP_ID=`ls -lahn / | grep mapproxy | awk '{print $4}'`
USER_NAME=`ls -lah / | grep mapproxy | awk '{print $3}'`

cd /mapproxy

su $USER_NAME -c "uwsgi --ini uwsgi.conf --daemonize /var/log/uwsgi.log --post-buffering 32768 --buffer-size 32768"
#su $USER_NAME -c "nginx -g daemon off"


