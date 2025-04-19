/* Aggregations */
-- Q33: Count the total number of projects.
SELECT COUNT(*) AS TotalProjects FROM projects;

-- Q34: Find the maximum donation amount.
SELECT MAX(DonationAmount) AS MaxDonation FROM donations;

-- Q35: Calculate the average Budget across all projects.
SELECT AVG(Budget) AS AvgBudget FROM projects;

-- Q36: Group projects by Status and count each group.
SELECT Status, COUNT(*) AS TotalProjects 
FROM projects 
GROUP BY Status;

-- Q37: Order beneficiaries by their IncomeLevel.
SELECT * FROM beneficiaries ORDER BY IncomeLevel ASC;

/* Filtering with HAVING */
-- Q38: Find projects with an average activity budget greater than $5,000.
SELECT 
ProjectID, 
ROUND(AVG(Budget),2) AS AvgActivityBudget
FROM projects
GROUP BY ProjectID
HAVING AVG(Budget) > 5000;