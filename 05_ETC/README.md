# 環境構築

## 前提条件
* Docker Desktopがインストール済みであること。
* 以下のディレクトリ構成となっていること
```
./GoodHabitsClient
./GoodHabitsServer
./GoodHabitsDoc
```

## コマンド
```
GoodHabitsDoc/05_ETC $ pwd
/c/workspace/GoodHabits/GoodHabitsDoc/05_ETC

GoodHabitsDoc/05_ETC $ run.sh -b # コンテナのビルド

...

GoodHabitsDoc/05_ETC $ run.sh -s # コンテナスタート
```