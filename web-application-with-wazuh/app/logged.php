<?php
session_start();
require_once 'db.php';
function logged() {
    $err_login = "Location: login.php?error=Esegui il login per vedere questa pagina";
    if (!empty($_SESSION["uname"])) return true;
    if (isset($_COOKIE["logged"])){
        $logged_cookie = $_COOKIE["logged"];
        try {
            $conn = connect();
            $conn = connect();
            $sql = "SELECT username, password FROM users WHERE username=:logged_user";
            $stmt = $conn->prepare($sql);
            $stmt->bindParam(":logged_user", $logged_cookie);
            $stmt->execute();
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            if(count($rows)!=1){
                header($err_login);
                $conn = null;
                die();
            } else {
                session_start();
                $_SESSION["uname"] = $logged_cookie;
                setcookie("logged", $logged_cookie, time() + (86400 * 30), "/");
                $conn = null;
                return true;
            }
        } catch(PDOException $e) {
            var_dump($e->getTrace());
            echo "<br>Error: ".$e->getMessage();
            return false;
        }
    } else if (empty($_SESSION["uname"])){
        header($err_login);
        die();
    }
}
