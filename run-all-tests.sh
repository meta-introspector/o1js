
set +e

#NO_INSIGHT=true clinic doctor -- node --perf-basic-prof --enable-source-maps --stack-trace-limit=1000 ./node_modules/jest-cli/bin/jest.js
#NO_INSIGHT=true clinic flame -- node --perf-basic-prof --enable-source-maps --stack-trace-limit=1000 ./node_modules/jest-cli/bin/jest.js
# May Clinic.js report anonymous usage statistics to improve the tool over time?

#######
#find /app > /tmp/app-files-list.txt
#NO_INSIGHT=true clinic doctor --collect-only --
#node /usr/local/bin/pnpm run test
#./run-jest-tests.sh
export NODE_OPTIONS=--experimental-vm-modules
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

mkdir /tmp/perf/
TESTS="src/lib/provable/test/merkle-list.test.ts src/lib/provable/test/merkle-tree.test.ts src/lib/provable/test/scalar.test.ts  src/lib/provable/test/merkle-map.test.ts  src/lib/provable/test/provable.test.ts  src/lib/provable/test/primitives.test.ts  src/lib/provable/test/group.test.ts  src/lib/provable/test/int.test.ts  src/lib/mina/precondition.test.ts src/lib/mina/token.test.ts"
for testname in $TESTS;

do
    perf record -o ${testname}.perf.data -F 999 --call-graph dwarf node --perf-basic-prof ./node_modules/.bin/../jest/bin/jest.js ${testname} > ${testname}.reportout.txt 2>&1
    perf archive ${testname}.perf.data

    cp ${testname}.* /tmp/perf/
done

tar -czf /tmp/perf.data.tar.gz /tmp/perf/*
#perf script > perf_script.txt
#perf report > perf_report.txt
#clinic doctor --collect-only -- node ./node_modules/jest-cli/bin/jest.js ./src/mina-signer/tests/rosetta.test.ts
#clinic doctor --collect-only -- node ./node_modules/.pnpm/@jest+monorepo@https+++codeload.github.com+meta-introspector+jest+tar.gz+4a58402556ecd05ca9cc01873db6fbc5596ccc67/node_modules/@jest/monorepo/packages/jest-cli/bin/jest.js ./src/mina-signer/tests/rosetta.test.ts

# + for f in ./src/**/*.test.ts
#./src/lib/mina/precondition.test.ts
#./src/lib/mina/token.test.ts
#./src/lib/provable/test/primitives.test.ts

# NO_INSIGHT=true clinic doctor --collect-only -- node /usr/local/bin/pnpm run test:integration
# NO_INSIGHT=true clinic doctor --collect-only -- node /usr/local/bin/pnpm run test:unit
# NO_INSIGHT=true clinic doctor --collect-only -- node /usr/local/bin/pnpm run test:e2e

# #######
# NO_INSIGHT=true clinic flame -- node /usr/local/bin/pnpm run test
# NO_INSIGHT=true clinic flame -- node /usr/local/bin/pnpm run test:integration
# NO_INSIGHT=true clinic flame -- node /usr/local/bin/pnpm run test:unit
# NO_INSIGHT=true clinic flame -- node /usr/local/bin/pnpm run test:e2e

# #clinic flame -- node index.js

# # pnpm run test
# # pnpm run test:integration
# # pnpm run test:unit
# # pnpm run test:e2e
