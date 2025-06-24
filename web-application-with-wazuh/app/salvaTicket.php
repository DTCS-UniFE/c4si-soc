<?php
require_once 'logged.php';
require_once 'test_input.php';
logged();

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    if (empty($_POST["data"])) {
        header("Location: newTicket.php?error=La data è obbligatoria");
        die();
    } else {
        $data = test_input($_POST["data"]);
    }
    $commento = test_input($_POST["testo"]);
} else {
    header("Location: login.php?error=method not allowed", true, 405);
    die();
}
try {
    $conn = connect();
    $sql = "INSERT INTO tickets (date, testo, username) VALUES (:data, :testo, :uname)";
    $stmt = $conn->prepare($sql);
    $stmt->bindParam(':data', $data);
    $STMTCommento = (strlen($commento)!=0)? $commento:"---";
    $stmt->bindParam(':testo', $STMTCommento);
    $stmt->bindParam(':uname', $_SESSION["uname"]);
    $stmt->execute();
    $conn=null;
    header("Location: home.php?error=Ticket inserito");
    die();
} catch(PDOException $e) {
    var_dump($e->getTrace());
    echo "<br>Error: ".$e->getMessage();
}
