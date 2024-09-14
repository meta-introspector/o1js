FROM node:20-slim AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable
COPY . /app
WORKDIR /app

FROM base AS prod-deps
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --prod --frozen-lockfile

FROM base AS build
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile
RUN npm run build

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
# RUN apt update && apt install -y \
#     git \
#     curl \
#     npm \
#     nodejs

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