# Research: Denpyo 振替伝票機能

## 1. Hono + Deno ベストプラクティス
- Decision: ルート構成 /api/*, エラーハンドリング middleware, JSONレスポンス統一 {ok:boolean,data|error}
- Rationale: シンプルでテスト容易、追加モジュール最小
- Alternatives: Fresh, Oak → 追加学習コスト / 過剰

## 2. SQLite in Deno
- Decision: deno-sqlite を利用しリクエスト毎に疎結合トランザクション、テストは一時ファイルで隔離
- Rationale: 外部サーバ不要、単一ユーザー前提
- Alternatives: PostgreSQL (オーバーキル), Deno KV (PDF/照会要件向けSchema制御が弱い)

## 3. PDF 生成方式
- Decision: 初期は HTML/CSS + ブラウザ印刷 (サーバ提供HTML) → 後段で pdf-lib 切替可能
- Rationale: 迅速な価値提供 / 要件は印刷体裁のみ
- Alternatives: pdf-lib, jsPDF (即導入は余計なAPI学習)

## 4. パスワードハッシュ
- Decision: bcrypt (十分な実績) + Deno向けライブラリ
- Rationale: Argon2 はビルド負荷増加可能性、単一ユーザーで十分
- Alternatives: Argon2 (将来強化), scrypt

## 5. TDD ワークフロー (t-wada流)
- Decision: コントラクトテスト起点 → 失敗確認 → 最小実装 → リファクタ。コミットメッセージに RED/GREEN/REFACTOR 接頭辞。
- Rationale: 可視化と履歴トレーサビリティ
- Alternatives: 通常TDD (命名統一欠如)

## 6. PDF パフォーマンス目標
- Decision: 1ページ標準(≤30行)生成 ≤1s 実測後調整。p95 5s 以内達成に向け段階測定ログ。
- Rationale: ユーザ体感良好確保
- Alternatives: 先行最適化（不要）

## 7. ログ構造
- Decision: {ts,level,msg,traceId?,context?}
- Rationale: grep/集計容易
- Alternatives: NDJSON 以外の形式

## 8. バリデーション
- Decision: Zod スキーマ (Voucher, VoucherLine, Auth) を単一点に定義
- Rationale: 再利用, 型安全
- Alternatives: 手書き if 文（重複）

## 9. データマイグレーション
- Decision: 初期はスキーマ直接 create。将来変更時に migration table 方式採用。
- Rationale: 初期段階シンプル保持
- Alternatives: 早期にmigrationフレーム導入（過剰）

## 10. セキュリティ簡易方針
- Decision: CSRFは単一ユーザー・非公開前提で最小化、パスワード入力時のみPOST、Cookie httpOnly。将来公開時再評価。
- Rationale: スコープ適合
- Alternatives: 初期段階で包括的CSRFトークン

## 結論
未確定事項は全て確定。Phase 0 完了。
