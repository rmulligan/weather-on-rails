# Dockerfile for WeatherOnRails
FROM ruby:3.2.2-slim

# install dependencies
RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends \
       build-essential \
       libsqlite3-dev \
       sqlite3 \
       nodejs \
    && rm -rf /var/lib/apt/lists/*

# set working directory
WORKDIR /app

# cache and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test' \
  && bundle install -j "$(nproc)"

# copy application code
COPY . .

# precompile assets (no database setup needed since ActiveRecord is disabled)
# RUN bundle exec rails db:prepare

# expose port
EXPOSE 3000

# default command
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]