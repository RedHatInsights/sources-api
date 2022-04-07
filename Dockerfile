FROM registry.access.redhat.com/ubi8/ubi:latest

RUN dnf -y --disableplugin=subscription-manager module enable ruby:2.6 && \
    dnf -y --disableplugin=subscription-manager --setopt=tsflags=nodocs install \
      ruby-devel \
      # To compile native gem extensions
      gcc-c++ make redhat-rpm-config \
      # For git based gems
      git \
      # For checking service status
      nmap-ncat \
      # Libraries
      postgresql-devel openssl-devel libxml2-devel \
      # For the rdkafka gem
      cyrus-sasl-devel zlib-devel openssl-devel diffutils \
      # For the mimemagic gem (+rails)
      shared-mime-info \
      jq libffi-devel \
      && \
    dnf --disableplugin=subscription-manager clean all

ENV WORKDIR /opt/sources-api/
ENV RAILS_ROOT $WORKDIR
WORKDIR $WORKDIR

RUN touch /opt/rdsca.crt && chmod 666 /opt/rdsca.crt

COPY Gemfile $WORKDIR
COPY Gemfile.lock $WORKDIR
RUN echo "gem: --no-document" > ~/.gemrc && \
    gem install bundler --conservative --without development:test && \
    bundle install --jobs 8 --retry 3 && \
    rm -rvf $(gem env gemdir)/cache/* && \
    rm -rvf /root/.bundle/cache

# Download the go-rewrite's encryption compatibility tool
RUN curl -L https://github.com/lindgrenj6/sources-encrypt-compat/releases/download/v1.0.0/sources-encrypt-compat > /usr/local/bin/sources-encrypt-compat && \
    chmod +x /usr/local/bin/sources-encrypt-compat

COPY . $WORKDIR
COPY docker-assets/* /usr/bin/

RUN chgrp -R 0 $WORKDIR && \
    chmod -R g=u $WORKDIR

# for compatibility with CI
EXPOSE 3000 8000

ENTRYPOINT ["entrypoint"]
CMD ["run_rails_server"]
