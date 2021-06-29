SET NAMES latin1;
USE `carsharing`;
SET FOREIGN_KEY_CHECKS = 1;
SET GLOBAL EVENT_SCHEDULER = ON;

-- Operazione 1: Registrazione Utente

DROP PROCEDURE IF EXISTS RegistrazioneUtente;
DELIMITER $$
CREATE PROCEDURE RegistrazioneUtente(IN `CodFiscale` char(50),
									 IN `Nome` char(50),
                                     IN `Cognome` char(50),
                                     IN `NumeroTelefono` int(11) unsigned,
                                     IN `NumeroCivico` int(11) unsigned,
                                     IN `Via` char(50),
                                     IN `CAP` int(11) unsigned,
                                     IN `Password` char(50),
                                     IN `NomeUtente` char(50),
                                     IN `DomandaRiserva` char(50),
                                     IN `RispostaRiserva` char(50),
                                     IN `Numero` int(11) unsigned,
                                     IN `Tipologia` char(50),
                                     IN `Scadenza` date,
                                     IN `EnteRilascio` char(50)
                                    )
BEGIN
	INSERT INTO `Account`
	VALUES(`NomeUtente`, current_date(), `CodFiscale`, `Password`, `DomandaRiserva`, `RispostaRiserva`, 'inattivo');
	
    INSERT INTO `Utente`
    VALUES(`CodFiscale`, `Nome`, `Cognome`, `NumeroTelefono`, `NumeroCivico`, `Via`, `CAP`, NULL);

	INSERT INTO `Documento`
    VALUES(`Numero`, `CodFiscale`, `Tipologia`, `Scadenza`, `EnteRilascio`);
END $$

DELIMITER ;

-- Operazione 2: Registrazione Autovettura

DROP PROCEDURE IF EXISTS RegistrazioneAutovettura;
DELIMITER $$
CREATE PROCEDURE RegistrazioneAutovettura(IN `Targa` char(50),
										  IN `CodiceProponente` char(50),
                                          IN `CodFiscale` char(50),
										  IN `AnnoImmatricolazione` int(11),
										  IN `CostoOperativo` int(11) unsigned,
										  IN `CostoUsura` int(11) unsigned,
										  IN `CostoExtra` int(11) unsigned,
										  IN `ChilometriPercorsi` int(11) unsigned,
										  IN `Disponibilita` char(50),
										  IN `CarburanteDisponibile` float(13,2) unsigned,
										  IN `NomeModello` char(50),
										  IN `Connettivita` bool,
										  IN `Tavolini` bool,
										  IN `TettoVetro` bool,
										  IN `DimensioneBagagliaio` int(11) unsigned,
										  IN `RumoreAbitacolo` int(11) unsigned
										  )
BEGIN
	IF `CodiceProponente` NOT IN (SELECT `CodiceProponente`
								  FROM `proponente` P
								  WHERE P.`CodiceProponente` = `CodiceProponente`) THEN
		INSERT INTO `proponente`
        VALUES(`CodiceProponente`, `CodFiscale`);
	END IF;

	INSERT INTO `autovettura`
	VALUES(`Targa`,
			`CodiceProponente`,
			`AnnoImmatricolazione`,
            `CostoOperativo`,
            `CostoUsura`,
            `CostoExtra`,
            `ChilometriPercorsi`,
            `Disponibilita`,
            `CarburanteDisponibile`,
            `NomeModello`);
	
    INSERT INTO `optional`
    VALUES(`Targa`, `Connettivita`, `Tavolini`, `TettoVetro`, `DimensioneBagagliaio`, `RumoreAbitacolo`);
    
END $$

DELIMITER ;

-- Operazione 3: Prenotazione Car Sharing

DROP PROCEDURE IF EXISTS PrenotazioneCarsharing;
DELIMITER $$
CREATE PROCEDURE PrenotazioneCarSharing(IN `Targa` char(50),
										IN `CodiceFruitore` char(50),
                                        IN `IDNoleggio` char(50),
										IN `CodFiscale` char(50),
										IN `DataInizio` date,
										IN `DataFine` date
										)
BEGIN
	IF `CodFiscale` NOT IN (SELECT `CodFiscale`
								  FROM `fruitore` F
								  WHERE F.`CodFiscale` = `CodFiscale`) THEN
		INSERT INTO `fruitore`
        VALUES(`CodiceFruitore`, `CodFiscale`);
	END IF;
	
    INSERT INTO `noleggio`
    VALUES(`IDNoleggio`, `CodiceFruitore`, `Targa`, `DataInizio`, NULL, `DataFine`, NULL);
	
    INSERT INTO `prenotazionen`(`CodiceFruitore`, `IDNoleggio`)
	VALUES(`CodiceFruitore`, `IDNoleggio`);    
END $$

DELIMITER ;

-- Operazione 4: Restituzione Noleggio

DROP PROCEDURE IF EXISTS RestituzioneNoleggio;
DELIMITER $$
CREATE PROCEDURE RestituzioneNoleggio(IN `IDNoleggio` char(50),
									  IN `Targa` char(50),
									  IN `ChilometriPercorsi` char(50),
									  IN `CarburanteFinenoleggio` char(50)
									  )
BEGIN
	IF `CarburanteFineNoleggio` >= 0.95*(SELECT `CarburanteDisponibile`
										FROM `autovettura` A
                                        WHERE A.`Targa` = `Targa`
                                        ) THEN
		UPDATE `noleggio` N
		SET N.`CarburanteFineNoleggio` = `CarburanteFineNoleggio`
        WHERE N.`IDNoleggio` = `IDNoleggio`;
        
        UPDATE `autovettura` A
		SET A.`ChilometriPercorsi` = `ChilometriPercorsi`
        WHERE A.`Targa` = `Targa`;
	END IF;
END $$

DELIMITER ;

-- Operazione 5: Registrazione Sinistro 

DROP PROCEDURE IF EXISTS RegistrazioneSinistro;
DELIMITER $$
CREATE PROCEDURE RegistrazioneSinistro(IN `IDNoleggio` char(50),
									   IN `Timestamp` datetime,
									   IN `Dinamica` char(250),
									   IN `CasaAutomobilistica` char(50),
									   IN `Modello` char(50),
									   IN `Targa` char(50)
									   )
BEGIN
    INSERT INTO `incidente`
    VALUES(`IDNoleggio`, `Timestamp`, `Dinamica`);
	
    INSERT INTO `autocoinvolta`
	VALUES(`Targa`, `IDNoleggio`, `Timestamp`, `CasaAutomobilistica`, `Modello`);    
END $$

DELIMITER ;

-- Operazione 6: Creazione Pool

DROP PROCEDURE IF EXISTS CreazionePool;
DELIMITER $$
CREATE PROCEDURE CreazionePool(IN `CodiceProponente` char(50),
									   IN `IDPool` char(50),
									   IN `CodiceTragitto` char(50),
									   IN `Targa` char(50),
									   IN `Flessibilita` char(50),
									   IN `NumeroPosti` int(11),
									   IN `OreChiusura` int(11),
                                       IN `Spesa` float(13, 2),
                                       IN `Partenza` datetime,
                                       IN `GiornoArrivo` datetime
                                       )
BEGIN
    INSERT INTO `pool`
    VALUES(`IDPool`,
		   `CodiceTragitto`,
           `CodiceProponente`,
		   `Targa`,
		   `Flessibilita`,
		   `NumeroPosti`,
           `OreChiusura`,
		   `Spesa`,
           `Partenza`,
		   `GiornoArrivo`,
           'aperto',
           0,
           NULL);
END $$

DELIMITER ;

-- Operazione 7: Proposta Variazione Pool

DROP PROCEDURE IF EXISTS PropostaVariazionePool;
DELIMITER $$
CREATE PROCEDURE PropostaVariazionePool(IN `IDPool` char(50),
									    IN `CodiceTragitto` char(50),
									    IN `IDFruitore` char(50)
									    )
BEGIN
	DECLARE Entita char(50);
    DECLARE Lunghezza int(11) unsigned;
    SET Lunghezza = (SELECT `LunghezzaTragitto`
					 FROM `tragitto` T
                     WHERE T.`CodiceTragitto` = `CodiceTragitto`
                     );
	CASE
		WHEN Lunghezza <= 2 THEN
			SET Entita = 'bassa';
		WHEN (Lunghezza > 2 AND Lunghezza <= 5) THEN
			SET Entita = 'media';
		WHEN (Lunghezza > 5 AND Lunghezza <= 10) THEN
			SET Entita = 'alta';
	END CASE;
    
    INSERT INTO `variazione`(`IDPool`, `IDFruitore`, `Entita`, `CodiceTragitto`)
    VALUES(`IDPool`,
		   `IDFruitore`,
			Entita,
            `CodiceTragitto`
		   );
END $$

DELIMITER ;

-- Operazione 8: Chiamata Ride Sharing

DROP PROCEDURE IF EXISTS ChiamataRideSharing;
DELIMITER $$
CREATE PROCEDURE ChiamataRideSharing(IN `CodFiscale` char(50),
									 IN `CodiceFruitore` char(50),
									 IN `PosizioneFruitore` char(50),
									 IN `Destinazione` char(50),
									 IN `TimestampChiamata` datetime,
									 IN `Codice` char(50),
									 IN `TimestampRisposta` datetime
									 )
BEGIN
	IF `CodFiscale` NOT IN (SELECT `CodFiscale`
								  FROM `fruitore` F
								  WHERE F.`CodFiscale` = `CodFiscale`) THEN
		INSERT INTO `fruitore`
        VALUES(`CodiceFruitore`, `CodFiscale`);
	END IF;
	
    INSERT INTO `chiamatasharing`(`Codice`, `CodiceFruitore`, `PosizioneFruitore`, `Destinazione`, `TimestampChiamata`, `TimestampRisposta`)
	VALUES(`Codice`, `CodiceFruitore`, `PosizioneFruitore`, `Destinazione`, `TimestampChiamata`, `TimestampRisposta`);
END $$

DELIMITER ;

-- Operazione 9: Inserimento di una recensione

DROP PROCEDURE IF EXISTS InserimentoRecensione;
DELIMITER $$
CREATE PROCEDURE InserimentoRecensione(IN `TestoValutazione` char(50),
									   IN `CodiceTragitto` char(50),
									   IN `CodFiscale` char(50),
									   IN `Valutato` char(50),
									   IN `Codice` char(50),
									   IN `Serieta` int(11) unsigned,
                                       IN `Comportamento` int(11) unsigned,
                                       IN `PiacereViaggio` int(11) unsigned,
                                       IN `GiudizioPersona` int(11) unsigned,
                                       IN `Ruolo` char(50)
									   )
BEGIN
    INSERT INTO `valutazione`
	VALUES(`Codice`, `CodiceTragitto`, `CodFiscale`, `TestoValutazione`, `Comportamento`, `Serieta`, `PiacereViaggio`, `GiudizioPersona`, `Ruolo`, `Valutato`);
END $$

DELIMITER ;

-- Operazione 10: Visualizzazione della valutazione media di un utente

DROP PROCEDURE IF EXISTS VisualizzaValutazioneMedia;
DELIMITER $$
CREATE PROCEDURE VisualizzaValutazioneMedia(IN `CodFiscale` char(50), OUT `MediaValutazioni` float)
BEGIN
	SELECT `ValutazioneMedia` into `MediaValutazioni`
    FROM `Utente` U
    WHERE U.`CodFiscale` = `CodFiscale`;
END $$

DELIMITER ;


-- Operazione 11: Ricerca Pool ordinati per lunghezza del tragitto

DROP PROCEDURE IF EXISTS RicercaPoolOrdineLunghezza;
DELIMITER $$
CREATE PROCEDURE RicercaPoolOrdineLunghezza(IN `PosizionePartenza` char(50), IN `PosizioneArrivo` char(50))
BEGIN
	SELECT `IDPool`, `LunghezzaTragitto`
    FROM `pool` NATURAL JOIN `tragitto` T 
    WHERE `Stato` = 'aperto' AND
		  T.`PosizionePartenza` = `PosizionePartenza` AND
          T.`PosizioneArrivo` = `PosizioneArrivo`
	ORDER BY `LunghezzaTragitto`, `Partenza` DESC;
END $$

DELIMITER ;