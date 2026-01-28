This is a [Next.js](https://nextjs.org) project bootstrapped with [`create-next-app`](https://nextjs.org/docs/app/api-reference/cli/create-next-app).

## Getting Started

First, run the development server:

```bash
npm run dev
# or
yarn dev
# or
pnpm dev
# or
bun dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

You can start editing the page by modifying `app/page.tsx`. The page auto-updates as you edit the file.

This project uses [`next/font`](https://nextjs.org/docs/app/building-your-application/optimizing/fonts) to automatically optimize and load [Geist](https://vercel.com/font), a new font family for Vercel.


# Prisma Schema Design

## Key Decisions

**No User Model**
- Clerk handles all user data (auth, profile, passwords)
- We only store `userId` string to link resources to users
- Reduces complexity, no user management needed

**Resource Model Structure**

*Basic Info*: title, url, description
*Categorization*: category enum (AI_TOOLS, DATA_SCIENCE, etc.), type enum (VIDEO, ARTICLE, etc.), tags array
*AI Fields*: aiSummary, aiKeyPoints, aiSkillLevel, aiEstimatedTime - for AI-generated insights
*Metadata*: userId (Clerk link), createdAt, updatedAt (auto-managed)

**Indexes for Performance**
- `@@index([userId])` - fast "get my resources"
- `@@index([category])` - fast category filtering
- `@@index([userId, category])` - fast combined queries

**Why Enums?**
- Ensures data consistency (no typos)
- Type-safe in TypeScript
- Better query performance than strings

**Why String Arrays?**
- `tags[]` - flexible user tagging
- `aiKeyPoints[]` - multiple learning points
- Searchable with Prisma operators

# Supabase Configuration

## Database Architecture & Connection Pooling

# Overview

LearnVault is deployed on **Vercel**, a serverless platform where each incoming request executes inside an ephemeral function. In such environments, traditional persistent database connections are inefficient and can quickly exhaust PostgreSQL’s connection limits.

To address this, LearnVault uses **Supabase’s Transaction Pooler** to efficiently manage database connectivity under concurrent load.

---

## Connection Pooling Strategy

### Decision

Utilize **Supabase Transaction Pooler** with:

- **200 concurrent client connections**
- **15 persistent PostgreSQL database connections**

---

## Context

Serverless execution introduces several database challenges:

- Each API request may spawn a new function instance
- Functions are short-lived (typically < 5 seconds)
- Database connections cannot be reused reliably
- PostgreSQL has a hard connection limit (default: 100)

Without pooling, even moderate traffic can exhaust available connections and cause request failures.

---

## Rationale

### Serverless Optimization

Transaction-level pooling aligns with serverless workloads:

- Each request borrows a database connection only during query execution
- Connections are returned immediately after completion
- No idle or long-lived connections are maintained

This enables hundreds of concurrent requests to safely share a small number of database connections.

---

### Resource Efficiency

Each PostgreSQL connection consumes approximately **10 MB of memory**.

By maintaining only **15 active connections** instead of 100+:

- Database memory usage is reduced
- CPU overhead is minimized
- Overall system stability improves

The pooler handles queuing and connection reuse transparently.

---

### Scalability

With an average query latency of **50–100 ms**, a 15-connection pool can support approximately:

- **150–300 queries per second**

This throughput is sufficient for LearnVault’s expected moderate traffic patterns.

---

### Fault Tolerance

The transaction pooler provides:

- Automatic connection health checks
- Graceful retry handling
- Request queuing instead of immediate failure

If all connections are busy, incoming requests are queued briefly rather than dropped, ensuring high reliability.

---

## Trade-offs Accepted

| Limitation | Impact |
|-----------|--------|
| Maximum 200 concurrent clients | Acceptable for projected usage |
| 50–200 ms queue latency under load | Imperceptible to users |
| Session-level PostgreSQL features unavailable | Not required for this application |

---

## Alternatives Considered

### Direct Connections (Session Pooling)

**Rejected** due to:

- Poor compatibility with serverless execution
- High risk of connection exhaustion during traffic spikes
- Inefficient resource utilization

Transaction pooling was selected as the most robust and scalable option.

### What happens when more than 200 requests came:-
Scenario: 250 requests arrive simultaneously

Request 1-15   → Using 15 DB connections (ACTIVE)
Request 16-200 → Waiting in queue (QUEUED)
Request 201-250 → REJECTED with error

Error returned to requests 201-250:
"Connection pool timeout" or "Too many connections"
Status: 503 Service Unavailable

---

This architecture follows modern serverless backend best practices.

## Deploy on Vercel

The easiest way to deploy your Next.js app is to use the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme) from the creators of Next.js.

Check out our [Next.js deployment documentation](https://nextjs.org/docs/app/building-your-application/deploying) for more details.
