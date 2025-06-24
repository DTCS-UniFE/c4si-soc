<?php
require_once '../db.php';
require_once '../test_input.php';
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    if (empty($_POST["username"])) {
        header("Location: login.php?error=Username is required");
        die();
    } else {
        $uname = test_input($_POST["username"]);
    }

    if (empty($_POST["password"])) {
        header("Location: login.php?error=Password is required");
        die();
    } else {
        $user_password = test_input($_POST["password"]);
    }
} else {
    header("Location: login.php?error=method not allowed", true, 405);
    die();
}

try {
    $conn = connect();
    $stmt = $conn->prepare("SELECT * FROM admin WHERE username=?");
    $stmt->execute(array($uname));
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if(count($rows)!=1){
        header("Location: login.php?error=Nome utente o password errati");
        die();
    } else {
        $user = $rows[0];
        if (md5($user_password) === $user['password']){
            session_start();
            $_SESSION["uname"] = $uname;
            $tohash = $uname."".$user['password'];
            $hash = hash ( "sha512" , $tohash);
            setcookie("logged", $uname.'-'.$hash, time() + (86400 * 30), "/");
            header("Location: home.php");
            die();
        } else {
            header("Location: login.php?error=Nome utente o password errati");
            die();
        }
    }
} catch(PDOException $e) {
    header("Location: login.php?error=Error: " . $e->getMessage());
}
