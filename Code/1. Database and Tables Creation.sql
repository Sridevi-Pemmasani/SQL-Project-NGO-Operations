/**Create Database and tables for the NGO database**/
CREATE DATABASE ngooperations;
USE ngooperations;

-- Creating StaffRole table 
CREATE TABLE StaffRole (
    RoleID INT AUTO_INCREMENT PRIMARY KEY,
    RoleName VARCHAR(50) UNIQUE NOT NULL,
    Description VARCHAR(255)
);

-- Creating Staff table 
CREATE TABLE Staff (
    StaffID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    RoleID INT,
    Email VARCHAR(100) UNIQUE NOT NULL,
    PhoneNumber VARCHAR(15),
    HireDate DATE,
    FOREIGN KEY (RoleID) REFERENCES StaffRole(RoleID) ON DELETE SET NULL
);

-- Creating Volunteers table 
CREATE TABLE Volunteers (
    VolunteerID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    PhoneNumber VARCHAR(15),
    Availability ENUM('Yes', 'No') NOT NULL DEFAULT 'No',
    JoinDate DATE
);

-- Creating Donors table
CREATE TABLE Donors (
    DonorID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    PhoneNumber VARCHAR(15),
    Address TEXT
);

-- Creating Beneficiaries table
CREATE TABLE Beneficiaries (
    BeneficiaryID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
	DOB DATE,
	Gender ENUM('Male', 'Female','Other') NOT NULL,
	IncomeLevel ENUM('Low', 'Medium', 'High'),
	FamilySize INT CHECK (FamilySize >= 0),
	Address TEXT
);

-- Creating Projects table
CREATE TABLE Projects (
    ProjectID INT PRIMARY KEY AUTO_INCREMENT,
    ProjectName VARCHAR(100) NOT NULL,
    ProjectDescription VARCHAR(255),
    StartDate DATE,
    EndDate DATE,
    Budget DECIMAL(15, 2) CHECK (Budget >= 0),
    Status ENUM('Planned', 'On-Going', 'Completed','Cancelled','Paused') NOT NULL,
    CHECK (StartDate IS NULL OR EndDate IS NULL OR StartDate <= EndDate)
);

-- Creating ProjectActivities table
CREATE TABLE ProjectActivities (
    ActivityID INT PRIMARY KEY AUTO_INCREMENT,
    ProjectID INT,
    ActivityName VARCHAR(100) NOT NULL,
    ActivityDescription VARCHAR(255),
   FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID) ON DELETE SET NULL,
   INDEX projectactivities_project_idx (ProjectID)
);

-- Creating StaffProjects table
CREATE TABLE StaffProjects (
    StaffID INT,
    ProjectID INT,
    FromDate DATE NOT NULL,
    ToDate DATE,
    PRIMARY KEY (StaffID,ProjectID,FromDate),
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID) ON DELETE CASCADE,
	FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID) ON DELETE CASCADE,
	CHECK (ToDate IS NULL OR FromDate <= ToDate)
);

-- Creating Expenses table
CREATE TABLE Expenses (
    ExpenseID INT PRIMARY KEY AUTO_INCREMENT,
    ExpenseDescription VARCHAR(255) NOT NULL,
    Amount DECIMAL(10, 2) CHECK (Amount >= 0),
    ExpenseDate DATE,
	ProjectID INT NOT NULL,
    FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID) ON DELETE CASCADE,
	INDEX expenses_project_idx (ProjectID)
);

-- Creating VolunteerHours table
CREATE TABLE VolunteerHours (
    VolunteerID INT,
    ActivityID INT,
    WorkDate DATE NOT NULL,
    HoursWorked INT CHECK (HoursWorked BETWEEN 0 AND 8),
    PRIMARY KEY (VolunteerID,ActivityID,WorkDate),
    FOREIGN KEY (VolunteerID) REFERENCES Volunteers(VolunteerID) ON DELETE CASCADE,
    FOREIGN KEY (ActivityID) REFERENCES ProjectActivities(ActivityID) ON DELETE CASCADE,
    INDEX volunteerhours_volunteer_idx (VolunteerID),
    INDEX volunteerhours_projectactivities_idx (ActivityID),
    INDEX volunteerhours_volunteer_projectactivities_idx (VolunteerID, ActivityID)
);

-- Creating Donations table
CREATE TABLE Donations (
    DonationID INT PRIMARY KEY AUTO_INCREMENT,
    DonorID INT,
    DonationAmount DECIMAL(10, 2) CHECK (DonationAmount >= 0),
    DonationDate DATE NOT NULL,
    ProjectID INT,
    FOREIGN KEY (DonorID) REFERENCES Donors(DonorID) ON DELETE CASCADE,
    FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID) ON DELETE SET NULL,
    INDEX donations_donor_idx (DonorID),
    INDEX donations_project_idx (ProjectID),
    INDEX Donations_donor_project_idx (DonorID, ProjectID)	
);

-- Creating Beneficiaries_Feedback table
CREATE TABLE Beneficiaries_Feedback (
    BeneficiaryID INT,
    ProjectID INT,
    FeedbackDate DATE NOT NULL,
    Feedback VARCHAR(255),
    PRIMARY KEY (BeneficiaryID,ProjectID,FeedbackDate),
    FOREIGN KEY (BeneficiaryID) REFERENCES Beneficiaries(BeneficiaryID) ON DELETE CASCADE,
    FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID) ON DELETE CASCADE,
    INDEX feedback_beneficiary_idx (BeneficiaryID),
    INDEX feedback_project_idx (ProjectID),
    INDEX beneficiaries_feedback_beneficiary_project_idx (BeneficiaryID,ProjectID)
);