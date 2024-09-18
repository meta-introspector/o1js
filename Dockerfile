FROM node:20-slim AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable
RUN apt update
RUN apt install -y git

WORKDIR /app

ADD pnpm-lock.yaml pnpm-lock.yaml
ADD package.json package.json
#ADD package-lock.json package-lock.json
ADD tsconfig.examples.json tsconfig.examples.json
ADD tsconfig.json tsconfig.json
ADD tsconfig.mina-signer.json tsconfig.mina-signer.json
ADD tsconfig.mina-signer-web.json tsconfig.mina-signer-web.json
ADD tsconfig.node.json tsconfig.node.json
ADD tsconfig.test.json tsconfig.test.json
ADD tsconfig.web.json tsconfig.web.json
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --prod --frozen-lockfile
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile

## now the source is copied
COPY src /app/src
COPY tests /app/tests
COPY benchmark /app/benchmark
COPY jest /app/jest
COPY dune-project /app/dune-project

#RUN pnpm ci
RUN corepack enable
RUN corepack prepare pnpm@latest-9 --activate
RUN pnpm install
#    "dev": "npx tsc -p tsconfig.test.json && node src/build/copy-to-dist.js",
RUN npx tsc --help || echo 2
RUN npx tsc --all || echo 2
RUN npx tsc --version
RUN npx tsc -p tsconfig.test.json

RUN pnpm install "https://github.com/meta-introspector/jest.git"
RUN pnpm install "https://github.com/meta-introspector/ts-jest.git"
RUN pnpm install "https://github.com/meta-introspector/node-clinic-doctor"
RUN pnpm install -g "https://github.com/meta-introspector/node-clinic"

RUN pnpm run build

#RUN apt update
#RUN apt install -y strace

COPY run-jest-tests.sh /app/run-jest-tests.sh
COPY jest.config.js /app/jest.config.js
COPY run-integration-tests.sh /app/run-integration-tests.sh
COPY run-unit-tests.sh /app/run-unit-tests.sh
COPY run-all-tests.sh /app/run-all-tests.sh
COPY run /app/run
COPY run-debug /app/run-debug
COPY run-minimal-mina-tests.sh /app/run-minimal-mina-tests.sh
COPY run-ci-benchmarks.sh /app/run-ci-benchmarks.sh

# why?
RUN ln -s /app/dist /app/src/mina-signer/dist

# '/app/dist/node/bindings/compiled/_node_bindings/plonk_wasm.cjs' imported from /app/dist/node/bindings/js/node/node-backend.js
# found here
#./src/bindings/compiled/node_bindings/plonk_wasm.cjs
#./src/bindings/compiled/_node_bindings/plonk_wasm.cjs
#./dist/node/bindings/compiled/_node_bindings/plonk_wasm.cjs

CMD [ "pnpm", "run", "test" ]

#RUN pnpm run test || echo skip errors