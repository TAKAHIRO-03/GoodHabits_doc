# 基本設計書

## システム構成

物理サーバは用意せず、AWSのクラウドサービスを使用する。

* クライアント（SPAを想定）
![クライアント](./img/d2dedab2-0d79-0489-e45b-434d32bb8608.png) 

参考 [【AWS】S3+CloudFront+Route53+ACMでSSL化(https)した静的Webサイトを公開する](https://zenn.dev/wakkunn/articles/66a6e8372611dc)


* バックエンド
```plantuml
actor User
actor Admin
cloud Internet
node Stripe

cloud AWS {
  node InternetGateway
  node ACM
  node Route53
  node Datadog

  frame Public.subnet {
    node ALB
    node NatGateway
  }
  frame Private.subnet {
    frame Fargate {
      frame backendservice {
        node TaskApp
        node TaskJob
        node DatadogAgent
      }
    }
    node RDS
    node ElastiCache
  }
  node SES
}

Admin --[#red]> Internet
Internet --[#red]> Datadog
User --[#red]> Internet: RESTAPI
Internet --[#red]> Route53
Route53 --[#red]> InternetGateway
InternetGateway --[#red]> ALB
ALB --[#red]> TaskApp
TaskApp --[#red]> RDS
TaskApp --[#red]> SES
TaskApp --[#red]> ElastiCache
TaskJob --[#blue]> RDS
TaskJob --[#blue]> NatGateway
NatGateway --[#blue]> InternetGateway
InternetGateway --[#blue]> Internet
Internet --[#blue]> Stripe
DatadogAgent --[#blue]> Datadog
Datadog --[#blue]> Admin: アラーム通知

node Comment
note top of Comment
赤矢印・・・Internet起点の通信の流れ
青矢印・・・AWS起点の通信の流れ
User・・・GoodHabitsを利用するユーザー
ACM・・・SSL証明書のサービス
Internet・・・インターネット回線
Stripe・・決済処理を行う外部サービス
Route53・・・DNSサーバー
InternetGateway・・・VPCとインターネット間の接続端点
NatGateway・・・プライベートサブネットから外部接続単点
ALB・・・ロードバランサー
TaskApp・・・RESTAPIサーバーコンテナ
TaskJob・・・バッチジョブコンテナ
RDS・・・データベース
ElastiCache・・・NoSQL
SES・・・メールサーバー
DatadogAgent・・・ログを収集及び転送するエージェント
Datadog・・・ログの転送先

end note

```

## NW構成

* アクセスポイント一覧

| サーバ端点                   | ドメイン         | IPアドレス | ポート        | 外部公開 | 備考  |
| ----------------------- | ------------ | ------ | ---------- | ---- | --- |
| クライアント:Route53          | goodhabits.com | 未定     | 443        | 〇    |     |
| バックエンド:Route53          | デフォルト        | 未定     | 443        | 〇    |     |
| バックエンド:InternetGateway | デフォルト        | 未定     | 443        | 〇    |     |
| バックエンド:NATGateway       | デフォルト        | 未定     | 未定       | 〇    |     |
| バックエンド:ALB              | デフォルト        | 未定     | 443        | 〇    |     |
| バックエンド:TaskApp          | デフォルト        | 未定     | 8080 or 80 | ×    |     |
| バックエンド:TaskJob          | デフォルト        | 未定     | 8080 or 80 | ×    |     |
| バックエンド:RDS              | デフォルト        | 未定     | 5432       | ×    |     |
| バックエンド:ElastiCache      | デフォルト        | 未定     | 6379       | ×    |     |
| バックエンド:SES              | デフォルト        | 未定     | 465 or 2645  | ×    |     |


## ユースケース
* アカウント登録
  * GoodHabitsにアクセスしアカウント登録出来る。
  * アカウント登録時に確認メールがユーザーの元に届き承認を押すと本登録が完了する。
* ログイン
  * GoodHabitsにアクセスしログイン出来る。
* プロフィール編集
  * ユーザーは自分のパスワード及びクレジットカード情報を変更出来る。
  * ユーザーはタスクの通知設定が出来る。
* パスワード再設定
  * ユーザーがパスワードを忘れた場合はパスワード再設定を申請し、再登録出来る。
* タスク計画
  * 開始、終了時間、タスクの内容を決め、支払う金額を決め、タスクを計画することが出来る。
  * タスク計画は1年先までを繰り返し設定することが出来る。
  * 計画したタスクを開始の15分前までキャンセルすることが出来る。
  * タスク計画時にユーザーにメールを通知する。
* タスク通知
  * ブラウザのPush通知及びメールの通知を受信することが出来る。
* タスク開始・完了
  * 画面にあるストップウォッチを基にタスクを開始、終了することが出来る。
* タスク実行履歴
  * 累計のタスク実行履歴を行った履歴を確認出来る。
* 退会
  * GoodHabitsを退会することが出来る。

## 機能一覧
* アカウント登録機能
  * ニックネーム、メールアドレス、パスワードを入力し、アカウントを登録する。
  * アカウント登録処理を実行した際は、GoodHabits側からユーザーにメールを送信し本人であるかを認証する。
  * パスワードは2回入力し、誤ったパスワードが入力されないようにする。
  * 認証は24時間以内とする。認証されずに24時間経過した場合、DBに保存されているデータは削除する。
* ログイン機能
  * ログイン時にサーバーからJWTとリフレッシュトークンを払い出しクライアント側で持ちまわす。
  * JWTの有効期限は30分とし、リフレッシュトークンは1か月とする。
  * 複数の端末からはログイン出来ないようにする。後からログインしたユーザーを常に優先し、前にログインしていた端末からはログアウトされる（後勝ち）。
  * ログイン試行回数は5回。5回を超えたら30分ログイン出来なくなる。
* プロフィール編集機能
  * ログイン中にパスワード、通知を変更する。
  * クレジットカードを登録・更新することが出来る。尚、サーバー側ではクレジットカード情報は保持しない。
* パスワード再設定機能
  * ユーザーがパスワードを忘れた場合は、メール経由で再設定する。
    * パスワードの再設定は24時間以内とする。パスワード再設定がされずに24時間経過した場合、DBに保存されているデータは削除する。
* タスク計画機能
  * ユーザーが開始時間と終了時間、タスク内容を入力後、運営にお金を支払う。計画の時点では決済処理はされない。
  * タスク計画時にユーザーにメールを送信する。複数タスクを同時に計画した場合は1件のみの通知とする。
  * タスク登録時に当該タスクを繰り返し登録出来る。尚、1年先までとする。例）1週間 毎日9時にランニングを行う。
  * 計画しているタスクを確認出来る。
* タスク通知機能
  * ユーザーが計画したタスク通知をPush通知及びメール通知をする。
* タスク開始・完了機能
  * 画面上にストップウォッチと開始ボタンと終了ボタンがある。開始ボタンを押下するとタスクが開始され、画面上のストップウォッチは進む。タスクを計画した時間が経過したら、タスクを終了した旨を表示する。終了ボタン押下することにより、タスクが完了となる。サーバーでは、開始時間と終了時間の差分が計画したときの時間の前後5分の間であれば、タスクを正常に完了したと判断する。
* タスク実行履歴確認機能
  * 今まで実行したタスクを確認することが出来る。
  * 棒グラフ等で視覚的に見れる。
* 退会機能
  * 画面に表示されている退会ボタンを押下することによりGoodHabitsを退会することが出来る。
  * GoodHabitsで保持しているデータは全て物理削除される。

## バッチジョブ一覧
* 決済処理
  * ペナルティとなるユーザーの決済処理を実行する。
  * バッチジョブの対象となる条件は以下となる（ユースケース：条件式）。
    * サボった : ジョブ履歴に残っていない かつ タスクが開始・終了されていない かつ 計画の終了日時がジョブの実行時間より過去
    * 終了ボタンを押し忘れた : ジョブ履歴に残っていない かつ タスクが開始されている かつ タスクが終了していない かつ 計画の終了日時と現在時刻の差が5分以上 かつ 計画の終了日時がジョブの実行時間より過去
    * 計画された時間内に出来なかった : ジョブ履歴に残っていない かつ タスクが開始・終了されている かつ 未達成 かつ 計画の終了日時がジョブの実行時間より過去

## ソフトウェア構成

```plantuml
actor User

frame frontend {
  node React
}

frame backend {
  node SpringBoot
  node SpringBatch
  node DatadogAgent
}

frame DB {
  node Redis
  node PostgreSQL
}

frame 外部サービス {
  node Stripe
  node Datadog
}

User --> React
User --> SpringBoot
SpringBoot --> PostgreSQL
SpringBoot --> Redis
SpringBatch --> PostgreSQL
SpringBatch --> Stripe
```

商用環境はS3を静的ホスティングしてファイルを配置、backendはAWSのFargate上にTaskとして構築する。

| FW/ライブラリ/言語 | バージョン  | 役割                         |
| ----------- | ------ | -------------------------- |
| React       | 18.1.0 | 画面表示FW                       |
| TypeScript  | 4.5    | 画面表示言語                       |
| SpringBoot  | 2.5.13 | WebサーバーFW                 |
| SpringBatch | 4.3.5  | バッチ処理                      |
| Java        | 17     | Webサーバー・バッチ処理言語         |
| PostgreSQL  | 13.6   | データストア                     |
| Redis       | 6.2.6  | 揮発性データを格納するデータストア |

2022/04/29 時点での最新または安定バージョンを選定

## エラー方針
* クライアントサイド、サーバサイド両方で入力値チェックをする。
* エラーメッセージは、クライアントサイド、サーバサイド両方で持つ。クライアントで完結するエラーの場合は、クライアントサイドで持っているエラーメッセージを表示し、サーバからエラーのレスポンスが返却された場合は、その情報を表示する。

## セキュリティ方針
* クライアントからの入力値をそのままサーバ側でSQL発行に使わない（SQLインジェクション対策）。
```
例）
   NG：
    Query query = em.createQuery("SELECT b FROM Book b WHERE b.title = '" + param + "'");
    List<Book> books = query.getResultList();
    return books.size();

   OK：
    Query query = em.createQuery("SELECT b FROM Book b WHERE b.title = :param");
    query.setParameter("param", param);
    List<Book> books = query.getResultList();
    return books.size();

paramは必ずプレースホルダー（:param）にバインド（割り当てる）する。
```

* 認証については、JWTとリフレッシュトークンの実装を行う。

[SPAのログイン認証のベストプラクティスがわからなかったのでわりと網羅的に研究してみた〜JWT or Session どっち？〜](https://qiita.com/Hiro-mi/items/18e00060a0f8654f49d6)

## ログ方針
* GoodHabitsにアクセス出来ないことが理由で、ユーザーにペナルティが発生した場合をデバッグログからトレース出来ること。
* Datadogを用いて、アラートメールもしくはSlack等で通知すること。

## ブラウザ
* Google ChromeのOSを想定して作る

## 画面サイズ

端末 画面サイズ

