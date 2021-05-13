#########################
# Stage: builder        #
#########################
FROM hexpm/elixir:1.11.4-erlang-23.3.4-alpine-3.13.3 as builder

# install build dependencies
RUN apk add --no-cache --update git build-base

WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get
RUN mix deps.compile

# build project
COPY priv priv
COPY lib lib
RUN mix compile

# build release
COPY rel rel
RUN mix release

#########################
# Stage: production     #
#########################
FROM alpine:3.13 as production

RUN apk add --no-cache bash openssl ncurses-libs

WORKDIR /app

COPY --from=builder /app/_build/prod/rel/forza_challenge_demo ./
RUN chown -R nobody: /app
USER nobody

ENV HOME=/app

ENTRYPOINT ["bin/forza_challenge_demo"]
# CMD ["start"]
