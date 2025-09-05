# 設計書

## 概要

振替伝票作成Webアプリケーションは、Deno + Hono（バックエンド）とReact（フロントエンド）を使用したSPA（Single Page Application）として設計します。関数型プログラミングパターンを重視し、クラスの使用を最小限に抑えた実装を行います。

## アーキテクチャ

### システム構成

```
┌─────────────────┐    HTTP API    ┌─────────────────┐
│   React SPA     │ ◄─────────────► │  Deno + Hono    │
│  (Frontend)     │                 │   (Backend)     │
└─────────────────┘                 └─────────────────┘
                                             │
                                             ▼
                                    ┌─────────────────┐
                                    │   SQLite DB     │
                                    │   (Database)    │
                                    └─────────────────┘
```

### 技術スタック

- **バックエンド**: Deno 2.0 + Hono
- **フロントエンド**: React 18 + TypeScript
- **データベース**: SQLite (deno-sqlite)
- **PDF生成**: jsPDF + html2canvas
- **スタイリング**: CSS Modules または Tailwind CSS
- **状態管理**: React Hooks (useState, useReducer)

## コンポーネントとインターフェース

### バックエンドAPI設計

#### 認証エンドポイント
```typescript
POST /api/auth/login
Body: { password: string }
Response: { success: boolean, token?: string }

POST /api/auth/set-password
Body: { password: string }
Response: { success: boolean }
```

#### 振替伝票エンドポイント
```typescript
GET /api/vouchers
Query: { startDate?: string, endDate?: string }
Response: { vouchers: JournalVoucher[] }

POST /api/vouchers
Body: JournalVoucher
Response: { id: number, voucher: JournalVoucher }

GET /api/vouchers/:id
Response: { voucher: JournalVoucher }

PUT /api/vouchers/:id
Body: JournalVoucher
Response: { voucher: JournalVoucher }

DELETE /api/vouchers/:id
Response: { success: boolean }
```

#### 勘定科目エンドポイント
```typescript
GET /api/accounts
Response: { accounts: AccountItem[] }
```

### フロントエンドコンポーネント設計

#### コンポーネント階層
```
App
├── AuthGuard
├── Header
├── Router
│   ├── VoucherForm
│   │   ├── DateInput
│   │   ├── AccountSelector
│   │   ├── AmountInput
│   │   ├── DescriptionInput
│   │   └── BalanceValidator
│   ├── VoucherList
│   │   ├── SearchFilter
│   │   └── VoucherItem
│   └── VoucherDetail
│       ├── VoucherDisplay
│       └── PDFExporter
└── PasswordModal
```

## データモデル

### JournalVoucher型定義
```typescript
interface JournalVoucher {
  id?: number;
  date: string; // ISO date string
  number?: string;
  entries: VoucherEntry[];
  createdAt?: string;
  updatedAt?: string;
}

interface VoucherEntry {
  id?: number;
  accountCode: string;
  accountName: string;
  debitAmount: number;
  creditAmount: number;
  description: string;
}

interface AccountItem {
  code: string;
  name: string;
  category: 'asset' | 'liability' | 'equity' | 'revenue' | 'expense';
}
```

### データベーススキーマ
```sql
-- 振替伝票テーブル
CREATE TABLE journal_vouchers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL,
  number TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- 仕訳エントリテーブル
CREATE TABLE voucher_entries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  voucher_id INTEGER NOT NULL,
  account_code TEXT NOT NULL,
  account_name TEXT NOT NULL,
  debit_amount REAL DEFAULT 0,
  credit_amount REAL DEFAULT 0,
  description TEXT,
  FOREIGN KEY (voucher_id) REFERENCES journal_vouchers (id) ON DELETE CASCADE
);

-- 勘定科目マスタテーブル
CREATE TABLE account_items (
  code TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL
);

-- 設定テーブル（パスワードハッシュ保存用）
CREATE TABLE app_settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);
```

## エラーハンドリング

### バックエンドエラーハンドリング
- HTTPステータスコードによる統一的なエラーレスポンス
- データベースエラーのキャッチと適切なメッセージ変換
- バリデーションエラーの詳細情報提供

### フロントエンドエラーハンドリング
- React Error Boundaryによるコンポーネントレベルのエラーキャッチ
- APIエラーレスポンスの統一的な処理
- ユーザーフレンドリーなエラーメッセージ表示

### エラーレスポンス形式
```typescript
interface ErrorResponse {
  error: {
    code: string;
    message: string;
    details?: any;
  };
}
```

## テスト戦略

### バックエンドテスト
- **単体テスト**: 各API関数の動作確認
- **統合テスト**: データベース操作を含むエンドツーエンドテスト
- **テストツール**: Deno標準のテスト機能

### フロントエンドテスト
- **コンポーネントテスト**: React Testing Libraryを使用
- **統合テスト**: ユーザーインタラクションのシミュレーション
- **E2Eテスト**: Playwrightまたは類似ツール

### テスト対象
- 借方・貸方の合計金額一致検証
- PDF生成機能
- 認証機能
- CRUD操作の整合性

## セキュリティ考慮事項

### 認証・認可
- パスワードのハッシュ化（bcrypt使用）
- セッション管理（JWT または セッションクッキー）
- CSRF対策

### データ保護
- SQLインジェクション対策（プリペアドステートメント使用）
- XSS対策（適切なエスケープ処理）
- 入力値バリデーション

## パフォーマンス最適化

### フロントエンド
- React.memoによるコンポーネント最適化
- useMemoとuseCallbackによる再計算防止
- 仮想化による大量データ表示の最適化

### バックエンド
- データベースインデックスの適切な設定
- ページネーション実装
- レスポンスキャッシュ

## デプロイメント

### 開発環境
- Deno標準のdev serverを使用
- ホットリロード対応

### 本番環境
- 静的ファイル配信の最適化
- 環境変数による設定管理
- ログ出力の適切な設定