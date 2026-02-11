# VEDA — Technical Documentation

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        FLUTTER CLIENT                              │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────────────────┐ │
│  │ Mobile App   │  │  Web App     │  │ veda_client (generated)   │ │
│  │ (Learner)    │  │ (Creator)    │  │ Type-safe RPC SDK         │ │
│  └──────┬───────┘  └──────┬───────┘  └───────────┬───────────────┘ │
└─────────┼─────────────────┼──────────────────────┼─────────────────┘
          │                 │                      │
          └─────────────────┼──────────────────────┘
                            │ RPC (HTTP)
┌───────────────────────────┼─────────────────────────────────────────┐
│                    SERVERPOD BACKEND                                │
│  ┌────────────────────────┼──────────────────────────────────────┐  │
│  │              ENDPOINT LAYER                                   │  │
│  │  ┌─────────────────┐ ┌──────────────┐ ┌───────────────────┐  │  │
│  │  │ GeminiEndpoint  │ │ LmsEndpoint  │ │ UserProfile       │  │  │
│  │  │ • courseChat     │ │ • addFile    │ │ Endpoint          │  │  │
│  │  │ • teachingChat  │ │ • genTOC     │ └───────────────────┘  │  │
│  │  │ • answerQ&A     │ │ • RAG search │                        │  │
│  │  │ • generateTTS   │ │ • enroll     │                        │  │
│  │  └────────┬────────┘ └──────┬───────┘                        │  │
│  └───────────┼─────────────────┼────────────────────────────────┘  │
│              │                 │                                    │
│  ┌───────────┼─────────────────┼────────────────────────────────┐  │
│  │           SERVICE LAYER     │                                 │  │
│  │  ┌────────┴────────┐       │                                 │  │
│  │  │ GeminiService   │       │                                 │  │
│  │  │ • chat()        │       │                                 │  │
│  │  │ • courseChat()   │       │                                 │  │
│  │  │ • embedding()   │       │                                 │  │
│  │  └────────┬────────┘       │                                 │  │
│  └───────────┼─────────────────┼────────────────────────────────┘  │
│              │                 │                                    │
│  ┌───────────┼─────────────────┼────────────────────────────────┐  │
│  │      EXTERNAL SERVICES      │          DATA LAYER             │  │
│  │  ┌────────┴──────┐  ┌──────┴────────┐  ┌─────────────────┐  │  │
│  │  │ Gemini API    │  │ PostgreSQL 16 │  │ AWS S3          │  │  │
│  │  │ • Flash 2.0   │  │ + pgvector    │  │ File storage    │  │  │
│  │  │ • Embeddings  │  │ HNSW index    │  │                 │  │  │
│  │  └───────────────┘  └───────────────┘  └─────────────────┘  │  │
│  │  ┌───────────────┐  ┌───────────────┐                        │  │
│  │  │ ElevenLabs    │  │ Redis 6.2     │                        │  │
│  │  │ TTS streaming │  │ Session cache │                        │  │
│  │  └───────────────┘  └───────────────┘                        │  │
│  └──────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────────┘
```

The entire stack is **Dart** — server, client SDK, and frontend. The client SDK is auto-generated from server endpoint and model definitions via `serverpod generate`, meaning a model change in the server propagates to every Flutter widget at compile time. Zero runtime serialization errors.

---

## Course Creation Architecture

Course creation is a **conversational AI workflow** — no forms, no drag-and-drop builders. The creator chats with Gemini, and the AI decides when to execute database mutations via function calling (tool use).

### Flow: Creator Chat → Tool Calling → Database Mutation

```
Creator types message
        │
        ▼
GeminiEndpoint.courseChat()
        │
        ├── 1. Load Course from DB (current state)
        ├── 2. Load ALL KnowledgeFiles for course (text ≤ 3000 chars each)
        ├── 3. Build system instruction:
        │       • Current course state (title, desc, visibility, videoUrl, systemPrompt)
        │       • Inline knowledge file contents (concatenated)
        │       • Tool usage guidelines
        │
        ▼
GeminiService.courseChat(message, history, systemInstruction)
        │
        ├── Attaches 9 tool declarations (_courseTools)
        ├── Sends to Gemini 2.0 Flash API
        │
        ▼
   Model Response
        │
        ├── [TEXT ONLY] → Return text to client
        │
        └── [FUNCTION CALL] → Extract functionName + args
                │
                ▼
        _executeCourseFunction(session, course, functionName, args)
                │
                ├── Executes real DB write (insert/update)
                ├── Returns execution result
                │
                ▼
        GeminiService.sendFunctionResultForCourse()
                │
                ├── Appends function call + result to conversation
                ├── Sends back to Gemini for natural language follow-up
                │
                ▼
        Return: { text, toolsExecuted, updatedCourse }
```

### Tool Declarations (9 Functions)

The AI has access to these tools and autonomously decides when to call them based on conversation context:

| Tool | Parameters | Behavior |
|------|-----------|----------|
| `updateCourseTitle` | `title: string` | Updates course title. **Only called when user explicitly requests.** |
| `updateCourseDescription` | `description: string` | Updates description. **Only on explicit request.** |
| `updateCourseVisibility` | `visibility: enum[draft, public, private]` | Changes course visibility state. |
| `updateCourseVideoUrl` | `videoUrl: string` | Sets the course intro video URL. |
| `updateCourseSystemPrompt` | `systemPrompt: string` | Stores teaching personality/context. **Called proactively** — the AI updates this as it learns about the course through conversation. |
| `generateCourseImage` | `imagePrompt: string` | Generates course cover image from AI prompt. |
| `generateBannerImage` | `imagePrompt: string` | Generates course banner image. |
| `createModule` | `title, description?, sortOrder: int` | Creates a new module in the database. |
| `generateTableOfContents` | `customPrompt?: string` | Triggers full TOC generation from uploaded knowledge files (see below). |

The key design decision: `updateCourseSystemPrompt` is **proactive** while most other tools are **reactive**. The AI continuously refines the teaching prompt as the conversation reveals more about the course's purpose and audience, without the creator needing to ask.

---

## File Upload → Embedding → pgvector Pipeline

When a creator uploads a knowledge file, it goes through a synchronous embedding pipeline before the upload response is returned.

### Flow: File Upload → Vector Storage

```
Creator selects file (PDF, DOCX, TXT)
        │
        ▼
Client calls getUploadDescription(path)
        │ → Returns signed S3 upload URL
        ▼
Client uploads directly to S3 (veda-storage bucket)
        │
        ▼
Client calls verifyUpload(path) → confirms S3 upload
        │
        ▼
Client calls addFileToCourse(KnowledgeFile)
        │
        ▼
LmsEndpoint.addFileToCourse()
        │
        ├── Insert KnowledgeFile row in DB
        │
        ▼
_processFileEmbedding(session, file)
        │
        ├── 1. _readFileContent() → HTTP GET from S3 public URL
        │       • TXT: utf8.decode(bytes)
        │       • PDF/DOCX: placeholder (extraction planned)
        │
        ├── 2. Truncate text to 10,000 characters
        │
        ├── 3. GeminiService.generateEmbedding(text)
        │       • Model: gemini-embedding-001
        │       • Output: List<double> (3072 dimensions)
        │
        ├── 4. Store in DB:
        │       • file.embedding = Vector(embedding)   ← pgvector column
        │       • file.textContent = extractedText
        │
        └── DB Update (file row now has embedding + text)
```

### pgvector Configuration

```sql
-- Column type
embedding Vector(3072)

-- HNSW index for fast cosine similarity search
CREATE INDEX knowledge_files_embedding_idx
ON knowledge_files
USING hnsw (embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);
```

- **3072 dimensions** — Gemini embedding-001 output size
- **HNSW index** — Hierarchical Navigable Small World graph for approximate nearest neighbor search
- **m=16** — max connections per graph layer (higher = more accurate, more memory)
- **ef_construction=64** — search width during index build (higher = better recall, slower build)
- **Cosine distance** — measures angular similarity between vectors

---

## Table of Contents Generation

When the AI calls `generateTableOfContents`, or when triggered directly, the system generates a complete course structure from uploaded knowledge files.

### Flow: Knowledge Files → RAG → Structured JSON → Database

```
generateTableOfContents(courseId, customPrompt?)
        │
        ▼
Load course + all knowledgeFiles
        │
        ▼
Build RAG query: course.title + description + systemPrompt + customPrompt
        │
        ▼
findRelevantKnowledge(query, courseId, limit: 10)
        │
        ├── generateEmbedding(query) → 3072-dim vector
        ├── KnowledgeFile.db.find(
        │       where: courseId,
        │       orderBy: embedding.distanceCosine(queryVector),
        │       limit: 10
        │   )
        ├── Returns top-10 most relevant knowledge chunks
        │
        ▼  [Fallback if no embeddings exist]
        │  → Read all files directly via HTTP, truncate to 10K each
        │
        ▼
Build prompt requesting JSON output:
        │  • Format: [{ title, description, topics: [{ title, desc }] }]
        │  • Guidelines: 4–8 modules, 3–6 topics each, logical progression
        │
        ▼
GeminiService.chat(
    message: prompt,
    enableTools: false,           ← No tool calling in this path
    maxOutputTokens: 8192,        ← Large output for full TOC
    responseMimeType: 'application/json'  ← Forces structured JSON
)
        │
        ▼
Robust JSON parsing:
        │  • Strip BOM, markdown fences, trailing commas, control chars
        │  • Fallback: extract [...] boundaries manually
        │
        ▼
DELETE all existing modules for course (full replacement)
        │
        ▼
For each module in parsed JSON:
    ├── Create Module row (title, description, sortOrder, courseId)
    └── For each topic in module:
        ├── Create Topic row (title, description)
        └── Create ModuleItem row (moduleId, topicId, sortOrder)  ← join table
        │
        ▼
Return: List<Module> (fully hydrated with items + topics)
```

---

## Teaching Architecture

Teaching is the learner-facing AI experience — the system generates voice-narrated lectures from course knowledge, module by module.

### Flow: Module Selection → RAG → AI Lecture → TTS → Word-by-Word Playback

```
Learner selects a module in EnrolledCourseScreen
        │
        ├── Selects teaching mode: Quick | Explanative | Lecture
        │       Quick:       150–300 words
        │       Explanative: 300–600 words  
        │       Lecture:     600–1200 words
        │
        ▼
ModuleTeachScreen builds firstMessage:
    "Teach me about: {module.title}"
    + topic titles + topic descriptions (concatenated)
        │
        ▼
GeminiEndpoint.startTeachingChat(courseId, systemPrompt, firstMessage, minWords, maxWords)
        │
        ├── 1. Load Course from DB
        │
        ├── 2. RAG Retrieval (top 5):
        │       generateEmbedding(firstMessage) → 3072-dim vector
        │       KnowledgeFile.db.find(
        │           where: courseId,
        │           orderBy: embedding.distanceCosine(queryVector),
        │           limit: 5
        │       )
        │       → Build knowledgeContext: fileName + textContent per chunk
        │
        ├── 3. Construct system prompt:
        │       {course.systemPrompt}           ← Creator's teaching personality
        │       {knowledgeContext}               ← RAG-retrieved content
        │       CRITICAL: Response MUST be {minWords}–{maxWords} words
        │
        ▼
GeminiService.chat(firstMessage, systemInstruction: fullPrompt)
        │
        ▼
Returns: Raw lecture text (with audio expressiveness tags)
        │
        ▼
Client: GeminiEndpoint.generateSpeech(text)
        │
        ├── ElevenLabs API (eleven_v3, voice: "Rachel")
        ├── Streaming TTS → MP3 bytes
        ├── Settings: stability 0.5, similarity 0.8, style 0.5
        │
        ▼
Client: Audio playback with synchronized word highlighting
        │
        ├── Split text into words
        ├── Map audio position → word index
        ├── Highlight current word + adjacent words
        ├── Support pause/resume
        │
        ▼
Module marked as in_progress → completed on finish
```

### Q&A After Lecture

After the lecture finishes, the learner can ask follow-up questions using speech-to-text.

```
Learner speaks question (speech_to_text)
        │
        ▼
GeminiEndpoint.answerTeachingQuestion(courseId, moduleTitle, question, history)
        │
        ├── 1. Load Course
        │
        ├── 2. RAG Retrieval (top 3):    ← Fewer chunks than teaching
        │       generateEmbedding(question)
        │       pgvector cosine search, limit: 3
        │
        ├── 3. Build system prompt:
        │       • Role: teacher for "{course.title}", module "{moduleTitle}"
        │       • Course context: description + systemPrompt
        │       • RAG knowledge context
        │       • Audio expressiveness tags for TTS:
        │         [excited], [thoughtful], [pauses],
        │         [encouragingly], [chuckles]
        │       • Word count: 100–300 words
        │
        ├── 4. Pass full conversation history (multi-turn)
        │
        ▼
GeminiService.chat(question, history, systemInstruction)
        │
        ▼
Returns: Answer text with audio tags → TTS → playback with highlighting
```

### RAG Retrieval Limits by Context

| Use Case | Top-N Chunks | Rationale |
|----------|-------------|-----------|
| Teaching lecture | 5 | Broad coverage for comprehensive explanation |
| Q&A answers | 3 | Focused retrieval for specific questions |
| TOC generation | 10 | Maximum coverage to structure the full course |

---

## RevenueCat Integration

RevenueCat manages subscription lifecycle, receipt validation, and cross-platform entitlement sync across iOS and Android.

### Architecture

```
┌──────────────────┐     ┌────────────────────┐
│  Flutter App     │     │   App Store /       │
│                  │────▶│   Google Play       │
│  purchases_flutter     │   (IAP)             │
│  SDK             │◀────│                     │
└────────┬─────────┘     └────────┬────────────┘
         │                        │
         │  User identity         │  Receipt validation
         │  (authUserId)          │
         ▼                        ▼
┌────────────────────────────────────────────┐
│           RevenueCat Backend               │
│                                            │
│  • Subscriber identity (keyed by           │
│    Serverpod authUserId)                   │
│  • Receipt validation                      │
│  • Entitlement management                  │
│  • Cross-platform sync                     │
│  • Analytics (MRR, churn, cohorts)         │
│                                            │
└────────────────────┬───────────────────────┘
                     │
                     │  Webhooks (HTTPS POST)
                     ▼
┌────────────────────────────────────────────┐
│         Serverpod Backend                  │
│                                            │
│  Webhook endpoint handles:                 │
│  • INITIAL_PURCHASE → create entitlement   │
│  • RENEWAL → extend expiry                 │
│  • CANCELLATION → expire at period end     │
│  • EXPIRATION → revoke access              │
│  • BILLING_ISSUE → grace period            │
│                                            │
│  Entitlement table in PostgreSQL           │
│  (server-authoritative, never trust client)│
│                                            │
└────────────────────────────────────────────┘
```

### SDK Initialization

```dart
await Purchases.configure(
  PurchasesConfiguration('<revenuecat_api_key>')
    ..appUserID = authenticatedUserId   // Serverpod authUserId
);
```

User identity is linked to Serverpod's `authUserId` — a subscriber on iOS retains access on Android and web via the same identity key.

### Product Catalog

| Product ID | Type | Tier | Price |
|-----------|------|------|-------|
| `veda_pass_monthly` | Auto-renewable | Learner Premium | $12/mo |
| `veda_pass_annual` | Auto-renewable | Learner Premium | $99/yr |
| `veda_pro_monthly` | Auto-renewable | Creator Pro | $19/mo |
| `veda_pro_annual` | Auto-renewable | Creator Pro | $159/yr |

### Entitlements

| Entitlement ID | Unlocks |
|---------------|---------|
| `learner_premium` | All teaching modes (Explanative + Lecture), unlimited Q&A, offline audio downloads |
| `creator_pro` | Unlimited courses & modules, 50 file uploads, analytics dashboard, priority AI queue |

### Paywall Triggers

The paywall surfaces when free-tier users hit limits:

| Action | Free Limit | Premium |
|--------|-----------|---------|
| Teaching mode | Quick only | Quick + Explanative + Lecture |
| Q&A questions | 5/day | Unlimited |
| Offline audio | None | Download for offline |
| Courses created | 1 | Unlimited |
| Knowledge files | 3 per course | 50 per course |

### Server-Side Validation

All entitlement checks are **server-authoritative**. The Flutter app queries the Serverpod backend for access rights — never trusts client-side receipt data alone. RevenueCat webhooks keep the server entitlement table in sync with subscription state.

---

*Last updated: February 2026*
