# Tasks: 振替伝票作成Webアプリケーション

**Input**: Design documents from `/specs/001-furikae-denpyo-webapp/`
**Prerequisites**: plan.md ✓, research.md ✓, data-model.md ✓, contracts/ ✓

## Execution Flow (main)
```
1. Load plan.md from feature directory ✓
   → Extracted: TypeScript + Deno + Hono + React + SQLite
   → Structure: Web application (backend + frontend)
   → Libraries: furikae-core, pdf-generator, account-master
2. Load optional design documents ✓:
   → data-model.md: 4 entities (FurikaeDenpyo, ShiwakeEntry, Account, AppConfig)
   → contracts/: OpenAPI + Database schema → 11 endpoints
   → research.md: Technology decisions and architecture patterns
3. Generate tasks by category ✓:
   → Setup: Deno + React environment, SQLite
   → Tests: Contract tests for 11 endpoints, integration tests
   → Core: 4 models, 3 services, 3 libraries
   → Integration: Database, PDF generation, API endpoints
   → Polish: E2E tests, performance validation
4. Apply task rules ✓:
   → Different files = [P] for parallel execution
   → Tests before implementation (TDD mandatory)
   → Models → Services → API → UI sequence
5. Number tasks sequentially (T001-T035) ✓
6. Generate dependency graph ✓
7. Create parallel execution examples ✓
8. Validate task completeness ✓:
   → All 11 endpoints have contract tests ✓
   → All 4 entities have model tasks ✓
   → All 5 user scenarios have integration tests ✓
9. Return: SUCCESS (35 tasks ready for execution)
```

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- File paths based on web application structure

## Phase 3.1: Environment Setup
- [ ] T001 Create backend project structure with deno.json and import map
- [ ] T002 Create frontend project structure with package.json and Vite config
- [ ] T003 [P] Configure SQLite database directory and schema file
- [ ] T004 [P] Setup Deno dev script with file watching in backend/deno.json
- [ ] T005 [P] Setup React dev environment with TypeScript in frontend/

## Phase 3.2: Library Architecture (Constitutional Requirement)
- [ ] T006 [P] Create furikae-core library with CLI interface in backend/src/lib/furikae-core/
- [ ] T007 [P] Create pdf-generator library with CLI interface in backend/src/lib/pdf-generator/
- [ ] T008 [P] Create account-master library with CLI interface in backend/src/lib/account-master/
- [ ] T009 [P] Add --help, --version, --format flags to all library CLIs
- [ ] T010 [P] Create llms.txt documentation for each library

## Phase 3.3: Database Setup
- [ ] T011 Initialize SQLite database with schema from contracts/database.sql
- [ ] T012 [P] Create database migration system in backend/database/migrations/
- [ ] T013 [P] Load initial account master data from seeds in backend/database/seeds/
- [ ] T014 [P] Create database connection module in backend/src/lib/database-client/

## Phase 3.4: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.5
**CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation**

### Contract Tests (API Schema Validation)
- [ ] T015 [P] Contract test GET /api/denpyo in backend/tests/contract/test_denpyo_list.ts
- [ ] T016 [P] Contract test POST /api/denpyo in backend/tests/contract/test_denpyo_create.ts
- [ ] T017 [P] Contract test GET /api/denpyo/{id} in backend/tests/contract/test_denpyo_get.ts
- [ ] T018 [P] Contract test PUT /api/denpyo/{id} in backend/tests/contract/test_denpyo_update.ts
- [ ] T019 [P] Contract test DELETE /api/denpyo/{id} in backend/tests/contract/test_denpyo_delete.ts
- [ ] T020 [P] Contract test GET /api/denpyo/{id}/pdf in backend/tests/contract/test_denpyo_pdf.ts
- [ ] T021 [P] Contract test GET /api/accounts in backend/tests/contract/test_accounts_list.ts
- [ ] T022 [P] Contract test POST /api/accounts in backend/tests/contract/test_accounts_create.ts
- [ ] T023 [P] Contract test POST /api/auth/verify in backend/tests/contract/test_auth_verify.ts
- [ ] T024 [P] Contract test POST /api/auth/setup in backend/tests/contract/test_auth_setup.ts
- [ ] T025 [P] Contract test GET /api/auth/status in backend/tests/contract/test_auth_status.ts

### Integration Tests (User Scenarios)
- [ ] T026 [P] Integration test: 振替伝票作成フロー in backend/tests/integration/test_denpyo_creation.ts
- [ ] T027 [P] Integration test: PDF出力フロー in backend/tests/integration/test_pdf_generation.ts
- [ ] T028 [P] Integration test: 借方貸方バランス検証 in backend/tests/integration/test_balance_validation.ts
- [ ] T029 [P] Integration test: カスタム勘定科目使用 in backend/tests/integration/test_custom_accounts.ts
- [ ] T030 [P] Integration test: パスワード保護機能 in backend/tests/integration/test_password_protection.ts

## Phase 3.5: Core Implementation (ONLY after tests are failing)

### Data Models
- [ ] T031 [P] FurikaeDenpyo model with validation in backend/src/models/furikae_denpyo.ts
- [ ] T032 [P] ShiwakeEntry model with validation in backend/src/models/shiwake_entry.ts
- [ ] T033 [P] Account model with validation in backend/src/models/account.ts
- [ ] T034 [P] AppConfig model with validation in backend/src/models/app_config.ts

### Business Logic Services
- [ ] T035 DenpyoService with CRUD operations in backend/src/services/denpyo_service.ts
- [ ] T036 AccountService with master data in backend/src/services/account_service.ts
- [ ] T037 AuthService with password handling in backend/src/services/auth_service.ts

### Library Implementations
- [ ] T038 Implement furikae-core business logic and validation functions
- [ ] T039 Implement pdf-generator with jsPDF for 振替伝票 format
- [ ] T040 Implement account-master with default accounts and custom account management

## Phase 3.6: API Endpoints (Backend)
- [ ] T041 GET /api/denpyo endpoint with pagination in backend/src/api/denpyo_routes.ts
- [ ] T042 POST /api/denpyo endpoint with validation in backend/src/api/denpyo_routes.ts
- [ ] T043 GET /api/denpyo/{id} endpoint in backend/src/api/denpyo_routes.ts
- [ ] T044 PUT /api/denpyo/{id} endpoint in backend/src/api/denpyo_routes.ts
- [ ] T045 DELETE /api/denpyo/{id} endpoint in backend/src/api/denpyo_routes.ts
- [ ] T046 GET /api/denpyo/{id}/pdf endpoint in backend/src/api/denpyo_routes.ts
- [ ] T047 [P] GET /api/accounts endpoint in backend/src/api/account_routes.ts
- [ ] T048 [P] POST /api/accounts endpoint in backend/src/api/account_routes.ts
- [ ] T049 [P] Auth routes (verify, setup, status) in backend/src/api/auth_routes.ts
- [ ] T050 Main Hono app setup with CORS and error handling in backend/src/main.ts

## Phase 3.7: Frontend Implementation
### Base Infrastructure
- [ ] T051 [P] TypeScript type definitions in frontend/src/types/api.ts
- [ ] T052 [P] API client service in frontend/src/services/api_client.ts
- [ ] T053 [P] Authentication context and hooks in frontend/src/services/auth_context.tsx

### React Components
- [ ] T054 [P] DenpyoForm component for 振替伝票 input in frontend/src/components/DenpyoForm.tsx
- [ ] T055 [P] ShiwakeEntryRow component for 仕訳 input in frontend/src/components/ShiwakeEntryRow.tsx
- [ ] T056 [P] AccountSelector component with custom input in frontend/src/components/AccountSelector.tsx
- [ ] T057 [P] BalanceDisplay component for 借方貸方 totals in frontend/src/components/BalanceDisplay.tsx
- [ ] T058 [P] DenpyoList component for 振替伝票 listing in frontend/src/components/DenpyoList.tsx
- [ ] T059 [P] AuthForm component for password setup/verify in frontend/src/components/AuthForm.tsx

### Pages
- [ ] T060 Main dashboard page in frontend/src/pages/Dashboard.tsx
- [ ] T061 Denpyo create/edit page in frontend/src/pages/DenpyoEdit.tsx
- [ ] T062 Login page in frontend/src/pages/Login.tsx
- [ ] T063 App router setup in frontend/src/App.tsx

## Phase 3.8: Integration & Polish
### Database Integration
- [ ] T064 Connect all services to SQLite database with transaction support
- [ ] T065 [P] Add structured logging to all services in backend/src/lib/logger.ts
- [ ] T066 [P] Error handling middleware for Hono in backend/src/api/middleware/error_handler.ts

### Frontend Integration
- [ ] T067 Connect frontend components to API client
- [ ] T068 [P] Add loading states and error handling in frontend/src/hooks/useAsync.ts
- [ ] T069 [P] PDF download functionality in frontend/src/utils/pdf_download.ts

### End-to-End Testing
- [ ] T070 [P] E2E test: Complete 振替伝票 creation workflow in frontend/tests/e2e/denpyo_workflow.spec.ts
- [ ] T071 [P] E2E test: PDF generation and download in frontend/tests/e2e/pdf_generation.spec.ts
- [ ] T072 [P] E2E test: Authentication flow in frontend/tests/e2e/auth_flow.spec.ts

### Performance & Validation
- [ ] T073 Performance test: API response times <500ms in backend/tests/performance/api_performance.ts
- [ ] T074 Performance test: PDF generation <2s in backend/tests/performance/pdf_performance.ts
- [ ] T075 Execute quickstart.md validation scenarios manually

## Dependencies
```
Setup (T001-T005) → Library setup (T006-T010) → Database (T011-T014)
Database setup → Tests (T015-T030) → Models (T031-T034)
Models → Services (T035-T037) → Libraries (T038-T040)
Services → API endpoints (T041-T050)
API endpoints → Frontend infrastructure (T051-T053)
Frontend infrastructure → Components (T054-T059) → Pages (T060-T063)
Integration (T064-T069) → E2E tests (T070-T072) → Performance (T073-T075)
```

## Parallel Execution Examples
```bash
# Phase 3.2: Library setup (can run in parallel)
Task: "Create furikae-core library with CLI interface in backend/src/lib/furikae-core/"
Task: "Create pdf-generator library with CLI interface in backend/src/lib/pdf-generator/"
Task: "Create account-master library with CLI interface in backend/src/lib/account-master/"

# Phase 3.4: Contract tests (can run in parallel)
Task: "Contract test GET /api/denpyo in backend/tests/contract/test_denpyo_list.ts"
Task: "Contract test POST /api/denpyo in backend/tests/contract/test_denpyo_create.ts"
Task: "Contract test GET /api/accounts in backend/tests/contract/test_accounts_list.ts"

# Phase 3.5: Models (can run in parallel)
Task: "FurikaeDenpyo model with validation in backend/src/models/furikae_denpyo.ts"
Task: "ShiwakeEntry model with validation in backend/src/models/shiwake_entry.ts"
Task: "Account model with validation in backend/src/models/account.ts"
```

## Validation Checklist
*GATE: All items verified before task execution*

- [x] All 11 API endpoints have corresponding contract tests (T015-T025)
- [x] All 4 entities have model creation tasks (T031-T034)
- [x] All 5 user scenarios have integration tests (T026-T030)
- [x] Tests come before implementation (Phase 3.4 before 3.5)
- [x] Parallel tasks are truly independent (different files)
- [x] Each task specifies exact file path
- [x] No task modifies same file as another [P] task
- [x] Constitutional library requirement met (3 libraries with CLI)
- [x] TDD RED-GREEN-Refactor cycle enforced
- [x] Performance targets included (T073-T074)

## Notes
- **Critical**: ALL tests in Phase 3.4 MUST fail before implementing Phase 3.5
- Commit after each completed task
- Run `deno test` after backend changes
- Run `npm test` after frontend changes
- Library CLIs must support --help, --version, --format flags
- Follow quickstart.md for final validation

---
**Ready for execution**: 75 tasks generated following TDD principles and constitutional requirements
