-- 振替伝票作成Webアプリケーション データベーススキーマ
-- SQLite 3.43+ 対応
-- 文字エンコーディング: UTF-8

-- プラグマ設定
PRAGMA foreign_keys = ON;
PRAGMA journal_mode = WAL;
PRAGMA synchronous = NORMAL;
PRAGMA temp_store = memory;
PRAGMA mmap_size = 268435456; -- 256MB

-- 振替伝票テーブル
CREATE TABLE furikae_denpyo (
    id TEXT PRIMARY KEY CHECK (length(id) = 36), -- UUID v4 format
    date TEXT NOT NULL CHECK (date MATCH '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'), -- YYYY-MM-DD
    number TEXT CHECK (length(number) <= 20 AND number GLOB '[A-Za-z0-9]*'),
    created_at TEXT NOT NULL DEFAULT (datetime('now', 'utc')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now', 'utc'))
);

-- 勘定科目テーブル
CREATE TABLE accounts (
    id TEXT PRIMARY KEY CHECK (length(id) = 36), -- UUID v4 format
    code TEXT UNIQUE NOT NULL CHECK (length(code) <= 10 AND code GLOB '[A-Z0-9_]*'),
    name TEXT NOT NULL CHECK (length(name) <= 50 AND length(trim(name)) > 0),
    type TEXT NOT NULL CHECK (type IN ('asset', 'liability', 'equity', 'revenue', 'expense', 'other')),
    is_system BOOLEAN NOT NULL DEFAULT FALSE,
    sort_order INTEGER NOT NULL CHECK (sort_order > 0)
);

-- 仕訳明細テーブル
CREATE TABLE shiwake_entries (
    id TEXT PRIMARY KEY CHECK (length(id) = 36), -- UUID v4 format
    denpyo_id TEXT NOT NULL,
    side TEXT NOT NULL CHECK (side IN ('debit', 'credit')),
    account_id TEXT NOT NULL,
    account_custom TEXT CHECK (length(account_custom) <= 50),
    amount INTEGER NOT NULL CHECK (amount > 0 AND amount <= 9999999999),
    description TEXT NOT NULL CHECK (length(description) <= 200 AND length(trim(description)) > 0),
    FOREIGN KEY (denpyo_id) REFERENCES furikae_denpyo(id) ON DELETE CASCADE,
    FOREIGN KEY (account_id) REFERENCES accounts(id),
    CHECK (
        (account_id = 'OTHER' AND account_custom IS NOT NULL AND length(trim(account_custom)) > 0) OR
        (account_id != 'OTHER' AND account_custom IS NULL)
    )
);

-- アプリケーション設定テーブル
CREATE TABLE app_config (
    id TEXT PRIMARY KEY DEFAULT 'app' CHECK (id = 'app'),
    password_hash TEXT CHECK (length(password_hash) = 60), -- bcrypt hash length
    created_at TEXT NOT NULL DEFAULT (datetime('now', 'utc')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now', 'utc'))
);

-- インデックス作成
CREATE INDEX idx_denpyo_date ON furikae_denpyo(date DESC);
CREATE INDEX idx_denpyo_created ON furikae_denpyo(created_at DESC);
CREATE INDEX idx_entries_denpyo ON shiwake_entries(denpyo_id);
CREATE INDEX idx_entries_account ON shiwake_entries(account_id);
CREATE INDEX idx_accounts_type_sort ON accounts(type, sort_order);
CREATE INDEX idx_accounts_system ON accounts(is_system, sort_order);

-- 更新日時自動更新トリガー
CREATE TRIGGER update_denpyo_timestamp 
    AFTER UPDATE ON furikae_denpyo
    FOR EACH ROW
BEGIN
    UPDATE furikae_denpyo 
    SET updated_at = datetime('now', 'utc') 
    WHERE id = NEW.id;
END;

CREATE TRIGGER update_config_timestamp 
    AFTER UPDATE ON app_config
    FOR EACH ROW
BEGIN
    UPDATE app_config 
    SET updated_at = datetime('now', 'utc') 
    WHERE id = NEW.id;
END;

-- 借方・貸方残高チェック用ビュー
CREATE VIEW denpyo_balance_check AS
SELECT 
    d.id,
    d.date,
    d.number,
    COALESCE(debit_sum.total, 0) as debit_total,
    COALESCE(credit_sum.total, 0) as credit_total,
    CASE 
        WHEN COALESCE(debit_sum.total, 0) = COALESCE(credit_sum.total, 0) 
        THEN 1 
        ELSE 0 
    END as is_balanced,
    ABS(COALESCE(debit_sum.total, 0) - COALESCE(credit_sum.total, 0)) as difference
FROM furikae_denpyo d
LEFT JOIN (
    SELECT denpyo_id, SUM(amount) as total
    FROM shiwake_entries 
    WHERE side = 'debit'
    GROUP BY denpyo_id
) debit_sum ON d.id = debit_sum.denpyo_id
LEFT JOIN (
    SELECT denpyo_id, SUM(amount) as total
    FROM shiwake_entries 
    WHERE side = 'credit'
    GROUP BY denpyo_id
) credit_sum ON d.id = credit_sum.denpyo_id;

-- 勘定科目別集計ビュー
CREATE VIEW account_summary AS
SELECT 
    a.id,
    a.code,
    a.name,
    a.type,
    COUNT(se.id) as usage_count,
    COALESCE(SUM(CASE WHEN se.side = 'debit' THEN se.amount ELSE 0 END), 0) as debit_total,
    COALESCE(SUM(CASE WHEN se.side = 'credit' THEN se.amount ELSE 0 END), 0) as credit_total
FROM accounts a
LEFT JOIN shiwake_entries se ON a.id = se.account_id
GROUP BY a.id, a.code, a.name, a.type;

-- 初期データ: システム定義勘定科目
INSERT INTO accounts (id, code, name, type, is_system, sort_order) VALUES
('550e8400-e29b-41d4-a716-446655440000', 'CASH', '現金', 'asset', TRUE, 100),
('550e8400-e29b-41d4-a716-446655440001', 'BANK', '普通預金', 'asset', TRUE, 110),
('550e8400-e29b-41d4-a716-446655440002', 'BANK_SAVING', '定期預金', 'asset', TRUE, 120),
('550e8400-e29b-41d4-a716-446655440003', 'AR', '売掛金', 'asset', TRUE, 130),
('550e8400-e29b-41d4-a716-446655440004', 'INVENTORY', '商品', 'asset', TRUE, 140),
('550e8400-e29b-41d4-a716-446655440005', 'PREPAID', '前払費用', 'asset', TRUE, 150),

('550e8400-e29b-41d4-a716-446655440010', 'AP', '買掛金', 'liability', TRUE, 200),
('550e8400-e29b-41d4-a716-446655440011', 'ACCRUED', '未払費用', 'liability', TRUE, 210),
('550e8400-e29b-41d4-a716-446655440012', 'LOAN', '借入金', 'liability', TRUE, 220),

('550e8400-e29b-41d4-a716-446655440020', 'CAPITAL', '資本金', 'equity', TRUE, 300),
('550e8400-e29b-41d4-a716-446655440021', 'RETAINED', '繰越利益剰余金', 'equity', TRUE, 310),

('550e8400-e29b-41d4-a716-446655440030', 'SALES', '売上高', 'revenue', TRUE, 400),
('550e8400-e29b-41d4-a716-446655440031', 'SERVICE_REV', 'サービス売上', 'revenue', TRUE, 410),

('550e8400-e29b-41d4-a716-446655440040', 'COGS', '売上原価', 'expense', TRUE, 500),
('550e8400-e29b-41d4-a716-446655440041', 'SALARY', '給与', 'expense', TRUE, 510),
('550e8400-e29b-41d4-a716-446655440042', 'RENT', '地代家賃', 'expense', TRUE, 520),
('550e8400-e29b-41d4-a716-446655440043', 'UTILITY', '水道光熱費', 'expense', TRUE, 530),
('550e8400-e29b-41d4-a716-446655440044', 'TRAVEL', '旅費交通費', 'expense', TRUE, 540),
('550e8400-e29b-41d4-a716-446655440045', 'COMM', '通信費', 'expense', TRUE, 550),
('550e8400-e29b-41d4-a716-446655440046', 'OFFICE', '事務用品費', 'expense', TRUE, 560),
('550e8400-e29b-41d4-a716-446655440047', 'ENTERTAINMENT', '接待交際費', 'expense', TRUE, 570),
('550e8400-e29b-41d4-a716-446655440048', 'DEPRECIATION', '減価償却費', 'expense', TRUE, 580),
('550e8400-e29b-41d4-a716-446655440049', 'TAX', '租税公課', 'expense', TRUE, 590),

('550e8400-e29b-41d4-a716-446655440099', 'OTHER', 'その他', 'other', TRUE, 999);

-- アプリケーション設定の初期レコード作成
INSERT INTO app_config (id, password_hash) VALUES ('app', NULL);

-- データベース統計情報更新
ANALYZE;

-- バックアップとリストア用のコメント
-- バックアップ: sqlite3 furikae_denpyo.db ".backup backup_YYYYMMDD.db"
-- リストア: sqlite3 furikae_denpyo.db ".restore backup_YYYYMMDD.db"
-- CSVエクスポート: sqlite3 -header -csv furikae_denpyo.db "SELECT * FROM furikae_denpyo;" > denpyo_export.csv

-- テスト用サンプルデータ（開発環境のみ）
-- INSERT INTO furikae_denpyo (id, date, number) VALUES 
-- ('123e4567-e89b-12d3-a456-426614174000', '2025-09-04', 'TEST001');
-- 
-- INSERT INTO shiwake_entries (id, denpyo_id, side, account_id, amount, description) VALUES
-- ('123e4567-e89b-12d3-a456-426614174001', '123e4567-e89b-12d3-a456-426614174000', 'debit', '550e8400-e29b-41d4-a716-446655440044', 500, '電車代'),
-- ('123e4567-e89b-12d3-a456-426614174002', '123e4567-e89b-12d3-a456-426614174000', 'credit', '550e8400-e29b-41d4-a716-446655440000', 500, '現金支払い');
