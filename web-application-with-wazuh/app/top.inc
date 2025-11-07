<?php session_start(); ?>
<header id="header" class="alt">
    <a href="home.php"><h2 style="color: white; margin-left: 5px;">FactoryTicket</h2></a>
    <nav id="nav">
        <ul>
            <li><a href="home.php">Home</a></li>
            <?php
            $lgd = isset($_SESSION["uname"]);
            if ($lgd) {
                echo '<li><a href="#">Benvenuto '.$_SESSION["uname"].'</a></li>
                        <li><a href="tickets.php">Tickets</a></li>
                        <li><a href="logout.php">Logout</a></li>';
            }
            else {
                echo '<li><a href="login.php">Login</a></li>';
            }
            ?>
        </ul>
    </nav>
</header>