<?php 

header("Content-Type: application/json; charset=UTF-8");
include_once "../handler.php";
include("../../model/prize.php");
include("../../model/db.php");
include("../../model/list_query.php");

$data = handle_request();
$query = new list_query();
$query->set($data);

$usr = new prize();
$result = $usr->all(get_connection(include("../config.php")),$query);

echo json_encode($result, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);

?>