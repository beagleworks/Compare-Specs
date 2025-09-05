# Tasks: 振替伝票作成Webアプリケーション

**Input**: Design documents from `/specs/001-furikae-denpyo-webapp/`
**Prerequisites**: plan.md (required), research.md, data-model.md, contracts/

## Execution Flow (generated)
(Plan/Spec → Contracts → Data Model → User Stories)

## Phase 3.1: Setup
- [ ] T001 Create project structure (backend/, frontend/, shared/) per plan
- [ ] T002 Initialize backend Deno project (deps.ts, import_map.json, config) in `backend/`
- [ ] T003 Initialize frontend React TypeScript project in `frontend/`
- [ ] T004 [P] Configure lint + format (Deno fmt/deno.json + ESLint/Prettier) `backend/` & `frontend/`
- [ ] T005 [P] Add shared schema directory `shared/schema/` with Zod dependency setup
- [ ] T006 Setup SQLite database init script & migrations in `backend/src/db/migrate.ts`

## Phase 3.2: Tests First (TDD)
### Contract Tests (OpenAPI endpoints)
- [ ] T007 [P] Contract test List vouchers GET /v1/vouchers in `backend/tests/contract/vouchers_list_test.ts`
- [ ] T008 [P] Contract test Create voucher POST /v1/vouchers in `backend/tests/contract/vouchers_create_test.ts`
- [ ] T009 [P] Contract test Get voucher GET /v1/vouchers/{id} in `backend/tests/contract/vouchers_get_test.ts`
- [ ] T010 [P] Contract test Update voucher PUT /v1/vouchers/{id} in `backend/tests/contract/vouchers_update_test.ts`
- [ ] T011 [P] Contract test Delete voucher DELETE /v1/vouchers/{id} in `backend/tests/contract/vouchers_delete_test.ts`
- [ ] T012 [P] Contract test Voucher PDF POST /v1/vouchers/{id}/pdf in `backend/tests/contract/vouchers_pdf_test.ts`
- [ ] T013 [P] Contract test List accounts GET /v1/accounts in `backend/tests/contract/accounts_list_test.ts`
- [ ] T014 [P] Contract test Set password PUT /v1/settings/password in `backend/tests/contract/settings_password_test.ts`
- [ ] T015 [P] Contract test Auth POST /v1/auth in `backend/tests/contract/auth_test.ts`

### Integration Tests (User Stories / Flows)
- [ ] T016 [P] Integration test create + list voucher flow in `backend/tests/integration/voucher_create_list_flow_test.ts`
- [ ] T017 [P] Integration test debit/credit mismatch rejection in `backend/tests/integration/voucher_balance_validation_test.ts`
- [ ] T018 [P] Integration test edit voucher update timestamp in `backend/tests/integration/voucher_update_flow_test.ts`
- [ ] T019 [P] Integration test delete voucher removal in `backend/tests/integration/voucher_delete_flow_test.ts`
- [ ] T020 [P] Integration test password set + auth flow in `backend/tests/integration/password_auth_flow_test.ts`
- [ ] T021 [P] Integration test PDF generation (status/content-type) in `backend/tests/integration/pdf_generation_flow_test.ts`
- [ ] T022 [P] Integration test account 'other' free text in `backend/tests/integration/account_other_flow_test.ts`

### Frontend Integration (initial stubs)
- [ ] T023 [P] Frontend test: voucher form validation (debit!=credit) in `frontend/tests/integration/voucher_form_validation.test.ts`
- [ ] T024 [P] Frontend test: account other input toggle in `frontend/tests/integration/account_other_input.test.ts`

## Phase 3.3: Core Implementation (Backend Models/Services)
- [ ] T025 [P] Implement SQLite schema & migration script in `backend/src/db/migrate.ts`
- [ ] T026 [P] Implement DB connection utility in `backend/src/db/connection.ts`
- [ ] T027 [P] Implement AccountMaster seed in `backend/src/db/seed_accounts.ts`
- [ ] T028 [P] Voucher repository functions (no classes) in `backend/src/models/voucher_repo.ts`
- [ ] T029 [P] Entry repository functions in `backend/src/models/entry_repo.ts`
- [ ] T030 [P] Account repository functions in `backend/src/models/account_repo.ts`
- [ ] T031 [P] AppSetting repository functions in `backend/src/models/app_setting_repo.ts`
- [ ] T032 Voucher service (compose repos + validation) in `backend/src/services/voucher_service.ts`
- [ ] T033 Password service (hash/verify) in `backend/src/services/password_service.ts`
- [ ] T034 PDF generation module (HTML template render) in `backend/src/pdf/voucher_pdf.ts`
- [ ] T035 Validation schemas (Zod) shared export in `shared/schema/voucher.ts`
- [ ] T036 Validation schemas (password/account) in `shared/schema/meta.ts`

## Phase 3.4: Backend API Endpoints (Hono)
- [ ] T037 [P] Route: GET /v1/vouchers in `backend/src/api/vouchers_list.ts`
- [ ] T038 [P] Route: POST /v1/vouchers in `backend/src/api/vouchers_create.ts`
- [ ] T039 [P] Route: GET /v1/vouchers/{id} in `backend/src/api/vouchers_get.ts`
- [ ] T040 [P] Route: PUT /v1/vouchers/{id} in `backend/src/api/vouchers_update.ts`
- [ ] T041 [P] Route: DELETE /v1/vouchers/{id} in `backend/src/api/vouchers_delete.ts`
- [ ] T042 [P] Route: POST /v1/vouchers/{id}/pdf in `backend/src/api/vouchers_pdf.ts`
- [ ] T043 [P] Route: GET /v1/accounts in `backend/src/api/accounts_list.ts`
- [ ] T044 [P] Route: PUT /v1/settings/password in `backend/src/api/settings_password.ts`
- [ ] T045 [P] Route: POST /v1/auth in `backend/src/api/auth.ts`
- [ ] T046 API bootstrap (assemble routes, logging) in `backend/src/api/server.ts`

## Phase 3.5: Frontend Core
- [ ] T047 App shell + routing in `frontend/src/pages/App.tsx`
- [ ] T048 Voucher list page in `frontend/src/pages/VoucherListPage.tsx`
- [ ] T049 Voucher form (create/edit) in `frontend/src/pages/VoucherFormPage.tsx`
- [ ] T050 Account select component in `frontend/src/components/AccountSelect.tsx`
- [ ] T051 Entry rows component in `frontend/src/components/EntryRows.tsx`
- [ ] T052 PDF download action hook in `frontend/src/hooks/useVoucherPdf.ts`
- [ ] T053 Auth/password dialog in `frontend/src/components/PasswordDialog.tsx`
- [ ] T054 API client functions in `frontend/src/services/apiClient.ts`

## Phase 3.6: Integration & Cross-Cutting
- [ ] T055 Logging middleware backend in `backend/src/api/middleware/logging.ts`
- [ ] T056 Error handling middleware backend in `backend/src/api/middleware/error.ts`
- [ ] T057 CORS/security headers setup in `backend/src/api/middleware/security.ts`
- [ ] T058 Shared types export barrel in `shared/schema/index.ts`
- [ ] T059 PDF template HTML/CSS in `backend/src/pdf/templates/voucher.html`

## Phase 3.7: Polish & Additional Tests
- [ ] T060 [P] Unit tests voucher service in `backend/tests/unit/voucher_service_test.ts`
- [ ] T061 [P] Unit tests password service in `backend/tests/unit/password_service_test.ts`
- [ ] T062 [P] Unit tests validation schemas in `backend/tests/unit/validation_schemas_test.ts`
- [ ] T063 [P] Frontend component test AccountSelect in `frontend/tests/unit/account_select.test.tsx`
- [ ] T064 [P] Frontend hook test useVoucherPdf in `frontend/tests/unit/use_voucher_pdf.test.tsx`
- [ ] T065 Performance check PDF generation (timing) in `backend/tests/integration/pdf_perf_test.ts`
- [ ] T066 Accessibility audit script (basic) in `frontend/tests/a11y/a11y_smoke.test.ts`
- [ ] T067 Documentation update README feature section `README.md`
- [ ] T068 Cleanup duplication & dead code (review commit) (no file)
- [ ] T069 Manual test script record `docs/manual-test-v1.md`

## Phase 3.8: Finalization
- [ ] T070 Version bump & changelog entry `CHANGELOG.md`
- [ ] T071 Tag release & archive sample PDF `samples/` (create dir)

## Dependencies Summary
- Contract tests (T007-T015) must exist & fail before endpoints (T037-T045)
- Integration tests (T016-T022) before related services/endpoints (T032-T045)
- Models/repos (T025-T031) before services (T032-T034)
- Services before routes (T037-T045)
- Shared schemas (T035-T036) before service & frontend usage (T047+)

## Parallel Groups Examples
Group A (early contract tests): T007 T008 T009 T010 T011 T012 T013 T014 T015
Group B (integration tests): T016 T017 T018 T019 T020 T021 T022
Group C (repos): T028 T029 T030 T031
Group D (frontend components early): T050 T051 T052 T053 T054

## Validation Checklist
- [x] All contracts have contract test tasks
- [x] All entities have model/repo tasks
- [x] Tests precede implementation tasks
- [x] Parallel tasks use distinct files
- [x] Each task lists concrete file path (where applicable)

