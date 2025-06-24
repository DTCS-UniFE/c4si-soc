<?php
session_start();
session_destroy();
session_unset();
setcookie("logged", null, time() - 3600, "/");
header("Location: home.php?error=Logout effettuato con successo");
die();