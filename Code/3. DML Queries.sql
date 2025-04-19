/* DML Statements */
-- Q28:Insert a new staff record.
INSERT INTO staff (FirstName, LastName, Email, PhoneNumber, HireDate, RoleID) 
VALUES ('Sridevi', 'Pemmasani', 'sridevi.pemmasani@examplengo.com', '1234567890', '2024-01-01', 1);

-- Q29: Update the Budget of a project with ProjectID = 103.
SELECT Budget from projects where ProjectID = 1;
UPDATE projects SET Budget = 200000 WHERE ProjectID = 1;

-- Q30: Delete a beneficiary with BeneficiaryID = 15.
DELETE FROM beneficiaries WHERE BeneficiaryID = 15;