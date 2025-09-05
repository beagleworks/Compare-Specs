# Tasks: Denpyo 振替伝票作成・PDF保存機能

**Input**: Design documents from `/specs/001-web-denpyo-pdf/`
**Prerequisites**: plan.md (required), research.md, data-model.md, contracts/

## Execution Flow (main)
```
1. Load plan.md from feature directory
   → If not found: ERROR "No implementation plan found"
   → Extract: tech stack, libraries, structure
2. Load optional design documents:
   → data-model.md: Extract entities → model tasks
   → contracts/: Each file → contract test task
   → research.md: Extract decisions → setup tasks
3. Generate tasks by category:
   → Setup: project init, dependencies, linting
   → Tests: contract tests, integration tests
   → Core: models, services, API routes
   → Integration: DB, middleware, logging
   → Frontend: pages, client
   → Polish: performance, accessibility, docs
4. Apply task rules:
   → Different files = mark [P] for parallel
   → Same file = sequential (no [P])
   → Tests before implementation (TDD)
5. Number tasks sequentially (T001, T002...)
6. Generate dependency graph
7. Create parallel execution examples
8. Validate task completeness:
   → All contracts have tests?
   → All entities have model tasks?
   → All endpoints implemented?
9. Return: SUCCESS (tasks ready for execution)
```

## Format: `[ID] [P?] Description`
- [P]: Can run in parallel (different files, no direct dependencies)
- Include exact file paths in descriptions

## Path Conventions (from plan.md → Web app)
- backend/src/{models,services,api,lib}
- backend/tests/{contract,integration,unit,e2e}
- frontend/src/{pages,components,services}

---

## Phase 3.1: Setup
- [ ] T001 Create project structure (directories only)
  - backend/src/{models,services,api,lib}
  - backend/tests/{contract,integration,unit,e2e}
  - db/ (for sqlite file & schema)
  - frontend/src/{pages,components,services}
- [ ] T002 Initialize backend Deno project config
  - Create `backend/deno.jsonc` with tasks: fmt, lint, test, dev
  - Create `backend/import_map.json` if needed
- [ ] T003 [P] Database bootstrap
  - Create `db/schema.sql` (tables: voucher, voucher_line, user_access, schema_migrations; FK ON)
  - Create `backend/src/services/db.ts` (connection helper skeleton; loads schema.sql on first run)
- [ ] T004 [P] Test bootstrap & helpers
  - Create `backend/tests/_setup.ts` (temp DB per test, cleanup)
  - Wire via `deno.jsonc` test options
- [ ] T005 [P] Shared utils scaffolding (skeleton only, no impl)
  - `backend/src/lib/logger.ts` (JSON lines logger stub)
  - `backend/src/lib/errors.ts` (error helpers, error DTO contract)
  - `backend/src/lib/id.ts` (YYYYMMDD-### generator placeholder)
- [ ] T006 Initialize frontend (React + TS)
  - Create `frontend/` scaffold (Vite React TS or equivalent) and `frontend/tsconfig.json`

## Phase 3.2: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.3
CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation.

### Contract tests (from contracts/openapi.yaml)
- [ ] T007 [P] Contract test POST /api/auth/password in `backend/tests/contract/auth_password_post.test.ts`
- [ ] T008 [P] Contract test POST /api/auth/login in `backend/tests/contract/auth_login_post.test.ts`
- [ ] T009 [P] Contract test POST /api/auth/logout in `backend/tests/contract/auth_logout_post.test.ts`
- [ ] T010 [P] Contract test POST /api/vouchers in `backend/tests/contract/vouchers_post.test.ts`
- [ ] T011 [P] Contract test GET /api/vouchers in `backend/tests/contract/vouchers_get_list.test.ts`
- [ ] T012 [P] Contract test GET /api/vouchers/{id} in `backend/tests/contract/vouchers_get_id.test.ts`
- [ ] T013 [P] Contract test GET /api/vouchers/{id}/pdf in `backend/tests/contract/vouchers_get_id_pdf.test.ts`

### Integration tests (from quickstart and data-model)
- [ ] T014 [P] Integration: initial password set flow in `backend/tests/integration/auth_init_password.test.ts`
- [ ] T015 [P] Integration: login/logout and lockout (5 fails → 10min) in `backend/tests/integration/auth_lockout.test.ts`
- [ ] T016 [P] Integration: voucher create with balance validation and numbering in `backend/tests/integration/voucher_create_balance_numbering.test.ts`
- [ ] T017 [P] Integration: voucher list filters (date, q) in `backend/tests/integration/voucher_list_filters.test.ts`
- [ ] T018 [P] Integration: voucher PDF endpoint 200/404 in `backend/tests/integration/voucher_pdf_endpoint.test.ts`

### Unit/validation tests
- [ ] T019 [P] Zod schema validation tests for Voucher/VoucherLine/UserAccess in `backend/tests/unit/validation_schemas.test.ts`

## Phase 3.3: Core Implementation (ONLY after tests are failing)
- [ ] T020 [P] Implement Zod schemas in `backend/src/models/schemas.ts` (Voucher, VoucherLine, UserAccess)
- [ ] T021 [P] Implement DB layer
  - `backend/src/services/db.ts` (connect, migrate init, FK ON)
  - Apply `db/schema.sql` (voucher, voucher_line, user_access)
- [ ] T022 Implement Auth service & routes
  - Service: `backend/src/services/auth.ts` (bcrypt hash cost=12, lockout, session token)
  - Routes: `backend/src/api/auth.ts` (POST /api/auth/password, /login, /logout)
- [ ] T023 Implement Voucher service & routes
  - Service: `backend/src/services/voucher.ts` (create with transaction + numbering, get, list with filters)
  - Routes: `backend/src/api/vouchers.ts` (POST /api/vouchers, GET /api/vouchers, GET /api/vouchers/:id)
- [ ] T024 Implement PDF exporter placeholder
  - `backend/src/services/pdf.ts` (generate minimal application/pdf response containing voucher summary)
  - Route: in `backend/src/api/vouchers.ts` add GET /api/vouchers/:id/pdf
- [ ] T025 Middleware & app wiring
  - `backend/src/api/middleware/auth.ts` (session check for protected routes)
  - `backend/src/api/middleware/logging.ts` (structured log + traceId)
  - `backend/src/main.ts` (Hono app, error handler, cookie httpOnly+Secure, mount routes)

## Phase 3.4: Integration (backend)
- [ ] T026 Security headers & CORS (minimal) in `backend/src/api/middleware/security.ts` and wire in `backend/src/main.ts`

## Phase 3.5: Frontend (contract-driven)
- [ ] T027 [P] API client thin wrapper in `frontend/src/services/api.ts` (fetch, JSON parse, error contract)
- [ ] T028 Login page in `frontend/src/pages/Login.tsx` (initial password set → login flow)
- [ ] T029 Voucher list page in `frontend/src/pages/VoucherList.tsx` (filters: date, q; links to detail/new)
- [ ] T030 Voucher create form in `frontend/src/pages/VoucherNew.tsx` (dynamic rows, client-side balance hint)
- [ ] T031 Voucher detail + PDF in `frontend/src/pages/VoucherDetail.tsx` (open `/api/vouchers/:id/pdf`)

## Phase 3.6: Polish
- [ ] T032 [P] Add minimal unit tests for critical logic (id generator, balance calc) in `backend/tests/unit/core_logic.test.ts`
- [ ] T033 Performance instrumentation (p95 logging for save/PDF) in `backend/src/lib/logger.ts` + middleware timing
- [ ] T034 Accessibility pass (labels, keyboard, contrast) across frontend pages
- [ ] T035 [P] Update docs (`specs/001-web-denpyo-pdf/quickstart.md`, `README.md`) and add `scripts/version-bump.sh` (patch)

## Dependencies
- Tests (T007–T019) must fail first, before implementation (T020–T025)
- T021 (DB) blocks T022–T024
- T022 (Auth service/routes) blocks protected endpoint tests from passing
- T023 (Voucher service/routes) blocks PDF (T024) and frontend voucher pages (T029–T031)
- T024 (PDF) blocks PDF-related tests and frontend detail page (T031)
- T025–T026 wiring/middleware required before contract tests go GREEN
- Frontend (T027–T031) depends on backend routes (T022–T024) being available
- Polish tasks (T032–T035) come last

## Parallel Example
```
# Launch contract tests together (different files, no dependencies among tests):
Task: "Contract test POST /api/auth/password in backend/tests/contract/auth_password_post.test.ts"
Task: "Contract test POST /api/auth/login in backend/tests/contract/auth_login_post.test.ts"
Task: "Contract test POST /api/auth/logout in backend/tests/contract/auth_logout_post.test.ts"
Task: "Contract test POST /api/vouchers in backend/tests/contract/vouchers_post.test.ts"
Task: "Contract test GET /api/vouchers in backend/tests/contract/vouchers_get_list.test.ts"
Task: "Contract test GET /api/vouchers/{id} in backend/tests/contract/vouchers_get_id.test.ts"
Task: "Contract test GET /api/vouchers/{id}/pdf in backend/tests/contract/vouchers_get_id_pdf.test.ts"
```

## Validation Checklist
- [x] All contracts have corresponding tests (7/7 endpoints)
- [x] All entities have model/DB tasks (Voucher, VoucherLine, UserAccess)
- [x] All tests come before implementation
- [x] Parallel tasks only touch independent files
- [x] Each task specifies exact file path(s)
- [x] No [P] tasks modify the same file

---
*Generated from templates/tasks-template.md and design docs on branch `001-web-denpyo-pdf`.*
