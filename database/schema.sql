-- TruthChecker Database Schema
-- SQLite/PostgreSQL compatible

-- Sources table: Trusted fact-checking sources
CREATE TABLE IF NOT EXISTS sources (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR(100) NOT NULL UNIQUE,
  url VARCHAR(255) NOT NULL,
  category VARCHAR(50),
  credibility_score INTEGER CHECK(credibility_score >= 0 AND credibility_score <= 100),
  country VARCHAR(50),
  description TEXT,
  is_active BOOLEAN DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Claims table: Fact-checked claims
CREATE TABLE IF NOT EXISTS claims (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  claim_text TEXT NOT NULL,
  claim_normalized TEXT NOT NULL,
  category VARCHAR(50),
  verdict VARCHAR(20) NOT NULL,
  consensus_score INTEGER,
  explanation TEXT,
  language VARCHAR(10) DEFAULT 'en',
  is_trending BOOLEAN DEFAULT 0,
  search_count INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_verified TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Claim sources: Many-to-many relationship
CREATE TABLE IF NOT EXISTS claim_sources (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  claim_id INTEGER NOT NULL,
  source_id INTEGER NOT NULL,
  source_verdict VARCHAR(20),
  source_url VARCHAR(255),
  source_date DATE,
  confidence INTEGER,
  last_checked TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (claim_id) REFERENCES claims(id) ON DELETE CASCADE,
  FOREIGN KEY (source_id) REFERENCES sources(id) ON DELETE RESTRICT
);

-- Similar claims: Relationship table for similar claims
CREATE TABLE IF NOT EXISTS similar_claims (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  claim_id_1 INTEGER NOT NULL,
  claim_id_2 INTEGER NOT NULL,
  similarity_score DECIMAL(3,2),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (claim_id_1) REFERENCES claims(id) ON DELETE CASCADE,
  FOREIGN KEY (claim_id_2) REFERENCES claims(id) ON DELETE CASCADE,
  UNIQUE(claim_id_1, claim_id_2)
);

-- Verification logs: Audit trail
CREATE TABLE IF NOT EXISTS verification_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  claim_id INTEGER NOT NULL,
  action VARCHAR(50),
  old_verdict VARCHAR(20),
  new_verdict VARCHAR(20),
  notes TEXT,
  verified_by VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (claim_id) REFERENCES claims(id) ON DELETE CASCADE
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_claims_normalized ON claims(claim_normalized);
CREATE INDEX IF NOT EXISTS idx_claims_category ON claims(category);
CREATE INDEX IF NOT EXISTS idx_claims_verdict ON claims(verdict);
CREATE INDEX IF NOT EXISTS idx_sources_name ON sources(name);
CREATE INDEX IF NOT EXISTS idx_sources_credibility ON sources(credibility_score);
CREATE INDEX IF NOT EXISTS idx_claim_sources_claim ON claim_sources(claim_id);
CREATE INDEX IF NOT EXISTS idx_claim_sources_source ON claim_sources(source_id);
