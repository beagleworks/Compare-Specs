# Data Model: 振替伝票作成Webアプリケーション

**Date**: 2025-09-04  
**Phase**: 1 - Data Model Design  
**Status**: Complete

## Core Entities

### 振替伝票 (FurikaeDenpyo)
**Purpose**: 経費立替の証憑として作成される帳票の基本情報

**Fields**:
- `id`: string (UUID) - Primary key
- `date`: string (YYYY-MM-DD) - 振替伝票の日付
- `number`: string | null - 振替伝票番号（任意）
- `created_at`: string (ISO 8601) - 作成日時
- `updated_at`: string (ISO 8601) - 更新日時

**Validation Rules**:
- `date`: 必須、有効な日付形式
- `number`: 任意、英数字のみ、最大20文字
- `id`: システム生成UUID

**State Transitions**:
- Draft → Complete (借方・貸方合計一致時)
- Complete → Draft (編集時)

### 仕訳明細 (ShiwakeEntry)
**Purpose**: 振替伝票内の個別仕訳行（借方・貸方エントリ）

**Fields**:
- `id`: string (UUID) - Primary key
- `denpyo_id`: string (UUID) - 振替伝票ID (Foreign Key)
- `side`: 'debit' | 'credit' - 借方(debit)または貸方(credit)
- `account_id`: string (UUID) - 勘定科目ID (Foreign Key)
- `account_custom`: string | null - カスタム勘定科目名（account_idがOTHERの場合）
- `amount`: number - 金額（正の整数、円単位）
- `description`: string - 摘要

**Validation Rules**:
- `side`: 必須、'debit' または 'credit'
- `amount`: 必須、正の整数、最大9999999999（100億円未満）
- `description`: 必須、最大200文字
- `account_custom`: account_idが'OTHER'の場合は必須、その他の場合はnull

**Relationships**:
- 1つの振替伝票に複数の仕訳明細
- 1つの仕訳明細は1つの勘定科目に対応

### 勘定科目 (Account)
**Purpose**: 会計処理で使用される科目マスター

**Fields**:
- `id`: string (UUID) - Primary key
- `code`: string - 勘定科目コード
- `name`: string - 勘定科目名
- `type`: 'asset' | 'liability' | 'equity' | 'revenue' | 'expense' | 'other' - 科目区分
- `is_system`: boolean - システム定義科目か（true: システム、false: ユーザー定義）
- `sort_order`: number - 表示順序

**Validation Rules**:
- `code`: 必須、英数字、最大10文字、一意
- `name`: 必須、最大50文字
- `type`: 必須、定義済み値のみ
- `sort_order`: 必須、正の整数

**Default System Accounts**:
```typescript
const SYSTEM_ACCOUNTS = [
  { code: 'CASH', name: '現金', type: 'asset', sort_order: 100 },
  { code: 'BANK', name: '普通預金', type: 'asset', sort_order: 110 },
  { code: 'AR', name: '売掛金', type: 'asset', sort_order: 120 },
  { code: 'EXPENSE_TRAVEL', name: '旅費交通費', type: 'expense', sort_order: 200 },
  { code: 'EXPENSE_OFFICE', name: '事務用品費', type: 'expense', sort_order: 210 },
  { code: 'EXPENSE_COMM', name: '通信費', type: 'expense', sort_order: 220 },
  { code: 'AP', name: '買掛金', type: 'liability', sort_order: 300 },
  { code: 'OTHER', name: 'その他', type: 'other', sort_order: 999 }
];
```

### アプリケーション設定 (AppConfig)
**Purpose**: アプリケーション全体の設定情報

**Fields**:
- `id`: string (固定値 'app') - Primary key
- `password_hash`: string | null - パスワードのbcryptハッシュ
- `created_at`: string (ISO 8601) - 設定作成日時
- `updated_at`: string (ISO 8601) - 設定更新日時

**Validation Rules**:
- `password_hash`: bcrypt形式（設定時のみ）

## Database Schema (SQLite)

```sql
-- 振替伝票テーブル
CREATE TABLE furikae_denpyo (
    id TEXT PRIMARY KEY,
    date TEXT NOT NULL,
    number TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- 勘定科目テーブル
CREATE TABLE accounts (
    id TEXT PRIMARY KEY,
    code TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('asset', 'liability', 'equity', 'revenue', 'expense', 'other')),
    is_system BOOLEAN NOT NULL DEFAULT FALSE,
    sort_order INTEGER NOT NULL
);

-- 仕訳明細テーブル
CREATE TABLE shiwake_entries (
    id TEXT PRIMARY KEY,
    denpyo_id TEXT NOT NULL,
    side TEXT NOT NULL CHECK (side IN ('debit', 'credit')),
    account_id TEXT NOT NULL,
    account_custom TEXT,
    amount INTEGER NOT NULL CHECK (amount > 0),
    description TEXT NOT NULL,
    FOREIGN KEY (denpyo_id) REFERENCES furikae_denpyo(id) ON DELETE CASCADE,
    FOREIGN KEY (account_id) REFERENCES accounts(id)
);

-- アプリケーション設定テーブル
CREATE TABLE app_config (
    id TEXT PRIMARY KEY DEFAULT 'app',
    password_hash TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- インデックス
CREATE INDEX idx_denpyo_date ON furikae_denpyo(date);
CREATE INDEX idx_entries_denpyo ON shiwake_entries(denpyo_id);
CREATE INDEX idx_accounts_type ON accounts(type, sort_order);

-- 更新日時自動更新トリガー
CREATE TRIGGER update_denpyo_timestamp 
    AFTER UPDATE ON furikae_denpyo
BEGIN
    UPDATE furikae_denpyo SET updated_at = datetime('now') WHERE id = NEW.id;
END;

CREATE TRIGGER update_config_timestamp 
    AFTER UPDATE ON app_config
BEGIN
    UPDATE app_config SET updated_at = datetime('now') WHERE id = NEW.id;
END;
```

## Business Rules

### 振替伝票作成ルール
1. **借方・貸方均衡**: 借方合計金額 = 貸方合計金額 でなければ保存不可
2. **最小エントリ数**: 最低1つの借方エントリと1つの貸方エントリが必要
3. **金額制限**: 1つのエントリの金額は1円以上、100億円未満
4. **日付制限**: 未来日は警告表示（保存は可能）

### 勘定科目選択ルール
1. **システム科目**: 削除・名前変更不可
2. **カスタム科目**: account_id='OTHER'の場合、account_customフィールドに自由入力
3. **表示順序**: type別グループ化、sort_order昇順

### データ整合性ルール
1. **参照整合性**: 振替伝票削除時、関連仕訳明細も削除（CASCADE）
2. **孤児レコード防止**: 勘定科目削除時、使用中の場合はエラー
3. **一意性制約**: 勘定科目コードは一意

## TypeScript Type Definitions

```typescript
// 基本型定義
export interface FurikaeDenpyo {
  id: string;
  date: string;
  number: string | null;
  created_at: string;
  updated_at: string;
  entries?: ShiwakeEntry[];
}

export interface ShiwakeEntry {
  id: string;
  denpyo_id: string;
  side: 'debit' | 'credit';
  account_id: string;
  account_custom: string | null;
  amount: number;
  description: string;
  account?: Account;
}

export interface Account {
  id: string;
  code: string;
  name: string;
  type: 'asset' | 'liability' | 'equity' | 'revenue' | 'expense' | 'other';
  is_system: boolean;
  sort_order: number;
}

export interface AppConfig {
  id: 'app';
  password_hash: string | null;
  created_at: string;
  updated_at: string;
}

// 作成・更新用型
export type CreateDenpyoRequest = Omit<FurikaeDenpyo, 'id' | 'created_at' | 'updated_at'> & {
  entries: Omit<ShiwakeEntry, 'id' | 'denpyo_id'>[];
};

export type UpdateDenpyoRequest = Partial<CreateDenpyoRequest>;

// バリデーション結果型
export interface ValidationResult {
  isValid: boolean;
  errors: string[];
  warnings: string[];
}

// 残高確認用型
export interface BalanceCheck {
  debitTotal: number;
  creditTotal: number;
  isBalanced: boolean;
  difference: number;
}
```

## Validation Functions

```typescript
// 振替伝票バリデーション
export function validateDenpyo(denpyo: CreateDenpyoRequest): ValidationResult {
  const errors: string[] = [];
  const warnings: string[] = [];
  
  // 日付チェック
  if (!denpyo.date || !isValidDate(denpyo.date)) {
    errors.push('有効な日付を入力してください');
  }
  
  // 未来日チェック
  if (new Date(denpyo.date) > new Date()) {
    warnings.push('未来日が設定されています');
  }
  
  // エントリ数チェック
  if (!denpyo.entries || denpyo.entries.length < 2) {
    errors.push('最低2つの仕訳明細が必要です');
  }
  
  // 借方・貸方チェック
  const balance = calculateBalance(denpyo.entries);
  if (!balance.isBalanced) {
    errors.push(`借方・貸方が一致しません（差額: ${balance.difference}円）`);
  }
  
  return {
    isValid: errors.length === 0,
    errors,
    warnings
  };
}

// 残高計算
export function calculateBalance(entries: Omit<ShiwakeEntry, 'id' | 'denpyo_id'>[]): BalanceCheck {
  const debitTotal = entries
    .filter(e => e.side === 'debit')
    .reduce((sum, e) => sum + e.amount, 0);
    
  const creditTotal = entries
    .filter(e => e.side === 'credit')
    .reduce((sum, e) => sum + e.amount, 0);
    
  return {
    debitTotal,
    creditTotal,
    isBalanced: debitTotal === creditTotal,
    difference: Math.abs(debitTotal - creditTotal)
  };
}
```

---

**Data Model Complete**: All entities, relationships, and validation rules defined. Ready for contract generation.
