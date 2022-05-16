#!/bin/bash

function usage {
  cat <<EOM
Usage: $(basename "$0") [OPTION]...
  -h          Display help
  -b          Build server container
  -d          Delete container
  -s          Start Container
EOM

  exit 2
}

while getopts "sbdrh" optKey; do
  case "$optKey" in
    b)
      docker build -t goodhabits/client:latest ../../GoodHabitsClient
      cd ../../GoodHabitsServer && ./mvnw compile jib:dockerBuild && cd "$PWD"
      echo "Builded containers."
      exit 0
      ;;
    d)
      docker-compose -p goodhabits down --volumes --remove-orphans # コンテナ等削除
      docker-compose -p goodhabits ps # プロセス確認
      echo ""
      echo "Deleted containers."
      exit 0
      ;;
    r)
      docker-compose -p goodhabits restart
      docker-compose -p goodhabits ps # プロセス確認
      echo ""
      echo "Restarted containers."
      exit 0
      ;;
    s)
      docker-compose -p goodhabits up -d # 各コンテナ実行
      sleep 3 # 開始ログを出力するために少しスリープ
      docker-compose -p goodhabits ps # プロセス確認
      echo ""
      echo "Start containers."
      exit 0
      ;;
    '-h'|'--help'|* )
      usage
      ;;
  esac
done

echo "You must specify option \"-s\" \"-b\" \"-d\" \"-h\""
usage
