#!/bin/bash

set -f
DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
RAKE=$(which rake)
cron="0 0 * * * cd "$DIR" && "$RAKE" RAILS_ENV=development rotation"
echo $cron > cron.tmp


crontab cron.tmp
rm cron.tmp

