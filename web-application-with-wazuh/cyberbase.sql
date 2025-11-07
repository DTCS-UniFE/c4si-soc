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
(1, '2025-11-07', 'Buongiorno, il sistema di monitoraggio della linea 3 non mostra più i dati in tempo reale. Il pannello rimane fisso alle 06:42 di stamattina.', 'marco.rossi'),
(2, '2025-11-06', 'Il robot di saldatura KUKA ha smesso di rispondere ai comandi dal terminale HMI. Sul display appare l’errore "Communication timeout with PLC".', 'elena.bianchi'),
(3, '2025-11-05', 'Il macchinario per il taglio laser segnala un surriscaldamento anomalo nonostante la temperatura ambiente sia regolare. Ho già riavviato il sistema senza successo.', 'giacomo.verdi'),
(4, '2025-11-04', 'Durante la produzione, la pressa idraulica della linea 2 si è arrestata automaticamente. Il messaggio di errore indica "Low hydraulic pressure - Sensor fault".', 'federico.mantovani'),
(5, '2025-11-03', 'Non riesco ad accedere al portale MES. Dopo il login, rimane una schermata bianca e non carica i dati della produzione.', 'chiara.romano'),
(6, '2025-11-02', 'L’applicazione di manutenzione predittiva non sta registrando le vibrazioni del motore principale. Ultima lettura disponibile risale a ieri pomeriggio.', 'simone.costa'),
(7, '2025-11-01', 'Il sensore di temperatura sul forno di trattamento termico segnala valori incoerenti (oscilla tra 40°C e 300°C in pochi secondi).', 'valentina.moretti'),
(8, '2025-10-31', 'Il tablet utilizzato per la raccolta dati in reparto non si collega più alla rete Wi-Fi interna. Altri dispositivi funzionano correttamente.', 'andrea.lombardi'),
(9, '2025-10-30', 'Il sistema ERP non aggiorna correttamente lo stato degli ordini di produzione. Le modifiche fatte ieri non risultano visibili agli operatori.', 'francesca.gallo'),
(10, '2025-10-29', 'Sul pannello HMI della linea 5 compare l’errore "Data synchronization failed with server". La produzione continua ma i dati non vengono registrati.', 'davide.ferraro'),
(11, '2025-10-28', 'Dopo l’ultimo aggiornamento software, il braccio robotico della linea 1 si muove in modo irregolare durante il ciclo automatico.', 'roberto.neri');


-- --------------------------------------------------------

CREATE TABLE `users` (
  `username` varchar(64) NOT NULL,
  `password` varchar(128) NOT NULL,
  CONSTRAINT `users_pk` PRIMARY KEY (`username`)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `users` (`username`, `password`) VALUES
('marco.rossi', '687e58e1ebe7b405030d28882f704d0b'),
('elena.bianchi', 'e10adc3949ba59abbe56e057f20f883e'),
('giacomo.verdi', '781af835071083fc200068969de31a0e'),
('federico.mantovani', 'd8578edf8458ce06fbc5bb76a58c5ca4'),
('chiara.romano', '25f9e794323b453885f5181f1b624d0b'),
('simone.costa', '6ca67655355711baccbb968d3b59ec88'),
('valentina.moretti', 'e45bada182e46e48804ba616533c9c12'),
('andrea.lombardi', '5f4dcc3b5aa765d61d8327deb882cf99'),
('francesca.gallo', 'd9ead3b1ec90fb88402c39ddddc6fd13'),
('davide.ferraro', '51a3a888f816ca5e7f3d43adfc87eb3c'),
('roberto.neri', 'f25a2fc72690b780b2a14e140ef6a9e0');

COMMIT;
