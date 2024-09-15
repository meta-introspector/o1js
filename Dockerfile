FROM node:20-slim AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

WORKDIR /app

ADD pnpm-lock.yaml pnpm-lock.yaml
ADD package.json package.json
ADD package-lock.json package-lock.json
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

RUN npm ci
RUN pnpm run build
RUN pnpm install jest

COPY run-jest-tests.sh /app/run-jest-tests.sh
COPY jest.config.js /app/jest.config.js

CMD [ "pnpm", "run", "test" ]

#RUN pnpm run test || echo skip errors