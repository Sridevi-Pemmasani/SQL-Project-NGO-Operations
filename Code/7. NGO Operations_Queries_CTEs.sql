/* NGO Operations CTEs */

-- CTE1 #1: To get summarized donation details by projects - Which 5 projects have Minimum Average Donation
WITH ProjectDonationsSummary AS
(
SELECT 
    P.ProjectID, 
    P.ProjectName, 
    COUNT(D.DonationID) AS TotalDonations, 
    SUM(D.DonationAmount) AS TotalDonationAmount, 
    AVG(D.DonationAmount) AS AverageDonation
FROM 
    projects P
LEFT JOIN 
    donations D ON P.ProjectID = D.ProjectID
GROUP BY 
    P.ProjectID, P.ProjectName
),
MinAverageProject AS
(
SELECT * 
FROM 
ProjectDonationsSummary
ORDER BY AverageDonation
LIMIT 5
)
SELECT * FROM  MinAverageProject;

    
-- CTE #2: To display volunteers and their total hours worked in Descending order
WITH VolunteerHoursSummary AS
(
SELECT 
    V.VolunteerID, 
    CONCAT(V.FirstName, " ", V.LastName) as VolunteerName, 
    SUM(VH.HoursWorked) AS TotalHoursWorked
FROM 
    volunteers V
LEFT JOIN 
    volunteerhours VH ON V.VolunteerID = VH.VolunteerID
GROUP BY 
    V.VolunteerID, VolunteerName
)
SELECT * FROM VolunteerHoursSummary
ORDER BY TotalHoursWorked DESC;

-- CTE #3: To list beneficiaries and their feedback for projects - Show first 10 based on beneficiaryID
WITH BeneficiaryFeedbackSummary AS
(
SELECT 
    B.BeneficiaryID, 
    CONCAT(B.FirstName, " " , B.LastName) as BeneficiaryName, 
    P.ProjectName, 
    BF.FeedbackDate, 
    BF.Feedback
FROM 
    beneficiaries B
JOIN 
    beneficiaries_feedback BF ON B.BeneficiaryID = BF.BeneficiaryID
JOIN 
    projects P ON BF.ProjectID = P.ProjectID
)
SELECT * FROM BeneficiaryFeedbackSummary
ORDER BY BeneficiaryID
LIMIT 10;

-- CTE #4: To show staff and their assigned projects which has completed on 2023-06-30
WITH StaffProjectAssignment AS
(
SELECT 
    S.StaffID, 
    Concat(S.FirstName, " ", S.LastName) as StaffName, 
    P.ProjectName, 
    SP.FromDate, 
    SP.ToDate
FROM 
    staff S
JOIN 
    staffprojects SP ON S.StaffID = SP.StaffID
JOIN 
    projects P ON SP.ProjectID = P.ProjectID
)
SELECT * FROM StaffProjectAssignment
WHERE ToDate = '2023-06-30';
	
