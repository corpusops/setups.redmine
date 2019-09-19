FROM "{{cops_redmine_image}}"
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        freetds-dev \
        gcc \
        libmagickcore-dev \
        libmagickwand-dev \
        libmariadbclient-dev \
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
RUN set -eux \
    && : echo "gem 'rich', :git => 'https://github.com/a-ono/rich.git', :branch => 'master'" >> Gemfile \
	&& for adapter in mysql2 postgresql sqlserver sqlite3; do \
		echo "$RAILS_ENV:" > ./config/database.yml; \
		echo "  adapter: $adapter" >> ./config/database.yml; \
		gosu redmine bundle install --jobs "$(nproc)" --without development test; \
		cp Gemfile.lock "Gemfile.lock.${adapter}"; \
	done; \
	rm ./config/database.yml
