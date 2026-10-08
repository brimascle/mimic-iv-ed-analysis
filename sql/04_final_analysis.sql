-- ============================================
-- 04. Final Analysis Dataset
-- MIMIC-IV-ED Demo
-- ============================================

-- Goal:
-- Create a clean one-row-per-ED-stay dataset
-- that can be used directly in Power BI.


-- ============================================
-- 1. Primary Diagnosis Validation
-- ============================================

-- Confirm that each ED stay has no more than one
-- primary diagnosis record (seq_num = 1).
SELECT
    stay_id,
    COUNT(*) AS primary_diagnosis_count
FROM diagnosis
WHERE seq_num = 1
GROUP BY stay_id
HAVING COUNT(*) > 1;


-- ============================================
-- 2. Final Dataset Preview
-- ============================================

-- Combine ED stay, triage, and primary diagnosis data
-- while maintaining one row per ED stay.
SELECT
    e.subject_id,
    e.stay_id,
    e.hadm_id,
    e.intime,
    e.outtime,

    ROUND(
        (EXTRACT(EPOCH FROM (e.outtime - e.intime)) / 3600.0)::numeric, 2
    ) AS ed_los_hours,

    e.disposition,
    e.arrival_transport,

    t.acuity,
    t.heartrate,
    t.resprate,
    t.o2sat,
    t.sbp,

    CASE
        WHEN e.disposition = 'ADMITTED' THEN 1
        ELSE 0
    END AS admitted_flag,

    d.icd_version AS primary_icd_version,
    d.icd_code AS primary_icd_code,
    d.icd_title AS primary_diagnosis

FROM edstays e

LEFT JOIN triage t
    ON e.stay_id = t.stay_id

LEFT JOIN diagnosis d
    ON e.stay_id = d.stay_id
    AND d.seq_num = 1

ORDER BY e.stay_id;


-- ============================================
-- 3. Final Dataset Validation
-- ============================================

-- Verify that the final join preserves exactly
-- one row per ED stay.
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT e.stay_id) AS unique_stays

FROM edstays e

LEFT JOIN triage t
    ON e.stay_id = t.stay_id

LEFT JOIN diagnosis d
    ON e.stay_id = d.stay_id
    AND d.seq_num = 1;


-- ============================================
-- 4. Create Final Analysis View
-- ============================================

-- Create a reusable one-row-per-ED-stay view
-- for direct use in Power BI.
CREATE OR REPLACE VIEW final_ed_analysis AS

SELECT
    e.subject_id,
    e.stay_id,
    e.hadm_id,
    e.intime,
    e.outtime,

    ROUND(
        (EXTRACT(EPOCH FROM (e.outtime - e.intime)) / 3600.0)::numeric, 2
    ) AS ed_los_hours,

    e.disposition,
    e.arrival_transport,

    t.acuity,
    t.heartrate,
    t.resprate,
    t.o2sat,
    t.sbp,

    CASE
        WHEN e.disposition = 'ADMITTED' THEN 1
        ELSE 0
    END AS admitted_flag,

    d.icd_version AS primary_icd_version,
    d.icd_code AS primary_icd_code,
    d.icd_title AS primary_diagnosis

FROM edstays e

LEFT JOIN triage t
    ON e.stay_id = t.stay_id

LEFT JOIN diagnosis d
    ON e.stay_id = d.stay_id
    AND d.seq_num = 1;


-- ============================================
-- 5. Final View Validation
-- ============================================

-- Confirm that the final Power BI view contains
-- exactly one row per ED stay.
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT stay_id) AS unique_stays
FROM final_ed_analysis;

-- Preview the final Power BI dataset
SELECT *
FROM final_ed_analysis
LIMIT 10;