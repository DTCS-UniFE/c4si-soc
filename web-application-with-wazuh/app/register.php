<!DOCTYPE HTML>
<html>
	<head>
		<title>Registrati</title>
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
									<h2>Registra un nuovo account</h2>
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
							<form action="confirmRegister.php" method="POST" enctype="utf8" class="row gtr-uniform">
								<div class="col-6 col-12-mobile">
									<label>Username:</label>
									<input type="text" autocomplete="username" id="username" name="username" placeholder="il tuo username" required/>
								</div>
								<div class="col-6 col-12-mobile">
									<label>Password (minimo 4 caratteri):</label>
									<input type="password" id="password" name="password" pattern="\S{4,}" autocomplete="new-password" placeholder="Minimo 4 caratteri" minlength="4" required/>
								</div>
								<div class="col-6 col-12-mobile">
									<label>Confema Password:</label>
									<input type="password" id="cpassword" name="cpassword" pattern="\S{4,}" placeholder="Minimo 4 caratteri" minlength="4" required/>
								</div>
								<div class="col-6 col-12-mobile">
									<br>
									<br>
									<input type="checkbox" id="mostra" name="mostra" onclick="viewPass()"/>
									<label for="mostra">Mostra password</label>
								</div>
								<div class="col-12 col-12-mobile" id="message">
									<h3>La password deve:</h3>
									<h4 id="length" class="invalid"><i id="l1" class='far fa-times-circle fa-2x'></i>Avere minimo 4 caratteri</h4>
								</div>
								<div class="col-12 col-12-mobile">
									<input type="submit" value="Registrati"/>
								</div>
							</form>
							<div class="col-12 col-12-mobile"><hr></div>
						</section>
					</div>
				</div>
			</section>
		</div>
		<script>
		
function viewPass() {
    let x = document.getElementById("password");
    if (x.type === "password") {
    	x.type = "text";
	} else {
		x.type = "password";
	}
}

let myInput = document.getElementById("password");
myInput.onfocus = function() {
  document.getElementById("message").style.display = "block";
}
myInput.onblur = function() {
  document.getElementById("message").style.display = "none";
}
myInput.onkeyup = function() {
  // Validate length
  if(myInput.value.length >= 4) {
    myInput.classList.remove("invalid");
    myInput.classList.add("valid");
  } else {
    myInput.classList.remove("valid");
    myInput.classList.add("invalid");
  }
}
</script>
	</body>
</html>