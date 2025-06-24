SET NAMES 'utf8mb4';
SET character_set_client = utf8mb4;
SET character_set_results = utf8mb4;
SET collation_connection = utf8mb4_unicode_ci;

START TRANSACTION;

CREATE DATABASE `cyberbase` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `cyberbase`;

-- --------------------------------------------------------

CREATE TABLE `admin` (
  `username` varchar(64) NOT NULL,
  `password` varchar(128) NOT NULL,
  CONSTRAINT `admin_pk` PRIMARY KEY (`username`)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `admin` (`username`, `password`) VALUES
('administrator', '36a2930dae16f82885cc78fc5bc8bf5a');

-- --------------------------------------------------------

CREATE TABLE `tickets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `date` date NOT NULL,
  `testo` varchar(512) NOT NULL,
  `username` varchar(128) NOT NULL,
  CONSTRAINT `tickets_pk` PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `tickets` (`id`, `date`, `testo`, `username`) VALUES
(1, '2001-01-01', 'Ciao questo è il mio primo ticket!', 'test.unife'),
(2, '2024-04-30', 'La stampante sta stampando solo in rosa, anche se cerco di stampare in bianco e nero. Ho provato a cambiare le impostazioni ma il problema persiste.', 'maria.rossi82'),
(3, '2024-04-29', 'Il mio computer non si accende più. Ho provato a premere il pulsante di accensione più volte, ma non succede nulla. Ho controllato che sia collegato correttamente all''alimentazione.', 'luigi_bianchi'),
(4, '2024-04-28', 'Quando cerco di accedere alla homepage di Google, vengo reindirizzato a un sito web sospetto: "www.pubblicita.cryptovalute.it". Non riesco ad accedere alla vera homepage di Google.', 'giulietta94'),
(5, '2024-04-27', 'Sto riscontrando un errore quando provo ad accedere a un sito web specifico. Ricevo un messaggio di errore "Errore 404: Pagina non trovata" anche se sono sicuro che l''URL sia corretto.', 'andrea_lombardi85'),
(6, '2024-04-26', 'Non riesco a connettermi alla rete Wi-Fi di mia casa con il mio pc. Altri dispositivi sembrano essere connessi correttamente alla stessa rete.', 'giuseppecosta'),
(7, '2024-04-25', 'Ho aperto un file importante sul mio computer e ho scoperto che i dati all''interno sono stati corrotti o mancanti, nonostante non abbia apportato modifiche al file di recente.', 'ale_moretti88'),
(8, '2024-04-24', 'Sto tentando di installare un nuovo software sul mio pc, ma durante l''installazione ricevo un messaggio di errore "Impossibile completare l''installazione".', 'paola_pellegrini'),
(9, '2024-04-23', 'Ho ricevuto un avviso da parte del mio antivirus che indica la presenza di un software dannoso sul mio computer. Ho eseguito una scansione completa ma il problema persiste.', 'davide.ferraro90'),
(10, '2024-04-22', 'Non riesco ad accedere al mio account email. Quando inserisco le mie credenziali, ottengo un messaggio di errore che dice "Credenziali non valide".', 'roberta.neri81'),
(11, '2024-04-21', 'Il mio computer è diventato estremamente lento negli ultimi giorni. Anche le operazioni di base richiedono molto tempo e spesso si bloccano. Ho provato a riavviare il computer più volte, ma il problema persiste.', 'luca_ferrari87');

-- --------------------------------------------------------

CREATE TABLE `users` (
  `username` varchar(64) NOT NULL,
  `password` varchar(128) NOT NULL,
  CONSTRAINT `users_pk` PRIMARY KEY (`username`)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `users` (`username`, `password`) VALUES
('test.unife', '687e58e1ebe7b405030d28882f704d0b'),
('maria.rossi82', 'e10adc3949ba59abbe56e057f20f883e'),
('luigi_bianchi', '781af835071083fc200068969de31a0e'),
('giulietta94', 'd8578edf8458ce06fbc5bb76a58c5ca4'),
('andrea_lombardi85', '25f9e794323b453885f5181f1b624d0b'),
('giuseppecosta', '6ca67655355711baccbb968d3b59ec88'),
('ale_moretti88', 'e45bada182e46e48804ba616533c9c12'),
('paola_pellegrini', '5f4dcc3b5aa765d61d8327deb882cf99'),
('davide.ferraro90', 'd9ead3b1ec90fb88402c39ddddc6fd13'),
('roberta.neri81', '51a3a888f816ca5e7f3d43adfc87eb3c'),
('luca_ferrari87', 'f25a2fc72690b780b2a14e140ef6a9e0');

COMMIT;
