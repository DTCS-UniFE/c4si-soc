<?php
require_once 'db.php';
require_once 'test_input.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    if (empty($_POST["username"]) || strlen($_POST["username"]) > 64) {
        header("Location: register.php?error=Username vuoto o troppo lungo");
        die();
    } else {
        $uname = test_input($_POST["username"]);
    }
    if (empty($_POST["password"]) && ($_POST["password"] != $_POST["cpassword"])) {
        header("Location: register.php?error=Password e conferma password sono necessari");
        die();
    } else {
        if (strlen($_POST["password"]) < '4') {
            header("Location: register.php?error=La password deve avere almeno 4 caratteri");
            die();
        }
        $user_password = trim($_POST["password"]);
    }
} else {
    header("Location: login.php?error=method not allowed", true, 405);
    die();
}
try {
    $conn = connect();
    $pwd_hash = md5($user_password);
    $sql = "INSERT INTO users (username, password) VALUES (:uname, :pwd_hash)";
    $stmt = $conn->prepare($sql);
    $false = false;
    $stmt->bindParam(':uname', $uname);
    $stmt->bindParam(':pwd_hash', $pwd_hash);
    $stmt->execute();
    $msg = "<h3>Registrazione completata</h3><h3>Benvenuto ".$uname.", ora puoi fare il login</h3>";
} catch(PDOException $e) {
    echo "<h2 class='error'>SQL error<br>" . $e->getMessage()."</h2>";
}

$conn = null;
?>

<!DOCTYPE HTML>
<html>
<head>
    <title>Registrazione</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no" />
    <link rel="stylesheet" href="assets/css/main.css" />
</head>
<body class="landing is-preload">
<div id="page-wrapper">
    <header id="header">
        <a href="home.php"><h2 style="color: white; margin-left: 5px;">FactoryTicket</h2></a>
        <nav id="nav">
            <ul>
                <li><a href="home.php">Home</a></li>
                <li>
                    <form name="logoutForm"></form>
                </li>
                <li><a href="login.php" class="button">Registrati e Accedi</a></li>
            </ul>
        </nav>
    </header>
    <section id="main" class="container">
        <div class="row">
            <div class="col-12">
                <section class="box">
                    <div class="row gtr-uniform">
                        <div class="col-12 col-12-mobile">
                            <h2>Esito registrazione</h2>
                        </div>
                        <div class="col-12 col-12-mobile">
                            <?php echo $msg; ?>
                        </div>
                    </div>
                </section>
            </div>
        </div>
    </section>
</div>
</body>
</html>
