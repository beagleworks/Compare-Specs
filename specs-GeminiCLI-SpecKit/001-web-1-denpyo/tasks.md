# Tasks for Feature: Denpyo Web Application

This document breaks down the implementation of the Denpyo Web Application feature into specific, executable tasks. All file paths are relative to the repository root.

## Phase 1: Project Setup

*T001: Create backend directory structure*
- **File**: `backend/`
- **Action**: Create the directory structure for the backend, including `backend/src/` and `backend/tests/`.

*T002: Initialize frontend project*
- **File**: `frontend/`
- **Action**: Use Vite to initialize a new React + TypeScript project in the `frontend` directory. Run `npm create vite@latest frontend -- --template react-ts`.

*T003: Install frontend dependencies*
- **File**: `frontend/package.json`
- **Action**: Navigate to the `frontend` directory and run `npm install` to install the default dependencies.

*T004: Configure frontend linting*
- **File**: `frontend/.eslintrc.cjs`, `frontend/.prettierrc`
- **Action**: Set up ESLint and Prettier for the frontend project to enforce code style and quality.

## Phase 2: Backend Development (TDD)

*T005: [Test] [P] Write database schema test*
- **File**: `backend/tests/db_test.ts`
- **Action**: Write a failing test that attempts to connect to an in-memory SQLite database and query for the `slips` and `slip_entries` tables, expecting them to exist.

*T006: [Implement] Create database initialization script*
- **File**: `backend/src/db.ts`
- **Action**: Implement a function that connects to the SQLite database and executes the SQL `CREATE TABLE` statements defined in `data-model.md`. Ensure the test from T005 passes.

*T007: [Test] [P] Write login endpoint contract test*
- **File**: `backend/tests/auth_api_test.ts`
- **Action**: Write a failing contract test for the `POST /api/login` endpoint. Test for both incorrect password (401) and correct password (200 with JWT) scenarios.

*T008: [Implement] Implement login endpoint*
- **File**: `backend/src/main.ts`, `backend/src/auth.ts`
- **Action**: Set up a basic Hono server in `main.ts`. Implement the `/api/login` endpoint. Use a hardcoded password for now. Add a dependency for JWT and implement token generation.

*T009: [Test] [P] Write create slip endpoint contract test*
- **File**: `backend/tests/slips_api_test.ts`
- **Action**: Write a failing contract test for `POST /api/slips`. The test should send a valid slip payload and assert a 201 Created response.

*T010: [Implement] Implement create slip endpoint*
- **File**: `backend/src/main.ts`
- **Action**: Implement the `POST /api/slips` endpoint. It must include the validation logic to ensure the sum of debits equals the sum of credits.

*T011: [Test] Add get slips endpoint contract test*
- **File**: `backend/tests/slips_api_test.ts`
- **Action**: Add a failing contract test for `GET /api/slips` to the existing test file.

*T012: [Implement] Implement get slips endpoint*
- **File**: `backend/src/main.ts`
- **Action**: Implement the `GET /api/slips` endpoint to return all slips from the database.

*T013: [Test] Add PDF generation endpoint contract test*
- **File**: `backend/tests/slips_api_test.ts`
- **Action**: Add a failing contract test for `GET /api/slips/{id}/pdf`. The test should assert the `Content-Type` header is `application/pdf`.

*T014: [Implement] Implement PDF generation endpoint*
- **File**: `backend/src/main.ts`
- **Action**: Research and add a Deno-compatible PDF generation library. Implement the endpoint to generate a PDF for a given slip.

## Phase 3: Frontend Development (TDD)

*T015: [Test] [P] Write Login page component test*
- **File**: `frontend/src/pages/LoginPage.test.tsx`
- **Action**: Write a failing component test (using Vitest) to verify that the `LoginPage` component renders a password input and a button.

*T016: [Implement] Create Login page component*
- **File**: `frontend/src/pages/LoginPage.tsx`
- **Action**: Create the `LoginPage` component. Make the test from T015 pass.

*T017: [Test] [P] Write Slip form component test*
- **File**: `frontend/src/components/SlipForm.test.tsx`
- **Action**: Write a failing component test that verifies the slip form renders all necessary inputs and that a new entry line can be added dynamically.

*T018: [Implement] Create Slip form component*
- **File**: `frontend/src/components/SlipForm.tsx`
- **Action**: Create the `SlipForm` component with inputs for date, summary, and a dynamic list of debit/credit entries.

*T019: [Test] [P] Write Slip history component test*
- **File**: `frontend/src/components/SlipHistory.test.tsx`
- **Action**: Write a failing component test that verifies the component can receive an array of slips and render them correctly.

*T020: [Implement] Create Slip history component*
- **File**: `frontend/src/components/SlipHistory.tsx`
- **Action**: Create the `SlipHistory` component.

*T021: [Implement] Create frontend API service*
- **File**: `frontend/src/services/api.ts`
- **Action**: Create a service that encapsulates all communication with the backend API (login, getSlips, createSlip).

*T022: [Implement] Create frontend auth service*
- **File**: `frontend/src/services/auth.ts`
- **Action**: Create a service to manage the user's authentication state, including storing and retrieving the JWT from local storage.

*T023: [Style] [P] Apply application-wide styles*
- **File**: `frontend/src/index.css`
- **Action**: Define a basic layout, color scheme, and typography for the application to ensure a clean and consistent user interface.

## Phase 4: Integration and Polish

*T024: [Test] Write end-to-end workflow test*
- **File**: `frontend/tests/e2e/main_workflow.spec.ts`
- **Action**: Set up an E2E test framework (e.g., Playwright). Write a failing test that simulates the entire user journey: logging in, creating a new slip, and seeing that slip in the history list.

*T025: [Implement] Integrate frontend and backend*
- **File**: `frontend/src/pages/HomePage.tsx`, `frontend/src/pages/LoginPage.tsx`
- **Action**: Connect the UI components to the API and auth services. Ensure the full application workflow is functional and the E2E test from T024 passes.

*T026: [Polish] [P] Implement frontend error handling*
- **File**: Various frontend components.
- **Action**: Improve the user experience by adding error handling. Display clear messages when API calls fail or when user input is invalid.

*T027: [Polish] Update documentation*
- **File**: `README.md`
- **Action**: Update the root `README.md` file with comprehensive instructions on how to set up, run, and test the entire application (both backend and frontend).

## Parallel Execution Example

The following tasks can be run in parallel as they do not have direct dependencies on each other:

- `T005: [Test] [P] Write database schema test`
- `T007: [Test] [P] Write login endpoint contract test`
- `T009: [Test] [P] Write create slip endpoint contract test`
- `T015: [Test] [P] Write Login page component test`
- `T017: [Test] [P] Write Slip form component test`
- `T019: [Test] [P] Write Slip history component test`
