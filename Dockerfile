#
# Geminabox
#

# Pull base image.
FROM ashangit/base:latest
MAINTAINER Nicolas Fraison <nfraison@yahoo.fr>

# Deploy geminabox.
RUN yum install ruby ruby-devel gcc make -y && \
    gem install geminabox && \
    gem install unicorn

# Remove compiler package
RUN yum remove ruby-devel gcc make -y

# Create required folders
RUN mkdir -p /data/geminabox/conf && \
	mkdir -p /data/geminabox/data

# Set working directory
WORKDIR /data/geminabox/conf

# Copy default config file
COPY conf/config.ru /data/geminabox/conf/config.ru
COPY conf/unicorn.rb /data/geminabox/conf/unicorn.rb

# Declare default env variable
ENV RUBYGEMS_PROXY true
ENV ALLOW_REMOTE_FAILURE true
ENV WORKER_PROCESSES 2
ENV TIMEOUT 60

# Expose geminabox port
EXPOSE 9292

# Default command
CMD unicorn -p 9292 -c /data/geminabox/conf/unicorn.rb