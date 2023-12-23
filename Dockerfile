# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.1.3
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

# Rails app lives here
WORKDIR /rails

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# Install packages needed for deployment
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libvips postgresql-client \
    # libjpeg-dev, lib-png-dev, libxml2-dev is for image magick delegate, pkg-config for linking the delegates to imagemagick
    tesseract-ocr tesseract-ocr-jpn ffmpeg build-essential python3 zlib1g-dev libjpeg-dev libpng-dev libxml2-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

RUN curl -L https://github.com/ImageMagick/ImageMagick/archive/refs/tags/7.1.1-23.tar.gz -o 7.1.1-23.tar.gz && \
    mkdir imagemagick && \
    tar xzf 7.1.1-23.tar.gz -C imagemagick && \
    rm 7.1.1-23.tar.gz && \
    cd imagemagick/ && \
    sh ./ImageMagick-7.1.1-23/configure --prefix=/usr/local --with-bzlib=yes --with-fontconfig=yes --with-freetype=yes --with-gslib=yes --with-gvc=yes --with-jpeg=yes --with-jp2=yes --with-png=yes --with-tiff=yes --with-xml=yes --with-gs-font-dir=yes && \
    make -j && make install && ldconfig /usr/local/lib/ && \
    cd .. && rm -rf imagemagick

# Throw-away build stage to reduce size of final image
FROM base as build

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt list -a nodejs &&\
    apt-get install --no-install-recommends -y build-essential git libpq-dev libvips pkg-config nodejs npm

RUN npm install -g n && n 16.20.1

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile
RUN node -v && npm -v

COPY package.json package-lock.json ./
RUN npm install

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails db:prepare

# RUN bundle exec rake fetch_latest_game_data:all

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

RUN rm -rf node_modules

# Final stage for app image
FROM base

# Need to update frequently due to youtube changing
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp && \
    chmod a+rx /usr/local/bin/yt-dlp

# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server"]
