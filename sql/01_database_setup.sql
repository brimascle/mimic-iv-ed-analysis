--============================
--MIMIC_ED Database Setup
--============================

--ED stays
CREATE TABLE edstays (
	subject_id BIGINT,
	hadm_id BIGINT,
	stay_id BIGINT,
	intime TIMESTAMP,
	outtime TIMESTAMP,
	gender VARCHAR(10),
	race VARCHAR(100),
	arrival_transport VARCHAR(50),
	disposition VARCHAR(50)
);

--Diagnosis
CREATE TABLE diagnosis(
	subject_id BIGINT,
	stay_id BIGINT,
	seq_num INTEGER,
	icd_code VARCHAR(20),
	icd_version INTEGER,
	icd_title VARCHAR(255)
);

--Triage
CREATE TABLE triage (
    subject_id BIGINT,
    stay_id BIGINT,
    temperature DOUBLE PRECISION,
    heartrate DOUBLE PRECISION,
    resprate DOUBLE PRECISION,
    o2sat DOUBLE PRECISION,
    sbp DOUBLE PRECISION,
    dbp DOUBLE PRECISION,
    pain VARCHAR(20),
    acuity DOUBLE PRECISION,
    chiefcomplaint TEXT
);

--Vital Sign
CREATE TABLE vitalsign (
    subject_id BIGINT,
    stay_id BIGINT,
    charttime TIMESTAMP,
    temperature DOUBLE PRECISION,
    heartrate DOUBLE PRECISION,
    resprate DOUBLE PRECISION,
    o2sat DOUBLE PRECISION,
    sbp DOUBLE PRECISION,
    dbp DOUBLE PRECISION,
    rhythm VARCHAR(50),
    pain TEXT
);