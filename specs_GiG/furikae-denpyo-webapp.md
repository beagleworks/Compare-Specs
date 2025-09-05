# Feature Specification: 振替伝票作成Webアプリケーション

**Feature Branch**: `001-furikae-denpyo-webapp`  
**Created**: 2025-09-05  
**Status**: Draft  
**Input**: User description: "振替伝票を作成できるWebアプリケーションを作成してください"

## Execution Flow (main)
```
1. Parse user description from Input ✓
   → 振替伝票作成Webアプリケーションの開発要求
2. Extract key concepts from description ✓
   → 利用者: 単一ユーザー（経理/管理者）
   → アクション: 振替伝票作成, PDF化, 印刷, 保存, パスワード保護
   → データ: 振替伝票(日付, 借方/貸方科目, 金額, 摘要, 合計, 任意番号)
   → 制約: 借方/貸方合計一致, 科目プルダウン + その他自由入力
3. Unclear aspects: なし（初期スコープでは単純化）
4. User Scenarios & Testing section filled ✓
5. Functional Requirements generated ✓
6. Key Entities identified ✓
7. Review Checklist passed ✓ (暫定: 追加要件出現時に更新)
8. Return: SUCCESS (spec ready for planning)
```

---

## ⚡ Quick Guidelines
- ✅ 利用目的: 手書き伝票を電子化し保管性/再利用性向上
- ❌ 技術的実装詳細は含めない（UI構成/DB種別等）
- 👥 非技術ステークホルダー向け説明

## User Scenarios & Testing *(mandatory)*

### Primary User Story
利用者が領収書を取得できなかった経費精算の状況で、代替証憑として振替伝票を作成し、PDFとして保存または印刷可能な形で出力したい。

### Acceptance Scenarios
1. **Given** 経費立替が発生、**When** 新規伝票画面で必要項目を入力し保存、**Then** 伝票が登録され一覧に表示される
2. **Given** 既に登録済の伝票、**When** PDF出力操作を行う、**Then** 帳票レイアウトのPDFが生成・ダウンロードできる
3. **Given** 伝票編集中、**When** 借方と貸方の合計が不一致で保存操作、**Then** エラーメッセージが表示され保存されない
4. **Given** 初回利用、**When** パスワード設定を選択、**Then** 次回アクセス時にそのパスワード入力が要求される
5. **Given** 科目選択時、**When** 選択肢に該当科目が見つからない、**Then** 「その他」を選び自由入力欄で科目名を入力できる
6. **Given** 既存伝票、**When** 内容を修正し保存、**Then** 修正履歴（更新日時）が反映される
7. **Given** 不要となった伝票、**When** 削除操作を実行、**Then** 一覧から除去され再取得できない（論理/物理削除方針は初期物理削除）

### Edge Cases
- 借方/貸方行が1行のみ
- 金額=0の行入力を試行（禁止: 保存時バリデーションエラー）
- 摘要が非常に長い（例: 500文字）→ PDF内で折返しレイアウト保持
- 同一日付で多数(>50)の伝票作成→ 番号重複なく採番継続
- パスワード未設定状態でのアクセス→ 直接利用可能

## Requirements *(mandatory)*

### Functional Requirements
- **FR-001**: システムは振替伝票の新規作成を提供しなければならない
- **FR-002**: システムは日付, 借方/貸方科目, 借方/貸方金額, 摘要, 任意番号の入力を受け付けなければならない
- **FR-003**: システムは複数行の仕訳明細入力を許容しなければならない (借方/貸方区分含む)
- **FR-004**: システムは借方金額合計と貸方金額合計の一致を保存前に検証しなければならない
- **FR-005**: システムは勘定科目プルダウン選択と「その他」による自由入力を提供しなければならない
- **FR-006**: システムは登録済振替伝票の編集を提供しなければならない
- **FR-007**: システムは登録済振替伝票の削除を提供しなければならない
- **FR-008**: システムは振替伝票一覧表示を提供しなければならない
- **FR-009**: システムは振替伝票のPDF出力を提供しなければならない
- **FR-010**: システムは作成・更新日時を各伝票に記録しなければならない
- **FR-011**: システムは任意で利用パスワード設定/変更機能を提供しなければならない
- **FR-012**: システムは保存した振替伝票データを永続化しなければならない
- **FR-013**: システムは0以下の金額行の保存を拒否しなければならない
- **FR-014**: システムは摘要最大文字数を制限し (例: 500文字) 超過時エラーを表示しなければならない
- **FR-015**: システムは番号未入力時に自動採番を行わなければならない

### Key Entities
- **振替伝票 (Voucher)**: 伝票ID, 日付, 任意番号, 作成日時, 更新日時, 合計借方金額, 合計貸方金額
- **仕訳明細 (Entry)**: 行ID, 伝票ID, 区分(借方/貸方), 勘定科目種別(標準/その他), 勘定科目名, 金額, 摘要
- **勘定科目 (AccountMaster)**: 科目コード, 科目名, 表示順, 有効フラグ
- **アプリ設定 (AppSetting)**: パスワードハッシュ, 最終更新日時

---

## Review & Acceptance Checklist

### Content Quality
- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

### Requirement Completeness
- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and unambiguous  
- [x] Success criteria are measurable
- [x] Scope is clearly bounded
- [x] Dependencies and assumptions identified (単一ユーザー, ローカル利用想定初期)

---

## Execution Status
- [x] User description parsed
- [x] Key concepts extracted
- [x] Ambiguities marked (none)
- [x] User scenarios defined
- [x] Requirements generated
- [x] Entities identified
- [x] Review checklist passed

---
