# Research: 振替伝票作成Webアプリケーション技術調査

**Date**: 2025-09-04  
**Phase**: 0 - Technology Research  
**Status**: Complete

## Technology Decisions

### Backend: Deno + Hono
**Decision**: Deno 1.37+ with Hono 3.8+ framework for REST API development  
**Rationale**: 
- Deno provides built-in TypeScript support without compilation step
- Hono is lightweight, fast, and follows modern web standards
- No classes requirement aligns with functional programming approach
- Built-in testing framework reduces dependencies

**Alternatives Considered**:
- Node.js + Express: More ecosystem but requires transpilation
- Bun + Elysia: Fast but newer, less stable
- Fresh: Too opinionated for simple API

### Frontend: React + TypeScript
**Decision**: React 18+ with TypeScript, Vite as build tool  
**Rationale**:
- React hooks-based approach avoids classes naturally
- TypeScript provides type safety without classes
- Vite offers fast development experience
- Large ecosystem for PDF viewing/downloading

**Alternatives Considered**:
- Vue.js: Good but team less familiar
- Svelte: Excellent but smaller ecosystem
- Plain TypeScript: Too much manual DOM work

### Database: SQLite
**Decision**: SQLite 3.43+ with direct Deno integration  
**Rationale**:
- Single-user application doesn't need client-server DB
- File-based storage simplifies deployment
- Full SQL support for complex queries
- ACID compliance for data integrity

**Alternatives Considered**:
- PostgreSQL: Overkill for single user
- JSON files: No transactional support
- Deno KV: Too new, limited query capabilities

### PDF Generation
**Decision**: jsPDF library with custom 振替伝票 template  
**Rationale**:
- Pure JavaScript, works in both browser and Deno
- Good Japanese font support
- Customizable layout for 振替伝票 format
- No server-side dependencies

**Alternatives Considered**:
- Puppeteer: Heavy, requires Chrome
- PDFKit: Node.js focused
- wkhtmltopdf: External binary dependency

### Testing Strategy
**Decision**: Multi-layer testing with Deno test (backend) + Vitest (frontend)  
**Rationale**:
- Deno built-in test runner for backend
- Vitest for React component testing
- Playwright for E2E testing
- Real SQLite DB for integration tests

**Alternatives Considered**:
- Jest: Slower, requires more configuration
- Mocha: More setup needed
- Testing Library only: Missing E2E coverage

## Architecture Patterns

### Functional Programming Approach
**Decision**: Function-based modules instead of classes  
**Rationale**:
- User requirement to avoid classes
- Easier to test pure functions
- Better composability
- Reduced complexity

**Implementation**:
```typescript
// Instead of classes
export interface FurikaeDenpyo {
  id: string;
  date: string;
  entries: ShiwakeEntry[];
}

// Use factory functions
export function createDenpyo(data: Partial<FurikaeDenpyo>): FurikaeDenpyo {
  return {
    id: crypto.randomUUID(),
    date: new Date().toISOString().split('T')[0],
    entries: [],
    ...data
  };
}
```

### API Design Pattern
**Decision**: RESTful API with OpenAPI documentation  
**Rationale**:
- Standard HTTP methods for CRUD operations
- Clear resource-based URLs
- Easy to test and document
- Frontend can cache responses

### Error Handling
**Decision**: Structured error responses with context  
**Rationale**:
- Consistent error format across API
- Detailed context for debugging
- Proper HTTP status codes
- Frontend can display meaningful messages

## Development Workflow

### TDD Approach
**Decision**: Strict Test-First development  
**Process**:
1. Write failing test for requirement
2. Run test to confirm failure (RED)
3. Write minimal implementation (GREEN)
4. Refactor while keeping tests passing (REFACTOR)

### Library Structure
**Decision**: Modular libraries with CLI interfaces  
**Libraries Planned**:
- `furikae-core`: Business logic and validation
- `pdf-generator`: PDF creation functionality  
- `account-master`: 勘定科目 management
- `database-client`: SQLite operations

### File Organization
**Decision**: Feature-based organization within clean architecture  
**Structure**:
```
backend/src/
├── models/     # Data structures and types
├── services/   # Business logic
├── api/        # HTTP handlers
└── lib/        # Shared utilities
```

## Performance Considerations

### Response Time Targets
- API responses: <200ms for CRUD operations
- PDF generation: <2 seconds for typical 振替伝票
- Database queries: <50ms for single record operations

### Memory Usage
- PDF generation: <10MB memory per document
- Database: <100MB for 1000 振替伝票
- Frontend bundle: <2MB gzipped

### Caching Strategy
- Static assets: Browser cache with versioning
- API responses: No caching (data freshness priority)
- PDF generation: Cache templates, not documents

## Security Considerations

### Authentication
**Decision**: Optional password protection with browser session  
**Implementation**:
- Single password for application access
- Session-based authentication (no JWT needed)
- Password stored as bcrypt hash

### Data Protection
- Input validation for all API endpoints
- SQL injection prevention through parameterized queries
- XSS prevention through proper React rendering
- CSRF protection for state-changing operations

## Deployment Strategy

### Development Environment
- Deno for backend development
- Vite dev server for frontend
- File-based SQLite database
- Local PDF generation

### Production Considerations
- Single-server deployment (user requirement)
- File-based storage for PDFs
- Database backup strategy
- Log file management

---

**Research Complete**: All technology choices documented and justified. Ready for Phase 1 design work.
