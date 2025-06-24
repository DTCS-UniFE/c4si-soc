<?php
require_once 'logged.php';
if(logged()) {
}
?>

<!DOCTYPE HTML>
<html>
<head>
    <title>Nuovo ticket</title>
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
                <section class="box">
                    <div class="row gtr-uniform">
                        <div class="col-12 col-12-mobile">
                            <h2>Nuovo ticket</h2>
                        </div>
                    </div>
                    <?php if (isset($_GET['error']) && $_GET['error'] != '') {
                        echo '<div class="col-12 col-12-mobile"><h3 class="error">'.$_GET['error'].'</h3></div>';
                    } ?>
                    <br>
                    <form action="salvaTicket.php" method="post" class="row gtr-uniform">
                        <div class="col-3 col-12-mobile">
                            <label for="data">Data: </label>
                            <input type="date" id="data" name="data" autocomplete="data" required
                            value="<?php echo date("Y-m-d") ?>" />
                        </div>
                        <div class="col-12 col-12-mobile">
                            <label for="testo">Testo: </label>
                            <textarea name="testo" id="testo" placeholder="Inserisci il testo del ticket" rows="3" maxlength="512"></textarea>
                        </div>
                        <div class="col-12 col-12-mobile">
                            <input type="submit" value="Inserisci ticket"/>
                        </div>
                    </form>
                </section>
            </div>
        </div>
    </section>
</div>
</body>
</html>