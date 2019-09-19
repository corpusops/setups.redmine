#!/usr/bin/env bash
set -euo pipefail
[ ! -f .env ] && exit 1
source <(grep -v '^#' .env | sed -E 's|^(.+)=(.*)$|: ${\1=\2}; export \1|g')
[[ -z $REDMINE_ORIG_HOST ]] && exit 0
ssh="ssh -p $REDMINE_ORIG_PORT"
if [[ -z ${SKIP_DATA-} ]];then
    rsync -azv --delete -e "$ssh" "$REDMINE_ORIG_HOST:$REDMINE_ORIGDATA_PATH/" "$REDMINE_DATA_PATH/"
fi
cd "$REDMINE_WD"
if [[ -z ${SKIP_STOP-} ]];then
    systemctl stop redmine
    docker-compose stop -t 0
fi
if [[ -z ${SKIP_START-} ]];then
    docker-compose start log db
fi
set -x
cd $REDMINE_WD
( $ssh $REDMINE_ORIG_HOST bash|docker-compose exec -T db sh -c 'mysql --password=$MYSQL_PASSWORD $REDMINE_DB_DATABASE' )<<EOF
set -e
cd $REDMINE_ORIG_WD
docker-compose exec -T db sh -c 'mysqldump --password=$MYSQL_PASSWORD $REDMINE_DB_DATABASE'
EOF
exit 0
if [[ -z ${SKIP_UP-} ]];then
    docker-compose up -d
    docker-compose up -d --force-recreate redmine
fi
# vim:set et sts=4 ts=4 tw=0:
