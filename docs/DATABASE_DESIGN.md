# Database Design Documentation

## Overview

The TruthChecker database stores verified claims, sources, and relationships between them. It uses a normalized relational structure for efficient querying and maintenance.

## Database Schema

### 1. `sources` Table

Stores trusted fact-checking sources and their credibility ratings.

```sql
CREATE TABLE sources (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR(100) NOT NULL UNIQUE,
  url VARCHAR(255) NOT NULL,
  category VARCHAR(50),  -- health, politics, science, general
  credibility_score INTEGER CHECK(credibility_score >= 0 AND credibility_score <= 100),
  country VARCHAR(50),
  description TEXT,
  is_active BOOLEAN DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Example Data:**
```
id | name      | credibility_score | category | is_active
1  | Snopes    | 95                | general  | 1
2  | PolitiFact| 90                | politics | 1
3  | WHO       | 99                | health   | 1
4  | CDC       | 99                | health   | 1
5  | Full Fact | 92                | general  | 1
```

---

### 2. `claims` Table

Stores claims that have been fact-checked.

```sql
CREATE TABLE claims (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  claim_text TEXT NOT NULL,
  claim_normalized TEXT NOT NULL,  -- lowercase, no extra spaces for searching
  category VARCHAR(50),  -- health, politics, science, technology, etc.
  verdict VARCHAR(20) NOT NULL,  -- TRUE, FALSE, PARTIALLY_TRUE, UNCLEAR
  consensus_score INTEGER,  -- 0-100, where 100 is definitely true
  explanation TEXT,  -- human-readable explanation
  language VARCHAR(10) DEFAULT 'en',
  is_trending BOOLEAN DEFAULT 0,
  search_count INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_verified TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Example Data:**
```
id | claim_text                    | verdict       | consensus_score
1  | 5G causes COVID-19            | FALSE         | 5
2  | Vaccines contain microchips   | FALSE         | 2
3  | Earth is round                | TRUE          | 99
4  | Climate change is real        | PARTIALLY_TRUE| 92
```

---

### 3. `claim_sources` Table

Junction table linking claims to sources and storing verification details.

```sql
CREATE TABLE claim_sources (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  claim_id INTEGER NOT NULL,
  source_id INTEGER NOT NULL,
  source_verdict VARCHAR(20),  -- TRUE, FALSE, PARTIALLY_TRUE, UNCLEAR
  source_url VARCHAR(255),  -- Direct link to the fact-check
  source_date DATE,  -- When this source verified it
  confidence INTEGER,  -- 0-100, how confident is this source
  last_checked TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (claim_id) REFERENCES claims(id) ON DELETE CASCADE,
  FOREIGN KEY (source_id) REFERENCES sources(id) ON DELETE RESTRICT
);
```

**Example Data:**
```
claim_id | source_id | source_verdict | confidence | source_url
1        | 1         | FALSE          | 95         | https://snopes.com/5g-covid
1        | 3         | FALSE          | 99         | https://who.int/5g-covid
2        | 1         | FALSE          | 98         | https://snopes.com/vaccine-chips
```

---

### 4. `similar_claims` Table

Stores relationships between similar claims for better search results.

```sql
CREATE TABLE similar_claims (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  claim_id_1 INTEGER NOT NULL,
  claim_id_2 INTEGER NOT NULL,
  similarity_score DECIMAL(3,2),  -- 0.00 to 1.00
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (claim_id_1) REFERENCES claims(id) ON DELETE CASCADE,
  FOREIGN KEY (claim_id_2) REFERENCES claims(id) ON DELETE CASCADE,
  UNIQUE(claim_id_1, claim_id_2)
);
```

---

### 5. `verification_logs` Table

Audit trail for tracking when claims were verified and updated.

```sql
CREATE TABLE verification_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  claim_id INTEGER NOT NULL,
  action VARCHAR(50),  -- created, updated, verified
  old_verdict VARCHAR(20),
  new_verdict VARCHAR(20),
  notes TEXT,
  verified_by VARCHAR(100),  -- username or source
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (claim_id) REFERENCES claims(id) ON DELETE CASCADE
);
```

---

## Indexes for Performance

```sql
-- Speed up claim searches
CREATE INDEX idx_claims_normalized ON claims(claim_normalized);
CREATE INDEX idx_claims_category ON claims(category);
CREATE INDEX idx_claims_verdict ON claims(verdict);

-- Speed up source lookups
CREATE INDEX idx_sources_name ON sources(name);
CREATE INDEX idx_sources_credibility ON sources(credibility_score);

-- Speed up claim-source relationships
CREATE INDEX idx_claim_sources_claim ON claim_sources(claim_id);
CREATE INDEX idx_claim_sources_source ON claim_sources(source_id);
```

---

## Consensus Score Calculation

```
consensus_score = (sum of (source_confidence × source_verdict_weight)) / total_sources

where:
- source_verdict_weight: TRUE=1.0, PARTIALLY_TRUE=0.5, FALSE=0.0, UNCLEAR=0.25
- Each source weighted by its credibility_score (95/100 = 0.95 multiplier)

Example:
- Snopes (95 credibility) says FALSE → 0.95 × 0.0 = 0.0
- WHO (99 credibility) says FALSE → 0.99 × 0.0 = 0.0
- CDC (99 credibility) says FALSE → 0.99 × 0.0 = 0.0
- Average = 0, so consensus_score = 0 (definitely FALSE)
```
