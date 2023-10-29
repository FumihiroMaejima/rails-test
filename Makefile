.PHONY: help
.DEFAULT_GOAL := help

# load test
WOKER=1
LOCUST_FILE=./loadTest/locust/locustfile.py
LOCUST_SAMPLE_FILE=./loadTest/locust/samples/locustfileTest.py

# redis
REDIS_DB=1
REDIS_KEY=test_key
REDIS_CLUSTER_CONTAINER_COUNT=6

# etc
TMP_PARAM=
TMP_PARAM2=

##############################
# make docker environmental
##############################
up:
	docker-compose up -d

stop:
	docker-compose stop

down:
	docker-compose down

down-volume:
	docker-compose down -v

down-rmi:
	docker-compose down --rmi all
ps:
	docker-compose ps

rebuild: # 個別のコンテナを作り直し
	docker-compose -f ./docker-compose.yml build --no-cache $(SEVICE_NAME)

recreate-volume:
	docker volume rm $(VOLUME_NAME) && \
	docker volume create $(VOLUME_NAME) && \

dev:
	sh ./scripts/docker/container-dev.sh
#	sh ./scripts/docker/container-dev.sh && \
#	${SHELL} ./scripts/change-db-host.sh db-next db

# ssr:
# 	sh ./scripts/docker/container-nextjs.sh && \
# 	${SHELL} ./scripts/change-db-host.sh db db-next

##############################
# make frontend production in nginx container
##############################
frontend-install:
	docker-compose exec nginx ash -c 'cd /var/www/frontend && yarn install'

frontend-build:
	docker-compose exec nginx ash -c 'cd /var/www/frontend && yarn build'

##############################
# backend (Ruby on Rails)
##############################
bundle-install:
	docker-compose run app ash -c 'bundle install'

create-rails-project:
	docker-compose run app ash -c 'cd /var/www/html && rails new . -fT -d mysql'

webpacker-install:
	docker-compose run app ash -c 'rails webpacker:install'

##############################
# web server(nginx)
##############################
nginx-t:
	docker-compose exec nginx ash -c 'nginx -t'

nginx-reload:
	docker-compose exec nginx ash -c 'nginx -s reload'

nginx-stop:
	docker-compose exec nginx ash -c 'nginx -s stop'


##############################
# db container(mysql)
##############################
mysql:
	docker-compose exec db bash -c 'mysql -u $$DB_USER -p$$MYSQL_PASSWORD $$DB_DATABASE'

mysql-dump:
	sh ./scripts/database/get-dump.sh $(TMP_PARAM)

mysql-restore:
	sh ./scripts/database/restore-dump.sh $(TMP_PARAM)

##############################
# redis container
##############################
redis-server:
	docker-compose exec redis redis-server --version

redis-info:
	docker-compose exec redis redis-cli info

redis-keys:
	docker-compose exec redis redis-cli -h localhost -p 6379 -n $(REDIS_DB) keys '*'

redis-get:
	docker-compose exec redis redis-cli -h localhost -p 6379 -n $(REDIS_DB) get $(REDIS_KEY)

redis-del:
	docker-compose exec redis redis-cli -h localhost -p 6379 -n $(REDIS_DB) del $(REDIS_KEY)

redis-hget:
	docker-compose exec redis redis-cli -h localhost -p 6379 -n $(REDIS_DB) HGETALL $(REDIS_KEY)

##############################
# redis cluster container
##############################
redis-cluster-up:
	docker-compose -f ./docker-compose.redis-cluster.yml up -d --scale redis-cluster=$(REDIS_CLUSTER_CONTAINER_COUNT)

redis-cluster-down:
	docker-compose -f ./docker-compose.redis-cluster.yml down -v

redis-cluster-ps:
	docker-compose -f ./docker-compose.redis-cluster.yml ps

redis-cluster-dev:
	sh ./scripts/docker/redis-cluster-dev.sh $(REDIS_CLUSTER_CONTAINER_COUNT)

redis-cluster-server:
	docker-compose exec redis-cluster redis-server --version

redis-cluster-nodes: # check cluster status
	docker-compose exec redis-cluster redis-cli cluster nodes

redis-cluster-networks: # check cluster status
	docker network inspect cochlea-net | jq '.[0].Containers | .[] | {Name, IPv4Address}'

redis-cluster-info:
	docker-compose exec redis-cluster redis-cli info

redis-cluster-keys:
	docker-compose exec redis-cluster redis-cli -h localhost -p 6379 -n $(REDIS_DB) keys '*'

redis-cluster-get:
	docker-compose exec redis-cluster redis-cli -h localhost -p 6379 -n $(REDIS_DB) get $(REDIS_KEY)

redis-cluster-del:
	docker-compose exec redis-cluster redis-cli -h localhost -p 6379 -n $(REDIS_DB) del $(REDIS_KEY)

redis-cluster-hget:
	docker-compose exec redis-cluster redis-cli -h localhost -p 6379 -n $(REDIS_DB) HGETALL $(REDIS_KEY)

##############################
# grafana docker container
##############################
grafana-up:
	docker-compose -f ./docker-compose.grafana.yml up -d && \
	echo 'prometheus : http://localhost:9090' && \
	echo 'node-exporter : http://localhost:9100/metrics' && \
	echo 'grafana : http://localhost:3200' && \
	echo 'alertmanager : http://localhost:9093/#/status' && \
	echo 'promtail : http://localhost:9080/targets'

grafana-down:
	docker-compose -f ./docker-compose.grafana.yml down

grafana-ps:
	docker-compose -f ./docker-compose.grafana.yml ps

grafana-dev:
	sh ./scripts/docker/grafana-container.sh

##############################
# locust docker environmental
##############################
locust-up:
	docker-compose -f ./docker-compose.locust.yml up -d --scale worker=$(WOKER) && \
	echo 'locust : http://localhost:8089'

locust-down:
	docker-compose -f ./docker-compose.locust.yml down

locust-down-rmi:
	docker-compose -f ./docker-compose.locust.yml down --rmi all

locust-ps:
	docker-compose -f ./docker-compose.locust.yml ps

locust-create: # create locustfile.py
ifeq ("$(wildcard $(LOCUST_FILE))", "") # ファイルが無い場合
	cp $(LOCUST_SAMPLE_FILE) $(LOCUST_FILE)
else
	@echo file already exist.
endif

locust-dev:
#	 sh ./scripts/locust-dev.sh
	sh ./scripts/docker/locust-dev.sh $(WOKER)

##############################
# jenkins
##############################
jenkins-up:
	docker-compose -f ./docker-compose.jenkins.yml up -d && \
	echo 'locust : http://localhost:8280'

jenkins-down:
	docker-compose -f ./docker-compose.jenkins.yml down -v && \
	rm -r jenkins/home/.cache

jenkins-clear-src:
	rm -rf jenkins/home/* && \
	rm -r jenkins/home/.cache && \
	rm -r jenkins/home/.java

jenkins-rebuild: # down container & remove cacahe & rebuild container.
	docker-compose -f ./docker-compose.jenkins.yml down --rmi all && \
	rm -r jenkins/home/.cache && \
	docker-compose -f ./docker-compose.jenkins.yml up -d

jenkins-quiet: # down jenkins.
	curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d '{}' localhost:8080/quietDown

##############################
# sqldef docker environmental
##############################
sqldef-up:
	docker-compose -f ./docker-compose.sqldef.yml up -d

sqldef-down:
	docker-compose -f ./docker-compose.sqldef.yml down

sqldef-down-rmi:
	docker-compose -f ./docker-compose.sqldef.yml down --rmi all

sqldef-ps:
	docker-compose -f ./docker-compose.sqldef.yml ps

sqldef-dev:
	sh ./scripts/docker/sqldef-dev.sh

sqldef-export:
	sh ./sqldef/src/scripts/export.sh $(TMP_PARAM)

sqldef-import:
	sh ./sqldef/src/scripts/import.sh $(TMP_PARAM) $(TMP_PARAM2)

sqldef-import-dry-run:
	sh ./sqldef/src/scripts/import.sh $(TMP_PARAM) dryRun

sqldef-help:
	docker-compose exec sqldef /mysqldef --help

##############################
# circle ci
##############################
circleci:
	cd app/backend && circleci build

ci:
	circleci build

##############################
# mock-server docker container
##############################
mock-up:
	docker-compose -f ./docker-compose.mock.yml up -d

mock-down:
	docker-compose -f ./docker-compose.mock.yml down

mock-ps:
	docker-compose -f ./docker-compose.mock.yml ps

##############################
# swagger docker container
##############################
swagger-up:
	docker-compose -f ./docker-compose.swagger.yml up -d

swagger-down:
	docker-compose -f ./docker-compose.swagger.yml down

swagger-ps:
	docker-compose -f ./docker-compose.swagger.yml ps

swagger-dev:
	sh ./scripts/docker/swagger-container.sh

##############################
# swagger codegen mock-server
##############################
codegen-mock:
	rm -rf swagger/node-mock/* && \
	swagger-codegen generate -i swagger/api.yaml -l nodejs-server -o swagger/node-mock && \
	sed -i -e "s/serverPort = 8080/serverPort = 3200/g" swagger/node-mock/index.js && \
	cd swagger/node-mock && npm run prestart

codegen-changeport:
	sed -i -e "s/serverPort = 8080/serverPort = 3200/g" swagger/node-mock/index.js

codegen-prestart:
	cd swagger/node-mock && npm run prestart

codegen-start:
	cd swagger/node-mock && npm run start

##############################
# etc
##############################
help:
	@cat Makefile
