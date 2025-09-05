# Feature Specification: Denpyo 振替伝票作成・PDF保存機能

**Feature Branch**: `001-web-denpyo-pdf`  
**Created**: 2025-09-06  
**Status**: Draft  
**Input**: User description: "振替伝票を作成できるWebアプリケーションを作成してください\n\n1. アプリケーション名\nDenpyo\n\n2. アプリケーションの目的\n\n- 紙の振替伝票に手書きする行為をアプリケーションで置き換える\n- 振替伝票の作成履歴を記録する\n\n3. アプリケーションの機能要件\n\n- 振替伝票を作成できる\n- 振替伝票をPDF化して保存、もしくは印刷することができる\n- 入力した情報をデータベースに記録できる\n- 利用者は1名であり、アカウントは不要。ただし他者に閲覧されるのを防ぐため、利用時にパスワードを設定できる。\n\n4. 振替伝票の利用ケース\n\n経費を支払ったとき、既定の領収書が入手できなかった場合に代わりに作成する(例えば業務中の移動に関する電車代を自身の財布から建て替えた場合)\n\n5. 振替伝票の項目\n\n- 日付\n- 借方／貸方科目\n- 借方／貸方金額\n- 摘要\n- 借方／貸方合計金額\n- ナンバー(任意)\n\n6. 振替伝票の要件\n\n- 貸方、借方の合計金額は一致している必要がある\n- 借方／貸方科目は一般的な勘定科目をプルダウンで選べるようにするが、「その他」を作成し自由入力も可能とする"

## Execution Flow (main)
```
1. Parse user description from Input
   → If empty: ERROR "No feature description provided"
2. Extract key concepts from description
   → Identify: actors, actions, data, constraints
3. For each unclear aspect:
   → Mark with [NEEDS CLARIFICATION: specific question]
4. Fill User Scenarios & Testing section
   → If no clear user flow: ERROR "Cannot determine user scenarios"
5. Generate Functional Requirements
   → Each requirement must be testable
   → Mark ambiguous requirements
6. Identify Key Entities (if data involved)
7. Run Review Checklist
   → If any [NEEDS CLARIFICATION]: WARN "Spec has uncertainties"
   → If implementation details found: ERROR "Remove tech details"
8. Return: SUCCESS (spec ready for planning)
```

---

## ⚡ Quick Guidelines
- ✅ Focus on WHAT users need and WHY
- ❌ Avoid HOW to implement (no tech stack, APIs, code structure)
- 👥 Written for business stakeholders, not developers

### Section Requirements
- **Mandatory sections**: Must be completed for every feature
- **Optional sections**: Include only when relevant to the feature
- When a section doesn't apply, remove it entirely (don't leave as "N/A")

### For AI Generation
When creating this spec from a user prompt:
1. **Mark all ambiguities**: Use [NEEDS CLARIFICATION: specific question] for any assumption you'd need to make
2. **Don't guess**: If the prompt doesn't specify something (e.g., "login system" without auth method), mark it
3. **Think like a tester**: Every vague requirement should fail the "testable and unambiguous" checklist item
4. **Common underspecified areas**:
   - User types and permissions
   - Data retention/deletion policies  
   - Performance targets and scale
   - Error handling behaviors
   - Integration requirements
   - Security/compliance needs

---

## User Scenarios & Testing *(mandatory)*

### Primary User Story
単一利用者は経費を私費で立替えた直後にアプリを開き、パスワードでアクセス保護を設定/解除しつつ、日付・勘定科目（借方/貸方）・金額・摘要を入力し、借方合計と貸方合計が一致する振替伝票を作成して保存し、必要に応じてPDFを生成・印刷して紙の振替伝票を置き換える。また後から履歴を一覧・参照できる。

### Acceptance Scenarios
1. **Given** 立替経費が発生しアプリに初回アクセスする, **When** 利用者が初回パスワードを設定し振替伝票入力画面を開く, **Then** 入力フォーム（行追加/削除、摘要入力、日付入力、勘定科目選択/その他自由入力）が表示される。
2. **Given** 借方と貸方の行が入力済みで金額合計が一致している, **When** 利用者が「保存」操作を行う, **Then** 振替伝票が保存され履歴に新しいレコードとして追加され伝票番号が自動採番（未入力の場合）される。
3. **Given** 入力中に借方合計と貸方合計が不一致, **When** 利用者が「保存」を試みる, **Then** 保存は拒否され不一致警告が表示される。
4. **Given** 既に保存済みの振替伝票詳細画面, **When** 利用者が「PDF出力」を選択, **Then** 対応するレイアウトでPDFが生成されダウンロードまたは印刷ダイアログが開く。
5. **Given** アプリ起動後パスワード保護が有効, **When** 正しいパスワードを入力, **Then** 振替伝票作成/履歴閲覧機能へアクセスできる（誤りは拒否される）。

### Edge Cases
- 借方または貸方に行が一つも無いまま保存試行 → 保存拒否。
- 借方/貸方金額の片方が未入力または0の行がある → その行は保存前に自動除外。除外後に借方または貸方が0件ならエラー。
- 摘要は200文字を上限とし超過時は保存不可（入力時に残り文字数表示）。
- 同一伝票番号を手入力で重複指定 → 保存エラー（ユーザーに別番号再入力を促す、システム側で自動変更はしない）。
- 「その他」科目選択後科目自由入力が空のまま保存 → 保存拒否（エラーメッセージ表示）。
- PDF生成時に内部エラー → 伝票データは保持され、ユーザーに再試行案内を表示。
- 初回アクセス時はパスワード未設定なら設定画面に強制遷移し設定完了まで他機能を利用不可。

## Requirements *(mandatory)*

### Functional Requirements
- **FR-001**: システムは利用者が借方/貸方行（勘定科目・金額）と日付・摘要を入力して振替伝票を作成できること。
- **FR-002**: システムは借方合計金額と貸方合計金額が一致しない場合、保存を拒否し不一致を明示すること。
- **FR-003**: システムは振替伝票保存時に未指定であれば YYYYMMDD-連番(当日内3桁ゼロ埋め) 形式で一意な伝票番号を採番すること（例: 20250906-001）。
- **FR-004**: システムは利用者が任意で伝票番号を指定した場合、既存番号との重複を検出し重複時は保存を拒否し再入力を促す（自動再採番は行わない）。
- **FR-005**: システムは勘定科目選択用プルダウンで標準科目リスト（現金, 預金, 売掛金, 未収入金, 旅費交通費, 通信費, 消耗品費, 雑費, 立替金, 仮払金, 租税公課, 支払手数料, その他）を表示すること。
- **FR-006**: システムは「その他」選択時に自由入力科目名を必須とし未入力なら保存を拒否すること。
- **FR-007**: システムは保存済み振替伝票を一覧表示し、日付・伝票番号・摘要部分一致検索・金額合計・含まれる勘定科目でソート/フィルタできること（少なくとも日付/伝票番号/金額合計ソート + 摘要テキストフィルタ）。
- **FR-008**: システムは任意の保存済み振替伝票をPDF形式（A4縦, 上下15mm左右12mm余白, フォント本文10pt, ヘッダ: アプリ名+伝票番号+日付）で生成し利用者がダウンロードまたは印刷できること。行が1ページを超える場合は複数ページ継続。
- **FR-009**: システムは振替伝票作成履歴（全入力項目値と生成日時）を7年間保持しユーザー操作での削除機能を本スコープでは提供しない。
- **FR-010**: システムは初回アクセス時にパスワード設定を必須とし、以後アクセス時に認証を要求する。再設定には現行パスワードを要する。
- **FR-011**: システムはパスワード誤入力5回連続で10分間ロックし、ロック解除後失敗回数をリセットする。10分経過または正しいパスワード入力成功で解除。
- **FR-012**: システムは入力フォームで借方/貸方の合計一致可否をリアルタイムに視覚表示する（例: 一致=緑, 不一致=警告表示）。
- **FR-013**: システムは各行の借方/貸方区分を視覚的に区別し誤入力を防止する。
- **FR-014**: システムは摘要入力を最大200文字に制限し超過時保存不可とし残り文字数を表示する。
- **FR-015**: システムは日付未入力の場合、保存時に当日の日付を自動補完する。

### 非機能・制約 (必要最小限)
- **NFR-001**: 単一利用者前提で同時編集競合は想定しない（将来マルチユーザー化は別機能）。
- **NFR-002**: 振替伝票保存操作の完了時間は95%のリクエストで2秒以内、最大10秒を超えない。
- **NFR-003**: パスワードは平文保管しない（ハッシュ化等の安全な保管方式を要するが方式詳細は実装段階で決定）。
- **NFR-004**: PDF生成は95%のリクエストで5秒以内、最大15秒を超えない。
- **NFR-005**: 年間想定伝票数上限: 2,000件（性能要件の前提）。
- **NFR-006**: データ保持: 7年間保持（法令上の一般的保存要件を前提）し期間内は改ざん/削除を行わない（アプリ上削除機能なし）。

### Key Entities *(include if feature involves data)*
- **Voucher (振替伝票)**: 立替経費に対する仕訳記録単位。属性: 伝票番号, 日付, 摘要, 借方合計, 貸方合計, 作成日時。
- **VoucherLine (仕訳行)**: 振替伝票を構成する行。属性: 区分(借方/貸方), 勘定科目, 金額, 科目自由入力（"その他"時）, 行順序。関係: Voucher に複数属する。
- **Account (勘定科目)**: 標準科目集合（現金/預金/売掛金/未収入金/旅費交通費/通信費/消耗品費/雑費/立替金/仮払金/租税公課/支払手数料/その他）。属性: 科目コード, 表示名, 種別。
- **UserAccess (利用アクセス設定)**: パスワード設定状態とロック状態。属性: パスワード設定有無, 失敗回数, ロックフラグ, 最終アクセス日時, ロック解除予定時刻。

---

## Assumptions & Decisions
- 採番方式: 日毎連番（YYYYMMDD-001形式）で一意性確保。
- 伝票番号重複時: 自動調整せずユーザー再入力。
- 不完全行: 金額未入力/0または科目未選択は自動除外。結果として任意側0件ならエラー。
- 勘定科目リスト: 小規模事業の主要科目＋その他（上記FR-005参照）。
- 摘要文字数: 200文字上限。
- パスワード: 初回必須設定。再設定は現行パスワード必須。忘失時の救済（初期化復旧等）はスコープ外。
- 誤入力ロック: 5回失敗で10分ロック、時間経過または成功で解除。
- データ保持: 7年間。期間内削除機能なし（法令準拠前提）。
- パフォーマンス指標: 保存≤2秒(95%) / PDF≤5秒(95%)。
- 年間件数前提: 最大2,000件を計画上限と想定。

---

## Review & Acceptance Checklist
*GATE: Automated checks run during main() execution*

### Content Quality
- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

### Requirement Completeness
- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and unambiguous
- [x] Success criteria are measurable
- [x] Scope is clearly bounded (単一利用者/履歴保存/PDFに限定)
- [x] Dependencies and assumptions identified

---

## Execution Status
*Updated by main() during processing*

- [ ] User description parsed
- [ ] Key concepts extracted
- [ ] Ambiguities marked
- [ ] User scenarios defined
- [ ] Requirements generated
- [ ] Entities identified
- [ ] Review checklist passed

---
