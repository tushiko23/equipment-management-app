# syntax = docker/dockerfile:1

# This Dockerfile is designed for production, not development. Use with Kamal or build'n'run by hand:
# docker build -t my-app .
# docker run -d -p 80:80 -p 443:443 --name my-app -e RAILS_MASTER_KEY=<value from config/master.key> my-app

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.3.3
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# 環境変数の定義
ENV APP_NAME="equipment-management-app" \
    USER_NAME="rails"

# Rails app lives here
WORKDIR /"${APP_NAME}"

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips postgresql-client msmtp-mta iputils-ping net-tools iproute2 git vim less sudo man bzip2 zip && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set development environment
ENV RAILS_ENV="development" \
    BUNDLE_DEPLOYMENT="0" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT=""

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Final stage for app image
FROM base

ENV APP_NAME="equipment-management-app" \
    BUNDLE_PATH="/usr/local/bundle" \
    USER_NAME="rails"

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /"${APP_NAME}" /"${APP_NAME}"

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 "${USER_NAME}" && \
    useradd "${USER_NAME}" --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    # ここで /usr/local/bundle の所有者も rails に変更します
    mkdir -p "${BUNDLE_PATH}" && \
    chown -R "${USER_NAME}":"${USER_NAME}" db log storage tmp
USER 1000:1000

# Entrypoint prepares the database.
# equipment-management-appにはアプリケーション名(${APP_NAME})を定義
ENTRYPOINT ["/equipment-management-app/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
