# Implementation Plan: 振替伝票作成Webアプリケーション

**Branch**: `001-furikae-denpyo-webapp` | **Date**: 2025-09-05 | **Spec**: `../furikae-denpyo-webapp.md`
**Input**: Feature specification from `/specs/furikae-denpyo-webapp.md`

## Summary
単一ユーザー向け振替伝票管理。主要要件: 伝票CRUD, 仕訳複数行整合(借貸合計一致), PDF出力, 科目マスター+その他自由入力, 任意パスワード保護, SQLite永続化。技術選定: バックエンド Deno + Hono, フロント React(TypeScript, 関数型志向/クラス最小), PDF生成はサーバ(HTML→PDF)またはクライアント(Canvas)比較後選定。初期はサーバ側headlessライブラリ利用方針検討。

## Technical Context
**Language/Version**: TypeScript (Deno最新安定), React 18+  
**Primary Dependencies**: Hono (HTTP), better-sqlite3 equivalent for Deno/`deno-sqlite`, Zod(バリデーション), PDF生成: `deno-dom`+`puppeteer`または `pdf-lib` (NEEDS CLARIFICATION: 最終選定 Phase0)  
**Storage**: SQLite (ローカルファイル)  
**Testing**: Deno test (backend), Vitest or Jest (frontend)  
**Target Platform**: Linux/Desktop browser (最新Chrome/Firefox)  
**Project Type**: web (frontend + backend)  
**Performance Goals**: 伝票保存 <200ms, PDF生成 <3s 単票  
**Constraints**: 単一ユーザー/低同時アクセス, ローカル動作簡易性重視, クラス設計最小  
**Scale/Scope**: 伝票 ~数千件/年, 行数/伝票 <50, 科目マスター ~100

## Constitution Check (Initial)
**Simplicity**:
- Projects: 2 (backend, frontend) → OK
- Framework直接利用: Yes (Hono, React)
- 単一データモデル層: Yes (直接SQL + 軽薄repository関数)
- 余計なパターン回避: Yes

**Architecture**:
- ライブラリ分割不要（単純スコープ）
- CLI不要 (将来エクスポート時検討)

**Testing**:
- RED→GREEN→Refactor 前提
- Contract tests (OpenAPI schema) → integration → minimal unit順
- 実DB(SQLite tempコピー)使用

**Observability**:
- 構造化ログ(JSON) backend  
- フロント→バック 重要操作のみイベント送信 (create/update/delete/export)

**Versioning**:
- 初期バージョン: 0.1.0 (BUILDはコミットで上げる運用)  

Initial Constitution Check: PASS

## Project Structure
```
backend/
  src/
    api/
    services/
    models/
    db/
    pdf/
  tests/
    contract/
    integration/
    unit/
frontend/
  src/
    components/
    pages/
    hooks/
    services/
    lib/
  tests/
```
**Structure Decision**: Webアプリ (Option 2)

## Phase 0: Outline & Research
Unknown / Clarification Topics:
1. PDF生成手段 (puppeteer vs pdf-lib vs サーバレスHTML変換)
2. 科目マスター初期セット (標準勘定科目リスト範囲)
3. パスワードハッシュ方式 (bcrypt vs argon2 - Denoサポート/軽量性)
4. 自動採番方式 (単純連番 vs 日付+連番)
5. バリデーションライブラリ確定 (Zod想定)

Research Tasks (生成予定):
- PDFライブラリ比較 (機能, サイズ, Deno互換)
- 勘定科目標準セット選定 (日本の一般的勘定科目中から最小必須)
- ハッシュ方式性能/依存性比較
- 採番方式: 衝突回避/並列不要の簡易化根拠
- Zodでの型共有戦略 (frontend/backend共通schema?)

Output: `research.md` に Decision/Rationale/Alternatives 形式。

## Phase 1: Design & Contracts (予定)
1. `data-model.md`: ER/フィールド定義/制約/インデックス/バリデーション
2. API (OpenAPI):
   - POST /v1/vouchers
   - GET /v1/vouchers
   - GET /v1/vouchers/{id}
   - PUT /v1/vouchers/{id}
   - DELETE /v1/vouchers/{id}
   - POST /v1/vouchers/{id}/pdf
   - GET /v1/accounts
   - PUT /v1/settings/password
   - POST /v1/auth (存在するパスワード検証)
3. Contract tests: 各エンドポイント schemaテスト
4. Integration scenarios: 受入シナリオをテスト化
5. Quickstart: セットアップ→最初の伝票作成→PDF出力→パスワード設定流れ

## Phase 2: Task Planning Approach
- Contract→Integration→Unit→Implementation順
- 独立テストは [P] 並列印
- モデル & マイグレーション → APIハンドラ → フロントUI
- PDF出力最後 (依存が少ない)

## Phase 3+: (範囲外)
- 実装、テストパス、リリースタグ

## Complexity Tracking
(現時点なし)

## Progress Tracking
**Phase Status**:
- [ ] Phase 0: Research complete (/plan command)
- [ ] Phase 1: Design complete (/plan command)
- [ ] Phase 2: Task planning complete (/plan command - describe approach only)
- [ ] Phase 3: Tasks generated (/tasks command)
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:
- [x] Initial Constitution Check: PASS
- [ ] Post-Design Constitution Check: (pending)
- [ ] All NEEDS CLARIFICATION resolved
- [ ] Complexity deviations documented

---
