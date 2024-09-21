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
    unzip -u /app/perf-reporting/input_data/perf.data.zip
    tar -xzf perf.data.tar.gz
    ls -latr
    find .
    #tar xvf src/lib/provable/test/primitives.test.ts.perf.data.tar.bz2 -C ~/.debug
#    unzip /app/perf-reporting/input_data/perf.data.zip
fi

ls -latr /app/perf-reporting/output/tmp/perf/

mkdir -p ~/.debug

for perfdata in /app/perf-reporting/output/tmp/perf/*.perf.data;
do
    echo $perfdata
    ls -latr ${perfdata}
    tar xvf "${perfdata}.tar.bz2" -C ~/.debug		
    perf report -i $perfdata --verbose --stdio --header > ${perfdata}.header.txt 2>&1
    perf report -i $perfdata --verbose --stdio --stats > ${perfdata}.stats.txt 2>&1
    perf script -F +pid -i $perfdata  > ${perfdata}.script.txt 2>&1
    perf report --stdio -i $perfdata  > ${perfdata}.report.txt 2>&1
    ls -latr ${perfdata}
done

#ls -latr /app/perf-reporting/data/
#find /app/perf-reporting/data/
