<?php
require_once 'logged.php';
require_once 'test_input.php';

if(logged()){
    if ($_SERVER["REQUEST_METHOD"] == "GET") {
        $rows = print_tickets();
    } else {
        header("Location: login.php?error=request method error");
        die();
    }
}

function print_tickets(){
    $conn = connect();
    $sql = "SELECT * FROM tickets WHERE username=:uname";
    $stmt = $conn->prepare($sql);
    $stmt->bindParam(":uname", $_SESSION["uname"]);
    $stmt->execute();
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}
?>

<!DOCTYPE HTML>
<html>
<head>
    <title>I tuoi ticket</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no" />
    <link rel="stylesheet" href="assets/css/main.css" />
</head>
<body class="landing is-preload">
<div id="page-wrapper">
    <?php include 'top.inc';?>
    <section id="main" class="container">
        <div class="row">
            <div class="col-12">
                <h2>Tickets</h2>
                <a href="newTicket.php" class="button">Inserisci un nuovo ticket</a>
                <br><hr>
                <?php
                if(count($rows)==0){
                    echo '<div class="col-12 col-12-mobile"><h3>Non hai ancora aperto nessun ticket.</h3></div>';
                } else {
                    echo '<div class="table-wrapper"><table><thead><tr><th>Data</th><th>Testo</th></tr></thead><tbody>';
                    $tot = 0;
                    $totp = 0;
                    $totn = 0;
                    foreach ($rows as $r) {
                        echo '<tr><td>'.$r['date'].'</td>
                            <td>'.substr($r['testo'],0,100).' '.(strlen($r['testo'])>100? " ...":"").'</td>
                        </tr>';
                    }
                }
                ?>
            </div>
        </div>
    </section>
</div>
</body>
</html>
