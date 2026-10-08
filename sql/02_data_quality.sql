-- ============================================
-- 1. Import Validation
-- ============================================


-- Verify successful data import by checking row counts for each table
SELECT 'edstays' AS table_name, COUNT(*) AS row_count
FROM edstays

UNION ALL

SELECT 'diagnosis', COUNT(*)
FROM diagnosis

UNION ALL

SELECT 'triage', COUNT(*)
FROM triage

UNION ALL

SELECT 'vitalsign', COUNT(*)
FROM vitalsign;


-- Preview sample records from each table to verify data structure and import quality
SELECT * 
FROM edstays 
LIMIT 10;

SELECT * 
FROM diagnosis 
LIMIT 10;

SELECT * 
FROM triage 
LIMIT 10;

SELECT * 
FROM vitalsign 
LIMIT 10;

-- ============================================
-- 2. Missing Value Check
-- ============================================


-- Check missing values in ED stays
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN subject_id IS NULL THEN 1 ELSE 0 END) AS null_subject_id,
    SUM(CASE WHEN stay_id IS NULL THEN 1 ELSE 0 END) AS null_stay_id,
    SUM(CASE WHEN hadm_id IS NULL THEN 1 ELSE 0 END) AS null_hadm_id,
    SUM(CASE WHEN intime IS NULL THEN 1 ELSE 0 END) AS null_intime,
    SUM(CASE WHEN outtime IS NULL THEN 1 ELSE 0 END) AS null_outtime,
    SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) AS null_gender,
    SUM(CASE WHEN race IS NULL THEN 1 ELSE 0 END) AS null_race,
    SUM(CASE WHEN arrival_transport IS NULL THEN 1 ELSE 0 END) AS null_arrival_transport,
    SUM(CASE WHEN disposition IS NULL THEN 1 ELSE 0 END) AS null_disposition
FROM edstays;


-- Check missing values in triage
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN subject_id IS NULL THEN 1 ELSE 0 END) AS null_subject_id,
    SUM(CASE WHEN stay_id IS NULL THEN 1 ELSE 0 END) AS null_stay_id,
    SUM(CASE WHEN temperature IS NULL THEN 1 ELSE 0 END) AS null_temperature,
    SUM(CASE WHEN heartrate IS NULL THEN 1 ELSE 0 END) AS null_heartrate,
    SUM(CASE WHEN resprate IS NULL THEN 1 ELSE 0 END) AS null_resprate,
    SUM(CASE WHEN o2sat IS NULL THEN 1 ELSE 0 END) AS null_o2sat,
    SUM(CASE WHEN sbp IS NULL THEN 1 ELSE 0 END) AS null_sbp,
    SUM(CASE WHEN dbp IS NULL THEN 1 ELSE 0 END) AS null_dbp,
    SUM(CASE WHEN pain IS NULL THEN 1 ELSE 0 END) AS null_pain,
    SUM(CASE WHEN acuity IS NULL THEN 1 ELSE 0 END) AS null_acuity,
    SUM(CASE WHEN chiefcomplaint IS NULL THEN 1 ELSE 0 END) AS null_chiefcomplaint
FROM triage;


-- Check missing values in vitalsign
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN subject_id IS NULL THEN 1 ELSE 0 END) AS null_subject_id,
    SUM(CASE WHEN stay_id IS NULL THEN 1 ELSE 0 END) AS null_stay_id,
    SUM(CASE WHEN charttime IS NULL THEN 1 ELSE 0 END) AS null_charttime,
    SUM(CASE WHEN temperature IS NULL THEN 1 ELSE 0 END) AS null_temperature,
    SUM(CASE WHEN heartrate IS NULL THEN 1 ELSE 0 END) AS null_heartrate,
    SUM(CASE WHEN resprate IS NULL THEN 1 ELSE 0 END) AS null_resprate,
    SUM(CASE WHEN o2sat IS NULL THEN 1 ELSE 0 END) AS null_o2sat,
    SUM(CASE WHEN sbp IS NULL THEN 1 ELSE 0 END) AS null_sbp,
    SUM(CASE WHEN dbp IS NULL THEN 1 ELSE 0 END) AS null_dbp,
    SUM(CASE WHEN rhythm IS NULL THEN 1 ELSE 0 END) AS null_rhythm,
    SUM(CASE WHEN pain IS NULL THEN 1 ELSE 0 END) AS null_pain
FROM vitalsign;


-- Check missing values in diagnosis
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN subject_id IS NULL THEN 1 ELSE 0 END) AS null_subject_id,
    SUM(CASE WHEN stay_id IS NULL THEN 1 ELSE 0 END) AS null_stay_id,
    SUM(CASE WHEN seq_num IS NULL THEN 1 ELSE 0 END) AS null_seq_num,
    SUM(CASE WHEN icd_code IS NULL THEN 1 ELSE 0 END) AS null_icd_code,
    SUM(CASE WHEN icd_version IS NULL THEN 1 ELSE 0 END) AS null_icd_version,
    SUM(CASE WHEN icd_title IS NULL THEN 1 ELSE 0 END) AS null_icd_title
FROM diagnosis;


-- ============================================
-- 3. Duplicate / Key Check
-- ============================================

-- Check duplicate ED stay IDs
SELECT
    stay_id,
    COUNT(*) AS record_count
FROM edstays
GROUP BY stay_id
HAVING COUNT(*) > 1;


-- Check duplicate triage stay IDs
SELECT
    stay_id,
    COUNT(*) AS record_count
FROM triage
GROUP BY stay_id
HAVING COUNT(*) > 1;


-- ============================================
-- 4. Categorical Value Check
-- ============================================

-- Review ED disposition distribution
SELECT
    disposition,
    COUNT(*) AS visit_count
FROM edstays
GROUP BY disposition
ORDER BY visit_count DESC;


-- Review arrival transport distribution
SELECT
    arrival_transport,
    COUNT(*) AS visit_count
FROM edstays
GROUP BY arrival_transport
ORDER BY visit_count DESC;


-- Review triage acuity distribution
SELECT
    acuity,
    COUNT(*) AS visit_count
FROM triage
GROUP BY acuity
ORDER BY acuity;


-- Review ICD versions
SELECT
    icd_version,
    COUNT(*) AS diagnosis_count
FROM diagnosis
GROUP BY icd_version
ORDER BY icd_version;


-- ============================================
-- 5. Numeric Range Check
-- ============================================

-- Review ranges of triage vital signs
SELECT
    MIN(temperature) AS min_temperature,
    MAX(temperature) AS max_temperature,
    MIN(heartrate) AS min_heartrate,
    MAX(heartrate) AS max_heartrate,
    MIN(resprate) AS min_resprate,
    MAX(resprate) AS max_resprate,
    MIN(o2sat) AS min_o2sat,
    MAX(o2sat) AS max_o2sat,
    MIN(sbp) AS min_sbp,
    MAX(sbp) AS max_sbp,
    MIN(dbp) AS min_dbp,
    MAX(dbp) AS max_dbp
FROM triage;


-- Investigate suspicious temperature values
SELECT *
FROM triage
WHERE temperature < 90;


-- Investigate suspicious blood pressure values
SELECT *
FROM triage
WHERE dbp > 200;


-- Data quality findings:
-- One temperature value (36.5°F) and one DBP value (879 mmHg)
-- were identified as implausible outliers.
-- Original values were retained; these values will be treated as missing
-- if the variables are used in downstream analysis.

-- ============================================
-- 6. Table Relationship Check
-- ============================================

-- Check whether ED stays have matching triage records
SELECT
    COUNT(*) AS total_ed_stays,
    COUNT(t.stay_id) AS matched_triage_records,
    COUNT(*) - COUNT(t.stay_id) AS unmatched_triage_records
FROM edstays e
LEFT JOIN triage t
    ON e.stay_id = t.stay_id;


-- Check how many ED stays have diagnosis records
SELECT
    COUNT(DISTINCT e.stay_id) AS total_ed_stays,
    COUNT(DISTINCT d.stay_id) AS stays_with_diagnosis
FROM edstays e
LEFT JOIN diagnosis d
    ON e.stay_id = d.stay_id;


-- Identify ED stays without a diagnosis record
SELECT
    e.*
FROM edstays e
LEFT JOIN diagnosis d
    ON e.stay_id = d.stay_id
WHERE d.stay_id IS NULL;


-- Relationship check findings:
-- 221 of 222 ED stays had at least one matching diagnosis record.
-- One admitted ED stay had no corresponding record in the diagnosis table.
-- The ED stay itself contained complete encounter information.


-- Check how many ED stays have repeated vital sign records
SELECT
    COUNT(DISTINCT e.stay_id) AS total_ed_stays,
    COUNT(DISTINCT v.stay_id) AS stays_with_vitals
FROM edstays e
LEFT JOIN vitalsign v
    ON e.stay_id = v.stay_id;


-- ============================================
-- Data Quality Summary
-- ============================================

-- 1. edstays and triage contain 222 ED stays with no duplicate stay_id.
-- 2. All 222 ED stays have a matching triage record.
-- 3. 221 of 222 ED stays have at least one diagnosis record.
-- 4. 206 of 222 ED stays have at least one repeated vitalsign record.
-- 5. Triage acuity is missing for 15 stays.
-- 6. One temperature value (36.5°F) and one DBP value (879 mmHg)
--    were identified as implausible outliers.
-- 7. Original source values were retained. Implausible values will be
--    excluded or converted to NULL if used in downstream analysis.
-- 8. Rhythm in vitalsign is 96.8% missing and will not be used as a
--    core analysis variable.
