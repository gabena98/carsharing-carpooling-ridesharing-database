DROP PROCEDURE IF EXISTS scan_numero;
DELIMITER $$
CREATE PROCEDURE scan_numero(IN `curr_strada` char(50))
BEGIN
DECLARE finished integer(11) DEFAULT 0;

	DECLARE `curr_num` varchar(50);

	DECLARE scan CURSOR FOR
		SELECT `Numero`
		FROM `chilometro`;

	DECLARE CONTINUE HANDLER FOR NOT FOUND
	SET finished = 1;

	OPEN scan;
	scan : LOOP
		FETCH scan INTO `curr_num`;
		IF finished = 1 THEN
			LEAVE scan;
		END IF;

		CALL aggiorna_tempi_medi(`curr_strada`, `curr_num`);
	END LOOP;
	CLOSE scan;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS scan_strada;
DELIMITER $$
CREATE PROCEDURE scan_strada()
BEGIN
DECLARE finished integer(11) DEFAULT 0;

	DECLARE `curr_strada` varchar(50);

	DECLARE scan CURSOR FOR
		SELECT `IDSTrada`
		FROM `chilometro`;

	DECLARE CONTINUE HANDLER FOR NOT FOUND
	SET finished = 1;

	OPEN scan;
	scan : LOOP
		FETCH scan INTO `curr_strada`;
		IF finished = 1 THEN
			LEAVE scan;
		END IF;

		CALL scan_numero(`curr_strada`);
	END LOOP;
	CLOSE scan;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS aggiorna_tempi_medi;
DELIMITER $$
CREATE PROCEDURE aggiorna_tempi_medi(IN `IDSTrada` char(50), IN `Numero` int(11))
BEGIN
	DECLARE DiffTempi float(13, 2);
    DECLARE DiffSpazio float(18, 7);
    DECLARE TempoMedioSecondi int(11);
    
	SET DiffTempi = (SELECT AVG(time_to_sec(timediff(P2.`Timestamp`, P1.`Timestamp`)))
					FROM `posizione` P1 INNER JOIN `posizione` P2 ON P1.`CodiceTragitto` = P2.`CodiceTragitto`
                    WHERE P1.`Timestamp`< P2.`Timestamp` AND current_timestamp < DATE_ADD(P1.`Timestamp`, INTERVAL 1 HOUR) AND
						P2.`Numero` = P1.`Numero` + 1 AND 
						P1.`IDPosizione` IN(
											SELECT `IDPosizione`
                                            FROM `relativa` R
                                            WHERE R.`IDSTrada` = `IDSTrada` AND
												R.`Numero` = `Numero`
											) AND
						P2.`IDPosizione` IN(
											SELECT `IDPosizione`
                                            FROM `relativa` R
                                            WHERE R.`IDSTrada` = `IDSTrada` AND
												R.`Numero` = `Numero`
											)
                    );
                    
	SET DiffSpazio = (SELECT AVG(ACOS(SIN(P1.`Latitudine`*PI()/180)*SIN(P2.`Latitudine`*PI()/180) + COS(P1.`Latitudine`*PI()/180)*COS(P2.`Latitudine`*PI()/180)*COS(P2.`Longitudine`*PI()/180-P1.`Longitudine`*PI()/180))*6371)
					FROM `posizione` P1 INNER JOIN `posizione` P2 ON P1.`CodiceTragitto` = P2.`CodiceTragitto`
                    WHERE P1.`Timestamp`< P2.`Timestamp` AND current_timestamp < DATE_ADD(P1.`Timestamp`, INTERVAL 1 HOUR) AND
						P2.`Numero` = P1.`Numero` + 1 AND
						P1.`IDPosizione` IN(
											SELECT `IDPosizione`
                                            FROM `relativa` R
                                            WHERE R.`IDSTrada` = `IDSTrada` AND
												R.`Numero` = `Numero`
											) AND
						P2.`IDPosizione` IN(
											SELECT `IDPosizione`
                                            FROM `relativa` R
                                            WHERE R.`IDSTrada` = `IDSTrada` AND
												R.`Numero` = `Numero`
											)
                    );
        
        SET TempoMedioSecondi = 1/(DiffSpazio/DiffTempi);
		IF TempoMedioSecondi IS NOT NULL THEN
			UPDATE `chilometro` C
			SET C.`TempoMedio` = sec_to_time(TempoMedioSecondi)
			WHERE C.`IDStrada` = `IDSTrada` AND C.`Numero` = `Numero`;
        END IF;
        
END $$

DELIMITER ;

DROP EVENT IF EXISTS aggiorna_tempi_medi_percorrenza;
DELIMITER $$

CREATE EVENT aggiorna_tempi_medi_percorrenza
ON SCHEDULE EVERY 1 HOUR
DO
BEGIN
	CALL scan_strada();
END $$

DELIMITER ;
