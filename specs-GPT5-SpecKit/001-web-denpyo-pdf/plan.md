# Implementation Plan: Denpyo 振替伝票作成・PDF保存機能

**Branch**: `001-web-denpyo-pdf` | **Date**: 2025-09-06 | **Spec**: /home/beagleworks/AIPJ/denpyo/specs/001-web-denpyo-pdf/spec.md
**Input**: Feature specification from `/specs/001-web-denpyo-pdf/spec.md`

## Execution Flow (/plan command scope)
```
1. Load feature spec from Input path
   → If not found: ERROR "No feature spec at {path}"
2. Fill Technical Context (scan for NEEDS CLARIFICATION)
   → Detect Project Type from context (web=frontend+backend, mobile=app+api)
   → Set Structure Decision based on project type
3. Evaluate Constitution Check section below
   → If violations exist: Document in Complexity Tracking
   → If no justification possible: ERROR "Simplify approach first"
   → Update Progress Tracking: Initial Constitution Check
4. Execute Phase 0 → research.md
   → If NEEDS CLARIFICATION remain: ERROR "Resolve unknowns"
5. Execute Phase 1 → contracts, data-model.md, quickstart.md, agent-specific template file (e.g., `CLAUDE.md` for Claude Code, `.github/copilot-instructions.md` for GitHub Copilot, or `GEMINI.md` for Gemini CLI).
6. Re-evaluate Constitution Check section
   → If new violations: Refactor design, return to Phase 1
   → Update Progress Tracking: Post-Design Constitution Check
7. Plan Phase 2 → Describe task generation approach (DO NOT create tasks.md)
8. STOP - Ready for /tasks command
```

**IMPORTANT**: The /plan command STOPS at step 7. Phases 2-4 are executed by other commands:
- Phase 2: /tasks command creates tasks.md
- Phase 3-4: Implementation execution (manual or via tools)

## Summary
単一利用者向けに振替伝票（仕訳）をWeb UIで作成・保存・PDF出力する。借方/貸方合計一致バリデーション、日毎連番採番、7年保持、パスワードによるアクセス保護、一覧検索/フィルタを提供。技術スタックは Deno + Hono (API), React (フロントエンド), TypeScript, sqlite。TDD (t-wada流) を徹底し RED→GREEN→REFACTOR を契約/統合/エンドツーエンド優先順で実施。

## Technical Context
**Language/Version**: TypeScript (Deno latest LTS), React (TypeScript)
**Primary Dependencies**: Hono (HTTP routing), React, (PDF生成) 後で検討: pdf-lib もしくは jsPDF / print CSS, Zod(スキーマバリデーション)
**Storage**: SQLite (Deno向けライブラリ: deno-sqlite)
**Testing**: t-wada流 TDD: Deno標準テスト + Playwright(E2E) 検討（初期はDeno test + contract/integration層）
**Target Platform**: Linux サーバ / ローカル実行 (ブラウザ: 最新 Chrome/Firefox)
**Project Type**: web (frontend + backend)
**Performance Goals**: 保存 p95 ≤2s / PDF生成 p95 ≤5s / 同時利用1ユーザー
**Constraints**: 単一ユーザー / 簡易認証（パスワード） / 7年保持 / 伝票件数年間≤2,000
**Scale/Scope**: 小規模（単一利用者, 年間2,000伝票, UI画面数 ~5: ログイン/伝票一覧/新規/詳細(PDF)/設定）

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Simplicity**:
- Projects: 2 (backend, frontend) + shared tests conceptually (≤3 OK)
- Using framework directly: Hono 直接利用（独自抽象層追加しない）
- Single data model: Voucher/VoucherLine/UserAccess の最少構成。DTOは不要。
- Avoiding patterns: Repository/UoW 導入しない。直接SQLite操作（薄いdataモジュール）。

**Architecture**:
- Library-first: backend/src はモジュール化（models, services, api）。frontend/src はページ + services のみ。
- Libraries listed: core-model (型/バリデーション), voucher-service (業務ロジック), pdf-export (PDF生成), auth (パスワード管理) ※ すべて1リポ内モジュール。
- CLI per library: Phase 1で deno task 経由のテスト/契約検証コマンド整備予定。
- Library docs: quickstart.md / contracts/ で補完。

**Testing (NON-NEGOTIABLE)**:
- RED-GREEN-Refactor: コミットポリシーで強制（テスト失敗→実装→リファクタ）。
- Order: Contract(HTTP) → Integration(DB結合) → E2E(後段) → Unit(補助) 順。
- Real dependencies: SQLite 実ファイル（テスト毎に一時DB）。
- Integration tests: voucher CRUD, balance validation, auth lockout, PDF placeholder。
- Forbidden practices: モック過多 / 実装先行を禁止。

**Observability**:
- Structured logging: JSON lines (level,msg,context) backend。frontend はconsole→開発時のみ。
- Error context: API 失敗時トレースID(簡易UUID)。

**Versioning**:
- Version: 0.1.0 初期。BUILDはタスク完了毎に patch increment (git tag optional)。
- Breaking changes: データスキーマ変更は migration スクリプト（後続タスク）想定。

## Project Structure

### Documentation (this feature)
```
specs/[###-feature]/
├── plan.md              # This file (/plan command output)
├── research.md          # Phase 0 output (/plan command)
├── data-model.md        # Phase 1 output (/plan command)
├── quickstart.md        # Phase 1 output (/plan command)
├── contracts/           # Phase 1 output (/plan command)
└── tasks.md             # Phase 2 output (/tasks command - NOT created by /plan)
```

### Source Code (repository root)
```
# Option 1: Single project (DEFAULT)
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# Option 2: Web application (when "frontend" + "backend" detected)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# Option 3: Mobile + API (when "iOS/Android" detected)
api/
└── [same as backend above]

ios/ or android/
└── [platform-specific structure]
```

**Structure Decision**: Option 2 (web: frontend + backend) を採用。

## Phase 0: Outline & Research
対象未知はほぼ仕様で解消済み。確認/補強する研究テーマ:
1. Hono + Deno での構成ベストプラクティス（ルーティング・エラーハンドリング）。
2. Deno での SQLite ハンドリング（トランザクション/接続ライフサイクル）。
3. PDF 生成手段比較 (pdf-lib vs jsPDF vs ブラウザ印刷 CSS) — 初期は HTML+print CSS で代替し将来ライブラリ化。
4. パスワードハッシュ: Deno 標準/ライブラリ (bcrypt/argon2) 選定。
5. TDD ワークフロー (t-wada流) を Deno + React でどう実行順組むか。

research.md に Decision / Rationale / Alternatives を記載。

**Output**: research.md 作成（以下に生成）。

## Phase 1: Design & Contracts
1. data-model.md: エンティティ定義 + バリデーション（合計一致, 摘要200文字, 科目必須など）。
2. API Contracts (REST, JSON):
   - POST /api/auth/password (初回設定)
   - POST /api/auth/login
   - POST /api/auth/logout
   - POST /api/vouchers (作成)
   - GET /api/vouchers (一覧 + filters)
   - GET /api/vouchers/:id (詳細)
   - GET /api/vouchers/:id/pdf (PDF生成)
3. 契約表現: OpenAPI YAML (contracts/openapi.yaml) + エンドポイント別最小例。
4. Contract tests: 各エンドポイントごとに Deno test (最初は未実装で fail)。
5. Integration test シナリオ: 主ユーザーストーリーを quickstart.md に手順化。
6. agent context 更新は後続（/scripts/update-agent-context.sh copilot）。

**Output**: data-model.md, contracts/openapi.yaml, quickstart.md, contracts/tests placeholder。

## Phase 2: Task Planning Approach
*This section describes what the /tasks command will do - DO NOT execute during /plan*

**Task Generation Strategy**:
- Load `/templates/tasks-template.md` as base
- Generate tasks from Phase 1 design docs (contracts, data model, quickstart)
- Each contract → contract test task [P]
- Each entity → model creation task [P] 
- Each user story → integration test task
- Implementation tasks to make tests pass

**Ordering Strategy**:
- TDD order: Tests before implementation 
- Dependency order: Models before services before UI
- Mark [P] for parallel execution (independent files)

**Estimated Output**: 25-30 numbered, ordered tasks in tasks.md

**IMPORTANT**: This phase is executed by the /tasks command, NOT by /plan

### (Audit Addition) Detailed Pre-Tasks Outline (Draft for tasks.md)
Order意識で大項目→小項目:
1. 基盤準備
   1. Create backend/ & frontend/ ディレクトリ初期スキャフォールド
   2. Deno タスク設定 (fmt, lint, test)
   3. SQLite 初期スキーマ生成スクリプト (schema.sql) + migration テーブル
   4. 共通ユーティリティ: logger, error response helper, id生成(YMD連番)
2. モデル & バリデーション (RED)
   1. Zod スキーマ（Voucher, VoucherLine, UserAccess）テスト(失敗)作成
   2. スキーマ実装 → テスト GREEN
3. 認証 (RED→GREEN)
   1. 初回パスワード設定コントラクトテスト
   2. bcrypt ハッシュ実装 + lockout ロジック
   3. login/logout テスト/実装
4. 伝票 CRUD & ビジネスルール
   1. POST /api/vouchers バランス不一致テスト (失敗)
   2. バランス検証実装 → GREEN
   3. 自動採番テスト → 実装
   4. 重複番号エラーテスト → 実装
   5. GET /api/vouchers (フィルタ/ソート) テスト → 実装
   6. GET /api/vouchers/:id テスト → 実装
5. PDF 出力 (Placeholder → HTML/CSS)
   1. PDFエンドポイント 404 / 正常ケーステスト
   2. HTMLテンプレ + print CSS → ブラウザでPDF化
   3. 回帰テスト: 合計値表示/科目/日付
6. フロントエンド (契約駆動)
   1. APIクライアント薄層 (fetch wrapper) テスト
   2. ログイン画面 → RED (E2E/統合) → 実装
   3. 一覧画面 (フィルタ/ソート UI) RED → 実装
   4. 新規作成フォーム (動的行追加/リアルタイムバランス) RED → 実装
   5. PDF表示/出力ボタン + 結果確認
7. 非機能
   1. パフォーマンス計測(保存/生成) 基本計測ユーティリティ
   2. ログ構造 JSON 確認テスト
8. アクセシビリティ/UX 最低限
   1. フォーム必須ARIA属性/Escapeキー挙動
9. セキュリティ強化
   1. Cookie httpOnly & secure 条件テスト
   2. ロック解除タイミングテスト
10. 文書/仕上げ
   1. quickstart.md 手順通り自動テスト(E2E) 化
   2. README 追記 (起動/テスト)
   3. バージョン 0.1.0 タグ準備

並列 [P] 候補: モデルスキーマ / ロガー / スキーマSQL / テスト基盤。タイト依存あり（API 実装前にモデル確立）。

## Phase 3+: Future Implementation
*These phases are beyond the scope of the /plan command*

**Phase 3**: Task execution (/tasks command creates tasks.md)  
**Phase 4**: Implementation (execute tasks.md following constitutional principles)  
**Phase 5**: Validation (run tests, execute quickstart.md, performance validation)

## Complexity Tracking
*Fill ONLY if Constitution Check has violations that must be justified*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |


## Progress Tracking
*This checklist is updated during execution flow*

**Phase Status**:
- [x] Phase 0: Research complete (/plan command)
- [x] Phase 1: Design complete (/plan command)
- [x] Phase 2: Task planning complete (/plan command - describe approach only)
- [x] Phase 3: Tasks generated (/tasks command)
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:
- [x] Initial Constitution Check: PASS
- [x] Post-Design Constitution Check: PASS
- [x] All NEEDS CLARIFICATION resolved
- [x] Complexity deviations documented (N/A → 空のまま)

---
*Based on Constitution v2.1.1 - See `/memory/constitution.md`*

---
## Audit Addendum (Implementation Plan Review)
### Identified Gaps & Added Resolutions
| 区分 | ギャップ | 追加方針 |
|------|----------|----------|
| ログ | ログ形式/traceId生成手段未具体化 | logger util で UUIDv4 + level 標準化 |
| エラー | エラー応答構造統一未記述 | { ok:false, error:{code,message} } 契約化 |
| セッション | 認証セッション持続方式未明確 | httpOnly Secure Cookie に署名済み session token (短期) |
| セキュリティ | bcryptコスト未定 | cost=12 (単一ユーザーで許容) |
| リカバリ | パスワード忘失時扱い | 手動 DB リセット手順 README に記載 (スコープ外明示) |
| PDF | ライブラリ切替条件未定 | 利用者要求/レイアウト高度化時 pdf-lib 導入判断指標追記 |
| マイグレーション | schema_migrations 実装詳細なし | 初回 schema + migrations table, 将来 add columns pattern |
| パフォーマンス | 測定手段 | middleware で計測 + console(JSON) ログ |
| テスト構成 | ディレクトリ細分未記載 | backend/tests/{contract,integration,e2e,unit} |
| アクセシビリティ | 要件未記述 | フォームラベル, キーボード操作, 色コントラスト最低基準 |
| バージョン | インクリメント手順 | scripts/version-bump.sh (patch) 想定 |
| Lint/Format | 運用明記不足 | deno lint / fmt pre-commit 推奨 |

### Risks & Mitigations
| リスク | 影響 | 低減策 |
|-------|------|--------|
| PDF レイアウト統一困難 | 出力品質低下 | 早期にサンプル2~3種比較 / CSS print 指針文書化 |
| 連番競合 (同日並行生成) | 番号重複 | 連番算出をトランザクション内SELECT+INSERT 確定 |
| SQLite ロック | 保存遅延 | 単一接続シリアライズ + 短トランザクション |
| ロックアウト誤判定 | UX悪化 | 失敗カウンタ更新を原子的に処理しテスト |
| バランス検証抜け | 不正データ | サービス層 & DB制約 (CHECK) 両面検証 |

### Acceptance of Plan Audit
この監査追補により Phase 2 生成に必要な詳細タスク粒度とリスク軽減策が明示された。tasks.md 生成時は "Detailed Pre-Tasks Outline" をベースに番号付与する。