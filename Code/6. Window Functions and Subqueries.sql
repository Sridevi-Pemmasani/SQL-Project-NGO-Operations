/* Window Functions and Subqueries */
-- Q39: Assign a row number to each project based on StartDate.
SELECT 
ProjectID, 
ProjectName, 
       ROW_NUMBER() OVER (ORDER BY StartDate) AS RowNum 
FROM projects;

-- Q40: Rank beneficiaries by their DOB.
SELECT 
	BeneficiaryID, 
	CONCAT(FirstName," ", LastName) as Name, 
	DOB, 
	RANK() OVER (ORDER BY DOB ASC) AS BeneficiaryRank 
FROM beneficiaries;

-- Q41: Use a subquery to find the project with the highest budget
SELECT *
FROM
    projects
WHERE
    Budget = 
    (SELECT 
	MAX(Budget)
	FROM
	projects);

-- Q42: Partition expenses by ProjectID and calculate their sum
SELECT 
	ProjectID, 
	ExpenseID, 
	SUM(Amount) OVER (PARTITION BY ProjectID) AS TotalExpense 
FROM expenses;

/* DESCRIBE */
-- Q43: Use DESCRIBE to show the structure of the beneficiaries table.
DESCRIBE beneficiaries;


/* Summary Statistics */
SELECT 
    MAX(DonationAmount) - MIN(DonationAmount) AS DonationRange
FROM
    donations;

-- Q45: Find the standard deviation of project budgets.
SELECT 
    STDDEV(Budget) AS StdDevBudget
FROM
    projects;

-- Q46: Calculate the variance of hours worked by volunteers.
SELECT 
    VARIANCE(HoursWorked) AS VarianceHours
FROM
    volunteerhours;

/* Date Functions */
SELECT 
    VolunteerID,
    EXTRACT(MONTH FROM JoinDate) AS JoinMonth,
    EXTRACT(YEAR FROM JoinDate) AS JoinYear
FROM
    volunteers;

SELECT 
    VolunteerID,
    MONTHNAME(JoinDate) AS JoinInMonth,
    DAYNAME(JoinDate) AS JoinedON
FROM
    volunteers;

-- Q48: Find all projects that started in the year 2022.
SELECT *
FROM
    projects
WHERE
    YEAR(StartDate) = 2022;

/* Multiple Joins */
SELECT 
    S.StaffID,
    CONCAT(S.FirstName, ' ', S.LastName) AS Name,
    P.ProjectName,
    PA.ActivityName
FROM
    staff S
        JOIN
    staffprojects sp ON S.StaffID = SP.StaffID
        JOIN
    projects P ON SP.ProjectID = P.ProjectID
        JOIN
    projectactivities PA ON P.ProjectID = PA.ProjectID
ORDER BY S.StaffID;

/* CTE */
-- Q50: Create a CTE to calculate the total budget for each project and fetch projects where the total exceeds $100,000.
WITH TotalBudget AS (
    SELECT 
		ProjectID, 
		SUM(Budget) AS TotalBudget 
    FROM projects 
    GROUP BY ProjectID
)
SELECT * FROM TotalBudget WHERE TotalBudget > 100000;

-- Q51: Find the top 3 donors for each project by donation amount
SELECT * 
FROM
(
SELECT 
    P.ProjectID, 
    P.ProjectName, 
    D.DonorID, 
    CONCAT(D.FirstName, " ", D.LastName) as DonarName, 
    DN.DonationAmount, 
    RANK() OVER (PARTITION BY P.ProjectID ORDER BY DN.DonationAmount DESC) AS DonarRank
FROM 
    projects P
JOIN 
    donations DN ON P.ProjectID = DN.ProjectID
JOIN 
    donors D ON DN.DonorID = D.DonorID
    GROUP BY P.ProjectID,P.ProjectName, D.DonorID, DonarName,DN.DonationAmount
  
)  As DonarRankData
WHERE DonarRankData.DonarRank IN (1,2,3);
    
-- Q52: Calculate the cumulative total of donations received by each project
SELECT 
    P.ProjectID, 
    P.ProjectName, 
    D.DonationAmount, 
    SUM(D.DonationAmount) OVER (PARTITION BY P.ProjectID ORDER BY D.DonationDate) AS CumulativeDonations
FROM 
    projects P
JOIN 
    donations D ON P.ProjectID = D.ProjectID;

-- Q53: Identify the most active volunteers based on total hours worked
SELECT 
    V.VolunteerID, 
    CONCAT(V.FirstName, " ", V.LastName) as VolunteerName,
    SUM(VH.HoursWorked) AS TotalHours,
    RANK() OVER (ORDER BY SUM(VH.HoursWorked) DESC) AS VolunteerRank
FROM 
    volunteers V
JOIN 
    volunteerhours VH ON V.VolunteerID = VH.VolunteerID
GROUP BY 
    V.VolunteerID, VolunteerName;

-- Q54: Find the projects with the highest number of volunteers
SELECT 
    P.ProjectID,
    P.ProjectName,
    COUNT(DISTINCT VH.VolunteerID) AS VolunteerCount
FROM
    projects P
        JOIN
    projectactivities PA ON P.ProjectID = PA.ProjectID
        JOIN
    volunteerhours VH ON PA.ActivityID = VH.ActivityID
GROUP BY P.ProjectID , P.ProjectName
ORDER BY VolunteerCount DESC;

-- Q55: Calculate the average donation amount for each donor and their rank within all donors
SELECT 
    D.DonorID, 
    CONCAT(D.FirstName, " ", D.LastName) AS DonarName, 
    AVG(DN.DonationAmount) AS AvgDonationAmount,
    RANK() OVER (ORDER BY AVG(DN.DonationAmount) DESC) AS DonorRank
FROM 
    donors D
JOIN 
    donations DN ON D.DonorID = DN.DonorID
GROUP BY 
    D.DonorID, DonarName;

-- Q56: Determine the average hours worked per volunteer per project
SELECT 
    P.ProjectID,
    P.ProjectName,
    V.VolunteerID,
    CONCAT(V.FirstName, ' ', V.LastName) AS VolunteerName,
    AVG(VH.HoursWorked) AS AvgHours
FROM
    projects P
        JOIN
    projectactivities PA ON P.ProjectID = PA.ProjectID
        JOIN
    volunteerhours VH ON PA.ActivityID = VH.ActivityID
        JOIN
    volunteers V ON VH.VolunteerID = V.VolunteerID
GROUP BY P.ProjectID , P.ProjectName , V.VolunteerID , VolunteerName;
    

-- Q57: Identify projects with expenses exceeding 50% of their budget
SELECT 
    P.ProjectID,
    P.ProjectName,
    P.Budget,
    SUM(E.Amount) AS TotalExpenses,
    CASE
        WHEN SUM(E.Amount) > (P.Budget * 0.5) THEN 'Exceeds 50%'
        ELSE 'Within Budget'
    END AS BudgetStatus
FROM
    projects P
        JOIN
    expenses E ON P.ProjectID = E.ProjectID
GROUP BY P.ProjectID , P.ProjectName , P.Budget;

-- Q58: Find the percentage of total donations each donor contributed
SELECT 
    D.DonorID,
    D.FirstName,
    D.LastName,
    SUM(DN.DonationAmount) AS TotalDonations,
    ROUND(SUM(DN.DonationAmount) * 100.0 / (SELECT 
                    SUM(DonationAmount)
                FROM
                    donations),
            2) AS PercentageOfTotal
FROM
    donors D
        JOIN
    donations DN ON D.DonorID = DN.DonorID
GROUP BY D.DonorID , D.FirstName , D.LastName;

-- Q59: Find the gap between consecutive donation amounts for each donor
SELECT 
    D.DonorID, 
    D.FirstName, 
    D.LastName, 
    DN.DonationAmount, 
    LEAD(DN.DonationAmount) OVER (PARTITION BY D.DonorID ORDER BY DN.DonationDate) - DN.DonationAmount AS DonationGap
FROM 
    donors D
JOIN 
    donations DN ON D.DonorID = DN.DonorID;

-- Q60: Calculate the time spent by each volunteer in their longest activity
SELECT 
    V.VolunteerID,
    V.FirstName,
    V.LastName,
    PA.ActivityName,
    MAX(VH.HoursWorked) AS MaxHours
FROM
    volunteers V
        JOIN
    volunteerhours VH ON V.VolunteerID = VH.VolunteerID
        JOIN
    projectactivities PA ON VH.ActivityID = PA.ActivityID
GROUP BY V.VolunteerID , V.FirstName , V.LastName , PA.ActivityName;