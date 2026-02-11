# VEDA — Written Proposal

---

## The Problem

Online education is broken on both sides.

**Creating a course is unreasonably expensive.** A single hour of polished video content takes 10–40 hours to produce — scripting, recording, editing, designing slides, re-shooting. This locks out the vast majority of domain experts — researchers, engineers, doctors, consultants — who have deep knowledge but neither the time, budget, nor production skills to package it into a traditional course. The result: most human expertise stays trapped in PDFs, papers, and documentation that nobody else can learn from.

**Consuming a course is fundamentally passive.** Learners watch pre-recorded videos, scroll through slides, and hope information sticks. There's no adaptation to their pace, no way to ask clarifying questions in the moment, and no personalized depth control. Completion rates on major platforms hover around 5–15%. The format hasn't meaningfully evolved since the first MOOCs launched over a decade ago.

The core tension is clear: **the people with the most knowledge have the least time to teach, and the people trying to learn have no way to interact with what they're consuming.**

---

## Target Audience

### Primary: Independent Subject-Matter Experts (Creators)

- University professors and researchers sitting on years of published papers and lecture notes
- Corporate trainers and consultants with proprietary methodologies documented internally
- Technical professionals — engineers, data scientists, designers — with deep domain knowledge captured in documentation, wikis, and guides
- Authors and thought leaders who want to extend their written work into interactive learning experiences

**What they share:** deep expertise, existing written material, zero interest in video production, and a desire to monetize or share their knowledge at scale.

### Secondary: Self-Directed Learners (Consumers)

- Working professionals upskilling in adjacent domains (e.g., a developer learning system design, a marketer learning data analytics)
- University students supplementing coursework with deeper, more interactive explanations
- Lifelong learners exploring new subjects who prefer guided, voice-driven instruction over passive video
- Non-native English speakers who benefit from adjustable pacing and AI-narrated clarity over variable-quality instructor audio

**What they share:** a preference for active, personalized learning over one-size-fits-all video lectures, and willingness to pay for quality instruction that adapts to them.

---

## Monetization Strategy

### 1. Freemium Creator Model

| Tier | Price | Includes |
|------|-------|----------|
| **Free** | $0 | 1 course, 5 modules, 3 knowledge file uploads, community-hosted |
| **Pro** | $19/mo | Unlimited courses & modules, 50 file uploads, custom branding, analytics dashboard, priority AI generation |
| **Institution** | $99/mo | Everything in Pro + team collaboration, bulk learner management, SSO, API access, white-label option |

Creators own their content. Veda charges for the AI infrastructure (Gemini API, ElevenLabs TTS, vector storage, cloud hosting) that powers course generation and delivery.

### 2. Revenue Share on Paid Courses

Creators can set their courses as **free** or **paid**. For paid courses:

- **Veda takes 15%** of each transaction (compared to Udemy's 63% on organic sales)
- Creators keep **85%** — a significantly better split than any major platform
- Payments processed via Stripe Connect with instant creator payouts

This aligns incentives: Veda succeeds when creators succeed.

### 3. Learner Subscription (Veda Pass)

| Tier | Price | Includes |
|------|-------|----------|
| **Free Learner** | $0 | Browse & enroll in free courses, basic teaching mode (Quick), 5 Q&A questions/day |
| **Veda Pass** | $12/mo | Unlimited courses, all teaching modes (Quick / Explanative / Lecture), unlimited Q&A, offline audio downloads, progress analytics |
| **Team Pass** | $9/mo per seat | Everything in Veda Pass + admin dashboard, team progress tracking, shared course libraries |

### 4. Enterprise & API Licensing

For organizations that want to deploy Veda's AI teaching engine internally:

- **Custom knowledge bases** — companies upload internal documentation and Veda generates interactive training programs for employees
- **API access** — integrate Veda's RAG-powered teaching into existing LMS platforms
- **White-label deployments** — fully branded instances for universities and training companies
- Pricing: **custom contracts starting at $500/mo** based on usage and seat count

### Projected Revenue Mix (Year 2)

| Stream | Share |
|--------|-------|
| Creator subscriptions (Pro + Institution) | 35% |
| Learner subscriptions (Veda Pass) | 30% |
| Transaction fees on paid courses | 20% |
| Enterprise & API licensing | 15% |

---

## Why Now

Three technology shifts make Veda possible today and impossible two years ago:

1. **Large language models with tool calling** — Gemini 2.0 Flash can orchestrate complex multi-step workflows (creating modules, generating images, structuring syllabi) through natural conversation, eliminating the need for complex authoring UIs.

2. **High-quality, low-cost text-to-speech** — ElevenLabs produces natural, expressive speech at $0.15/1K characters, making voice-narrated learning economically viable at scale for the first time.

3. **Production-grade vector search** — pgvector with HNSW indexing enables sub-100ms semantic retrieval across knowledge bases, making RAG-powered teaching responsive enough for real-time interaction.

The infrastructure cost of delivering a single AI-taught lesson is now **under $0.03** — cheaper than serving a YouTube video. This is the inflection point.

---

## Competitive Advantage

- **Udemy / Coursera** require months of video production → Veda creates a course in minutes from existing documents
- **ChatGPT / Perplexity** provide answers but not structured learning paths → Veda delivers curriculum-based, progressive education
- **NotebookLM** summarizes documents → Veda teaches from them with voice narration, progress tracking, and interactive Q&A
- **Full-stack Dart** gives us end-to-end type safety and a single-language codebase from database to mobile UI — faster iteration, fewer bugs, smaller team

---

*Veda turns documents into teachers and readers into learners — at a fraction of the cost and time of traditional course creation.*
