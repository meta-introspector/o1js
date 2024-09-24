#!/bin/bash
set +e
export OUTPUT_DIR="/tmp/perf"
export NODE_OUTPUT_DIR="${OUTPUT_DIR}/node"
export CLINIC_OUTPUT_DIR="${OUTPUT_DIR}/clinic"
mkdir "${OUTPUT_DIR}"
mkdir "${NODE_OUTPUT_DIR}"
mkdir "${CLINIC_OUTPUT_DIR}"
export NODE_OPTIONS="--experimental-vm-modules --perf-basic-prof --enable-source-maps --stack-trace-limit=1000 --report-dir $NODE_OUTPUT_DIR    --perf-prof-unwinding-info --perf-prof"
# --trace-events-enabled
#NO_INSIGHT=true clinic doctor -- node --perf-basic-prof --enable-source-maps --stack-trace-limit=1000 ./node_modules/jest-cli/bin/jest.js
#NO_INSIGHT=true clinic flame -- node --perf-basic-prof --enable-source-maps --stack-trace-limit=1000 ./node_modules/jest-cli/bin/jest.js
# May Clinic.js report anonymous usage statistics to improve the tool over time?

#######
#find /app > /tmp/app-files-list.txt
#NO_INSIGHT=true clinic doctor --collect-only --
#node /usr/local/bin/pnpm run test
#./run-jest-tests.sh

#export NO_INSIGHT=true
#npx jest
#clinic doctor -- node ./node_modules/.bin/../jest/bin/jest.js src/lib/provable/test/int.test.ts
echo 2 > /proc/sys/kernel/perf_event_paranoid


# mdupont@mdupont-G470:~/2024/09/20/o1js$ grep PASS report1.txt
# PASS src/lib/provable/test/merkle-list.test.ts (7.118 s)
# PASS src/lib/provable/test/merkle-tree.test.ts (7.297 s)
# PASS src/lib/provable/test/scalar.test.ts (7.623 s)
# PASS src/lib/provable/test/merkle-map.test.ts (7.353 s)
# PASS src/lib/provable/test/provable.test.ts (8.322 s)
# PASS src/lib/provable/test/primitives.test.ts (8.346 s)
# PASS src/lib/provable/test/group.test.ts (8.371 s)
# PASS src/lib/provable/test/int.test.ts (8.64 s)
# PASS src/lib/mina/precondition.test.ts (12.688 s)
# PASS src/lib/mina/token.test.ts (46.593 s)

TESTS=`ls -b src/lib/provable/test/*.test.ts src/lib/mina/*.test.ts `
#src/lib/provable/test/*unit-test.ts
#src/lib/mina/*.unit-test.ts

#TESTS="src/lib/provable/test/merkle-list-perf.test.ts"

export NO_INSIGHT=true
export JESTOPTS=--collectCoverage
export NODEOPT1="--prof  --expose-gc"
for testname in $TESTS;
do
    export MULTIPLE="${testname}"
    export perfdata="${testname}.perf.data"
    clinic flame -- node $NODEOPT1 ./node_modules/.bin/../jest/bin/jest.js "${JESTOPTS}" "${MULTIPLE}"
    clinic doctor -- node $NODEOPT1 ./node_modules/.bin/../jest/bin/jest.js "${JESTOPTS}" "${MULTIPLE}"
    clinic bubbleprof -- node $NODEOPT1 ./node_modules/.bin/../jest/bin/jest.js "${JESTOPTS}" "${MULTIPLE}"
    clinic heapprofiler -- node $NODEOPT1 ./node_modules/.bin/../jest/bin/jest.js "${JESTOPTS}" "${MULTIPLE}"
    
    perf record -g -o "${testname}.perf.data" -F 999 --call-graph dwarf node  $NODEOPT1 ./node_modules/.bin/../jest/bin/jest.js "${JESTOPTS}" "${MULTIPLE}" > "${testname}.reportout.txt" 2>&1
    perf archive ${testname}.perf.data
    perf report -i "${perfdata}" --verbose --stdio --header > "${perfdata}.header.txt" 2>&1
    perf report -i "${perfdata}" --verbose --stdio --stats > "${perfdata}.stats.txt" 2>&1
    perf script -F +pid -i "${perfdata}"  > "${perfdata}.script.txt" 2>&1
    perf report --stdio -i "${perfdata}"  > "${perfdata}.report.txt" 2>&1
    cp ${testname}.* "${OUTPUT_DIR}"
    cp -r .clinic/* "${CLINIC_OUTPUT_DIR}"
    cp -r coverage/* "${OUTPUT_DIR}/"
    cp -r jit*.dump "${OUTPUT_DIR}/"
    cp -r *.log "${OUTPUT_DIR}/"    
done

tar -czf /tmp/perf.data.tar.gz /tmp/perf/*

# + for f in ./src/**/*.test.ts
#./src/lib/mina/precondition.test.ts
#./src/lib/mina/token.test.ts
#./src/lib/provable/test/primitives.test.ts

# #######
# NO_INSIGHT=true clinic flame -- node /usr/local/bin/pnpm run test
# NO_INSIGHT=true clinic flame -- node /usr/local/bin/pnpm run test:integration
# NO_INSIGHT=true clinic flame -- node /usr/local/bin/pnpm run test:unit
# NO_INSIGHT=true clinic flame -- node /usr/local/bin/pnpm run test:e2e

