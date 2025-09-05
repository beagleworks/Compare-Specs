# Data Model

This document defines the database schema based on the key entities identified in the feature specification. The database will be SQLite.

## Tables

### 1. `slips`

Stores the main information for each transfer slip.

| Column      | Type      | Constraints              | Description                               |
|-------------|-----------|--------------------------|-------------------------------------------|
| `id`        | `INTEGER` | `PRIMARY KEY AUTOINCREMENT` | Unique identifier for the slip.           |
| `slip_date` | `TEXT`    | `NOT NULL`               | The date of the transaction (ISO 8601 format). |
| `summary`   | `TEXT`    | `NOT NULL`               | A brief description of the transaction.   |
| `slip_number` | `TEXT`    |                          | An optional, user-defined number for the slip. |
| `created_at`| `TEXT`    | `NOT NULL`               | Timestamp of creation (ISO 8601 format).  |

**Example:**
```json
{
  "id": 1,
  "slip_date": "2025-09-06",
  "summary": "Purchase of office supplies",
  "slip_number": "PO-001",
  "created_at": "2025-09-06T10:00:00Z"
}
```

### 2. `slip_entries`

Stores the individual debit and credit lines for each transfer slip.

| Column    | Type      | Constraints              | Description                               |
|-----------|-----------|--------------------------|-------------------------------------------|
| `id`      | `INTEGER` | `PRIMARY KEY AUTOINCREMENT` | Unique identifier for the entry.          |
| `slip_id` | `INTEGER` | `NOT NULL, FOREIGN KEY(slips.id)` | Links the entry to a slip.                |
| `type`    | `TEXT`    | `NOT NULL`               | The type of entry: 'DEBIT' or 'CREDIT'.   |
| `account` | `TEXT`    | `NOT NULL`               | The account title (e.g., "Cash", "Supplies"). |
| `amount`  | `INTEGER` | `NOT NULL`               | The amount in the smallest currency unit (e.g., cents). |

**Example:**
```json
[
  {
    "id": 1,
    "slip_id": 1,
    "type": "DEBIT",
    "account": "Office Supplies",
    "amount": 1500
  },
  {
    "id": 2,
    "slip_id": 1,
    "type": "CREDIT",
    "account": "Cash",
    "amount": 1500
  }
]
```
