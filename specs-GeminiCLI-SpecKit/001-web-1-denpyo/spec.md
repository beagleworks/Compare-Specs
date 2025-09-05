# Feature Specification: 振替伝票を作成できるWebアプリケーション

**Feature Branch**: `001-web-1-denpyo`  
**Created**: 2025-09-05  
**Status**: Draft  
**Input**: User description: "振替伝票を作成できるWebアプリケーションを作成してください 1. アプリケーション名 Denpyo 2. アプリケーションの目的 - 紙の振替伝票に手書きする行為をアプリケーションで置き換える - 振替伝票の作成履歴を記録する 3. アプリケーションの機能要件 - 振替伝票を作成できる - 振替伝票をPDF化して保存、もしくは印刷することができる - 入力した情報をデータベースに記録できる - 利用者は1名であり、アカウントは不要。ただし他者に閲覧されるのを防ぐため、利用時にパスワードを設定できる。 4. 振替伝票の利用ケース 経費を支払ったとき、既定の領収書が入手できなかった場合に代わりに作成する(例えば業務中の移動に関する電車代を自身の財布から建て替えた場合) 5. 振替伝票の項目 - 日付 - 借方／貸方科目 - 借方／貸方金額 - 摘要 - 借方／貸方合計金額 - ナンバー(任意) 6. 振替伝票の要件 - 貸方、借方の合計金額は一致している必要がある - 借方／貸方科目は一般的な勘定科目をプルダウンで選べるようにするが、「その他」を作成し自由入力も可能とする"

---

## ⚡ Quick Guidelines
- ✅ Focus on WHAT users need and WHY
- ❌ Avoid HOW to implement (no tech stack, APIs, code structure)
- 👥 Written for business stakeholders, not developers

---

## User Scenarios & Testing *(mandatory)*

### Primary User Story
A user needs to record an expense for which they do not have a formal receipt (e.g., paying for business-related train fare with personal cash). They open the "Denpyo" application. To prevent unauthorized access, they first enter a password. Once authenticated, they create a new transfer slip, filling in the date and a description of the expense. They add one or more debit and credit entries, ensuring the totals match. They save the slip, which is stored in a history log. The user can then generate a PDF of the slip to print or save for their accounting records.

### Acceptance Scenarios
1. **Given** the user has entered valid slip details with matching debit and credit totals, **When** they click the "Save" button, **Then** the slip is persisted to the database and appears in the creation history.
2. **Given** a saved slip exists in the history, **When** the user clicks the "Print/PDF" button for that slip, **Then** a PDF version of the slip is generated and made available for download or printing.
3. **Given** the user is creating a new slip and has entered details where the total debit and credit amounts do not match, **When** they attempt to save the slip, **Then** the system displays an error message indicating that the totals must be equal.
4. **Given** the application is launched for the first time, **When** the user accesses it, **Then** they are prompted to set and enter a password to proceed.

### Edge Cases
- How should the system behave if the database is unavailable when a user tries to save a slip or view history?

## Requirements *(mandatory)*

### Functional Requirements
- **FR-001**: The system MUST allow a user to create a transfer slip containing a date, summary, and one or more debit/credit entries.
- **FR-002**: The system MUST persist all saved transfer slips to a database.
- **FR-003**: The system MUST provide a view of the historical record of all created slips.
- **FR-004**: The system MUST allow the user to generate a PDF file from any saved transfer slip.
- **FR-005**: The system MUST allow the user to print any saved transfer slip.
- **FR-006**: The system MUST enforce a password protection mechanism for application access.
- **FR-007**: The system MUST validate that the sum of all debit amounts equals the sum of all credit amounts before a slip can be saved.
- **FR-008**: The system MUST provide a pre-populated dropdown list of common account titles for debit/credit entries.
- **FR-009**: The account title dropdown MUST include an "Other" option that, when selected, allows for free-form text input.
- **FR-010**: The system MAY allow the user to add an optional "Number" to a transfer slip.

### Key Entities *(include if feature involves data)*
- **Transfer Slip**: Represents a single, complete financial transaction record.
  - **Attributes**: Date, Summary, Number (Optional), Total Debit Amount, Total Credit Amount.
  - **Relationships**: Has one or more **Slip Entries**.
- **Slip Entry**: Represents a single line item within a Transfer Slip.
  - **Attributes**: Account Title, Amount, Type (Debit or Credit).
- **Account Title**: Represents a category for financial entries.
  - **Attributes**: Name (e.g., "Travel Expenses", "Cash").

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
- [x] Scope is clearly bounded
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