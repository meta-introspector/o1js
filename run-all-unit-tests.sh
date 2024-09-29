#!/bin/bash
#set +e
set -x
export OUTPUT_DIR="/tmp/perf"
#rm -rf /tmp/perf/ 
export NODE_OUTPUT_DIR="${OUTPUT_DIR}/node"
export CLINIC_OUTPUT_DIR="${OUTPUT_DIR}/clinic"
export NO_INSIGHT=true
export NODE_OPTIONS="--experimental-vm-modules  --perf-basic-prof --enable-source-maps --stack-trace-limit=1000 --report-dir $NODE_OUTPUT_DIR    --perf-prof-unwinding-info --perf-prof"
export NO_INSIGHT=true
#--experimental-test-coverage --test-reporter tap
export NODEOPT1="--test"
# setup perf permissions
echo 2 > /proc/sys/kernel/perf_event_paranoid || echo run as root!


## hacks to update the docker image
ls -latr /opt/introspector/test/package.json /app/package.json
md5sum /opt/introspector/test/package.json /app/package.json
cp /opt/introspector/test/package.json /app/
cp /opt/introspector/test/*.json /app/ || echo ok
cp /opt/introspector/test/*.yaml /app/ || echo ok
cp /opt/introspector/test/*.yml /app/ || echo ok
rm /app/jest.config.js || echo ok
ls -latr /opt/introspector/test/package.json /app/package.json
md5sum /opt/introspector/test/package.json /app/package.json
######

mkdir -p "${OUTPUT_DIR}" || echo ok
mkdir "${NODE_OUTPUT_DIR}"
mkdir "${CLINIC_OUTPUT_DIR}"
pnpm install -g clinic
cd /app/
export SOURCE_DIR=/app/src
run_test() {
    testname=$1
    export MULTIPLE="${testname}"
    export perfdata="${testname}.perf.data"
    OUTPUT_DIR2="${OUTPUT_DIR}$testname/"
    mkdir -p "${OUTPUT_DIR2}clinic/"
    mkdir -p "${OUTPUT_DIR2}log/"
#    mkdir -p "${OUTPUT_DIR2}coverage/"

    echo plain test
    node  ${NODEOPT1} ${MULTIPLE}

    #echo run again for capture
    #echo node  "${NODEOPT1}"   "${MULTIPLE}"
    #node  "${NODEOPT1}"   "${MULTIPLE}" > "${testname}.report_plain.txt" 2>&1
    
    echo run clinic flame -- node "${NODEOPT1}"   "${MULTIPLE}"
    clinic flame -- node "${NODEOPT1}"   "${MULTIPLE}" > "${OUTPUT_DIR2}clinic-flame.txt" 2>&1
    echo $?
    cat "${OUTPUT_DIR2}clinic-flame.txt"

    echo clinic doctor -- node "${NODEOPT1}"    "${MULTIPLE}"
    clinic doctor -- node "${NODEOPT1}"    "${MULTIPLE}" > "${OUTPUT_DIR2}clinic-doctor.txt" 2>&1
    echo $?    
    cat "${OUTPUT_DIR2}clinic-doctor.txt"

    echo clinic bubbleprof -- node "${NODEOPT1}"  "${MULTIPLE}" 
    clinic bubbleprof -- node "${NODEOPT1}"  "${MULTIPLE}" > "${OUTPUT_DIR2}clinic-bubble.txt" 2>&1
    echo $?
    cat "${OUTPUT_DIR2}clinic-bubble.txt"
    
    #clinic heapprofiler --collect-only --open=false -- node "${NODEOPT1}"   "${MULTIPLE}"  | tee "${OUTPUT_DIR2}clinic-heap.txt" 2>&1

    echo run perf
    perf record -g -o "${testname}.perf.data" -F 999 --call-graph dwarf node  "${NODEOPT1}"   "${MULTIPLE}" > "${testname}.reportout.txt" 2>&1
    perf archive "${testname}.perf.data"
    perf report -i "${perfdata}" --verbose --stdio --header > "${perfdata}.header.txt" 2>&1
    cat "${perfdata}.header.txt"
    perf report -i "${perfdata}" --verbose --stdio --stats > "${perfdata}.stats.txt" 2>&1
    cat "${perfdata}.stats.txt"
    perf script -F +pid -i "${perfdata}"  > "${perfdata}.script.txt" 2>&1
    cat "${perfdata}.script.txt"
    perf report --stdio -i "${perfdata}"  > "${perfdata}.report.txt" 2>&1
    cat "${perfdata}.report.txt"
    ls -latr jit*.dump
    rm -r jit*.dump    
    mv ${testname}.perf.data "${OUTPUT_DIR2}perf_data"
    mv "${testname}.*.txt" "${OUTPUT_DIR2}perf_data"
    mv .clinic/* "${OUTPUT_DIR2}clinic/"
#    mv coverage/* "${OUTPUT_DIR2}coverage/" no jest, no coverage right now
    mv  *.log "${OUTPUT_DIR2}log/"    
    du -s "${OUTPUT_DIR2}"
    find "${OUTPUT_DIR2}"
    ls -latr "${OUTPUT_DIR2}"
}

for testname in $TESTS;
do
    export MULTIPLE1="${testname}"
    export perfdata1="${testname}.perf.data"
    export OUTPUT_DIR3="${OUTPUT_DIR}$testname/"
    #results=$(run_test $testname)
    run_test $testname | tee "${OUTPUT_DIR3}stdout.txt" 2>&1
    #echo $results > "${OUTPUT_DIR3}stdout.txt"
    tar -czvf "${OUTPUT_DIR}${testname}.tgz" "${OUTPUT_DIR3}"
    # remove the intermediates for space saving.
    if [ $REMOVE_DATA == "CLEAN" ]; then
       rm -rf "${OUTPUT_DIR3}/"
    fi
    ls -latr "${OUTPUT_DIR}"
done

tar -czf /tmp/perf.data.tar.gz /tmp/perf/*


