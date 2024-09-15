#18.20.4
FROM node:18.20.4-slim AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

#FROM ocaml/opam:ubuntu-22.04-ocaml-4.14@sha256:73f7c5dd28f7b757de325d915562a3f89903a64e763c0e334914fb56e082f5cb as build
RUN apt-get update
RUN apt-get install -y opam

USER root
RUN apt-get update && apt-get install -y --no-install-recommends bubblewrap
RUN opam init --disable-sandboxing --yes
RUN opam exec -- opam update
RUN opam exec -- opam install dune
#RUN opam exec -- opam install --deps-only --with-test -y .
#RUN sudo chown -R opam .
#RUN opam exec -- dune build && opam exec -- dune test


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
FROM base AS prod-deps
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --prod --frozen-lockfile

FROM base AS build
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile
#RUN npm run build
RUN opam install -y js_of_ocaml-ppx
RUN apt install -y libjemalloc-dev

## rust

# install toolchain
RUN apt-get install --no-install-recommends -y  musl-tools
#RUN curl https://sh.rustup.rs -sSf |  bash -x -s -- --default-toolchain stable -y
# Get Rust
RUN apt install -y     git    curl 

RUN curl https://sh.rustup.rs -sSf | bash -s -- -y --verbose
RUN echo 'source $HOME/.cargo/env' >> $HOME/.bashrc
ENV PATH=/root/.cargo/bin:$PATH
# musl tools

# install musl target
#RUN /root/.cargo/bin/rustup target add x86_64-unknown-linux-musl  --toolchain stable-x86_64-unknown-linux-gnu
# nightly-2023-09-01-x86_64-unknown-linux-gnu

# make default target to musl
#RUN mkdir /.cargo && \
#    echo "[build]\ntarget = \"x86_64-unknown-linux-musl\"" > /.cargo/config
RUN rustup toolchain install nightly-2023-09-01-x86_64-unknown-linux-gnu
RUN rustup component add rust-src --toolchain nightly-2023-09-01-x86_64-unknown-linux-gnu

## now the source copyied
COPY src /app/src
COPY tests /app/tests
COPY benchmark /app/benchmark
COPY jest /app/jest

#RUN rustup toolchain install nightly


COPY dune-project /app/dune-project
# nightly-2023-09-01-x86_64-unknown-linux-gnu
RUN cargo install wasm-pack
RUN opam install -y bin_prot
RUN opam install -y async
RUN opam install -y Core_kernel
RUN opam install -y re2
RUN opam install -y ctypes
RUN opam install -y digestif.ocaml
RUN opam install -y hash_prefix_create.js
RUN opam install -y  logger.fake
RUN opam install -y  promise.js
RUN opam install -y   promise.js_helpers
RUN opam install -y  run_in_thread.fake

RUN opam exec -- pnpm run build:bindings
RUN pnpm run build

FROM base
COPY --from=prod-deps /app/node_modules /app/node_modules
COPY --from=build /app/dist /app/dist
EXPOSE 8000
CMD [ "pnpm", "start" ]



# # Use an official Ubuntu image as a base
# #FROM ubuntu:latest
# FROM o1labs/mina-local-network:compatible-latest-devnet

# # Set the working directory to /app
# WORKDIR /app

# # Install required dependencies

# # Install Node.js version 18
# RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
# RUN apt-get install -y nodejs

# # Clone the repository and checkout the specific branch
# RUN git clone https://github.com/meta-introspector/o1js.git .
# RUN git checkout 7647eb9

# # Install npm dependencies
# RUN npm ci

# # Build o1js
# RUN npm run build

# # Expose the port for the web server
# EXPOSE 8080

# # Run the command to start the web server when the container launches
# CMD ["npm", "run", "start"]