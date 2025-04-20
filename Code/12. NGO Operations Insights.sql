/* Donor Retention & Contribution Trends Over Time */
/* Insight: Are donors coming back? Are donations growing? */
SELECT 
    dn.DonorID,
    CONCAT(FirstName, ' ', LastName) AS DonorName,
    YEAR(DonationDate) AS DonationYear,
    COUNT(DonationID) AS DonationCount,
    SUM(DonationAmount) AS TotalDonated
FROM donations d
JOIN donors dn ON d.DonorID = dn.DonorID
GROUP BY dn.DonorID, DonationYear
ORDER BY dn.DonorID, DonationYear;

--

/* Top Performing Projects by Impact - Define impact based on donations received + volunteer hours + feedback) */
/* Insight: Which projects are bringing in the most resources and engagement? */
WITH ProjectImpact AS (
    SELECT 
        p.ProjectID,
        p.ProjectName,
        COALESCE(SUM(d.DonationAmount), 0) AS TotalDonations,
        COALESCE(SUM(vh.HoursWorked), 0) AS TotalVolunteerHours,
        COUNT(DISTINCT bf.FeedbackDate) AS FeedbackCount
    FROM projects p
    LEFT JOIN donations d ON p.ProjectID = d.ProjectID
    LEFT JOIN projectactivities pa ON p.ProjectID = pa.ProjectID
    LEFT JOIN volunteerhours vh ON pa.ActivityID = vh.ActivityID
    LEFT JOIN beneficiaries_feedback bf ON p.ProjectID = bf.ProjectID
    GROUP BY p.ProjectID, p.ProjectName
)
SELECT *
FROM ProjectImpact
ORDER BY TotalDonations DESC, TotalVolunteerHours DESC;

--

/* Monthly Donation Trends */
/* Insight: Are donations seasonal? Helps with fundraising strategies. */
SELECT 
    DATE_FORMAT(DonationDate, '%Y-%m') AS Month,
    SUM(DonationAmount) AS TotalDonations
FROM donations
GROUP BY Month
ORDER BY Month;

--

/* Volunteer Workload Distribution */
/* Insight: Are some volunteers over/under-utilized? */
SELECT 
    v.VolunteerID,
    CONCAT(FirstName, ' ', LastName) AS VolunteerName,
    COUNT(DISTINCT ActivityID) AS ActivitiesInvolved,
    SUM(HoursWorked) AS TotalHours,
    AVG(HoursWorked) AS AvgHoursPerActivity
FROM volunteerhours vh
JOIN volunteers v ON vh.VolunteerID = v.VolunteerID
GROUP BY v.VolunteerID
ORDER BY TotalHours DESC;

--

/* Beneficiary Demographics & Feedback Summary */
/* Insight: Who are we serving, and who is providing feedback? */
SELECT 
    b.Gender,
    b.IncomeLevel,
    COUNT(DISTINCT b.BeneficiaryID) AS TotalBeneficiaries,
    COUNT(bf.FeedbackDate) AS FeedbackEntries
FROM beneficiaries b
LEFT JOIN beneficiaries_feedback bf ON b.BeneficiaryID = bf.BeneficiaryID
GROUP BY b.Gender, b.IncomeLevel
ORDER BY TotalBeneficiaries DESC;

--

/*
TotalActivities: total number of activities per project.
VolunteerCount: how many unique volunteers participated in each activity.
TotalHoursWorked: cumulative hours volunteers contributed per activity. 
*/

-- Step 1: Get volunteer and activity details
WITH ActivityDetails AS (
    SELECT 
        p.ProjectID,
        p.ProjectName,
        pa.ActivityID,
        pa.ActivityName,
        v.VolunteerID,
        CONCAT(v.FirstName, ' ', v.LastName) AS VolunteerName,
        vh.WorkDate,
        vh.HoursWorked
    FROM 
        projects p
    LEFT JOIN projectactivities pa ON p.ProjectID = pa.ProjectID
    LEFT JOIN volunteerhours vh ON pa.ActivityID = vh.ActivityID
    LEFT JOIN volunteers v ON vh.VolunteerID = v.VolunteerID
),

-- Step 2: Get count of unique activities per project
ProjectActivityCounts AS (
    SELECT 
        ProjectID,
        COUNT(DISTINCT ActivityID) AS TotalActivities
    FROM ActivityDetails
    GROUP BY ProjectID
),

-- Step 3: Aggregate activity-level volunteer stats
ActivityAggregates AS (
    SELECT
        ProjectID,
        ProjectName,
        ActivityID,
        ActivityName,
        COUNT(DISTINCT VolunteerID) AS VolunteerCount,
        SUM(HoursWorked) AS TotalHoursWorked
    FROM ActivityDetails
    GROUP BY ProjectID, ProjectName, ActivityID, ActivityName
)

-- Step 4: Combine everything
SELECT 
    aa.ProjectID,
    aa.ProjectName,
    aa.ActivityID,
    aa.ActivityName,
    pac.TotalActivities,
    aa.VolunteerCount,
    aa.TotalHoursWorked
FROM 
    ActivityAggregates aa
JOIN ProjectActivityCounts pac ON aa.ProjectID = pac.ProjectID
ORDER BY aa.ProjectID, aa.ActivityID;

--

/* 
Donor Engagement in Different Projects
Using a CTE with RANK() window function to find top contributing donors per project
This gives the top 3 donors for each project. 
*/

WITH DonorContributions AS (
    SELECT 
        d.DonorID,
        CONCAT(d.FirstName, ' ', d.LastName) AS DonorName,
        p.ProjectID,
        p.ProjectName,
        SUM(dn.DonationAmount) AS TotalDonated,
        RANK() OVER (PARTITION BY p.ProjectID ORDER BY SUM(dn.DonationAmount) DESC) AS DonorRank
    FROM 
        donors d
    JOIN donations dn ON d.DonorID = dn.DonorID
    JOIN projects p ON dn.ProjectID = p.ProjectID
    GROUP BY d.DonorID, p.ProjectID
)
SELECT * 
FROM DonorContributions
WHERE DonorRank <= 3
ORDER BY ProjectID, DonorRank;

--

/* Track Donations of Donors Against Different Projects
Track donation history using a CTE and ROW_NUMBER() to get the first and latest donation by each donor
*/

WITH DonationHistory AS (
    SELECT 
        d.DonorID,
        CONCAT(d.FirstName, ' ', d.LastName) AS DonorName,
        p.ProjectName,
        dn.DonationAmount,
        dn.DonationDate,
        ROW_NUMBER() OVER (PARTITION BY d.DonorID ORDER BY dn.DonationDate ASC) AS FirstDonation,
        ROW_NUMBER() OVER (PARTITION BY d.DonorID ORDER BY dn.DonationDate DESC) AS LatestDonation
    FROM 
        donors d
    JOIN donations dn ON d.DonorID = dn.DonorID
    JOIN projects p ON dn.ProjectID = p.ProjectID
)
SELECT * 
FROM DonationHistory 
WHERE FirstDonation = 1 OR LatestDonation = 1
ORDER BY DonorID, DonationDate;

--

/*
Rolling totals for:
Total hours worked over time per volunteer
Total hours worked per project per volunteer over time
*/
SELECT 
    v.VolunteerID,
    CONCAT(v.FirstName, ' ', v.LastName) AS VolunteerName,
    p.ProjectName,
    pa.ActivityName,
    vh.WorkDate,
    vh.HoursWorked,

    -- Rolling total for each volunteer
    SUM(vh.HoursWorked) OVER (
        PARTITION BY v.VolunteerID 
        ORDER BY vh.WorkDate 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS RollingTotalHoursPerVolunteer,

    -- Rolling total per project per volunteer
    SUM(vh.HoursWorked) OVER (
        PARTITION BY v.VolunteerID, p.ProjectID 
        ORDER BY vh.WorkDate 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS RollingHoursPerProject

FROM 
    volunteers v
JOIN volunteerhours vh ON v.VolunteerID = vh.VolunteerID
JOIN projectactivities pa ON vh.ActivityID = pa.ActivityID
JOIN projects p ON pa.ProjectID = p.ProjectID
ORDER BY v.VolunteerID, vh.WorkDate;

--

/* Beneficiary Feedback for Projects
Using DENSE_RANK() to identify most recent feedback per beneficiary across projects
*/
WITH FeedbackRanked AS (
    SELECT 
        b.BeneficiaryID,
        CONCAT(b.FirstName, ' ', b.LastName) AS BeneficiaryName,
        p.ProjectName,
        bf.Feedback,
        bf.FeedbackDate,
        DENSE_RANK() OVER (PARTITION BY b.BeneficiaryID ORDER BY bf.FeedbackDate DESC) AS FeedbackRank
    FROM 
        beneficiaries b
    JOIN beneficiaries_feedback bf ON b.BeneficiaryID = bf.BeneficiaryID
    JOIN projects p ON bf.ProjectID = p.ProjectID
)
SELECT * 
FROM FeedbackRanked
ORDER BY BeneficiaryID;

