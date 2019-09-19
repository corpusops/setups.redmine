FROM "{{cops_redmine_image}}"
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        freetds-dev \
        gcc \
        libmagickcore-dev \
        libmagickwand-dev \
        libmariadb-dev-compat libmariadb-dev \
        libpq-dev \
        libsqlite3-dev \
        make \
        patch
USER redmine
RUN : rev1 \
    && set -eux \
    && cd plugins \
    && {{ cops_redmine_plugins_script }}
USER root
RUN set -eux ;\
    cp Gemfile.lock Gemfile.lock.orig; \
    for adapter in mysql2 postgresql sqlserver sqlite3; do \
        echo "$RAILS_ENV:" > ./config/database.yml; \
        echo "  adapter: $adapter" >> ./config/database.yml; \
        gosu redmine bundle install --jobs "$(nproc)" --without development test; \
        cp Gemfile.lock "Gemfile.lock.${adapter}"; \
    done; \
    cp Gemfile.lock.orig Gemfile.lock; \
    rm ./config/database.yml



# inspired by https://raw.githubusercontent.com/docker-library/redmine/master/Dockerfile-passenger.template
ENV PASSENGER_VERSION {{cops_redmine_passenger_version}}
RUN set -eux; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		gcc \
		make \
	; \
	rm -rf /var/lib/apt/lists/*; \
	\
	gem install passenger --version "$PASSENGER_VERSION"; \
# pre-build "passenger_native_support.so" while we have the compiler toolchain available
	passenger-config build-native-support; \
# the above command always exits with a zero exit code, but if we run it again and it was successful, it'll have empty output (that's the best way I can find to verify that it's worked)
	if [ -n "$(passenger-config build-native-support 2>&1)" ]; then cat /tmp/passenger_native_support-*.log; false; fi; \
	\
	apt-mark auto '.*' > /dev/null; \
	[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

# pre-download the PassengerAgent and the NGINX engine
RUN set -eux; \
	passenger-config install-agent; \
	passenger-config download-nginx-engine

# adjust Passenger to write the PID to the same file as "rails server"
ENV PASSENGER_PID_FILE tmp/pids/server.pid
    
ADD ./docker-entrypoint.sh /
