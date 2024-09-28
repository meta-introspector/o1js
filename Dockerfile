FROM node:20-slim AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable
RUN apt update
RUN apt install -y git bzip2
run apt-get install -y linux-perf # move to top
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
RUN npm install -g npm@10.8.3
#    "dev": "npx tsc -p tsconfig.test.json && node src/build/copy-to-dist.js",
RUN npx tsc -p tsconfig.test.json

#RUN pnpm install "https://github.com/meta-introspector/jest.git"
#RUN pnpm install "https://github.com/meta-introspector/ts-jest.git"
#RUN pnpm install "https://github.com/meta-introspector/node-clinic-doctor"
#RUN pnpm install "https://github.com/meta-introspector/node-clinic"
RUN pnpm install -g clinic

RUN pnpm run build

# why is this needed?
RUN ln -s /app/dist /app/src/mina-signer/dist

WORKDIR /app

FROM base AS prod-deps
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --prod --frozen-lockfile

FROM base AS build
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile
RUN pnpm run build

FROM base
COPY --from=prod-deps /app/node_modules /app/node_modules
COPY --from=build /app/dist /app/dist

COPY run-jest-tests.sh /app/run-jest-tests.sh
#COPY jest.config.js /app/jest.config.js
COPY run-integration-tests.sh /app/run-integration-tests.sh
COPY run-unit-tests.sh /app/run-unit-tests.sh
COPY run-all-tests.sh /app/run-all-tests.sh
COPY run /app/run
COPY run-debug /app/run-debug
COPY run-minimal-mina-tests.sh /app/run-minimal-mina-tests.sh
COPY run-ci-benchmarks.sh /app/run-ci-benchmarks.sh


EXPOSE 8000
CMD [ "pnpm", "start" ]


