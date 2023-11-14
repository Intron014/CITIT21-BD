DELIMITER $$
CREATE PROCEDURE getRacesInAYear (IN search_year INT)
    BEGIN
        SELECT races.name, COUNT(constructorId)
        FROM races
        JOIN results ON races.raceId = results.raceId
        WHERE races.year = search_year
        GROUP BY (races.raceId);
    END $$

DROP PROCEDURE getRacesInAYear;
##
DELIMITER $$
CREATE PROCEDURE getOnRaceMessages(IN error_code VARCHAR(3), OUT error_messa VARCHAR(255))
    BEGIN
        CASE error_code
            WHEN 'E01' THEN SET error_messa = 'SALSA1';
            WHEN 'E02' THEN SET error_messa = 'SALSA2';
            WHEN 'E03' THEN SET error_messa = 'SALSA3';
            ELSE SET error_messa = 'SALSA4';
        END CASE;
    END $$
DELIMITER ;

SET @error_message = '';
CALL getOnRaceMessages('E01', @error_message);
SELECT @error_message;

DROP PROCEDURE getOnRaceMessages;
##
DELIMITER $$
CREATE PROCEDURE getDriversWithNacionality(IN search_nacionality VARCHAR(255))
    BEGIN
        SELECT forename, surname
        FROM drivers
        WHERE nationality = search_nacionality;
    END $$
DELIMITER ;

SET @nacionality = 'German';
CALL getDriversWithNacionality(@nacionality);
SELECT @nacionality;

DROP PROCEDURE getDriversWithNacionality;
##
DELIMITER $$
CREATE PROCEDURE getChampionScore(IN search_year INT, OUT champion_score INT)
    BEGIN
        SELECT MAX(t.sumPoints) INTO champion_score
        FROM (SELECT SUM(points) AS sumPoints
            FROM results
                JOIN formula1.races on races.raceId = results.raceId
                WHERE races.year = search_year
                GROUP BY results.driverId) as t;
    END $$
DELIMITER ;

SET @champion_score = '';
SET @search_year = 2004;
CALL getChampionScore(@search_year, @champion_score);
SELECT @champion_score;

DROP PROCEDURE getChampionScore;
##
