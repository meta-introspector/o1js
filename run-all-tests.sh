
set +e

#NO_INSIGHT=true clinic doctor -- node --perf-basic-prof --enable-source-maps --stack-trace-limit=1000 ./node_modules/jest-cli/bin/jest.js
#NO_INSIGHT=true clinic flame -- node --perf-basic-prof --enable-source-maps --stack-trace-limit=1000 ./node_modules/jest-cli/bin/jest.js
# May Clinic.js report anonymous usage statistics to improve the tool over time?

#######
find /app > /tmp/app-files-list.txt
NO_INSIGHT=true clinic doctor -- node /usr/local/bin/pnpm run test
NO_INSIGHT=true clinic doctor -- node /usr/local/bin/pnpm run test:integration
NO_INSIGHT=true clinic doctor -- node /usr/local/bin/pnpm run test:unit
NO_INSIGHT=true clinic doctor -- node /usr/local/bin/pnpm run test:e2e

#######
NO_INSIGHT=true clinic flame -- node /usr/local/bin/pnpm run test
NO_INSIGHT=true clinic flame -- node /usr/local/bin/pnpm run test:integration
NO_INSIGHT=true clinic flame -- node /usr/local/bin/pnpm run test:unit
NO_INSIGHT=true clinic flame -- node /usr/local/bin/pnpm run test:e2e

#clinic flame -- node index.js

# pnpm run test
# pnpm run test:integration
# pnpm run test:unit
# pnpm run test:e2e
