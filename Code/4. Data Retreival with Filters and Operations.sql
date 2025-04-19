/* Basic Data Retrieval Statements (DQL) */
-- Q1: Retrieve all data from Staff
SELECT * FROM staff;

-- Q2:  Retrieve all projects with their ProjectName and Budget.
SELECT 
    ProjectName, 
    Budget
FROM
    projects;

-- Q3: Fetch the FirstName, LastName, and Email of volunteers. 
SELECT 
    FirstName, 
    LastName, 
    Email
FROM
    volunteers;

/* WHERE QUERIES */
SELECT *
FROM
    staff
WHERE
    HireDate > '2023-01-01';

-- Q5: Retrieve projects where the budget exceeds $100,000.
SELECT *
FROM
    projects
WHERE
    Budget > 100000;

-- Q6: Find all donors who donated more than $1,000.   
SELECT *
FROM
    donations
WHERE
    DonationAmount > 4000;

/* LIMIT QUERIES */
SELECT *
FROM
    projects
ORDER BY StartDate ASC
LIMIT 5;

-- Q8: Retrieve the top 10 donors by DonationAmount.
SELECT *
FROM
    donations
ORDER BY DonationAmount DESC
LIMIT 10;

/* Arithmetic Operations */
SELECT 
    SUM(Budget) AS TotalBudget
FROM
    projects;

-- Q10: Find the average donation per donor.
SELECT 
    AVG(DonationAmount) AS AvgDonation
FROM
    donations;

-- Q11: Increase all DonationAmount by 10% and display the new values.
SELECT 
    DonationID,
    DonationAmount AS existingDonation,
    DonationAmount * 1.10 AS UpdatedDonation
FROM
    donations;

/* Logical Operations */
SELECT *
FROM
    staff
WHERE
    HireDate > '2019-01-01' AND RoleID = 2;
 
-- Q13: List volunteers who are available and joined before 2022.
SELECT *
FROM
    volunteers
WHERE
    Availability = 'Yes'
	AND JoinDate < '2022-01-01';

/* Inline Functions */
SELECT 
    UPPER(ProjectName) AS UpperProjectName
FROM
    projects;

-- Q15: Concatenate the FirstName and LastName of beneficiaries into a full name.
SELECT 
    CONCAT(FirstName, ' ', LastName) AS FullName
FROM
    beneficiaries;

/* IN Clause */
SELECT *
FROM
    projects
WHERE
    ProjectID IN (1 , 3, 5);

-- Q17: List staff who belong to RoleID 1 or 2.
SELECT *
FROM
    staff
WHERE
    RoleID IN (1 , 2);

/* LIKE Clause */
SELECT *
FROM
    beneficiaries
WHERE
    FirstName LIKE 'A%';

-- Q19: Find projects with ProjectName containing the word "Health".
SELECT *
FROM
    projects
WHERE
    ProjectName LIKE '%Health%';

/* CASE Statement */
SELECT 
    DonorID,
    DonationAmount,
    CASE
        WHEN DonationAmount > 500 THEN 'More than $1000'
        ELSE 'Less than $500'
    END AS DonationCategory
FROM
    donations;

-- Q21: Categorize projects as 'Active' or 'Completed' based on their EndDate.
SELECT 
    ProjectID,
    ProjectName,
    CASE
        WHEN
            EndDate IS NULL
                OR EndDate > CURRENT_DATE
        THEN
            'Active'
        ELSE 'Completed'
    END AS Status
FROM
    projects;

/* CASE Statement */
SELECT 
    S.StaffID, 
    S.FirstName, 
    R.RoleName
FROM
    staff S
	INNER JOIN
    staffrole R ON S.RoleID = R.RoleID
ORDER BY S.StaffID;

-- Q23: List all volunteers and their total hours worked using a LEFT JOIN.
SELECT 
    V.VolunteerID, 
    V.FirstName, 
    SUM(VH.HoursWorked) AS TotalHours
FROM
    volunteers V
	LEFT JOIN
    volunteerhours VH ON V.VolunteerID = VH.VolunteerID
GROUP BY V.VolunteerID , V.FirstName;

-- Q24: Fetch all projects and their corresponding expenses using a RIGHT JOIN.
SELECT 
    P.ProjectID, 
    P.ProjectName, 
    E.Amount as ExpenseAmount
FROM
    projects P
        RIGHT JOIN
    expenses E ON P.ProjectID = E.ProjectID;

-- Q25: Display all project activities along with their volunteers
SELECT 
   PA.ActivityID,
   PA.ActivityName,
   CONCAT(V.FirstName, ' ', V.LastName) AS VolunteerName,
   VH.WorkDate
FROM
    projectactivities PA
        JOIN
    volunteerhours VH ON PA.ActivityID = VH.ActivityID
        JOIN
    volunteers V ON VH.VolunteerID = V.VolunteerID;