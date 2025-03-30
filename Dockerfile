# Find eligible builder and runner images on Docker Hub. We use Ubuntu/Debian
# instead of Alpine to avoid DNS resolution issues in production.
#
# https://hub.docker.com/r/hexpm/elixir/tags?page=1&name=ubuntu
# https://hub.docker.com/_/ubuntu?tab=tags
#
# This file is based on these images:
#
#   - https://hub.docker.com/r/hexpm/elixir/tags - for the build image
#   - https://hub.docker.com/_/debian?tab=tags&page=1&name=bullseye-20240701-slim - for the release image
#   - https://pkgs.org/ - resource for finding needed packages
#   - Ex: hexpm/elixir:1.17.1-erlang-27.0-debian-bullseye-20240701-slim
#
ARG ELIXIR_VERSION=1.18.3
ARG OTP_VERSION=27.3.1
ARG NODE_VERSION=22
ARG DEBIAN_VERSION=bookworm-20250317-slim

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

FROM ${BUILDER_IMAGE} AS builder

ARG DOGGO_VERSION
ARG NODE_VERSION

# install build dependencies
RUN apt-get update -y \
    && apt-get install -y build-essential curl git \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_VERSION}.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update -y && apt-get install -y nodejs \
    && corepack enable pnpm \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV "prod"
ENV VERSION ${DOGGO_VERSION}

RUN mkdir demo

# install mix dependencies
COPY demo/mix.exs demo/mix.lock ./demo
RUN cd demo && mix deps.get --only $MIX_ENV
RUN cd demo && mkdir config

COPY mix.exs mix.lock ./
COPY lib lib

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY demo/config/config.exs demo/config/${MIX_ENV}.exs ./demo/config/
RUN cd demo && mix deps.compile

COPY demo/priv demo/priv
COPY demo/lib demo/lib
COPY demo/assets demo/assets
COPY demo/storybook demo/storybook

# compile assets
RUN cd demo && mix assets.setup && mix assets.deploy

# Compile the release
RUN cd demo && mix compile

# Changes to config/runtime.exs don't require recompiling the code
COPY demo/config/runtime.exs demo/config/

COPY demo/rel demo/rel
RUN cd demo && mix release

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM ${RUNNER_IMAGE}

RUN apt-get update -y && \
  apt-get install -y libstdc++6 openssl libncurses5 locales ca-certificates \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR "/app"
RUN chown nobody /app

# set runner ENV
ENV MIX_ENV "prod"

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/demo/_build/${MIX_ENV}/rel/demo ./

USER nobody

# If using an environment that doesn't automatically reap zombie processes, it is
# advised to add an init process such as tini via `apt-get install`
# above and adding an entrypoint. See https://github.com/krallin/tini for details
# ENTRYPOINT ["/tini", "--"]

CMD ["/app/bin/server"]
