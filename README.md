# VEDA

**AI-powered learning platform — upload documents, chat with AI to create courses, learn through voice-narrated interactive lessons.**

Built as a full-stack Dart monorepo: **Serverpod** backend, **Flutter** frontend, **Gemini AI** for course creation & teaching, **pgvector** for RAG retrieval, **ElevenLabs** for text-to-speech.

---

## 📄 Documentation

| Document | Description |
|----------|-------------|
| [PROJECT_STORY.md](PROJECT_STORY.md) | Project narrative — inspiration, what it does, how we built it, challenges, accomplishments, and what's next. |
| [PROPOSAL.md](PROPOSAL.md) | Written proposal — problem statement, target audience, and monetization strategy (freemium tiers, revenue share, Veda Pass subscriptions, enterprise licensing). |
| [TECHNICAL_DOCS.md](TECHNICAL_DOCS.md) | Deep technical architecture — course creation with tool calling, file upload → embedding → pgvector pipeline, RAG retrieval, teaching & Q&A architecture, RevenueCat integration. |

---

## Project Structure

```
veda/
├── veda_server/     Serverpod 3.2.3 backend (PostgreSQL + pgvector + Redis)
├── veda_client/     Auto-generated client SDK (type-safe RPC)
├── veda_flutter/    Flutter app (iOS, Android, macOS, Windows, Linux, Web)
└── veda_desgin/     Static HTML design references
```

---

## Prerequisites

- **Dart SDK** `^3.8.0`
- **Flutter SDK** `^3.32.0`
- **Docker** (for PostgreSQL + Redis)
- **API Keys:**
  - [Google Gemini](https://aistudio.google.com/app/apikey) — AI chat, embeddings, course creation
  - [ElevenLabs](https://elevenlabs.io) — Text-to-speech
  - Gmail App Password — Email OTP verification ([generate here](https://myaccount.google.com/apppasswords))
  - AWS S3 credentials — File storage (optional, can use local storage)

---

## Setup & Run

### 1. Clone the repository

```bash
git clone https://github.com/kanakapalli/veda.git
cd veda
```

### 2. Start database services

```bash
cd veda_server
docker compose up -d
```

This starts:
- **PostgreSQL 16** (with pgvector) on port `8090`
- **Redis 6.2** on port `8091`

### 3. Configure API keys

Edit `veda_server/config/passwords.yaml` and add your keys:

```yaml
shared:
  geminiApiKey: 'YOUR_GEMINI_API_KEY'
  elevenlabsApiKey: 'YOUR_ELEVENLABS_API_KEY'
  AWSAccessKeyId: 'YOUR_AWS_ACCESS_KEY'
  AWSSecretKey: 'YOUR_AWS_SECRET_KEY'
  smtpUsername: 'your-email@gmail.com'
  smtpPassword: 'YOUR_GMAIL_APP_PASSWORD'
  smtpFromEmail: 'your-email@gmail.com'
```

### 4. Configure server host

Edit `veda_server/config/development.yaml` — set `publicHost` to your local IP:

```yaml
apiServer:
  port: 8080
  publicHost: YOUR_LOCAL_IP    # e.g., 192.168.1.100
  publicPort: 8080
  publicScheme: http
```

Find your IP: `ifconfig | grep "inet " | grep -v 127.0.0.1`

### 5. Start the server

```bash
cd veda_server
dart pub get
dart bin/main.dart --apply-migrations
```

The server runs on:
- `8080` — API server
- `8081` — Insights dashboard
- `8082` — Web server

`--apply-migrations` creates the database tables and pgvector indexes on first run.

### 6. Configure Flutter client

Edit `veda_flutter/assets/config.json` to point to your server:

```json
{
    "apiUrl": "http://YOUR_LOCAL_IP:8080"
}
```

### 7. Run the Flutter app

```bash
cd veda_flutter
flutter pub get
flutter run
```

**Platform-specific:**

```bash
# iOS
flutter run -d ios

# Android
flutter run -d android

# macOS
flutter run -d macos

# Web (connects to server at config.json URL)
flutter run -d chrome

# Or build web and serve from Serverpod:
cd veda_flutter
flutter build web --base-href /app/ --wasm --output ../veda_server/web/app
# Then access at http://YOUR_LOCAL_IP:8082/app/
```

---

## Generate Client SDK

After modifying server endpoints or models, regenerate the client SDK:

```bash
cd veda_server
serverpod generate
```

This updates `veda_client/` with new protocol types and endpoint stubs.

---

## Run Tests

```bash
# Start test database services
cd veda_server
docker compose up -d postgres_test redis_test

# Run server tests
dart test
```

---

## Key Commands Reference

| Command | Location | Purpose |
|---------|----------|---------|
| `docker compose up -d` | `veda_server/` | Start PostgreSQL + Redis |
| `dart bin/main.dart --apply-migrations` | `veda_server/` | Start server + apply DB migrations |
| `serverpod generate` | `veda_server/` | Regenerate client SDK after model/endpoint changes |
| `flutter run` | `veda_flutter/` | Run Flutter app on connected device |
| `dart analyze` | any package | Check for compile errors |
| `dart format .` | any package | Format code |

---

## Architecture at a Glance

**Creator flow (Web):** Upload files → files embedded as 3072-dim vectors in pgvector → chat with Gemini (9 tool-calling functions) to build course structure → AI generates TOC from knowledge base → preview with TTS lectures

**Learner flow (Mobile):** Browse/search courses → enroll → select module & teaching mode → server retrieves top-5 relevant knowledge chunks via cosine similarity → Gemini generates lecture → ElevenLabs converts to speech → word-by-word highlighted playback → ask follow-up questions via STT

See [TECHNICAL_DOCS.md](TECHNICAL_DOCS.md) for the full architecture deep-dive.

---

## License

Private repository. All rights reserved.
