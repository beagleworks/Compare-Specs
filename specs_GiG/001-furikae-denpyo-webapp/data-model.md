# Data Model (Phase 1 Draft)

## Overview
振替伝票, 仕訳明細, 勘定科目マスター, アプリ設定。SQLiteを前提。外部キー有効化。

## Entities
### Voucher
| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| id | INTEGER | PK AUTOINCREMENT | 内部ID |
| voucher_number | TEXT | UNIQUE, NOT NULL | 形式: YYYYMMDD-NNN |
| date | TEXT | NOT NULL | ISO日付 YYYY-MM-DD |
| total_debit | INTEGER | NOT NULL, >=0 | 確認用キャッシュ |
| total_credit | INTEGER | NOT NULL, >=0 | 同上 (一致検証) |
| created_at | TEXT | NOT NULL | ISO8601 |
| updated_at | TEXT | NOT NULL | ISO8601 |

Indexes: UNIQUE(voucher_number), INDEX(date)

### Entry
| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| id | INTEGER | PK AUTOINCREMENT | |
| voucher_id | INTEGER | FK REFERENCES voucher(id) ON DELETE CASCADE | |
| side | TEXT | NOT NULL | 'D' or 'C' |
| account_type | TEXT | NOT NULL | 'standard' or 'other' |
| account_name | TEXT | NOT NULL | |
| amount | INTEGER | NOT NULL, >0 | 通貨(円)整数 |
| description | TEXT | NOT NULL | 長さ<=500 |
| line_no | INTEGER | NOT NULL | 1..n |

Index: voucher_id, (voucher_id,line_no)

### AccountMaster
| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| code | TEXT | PK | 例: CASH, TRAVEL |
| name | TEXT | NOT NULL | |
| sort_order | INTEGER | NOT NULL | 表示順 |
| active | INTEGER | NOT NULL DEFAULT 1 | 0/1 |
| created_at | TEXT | NOT NULL | |
| updated_at | TEXT | NOT NULL | |

### AppSetting
| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| id | INTEGER | PK (常に1行) | |
| password_hash | TEXT | NULL | Argon2/Bcrypt |
| created_at | TEXT | NOT NULL | |
| updated_at | TEXT | NOT NULL | |

## Derived / Validation Rules
1. Voucher: total_debit == sum(entries.side='D'.amount)
2. Voucher: total_credit == sum(entries.side='C'.amount)
3. Voucher: total_debit == total_credit
4. Entry: amount > 0
5. Entry: description length <= 500
6. voucher_number uniqueness; if absent generate date-based serial
7. Consecutive line_no per voucher starting at 1
8. account_type 'other' → account_name自由入力; 'standard'→ account_nameはAccountMaster.nameに一致

## Migrations (Initial)
1. Create tables voucher, entry, account_master, app_setting
2. Seed account_master minimal set

## JSON Schemas (Conceptual)
(詳細は OpenAPI / Zod Schema にて)

Voucher (response):
```
{
  id: number,
  voucherNumber: string,
  date: string,
  entries: Entry[],
  totalDebit: number,
  totalCredit: number,
  createdAt: string,
  updatedAt: string
}
```
Entry:
```
{
  id?: number,
  side: 'D'|'C',
  accountType: 'standard'|'other',
  accountName: string,
  amount: number,
  description: string,
  lineNo?: number
}
```

## Indices & Performance Notes
- date検索最適化: INDEX(date)
- voucher_numberアクセス高速化: UNIQUE index
- 大規模化時: amount集計トリガ or view (現状不要)

## Future Considerations
- 論理削除フラグ (不要ならこのまま)
- 科目階層化 (現状平lat)
- エクスポートCSV
