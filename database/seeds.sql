-- Initial seed data for TruthChecker

-- Insert trusted sources
INSERT INTO sources (name, url, category, credibility_score, country, description)
VALUES
  ('Snopes', 'https://snopes.com', 'general', 95, 'USA', 'Urban legends, rumors, and misinformation'),
  ('PolitiFact', 'https://politifact.com', 'politics', 90, 'USA', 'Political fact-checking'),
  ('World Health Organization (WHO)', 'https://who.int', 'health', 99, 'International', 'Public health information'),
  ('CDC (Centers for Disease Control)', 'https://cdc.gov', 'health', 99, 'USA', 'Disease and health information'),
  ('Full Fact', 'https://fullfact.org', 'general', 92, 'UK', 'UK-focused fact-checking'),
  ('BBC Reality Check', 'https://bbc.com/news', 'general', 94, 'UK', 'BBC''s fact-checking service'),
  ('Reuters Fact Check', 'https://reuters.com/fact-check', 'general', 93, 'International', 'International news fact-checking'),
  ('AFP Fact Check', 'https://afp.com/en/pages/factcheck', 'general', 91, 'International', 'Agence France-Presse fact-checking');

-- Insert sample claims (health category - vaccines)
INSERT INTO claims (claim_text, claim_normalized, category, verdict, consensus_score, explanation, is_trending)
VALUES
  ('Vaccines contain microchips',
   'vaccines contain microchips',
   'health',
   'FALSE',
   2,
   'Multiple trusted sources confirm vaccines do NOT contain microchips. This is a common false claim spread online.',
   1),
  
  ('COVID-19 vaccines alter your DNA',
   'covid 19 vaccines alter your dna',
   'health',
   'FALSE',
   5,
   'COVID-19 vaccines cannot alter human DNA. They work differently from how DNA editing works.',
   1),
  
  ('Vaccines cause autism',
   'vaccines cause autism',
   'health',
   'FALSE',
   1,
   'The original study claiming this was fraudulent and has been thoroughly debunked by numerous peer-reviewed studies.',
   0);

-- Insert sample claims (general/conspiracy)
INSERT INTO claims (claim_text, claim_normalized, category, verdict, consensus_score, explanation)
VALUES
  ('5G causes COVID-19',
   '5g causes covid 19',
   'science',
   'FALSE',
   3,
   'COVID-19 is caused by a virus (SARS-CoV-2), not by 5G networks. The pandemic spread in countries without 5G.',
   0),
  
  ('Bill Gates invented the internet',
   'bill gates invented the internet',
   'technology',
   'FALSE',
   1,
   'The internet was developed through collective effort by many scientists and organizations. Bill Gates founded Microsoft.',
   0);

-- Insert claim-source relationships for vaccines contain microchips
INSERT INTO claim_sources (claim_id, source_id, source_verdict, source_url, source_date, confidence)
VALUES
  (1, 1, 'FALSE', 'https://snopes.com/vaccines-microchips', DATE('2024-03-01'), 95),
  (1, 3, 'FALSE', 'https://who.int/vaccine-microchips', DATE('2024-02-15'), 99),
  (1, 4, 'FALSE', 'https://cdc.gov/vaccine-microchips', DATE('2024-02-01'), 99),
  (1, 6, 'FALSE', 'https://bbc.com/vaccine-microchips', DATE('2024-01-20'), 94);

-- Insert claim-source relationships for 5G causes COVID
INSERT INTO claim_sources (claim_id, source_id, source_verdict, source_url, source_date, confidence)
VALUES
  (4, 1, 'FALSE', 'https://snopes.com/5g-covid', DATE('2024-02-10'), 95),
  (4, 3, 'FALSE', 'https://who.int/5g-covid', DATE('2024-01-15'), 99),
  (4, 6, 'FALSE', 'https://bbc.com/5g-covid', DATE('2024-01-10'), 94);
