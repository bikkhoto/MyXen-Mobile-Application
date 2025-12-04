`Context: MyXen Mobile App. All user-sensitive content must be encrypted client-side immediately after creation using KeyManager wrapping keys (AES-256-GCM, nonce=12 bytes). Server stores only ciphertext and minimal metadata. Support messages are end-to-end encrypted between user device and authorized support agent consoles. Minimum mobile OS: Android 8 (API 26), iOS 12.`

# MyXen Mobile — Complete Project Skeleton (checked & expanded)

Nice — Gemini’s phased outline is solid. I reviewed it and expanded it into a **full, production-ready skeleton** for the mobile application (Flutter single-codebase). This includes all app modules, screens, services, native integrations, test harnesses, docs, and operational items you’ll need to hand to engineers or paste into Gemini/Copilot.

I also flagged **missing/optional but recommended pieces** (security, relayer, CI, monitoring, SEO hooks, support, ads, university deep-links). Use this as the canonical project scaffold.

---

## Summary of missing/covered items (quick)

* Gemini covered core phases 0–4 — ✅ good.
* **Added / Expanded**:

  * Full code & folder skeleton (lib, android, ios, assets, tests)
  * Native channels & test hooks
  * AdsManager and Ad assets & verification
  * Support module (encrypted tickets)
  * Backup/Restore + KYC auto-encrypt hooks
  * Relayer & fee-payer placeholders (for future cross-chain)
  * CI/CD, security audit pipeline, release notes, runbook
  * Accessibility, i18n, performance, offline-first, telemetry
  * University deep-link & scholarship hooks (read-only in-app)
  * Docs (README, SECURITY.md, API.md, TESTS.md, NATIVE_INTEGRATION.md)

---

# Project skeleton (copy-paste ready)

```
/myxen-mobile/
├── README.md
├── CHANGELOG.md
├── docs/
│   ├── SECURITY.md
│   ├── NATIVE_INTEGRATION.md
│   ├── API.md
│   ├── TESTS.md
│   ├── RELEASE_NOTES_TEMPLATE.md
│   └── RUNBOOK.md
├── android/
├── ios/
├── assets/
│   ├── images/
│   ├── icons/
│   └── ads/
├── lib/
│   ├── main.dart
│   ├── app_config.dart
│   ├── routes.dart
│   ├── core/
│   │   ├── error/                      # error types & handlers
│   │   ├── analytics/                  # privacy-preserving metrics
│   │   ├── secure_storage_adapter.dart
│   │   └── di.dart                     # dependency injection
│   ├── modules/
│   │   ├── onboarding/
│   │   │   ├── onboarding_bloc.dart
│   │   │   ├── onboarding_screen.dart
│   │   │   └── widgets/
│   │   ├── wallet/
│   │   │   ├── wallet_home.dart
│   │   │   ├── balance_card.dart
│   │   │   ├── transaction_list.dart
│   │   │   └── receive_qr_screen.dart
│   │   ├── key_management/             # Steps 1-14 implemented here
│   │   │   ├── mnemonic_service.dart
│   │   │   ├── key_manager.dart
│   │   │   ├── signer.dart
│   │   │   ├── encryption/
│   │   │   │   ├── aes_gcm_wrapper.dart
│   │   │   │   └── hardware_keystore.dart
│   │   │   └── tests/
│   │   ├── payments/
│   │   │   ├── qr_scan_screen.dart
│   │   │   ├── qr_generate.dart
│   │   │   ├── checkout_flow.dart
│   │   │   └── invoice_verifier.dart
│   │   ├── transaction_engine/
│   │   │   ├── tx_builder.dart
│   │   │   ├── tx_signer.dart
│   │   │   └── tx_broadcast.dart
│   │   ├── token_manager/
│   │   │   ├── spl_account_service.dart
│   │   │   └── token_display.dart
│   │   ├── network/
│   │   │   ├── solana_rpc_client.dart
│   │   │   └── rpc_adapters.dart
│   │   ├── security/
│   │   │   ├── reauth_service.dart
│   │   │   ├── anti_tamper.dart
│   │   │   └── device_policy.dart
│   │   ├── backup/
│   │   │   ├── backup_manager.dart
│   │   │   └── backup_ui.dart
│   │   ├── kyc/
│   │   │   ├── kyc_client.dart
│   │   │   └── kyc_ui.dart
│   │   ├── support/
│   │   │   ├── support_client.dart      # encrypt before send
│   │   │   ├── tickets_screen.dart
│   │   │   └── agent_dashboard_api.md   # backend contract
│   │   ├── university/
│   │   │   ├── uni_hooks.dart           # deep-link UX & read-only status
│   │   │   └── scholarship_status.dart  # read-only UI
│   │   ├── emergency/
│   │   │   ├── sos_trigger.dart
│   │   │   └── open_dialer_helper.dart  # native integration
│   │   ├── ads/
│   │   │   ├── ads_manager.dart
│   │   │   └── ads_verifier.dart
│   │   └── settings/
│   │       ├── settings_screen.dart
│   │       └── preference_store.dart
│   └── ui/
│       ├── theme/
│       │   ├── theme_dark.dart
│       │   └── theme_light.dart
│       ├── widgets/
│       └── accessibility.dart
├── test/
│   ├── unit/
│   └── integration/
├── ci/
│   ├── pipeline.yml
│   ├── security_scan.yml
│   ├── device_farm.yml
│   └── release_pipeline.yml
└── tools/
    ├── scripts/
    └── sample_test_vectors/
```

---
Support System step-pack
# Notes on important folders / files (what they do)

* **lib/modules/key_management/** — your cryptography core (we already completed design Steps 1–14). Must be the most-reviewed area.
* **lib/modules/ads/** — signed internal banners; app verifies signature before show. No third-party ads.
* **lib/modules/support/** — client-side encryption before sending to support backend. Backend never receives plaintext.
* **lib/modules/university/** — light read-only integration; full University platform is separate (MyXen.University).
* **native integration (android/ios)** — implement method channel `com.myxen.crypto/hardware_keystore` and `com.myxen.emergency/dialer` per earlier docs.
* **ci/** — pipelines for unit tests, integration on device farm, security scans, and release gating.
* **docs/** — authoritative docs (SECURITY.md, NATIVE_INTEGRATION.md, TESTS.md).

---

# Missing / Recommended items to add right now (priority list)

1. **Relayer / Meta-tx module (phase for cross-chain/fee-in-MYXN)** — required for accepting other chains while charging $MYXN fees. (Medium → High priority if multi-chain needed.)
2. **Server-side relayer + audited multisig** — design prior to relayer rollout. (High)
3. **Automated security audit pipeline** — static analysis, SCA, dependency pinning. (High)
4. **App store compliance & privacy docs** — GDPR, data retention, terms for KYC. (High)
5. **E2E test harness on physical devices** (Android with StrongBox, iOS Secure Enclave). (High)
6. **Performance & accessibility verification** — Core Web Vitals for web, Lighthouse for web companion. (Medium)
7. **SEO & Content hooks** — meta tags & deep-link sitemaps for University pages. (Low but important for adoption)
8. **Support backend agent dashboard & E2E flow** — ensure encryption/decryption pipeline works. (Medium)

---

# Acceptance checklist to hand to engineering (short)

* [ ] Key Management module unit tests green (Step 7)
* [ ] Native hardware channel implemented + test hooks removed in release
* [ ] Backup/Import export flows validated on devices (hardware & non-hardware)
* [ ] Emergency dialer defaults to opening native dialer (no background calling)
* [ ] AdsManager fetching + signature verification implemented + assets signed
* [ ] Support client encrypts tickets and backend agent can decrypt (test vectors)
* [ ] KYC auto-encryption integration validated (server receives only ciphertext)
* [ ] Relayer design documented (if enabling non-MYXN txs)
* [ ] Security audit scheduled & remediation backlog tracked

---

# Support System — Complete Step-Pack (Gemini / Copilot–ready)

Boss — here’s the **full, production-grade Support System step-pack**, ready to paste into Gemini or Copilot.
Each numbered item is a single task prompt the model or an engineer can execute. They include exact inputs, expected outputs, acceptance criteria, and implementation notes. No code — only precise instructions, so your teams or any generative model can produce the required artifacts reliably.

Context to include with every prompt (copy/paste at top):

---

## 1) High-Level Product Brief (single deliverable)

**Prompt:**
Produce a one-page product brief for the Support System. Include purpose, users (end users, agents, admins), non-scope, data-flow overview, security goals, and top 5 risks with mitigations.

**Inputs:** Context.
**Output:** One-page brief (bullet list).
**Acceptance:** Fits one page; lists risks (plaintext leakage, impersonation, unauthorized disclosure, replay, availability) with mitigations.

---

## 2) API Contract — Mobile ↔ Support Backend (canonical)

**Prompt:**
Define the complete API contract between mobile app and Support Backend. Provide endpoint paths, HTTP methods, request/response shapes (JSON), required headers, auth methods (JWT + device signature), rate limits, and error codes. Include the exact schema for `createTicket`, `fetchTickets`, `updateTicketStatus`, `uploadAttachment`, `downloadAttachment`, `pollMessages`, and `pushNotificationAck`. Specify which fields are ciphertext vs plaintext metadata.

**Inputs:** Context + KeyManager APIs.
**Output:** API.md-style contract with example requests/responses.
**Acceptance:** Every endpoint lists which fields must be client-encrypted (ciphertext) and which may be plaintext; includes auth header format and exact error codes.

---

## 3) Message & Blob Schema (canonical)

**Prompt:**
Produce canonical schemas (JSON) for tickets and messages. For each schema, indicate which fields are encrypted, how AAD should be formed (e.g., `{ "v":"support_v1","ticket_id":..., "user_hash":... }`), how attachments are encrypted/wrapped, and the envelope format for server storage (include `kdf`, `nonce`, `enc`, `created_at`). Provide an example encrypted ticket blob (with dummy base64 placeholders).

**Inputs:** Context + AES-GCM rules from Key Management.
**Output:** JSON schemas and 1 example blob.
**Acceptance:** Nonces 12 bytes; `kdf` defined as `hardware|scrypt`; AAD examples present.

---

## 4) Mobile Client Prompts — Create Ticket Flow

**Prompt:**
Produce a step-by-step mobile client implementation plan for the “Create Ticket” flow. For each step list exact UI actions, input validation, encryption steps (what to call from KeyManager), network call sequence, retry rules (exponential backoff), offline queue behavior, and UX copy (consent/warning). Provide local storage keys used and offline sync behavior.

**Inputs:** Context + API contract.
**Output:** Implementation plan (ordered steps) + UX copy lines.
**Acceptance:** Includes re-auth requirement for attaching KYC docs; shows exact consent modal text; offline queue persists encrypted blobs and retries when online.

---

## 5) Agent Dashboard Spec (server-side, single deliverable)

**Prompt:**
Generate a full agent dashboard specification: routes, UI wireframes (text descriptions), authentication & authorization (MFA, role separation), message decryption workflow, ticket triage UI, search filters, tags, escalation buttons, and audit logging behavior (encrypted local logs). Define agent actions: reply (encrypt reply with user's public wrapping metadata), escalate, attach internal note (encrypted or plaintext as per policy), transfer ticket to another agent, and close ticket.

**Inputs:** Context + API contract + Message Schema.
**Output:** Dashboard spec doc with wireframe descriptions and operations list.
**Acceptance:** Decryption performed only at agent console after agent MFA; server never stores decrypted text; audit log schema included.

---

## 6) Encryption Key Flow (detailed)

**Prompt:**
Write exact, step-by-step rules for how encryption keys are used end-to-end:

* How mobile derives per-ticket encryption (use KeyManager wrapping key + ephemeral symmetric key per ticket).
* How attachments are encrypted (chunked AES-GCM with per-chunk nonce), how salts are stored.
* How agent consoles obtain decryption keys safely (agent public-key / enclave model) — include options:

  * Option A: Agent-side secure enclave where server rewraps ephemeral ticket key to agent public RSA/ED25519 envelope.
  * Option B: End-to-end via server-held envelope but agent must provide MFA and hardware key to unwrap.
    Choose both and explain tradeoffs; recommend one.

**Inputs:** Context.
**Output:** Key flow doc with diagrams (text) and recommended option.
**Acceptance:** Recommends Option A (agent enclave / agent keypair) with clear steps; includes fail-safe: if agent key compromised, tickets remain encrypted (rotate agent keys + rewrap policy).

---

## 7) Attachment Handling & Storage

**Prompt:**
Design the attachment upload/download process: chunking, client-side encryption, resumable upload protocol, virus scanning (server-side on ciphertext metadata only), and download decryption flow on agent side. Provide sample REST sequence for upload (initiate, upload chunks, finalize). Specify size limits, retention policy, and compliance (GDPR) guidance.

**Inputs:** Context.
**Output:** Attachment handling spec + REST sequence examples.
**Acceptance:** Supports resumable uploads, chunk size recommended 5MB, attachments stored encrypted; server stores only metadata and encrypted blobs.

---

## 8) Agent Authentication & Authorization Policy

**Prompt:**
Draft the agent auth policy: onboarding of agents, role definitions (Tier1, Tier2, Tier3, Admin), MFA requirements (Yubikey / TOTP + password), session timeout, device binding, and emergency access (break glass) rules. Include revocation procedures and key rotation policies for agent keys.

**Inputs:** Context.
**Output:** Auth policy doc.
**Acceptance:** MFA mandatory, device binding required for Tier2+, break-glass procedures logged and require 2 approvals.

---

## 9) UI Copy & UX Flow (full)

**Prompt:**
Write all UX microcopy for the support flows: create ticket modal, consent text for sending KYC docs, offline queued notice, ticket status messages, escalation prompts, rating prompt after resolution, and in-app help snippets. Provide translations for English + Bengali (short phrases). Ensure copy is concise, clear, and non-technical.

**Inputs:** Context.
**Output:** Copy list (keyed strings) + Bengali translations.
**Acceptance:** Each copy <140 chars where applicable; Bengali translations provided.

---

## 10) Test Plan & Test Vectors (unit + integration + security)

**Prompt:**
Generate a comprehensive test plan for the Support System: unit tests (encryption roundtrip, schema validation), integration tests (create ticket online/offline, attachment upload/download, agent decrypt & reply), security tests (attempt man-in-the-middle, replay attack, test-hook abuse), and load tests (tickets/sec). Provide deterministic test vectors (sample plaintext → expected ciphertext properties) and CI job definitions.

**Inputs:** Context + sample test vectors from Key Management.
**Output:** Test plan with explicit test cases, steps, expected assertions, and CI job names.
**Acceptance:** Includes tests for: offline queue retry, corrupted chunk handling, unauthorized agent access attempt, and ticket import/export roundtrip.

---

## 11) Monitoring, Telemetry & SLAs

**Prompt:**
Define monitoring metrics and SLA targets for Support System: ticket creation time, first response time, ticket resolution time, failed decrypt attempts, queued tickets count, agent login failures, and attachment upload errors. Provide alert thresholds and required dashboards. Include privacy-preserving telemetry policy (no message content logged).

**Inputs:** Context.
**Output:** Monitoring plan with metric names and alert rules.
**Acceptance:** Alerts for `support.decrypt.failures > 0.1%` and `support.first_response_time > 24h` (critical).

---

## 12) Privacy, Compliance & Retention Policy

**Prompt:**
Write support-specific privacy and retention policy: what is stored, what is ephemeral, encryption-at-rest, user rights for deletion, data export procedures (how to export encrypted ticket safely), and legal hold support. Provide sample retention schedule (e.g., tickets 2 years encrypted, attachments 1 year encrypted) and deletion API semantics.

**Inputs:** Context + legal assumptions (GDPR-ready).
**Output:** Privacy & retention policy doc.
**Acceptance:** Includes user right to delete requests, handles legal hold exceptions, and details secure wipe procedures.

---

## 13) Incident & Escalation Runbook

**Prompt:**
Produce a 1-page runbook for incidents involving Support System (data leak, agent compromise, service outage). Include immediate steps, communication templates, containment actions (rotate agent keys, disable agent accounts), and post-incident audit process.

**Inputs:** Context.
**Output:** Runbook (one page).
**Acceptance:** Actionable steps with contact roles and timelines; templates for user notification.

---

## 14) Deployment & Rollout Plan

**Prompt:**
Create a rollout plan for Support System: internal alpha (team), private beta (select users), public launch. Include feature flags (enable/disable agent consoles), migration steps for existing tickets (if any), and rollback procedures. Include QA acceptance criteria (aligned to Step 10 test plan).

**Inputs:** Context.
**Output:** Rollout plan with phases and exit criteria.
**Acceptance:** Includes rollback steps and QA checklist.

---

## 15) Documentation Artifacts (files to produce)

**Prompt:**
List exact documentation files to create and provide first line for each: `SUPPORT_README.md`, `SUPPORT_API.md`, `SUPPORT_SECURITY.md`, `SUPPORT_TESTS.md`, `SUPPORT_RUNBOOK.md`, `SUPPORT_AGENT_ONBOARDING.md`. Each file should include version and owner header. Provide the exact first line for each file.

**Inputs:** Context.
**Output:** doc list + first-line lines.
**Acceptance:** First lines present; files structured per earlier doc rules.

---

## 16) Sample PR Prompt — Implement Client Create Ticket (copy/paste)

**Prompt (for Gemini/Copilot):**
“Create a Dart/Flutter module `lib/modules/support/support_client.dart` implementing the Create Ticket flow. Use dependency injection to accept KeyManager and HttpClient. The module must: validate inputs, call KeyManager to generate ephemeral ticketKey, encrypt message with AES-GCM using ephemeral key, wrap ephemeral key with wrapping key per KeyManager, produce canonical ticket envelope, and POST to `/api/v1/support/tickets`. Include retry logic (exponential backoff), offline queue to local secure storage, and unit tests (mock KeyManager + HttpClient). Do not include agent-side code — only mobile client. Add a README in `lib/modules/support/README.md` explaining usage. Ensure tests assert ciphertext is non-empty and nonce length is 12.”

**Inputs:** Context + KeyManager API signatures.
**Output:** Single PR prompt (ready to paste).
**Acceptance:** Prompt contains exact file name, methods required, test expectations, and does not request secret returns.

---

## 17) Agent Console PR Prompt — Decrypt & Reply Flow (copy/paste)

**Prompt (for Gemini/Copilot):**
“Create a Node.js/TypeScript microservice `support-agent-console` that subscribes to support ticket events, retrieves encrypted ticket envelope, validates envelope schema, uses pre-provisioned agent private key (stored in HSM/secure enclave) to unwrap ephemeral ticket key, decrypts AES-GCM payload, renders message in dashboard, accepts agent reply, encrypts reply with same ticket ephemeral key, and POSTs reply to `/api/v1/support/tickets/{id}/messages`. Include tests for unwrap/decrypt roundtrip using sample vectors. Provide README and Dockerfile.”

**Inputs:** Context + KeyManager recommendations (agent keyflow).
**Output:** Single PR prompt.
**Acceptance:** Prompt includes HSM requirement, file names, tests, containerization note.

---

## 18) Acceptance & Audit Checklist (final)

**Prompt:**
Produce a final checklist for sign-off before going live: unit tests pass, integration tests pass, pen-test findings addressed, agent onboarding completed, MFA enforced, audit package prepared. Provide exact commands for QA to run verification scripts and list required artifacts for security audit.

**Inputs:** Context.
**Output:** Checklist (one page) + QA commands.
**Acceptance:** Must map to all earlier steps and provide exact commands (e.g., `./ci/run-support-tests.sh`) and artifact list.

---

Perfect — I’ll deliver everything now. Below you’ll find three complete, production-ready artifacts you can paste straight into Gemini/Copilot or hand to engineers:

1. **Full “Create Ticket” PR prompt** (Dart/Flutter) — generates the mobile client module and unit tests.
2. **Full “Agent Console” PR prompt** (Node/TypeScript) — generates the agent microservice for unwrap/decrypt/reply and containerization.
3. **SUPPORT_API.md** — the complete API contract (endpoints, request/response schemas, auth, error codes, which fields must be encrypted, examples, rate limits, and acceptance checks).

Each prompt is explicit about inputs, files to create, exact behaviours, tests, and acceptance criteria. Use them as-is.

---

## 1) PR Prompt — Mobile: `Create Ticket` (Dart / Flutter)

**Copy / Paste this prompt into Gemini / Copilot / your dev task board.**

```
Task: Implement `lib/modules/support/support_client.dart` — Create Ticket flow (Dart/Flutter)

Context:
- Project: MyXen Mobile App (Flutter).
- KeyManager API available in app (methods from Step 5). Use KeyManager to obtain wrapping key and encryption primitives.
- All sensitive user data must be encrypted client-side immediately (AES-256-GCM, nonce=12 bytes).
- Minimum OS: Android 8 (API 26), iOS 12.
- Do NOT return or log any sensitive plaintext anywhere in release.
- Use dependency injection for HttpClient and KeyManager so tests can mock.

Files to produce (exact paths):
1. lib/modules/support/support_client.dart
2. lib/modules/support/support_client_impl.dart
3. lib/modules/support/support_models.dart
4. lib/modules/support/support_storage.dart (local secure queue)
5. lib/modules/support/README.md
6. test/unit/support_client_test.dart
7. test/unit/support_storage_test.dart

Behavioral requirements (exact sequence):
1. `SupportClient.createTicket({ String subject, String message, List<File>? attachments, Map<String,String>? metadata })`:
   a. Validate inputs: subject non-empty, message non-empty (trim), attachments size <= configured max (default 25MB).
   b. Acquire KeyManager exclusive lock (call KeyManager adapter).
   c. Generate an ephemeral ticket symmetric key: call `crypto_utils.generateRandomBytes(32)` (secure RNG).
   d. Encrypt plaintext message with ephemeral key using AES-GCM (nonce=12 bytes random); create AAD: JSON bytes `{ "v":"support_v1", "ticket_id":<uuid>, "user_hash":sha256(user_id) }`.
   e. For attachments: chunk (5MB chunks), encrypt each chunk with ephemeral key using unique nonce per chunk.
   f. Wrap ephemeral ticket key with KeyManager wrapping key:
      - Call KeyManager to get wrappingKey (prefer hardware); then `aes_gcm_wrapper.encrypt(ephemeralKey, wrappingKey, aad)` to produce `wrapped_key` with nonce.
   g. Compose canonical ticket envelope JSON:
      {
        "ticket_id": "<uuidv4>",
        "user_hash": "<sha256(user_id)>",
        "v": "support_v1",
        "kdf": "<hardware|scrypt>",
        "kdf_params": { ... } OR null,
        "wrapped_key": "<base64>",
        "wrapped_key_nonce": "<base64>",
        "message": "<base64-ciphertext>",
        "message_nonce": "<base64>",
        "attachments": [ { "chunk_count":n, "chunks":[ { "index":0, "cipher":"base64", "nonce":"base64" } ] } ],
        "metadata": { ... },
        "created_at": "ISO8601"
      }
   h. Persist envelope to local secure queue (`support_storage.enqueueTicket(envelope)`) and attempt POST to `/api/v1/support/tickets`:
      - On success: mark local ticket status synced; remove queue item.
      - On failure: schedule retries with exponential backoff (1s, 2s, 4s, 8s, max 5 retries). If offline, queue for later sync; show user “Draft saved and will send when online”.
   i. Clean up: zeroize ephemeralKey and any plaintext buffers in memory.

2. Offline & retry behavior:
   - Support offline drafting; drafts are encrypted and stored in secure storage (never plaintext).
   - On network restore, attempt queued sends in FIFO order.

3. Attachments:
   - Implement `uploadAttachment(ticket_id, chunkIndex, chunkCipher, chunkNonce)` POST flow with chunk resume:
      - `POST /api/v1/support/tickets/{ticket_id}/attachments/init` → returns upload_id.
      - `PUT /api/v1/support/tickets/{ticket_id}/attachments/{upload_id}/chunk/{index}` for each chunk.
      - `POST /api/v1/support/tickets/{ticket_id}/attachments/{upload_id}/finalize`.
   - Canary: enforce chunk size 5MB.

4. UI integration:
   - No UI files required for this PR, but provide README with example usage and suggested widget hooks.

5. Tests:
   - Unit test `support_client_test.dart` must mock KeyManager and HttpClient and assert:
     - Envelope structure created.
     - `message_nonce` length == 12.
     - `wrapped_key` present and non-empty.
     - On simulated network failure, `support_storage.enqueueTicket` called and queue persists.
   - Unit test `support_storage_test.dart` must assert that queued envelopes persist to secure storage and are retrievable, and that `dequeue` removes them.

6. Security & logging:
   - No plaintext or secret values printed in logs.
   - Debug-only helpers allowed but gated by `kDebugMode` and compile-time flags.
   - Ensure release build removes test hooks.

7. Acceptance criteria:
   - All unit tests pass locally.
   - `message_nonce` is 12 bytes.
   - Ephemeral key is zeroized after use (testable via mock hook that confirms `zeroize` called).
   - Envelope matches canonical schema and is posted to `/api/v1/support/tickets` (mocked in tests).

Deliver README content (lib/modules/support/README.md) containing:
- Usage examples
- API of SupportClient
- How to run tests: `flutter test test/unit/support_client_test.dart`

End of task.
```

---

## 2) PR Prompt — Agent Console (Node.js / TypeScript + Docker)

**Copy / Paste this prompt into Gemini / Copilot / your dev task board.**

```
Task: Implement `support-agent-console` microservice (Node.js + TypeScript) — decrypt & reply flow

Context:
- Service processes encrypted support tickets created by mobile clients.
- Agent private keys reside in HSM or secure enclave; for dev/testing allow an adapter that reads keys from secure file (dev only).
- All message payloads in tickets are AES-GCM ciphertext and must be unwrapped using wrapped_key field and agent key unwrapping flow (see KeyManager docs).
- Minimum Node version: 18 LTS. Containerized via Docker.

Deliverables (exact files):
1. support-agent-console/
   ├─ src/
   │  ├─ index.ts
   │  ├─ config.ts
   │  ├─ server.ts (express)
   │  ├─ controllers/
   │  │   └─ ticketController.ts
   │  ├─ services/
   │  │   ├─ ticketService.ts
   │  │   ├─ cryptoAdapter.ts   # unwrap wrapped_key -> ephemeral key (HSM/adapter)
   │  │   └─ agentAuth.ts       # MFA check for agent action
   │  ├─ models/
   │  │   └─ ticketModel.ts
   │  └─ tests/
   │      └─ ticketService.test.ts
   ├─ Dockerfile
   ├─ package.json
   ├─ tsconfig.json
   └─ README.md

Behavioral requirements:
1. Endpoints:
   - `GET /agent/tickets` — list ticket envelopes (metadata) (requires agent JWT).
   - `GET /agent/tickets/:ticket_id` — fetch full envelope (metadata + wrapped_key + ciphertext)
   - `POST /agent/tickets/:ticket_id/decrypt` — perform unwrap+decrypt and return plaintext to agent (requires agent MFA/session validation).
   - `POST /agent/tickets/:ticket_id/reply` — accepts agent reply plaintext, encrypts reply with ticket ephemeral key, POSTs reply to `/api/v1/support/tickets/{id}/messages` (server-to-server request).
2. Decrypt flow for `POST /agent/tickets/:id/decrypt`:
   a. Validate agent JWT and ensure agent has MFA/approved session. If not, return 401.
   b. Retrieve envelope (from DB or ticket store). Extract `wrapped_key` and its `nonce`.
   c. Call `cryptoAdapter.unwrapWrappedKey(wrappedKey, nonce, ticketMetadata)` — cryptoAdapter must:
      - Use HSM or secure key store to unwrap symmetric ephemeral key.
      - In dev mode, support a seeded mock adapter that returns a deterministic ephemeral key.
   d. With ephemeral key, decrypt `message` using AES-GCM and AAD as `{ "v":"support_v1", "ticket_id":..., "user_hash":... }`.
   e. Return plaintext message in response body to agent controller.
   f. Log audit event (agent_id, ticket_id, timestamp) — store audit logs encrypted or in secure logging system.
3. Reply flow:
   a. Agent writes reply plaintext in dashboard.
   b. Server encrypts reply using ephemeral ticket key (same ephemeral key), producing ciphertext + nonce.
   c. Server calls `POST /api/v1/support/tickets/{id}/messages` (backend API) with body containing ciphertext, nonce and metadata. Ensure request uses server-to-server credentials.
4. Tests:
   - Unit test `ticketService.test.ts` must:
     - Use mock cryptoAdapter that returns deterministic ephemeralKey.
     - Assert decrypt works and matches expected plaintext from sample vector.
     - Assert reply encryption produces ciphertext with nonce length==12 and that API POST is invoked with correct envelope.
5. Security:
   - Agent decrypt endpoint requires agent JWT + fresh MFA flag for that session.
   - Agent private key material never leaves HSM/secure enclave in production. CryptoAdapter must implement HSM integration or wrap HSM SDK calls; the test adapter is allowed for CI.
6. Containerization:
   - Provide Dockerfile with multi-stage build and instructions to run locally and in k8s.
7. README:
   - How to run locally: `npm install`, `npm run build`, `npm run start`.
   - Env vars required: `AGENT_JWT_SECRET`, `HSM_CONFIG` (or path to dev key), `SUPPORT_BACKEND_URL`.
8. Acceptance Criteria:
   - Unit tests pass (`npm test`).
   - The decrypt endpoint decrypts test envelope using mock adapter and returns expected plaintext.
   - Docker image builds successfully and runs with default env vars (dev mode).

End of task.
```

---

## 3) `SUPPORT_API.md` — Full API Contract (mobile ↔ support-backend)

Below is the full API contract. Copy into your docs repo as `docs/SUPPORT_API.md`. This is precise and production-ready.

---

# SUPPORT_API.md

Version: 1.0.0
Last-updated: YYYY-MM-DD
Owner: Product (Support)
SecurityOwner: Security Engineering

---

## Overview

This document specifies the HTTP API between MyXen Mobile clients and the Support Backend for ticket creation, attachments, polling, and message acknowledgements. **All sensitive message content and attachments must be encrypted client-side**. The server stores only ciphertext and minimal metadata required for routing and search.

---

## Auth & Headers

* **Authentication (mobile → backend):**

  * `Authorization: Bearer <JWT>` (short-lived user JWT)
  * `X-Device-Signature: <base64>` — optional header where device signs the ticket_id using device key for non-repudiation (recommended)

* **Service-to-Service (agent console / backend):**

  * Mutual TLS or JWT signed with server key; use `x-api-key` or mTLS for agent console calls.

* **Common headers:**

  * `Content-Type: application/json`
  * `Accept: application/json`
  * `X-Request-ID: <uuid>` — idempotency & tracing

---

## Rate Limits (per-user / per-IP)

* `POST /api/v1/support/tickets` — 10 requests/minute per user (soft), 100/day.
* `POST /api/v1/support/tickets/{id}/attachments/*` — 100 chunks/hour per ticket.
* Backends should return `429` with `Retry-After` header.

---

## Error codes (standard)

* `400` — Bad Request (schema invalid)
* `401` — Unauthorized
* `403` — Forbidden (agent not permitted)
* `404` — Not Found
* `409` — Conflict (duplicate ticket_id)
* `429` — Rate Limited
* `500` — Internal Server Error
* `503` — Service Unavailable

All error responses must be:

```json
{
  "error_code": "SUPPORT_<TAG>",
  "message": "Human friendly summary",
  "details": { ... }  // optional, non-sensitive
}
```

---

## Canonical Ticket Envelope (what mobile posts)

**POST** `/api/v1/support/tickets`

Request body (JSON):

* `ticket_id` (string, uuid) — client generated
* `v` (string) — `"support_v1"`
* `user_hash` (string) — `sha256(user_id)` (for privacy)
* `kdf` (string) — `"hardware"` | `"scrypt"`
* `kdf_params` (object|null) — when `kdf == "scrypt"` include `{ "salt": base64, "N":16384, "r":8, "p":1 }`
* `wrapped_key` (string) — base64 of AES-GCM ciphertext of ephemeralKey wrapped with wrappingKey
* `wrapped_key_nonce` (string) — base64 nonce (12 bytes)
* `message` (string) — base64 AES-GCM ciphertext of message
* `message_nonce` (string) — base64 12-byte nonce
* `aad` (string) — base64 of AAD JSON used (optional, encouraged)
* `attachments` (array) — see attachment schema below
* `metadata` (object) — non-sensitive search fields (category, subject trimmed)
* `created_at` (ISO8601)

**Which fields are encrypted (MUST):**

* `message` (ciphertext) — message plaintext must never be sent
* `wrapped_key` — contains ephemeral key ciphertext
* `attachments[*].chunks[*].cipher` — all attachment chunks are ciphertext

**Which fields may be plaintext (allowed):**

* `ticket_id`, `v`, `user_hash` (pseudonymous), `metadata.category`, `metadata.subject` (short), `created_at`

Example request:

```json
{
  "ticket_id": "3f1bb0e8-1111-4a5a-a111-9e5c8f0d2f3e",
  "v": "support_v1",
  "user_hash": "1a2b3c4d5e6f...",
  "kdf": "hardware",
  "kdf_params": null,
  "wrapped_key": "BASE64_WRAPPED_KEY",
  "wrapped_key_nonce": "BASE64_NONCE_12B",
  "message": "BASE64_CIPHERTEXT",
  "message_nonce": "BASE64_NONCE_12B",
  "aad": "BASE64({\"v\":\"support_v1\",\"ticket_id\":\"...\",\"user_hash\":\"...\"})",
  "attachments": [],
  "metadata": {
    "category": "KYC",
    "subject": "Document upload for verification"
  },
  "created_at": "2025-12-04T12:34:56Z"
}
```

**Response (201 Created):**

```json
{
  "ticket_id": "3f1bb0e8-1111-4a5a-a111-9e5c8f0d2f3e",
  "status": "open",
  "server_received_at": "2025-12-04T12:34:58Z"
}
```

---

## Fetch tickets (mobile)

**GET** `/api/v1/support/tickets?status=open,closed&page=1&page_size=20`

Response (200):

```json
{
  "tickets": [
    {
      "ticket_id": "...",
      "v": "support_v1",
      "user_hash": "...",
      "metadata": { "category":"KYC", "subject":"..." },
      "status": "open",
      "updated_at": "..."
    }
  ],
  "page": 1,
  "page_size": 20,
  "total": 5
}
```

Note: Server returns only metadata and routing info; mobile must request `GET /api/v1/support/tickets/{id}` to get full envelope.

---

## Get full envelope (mobile)

**GET** `/api/v1/support/tickets/{ticket_id}`

Response:

* Returns the full envelope exactly as posted (including wrapped_key, message, nonces and attachments metadata). Mobile uses KeyManager to unwrap/validate if needed (normally mobile doesn't need to decrypt its own messages; used for sync).

---

## Attachments (resumable chunked uploads)

**POST** `/api/v1/support/tickets/{ticket_id}/attachments/init`
Request:

```json
{ "filename":"id_doc.pdf", "size": 12345678, "chunk_size": 5242880, "total_chunks": 3 }
```

Response:

```json
{ "upload_id":"<uuid>", "chunk_size":5242880 }
```

**PUT** `/api/v1/support/tickets/{ticket_id}/attachments/{upload_id}/chunks/{index}`

* Body: raw bytes of encrypted chunk (content-type: application/octet-stream)
* Headers: `Content-Range: bytes start-end/total` plus `X-Chunk-Nonce: <base64-12bnonce>`

**POST** `/api/v1/support/tickets/{ticket_id}/attachments/{upload_id}/finalize`
Request:

```json
{ "chunks": [ { "index":0, "nonce":"base64", "sha256":"hex" }, ... ], "metadata": { "original_filename":"id_doc.pdf" } }
```

Response (200):

```json
{ "attachment_id":"<uuid>", "status":"stored" }
```

**Notes:**

* Server must not attempt to inspect attachment plaintext.
* Server may run virus scan on ciphertext metadata only (Yara rules on filenames/metadata) — but actual virus scanning requires decrypting; for compliance, consider secure scan in isolated HSM enclave or require user to confirm scan scope.

---

## Agent & Message flows

**Agent decrypt endpoint (agent console → backend)**

**POST** `/agent/tickets/{ticket_id}/decrypt`

* Req: Agent JWT + proof of MFA in session
* Server verifies agent entitlement, fetches envelope, performs server-side unwrap to HSM (if server holds agent rewrap capability), or returns wrapped_key to agent console over mTLS (preferred is unwrap in HSM and return ephemeral key to agent console's enclave).
* Response (200): plaintext message (only returned to authenticated agent console over mTLS).

**Agent reply (agent console → support backend → mobile)**

**POST** `/api/v1/support/tickets/{ticket_id}/messages`
Request:

```json
{
  "from": "agent:agent_id",
  "message": "BASE64_CIPHERTEXT",
  "message_nonce": "BASE64",
  "aad": "...",
  "created_at":"ISO8601"
}
```

**Backend** will:

* Persist ciphertext message and notify mobile via push (push payload includes only metadata and notification id, not ciphertext).
* Mobile will `GET /api/v1/support/tickets/{id}/messages` to fetch message ciphertext and use KeyManager to decrypt (if mobile is the recipient).

---

## Validation & Security Rules (must be enforced server-side)

1. Validate `v` equals supported version; reject unknown versions.
2. Validate base64 formats and nonce lengths (nonce must decode to 12 bytes).
3. Ensure `kdf_params` match policy if `kdf == "scrypt"` (N=16384,r=8,p=1).
4. Do not attempt to decrypt client ciphertext on server unless using secure enclave and with explicit policy.
5. Audit logging: record only metadata and hashed digests (sha256 of ciphertext) — never store plaintext in logs.
6. Attachment retention: default 1 year encrypted by default; ticket retention 2 years (configurable per policy).
7. Support higher privacy: allow user to request deletion (GDPR) — server must delete ciphertext/metadata unless legal hold present.

---

## Examples

**Create Ticket (curl) — simplified (mobile would do client-side encryption prior):**

```bash
curl -X POST https://api.myxen.org/api/v1/support/tickets \
  -H "Authorization: Bearer <JWT>" \
  -H "Content-Type: application/json" \
  -d '@ticket_envelope.json'
```

**Fetch tickets:**

```bash
curl -H "Authorization: Bearer <JWT>" "https://api.myxen.org/api/v1/support/tickets?status=open"
```

---

## Acceptance Criteria (for engineers & QA)

* All endpoints validate `v` and nonces; tests assert decode(noncs).length == 12.
* Server stores only ciphertext for `message` and attachments; no plaintext retention.
* Mobile client can create envelope that passes server validation test vector (CI will include sample envelope).
* Rate limiting enforced and returns `429` with `Retry-After`.
* Attachments chunked upload works; server responds with `upload_id` and finalizes correctly.
* Audit logs do not contain plaintext, only ticket_id, agent_id, and hashed digests.

---

## CI Test Vectors (to include in repo)

* Deterministic BIP39 mnemonic vector, scrypt derived wrapping key vector, and AES-GCM example where only lengths are asserted (CI must not store real secrets).
* Sample envelope JSON with `BASE64_*` placeholders used to validate schema parsing.

---

## Appendix: Best-practice flow recommendations

* Use mTLS and mutual-auth for agent console server-to-server comms.
* Prefer HSM for agent key unwrapping; do not return agent private key bytes to any service.
* Provide agent auditing: every decrypt action requires `agent_id`, `MFA_time`, and is logged with incident id.

---

### End of SUPPORT_API.md

---
