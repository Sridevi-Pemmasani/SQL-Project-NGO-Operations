DELIMITER $$
CREATE EVENT updateProjectStatus
ON SCHEDULE EVERY 30 SECOND
DO
BEGIN
DECLARE pIDCOUNT INT DEFAULT 1;  -- Variable to check recound count
DECLARE done INT DEFAULT 0; 	-- Variable to signal the end of the cursor
DECLARE project_id INT;       	-- Variable to hold the current order ID

#1. Fetch project details
    DECLARE cur CURSOR FOR 			-- Cursor to iterate through pending orders
	SELECT projectID
	FROM ngooperations.projects 
	WHERE EndDate < curdate();
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;
# Fetch project redcord countthat matches criteria
	SELECT Count(*) INTO pIDCOUNT
	FROM ngooperations.projects 
	WHERE EndDate < curdate();

#2. Loop through project details to check any project EndDate approached or not
IF pIDCOUNT > 0 THEN
-- Open the cursor
   OPEN cur;
   read_loop: LOOP
		FETCH cur INTO project_id;
        IF done THEN
        LEAVE read_loop;
        END IF;
		UPDATE ngooperations.projects
		SET Status="Completed" 
		WHERE ProjectID = project_id;
    END LOOP;
    -- Close the cursor
   CLOSE cur;
  END IF;
  END $$
DELIMITER ;


/*
SHOW EVENTS;								# SHowing list of Events and their statuses

SET GLOBAL event_scheduler = ON; 			# Enabling Global Event Scheduler
SET GLOBAL event_scheduler = OFF;			# Disabling Global Event Scheduler

ALTER EVENT updateProjectStatus DISABLE;	# Alerting an individual event enable or disable
ALTER EVENT updateProjectStatus ENABLE;	# Alerting an individual event enable or disable
*/