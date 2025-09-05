# Research: 振替伝票作成Webアプリケーション (Phase 0)

## 1. PDF生成手段
- Decision: HTMLテンプレート + Headless Chromium(Puppeteer互換) でサーバ側生成 検討継続
- Alternatives:
  - pdf-lib（描画細かい制御/レイアウト再実装コスト大）
  - jsPDF（日本語フォント埋込/レイアウト制限）
  - serverless API外部サービス（依存/ネット接続増）
- Rationale: 帳票のレイアウト調整と将来ロゴ等の拡張容易性。Denoでのpuppeteerサポート互換確認必要。
- TODO: Deno実行環境でのheadless起動可否調査

## 2. 勘定科目初期セット
- Decision: 最小セット（現金/旅費交通費/通信費/消耗品費/雑費/売上/預り金）+ ユーザー追加(その他)
- Alternatives: 全勘定科目体系(過剰), 空(利便性低)
- Rationale: 入力効率とシンプルさのバランス
- TODO: 科目コード体系 (3桁任意) を data-modelで確定

## 3. パスワードハッシュ方式
- Decision: Argon2 (計算コスト調整/耐GPU) 可能なら。Fallback: bcrypt。
- Alternatives: PBKDF2（将来性/コスト調整劣る）
- Rationale: セキュリティ強度 + ライブラリ可用性
- TODO: Deno対応argon2パッケージ検証

## 4. 自動採番方式
- Decision: 日付(YYYYMMDD) + 連番(零埋め3) 例: 20250905-001
- Alternatives: グローバル連番(並び意味希薄), UUID(ユーザー向きでない)
- Rationale: ユーザー視認性 + 並び順保証
- TODO: 同日競合処理: トランザクション+MAX取得+1

## 5. バリデーションライブラリ
- Decision: Zod共通schema + 型共有(frontend/backend)
- Alternatives: 独自実装(重複), class-validator(クラス回避方針と不整合)
- Rationale: 宣言的/型推論
- TODO: 共通`/shared/schema` ディレクトリ検討

## Pending Checks
- [ ] Puppeteer (Deno) 実行確認
- [ ] Argon2 Deno 対応確認

## Open Questions
- PDF内フォント: 日本語埋込フォント(TTF) サイズ最適化 (Phase1で決定)

## Next
- data-model.md 作成
- OpenAPI初版
