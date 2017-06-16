<html> 
    <head> 
        <title>CSGO Webshortcuts</title> 
    </head> 
    <body> 
        <script type="text/javascript" > 
                window.open("<?php 
					//Set Your Credentials here
					$pdo = new PDO('mysql:host=localhost;dbname=dbname', 'user', 'password');
					$statement = $pdo->prepare("SELECT url FROM urls WHERE serverid = ? AND steamid = ?");
					$statement->execute(array($_GET["serverid"], $_GET["userid"]));   
					$row = $statement->fetch();
						echo $row['url'];
					?>", "_blank", "toolbar=yes, fullscreen=yes, scrollbars=yes, width=" + screen.width + ", height=" + (screen.height - 72)); 
        </script> 
    </body> 
</html>