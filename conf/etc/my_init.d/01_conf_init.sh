#!/bin/bash

conf_dir=/etc/graphite-statsd/conf

# auto setup graphite with default configs if /opt/graphite is missing
# needed for the use case when a docker host volume is mounted at an of the following:
#  - /opt/graphite
#  - /opt/graphite/conf
#  - /opt/graphite/webapp/graphite
graphite_dir_contents=$(find /opt/graphite -mindepth 1 -print -quit)
graphite_conf_dir_contents=$(find /opt/graphite/conf -mindepth 1 -print -quit)
graphite_webapp_dir_contents=$(find /opt/graphite/webapp/graphite -mindepth 1 -print -quit)
graphite_storage_dir_contents=$(find /opt/graphite/storage -mindepth 1 -print -quit)
if [[ -z $graphite_dir_contents ]]; then
  git clone -b 0.9.15 --depth 1 https://github.com/graphite-project/graphite-web.git /usr/local/src/graphite-web
  cd /usr/local/src/graphite-web && python ./setup.py install
fi
if [[ -z $graphite_storage_dir_contents ]]; then
  /usr/local/bin/django_admin_init.exp
  cd $graphite_webapp_dir_contents && python manage.py syncdb --noinput
fi
if [[ -z $graphite_conf_dir_contents ]]; then
  cp -R $conf_dir/opt/graphite/conf/*.conf /opt/graphite/conf/
fi
if [[ -z $graphite_webapp_dir_contents ]]; then
  cp $conf_dir/opt/graphite/webapp/graphite/local_settings.py /opt/graphite/webapp/graphite/local_settings.py
fi

# init graphitedb if empty.
graphitedb_size=$(ls -s /opt/graphite/storage/graphite.db | awk '{ print $1 }')
echo $graphitedb_size
[[ $graphitedb_size -eq 0 ]] && python /opt/graphite/webapp/graphite/manage.py syncdb --noinput

# Start all deamon
/etc/service/carbon/run &
/etc/service/carbon-aggregator/run &
/etc/service/graphite/run &
/etc/service/nginx/run &
sleep 1 && tail -f /var/log/nginx/error.log -f /var/log/nginx/access.log
