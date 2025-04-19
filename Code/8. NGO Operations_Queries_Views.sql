/* NGO Operations Views */

-- View #1: To get summarized donation details by projects
CREATE VIEW ProjectDonationsSummary AS
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
    P.ProjectID, P.ProjectName;
    
-- Extract the Project Donations Summary from the View
SELECT * FROM ProjectDonationsSummary;

-- View #2: To display volunteers and their total hours worked
CREATE VIEW VolunteerHoursSummary AS
SELECT 
    V.VolunteerID, 
    CONCAT(V.FirstName, " ", V.LastName) as VolunteerName, 
    SUM(VH.HoursWorked) AS TotalHoursWorked
FROM 
    volunteers V
LEFT JOIN 
    volunteerhours VH ON V.VolunteerID = VH.VolunteerID
GROUP BY 
    V.VolunteerID, VolunteerName;

-- Extract the Volunteer Hours Summary from the View
SELECT * FROM VolunteerHoursSummary;

-- View #3: To list beneficiaries and their feedback for projects
CREATE VIEW BeneficiaryFeedbackSummary AS
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
    projects P ON BF.ProjectID = P.ProjectID;

-- Extract the beneficiaries and their feedback for projects
SELECT * FROM BeneficiaryFeedbackSummary;

-- View #4: To show staff and their assigned projects
CREATE VIEW StaffProjectAssignment AS
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
    projects P ON SP.ProjectID = P.ProjectID;
	
    -- Extract staff and their assigned projects from View
	SELECT * FROM StaffProjectAssignment
