<?php 

header("Content-Type: application/json; charset=UTF-8");

include_once "../handler.php";
include("../../model/rank.php");
include("../../model/db.php");

$data = handle_request();

$usr = new rank();
$usr->set($data);

// if exist just update rank level
$check = $usr->one(get_connection(include("../config.php")));
if ($check->data != null){
    $check->data->rank_level = $usr->rank_level;
    $usr->set($check->data);
    $result = $usr->update(get_connection(include("../config.php")));

    echo json_encode($result, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
    exit;
}

$result = $usr->add(get_connection(include("../config.php")));

echo json_encode($result, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);

?>