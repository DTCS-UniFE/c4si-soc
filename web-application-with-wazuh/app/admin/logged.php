<?php
require_once '../db.php';
session_start();
function logged() {
    $err_login = "Location: login.php?error=Esegui il login per vedere questa pagina";
    if (!empty($_SESSION["uname"])) {
        return true;
    } else {
        if (isset($_COOKIE["logged"])) {
            $exp = explode("-", $_COOKIE["logged"]);
            try {
                $conn = connect();
                $stmt = $conn->prepare("SELECT username, password FROM admin WHERE username='" . $exp[0] . "'");
                $stmt->execute();
                $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
                if (count($rows) != 1) {
                    header($err_login);
                    $conn = null;
                    die();
                } else {
                    $user = $rows[0];
                    $tohash = $exp[0] . $user['password'];
                    $hash = hash("sha512", $tohash);
                    if ($exp[1] != $hash) {
                        header($err_login);
                        $conn = null;
                        die();
                    } else {
                        session_start();
                        $_SESSION["uname"] = $exp[0];
                        setcookie("logged", $exp[0] . '-' . $hash, time() + (86400 * 30), "/");
                        $conn = null;
                        return true;
                    }
                }
            } catch (PDOException $e) {
                var_dump($e->getTrace());
                echo "<br>Error: " . $e->getMessage();
                return false;
            }
        } else if (empty($_SESSION["uname"])) {
            header($err_login);
            die();
        }
    }
}

function admin() {
    $adm_error = "Location: login.php?error=Effettua il login da amministratore per vedere questa pagina";
    if (isset($_COOKIE["logged"])) {
        $exp = explode("-", $_COOKIE["logged"]);
        try {
            $conn = connect();
            $stmt = $conn->prepare("SELECT username, password FROM admin WHERE username='" . $exp[0] . "'");
            $stmt->execute();
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            if (count($rows) != 1) {
                header($adm_error);
                $conn = null;
                die();
            } else {
                $user = $rows[0];
                $tohash = $exp[0] . $user['password'];
                $hash = hash("sha512", $tohash);
                if ($exp[1] != $hash) {
                    header($adm_error);
                    $conn = null;
                    die();
                } else {
                    session_start();
                    $_SESSION["uname"] = $exp[0];
                    setcookie("logged", $exp[0] . '-' . $hash, time() + (86400 * 30), "/");
                    $conn = null;
                    return true;
                }
            }
        } catch (PDOException $e) {
            var_dump($e->getTrace());
            echo "<br>Error: " . $e->getMessage();
            return false;
        }
    } else if (empty($_SESSION["uname"])) {
        header($adm_error);
        die();
    }
    return true;
}
