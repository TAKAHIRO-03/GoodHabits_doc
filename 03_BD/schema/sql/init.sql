DROP TABLE IF EXISTS public.account;

DROP TABLE IF EXISTS public.oauth_provider;

DROP TABLE IF EXISTS public.timezones;

DROP TABLE IF EXISTS public.currency;

DROP TABLE IF EXISTS public.roles;

DROP TABLE IF EXISTS public.success_auth;

DROP TABLE IF EXISTS public.failed_auth;

DROP TABLE IF EXISTS public.planned_habit;

DROP TABLE IF EXISTS public.executed_habit;

DROP TABLE IF EXISTS public.margin_time;

DROP TABLE IF EXISTS public.maintenance_plan;

CREATE TABLE IF NOT EXISTS public.oauth_provider (id SMALLINT PRIMARY KEY, types TEXT NOT NULL);

COMMENT ON TABLE public.oauth_provider IS 'OAuthプロバイダー。サービス開始前に定義される。';

COMMENT ON COLUMN public.oauth_provider.id IS 'oauth_providerの識別子を表します。';

COMMENT ON COLUMN public.oauth_provider.types IS 'GOOGLE、TWITTER等の文字列を表します。';

ALTER TABLE
  public.oauth_provider OWNER TO ghuser;

CREATE TABLE IF NOT EXISTS public.timezones (
  name TEXT PRIMARY KEY,
  abbrev TEXT NOT NULL,
  utc_offset INTERVAL NOT NULL,
  is_dst BOOLEAN NOT NULL
);

COMMENT ON TABLE public.timezones IS 'タイムゾーン。サービス開始前に定義される。pg_timezone_nameと同じ内容となる。';

COMMENT ON COLUMN public.timezones.name IS '	時間帯名';

COMMENT ON COLUMN public.timezones.abbrev IS '	時間帯省略形';

COMMENT ON COLUMN public.timezones.utc_offset IS 'UTCからのオフセット(正はグリニッジより西側を意味する)';

COMMENT ON COLUMN public.timezones.is_dst IS '	現在夏時間である場合に真';

ALTER TABLE
  public.timezones OWNER TO ghuser;

CREATE TABLE IF NOT EXISTS public.currency (
  iso_code TEXT PRIMARY KEY,
  country TEXT NOT NULL,
  sign TEXT NOT NULL,
  name TEXT NOT NULL
);

COMMENT ON TABLE public.currency IS '通貨。サービス開始前に定義される。';

COMMENT ON COLUMN public.currency.iso_code IS 'ISOコード 例）JPY';

COMMENT ON COLUMN public.currency.country IS '国名 例）日本';

COMMENT ON COLUMN public.currency.sign IS '通貨記号 例）￥';

COMMENT ON COLUMN public.currency.name IS '通貨名 例）円';

ALTER TABLE
  public.currency OWNER TO ghuser;

CREATE TABLE IF NOT EXISTS public.account (
  id BIGSERIAL PRIMARY KEY,
  username VARCHAR(256) NOT NULL UNIQUE CHECK (username <> ''),
  password VARCHAR(60) CHECK (password <> ''),
  roles VARCHAR(30) [] NOT NULL,
  is_locked BOOLEAN NOT NULL,
  timezones_name TEXT NOT NULL DEFAULT 'Asia/Tokyo',
  currency_iso_code TEXT NOT NULL DEFAULT 'JPY',
  oauth_provider_id SMALLINT,
  created_time TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_time TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (timezones_name) REFERENCES public.timezones(name) ON DELETE
  SET
    DEFAULT,
    FOREIGN KEY (currency_iso_code) REFERENCES public.currency(iso_code) ON DELETE
  SET
    DEFAULT,
    FOREIGN KEY (oauth_provider_id) REFERENCES oauth_provider(id) ON DELETE
  SET
    NULL
);

COMMENT ON TABLE public.account IS 'アカウント情報。';

COMMENT ON COLUMN public.account.id IS 'アカウントID。';

COMMENT ON COLUMN public.account.username IS 'ユーザー名。メールアドレスの形式で保持する。ログインIDとしても使用される。';

COMMENT ON COLUMN public.account.password IS 'パスワード。ハッシュ化された状態で保持する。';

COMMENT ON COLUMN public.account.roles IS '権限。1アカウントで複数の権限を保有している。';

COMMENT ON COLUMN public.account.is_locked IS 'アカウントロックBool値。true=ロックされている。false=ロックされていない。';

COMMENT ON COLUMN public.account.timezones_name IS 'タイムゾーン。';

COMMENT ON COLUMN public.account.currency_iso_code IS '習慣計画時のお金を払う際の通貨。';

COMMENT ON COLUMN public.account.oauth_provider_id IS 'OAuthプロバイダーのタイプ。';

COMMENT ON COLUMN public.account.created_time IS '作成日時。';

COMMENT ON COLUMN public.account.updated_time IS '更新日時。';

ALTER TABLE
  public.account OWNER TO ghuser;

CREATE TABLE IF NOT EXISTS public.roles (
  id SMALLINT PRIMARY KEY,
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

COMMENT ON TABLE public.failed_auth IS '認証失敗イベント。アカウントのロックアウト機能で用いるために、認証失敗時に残す情報。';

COMMENT ON COLUMN public.failed_auth.account_id IS 'アカウントID。';

COMMENT ON COLUMN public.failed_auth.auth_ts IS '認証失敗時の時間。';

ALTER TABLE
  public.failed_auth OWNER TO ghuser;

CREATE TABLE IF NOT EXISTS public.planned_habit (
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

COMMENT ON TABLE public.planned_habit IS '計画済み習慣情報。';

COMMENT ON COLUMN public.planned_habit.id IS '識別子。';

COMMENT ON COLUMN public.planned_habit.account_id IS 'アカウントID。';

COMMENT ON COLUMN public.planned_habit.title IS 'タイトル。';

COMMENT ON COLUMN public.planned_habit.start_time IS '開始日時。';

COMMENT ON COLUMN public.planned_habit.end_time IS '終了日時。';

COMMENT ON COLUMN public.planned_habit.cost IS '金額。';

ALTER TABLE
  public.planned_habit OWNER TO ghuser;

CREATE TABLE IF NOT EXISTS public.executed_habit (
  planned_habit_id BIGINT PRIMARY KEY,
  started_time TIMESTAMPTZ,
  ended_time TIMESTAMPTZ,
  is_achieved BOOLEAN NOT NULL DEFAULT FALSE,
  is_cancelled BOOLEAN NOT NULL DEFAULT FALSE,
  FOREIGN KEY (planned_habit_id) REFERENCES public.planned_habit(id) ON DELETE CASCADE
);

COMMENT ON TABLE public.executed_habit IS '実行済み習慣情報。';

COMMENT ON COLUMN public.executed_habit.planned_habit_id IS '計画済み習慣ID。';

COMMENT ON COLUMN public.executed_habit.started_time IS '開始された日時。NULL=開始されていない。';

COMMENT ON COLUMN public.executed_habit.ended_time IS '終了された日時。NULL=終了していない。';

COMMENT ON COLUMN public.executed_habit.is_achieved IS '計画を予定通り実行できたか。true=達成, false=未達成。';

COMMENT ON COLUMN public.executed_habit.is_cancelled IS '運営がメンテナンス等の不可抗力で取り消しとなった状態を表す。 true=キャンセルされた, false=キャンセルされていない。';

ALTER TABLE
  public.executed_habit OWNER TO ghuser;

CREATE TABLE IF NOT EXISTS public.payment_job_history (
  planned_habit_id BIGINT PRIMARY KEY,
  executed_time TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (planned_habit_id) REFERENCES public.planned_habit(id) ON DELETE CASCADE
);

COMMENT ON TABLE public.payment_job_history IS '支払いのジョブ履歴。';

COMMENT ON COLUMN public.payment_job_history.planned_habit_id IS '計画済み習慣ID。';

COMMENT ON COLUMN public.payment_job_history.executed_time IS 'ジョブが実行された日時。';

CREATE TABLE IF NOT EXISTS public.margin_time (
  id SMALLINT PRIMARY KEY,
  completed_margin INTERVAL NOT NULL,
  cancel_margin INTERVAL NOT NULL
);

COMMENT ON TABLE public.margin_time IS 'マージンの時間。単位は分。例）計画済み習慣±5分が実行完了とするの時間。この±5分を表す。';

COMMENT ON COLUMN public.margin_time.completed_margin IS '計画済み習慣の実行完了となる時間。';

COMMENT ON COLUMN public.margin_time.cancel_margin IS 'キャンセルすることが出来る時間。';

ALTER TABLE
  public.margin_time OWNER TO ghuser;

CREATE TABLE IF NOT EXISTS public.maintenance_plan (
  id SMALLSERIAL PRIMARY KEY,
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ NOT NULL
);

COMMENT ON TABLE public.maintenance_plan IS '運営のメンテナンス計画。';

COMMENT ON COLUMN public.maintenance_plan.start_time IS 'メンテナンス開始時間';

COMMENT ON COLUMN public.maintenance_plan.end_time IS 'メンテナンス終了時間';

ALTER TABLE
  public.maintenance_plan OWNER TO ghuser;
