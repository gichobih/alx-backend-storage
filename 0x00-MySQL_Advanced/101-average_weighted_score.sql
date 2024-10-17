-- 101-average_weighted_score.sql

DELIMITER //

DROP PROCEDURE IF EXISTS ComputeAverageWeightedScoreForUsers;
CREATE PROCEDURE ComputeAverageWeightedScoreForUsers()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE current_user_id INT;

    -- Declare cursor to loop through all user ids
    DECLARE cur CURSOR FOR SELECT id FROM users;
    -- Handler for when the cursor has no more rows
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Open the cursor
    OPEN cur;

    read_loop: LOOP
        -- Fetch the next user id
        FETCH cur INTO current_user_id;

        -- Exit the loop if there are no more rows
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Update the average weighted score for the current user
        UPDATE users
        SET average_score = (
            SELECT IFNULL(SUM(c.score * p.weight) / SUM(p.weight), 0)
            FROM corrections c
            JOIN projects p ON c.project_id = p.id
            WHERE c.user_id = current_user_id
        )
        WHERE id = current_user_id;

    END LOOP;

    -- Close the cursor
    CLOSE cur;
END //

DELIMITER ;
