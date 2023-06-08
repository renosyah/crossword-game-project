<?php 

function handle_request(){
    $json = file_get_contents('php://input');
    $data = json_decode($json);
    return $data;
}

?>