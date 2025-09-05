# Data Model

## Entities
### Voucher
Fields:
- id (string: 伝票番号 YYYYMMDD-###)
- date (ISO date)
- summary (string ≤200)
- debitTotal (number >=0)
- creditTotal (number >=0)
- createdAt (ISO timestamp)
Constraints:
- debitTotal === creditTotal
- At least 1 debit line and 1 credit line

### VoucherLine
Fields:
- voucherId (FK Voucher.id)
- side ("debit" | "credit")
- account (string in STANDARD_ACCOUNTS or customAccount)
- customAccount (optional string when account === "その他")
- amount (number >0)
- order (integer)
Constraints:
- If account === "その他" then customAccount required

### UserAccess
Fields:
- passwordHash (string)
- failedAttempts (integer)
- lockUntil (nullable timestamp)
- updatedAt (timestamp)

## Enumerations
STANDARD_ACCOUNTS = [現金, 預金, 売掛金, 未収入金, 旅費交通費, 通信費, 消耗品費, 雑費, 立替金, 仮払金, 租税公課, 支払手数料, その他]

## Validation Rules Summary
- Voucher.summary length ≤200
- VoucherLine.amount >0
- Balanced totals check before persist
- Unique voucher id
- Password min length 8 (implicit decision)

## Derived Data
- debitTotal / creditTotal = sum(lines.side=debit/credit)

## Indexing
- Voucher(date), Voucher(id PK)
- VoucherLine(voucherId)

## Persistence Notes
- Single SQLite file db/denpyo.sqlite
- Foreign key enforcement ON

## Migration Approach
- Initial schema create; future changes tracked via schema_migrations table
