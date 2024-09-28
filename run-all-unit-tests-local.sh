#find /app

npx tsc -p tsconfig.test.json
pnpm run build

bash ./run-all-unit-tests.sh
