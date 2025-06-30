<?php
function connect(): PDO {
    $servername = "localhost";
    $username = "DATABASE_USER";
    $password = "DATABASE_PASSWORD";
    $dbname = "cyberbase";
    $conn = new PDO("mysql:host=".$servername.";dbname=".$dbname."", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    return $conn;
}
