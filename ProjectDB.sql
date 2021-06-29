SET NAMES latin1;
DROP DATABASE IF EXISTS `carsharing`;
CREATE DATABASE  IF NOT EXISTS `carsharing`;
USE `carsharing`;
SET FOREIGN_KEY_CHECKS = 1;
SET GLOBAL EVENT_SCHEDULER = ON;

DROP TABLE IF EXISTS `utente`;
CREATE TABLE `utente` (
  `CodFiscale` char(50) NOT NULL,
  `Nome` char(50) NOT NULL,
  `Cognome` char(50) NOT NULL,
  `NumeroTelefono` int(11) unsigned NOT NULL,
  `NumeroCivico` int(11) unsigned NOT NULL,
  `Via` char(50) NOT NULL,
  `CAP` int(11) unsigned NOT NULL,
  `ValutazioneMedia` float(13, 2) unsigned DEFAULT NULL,
  PRIMARY KEY (`CodFiscale`)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `account`;
CREATE TABLE `account` (
	`NomeUtente` char(50) NOT NULL,
	`Data` date NOT NULL,
	`CodFiscale` char(50) NOT NULL,
	`Password` char(50) NOT NULL,
	`DomandaRiserva` char(50) NOT NULL,
	`RispostaRiserva` char(50) NOT NULL,
	`Stato` char(50) NOT NULL DEFAULT 'inattivo',
	PRIMARY KEY (`NomeUtente`),
    UNIQUE (`CodFiscale`)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `documento`;
CREATE TABLE `documento` (
	`Numero` int(11) unsigned NOT NULL,
    `CodFiscale` char(50) NOT NULL,
    `Tipologia` char(50) NOT NULL,
    `Scadenza` date NOT NULL,
    `EnteRilascio` char(50) NOT NULL,
    PRIMARY KEY (`Numero`)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `fruitore`;
CREATE TABLE `fruitore` (
	`CodiceFruitore` char(50) NOT NULL,
    `CodFiscale` char(50) NOT NULL,
    PRIMARY KEY (`CodiceFruitore`),
	UNIQUE (`CodFiscale`)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `valutazione`;
CREATE TABLE `valutazione` (
	`Codice` char(50) NOT NULL,
    `CodiceTragitto` char(50) NOT NULL,
    `CodFiscale` char(50) NOT NULL,
    `TestoValutazione` char(50) NOT NULL,
    `Comportamento` int(11) unsigned NOT NULL,
    `Serieta` int(11) unsigned NOT NULL,
    `PiacereViaggio` int(11) unsigned NOT NULL,
    `GiudizioPersona` int(11) unsigned NOT NULL,
    `Ruolo` char(50) NOT NULL,
    `Valutato` char(50) NOT NULL,
    PRIMARY KEY (`Codice`)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `optional`;
CREATE TABLE `optional`(
	`Targa` char(50) NOT NULL,
    `Connettivita` bool DEFAULT NULL,
    `Tavolini` bool DEFAULT NULL,
    `TettoVetro` bool DEFAULT NULL,
    `DimensioneBagagliaio` int(11) unsigned NOT NULL, -- L
    `RumoreAbitacolo` int(11) unsigned NOT NULL, -- dB
    PRIMARY KEY (`Targa`)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `prenotazionen`;
CREATE TABLE `prenotazionen`(
	`CodiceFruitore` char(50) NOT NULL,
    `IDNoleggio` char(50) NOT NULL,
    `Accettata` char(50) DEFAULT 'pending' NOT NULL,
    PRIMARY KEY (`CodiceFruitore`, `IDNoleggio`)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `noleggio`;
CREATE TABLE `noleggio` (
	`IDNoleggio` char(50) NOT NULL,
    `CodiceFruitore` char(50) NOT NULL,
    `Targa` char(50) NOT NULL,
    `DataInizio` date NOT NULL,
    `CarburanteFineNoleggio` float(13, 2) unsigned NOT NULL, -- L 
    `DataFine` date NOT NULL,
    `CodiceTragitto` char(50) DEFAULT NULL,
    PRIMARY KEY (`IDNoleggio`)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `autocoinvolta`;
CREATE TABLE `autocoinvolta` (
	`Targa` char(50) NOT NULL,
    `IDNoleggio` char(50) NOT NULL,
    `Timestamp` datetime NOT NULL,
    `CasaAutomobilistica` char(50) NOT NULL,
    `Modello` char(50) NOT NULL,
    PRIMARY KEY (`Targa`, `IDNoleggio`, `Timestamp`)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `ridesharing`;
CREATE TABLE `ridesharing` (
	`IDSharing` char(50) NOT NULL,
    `CodiceTragitto` char(50) NOT NULL,
    `Targa` char(50) NOT NULL,
    `OrarioArrivo` datetime NOT NULL,
    `OrarioPartenza` datetime NOT NULL,
    `PartenzaEffettiva` datetime DEFAULT NULL,
    `CodiceProponente` char(50) NOT NULL,
    PRIMARY KEY (`IDSharing`)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `corsasharing`;
CREATE TABLE `corsasharing` (
	`Codice` char(50) NOT NULL,
    `IDSharing` char(50) NOT NULL,
    PRIMARY KEY (`Codice`,`IDSharing`)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `fasciaoraria`;
CREATE TABLE `fasciaoraria` (
	`Targa` char(50) NOT NULL,
    `OraInizio` time NOT NULL,
    `OraFine` time NOT NULL,
    `Giorno` char(50) NOT NULL,
    PRIMARY KEY (`Targa`, `OraInizio`, `OraFine`, `Giorno`)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `pool`;
CREATE TABLE `pool` (
	`IDPool` char(50) NOT NULL,
    `CodiceTragitto` char(50) NOT NULL,
    `CodiceProponente` char(50) NOT NULL,
    `Targa` char(50) NOT NULL,
    `Flessibilita` char(50) NOT NULL,
    `NumeroPosti` int(11) unsigned NOT NULL,
    `OreChiusura` int(11) unsigned NOT NULL,
    `Spesa` float(13, 2) unsigned NOT NULL, -- €
    `Partenza` datetime NOT NULL,
    `GiornoArrivo` datetime NOT NULL,
    `Stato` char(50) NOT NULL,
    `CostoVariazione` float(13, 2) unsigned DEFAULT 0, -- €
    `PartenzaEffettiva` datetime,
    PRIMARY KEY (`IDPool`)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `variazione`;
CREATE TABLE `variazione` (
	`IDPool` char(50) NOT NULL,
    `IDFruitore` char(50) NOT NULL,
    `Accettata` char(50) NOT NULL DEFAULT 'pending',
    `Entita` char(50) NOT NULL,
    `CodiceTragitto` char(50) NOT NULL,
	PRIMARY KEY (`IDPool`, `IDFruitore`)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `tragitto`;
CREATE TABLE `tragitto` (
	`CodiceTragitto` char(50) NOT NULL,
    `LunghezzaTragitto` float(13, 2) unsigned DEFAULT 0.0, -- km
    `PosizioneArrivo` char(50) NOT NULL,
    `PosizionePartenza` char(50) NOT NULL,
    PRIMARY KEY (`CodiceTragitto`)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `posizione`;
CREATE TABLE `posizione` (
	`IDPosizione` char(50) NOT NULL,
    `Strada` char(50) NOT NULL,
    `Latitudine` float(18, 7) NOT NULL,
    `Longitudine` float(18, 7) NOT NULL,
    `Timestamp` datetime,
    `Numero` int(11) unsigned NOT NULL,
    `CodiceTragitto` char(50) NOT NULL,
    PRIMARY KEY (`IDPosizione`)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `chilometro`;
CREATE TABLE `chilometro` (
	`IDStrada` char(50) NOT NULL,
    `Numero` int(11) unsigned NOT NULL,
    `Latitudine` float(18, 7) NOT NULL,
    `Longitudine` float(18, 7) NOT NULL,
    `LimiteVelocita` float(13, 2) unsigned NOT NULL, -- km/h
    `Pedaggio` float(13, 2) unsigned, -- €
    `TempoMedio` time, 
    PRIMARY KEY(`IDStrada`, `Numero`)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `strada`;
CREATE TABLE `strada` (
	`IDStrada` char(50) NOT NULL,
    `Tipologia` char(50) NOT NULL,
    `Nome` char(50),
    `TipoStrada` char(50) NOT NULL,
    `Lunghezza` float(13, 2) unsigned NOT NULL,
    `NCarreggiate` int(11) unsigned NOT NULL,
    `CorsieCarreggiata`int(11) unsigned NOT NULL,
    `NSensiMarcia`int(11) unsigned NOT NULL,
    `CaratterizzazioniAggiuntive` char(50),
	PRIMARY KEY (`IDStrada`)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `proponente`;
CREATE TABLE `proponente` (
	`CodiceProponente` char(50) NOT NULL,
	`CodFiscale` char(50)  NOT NULL,
	PRIMARY KEY (`CodiceProponente`),
    UNIQUE (`CodFiscale`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `autovettura`;
CREATE TABLE `autovettura` (
	`Targa` char(50) NOT NULL,
	`CodiceProponente` char(50)  NOT NULL,
	`AnnoImmatricolazione` int(11)  NOT NULL, 
	`CostoOperativo` float(13, 2) unsigned NOT NULL, -- costo per kilometro
	`CostoUsura` float(13, 2) unsigned NOT NULL, -- costo per kilometro
	`CostoExtra` float(13, 2) unsigned NOT NULL, -- costo per kilometro
	`ChilometriPercorsi` float(13, 2) unsigned NOT NULL, 
	`Disponibilita` char(50) NOT NULL,
	`CarburanteDisponibile` float(13, 2) unsigned NOT NULL, -- L
	`NomeModello` char(50) NOT NULL,
	PRIMARY KEY (`Targa`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `chiamatasharing`;
CREATE TABLE `chiamatasharing` (
	`Codice` char(50) NOT NULL,
	`CodiceFruitore` char(50)  NOT NULL,
	`PosizioneFruitore` char(50) NOT NULL, 
	`Destinazione` char(50) NOT NULL,
	`TimestampChiamata` datetime  NOT NULL,
	`Stato` char(50) DEFAULT 'pending' NOT NULL,
	`TimestampRisposta` datetime NOT NULL,
	PRIMARY KEY (`Codice`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `incidente`;
CREATE TABLE `incidente` (
	`IDNoleggio` char(50) NOT NULL,
	`Timestamp` datetime  NOT NULL,
	`Dinamica` char(250)  NOT NULL, 
	PRIMARY KEY (`IDNoleggio`,`Timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `prenotazionep`;
CREATE TABLE `prenotazionep` (
	`CodiceFruitore` char(50) NOT NULL,
	`IDPool` char(50)  NOT NULL,
	`CodicePrenotazione` char(50) NOT NULL, 
	PRIMARY KEY (`CodiceFruitore`,`IDPool`,`CodicePrenotazione`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `modello`;
CREATE TABLE `modello` (
	`NomeModello` char(50) NOT NULL,
	`ConsumoMisto` float(13, 2) unsigned  NOT NULL, -- litri per 100 kilometro
	`ConsumoUrbano` float(13, 2) unsigned NOT NULL, -- litri per 100 kilometro
	`ConsumoExtraurbano` float(13, 2) unsigned NOT NULL, -- litri per 100 kilometro
	`CasaProduttrice` char(50) NOT NULL,
	`NPosti` int(11) unsigned NOT NULL, 
	`Alimentazione` char(50) NOT NULL,
	`Comfort` int (11) unsigned NOT NULL, -- da 1 a 5
	`Serbatoio` int(11) unsigned NOT NULL, -- dipende dal tipo di alimetazione
	`Cilindrata` int(11) unsigned NOT NULL,
	PRIMARY KEY (`NomeModello`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `relativa`;
CREATE TABLE `relativa` (
	`IDPosizione` char(50) NOT NULL,
	`Numero` int(11) unsigned  NOT NULL, 
	`IDStrada` char(50) NOT NULL, 
  PRIMARY KEY (`IDPosizione`,`Numero`,`IDStrada`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `intersezione`;
CREATE TABLE `intersezione` (
	`Numero1` int(11) unsigned NOT NULL,
	`IDStrada1` char(50)  NOT NULL,
	`Numero2` int(11) unsigned NOT NULL, 
	`IDStrada2` char(50) NOT NULL,
	PRIMARY KEY (`Numero1`,`IDStrada1`,`Numero2`,`IDStrada2`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TRIGGER IF EXISTS `aggiorna_lunghezza_tragitto`;
DELIMITER $$
CREATE TRIGGER `aggiorna_lunghezza_tragitto`
AFTER INSERT ON `posizione` FOR EACH ROW
BEGIN
	DECLARE lat1 float(18, 7);
    DECLARE lat2 float(18, 7);
    DECLARE lon1 float(18, 7);
    DECLARE lon2 float(18, 7);
    DECLARE LunghezzaAggiunta float(18, 7);
	IF (NEW.`Numero` > 1) THEN
		SET lat1 = (SELECT `Latitudine`
					FROM `posizione`
					WHERE `CodiceTragitto` = NEW.`CodiceTragitto`
						AND `Numero` = NEW.`Numero` - 1)*PI()/180;
		SET lon1 = (SELECT `Longitudine`
					FROM `posizione`
					WHERE `CodiceTragitto` = NEW.`CodiceTragitto`
						AND `Numero` = NEW.`Numero` - 1)*PI()/180;
		SET lat2 = NEW.`Latitudine`*PI()/180;
		SET lon2 = NEW.`Longitudine`*PI()/180;
		SET LunghezzaAggiunta = ACOS(SIN(lat1)*SIN(lat2) + COS(lat1)*COS(lat2)*COS(lon2-lon1))*6371;

		IF LunghezzaAggiunta IS NOT NULL THEN
			UPDATE `tragitto`
			SET `LunghezzaTragitto` = `LunghezzaTragitto` + LunghezzaAggiunta
			WHERE `CodiceTragitto` = NEW.`CodiceTragitto`;
		END IF;
	END IF;
END $$

DELIMITER ;

DROP TRIGGER IF EXISTS `aggiornamento_media_valutazioni`;
DELIMITER $$
CREATE TRIGGER `aggiornamento_media_valutazioni`
AFTER INSERT ON `valutazione` FOR EACH ROW
BEGIN
	DECLARE media float(13, 2) DEFAULT NULL;
	SET media = (SELECT AVG((`Comportamento`+`Serieta`+`PiacereViaggio`+`GiudizioPersona`)/4)
				  FROM `valutazione`
				  WHERE `Valutato` = NEW.`Valutato`
                  );
	UPDATE `utente`
    SET `ValutazioneMedia` = media
	WHERE `CodFiscale` = NEW.`Valutato`;
END $$

DELIMITER ;
