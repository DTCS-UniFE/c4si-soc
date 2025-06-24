<!DOCTYPE HTML>
<html>
	<head>
		<title>Login amministratore</title>
		<meta charset="utf-8" />
		<meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no" />
		<link rel="stylesheet" href="../assets/css/main.css" />
	</head>
	<body class="landing is-preload">
		<div id="page-wrapper">
			<header id="header">
				<a href="../home.php" ><h2 style="color: white; margin-left: 5px;">UnifeTicket</h2></a>
				<nav id="nav">
					<ul>
						<li><a href="home.php">Home</a></li>
						<li><a href="login.php" class="button">Accedi</a></li>
					</ul>
				</nav>
			</header>
			<section id="main" class="container">
				<div class="row">
					<div class="col-12">
						<section class="box">
							<div class="row gtr-uniform">
								<div class="col-12 col-12-mobile">
									<h2>Login amministratore</h2>
								</div>
								<?php
									if (isset($_GET['error']) && $_GET['error'] != '') {
										echo '<div class="col-12 col-12-mobile">
									<h3 class="error">'.$_GET['error'].'</h3>
								</div>';
									}
								?>
							</div>
							<br>
							<form action="confirmLogin.php" method="post" class="row gtr-uniform">
								<div class="col-6 col-12-mobile">
									<label for="username">Username:</label>
									<input type="text" id="username" name="username" autocomplete="username"/>
								</div>
								<div class="col-6 col-12-mobile">
									<label for="password">Password:</label>
									<input type="password" id="password" name="password" autocomplete="password"/>
								</div>
								<div class="col-6 col-12-mobile">
									<input type="submit" value="Accedi"/>
								</div>
								<div class="col-6 col-12-mobile">
									<a href="register.php" class="button">Registrati</a>
								</div>
							</form>
						</section>
					</div>
				</div>
			</section>
		</div>
	</body>
</html>