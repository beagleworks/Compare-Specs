# API Contracts

This document defines the RESTful API for the Denpyo application.

## Authentication

A simple password-based authentication will be used. A JWT will be issued upon successful login and must be sent in the `Authorization` header for all subsequent requests.

### `POST /api/login`

- **Description**: Authenticates the user.
- **Request Body**:
  ```json
  {
    "password": "user-password"
  }
  ```
- **Response (200 OK)**:
  ```json
  {
    "token": "jwt-token"
  }
  ```
- **Response (401 Unauthorized)**: If the password is incorrect.

## Transfer Slips

### `GET /api/slips`

- **Description**: Retrieves a list of all saved transfer slips.
- **Response (200 OK)**:
  ```json
  [
    {
      "id": 1,
      "slip_date": "2025-09-06",
      "summary": "Purchase of office supplies",
      "total_amount": 1500,
      "entries": [
        { "type": "DEBIT", "account": "Office Supplies", "amount": 1500 },
        { "type": "CREDIT", "account": "Cash", "amount": 1500 }
      ]
    }
  ]
  ```

### `POST /api/slips`

- **Description**: Creates a new transfer slip.
- **Request Body**:
  ```json
  {
    "slip_date": "2025-09-06",
    "summary": "Client meeting travel",
    "slip_number": "optional-number",
    "entries": [
      { "type": "DEBIT", "account": "Travel Expenses", "amount": 880 },
      { "type": "CREDIT", "account": "Cash", "amount": 880 }
    ]
  }
  ```
- **Validation**: The sum of DEBIT amounts must equal the sum of CREDIT amounts.
- **Response (201 Created)**: The newly created slip object.

### `GET /api/slips/{id}/pdf`

- **Description**: Generates and returns a PDF version of a specific slip.
- **Response (200 OK)**:
  - **Content-Type**: `application/pdf`
  - **Body**: The PDF file content.
