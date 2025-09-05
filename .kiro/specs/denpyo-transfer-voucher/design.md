# 設計書

## 概要

Denpyoは振替伝票作成のためのWebアプリケーションで、Deno + Hono バックエンドとReactフロントエンドを使用したモダンなアーキテクチャを採用します。関数型プログラミングとテスト駆動開発（TDD）の原則に従い、TypeScriptで型安全性を確保しながら構築されます。

## アーキテクチャ

### 全体構成

```
┌─────────────────┐    HTTP/JSON    ┌─────────────────┐
│   React SPA     │ ←──────────────→ │  Deno + Hono    │
│   (Frontend)    │                 │   (Backend)     │
└─────────────────┘                 └─────────────────┘
                                             │
                                             ▼
                                    ┌─────────────────┐
                                    │   SQLite DB     │
                                    │   (Data Layer)  │
                                    └─────────────────┘
```

### 技術スタック

- **バックエンド**: Deno + Hono フレームワーク
- **フロントエンド**: React 18+ (関数コンポーネント + Hooks)
- **言語**: TypeScript (クラスレス関数型アプローチ)
- **データベース**: SQLite
- **開発手法**: テスト駆動開発（TDD）
- **テストフレームワーク**: Deno標準テストランナー + React Testing Library

## コンポーネントとインターフェース

### バックエンドアーキテクチャ

#### 1. APIレイヤー (Hono Routes)
```typescript
// 関数型アプローチでのルート定義
type VoucherRoutes = {
  'POST /api/vouchers': (voucher: CreateVoucherRequest) => Promise<VoucherResponse>
  'GET /api/vouchers': (params: ListVouchersParams) => Promise<VoucherListResponse>
  'GET /api/vouchers/:id': (id: string) => Promise<VoucherResponse>
  'GET /api/vouchers/:id/pdf': (id: string) => Promise<PDFResponse>
  'POST /api/auth/login': (credentials: LoginRequest) => Promise<AuthResponse>
}
```

#### 2. ビジネスロジックレイヤー
```typescript
// 純粋関数でのビジネスロジック
type VoucherService = {
  createVoucher: (data: VoucherData) => Promise<Result<Voucher, ValidationError>>
  validateVoucher: (voucher: VoucherData) => ValidationResult
  generatePDF: (voucher: Voucher) => Promise<Buffer>
  listVouchers: (filters: VoucherFilters) => Promise<Voucher[]>
}
```

#### 3. データアクセスレイヤー
```typescript
// 関数型データアクセス
type VoucherRepository = {
  save: (voucher: VoucherData) => Promise<Result<Voucher, DatabaseError>>
  findById: (id: string) => Promise<Option<Voucher>>
  findAll: (filters: VoucherFilters) => Promise<Voucher[]>
  delete: (id: string) => Promise<Result<void, DatabaseError>>
}
```

### フロントエンドアーキテクチャ

#### 1. コンポーネント構造
```
src/
├── components/
│   ├── VoucherForm/
│   ├── VoucherList/
│   ├── VoucherPDF/
│   └── Auth/
├── hooks/
│   ├── useVoucher.ts
│   ├── useAuth.ts
│   └── useValidation.ts
├── services/
│   └── api.ts
├── types/
│   └── voucher.ts
└── utils/
    ├── validation.ts
    └── formatting.ts
```

#### 2. 状態管理
```typescript
// React Hooks + Context API
type AppState = {
  vouchers: Voucher[]
  currentVoucher: Option<Voucher>
  auth: AuthState
  ui: UIState
}
```

## データモデル

### データベーススキーマ

#### vouchers テーブル
```sql
CREATE TABLE vouchers (
  id TEXT PRIMARY KEY,
  voucher_number TEXT,
  date TEXT NOT NULL,
  description TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
```

#### voucher_entries テーブル
```sql
CREATE TABLE voucher_entries (
  id TEXT PRIMARY KEY,
  voucher_id TEXT NOT NULL,
  account_type TEXT NOT NULL, -- 'debit' | 'credit'
  account_name TEXT NOT NULL,
  amount INTEGER NOT NULL, -- 金額（円単位、整数）
  FOREIGN KEY (voucher_id) REFERENCES vouchers (id) ON DELETE CASCADE
);
```

#### auth_settings テーブル
```sql
CREATE TABLE auth_settings (
  id INTEGER PRIMARY KEY CHECK (id = 1), -- 単一レコード制約
  password_hash TEXT,
  salt TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
```

### TypeScript型定義

```typescript
// 基本型
type VoucherId = string
type Amount = number // 円単位の整数
type AccountType = 'debit' | 'credit'

// ドメインモデル
type VoucherEntry = {
  readonly id: string
  readonly accountType: AccountType
  readonly accountName: string
  readonly amount: Amount
}

type Voucher = {
  readonly id: VoucherId
  readonly voucherNumber?: string
  readonly date: string // ISO date string
  readonly description: string
  readonly entries: readonly VoucherEntry[]
  readonly createdAt: string
  readonly updatedAt: string
}

// バリデーション結果型
type ValidationResult = {
  readonly isValid: boolean
  readonly errors: readonly ValidationError[]
}

type ValidationError = {
  readonly field: string
  readonly message: string
}

// API型
type CreateVoucherRequest = {
  readonly voucherNumber?: string
  readonly date: string
  readonly description: string
  readonly entries: readonly Omit<VoucherEntry, 'id'>[]
}
```

## エラーハンドリング

### エラー型システム
```typescript
// Result型パターンの採用
type Result<T, E> = 
  | { readonly success: true; readonly data: T }
  | { readonly success: false; readonly error: E }

type Option<T> = T | null

// エラー型定義
type AppError = 
  | ValidationError
  | DatabaseError
  | AuthenticationError
  | PDFGenerationError

type ValidationError = {
  readonly type: 'validation'
  readonly field: string
  readonly message: string
}

type DatabaseError = {
  readonly type: 'database'
  readonly message: string
  readonly cause?: unknown
}
```

### エラーハンドリング戦略
1. **バックエンド**: Result型を使用した関数型エラーハンドリング
2. **フロントエンド**: Error BoundariesとuseErrorフック
3. **バリデーション**: 即座のフィードバックと累積エラー表示
4. **ネットワーク**: 自動リトライとオフライン対応

## テスト戦略

### TDD アプローチ（t-wada式）

#### 1. テストファースト開発サイクル
```
Red → Green → Refactor
```

#### 2. テスト構造
```typescript
// バックエンドテスト例
Deno.test("振替伝票作成 - 借方貸方バランス検証", async () => {
  // Given
  const voucherData = createTestVoucherData({
    entries: [
      { accountType: 'debit', accountName: '交通費', amount: 1000 },
      { accountType: 'credit', accountName: '現金', amount: 500 } // 意図的に不一致
    ]
  })
  
  // When
  const result = await createVoucher(voucherData)
  
  // Then
  assertEquals(result.success, false)
  if (!result.success) {
    assertEquals(result.error.type, 'validation')
    assertEquals(result.error.field, 'entries')
  }
})
```

#### 3. テストカテゴリ
- **単体テスト**: 純粋関数とビジネスロジック
- **統合テスト**: API エンドポイントとデータベース操作
- **E2Eテスト**: ユーザーワークフロー全体
- **コンポーネントテスト**: React コンポーネントの動作

### テストツール
- **バックエンド**: Deno標準テストランナー
- **フロントエンド**: Vitest + React Testing Library
- **E2E**: Playwright
- **モック**: MSW (Mock Service Worker)

## セキュリティ考慮事項

### 認証・認可
```typescript
// パスワードハッシュ化（関数型アプローチ）
type HashPassword = (password: string) => Promise<{
  readonly hash: string
  readonly salt: string
}>

type VerifyPassword = (
  password: string,
  hash: string,
  salt: string
) => Promise<boolean>
```

### データ保護
1. **パスワード**: bcrypt または Argon2 でハッシュ化
2. **セッション**: JWT トークンまたはセッションクッキー
3. **入力検証**: 全入力データの厳密な型チェックとサニタイゼーション
4. **SQLインジェクション**: パラメータ化クエリの使用

## パフォーマンス最適化

### フロントエンド
1. **React.memo**: 不要な再レンダリング防止
2. **useMemo/useCallback**: 計算結果とコールバックのメモ化
3. **Code Splitting**: 動的インポートによる初期バンドルサイズ削減
4. **Virtual Scrolling**: 大量データ表示時の最適化

### バックエンド
1. **データベースインデックス**: 検索クエリの最適化
2. **接続プーリング**: SQLite接続の効率的管理
3. **レスポンス圧縮**: gzip圧縮の有効化
4. **キャッシング**: 頻繁にアクセスされるデータのメモリキャッシュ

## 開発・デプロイメント

### 開発環境
```typescript
// deno.json設定例
{
  "tasks": {
    "dev": "deno run --allow-net --allow-read --allow-write --watch server.ts",
    "test": "deno test --allow-all",
    "build": "deno run --allow-all build.ts"
  },
  "imports": {
    "hono": "https://deno.land/x/hono@v3.12.0/mod.ts",
    "sqlite": "https://deno.land/x/sqlite@v3.8.0/mod.ts"
  }
}
```

### プロジェクト構造
```
denpyo/
├── backend/
│   ├── src/
│   │   ├── routes/
│   │   ├── services/
│   │   ├── repositories/
│   │   └── utils/
│   ├── tests/
│   └── deno.json
├── frontend/
│   ├── src/
│   │   ├── components/
│   │   ├── hooks/
│   │   ├── services/
│   │   └── types/
│   ├── tests/
│   └── package.json
└── shared/
    └── types/
```

この設計により、保守性が高く、テスト可能で、スケーラブルな振替伝票アプリケーションを構築できます。