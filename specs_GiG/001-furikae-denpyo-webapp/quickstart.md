# Quickstart: 振替伝票作成Webアプリケーション

## Prerequisites
- Deno 最新安定版
- Node (フロントビルド) optional if using bundler
- SQLite3 (CLI for inspection 任意)

## Steps
1. リポジトリ取得 / ブランチ作成 `001-furikae-denpyo-webapp`
2. backend: 依存取得 & 開発サーバ起動 (実装後)
3. frontend: 依存取得 & 開発サーバ起動
4. ブラウザアクセス `/` で一覧(空)
5. 新規伝票作成 → 借方1行(旅費交通費), 貸方1行(現金) → 合計一致 → 保存
6. 一覧に反映されることを確認
7. 伝票詳細から PDF 出力 → ファイルを保存/開く
8. 設定画面でパスワード設定 → ログアウト/再アクセスで要求されること確認

## Smoke Test (After Implementation)
- 新規→保存: 201 Created JSON includes voucherNumber
- GET /v1/vouchers: array length 1
- GET /v1/vouchers/{id}: entries配列含む
- POST /v1/vouchers/{id}/pdf: application/pdf 返却
- パスワード設定後 POST /v1/auth 認証成功

## Troubleshooting
- 借貸不一致: 保存不可。行金額再確認。
- PDF日本語文字化け: フォント埋込設定確認。
- ハッシュエラー: Argon2未対応→ bcrypt fallback。
