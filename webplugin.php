<?php 

$db_user = "";
$db_pswd = "";
$db_host = "";
$bd_name = "";
$connect = mysqli_connect($db_host, $db_user, $db_pswd, $bd_name);

$playerid = $_GET['pid'];

if($playerid == null || !is_numeric($playerid))
{
	die("系统错误 0x00008342");
}

if($result = mysqli_query($connect, "SELECT * FROM webinterface WHERE playerid=$playerid"))
{
	if($row = mysqli_fetch_array($result))
	{
		$url = $row['url'];
		$width = $row['width'];
		$height = $row['height'];
		$show = $row['show'];
	}
}

if($url == null)
{
	die("系统错误 0x00009427");
}

mysqli_close($connect);

echo '<html><head><title>CSGOGAMERS Motd</title></head><body>';

if($show == 1)
{
	echo '<script type=text/javascript>';
	echo 'window.open("'.$url.'", "", "toolbar=yes, fullscreen=yes, scrollbars=yes, width='.$width.', height='.$height.'");';
	echo '</script>';
}
else
{
	echo '<iframe src="'.$url.'" style="display:none;"></iframe>';
}

echo '</body></html>';

?>