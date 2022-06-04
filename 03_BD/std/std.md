# 画面遷移図補足

## 概要
std.uifの中に記載のあるエンドポイントまたは名称の補足となる。

## 各種エンドポイントと名称の説明

| 論理名             | エンドポイントまたは名称                          | 認証要否 | 表示形式   |
| --------------- | ------------------------------------- | ---- | ------ |
| ホーム画面ヘッダー       | home_header                           | ×    | 画面     |
| ホーム画面ボディ        | home_body                             | ×    | 画面     |
| ホーム画面フッター       | home_footer                           | ×    | 画面     |
| インスタグラム         | Instagram                             | ×    | 画面     |
| ツイッター           | Twitter                               | ×    | 画面     |
| 運営会社画面          | /company                              | ×    | 画面     |
| プライバシーポリシー画面    | /pp                                   | ×    | 画面     |
| 特定商取引法に基づく表記画面  | /asct                                 | ×    | 画面     |
| メールアプリ起動画面      | mail app                              | ×    | メールアプリ |
| ログインと新規登録画面     | /signin                               | ×    | 画面     |
| ログイン画面          | /login                                | ×    | 画面     |
| 新規登録画面          | /signup                               | ×    | 画面     |
| 新規登録時の認証画面      | Authentication                        | ×    | ポップアップ |
| 新規登録メール認証画面     | /auth/account?authToken=hogehog       | ×    | 画面     |
| パスワード再発行画面      | /reissuePass                       | ×    | 画面     |
| パスワード再発行受付完了画面  | Authentication Pass                   | ×    | ポップアップ |
| パスワード再発行メール認証画面 | /auth/reissuePass?authToken=hogehoge | ×    | 画面     |
| 習慣一覧画面         | /habits                                 | 〇    | 画面     |
| 習慣新規登録画面       | /habits/create                              | 〇    | 画面  |
| 習慣計画方法画面       | /howto                                | 〇    | 画面     |
| 習慣一覧画面ヘッダー     | plan_header                           | 〇    | 画面     |
| 習慣履歴           | /habits/history                              | 〇    | 画面     |
| パスワード変更画面       | /newpass                              | 〇    | 画面     |
| クレジットカード変更画面    | /payment                               | 〇    | 画面  |
| ログアウト完了画面       | Logout                                | 〇    | ポップアップ |
| 退会完了画面          | Quit                                  | 〇    | ポップアップ |
| NotFound画面      | /notfound                             | ×    | 画面     |
| メンテナンス画面        | /maintenance                          | ×    | 画面     |
| Googleログイン画面    | GoogleAuth                            | ×    | 画面     |
