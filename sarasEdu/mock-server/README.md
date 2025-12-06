# Prisma / Prism Mock Server

This folder contains a small scaffold to run a mock server for the OpenAPI spec in `docs/openapi.yaml` using Stoplight Prism.

Quick start (no global install required):

PowerShell / Windows (from repository root):
```powershell
cd mock-server
npx @stoplight/prism-cli mock ../docs/openapi.yaml -p 4010
```

Or use the npm script:
```powershell
cd mock-server
npm install
npm run start
```

By default the mock server runs at `http://localhost:4010` and will respond according to `docs/openapi.yaml`.

Notes:
- The `package.json` includes `@stoplight/prism-cli` as a dev dependency so you can `npm install` locally if you prefer.
- Use the Postman collection `docs/postman_collection.json` to exercise the mock endpoints.
