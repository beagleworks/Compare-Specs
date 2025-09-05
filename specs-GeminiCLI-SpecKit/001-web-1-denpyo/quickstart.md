# Quickstart Guide

This guide provides instructions on how to set up and run the Denpyo application locally for development and testing.

## Prerequisites

- [Deno](https://deno.land/) (v1.x or later)
- [Node.js](https://nodejs.org/) (v18.x or later) and npm

## Backend Setup (Deno + Hono)

1.  **Navigate to the backend directory**:
    ```bash
    cd backend
    ```

2.  **Run the server**:
    The server will automatically fetch dependencies on the first run.
    ```bash
    deno run --allow-net --allow-read --allow-write main.ts
    ```
    The backend API will be available at `http://localhost:8000`.

3.  **Run tests**:
    ```bash
    deno test
    ```

## Frontend Setup (React + Vite)

1.  **Navigate to the frontend directory**:
    ```bash
    cd frontend
    ```

2.  **Install dependencies**:
    ```bash
    npm install
    ```

3.  **Run the development server**:
    ```bash
    npm run dev
    ```
    The frontend application will be available at `http://localhost:5173`.

4.  **Run tests**:
    ```bash
    npm test
    ```

## Database

- The application uses a single SQLite database file named `denpyo.db`.
- This file will be created automatically in the `backend` directory when the server is first run and a slip is created.
