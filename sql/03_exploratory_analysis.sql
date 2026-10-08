-- ============================================
-- 1. ED Length of Stay Validation
-- ============================================


-- Check ED length of stay range and identify invalid values
SELECT
    COUNT(*) AS total_ed_stays,

    SUM(
        CASE
            WHEN outtime < intime THEN 1
            ELSE 0
        END
    ) AS negative_los,

    SUM(
        CASE
            WHEN outtime = intime THEN 1
            ELSE 0
        END
    ) AS zero_los,

    MIN(
        EXTRACT(EPOCH FROM (outtime - intime)) / 3600.0
    ) AS min_los_hours,

    MAX(
        EXTRACT(EPOCH FROM (outtime - intime)) / 3600.0
    ) AS max_los_hours

FROM edstays;


-- Review ED stays with unusually short or long length of stay
SELECT
    subject_id,
    stay_id,
    intime,
    outtime,
    disposition,
    arrival_transport,
    EXTRACT(EPOCH FROM (outtime - intime)) / 3600.0 AS los_hours
FROM edstays
WHERE EXTRACT(EPOCH FROM (outtime - intime)) / 3600.0 < 0.5
   OR EXTRACT(EPOCH FROM (outtime - intime)) / 3600.0 > 24
ORDER BY los_hours;


-- LOS validation findings:
-- No negative or zero-length ED stays were identified.
-- Seven stays were shorter than 0.5 hours or longer than 24 hours.
-- These records were retained because no clear evidence indicated
-- timestamp or data-entry errors.
-- Median LOS will be emphasized because several long stays may
-- disproportionately affect the mean.


-- Summarize overall ED length of stay
SELECT
    COUNT(*) AS total_ed_stays,

    ROUND(
        AVG(EXTRACT(EPOCH FROM (outtime - intime)) / 3600.0)::numeric,
        2
    ) AS avg_los_hours,

    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP (
            ORDER BY EXTRACT(EPOCH FROM (outtime - intime)) / 3600.0
        )::numeric,
        2
    ) AS median_los_hours,

    ROUND(
        PERCENTILE_CONT(0.25) WITHIN GROUP (
            ORDER BY EXTRACT(EPOCH FROM (outtime - intime)) / 3600.0
        )::numeric,
        2
    ) AS q1_los_hours,

    ROUND(
        PERCENTILE_CONT(0.75) WITHIN GROUP (
            ORDER BY EXTRACT(EPOCH FROM (outtime - intime)) / 3600.0
        )::numeric,
        2
    ) AS q3_los_hours

FROM edstays;


-- ============================================
-- 2. ED Disposition and Length of Stay
-- ============================================

-- Compare visit volume and LOS across disposition groups
SELECT
    disposition,
    COUNT(*) AS visit_count,

    ROUND(
        AVG(EXTRACT(EPOCH FROM (outtime - intime)) / 3600.0)::numeric, 2
    ) AS avg_los_hours,

    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP (
            ORDER BY EXTRACT(EPOCH FROM (outtime - intime)) / 3600.0
        )::numeric, 2
    ) AS median_los_hours

FROM edstays
GROUP BY disposition
ORDER BY visit_count DESC;


-- ============================================
-- 3. Acuity, Admission, and Length of Stay
-- ============================================

-- Compare visit volume, admission rate, and LOS across acuity levels
SELECT
    t.acuity,
    COUNT(*) AS visit_count,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN e.disposition = 'ADMITTED' THEN 1
                ELSE 0
            END
        ) / COUNT(*), 1
    ) AS admission_rate_pct,

    ROUND(
        AVG(
            EXTRACT(EPOCH FROM (e.outtime - e.intime)) / 3600.0
        )::numeric, 2
    ) AS avg_los_hours,

    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP (
            ORDER BY EXTRACT(EPOCH FROM (e.outtime - e.intime)) / 3600.0
        )::numeric, 2
    ) AS median_los_hours

FROM edstays e
JOIN triage t
    ON e.stay_id = t.stay_id

WHERE t.acuity IS NOT NULL

GROUP BY t.acuity
ORDER BY t.acuity;


-- ============================================
-- 4. Same-Acuity Analysis by Arrival Transport
-- ============================================

-- Compare ambulance and walk-in visits within acuity levels 2 and 3
SELECT
    t.acuity,
    e.arrival_transport,

    -- Total number of ED visits in each subgroup
    COUNT(*) AS visit_count,

    -- Number of admitted visits in each subgroup
    SUM(
        CASE
            WHEN e.disposition = 'ADMITTED' THEN 1
            ELSE 0
        END
    ) AS admitted_count,

    -- Percentage of visits that resulted in admission
    ROUND(
        100.0 * SUM(
            CASE
                WHEN e.disposition = 'ADMITTED' THEN 1
                ELSE 0
            END
        ) / COUNT(*), 1
    ) AS admission_rate_pct,

    -- Average ED length of stay in hours
    ROUND(
        AVG(
            EXTRACT(EPOCH FROM (e.outtime - e.intime)) / 3600.0
        )::numeric, 2
    ) AS avg_los_hours,

    -- Median ED length of stay in hours
    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP (
            ORDER BY EXTRACT(EPOCH FROM (e.outtime - e.intime)) / 3600.0
        )::numeric, 2
    ) AS median_los_hours

FROM edstays e

JOIN triage t
    ON e.stay_id = t.stay_id

WHERE t.acuity IN (2, 3)
  AND e.arrival_transport IN ('AMBULANCE', 'WALK IN')

GROUP BY
    t.acuity,
    e.arrival_transport

ORDER BY
    t.acuity,
    e.arrival_transport;


-- ============================================
-- 5. Initial Vital Signs by Acuity and Disposition
-- ============================================

SELECT
    t.acuity,
    e.disposition,
    COUNT(*) AS visit_count,

    COUNT(t.heartrate) AS heartrate_count,

    ROUND(
        AVG(t.heartrate)::numeric, 1
    ) AS avg_heartrate,

    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP (
            ORDER BY t.heartrate
        )::numeric, 1
    ) AS median_heartrate,

    COUNT(t.sbp) AS sbp_count,

    ROUND(
        AVG(t.sbp)::numeric, 1
    ) AS avg_sbp,

    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP (
            ORDER BY t.sbp
        )::numeric, 1
    ) AS median_sbp,

    COUNT(t.o2sat) AS o2sat_count,

    ROUND(
        AVG(t.o2sat)::numeric, 1
    ) AS avg_o2sat,

    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP (
            ORDER BY t.o2sat
        )::numeric, 1
    ) AS median_o2sat

FROM edstays e
JOIN triage t
    ON e.stay_id = t.stay_id

WHERE t.acuity IN (2, 3)
  AND e.disposition IN ('ADMITTED', 'HOME')

GROUP BY
    t.acuity,
    e.disposition

ORDER BY
    t.acuity,
    e.disposition;


-- ============================================
-- 6. Primary Diagnosis Exploration
-- ============================================

-- Identify the most common primary diagnoses
SELECT
    d.icd_version,
    d.icd_code,
    d.icd_title,
    COUNT(DISTINCT d.stay_id) AS visit_count
FROM diagnosis d

WHERE d.seq_num = 1

GROUP BY
    d.icd_version,
    d.icd_code,
    d.icd_title

ORDER BY visit_count DESC;

-- Diagnosis exploration finding:
-- Primary diagnoses were highly fragmented across the 222-visit demo dataset.
-- The most common individual diagnosis occurred in only 6 visits.
-- Diagnosis-level outcome comparisons were therefore not used as a core
-- dashboard analysis because subgroup sizes were too small.

