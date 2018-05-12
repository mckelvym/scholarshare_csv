#!/bin/bash

path="$1"

if [ "$path" == "" ] ; then
    echo "Specify path."
    exit 1
fi

cd "$path"
merge_name=dailyprices.csv
out_name=dailyprices_tmp.csv
out_rss_name=feed.xml
archive_name=dailyprices`date "+%Y%m%d"`.csv
docker run -u $(id -u):$(id -g) -v "$PWD":/data registry.hub.docker.com/mckelvym/scholarshare.price:1.6.1 --merge-file=/data/$merge_name --out-file=/data/$out_name --out-rss-file=/data/$out_rss_name
if [ -s $out_name ] ; then
    mv $out_name $merge_name
    cp -v $merge_name $archive_name

    cd scholarshare_prices && \
	cp ../$out_rss_name . && \
        cp ../$merge_name . && \
        git add -u && \
        git commit -m "Daily update $archive_name" && \
        git push

    head $merge_name
else
    echo "WARN! File was zero size!"
fi
exit
