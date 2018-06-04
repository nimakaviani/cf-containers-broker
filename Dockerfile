FROM starefossen/ruby-node:2-8


# Install Node
# RUN apt-get -y update

# RUN apt-get -y install git-core curl build-essential openssl libssl-dev \
#  && git clone https://github.com/nodejs/node.git \
#  && cd node \
#  && ./configure \
#  && make \
#  && sudo make install

RUN npm install --production --quiet cli-flags
RUN npm install --production --quiet web3
RUN npm install --production --quiet solc

# Add application code
ADD . /app

# Prepare application (cache gems & precompile assets)
RUN cd /app && \
    bundle package --all && \
    RAILS_ENV=assets bundle exec rake assets:precompile && \
    rm -rf spec && \
    mkdir /config

# Add default configuration files
ADD ./config/unicorn.conf.rb /config/unicorn.conf.rb
ADD ./config/settings.yml /config/settings.yml

# Working directory
WORKDIR /app

# Define Rails environment
ENV RAILS_ENV production

# Define Settings file path
ENV SETTINGS_PATH /config/settings.yml

# Define Docker Remote API
ENV DOCKER_URL unix:///host/var/run/docker.sock

# Define NODE_PATH
ENV NODE_PATH /usr/local/lib/node_modules 

# Command to run
ENTRYPOINT ["/app/bin/run.sh"]
CMD ["bundle", "exec", "unicorn", "-c", "/config/unicorn.conf.rb"]

# Expose listen port
EXPOSE 80

# Expose the configuration and logs directories
VOLUME ["/config", "/app/log", "/envdir"]
