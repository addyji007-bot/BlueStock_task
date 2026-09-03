-- 1. Overall default rate
SELECT 
    COUNT(*) AS total_loans,
    SUM(loan_status) AS defaults,
    ROUND(AVG(loan_status)*100, 2) AS default_rate_pct
FROM credit_risk;

-- 2. Default rate by loan grade (key risk segmentation)
SELECT 
    loan_grade,
    COUNT(*) AS loans,
    SUM(loan_status) AS defaults,
    ROUND(AVG(loan_status)*100, 2) AS default_rate_pct,
    ROUND(AVG(loan_int_rate), 2) AS avg_interest
FROM credit_risk
GROUP BY loan_grade
ORDER BY loan_grade;

-- 3. Default rate by loan intent
SELECT 
    loan_intent,
    COUNT(*) AS loans,
    ROUND(AVG(loan_status)*100, 2) AS default_rate_pct
FROM credit_risk
GROUP BY loan_intent
ORDER BY default_rate_pct DESC;

-- 4. Affordability stress: loan_percent_income bands
SELECT 
    CASE 
        WHEN loan_percent_income < 0.2 THEN '<20%'
        WHEN loan_percent_income < 0.4 THEN '20-40%'
        WHEN loan_percent_income < 0.6 THEN '40-60%'
        ELSE '≥60%'
    END AS income_allocation_band,
    COUNT(*) AS loans,
    ROUND(AVG(loan_status)*100, 2) AS default_rate_pct
FROM credit_risk
GROUP BY income_allocation_band
ORDER BY default_rate_pct DESC;

-- 5. Employment length thresholds (test the "stability" assumption)
SELECT 
    CASE 
        WHEN person_emp_length < 1 THEN '<1 year'
        WHEN person_emp_length < 3 THEN '1-3 years'
        WHEN person_emp_length < 5 THEN '3-5 years'
        ELSE '5+ years'
    END AS emp_length_band,
    COUNT(*) AS loans,
    ROUND(AVG(loan_status)*100, 2) AS default_rate_pct
FROM credit_risk
WHERE person_emp_length IS NOT NULL
GROUP BY emp_length_band
ORDER BY default_rate_pct;

-- 6. Prior default flag power
SELECT 
    cb_person_default_on_file,
    COUNT(*) AS loans,
    ROUND(AVG(loan_status)*100, 2) AS default_rate_pct
FROM credit_risk
GROUP BY cb_person_default_on_file;

-- 7. Simple 3-flag risk score (adaptable from the original project)
-- Flag 1: High loan-to-income (≥40%)
-- Flag 2: Grade D or worse
-- Flag 3: Prior default on file = Y
SELECT 
    (CASE WHEN loan_percent_income >= 0.4 THEN 1 ELSE 0 END +
     CASE WHEN loan_grade IN ('D','E','F','G') THEN 1 ELSE 0 END +
     CASE WHEN cb_person_default_on_file = 'Y' THEN 1 ELSE 0 END) AS risk_flags,
    COUNT(*) AS loans,
    ROUND(AVG(loan_status)*100, 2) AS default_rate_pct
FROM credit_risk
GROUP BY risk_flags
ORDER BY risk_flags;