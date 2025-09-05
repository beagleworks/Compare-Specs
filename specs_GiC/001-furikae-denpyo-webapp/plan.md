# Implementation Plan: 振替伝票作成Webアプリケーション

**Branch**: `001-furikae-denpyo-webapp` | **Date**: 2025-09-04 | **Spec**: [furikae-denpyo-webapp.md](./furikae-denpyo-webapp.md)
**Input**: Feature specification from `/specs/furikae-denpyo-webapp.md`

## Execution Flow (/plan command scope)
```
1. Load feature spec from Input path ✓
   → Feature spec loaded successfully
2. Fill Technical Context ✓
   → Project Type: web (frontend + backend)
   → Structure Decision: Option 2 (Web application)
3. Evaluate Constitution Check section ✓
   → Initial Constitution Check: PASS
   → Update Progress Tracking: Initial Constitution Check
4. Execute Phase 0 → research.md ✓
   → All technical requirements are specified
5. Execute Phase 1 → contracts, data-model.md, quickstart.md ✓
6. Re-evaluate Constitution Check section ✓
   → Post-Design Constitution Check: PASS
   → Update Progress Tracking: Post-Design Constitution Check
7. Plan Phase 2 → Task generation approach described ✓
8. STOP - Ready for /tasks command ✓
```

## Summary
振替伝票作成Webアプリケーション：経理担当者が経費立替時に正式領収書の代替として振替伝票を作成、PDF化、データベース保存する機能を提供。技術スタック：Deno + Hono (backend), React (frontend), SQLite (database), TypeScript主体でクラスレス設計。

## Technical Context
**Language/Version**: TypeScript 5.2+, JavaScript ES2022  
**Primary Dependencies**: Deno 1.37+, Hono 3.8+, React 18+, SQLite 3.43+  
**Storage**: SQLite database for 振替伝票 persistence  
**Testing**: Deno test (backend), Vitest (frontend)  
**Target Platform**: Web browsers (Chrome, Firefox, Safari, Edge)  
**Project Type**: web - determines source structure (frontend + backend)  
**Performance Goals**: <500ms response time, <2MB PDF generation  
**Constraints**: Single user, no authentication required, クラスを避ける設計  
**Scale/Scope**: Single user application, ~1000 伝票/year capacity

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Simplicity**:
- Projects: 2 (backend API, frontend React app) - within max 3 ✓
- Using framework directly? YES (Hono, React直接利用) ✓
- Single data model? YES (振替伝票中心の統一モデル) ✓
- Avoiding patterns? YES (Repository/UoW パターン不使用) ✓

**Architecture**:
- EVERY feature as library? YES (PDF生成、DB操作、勘定科目管理) ✓
- Libraries listed: 
  - furikae-core: 振替伝票ビジネスロジック
  - pdf-generator: PDF出力機能
  - account-master: 勘定科目管理
- CLI per library: 各ライブラリは--help/--version/--format対応 ✓
- Library docs: llms.txt format planned ✓

**Testing (NON-NEGOTIABLE)**:
- RED-GREEN-Refactor cycle enforced? YES ✓
- Git commits show tests before implementation? YES ✓
- Order: Contract→Integration→E2E→Unit strictly followed? YES ✓
- Real dependencies used? YES (実際のSQLite DB使用) ✓
- Integration tests for: 新ライブラリ、契約変更、共有スキーマ ✓
- FORBIDDEN: Implementation before test, skipping RED phase ✓

**Observability**:
- Structured logging included? YES (Deno標準ロガー使用) ✓
- Frontend logs → backend? YES (統一ログストリーム) ✓
- Error context sufficient? YES (エラー詳細とスタックトレース) ✓

**Versioning**:
- Version number assigned? YES (1.0.0) ✓
- BUILD increments on every change? YES ✓
- Breaking changes handled? YES (並行テスト、移行計画) ✓

## Project Structure

### Documentation (this feature)
```
specs/001-furikae-denpyo-webapp/
├── plan.md              # This file (/plan command output)
├── research.md          # Phase 0 output (/plan command)
├── data-model.md        # Phase 1 output (/plan command)
├── quickstart.md        # Phase 1 output (/plan command)
├── contracts/           # Phase 1 output (/plan command)
│   ├── denpyo-api.yaml  # REST API specification
│   └── database.sql     # Database schema
└── tasks.md             # Phase 2 output (/tasks command - NOT created by /plan)
```

### Source Code (repository root)
```
# Option 2: Web application (frontend + backend)
backend/
├── src/
│   ├── models/          # 振替伝票、仕訳明細、勘定科目
│   ├── services/        # ビジネスロジック
│   ├── api/            # Hono API handlers
│   └── lib/            # 共通ライブラリ
├── tests/
│   ├── contract/       # API契約テスト
│   ├── integration/    # 統合テスト
│   └── unit/          # 単体テスト
├── database/
│   ├── migrations/     # SQLite schema migrations
│   └── seeds/         # 初期データ（勘定科目等）
└── deno.json          # Deno configuration

frontend/
├── src/
│   ├── components/     # React components
│   ├── pages/         # Page components
│   ├── services/      # API client
│   ├── types/         # TypeScript type definitions
│   └── utils/         # Utility functions
├── tests/
│   ├── unit/          # Component tests
│   ├── integration/   # User flow tests
│   └── e2e/          # End-to-end tests
├── public/            # Static assets
└── package.json       # Node.js configuration
```

**Structure Decision**: Option 2 (Web application) - frontend + backend separation for clear responsibility boundaries

## Phase 0: Outline & Research

1. **Extract unknowns from Technical Context**:
   - All technical requirements are specified in user request ✓
   - Deno + Hono backend setup and best practices
   - React + TypeScript frontend configuration
   - SQLite integration with Deno
   - PDF generation library selection
   - Testing frameworks setup

2. **Generate and dispatch research agents**:
   ```
   Task: "Research Deno + Hono best practices for REST API development"
   Task: "Research React + TypeScript project setup without classes"
   Task: "Research SQLite integration patterns for Deno applications"
   Task: "Research PDF generation libraries for JavaScript/TypeScript"
   Task: "Research testing strategies for Deno + React applications"
   ```

3. **Consolidate findings** in `research.md`:
   - Decision: 各技術選択の根拠
   - Rationale: なぜその技術を選んだか
   - Alternatives considered: 検討した代替案

**Output**: research.md with all technology decisions documented

## Phase 1: Design & Contracts
*Prerequisites: research.md complete*

1. **Extract entities from feature spec** → `data-model.md`:
   - 振替伝票 (FurikaeDenpyo): id, date, number, created_at, updated_at
   - 仕訳明細 (ShiwakeEntry): id, denpyo_id, side, account, amount, description
   - 勘定科目 (Account): id, name, type, is_custom
   - アプリケーション設定 (AppConfig): password_hash

2. **Generate API contracts** from functional requirements:
   - GET /api/denpyo - 振替伝票一覧取得
   - POST /api/denpyo - 新規振替伝票作成
   - PUT /api/denpyo/:id - 振替伝票更新
   - DELETE /api/denpyo/:id - 振替伝票削除
   - GET /api/denpyo/:id/pdf - PDF生成・ダウンロード
   - GET /api/accounts - 勘定科目一覧取得
   - POST /api/auth/verify - パスワード検証

3. **Generate contract tests** from contracts:
   - 各エンドポイントのスキーマ検証テスト
   - リクエスト/レスポンス形式テスト
   - 初期状態ではテスト失敗（実装前）

4. **Extract test scenarios** from user stories:
   - 振替伝票作成フロー統合テスト
   - PDF生成統合テスト
   - データ整合性検証テスト
   - パスワード保護機能テスト

5. **Update agent file incrementally**:
   - プロジェクト固有の技術スタック情報追加
   - 最近の変更履歴更新（最新3件保持）
   - 150行以内でトークン効率性維持

**Output**: data-model.md, /contracts/*, failing tests, quickstart.md, agent-specific file

## Phase 2: Task Planning Approach
*This section describes what the /tasks command will do - DO NOT execute during /plan*

**Task Generation Strategy**:
- Load `/templates/tasks-template.md` as base structure
- Generate tasks from Phase 1 design documents
- 契約テスト → 各APIエンドポイント [P]
- エンティティ → モデル作成タスク [P]
- ユーザーストーリー → 統合テストタスク
- 実装タスク（テストを通すため）

**Ordering Strategy**:
- TDD順序: テスト → 実装の順番
- 依存関係順序: モデル → サービス → API → UI
- [P]マーク: 並行実行可能（独立ファイル）

**Estimated Output**: 30-35個の番号付き、順序付きタスク in tasks.md

**Task Categories**:
1. **Environment Setup** (Tasks 1-5): Deno, React, SQLite setup
2. **Database & Models** (Tasks 6-10): Schema, migrations, model classes
3. **Backend API** (Tasks 11-20): Hono routes, business logic
4. **Frontend Components** (Tasks 21-30): React components, services
5. **Integration & Testing** (Tasks 31-35): E2E tests, PDF generation

**IMPORTANT**: This phase is executed by the /tasks command, NOT by /plan

## Phase 3+: Future Implementation
*These phases are beyond the scope of the /plan command*

**Phase 3**: Task execution (/tasks command creates tasks.md)  
**Phase 4**: Implementation (execute tasks.md following constitutional principles)  
**Phase 5**: Validation (run tests, execute quickstart.md, performance validation)

## Complexity Tracking
*No constitutional violations - this section remains empty*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| N/A | N/A | N/A |

## Progress Tracking
*This checklist is updated during execution flow*

**Phase Status**:
- [x] Phase 0: Research complete (/plan command)
- [x] Phase 1: Design complete (/plan command)
- [x] Phase 2: Task planning complete (/plan command - describe approach only)
- [x] Phase 3: Tasks generated (/tasks command) - 75 tasks created
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:
- [x] Initial Constitution Check: PASS
- [x] Post-Design Constitution Check: PASS
- [x] All NEEDS CLARIFICATION resolved
- [x] Complexity deviations documented (none)
- [x] Agent context file updated (CLAUDE.md)

---
*Based on Constitution v2.1.1 - See `/memory/constitution.md`*
