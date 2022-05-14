DROP USER IF EXISTS ghuser;

DROP TABLE IF EXISTS public.account;

DROP TABLE IF EXISTS public.oauth_provider;

DROP TABLE IF EXISTS public.roles;

DROP TABLE IF EXISTS public.success_auth;

DROP TABLE IF EXISTS public.failed_auth;

DROP TABLE IF EXISTS public.planned_task;

DROP TABLE IF EXISTS public.executed_task;

DROP TABLE IF EXISTS public.mergin_time;

CREATE ROLE ghuser WITH LOGIN SUPERUSER CREATEDB CREATEROLE INHERIT NOREPLICATION CONNECTION
LIMIT
  -1 PASSWORD 'ghpass';

CREATE TABLE IF NOT EXISTS public.oauth_provider (id SMALLINT PRIMARY KEY, types TEXT NOT NULL);

COMMENT ON TABLE public.oauth_provider IS 'OAuthプロバイダーを表すテーブルである。サービス開始前に事前に定義される。';

COMMENT ON COLUMN public.oauth_provider.id IS 'oauth_providerの識別子を表します。';

COMMENT ON COLUMN public.oauth_provider.types IS 'GOOGLE、TWITTER等の文字列を表します。';

ALTER TABLE
  public.oauth_provider OWNER TO ghuser;

CREATE TABLE IF NOT EXISTS public.timezones (
  name TEXT PRIMARY KEY,
  abbrev TEXT NOT NULL,
  utc_offset INTERVAL NOT NULL,
  is_dst boolean NOT NULL
);

COMMENT ON TABLE public.timezones IS 'タイムゾーンを表すテーブルである。サービス開始前に定義される。pg_timezone_nameと同じ内容となる。';

COMMENT ON COLUMN public.timezones.name IS '	時間帯名';

COMMENT ON COLUMN public.timezones.abbrev IS '	時間帯省略形';

COMMENT ON COLUMN public.timezones.utc_offset IS 'UTCからのオフセット(正はグリニッジより西側を意味する)';

COMMENT ON COLUMN public.timezones.is_dst IS '	現在夏時間である場合に真';

ALTER TABLE
  public.timezones OWNER TO ghuser;

CREATE TABLE IF NOT EXISTS public.account (
  id BIGSERIAL PRIMARY KEY,
  username VARCHAR(256) NOT NULL UNIQUE CHECK (username <> ''),
  password VARCHAR(60) CHECK (password <> ''),
  roles VARCHAR(30) [] NOT NULL,
  is_locked BOOLEAN NOT NULL,
  timezones_name TEXT NOT NULL DEFAULT 'Asia/Tokyo',
  oauth_provider_id SMALLINT,
  created_time TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_time TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (timezones_name) REFERENCES public.timezones(name) ON DELETE
  SET
    DEFAULT,
    FOREIGN KEY (oauth_provider_id) REFERENCES oauth_provider(id) ON DELETE
  SET
    NULL
);

COMMENT ON TABLE public.account IS 'アカウント情報。ユーザの登録済みアカウント情報を保持する。';

COMMENT ON COLUMN public.account.id IS 'アカウントID。';

COMMENT ON COLUMN public.account.username IS 'ユーザー名。メールアドレスの形式で保持する。ログインIDとしても使用される。';

COMMENT ON COLUMN public.account.password IS 'パスワード。ハッシュ化された状態で保持する。';

COMMENT ON COLUMN public.account.roles IS '権限。1アカウントで複数の権限を保有している';

COMMENT ON COLUMN public.account.is_locked IS 'アカウントロックBool値。true=ロックされている。false=ロックされていない';

COMMENT ON COLUMN public.account.timezones_name IS 'タイムゾーン';

COMMENT ON COLUMN public.account.oauth_provider_id IS 'OAuthプロバイダーのタイプを保持する。';

COMMENT ON COLUMN public.account.created_time IS '作成日時';

COMMENT ON COLUMN public.account.updated_time IS '更新日時';

ALTER TABLE
  public.account OWNER TO ghuser;

CREATE TABLE IF NOT EXISTS public.roles (
  role_label VARCHAR(30),
  role_value VARCHAR(30)
);

COMMENT ON TABLE public.roles IS '権限情報。認可に使用する権限。';

COMMENT ON COLUMN public.roles.role_value IS 'ロール値。';

COMMENT ON COLUMN public.roles.role_label IS 'ロール表示名。';

ALTER TABLE
  public.roles OWNER TO ghuser;

CREATE TABLE IF NOT EXISTS public.failed_auth (
  account_id BIGINT,
  auth_ts TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (account_id) REFERENCES public.account(id) ON DELETE CASCADE,
  PRIMARY KEY(account_id, auth_ts)
);

COMMENT ON TABLE public.failed_auth IS '認証失敗イベント。アカウントのロックアウト機能で用いるために、認証失敗時に残す情報';

COMMENT ON COLUMN public.failed_auth.account_id IS 'アカウントID。';

COMMENT ON COLUMN public.failed_auth.auth_ts IS '認証失敗時のタイムスタンプ';

ALTER TABLE
  public.failed_auth OWNER TO ghuser;

CREATE TABLE IF NOT EXISTS public.planned_task (
  id BIGSERIAL PRIMARY KEY,
  account_id BIGINT NOT NULL,
  title VARCHAR(100) NOT NULL CHECK (title <> ''),
  start_time TIMESTAMPTZ NOT NULL CHECK (
    CURRENT_TIMESTAMP <= start_time
    AND start_time < end_time
  ),
  end_time TIMESTAMPTZ NOT NULL CHECK (
    CURRENT_TIMESTAMP <= end_time
    AND start_time < end_time
  ),
  cost DECIMAL NOT NULL CHECK (0.0 < cost),
  FOREIGN KEY (account_id) REFERENCES public.account(id) ON DELETE CASCADE
);

COMMENT ON TABLE public.planned_task IS '計画済みタスク情報。';

COMMENT ON COLUMN public.planned_task.id IS '識別子。';

COMMENT ON COLUMN public.planned_task.account_id IS 'アカウントID。';

COMMENT ON COLUMN public.planned_task.title IS 'タイトル。';

COMMENT ON COLUMN public.planned_task.start_time IS '開始日時。';

COMMENT ON COLUMN public.planned_task.end_time IS '終了日時。';

COMMENT ON COLUMN public.planned_task.cost IS '金額';

ALTER TABLE
  public.planned_task OWNER TO ghuser;

CREATE TABLE IF NOT EXISTS public.executed_task (
  planned_task_id BIGINT PRIMARY KEY,
  started_time TIMESTAMPTZ,
  ended_time TIMESTAMPTZ,
  is_achieved BOOLEAN NOT NULL DEFAULT FALSE,
  is_cancelled BOOLEAN NOT NULL DEFAULT FALSE,
  FOREIGN KEY (planned_task_id) REFERENCES public.planned_task(id) ON DELETE CASCADE
);

COMMENT ON TABLE public.executed_task IS '実行済みタスク情報。';

COMMENT ON COLUMN public.executed_task.planned_task_id IS '計画済みタスクID。';

COMMENT ON COLUMN public.executed_task.started_time IS '開始された日時。';

COMMENT ON COLUMN public.executed_task.ended_time IS '終了された日時。';

COMMENT ON COLUMN public.executed_task.is_achieved IS '計画を予定通り実行できたか。true=達成, false=未達成';

COMMENT ON COLUMN public.executed_task.is_cancelled IS '運営がメンテナンス等の不可抗力で取り消しとなった状態を表す。 true=キャンセルされた, false=キャンセルされていない';

ALTER TABLE
  public.executed_task OWNER TO ghuser;

CREATE TABLE IF NOT EXISTS public.payment_job_history (
  planned_task_id BIGINT PRIMARY KEY,
  executed_time TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (planned_task_id) REFERENCES public.planned_task(id) ON DELETE CASCADE
);

COMMENT ON TABLE public.payment_job_history IS '支払いのジョブ履歴。';

COMMENT ON COLUMN public.payment_job_history.planned_task_id IS '計画済みタスクID。';

COMMENT ON COLUMN public.payment_job_history.executed_time IS 'ジョブが実行された日時。';

CREATE TABLE IF NOT EXISTS public.mergin_time (second INTERVAL NOT NULL);

COMMENT ON TABLE public.mergin_time IS 'タスク計画時の支払いが発生しないマージンの時間。例）計画済みタスク±5分が実行完了とするの時間。この±5分を表す。';

COMMENT ON COLUMN public.mergin_time.second IS '分。';

ALTER TABLE
  public.mergin_time OWNER TO ghuser;