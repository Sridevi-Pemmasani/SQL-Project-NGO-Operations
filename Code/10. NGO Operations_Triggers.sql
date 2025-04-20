SELECT * FROM ngooperations.staff;
SELECT * FROM ngooperations.staffprojects;

DROP TRIGGER IF EXISTS Insert_newstaff;
DELIMITER $$
CREATE TRIGGER Insert_newstaff
	AFTER INSERT ON staff
    For EACH ROW
BEGIN 
INSERT INTO staffprojects (staffID,projectID,fromDate,toDate)
VALUES (NEW.staffID,1,NEW.hireDate,NULL);
END $$
DELIMITER ;

INSERT INTO staff (firstName,lastName,roleID,email,phoneNumber,hireDate)
VALUES ("Sridevi","Pemmasani",1,"sri@samplengo.com","1238915612","2024-12-01")