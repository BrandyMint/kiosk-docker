# Pull base image.
FROM ubuntu:14.04

# Install.
ENV DEBIAN_FRONTEND noninteractive
RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y build-essential \
    make \
    byobu \
    curl \
    git \
    unzip \
    wget \
    ca-certificates \
    imagemagick \
    libffi-dev \
    libreadline-dev \
    libssl-dev \
    libmagickwand-dev \
    libmysqlclient-dev \
    mdbtools-dev \
    nodejs \
    nodejs-legacy && \
  rm -rf /var/lib/apt/lists/* && \
  mkdir -pv /var/www && \
  chown -v www-data:www-data /var/www  && \
  rsync --itemize-changes --checksum --copy-links /usr/share/zoneinfo/Europe/Moscow /etc/localtime && \
  echo 'Europe/Moscow' > /etc/timezone && \
  dpkg-reconfigure --frontend noninteractive tzdata



USER www-data
ENV HOME /var/www
WORKDIR /var/www
RUN git clone https://github.com/BrandyMint/kiosk.git && \
  git clone git://github.com/sstephenson/rbenv.git .rbenv && \
  git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build && \
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc && \
  echo 'eval "$(rbenv init -)"' >> ~/.bashrc && \
  cd /var/www/.rbenv/plugins/ruby-build && \
  git pull && \
  cd /var/www/kiosk/ && \
  bash -c "$HOME/.rbenv/bin/rbenv install -v `cat /var/www/kiosk/.ruby-version`" && \
  bash -c "$HOME/.rbenv/bin/rbenv global `cat /var/www/kiosk/.ruby-version`" && \
  bash -c "$HOME/.rbenv/bin/rbenv exec gem install bundler" && \
  bash -c "$HOME/.rbenv/bin/rbenv exec bundle install --without development test"

# Define default command.
USER www-data
EXPOSE 3000
ENV RAILS_ENV production
ENV APP_ROOT /var/www/kiosk
ENV PWD /var/www/kiosk
ENV PATH "/var/www/.rbenv/shims:/var/www/.rbenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
WORKDIR /var/www/kiosk
CMD ["/var/www/.rbenv/bin/rbenv", "exec", "bundle", "exec", "rails", "server"]
