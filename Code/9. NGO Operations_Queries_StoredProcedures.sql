/* NGO Operations Stored Procedures */
-- Stored Procedure #1: To Add a New Donation
DELIMITER //

CREATE PROCEDURE AddDonation(
    IN donorID INT, 
    IN projectID INT, 
    IN donationAmount DECIMAL(10,2), 
    IN donationDate DATE
)
BEGIN
    INSERT INTO donations (DonorID, ProjectID, DonationAmount, DonationDate)
    VALUES (donorID, projectID, donationAmount, donationDate);
END //

DELIMITER ;

-- Call Stored Procedure #1 to add a New Donation
CALL AddDonation(1,2,1500,'2024-12-01')

-- Stored Procedure #2: To Update a Project Budget
DELIMITER //

CREATE PROCEDURE UpdateProjectBudget(
    IN projectID INT, 
    IN newBudget DECIMAL(15,2)
)
BEGIN
    UPDATE projects P
    SET Budget = newBudget
    WHERE P.ProjectID = projectID;
END //
DELIMITER ;

-- Call SP to update the budget
CALL UpdateProjectBudget(4,200000)

-- Stored Procedure #3: To Get Project Details with Donor Information

DELIMITER //

CREATE PROCEDURE GetProjectDonorDetails(IN projectID INT)
BEGIN
    SELECT 
        P.ProjectName, 
        D.FirstName AS DonorFirstName, 
        D.LastName AS DonorLastName, 
        DN.DonationAmount, 
        DN.DonationDate
    FROM 
        projects P
    JOIN 
        donations DN ON P.ProjectID = DN.ProjectID
    JOIN 
        donors D ON DN.DonorID = D.DonorID
    WHERE 
        P.ProjectID = projectID;
END //

DELIMITER ;

-- Call SP to retrive project donars for 1 
CALL GetProjectDonorDetails(1);

-- Stored Procedure #4: To Delete a Beneficiary Feedback Entry

DELIMITER //

CREATE PROCEDURE DeleteBeneficiaryFeedback(
    IN beneficiaryid INT,
    IN projectid INT
)
BEGIN
    DELETE FROM beneficiaries_feedback BFB
    WHERE BFB.BeneficiaryID = beneficiaryid AND BFB.ProjectID = projectid;
END //

DELIMITER ;

-- Call SP to delete a Beneficiary Feedback Entry
CALL DeleteBeneficiaryFeedback(597,6);

-- Stored Procedure #5: To Generate Volunteer Summary
DELIMITER //

CREATE PROCEDURE GetVolunteerSummary()
BEGIN
    SELECT 
        V.VolunteerID, 
        V.FirstName, 
        V.LastName, 
        COUNT(VH.WorkDate) AS TotalDaysWorked, 
        SUM(VH.HoursWorked) AS TotalHoursWorked
    FROM 
        volunteers V
    LEFT JOIN 
        volunteerhours VH ON V.VolunteerID = VH.VolunteerID
    GROUP BY 
        V.VolunteerID, V.FirstName, V.LastName;
END //

DELIMITER ;

-- Call SP to retrive Volunteer Summary
CALL GetVolunteerSummary;