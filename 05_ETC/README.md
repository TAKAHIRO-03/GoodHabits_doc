# 環境構築

## 前提条件
* Docker Desktopがインストール済みであること。
* 以下のディレクトリ構成となっていること
```
./GoodHabits/GoodHabitsClient
./GoodHabits/GoodHabitsServer
./GoodHabits/GoodHabitsDoc
```
* リポジトリは以下
  * [GoodHabitsClient](https://github.com/TAKAHIRO-03/GoodHabitsClient) 
  * [GoodHabitsServer](https://github.com/TAKAHIRO-03/GoodHabitsServer)
  * [GoodHabitsDoc](https://github.com/TAKAHIRO-03/GoodHabitsDoc) 

## コマンド
```
GoodHabitsDoc/05_ETC $ pwd
/c/workspace/GoodHabits/GoodHabitsDoc/05_ETC

GoodHabitsDoc/05_ETC $ bash run.sh -b # RESTAPIサーバとクライアントコンテナのビルド

...

GoodHabitsDoc/05_ETC $ bash run.sh -s # 全コンテナスタート

GoodHabitsDoc/05_ETC $ bash run.sh -d # 全コンテナ削除

GoodHabitsDoc/05_ETC $ bash run.sh -r # 全コンテナ再起動

```

## ポート
| 論理名                    | コンテナ名       | ポート                 |
| ---------------------- | ----------- | ------------------- |
| クライアント(React)          | client-ctr  | 8888                |
| RESTAPIサーバ(SpringBoot) | server-ctr  | 8080 ※debugポートは8000 |
| RDB（PostgreSQL）        | rdb-ctr     | 5432                |
| NoSQL(Redis)           | nosql-ctr   | 6379                |
| DatadogAgent           | datadog-ctr | -                   |
| メールサーバ(MailHog)        | mail-ctr    | 8025                    |

"ホストポート：コンテナポート"は同じポート番号でマッピングしているため、``localhost:8080``等で通信をすることが可能。