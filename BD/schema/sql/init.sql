DROP TABLE IF EXISTS public.account;
DROP TABLE IF EXISTS public.role;
DROP TABLE IF EXISTS public.success_auth;
DROP TABLE IF EXISTS public.failed_auth;

-- アカウントテーブル
-- ユーザの登録済みアカウント情報
CREATE TABLE IF NOT EXISTS public.account (
  username VARCHAR(256) PRIMARY KEY, -- メールアドレス
  password VARCHAR(60) NOT NULL, -- パスワード
  roles VARCHAR(30)[] NOT NULL, -- 権限
  is_locked BOOLEAN NOT NULL, -- アカウントロック
	created_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- 作成日時
	updated_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP -- 更新日時
);
ALTER TABLE public.account OWNER TO postgres; -- 所有者設定

-- 権限
-- 認可に使用する権限
CREATE TABLE IF NOT EXISTS public.role (
  role_value VARCHAR(30) NOT NULL, -- ロール値
  role_label VARCHAR(30) NOT NULL -- ロールラベル
);
ALTER TABLE public.role OWNER TO postgres; -- 所有者設定

-- 認証成功イベント
-- アカウントの最終ログイン日時を取得するために、認証成功時に残す情報
CREATE TABLE IF NOT EXISTS public.success_auth (
  username VARCHAR(256), -- メールアドレス
  auth_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- ログインに成功した日時
  FOREIGN KEY (username) REFERENCES public.account(username),
  PRIMARY KEY(username, auth_ts)
);
ALTER TABLE public.success_auth OWNER TO postgres; -- 所有者設定

-- 認証失敗イベント
-- アカウントのロックアウト機能で用いるために、認証失敗時に残す情報
CREATE TABLE IF NOT EXISTS public.failed_auth (
  username VARCHAR(256), -- メールアドレス
  auth_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- ログインに成功した日時
  FOREIGN KEY (username) REFERENCES public.account(username),
  PRIMARY KEY(username, auth_ts)
);
ALTER TABLE public.failed_auth OWNER TO postgres; -- 所有者設定
