<?php 

header("Content-Type: application/json; charset=UTF-8");

include_once "../handler.php";
include("../../model/player.php");
include("../../model/db.php");

$data = handle_request();

$usr = new player();
$usr->set($data);

$check = $usr->one(get_connection(include("../config.php")));
if ($check->data != null){
    echo json_encode($check, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
    exit;
}

$result = $usr->add(get_connection(include("../config.php")));
$result->data = $data;

echo json_encode($result, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);

?>