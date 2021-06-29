SET NAMES latin1;
USE `carsharing`;
SET FOREIGN_KEY_CHECKS = 1;
SET GLOBAL EVENT_SCHEDULER = ON;

DROP TRIGGER IF EXISTS `controllo_scadenza_documento`;
DELIMITER $$
CREATE TRIGGER `controllo_scadenza_documento`
BEFORE INSERT ON `documento` FOR EACH ROW
BEGIN
	IF NEW.`Scadenza` < current_date THEN
		SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Documento scaduto';
	END IF;
END $$

DELIMITER ;

DROP TRIGGER IF EXISTS `controllo_entita_variazione`;
DELIMITER $$
CREATE TRIGGER `controllo_entita_variazione`
BEFORE INSERT ON `variazione` FOR EACH ROW
BEGIN
	SET @flessibilita = (SELECT `Flessibilita`
							FROM `pool`
							WHERE `IDPool` = NEW.`IDPool`);
	IF (NEW.`Entita` = 'media') THEN
		IF (flessibilita = 'bassa') THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'flessibilità non compatibile con la variazione';
		END IF;
	ELSEIF (NEW.`Entita` = 'alta') THEN
		IF (flessibilita = 'bassa') THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'flessibilità non compatibile con la variazione';
		ELSEIF (flessibilita = 'media') THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'flessibilità non compatibile con la variazione';
		END IF;
	END IF;
END $$

DELIMITER ;

DROP TRIGGER IF EXISTS `controllo_stato_pool`;
DELIMITER $$
CREATE TRIGGER `controllo_stato_pool`
BEFORE INSERT ON `prenotazionep` FOR EACH ROW
BEGIN
	IF (SELECT `Stato`
		FROM `pool`
        WHERE `IDPool` = NEW.`IDPool`
        ) = 'chiuso' THEN
        	SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'impossibile prenotare un pool chiuso';
	END IF;
END $$

DELIMITER ;

DROP TRIGGER IF EXISTS `controllo_stato_pool2`;
DELIMITER $$
CREATE TRIGGER `controllo_stato_pool2`
BEFORE INSERT ON `variazione` FOR EACH ROW
BEGIN
	IF (SELECT `Stato`
		FROM `pool`
        WHERE `IDPool` = NEW.`IDPool`
        ) = 'chiuso' THEN
        	SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'impossibile inserire una variazione per un pool chiuso';
	END IF;
END $$

DELIMITER ;

DROP TRIGGER IF EXISTS `controllo_variazione`;
DELIMITER $$
CREATE TRIGGER `controllo_variazione`
BEFORE INSERT ON `variazione` FOR EACH ROW
BEGIN
	IF (SELECT `PosizionePartenza`
		FROM `tragitto`
        WHERE NEW.`CodiceTragitto` = `CodiceTragitto`) =
		(SELECT `PosizioneArrivo`
		FROM `tragitto`
        WHERE NEW.`CodiceTragitto` = `CodiceTragitto`) THEN
        SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'impossibile inserire una variazione per un pool chiuso';
	END IF;
END $$

DELIMITER ;

DROP TRIGGER IF EXISTS `aggiornamento_tempi_medi`;
DELIMITER $$
CREATE TRIGGER `aggiornamento_tempi_medi`
AFTER UPDATE ON `chilometro` FOR EACH ROW
BEGIN
	DECLARE `TMR` time;
    SET `TMR` = (SELECT `TempoMedioRegolare`
				 FROM `MV_Viabilita`
				 WHERE NEW.`Numero` = `Numero` AND NEW.`IDStrada` = `IDStrada`
				);
	IF (time_to_sec(NEW.`TempoMedio`) > 2*time_to_sec(`TMR`)) THEN
		UPDATE `MV_Viabilita`
        SET `Viabilita` = 'compromessa'
        WHERE NEW.`Numero` = `Numero` AND NEW.`IDStrada` = `IDStrada`;
	ELSE
		UPDATE `MV_Viabilita`
        SET `Viabilita` = 'regolare'
        WHERE NEW.`Numero` = `Numero` AND NEW.`IDStrada` = `IDStrada`;
	END IF;
END $$

DELIMITER ;
