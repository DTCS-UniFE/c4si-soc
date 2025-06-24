<?php
function connect(): PDO {
    $servername = "localhost";
    $username = "UTENTE_DATABASE";
    $password = "PASSWORD_DATABASE";
    $dbname = "cyberbase";
    $conn = new PDO("mysql:host=".$servername.";dbname=".$dbname."", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    return $conn;
}
