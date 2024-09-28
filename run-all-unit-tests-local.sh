#find /app
corepack enable
corepack prepare pnpm@latest-9 --activate
pnpm install
pnpm install -g clinic
pnpm install -g npm@10.8.3

npx tsc -p tsconfig.test.json
pnpm run build

bash ./run-all-unit-tests.sh
