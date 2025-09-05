# Phase 0: Outline & Research

This document outlines the research and decisions made for the technical implementation of the Denpyo application.

## 1. Backend: Deno + Hono

- **Decision**: Use Deno for the runtime and Hono as the web framework.
- **Rationale**:
  - **Deno**: Provides a modern, secure-by-default TypeScript/JavaScript runtime. It simplifies dependency management through URL imports and has a comprehensive standard library. This aligns with the "TypeScript-first" requirement.
  - **Hono**: A small, simple, and ultrafast web framework for the edge. Its lightweight nature is suitable for this application's scale. It has excellent Deno support.
- **Best Practices**:
  - Dependencies will be managed in a `deps.ts` file.
  - The server entry point will be `main.ts`.
  - Deno's built-in testing and linting tools will be utilized.

## 2. Frontend: React

- **Decision**: Use React with Vite for the frontend application.
- **Rationale**:
  - **React**: A robust and popular library for building user interfaces. Its component-based architecture will facilitate the creation of the slip entry form.
  - **Vite**: Provides a fast development server and optimized build process, improving developer experience.
- **Best Practices**:
  - Functional components with Hooks will be used, adhering to the "no classes" constraint.
  - State management will be handled with React's built-in `useState` and `useContext` for simplicity, given the application's scope.
  - TypeScript will be used for all components and logic (`.tsx` files).

## 3. Database: SQLite

- **Decision**: Use SQLite as the database.
- **Rationale**:
  - **SQLite**: A serverless, self-contained, and reliable SQL database engine. It's ideal for a single-user application that requires simple, persistent storage without the overhead of a separate database server.
  - The database file can be easily included in the project repository for simplicity of setup.
- **Best Practices**:
  - The Deno SQLite module will be used for database access.
  - A single file (`denpyo.db`) will be used to store all data.
  - Migrations will be handled with a simple script to create the initial schema.

## 4. Development Methodology: TDD (t-wada style)

- **Decision**: Adhere to Test-Driven Development (TDD) principles as advocated by Takuto Wada.
- **Rationale**: This approach ensures that all code is written to satisfy a specific, testable requirement, which improves code quality and maintainability. It aligns with the project's constitutional requirement for test-first development.
- **Best Practices**:
  - The Red-Green-Refactor cycle will be strictly followed.
  - Tests will be written before implementation code.
  - For the backend, Deno's built-in test runner will be used.
  - For the frontend, Vitest will be used for unit and component testing.
  - Test files will be co-located with the source code (`*.test.ts`).
