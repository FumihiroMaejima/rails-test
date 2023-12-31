# Application Name

My Application.

# 構成

## backend

| 名前 | バージョン |
| :--- | :---: |
| Ruby | 3.2.2(ruby:3.2.2-alpine3.18) |
| MySQL | 5.7 |
| Nginx | 1.25(nginx:1.25-alpine) |
| Rails | 7.0.* |

[backend/README](./app/backend/README.md)

---

## volumeとnetworkの作成

networkは`gateway`と`subnet`を必ず指定する。(値は任意。)

```shell
docker volume create ${PROJECT_NAME}-db-store
docker volume create ${PROJECT_NAME}-redis-store
docker volume create ${PROJECT_NAME}-mail-store
docker network create --gateway=172.19.0.1 --subnet=172.19.0.0/16 ${PROJECT_NAME}-net
# 又は
docker network create ${PROJECT_NAME}-net

### volumeの作り直しをする時
docker volume rm ${PROJECT_NAME}-db-store

### コンテナのIPアドレスの確認(jqが入っている場合)
docker network inspect ${NETWORK_NAME} | jq '.[0].Containers | .[].IPv4Address'
```


---

## railsコンテナの立ち上げについて

先にDBのコンテナをビルドしておく。(ビルド後にdownする。)

下記のコマンドでrailsプロジェクトの作成を行う。

`-d`オプションは利用するDBによって変更する。(「postgresql」などがある)

```shell
docker-compose run --rm --no-deps app rails new . -fT -d mysql
### apiモードの場合は`--api`のオプションをつける
docker-compose run --rm --no-deps app rails new . -fT -d mysql --api

### ローカル環境でインストールを実行する為、mysqlを入れていないと下記のエラーが発生する。
An error occurred while installing mysql2 (0.5.5), and Bundler cannot continue.
In Gemfile:
  mysql2
         run  bundle binstubs bundler
Could not find gem 'mysql2 (~> 0.5)' in locally installed gems.
       rails  webpacker:install
Could not find gem 'mysql2 (~> 0.5)' in locally installed gems.


### docker container 内にmysql-clientを入れた上で下記のコマンドを実行すると解消する
docker-compose run app ash -c 'cd /var/www/html && gem install mysql2'

### railsのコンテナは基本的にgemのパッケージを追加する度にイメージをビルドし直す必要がある。

### 最終的に下記の3つのコマンドを実行すればよさそう。
docker-compose run app ash -c 'cd /var/www/html && rails new . -fT -d mysql'
### コンテナビルド時に`gcompat`をインストールしないと下記のコマンド実行時にエラーになる。インストールされれば、上記コマンド1つだけで済む様になる。
docker-compose run app ash -c 'cd /var/www/html && bundle binstubs bundler'
docker-compose run app ash -c 'cd /var/www/html && rails webpacker:install'

### Could not find mysql2...等のエラーが出たら下記のコマンドを実行する。もしくはDockerコンテナをビルドし直す
docker-compose run app ash -c 'cd /var/www/html && bundle install'

```

`config/database.yml`の設定は下記の通り行う

```yaml
default: &default
  adapter: mysql2
  encoding: utf8mb4
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  username: root
  password: <%= ENV['DATABASE_PASSWORD'] %>
  host: <%= ENV['DATABASE_HOST'] %>

development:
  <<: *default
  database: <%= ENV['DATABASE_NAME'] %>

test:
  <<: *default
  database: <%= ENV['DATABASE_NAME'] %>
```

### 環境変数の設定

`Gemfile`に下記の設定を追記する。

```Gemfile
# For .env
gem 'dotenv-rails'
```

プロジェクト直下に`.env`ファイルの作成

```shell
touch .env
```

---

### APIモードに途中から設定する

`config/application.rb`の設定は下記を追加する。(class Application内の直下)

```rb
config.api_only = true
```

---

### Modelの作成

下記のコマンドでModelを作成出来る。プロパティの指定も出来る。

```shell
rails generate model User name:string gender:string address:string
```

### Rails Consoleの実行

```shell
rails console
```

### ディレクトリの追加方法

名前空間の解決の為に、`/config/application.rb`に下記の設定を追加する。

設定を追加すれば`/app/libraries`内直下のクラスは`ClassName::Method`で実行出来る様になる。

```ruby
  class Application < Rails::Application
    # ...

    # 自動読み込みパスに下記のディレクトリを追加(/appディレクトリ内にlibraryディレクトリを追加)
    config.autoload_paths += Dir.glob("#{config.root}/app/libraries")
  end
```

### solargraph(Language Serverについて)

[About solargraph](https://github.com/castwide/vscode-solargraph)

---


## メールサーバーについて

[mailhog](https://github.com/mailhog/MailHog)を利用する。

データの永続化の為に専用のvolumeを新規で作成する。

最低限下記の形でdocker-compose.ymlに記載すれば良い。

コンテナ起動後は`http://localhost:8025/`でブラウザ上からメール情報を確認出来る。

```yaml
  mail:
    image: mailhog/mailhog
    container_name: container_name
    volumes:
      - volumeName:/tmp
    ports:
      - "8025:8025"
    environment:
      MH_MAILDIR_PATH: /tmp
```

`app/backend/.env`のメール設定を下記の通りに設定すること。

`MAIL_HOST`はデフォルトの値が`mailhog`になっているがDockerコンテナ名を設定する必要がある。

* 実際のSMTPでは、port:1025で受け付けている為8025ではなく1025にする必要がある。

```shell
MAIL_MAILER=smtp
MAIL_HOST=mail
MAIL_PORT=1025
```

---

# Redis

### メモリ情報等の確認

```shell
redis-cli info

# Memory
used_memory:1179368 # redisによって割り当てられたバイト数
used_memory_human:1.12M
used_memory_rss:7544832
used_memory_rss_human:7.20M
used_memory_peak:1179368
used_memory_peak_human:1.12M
used_memory_peak_perc:100.11%
used_memory_overhead:916012
used_memory_startup:894848
used_memory_dataset:263356
```

---

# 構成



---

