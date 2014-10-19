# 配置

## crontab 配置

每10分钟检查一次

*/10 * * * *  cd /data/php_learn/apps/series_update_reminder/ && /usr/bin/php check.php >  /dev/null 2>&1