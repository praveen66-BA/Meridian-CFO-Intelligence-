-- 
-- MERIDIAN GROUP — CFO Intelligence Platform
-- Complete SQL Analytics Suite
-- Author: Praveen Kumar Nutakki
-- Purpose: Financial close analytics, variance analysis,
--          anomaly detection and intercompany reconciliation
-- Database: MeridianCFO
-- 

USE MeridianCFO;
GO

-- 
-- QUERY 1: Revenue Variance By Business Unit
-- Business Need: Track which divisions are hitting revenue
--               targets and flag breaches beyond 10%
-- Anomaly Caught: West Division October 2023 revenue spike
--

SELECT 
    dim_business_unit.unit_name,
    dim_date.fiscal_period,
    dim_date.year,
    dim_date.month,

    SUM(CASE WHEN fact_financials.scenario_id = 1
        AND dim_account.account_type = 'Revenue'
        THEN fact_financials.amount ELSE 0 END)
        AS actual_revenue,

    SUM(CASE WHEN fact_financials.scenario_id = 2
        AND dim_account.account_type = 'Revenue'
        THEN fact_financials.amount ELSE 0 END)
        AS budget_revenue,

    SUM(CASE WHEN fact_financials.scenario_id = 1
        AND dim_account.account_type = 'Revenue'
        THEN fact_financials.amount ELSE 0 END) -
    SUM(CASE WHEN fact_financials.scenario_id = 2
        AND dim_account.account_type = 'Revenue'
        THEN fact_financials.amount ELSE 0 END)
        AS variance_amount,

    ROUND(
        (SUM(CASE WHEN fact_financials.scenario_id = 1
            AND dim_account.account_type = 'Revenue'
            THEN fact_financials.amount ELSE 0 END) -
        SUM(CASE WHEN fact_financials.scenario_id = 2
            AND dim_account.account_type = 'Revenue'
            THEN fact_financials.amount ELSE 0 END)) /
        NULLIF(ABS(SUM(CASE WHEN fact_financials.scenario_id = 2
            AND dim_account.account_type = 'Revenue'
            THEN fact_financials.amount ELSE 0 END)), 0) * 100
    , 2) AS variance_pct,

    CASE
        WHEN ABS(
            (SUM(CASE WHEN fact_financials.scenario_id = 1
                AND dim_account.account_type = 'Revenue'
                THEN fact_financials.amount ELSE 0 END) -
            SUM(CASE WHEN fact_financials.scenario_id = 2
                AND dim_account.account_type = 'Revenue'
                THEN fact_financials.amount ELSE 0 END)) /
            NULLIF(ABS(SUM(CASE WHEN fact_financials.scenario_id = 2
                AND dim_account.account_type = 'Revenue'
                THEN fact_financials.amount ELSE 0 END)), 0) * 100
        ) > 10 THEN 'BREACH'
        ELSE 'NORMAL'
    END AS status_flag

FROM fact_financials
JOIN dim_business_unit ON fact_financials.business_unit_id = dim_business_unit.unit_id
JOIN dim_account ON fact_financials.account_id = dim_account.account_id
JOIN dim_date ON fact_financials.date_id = dim_date.date_id

Group by dim_business_unit.unit_name,
		dim_date.fiscal_period,
		dim_date.year,
		dim_date.month

Order By 
	dim_date.year,
	dim_date.month,
	dim_business_unit.unit_name;




 
-- QUERY 2: Full Budget vs Actual Analysis
-- Business Need: Complete P&L variance report for every
--               account line every division every month
-- Anomaly Caught: South Division Q3 2024 G&A cost overrun
-- 

SELECT
    dim_business_unit.unit_name,
    dim_account.account_name,
    dim_account.account_type,
    dim_date.fiscal_period,

    ROUND(SUM(CASE WHEN fact_financials.scenario_id = 1
        THEN fact_financials.amount ELSE 0 END), 2)
        AS actual_amount,

    ROUND(SUM(CASE WHEN fact_financials.scenario_id = 2
        THEN fact_financials.amount ELSE 0 END), 2)
        AS budget_amount,

    ROUND(
        SUM(CASE WHEN fact_financials.scenario_id = 1
            THEN fact_financials.amount ELSE 0 END) -
        SUM(CASE WHEN fact_financials.scenario_id = 2
            THEN fact_financials.amount ELSE 0 END)
    , 2) AS variance_amount,

    ROUND(
        (SUM(CASE WHEN fact_financials.scenario_id = 1
            THEN fact_financials.amount ELSE 0 END) -
        SUM(CASE WHEN fact_financials.scenario_id = 2
            THEN fact_financials.amount ELSE 0 END)) /
        NULLIF(ABS(SUM(CASE WHEN fact_financials.scenario_id = 2
            THEN fact_financials.amount ELSE 0 END)), 0) * 100
    , 2) AS variance_pct,

    CASE
        WHEN dim_account.account_type = 'Revenue'
            AND SUM(CASE WHEN fact_financials.scenario_id = 1
                THEN fact_financials.amount ELSE 0 END) >=
                SUM(CASE WHEN fact_financials.scenario_id = 2
                THEN fact_financials.amount ELSE 0 END)
            THEN 'FAVORABLE'
        WHEN dim_account.account_type != 'Revenue'
            AND SUM(CASE WHEN fact_financials.scenario_id = 1
                THEN fact_financials.amount ELSE 0 END) <=
                SUM(CASE WHEN fact_financials.scenario_id = 2
                THEN fact_financials.amount ELSE 0 END)
            THEN 'FAVORABLE'
        ELSE 'UNFAVORABLE'
    END AS variance_type
    
FROM fact_financials 
JOIN dim_business_unit ON fact_financials.business_unit_id = dim_business_unit.unit_id 
JOIN dim_account ON fact_financials.account_id = dim_account.account_id
JOIN dim_date ON fact_financials.date_id = dim_date.date_id 

GROUP BY dim_business_unit.unit_name,
            dim_account.account_name,
            dim_account.account_type,
            dim_date.fiscal_period

ORDER BY 
        dim_date.fiscal_period,
        dim_business_unit.unit_name;
Go 

-- 
-- QUERY 3: Rolling 12 Month EBITDA Trend
-- Business Need: Show real profitability trend smoothed
--               across 12 months eliminating seasonal noise
-- Anomaly Caught: West Division EBITDA spike confirmed
--                as one-time event not structural growth
--

WITH monthly_pnl AS (
    SELECT
        dim_business_unit.unit_name,
        dim_date.fiscal_period,
        dim_date.year,
        dim_date.month,

        SUM(CASE WHEN fact_financials.scenario_id = 1
            AND dim_account.account_type = 'Revenue'
            THEN fact_financials.amount ELSE 0 END)
            AS total_revenue,

        SUM(CASE WHEN fact_financials.scenario_id = 1
            THEN fact_financials.amount ELSE 0 END)
            AS ebitda

    FROM fact_financials
    JOIN dim_business_unit
        ON fact_financials.business_unit_id = dim_business_unit.unit_id
    JOIN dim_account
        ON fact_financials.account_id = dim_account.account_id
    JOIN dim_date
        ON fact_financials.date_id = dim_date.date_id

    GROUP BY
        dim_business_unit.unit_name,
        dim_date.fiscal_period,
        dim_date.year,
        dim_date.month
)

SELECT
    unit_name,
    fiscal_period,
    year,
    month,
    ROUND(total_revenue, 2)     AS total_revenue,
    ROUND(ebitda, 2)            AS ebitda,

    ROUND(ebitda /
        NULLIF(total_revenue, 0) * 100, 2)
        AS ebitda_margin_pct,

    ROUND(SUM(ebitda) OVER (
        PARTITION BY unit_name
        ORDER BY year, month
        ROWS BETWEEN 11 PRECEDING AND CURRENT ROW
    ), 2) AS rolling_12m_ebitda,

    ROUND(ebitda - LAG(ebitda, 1) OVER (
        PARTITION BY unit_name
        ORDER BY year, month
    ), 2) AS mom_change

FROM monthly_pnl
ORDER BY
    unit_name,
    year,
    month;
GO


-- 
-- QUERY 4: Intercompany Reconciliation Check
-- Business Need: Verify all intercompany transactions
--               balance before monthly books are closed
-- Anomaly Caught: 3 months of mismatched amounts between
--                North and East Division
-- 

SELECT
    fact_intercompany.transaction_id,
    fact_intercompany.fiscal_period,

    sending_unit.unit_name      AS sending_division,
    receiving_unit.unit_name    AS receiving_division,

    fact_intercompany.amount_sent,
    fact_intercompany.amount_received,
    fact_intercompany.variance,
    fact_intercompany.status,

    CASE
        WHEN fact_intercompany.variance = 0
            THEN 'CLEAR'
        WHEN ABS(fact_intercompany.variance) < 0.5
            THEN 'LOW RISK'
        WHEN ABS(fact_intercompany.variance) BETWEEN 0.5 AND 1.0
            THEN 'MEDIUM RISK'
        ELSE
            'HIGH RISK'
    END AS risk_level,

    fact_intercompany.description

FROM fact_intercompany
JOIN dim_business_unit AS sending_unit
    ON fact_intercompany.sending_unit_id   = sending_unit.unit_id
JOIN dim_business_unit AS receiving_unit
    ON fact_intercompany.receiving_unit_id = receiving_unit.unit_id

ORDER BY
    fact_intercompany.status DESC,
    ABS(fact_intercompany.variance) DESC,
    fact_intercompany.fiscal_period;
GO

-- 
-- QUERY 5: Statistical Anomaly Detection
-- Business Need: Automatically identify transactions
--               outside normal statistical range using
--               2 standard deviation rule — same methodology
--               used in forensic accounting and fraud detection
-- Anomaly Caught: All 4 planted anomalies detected
--                automatically without manual intervention
-- 

WITH daily_amounts AS (
    SELECT
        dim_business_unit.unit_name,
        dim_account.account_name,
        dim_date.fiscal_period,
        fact_financials.date_id,
        SUM(fact_financials.amount) AS daily_amount

    FROM fact_financials
    JOIN dim_business_unit
        ON fact_financials.business_unit_id = dim_business_unit.unit_id
    JOIN dim_account
        ON fact_financials.account_id = dim_account.account_id
    JOIN dim_date
        ON fact_financials.date_id = dim_date.date_id

    WHERE fact_financials.scenario_id = 1

    GROUP BY
        dim_business_unit.unit_name,
        dim_account.account_name,
        dim_date.fiscal_period,
        fact_financials.date_id
),

stats AS (
    SELECT
        unit_name,
        account_name,
        AVG(daily_amount)   AS mean_amount,
        STDEV(daily_amount) AS std_amount
    FROM daily_amounts
    GROUP BY
        unit_name,
        account_name
)

SELECT
    daily_amounts.unit_name,
    daily_amounts.account_name,
    daily_amounts.fiscal_period,
    ROUND(daily_amounts.daily_amount, 2)    AS daily_amount,
    ROUND(stats.mean_amount, 2)             AS mean_amount,
    ROUND(stats.std_amount, 2)              AS std_deviation,

    ROUND(
        ABS(daily_amounts.daily_amount - stats.mean_amount) /
        NULLIF(stats.std_amount, 0)
    , 2) AS std_deviations_from_mean,

    CASE
        WHEN ABS(daily_amounts.daily_amount - stats.mean_amount) >
             2 * NULLIF(stats.std_amount, 0)
        THEN 'ANOMALY DETECTED'
        ELSE 'NORMAL'
    END AS anomaly_flag

FROM daily_amounts
JOIN stats
    ON  daily_amounts.unit_name    = stats.unit_name
    AND daily_amounts.account_name = stats.account_name

WHERE
    ABS(daily_amounts.daily_amount - stats.mean_amount) >
    2 * NULLIF(stats.std_amount, 0)

ORDER BY
    std_deviations_from_mean DESC;
GO


-- 
-- QUERY 6: Missing Accrual Detection
-- Business Need: Catch month end close errors where accounts
--               that normally post show zero for a period
--               Must be resolved before books are closed
-- Anomaly Caught: East Division December 2023 depreciation
--                posted as zero — missing accrual entry
-- 

WITH monthly_totals AS (
    SELECT
        dim_business_unit.unit_name,
        dim_account.account_name,
        dim_account.account_type,
        dim_date.fiscal_period,
        dim_date.year,
        dim_date.month,
        SUM(ABS(fact_financials.amount)) AS total_amount

    FROM fact_financials
    JOIN dim_business_unit
        ON fact_financials.business_unit_id = dim_business_unit.unit_id
    JOIN dim_account
        ON fact_financials.account_id = dim_account.account_id
    JOIN dim_date
        ON fact_financials.date_id = dim_date.date_id

    WHERE fact_financials.scenario_id = 1

    GROUP BY
        dim_business_unit.unit_name,
        dim_account.account_name,
        dim_account.account_type,
        dim_date.fiscal_period,
        dim_date.year,
        dim_date.month
),

account_averages AS (
    SELECT
        unit_name,
        account_name,
        AVG(total_amount) AS avg_monthly_amount
    FROM monthly_totals
    WHERE total_amount > 0
    GROUP BY
        unit_name,
        account_name
)

SELECT
    monthly_totals.unit_name,
    monthly_totals.account_name,
    monthly_totals.fiscal_period,
    monthly_totals.total_amount             AS posted_amount,
    ROUND(account_averages.avg_monthly_amount, 2)
                                            AS expected_amount,
    'MISSING ACCRUAL'                       AS flag,
    'Account normally posts ' +
    CAST(ROUND(account_averages.avg_monthly_amount, 0)
        AS VARCHAR) +
    ' but shows zero this period — investigate immediately'
                                            AS recommendation

FROM monthly_totals
JOIN account_averages
    ON  monthly_totals.unit_name    = account_averages.unit_name
    AND monthly_totals.account_name = account_averages.account_name

WHERE
    monthly_totals.total_amount = 0
    AND account_averages.avg_monthly_amount > 0

ORDER BY
    account_averages.avg_monthly_amount DESC;
GO

