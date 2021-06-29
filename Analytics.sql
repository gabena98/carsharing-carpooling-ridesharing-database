SET NAMES latin1;
USE `carsharing`;
SET FOREIGN_KEY_CHECKS = 1;
SET GLOBAL EVENT_SCHEDULER = ON;

DROP TABLE IF EXISTS `MV_Affidabilita`;
CREATE TABLE `MV_Affidabilita`(
	`CodFiscale` char(50) NOT NULL,
    `Affidabilita` float(13, 2) unsigned DEFAULT NULL,
    PRIMARY KEY (`CodFiscale`)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO `MV_Affidabilita`
SELECT U.`CodFiscale`, NULL
FROM `Utente` U;

DROP PROCEDURE IF EXISTS scan_usr;
DELIMITER $$
CREATE PROCEDURE scan_usr()
BEGIN
DECLARE finished integer(11) DEFAULT 0;

	DECLARE `curr_codfiscale` varchar(50);

	DECLARE scan CURSOR FOR
		SELECT `CodFiscale`
		FROM `utente`;

	DECLARE CONTINUE HANDLER FOR NOT FOUND
	SET finished = 1;

	TRUNCATE `MV_Affidabilita`;

	INSERT INTO `MV_Affidabilita`
	SELECT `CodFiscale`, NULL
	FROM `utente`;

	OPEN scan;
	scan : LOOP
		FETCH scan INTO `curr_codfiscale`;
		IF finished = 1 THEN
			LEAVE scan;
		END IF;

		CALL aggiorna_affidabilita_utente(`curr_codfiscale`);
	END LOOP;
	CLOSE scan;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS aggiorna_affidabilita_utente;
DELIMITER $$
CREATE PROCEDURE aggiorna_affidabilita_utente(IN `CodiceFiscale` char(50))
BEGIN
	DECLARE `ValutazioneMedia` float(13, 2) DEFAULT 0.0;
    DECLARE `PartenzePoolRispettate` int(11) DEFAULT NULL;
    DECLARE `PartenzeRideSharingRispettate` int(11) DEFAULT NULL;
    DECLARE `IndicePuntualita` float(13, 2) DEFAULT 1.0;
    DECLARE `CodiceProponente` char(50) DEFAULT NULL;
    DECLARE `PoolTotali` int(11) DEFAULT NULL;
    DECLARE `RidesharingTotali` int(11) DEFAULT NULL;
    
    SET `CodiceProponente` = (SELECT P.`CodiceProponente`
							  FROM `Proponente` P
                              WHERE `CodiceFiscale` = P.`CodFiscale`
                             );
                                 
    CALL VisualizzaValutazioneMedia(`CodiceFiscale`, `ValutazioneMedia`);
	SET `PartenzePoolRispettate` = (SELECT count(*)
									FROM `pool` P
									WHERE P.`PartenzaEffettiva` IS NOT NULL AND
										  P.`PartenzaEffettiva` < DATE_ADD(`Partenza`, INTERVAL 5 MINUTE) AND
										  `CodiceProponente` = P.`CodiceProponente`
								   );
     
    IF `PartenzePoolRispettate` IS NULL THEN
			SET `PartenzePoolRispettate` = 0;
	END IF;
                                   
	SET `PartenzeRideSharingRispettate` = (SELECT count(*)
										   FROM `ridesharing` R
										   WHERE R.`PartenzaEffettiva` IS NOT NULL AND
												 R.`PartenzaEffettiva` < DATE_ADD(`OrarioPartenza`, INTERVAL 5 MINUTE) AND
												 `CodiceProponente` = R.`CodiceProponente`
										  );
                                          
    IF `PartenzeRideSharingRispettate` IS NULL THEN
			SET `PartenzeRideSharingRispettate` = 0;
	END IF;
    
    SET `PoolTotali` = (SELECT count(*)
						FROM `pool` P
						WHERE P.`PartenzaEffettiva` IS NOT NULL AND
							  `CodiceProponente` = P.`CodiceProponente`
						);
    
    IF `PoolTotali` IS NULL THEN
			SET `PoolTotali` = 0;
	END IF;
    
	SET `RideSharingTotali` = (SELECT count(*)
							   FROM `ridesharing` R
							   WHERE R.`PartenzaEffettiva` IS NOT NULL AND
									 `CodiceProponente` = R.`CodiceProponente`
							 );
	
    IF `RideSharingTotali` IS NULL THEN
			SET `RideSharingTotali` = 0;
	END IF;
    
    IF (`PoolTotali` <> 0 OR `RideSharingTotali` <> 0) THEN
		SET `IndicePuntualita` = (`PartenzePoolRispettate` + `PartenzeRideSharingRispettate`) / (`PoolTotali` + `RidesharingTotali`);
	END IF;
    
	UPDATE `MV_Affidabilita`
    SET `Affidabilita` = (`ValutazioneMedia` + `IndicePuntualita`*5 ) / 2
    WHERE `CodiceFiscale` = `CodFiscale`;
END $$

DELIMITER ;

DROP EVENT IF EXISTS aggiorna_affidabilita;
DELIMITER $$

CREATE EVENT aggiorna_affidabilita
ON SCHEDULE EVERY 7 DAY
DO
BEGIN
	CALL scan_usr();
END $$

DELIMITER ;

DROP TABLE IF EXISTS `MV_Viabilita`;
CREATE TABLE `MV_Viabilita`(
	`IDStrada` char(50) NOT NULL,
    `Numero` int(11) unsigned NOT NULL,
    `Viabilita` char(50) DEFAULT 'regolare',
    `TempoMedioRegolare` time NOT NULL,
    PRIMARY KEY (`IDStrada`, `Numero`)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO `MV_Viabilita`
SELECT C.`IDStrada`, C.`Numero`, 'regolare', C.`TempoMedio`
FROM `chilometro` C;