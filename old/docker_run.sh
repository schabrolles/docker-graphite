[ ! -d /var/lib/graphite/storage/whisper ] && sudo mkdir -p /var/lib/graphite/storage/whisper
docker run -d --name graphite -h graphite -p 2003:2003 -v /var/lib/graphite/storage/whisper:/opt/graphite/storage/whisper schabrolles/graphite_ppc64le
#docker run -ti --name graphite -h graphite -p 9090:8080 -p 2003:2003 -v /var/lib/graphite/storage/whisper:/opt/graphite/storage/whisper schabrolles/graphite_ppc64le /bin/bash
