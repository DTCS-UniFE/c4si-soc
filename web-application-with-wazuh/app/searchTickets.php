<!DOCTYPE HTML>
<html>
<head>
    <title>Ricerca ticket</title>
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
                <h2>Ricerca ticket</h2>
                <form action="searchedTickets.php" method="GET" class="row gtr-uniform">
                    <div class="col-6 col-12-mobile">
                        <label>Testo da cercare:</label>
                        <input type="text" id="text" name="text" placeholder="Testo da cercare"/>
                    </div>
                    <div class="col-12 col-12-mobile">
                        <input type="submit" value="Cerca"/>
                    </div>
                </form>
            </div>
        </div>
    </section>
</div>
</body>
</html>
