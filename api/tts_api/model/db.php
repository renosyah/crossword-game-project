<?php

function get_connection($configs){
    $username = $configs['username'];
    $password = $configs['password'];
    $host = $configs['host'];
    $port = $configs['port'];
    $dbname = $configs['name'];
    
    $db = new mysqli($host, $username, $password, $dbname, $port);
    if ($db->connect_error) {
        die("Connection failed: " . $db->connect_error);
    }
    return $db;
}

?>