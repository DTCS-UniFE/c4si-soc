<?php
require_once 'db.php';
require_once 'test_input.php';

function get_all_tickets(){
    $conn = connect();
    $stmt = $conn->prepare("SELECT * FROM tickets ORDER BY date DESC, id DESC");
    $stmt->execute();
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}
?>

<!DOCTYPE HTML>
<html>
<head>
    <title>Benvenuto</title>
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
                <h2>Lista dei ticket</h2>
                <?php if (isset($_GET['error']) && $_GET['error'] != '') {
                    echo '<div class="col-12 col-12-mobile"><h3 class="error">'.$_GET['error'].'</h3></div>';
                } ?>
                <?php
                try {
                    $rows = get_all_tickets();
                    if (count($rows) == 0) {
                        echo '<div class="col-12 col-12-mobile"><h3>Nessun ticket trovato nel database</h3></div>';
                    } else {
                        echo '
                        <div class="table-wrapper">
                            <table>
                                <thead>
                                    <th>Id</th><th>Data</th><th>Testo</th><th>Utente</th>
                                </thead>
                                <tbody>';
                        foreach ($rows as $r) {
                            echo '<tr>';
                            foreach ($r as $c) {
                                echo '<td>' . $c . '</td>';
                            }
                            echo '</tr>';
                        }
                        echo '</tbody></table>';
                    }
                } catch (Exception $e) {
                    echo '<h3 class="error">'.$e.'</h3>';
                }
                ?>
            <input type="button" onclick="location.href='./searchTickets.php';" value="Clicca qui cercare fra i ticket" />
            <input type="button" onclick="location.href='./newTicket.php';" value="Inserisci un ticket" />
            </div>
        </div>
    </section>
</div>
</body>
</html>
