##1
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
##2
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
##3
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
##4
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
##5
DELIMITER $$
CREATE FUNCTION mediaPuntosConstructorYear(constructorName VARCHAR(40))
RETURNS DECIMAL(10,2)
BEGIN
    DECLARE output DECIMAL(10,2);
    SELECT AVG(t.sum_points) INTO output
    FROM (
        SELECT SUM(results.points) as sum_points
        FROM results
        JOIN formula1.races on races.raceId = results.raceId
        JOIN formula1.constructors on results.constructorId = constructors.constructorId
        WHERE constructors.name = constructorName
        GROUP BY races.year
        ) as t;
    RETURN (output);
END $$
DELIMITER ;

DROP FUNCTION mediaPuntosConstructorYear;
##6
DELIMITER $$
CREATE FUNCTION yearsOnActive(driverIdent VARCHAR(5))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE output INT;
    SELECT COUNT(DISTINCT races.year) INTO output
        FROM races
            JOIN formula1.results on races.raceId = results.raceId
        WHERE results.driverId = driverIdent;
    RETURN (output);
end $$
DELIMITER ;

SET @driverIdent = 20;
SELECT yearsOnActive(@driverIdent);

DROP FUNCTION yearsOnActive;
##7
ALTER TABLE drivers ADD COLUMN yearsActive INTEGER NULL;
DELIMITER $$
CREATE PROCEDURE updateYearsActive()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE id_cursor INT;
    DECLARE cur CURSOR FOR SELECT driverId FROM drivers;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO id_cursor;
        IF done THEN
            LEAVE read_loop;
        END IF;
        UPDATE drivers
            SET yearsActive = yearsOnActive(id_cursor)
            WHERE driverId = id_cursor;
    END LOOP;
    CLOSE cur;
end $$
DELIMITER ;

CALL updateYearsActive();

DROP PROCEDURE updateYearsActive;
##8
DELIMITER $$
CREATE TRIGGER checkDriversPerConstructorPerRace BEFORE INSERT ON results
FOR EACH ROW
BEGIN
    DECLARE numDrivers INTEGER;
    SELECT COUNT(DISTINCT driverId) INTO numDrivers
        FROM results
        JOIN formula1.races on results.raceId = races.raceId
        WHERE constructorId = NEW.constructorId
          AND results.driverId = NEW.driverId
          AND races.year = (
            SELECT year
            FROM races
            WHERE races.raceId = NEW.raceId
            );
    IF numDrivers >= 2 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede añadir un tercer piloto a un equipo';
    END IF;
END $$

INSERT INTO results VALUES (237821501,42,2,4,99,1,0,50,1,1,8, 3, 2);

DROP TRIGGER checkDriversPerConstructorPerRace;
##9
CREATE TABLE crashes (
    crashID INT UNIQUE NOT NULL AUTO_INCREMENT,
    driverID INT NOT NULL,
    description VARCHAR(30) DEFAULT NULL,
    PRIMARY KEY (crashID),
    CONSTRAINT FOREIGN KEY (driverID) REFERENCES drivers(driverID));

DELIMITER $$
CREATE TRIGGER newCrash AFTER INSERT ON results
    FOR EACH ROW
    BEGIN
        IF NEW.statusId = 3 OR NEW.statusId = 4 THEN
            INSERT INTO crashes (driverId) VALUES (NEW.driverId);
        END IF;
    END $$
DELIMITER ;

DROP TRIGGER newCrash;
##11
DELIMITER $$
CREATE PROCEDURE sameCountryWins(IN search_year INT)
BEGIN
    SELECT drivers.forename, drivers.surname, circuits.name
        FROM drivers
        JOIN formula1.results on drivers.driverId = results.driverId
        JOIN formula1.races on races.raceId = results.raceId
        JOIN formula1.circuits on races.circuitId = circuits.circuitId
        JOIN formula1.constructors on results.constructorId = constructors.constructorId
        WHERE races.year = search_year AND results.positionOrder = 1 AND drivers.nationality = constructors.nationality;
END $$
DELIMITER ;

DROP PROCEDURE sameCountryWins;
##12
DELIMITER $$
CREATE PROCEDURE podiumInYear(IN search_year INT)
BEGIN
    select DISTINCT drivers.driverID, drivers.forename, drivers.surname
        FROM drivers
        JOIN formula1.results on drivers.driverId = results.driverId
        JOIN formula1.races on results.raceId = races.raceId
        WHERE positionOrder <=3 AND races.year = search_year
        GROUP BY drivers.driverId, year
        HAVING COUNT(DISTINCT positionOrder) = 3
        ORDER BY drivers.driverId;
END $$
DELIMITER ;

CALL podiumInYear(2008);
DROP PROCEDURE podiumInYear;
##13
DELIMITER $$
CREATE FUNCTION diffPoints(driverId1 INT, driverId2 INT)
RETURNS DECIMAL (10,2)
DETERMINISTIC
BEGIN
    DECLARE pd1 INT;
    DECLARE pd2 INT;
    SELECT SUM(points) INTO pd1
    FROM results
    WHERE driverId1 = driverId;
    SELECT SUM(points) INTO pd2
    FROM results
    WHERE driverId2 = driverId;

    RETURN (pd1-pd2);
end $$
DELIMITER ;

SELECT diffPoints(1, 2);
DROP FUNCTION diffPoints;
##14
CREATE TABLE sponsors (
    sponsorID INT UNIQUE NOT NULL AUTO_INCREMENT,
    name VARCHAR(30) NOT NULL,
    type VARCHAR(30),
    year INT NOT NULL,
    raceID INT NOT NULL,
    revenue DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (sponsorID),
    CONSTRAINT FOREIGN KEY (raceID) REFERENCES races(raceID));

DELIMITER $$
CREATE TRIGGER sponsorTypyfier BEFORE INSERT on sponsors
FOR EACH ROW
BEGIN
    IF NEW.revenue >= 5000000 THEN
        SET NEW.type = 'oficial';
    ELSE
        SET NEW.type = 'cooficial';
    END IF;
END $$
DELIMITER ;
DROP TRIGGER sponsorTypyfier;
INSERT INTO sponsors (name, year, raceID, revenue) VALUES ('UPM', 2004, 1, 54268119);