#!/bin/bash

#set | grep .
#find "/app/perf-reporting/"
#ls -latr "/app/perf-reporting/data/"
#ls -latr "/app/perf-reporting/input_data/perf.data.zip"
#unzip "/app/perf-reporting/input_data/perf.data.zip" -d /app/perf-reporting/data/

ls -latr /app/perf-reporting/input_data/ 
find /app/perf-reporting/input_data/

cd /app/perf-reporting/output

if [ -f /app/perf-reporting/scripts/perf-report.sh ] ;
then
   bash -x /app/perf-reporting/scripts/perf-report.sh
fi

if [ ! -f  perf.data ]
then
    unzip /app/perf-reporting/input_data/perf.data.zip
#    unzip /app/perf-reporting/input_data/perf.data.zip
fi

#perf report --verbose --header > header.txt
#perf report --verbose --stats > stats.txt
echo script
perf script -F +pid > perf_script.txt
#perf report --stdio > perf_report.txt


#ls -latr /app/perf-reporting/data/
#find /app/perf-reporting/data/
