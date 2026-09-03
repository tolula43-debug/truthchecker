# Data Pipeline Documentation

## Overview

The data pipeline manages the flow of claim data from trusted sources into the TruthChecker database, and how user queries are matched against this data.

---

## System Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                    TRUSTED DATA SOURCES                      │
│  (Snopes, PolitiFact, WHO, CDC, Full Fact, NewsGuard)       │
└──────────────────┬───────────────────────────────────────────┘
                   │
                   ↓
┌──────────────────────────────────────────────────────────────┐
│               DATA INGESTION LAYER                           │
│  • API Clients (Google Fact Check, Snopes, PolitiFact)      │
│  • Data Parsers (normalize formats)                         │
│  • Validation (check data quality)                          │
└──────────────────┬───────────────────────────────────────────┘
                   │
                   ↓
┌──────────────────────────────────────────────────────────────┐
│               DATA PROCESSING LAYER                          │
│  • Deduplication (remove duplicate claims)                  │
│  • Normalization (standardize text)                         │
│  • Similarity matching (find related claims)                │
│  • Consensus calculation (aggregate verdicts)               │
└──────────────────┬───────────────────────────────────────────┘
                   │
                   ↓
┌──────────────────────────────────────────────────────────────┐
│                   DATABASE                                   │
│  (SQLite/PostgreSQL with claims, sources, relationships)    │
└──────────────────┬───────────────────────────────────────────┘
                   │
                   ↓
┌──────────────────────────────────────────────────────────────┐
│               USER QUERY PROCESSING                          │
│  1. Receive claim from user                                 │
│  2. Normalize search text                                   │
│  3. Fuzzy match against database                            │
│  4. Retrieve matching claims + sources                      │
│  5. Calculate confidence scores                             │
│  6. Format results for display                              │
└──────────────────┬───────────────────────────────────────────┘
                   │
                   ↓
┌──────────────────────────────────────────────────────────────┐
│              USER INTERFACE (Frontend)                       │
│  • Results display                                          │
│  • Source attribution                                       │
│  • Credibility indicators                                   │
└──────────────────────────────────────────────────────────────┘
```

---

## Data Ingestion

### 1. API Integration

#### Google Fact Check Explorer API
```
ENDPOINT = "https://factchecktools.googleapis.com/v1alpha1/claims:search"

Parameters:
- query: claim text to search
- languageCode: "en" for English
- pageSize: max 100 results

Returns:
- List of claims already fact-checked by multiple sources
- Each with verdict, sources, and links
```

#### Snopes API (via web scraping if no official API)
```
# Fallback: Parse Snopes website structure
# Extract: claim, verdict, explanation, sources
# Store in database with source attribution
```

#### PolitiFact API
```
# Similar to Google Fact Check
# Focus on political/public figure claims
# Extract credibility data
```

### 2. Data Normalization

Before storing in database:

```python
def normalize_claim(claim_text):
    """
    Normalize claim for consistent searching
    """
    # Remove extra whitespace
    claim = ' '.join(claim_text.split())
    
    # Convert to lowercase for matching
    claim_lower = claim.lower()
    
    # Remove common punctuation variations
    claim_normalized = claim_lower.replace('?', '').strip()
    
    return claim_normalized

# Example:
# Input:  "Is climate change  REAL ???"
# Output: "is climate change real"
```

### 3. Deduplication

```python
def check_duplicate(claim_text):
    """
    Check if claim already exists in database
    """
    normalized = normalize_claim(claim_text)
    
    existing = db.query(Claims).filter_by(
        claim_normalized=normalized
    ).first()
    
    if existing:
        return existing  # Don't add duplicate
    else:
        return None  # New claim
```

---

## Data Processing

### 1. Similarity Matching

Find related claims using fuzzy string matching:

```python
from difflib import SequenceMatcher

def calculate_similarity(claim1, claim2):
    """
    Compare two claims and return similarity score (0-1)
    """
    # Normalize both
    c1 = normalize_claim(claim1)
    c2 = normalize_claim(claim2)
    
    # Calculate similarity ratio
    ratio = SequenceMatcher(None, c1, c2).ratio()
    
    return ratio

# Example:
# "Vaccines contain microchips" vs "Do vaccines have microchips?"
# Similarity: 0.85 (85%) - very similar

# "Earth is flat" vs "Earth is round"
# Similarity: 0.60 (60%) - somewhat similar
```

### 2. Consensus Calculation

Aggregate verdicts from multiple sources:

```python
def calculate_consensus(claim_id):
    """
    Calculate overall confidence score from all sources
    """
    sources = db.query(ClaimSources).filter_by(claim_id=claim_id).all()
    
    if not sources:
        return None
    
    total_score = 0
    total_weight = 0
    
    for source in sources:
        # Weight by source credibility
        source_obj = db.query(Sources).get(source.source_id)
        credibility = source_obj.credibility_score / 100  # 0-1
        
        # Verdict weight
        verdict_map = {
            'TRUE': 1.0,
            'PARTIALLY_TRUE': 0.5,
            'FALSE': 0.0,
            'UNCLEAR': 0.25
        }
        verdict_weight = verdict_map.get(source.source_verdict, 0.25)
        
        # Weighted score
        weighted_score = credibility * verdict_weight
        total_score += weighted_score
        total_weight += credibility
    
    # Average consensus (0-100)
    consensus = (total_score / total_weight) * 100 if total_weight > 0 else 0
    
    return int(consensus)

# Example calculation:
# Source 1 (Snopes): 95 credibility, FALSE verdict
#   Score = 0.95 × 0.0 = 0.0
# Source 2 (WHO): 99 credibility, FALSE verdict
#   Score = 0.99 × 0.0 = 0.0
# Source 3 (CDC): 99 credibility, FALSE verdict
#   Score = 0.99 × 0.0 = 0.0
#
# Consensus = (0 + 0 + 0) / (0.95 + 0.99 + 0.99) × 100 = 0%
# → DEFINITELY FALSE
```

---

## User Query Processing

### Step-by-Step Flow

#### 1. User Input
```javascript
// User enters: "Do vaccines contain microchips?"
user_input = "Do vaccines contain microchips?"
```

#### 2. Backend Processing
```python
@app.route('/api/search', methods=['POST'])
def search_claim():
    user_claim = request.json.get('claim')
    
    # 1. Normalize input
    normalized = normalize_claim(user_claim)
    
    # 2. Search database
    results = search_claims(normalized)
    
    # 3. Calculate similarity
    ranked_results = rank_results(results, user_claim)
    
    # 4. Retrieve sources for top match
    if ranked_results:
        best_match = ranked_results[0]
        sources = get_claim_sources(best_match.id)
        consensus = calculate_consensus(best_match.id)
        
        # 5. Format response
        response = {
            'claim': best_match.claim_text,
            'verdict': best_match.verdict,
            'confidence': consensus,
            'explanation': best_match.explanation,
            'sources': format_sources(sources),
            'similar_claims': get_similar_claims(best_match.id)
        }
    else:
        response = {
            'found': False,
            'message': 'No information about this claim yet'
        }
    
    return response
```

#### 3. Search Function (Fuzzy Matching)
```python
def search_claims(normalized_query):
    """
    Find claims similar to user query
    """
    all_claims = db.query(Claims).all()
    
    matches = []
    for claim in all_claims:
        similarity = calculate_similarity(
            normalized_query,
            claim.claim_normalized
        )
        
        # Return if > 70% similar
        if similarity > 0.7:
            matches.append({
                'claim': claim,
                'similarity': similarity
            })
    
    # Sort by similarity (highest first)
    matches.sort(key=lambda x: x['similarity'], reverse=True)
    
    return matches
```

#### 4. Response Formatting
```python
def format_sources(sources):
    """
    Format sources for frontend display
    """
    formatted = []
    for source in sources:
        formatted.append({
            'name': source.source_object.name,
            'verdict': source.source_verdict,
            'credibility': source.source_object.credibility_score,
            'url': source.source_url,
            'date': source.source_date.isoformat()
        })
    
    return formatted
```

---

## Update Schedule

### Real-Time Updates
- User queries trigger database check
- Quick responses (< 2 seconds target)

### Hourly Updates
- Check Google Fact Check Explorer for new claims
- Update trending claims

### Daily Updates
- Sync with Snopes (if API available)
- Sync with PolitiFact
- Recalculate consensus scores

### Weekly Updates
- Full sync with all sources
- Deduplication pass
- Update source credibility scores
- Archive unverified claims > 1 year old

### Monthly Maintenance
- Manual review of top 100 searched claims
- Update explanations
- Merge duplicate claims
- Update similar_claims table

---

## Error Handling

```python
def search_claim_safe():
    try:
        # Process query
        results = search_claims(normalized_query)
        return results
    
    except DatabaseError as e:
        logger.error(f"Database error: {e}")
        return {
            'error': 'Database unavailable',
            'message': 'Please try again later'
        }
    
    except APIError as e:
        logger.error(f"API error: {e}")
        # Fall back to local database only
        results = db.query(Claims).all()
        return results
    
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        return {
            'error': 'Unknown error',
            'message': 'Please contact support'
        }
```

---

## Performance Optimization

### Caching
```python
# Cache popular searches (top 100 claims)
from functools import lru_cache

@lru_cache(maxsize=100)
def get_popular_claims():
    return db.query(Claims).order_by(
        Claims.search_count.desc()
    ).limit(100).all()
```

### Indexing
- Index on `claim_normalized` for fast searching
- Index on `consensus_score` for sorting
- Index on `category` for filtering

### Batch Processing
- Process multiple source updates in batches
- Reduce API call overhead
- Efficient database transactions
