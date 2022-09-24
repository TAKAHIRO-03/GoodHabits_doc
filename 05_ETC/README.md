# 環境構築

## 前提条件

- Docker Desktop がインストール済みであること。
- 以下のディレクトリ構成となっていること

```
./HaveTodo/HaveTodoClient
./HaveTodo/HaveTodoServer
./HaveTodo/HaveTodoDoc
```

- リポジトリは以下
  - [HaveTodoClient](https://github.com/TAKAHIRO-03/HaveTodoClient)
  - [HaveTodoServer](https://github.com/TAKAHIRO-03/HaveTodoServer)
  - [HaveTodoDoc](https://github.com/TAKAHIRO-03/HaveTodoDoc)

## コマンド

```
HaveTodoDoc/05_ETC $ pwd
/c/workspace/HaveTodo/HaveTodoDoc/05_ETC

HaveTodoDoc/05_ETC $ bash run.sh -b # RESTAPIサーバとクライアントコンテナのビルド

...

HaveTodoDoc/05_ETC $ bash run.sh -s # 全コンテナスタート

HaveTodoDoc/05_ETC $ bash run.sh -d # 全コンテナ削除

HaveTodoDoc/05_ETC $ bash run.sh -r # 全コンテナ再起動

```

## ポート

| 論理名                     | コンテナ名  | ポート |
| -------------------------- | ----------- | ------ |
| クライアント(React)        | client-ctr  | 8888   |
| RESTAPI サーバ(SpringBoot) | server-ctr  | 8080   |
| RDB（PostgreSQL）          | rdb-ctr     | 5432   |
| NoSQL(Redis)               | nosql-ctr   | 6379   |
| DatadogAgent               | datadog-ctr | -      |
| MailHog                    | mail-ctr    | 8025   |
| E2E テスト(Cypress)        | e2e-ctr     | -      |

"ホストポート：コンテナポート"は同じポート番号でマッピングしているため、`localhost:8080`等で通信をすることが可能。

## E2Eテスト実行コマンド
```
$ ~ docker exec e2e-ctr sh -c "npm run cy:run"
```