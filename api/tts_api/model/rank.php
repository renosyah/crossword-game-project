<?php

include_once("result_query.php");

class rank {
    public $id;
    public $player_id;
    public $player_name;
    public $player_avatar;
    public $player_email;
    public $rank_level;

    public function __construct(){
    }

    public function set($data){
        $this->id = (int) $data->id;
        $this->player_id = $data->player_id;
        $this->player_name = $data->player_name;
        $this->player_avatar = $data->player_avatar;
        $this->player_email = $data->player_email;
        $this->rank_level = (int) $data->rank_level;
    }
    
    public function add($db) {
        $result_query = new result_query();
        $result_query->data = "ok add";
        $query = "INSERT INTO rank_table (player_id,player_name,player_avatar,player_email,rank_level) VALUES ('$this->player_id','$this->player_name','$this->player_avatar','$this->player_email','$this->rank_level')";
        $stmt = $db->query($query);
        if (!$stmt){
            $result_query->error = "error at add new : ".$stmt->error;
            $result_query->data = "not ok";
            $db->close();
            return $result_query;
        }

        $db->close();
        return $result_query;
    }
    
    public function one($db) {
        $result_query = new result_query();
        
        $query = "SELECT id,player_id,player_name,player_avatar,player_email,rank_level FROM rank_table WHERE player_id='$this->player_id' LIMIT 1";
        $stmt = $db->query($query);
        if (!$stmt){
            $result_query->error = "error at query one : ".$stmt->error;
            $db->close();
            return $result_query;
        }

        $result = mysqli_fetch_assoc($stmt);
        if($result['id'] == null){
            $db->close();
            return $result_query;
        }

        $one = new rank();
        $one->id = (int) $result['id'];
        $one->player_id = $result['player_id'];
        $one->player_name = $result['player_name'];
        $one->player_avatar = $result['player_avatar'];
        $one->player_email = $result['player_email'];
        $one->rank_level = (int) $result['rank_level'];
        $result_query->data = $one;
        $db->close();
        return $result_query;
    }
 
    public function all($db,$list_query) {
        $result_query = new result_query();
        $all = array();
        $query = "SELECT 
                    id,player_id,player_name,player_avatar,player_email,rank_level
                FROM 
                    rank_table
                WHERE
                    ".$list_query->search_by." LIKE '%".$list_query->search_value."%'
                ORDER BY
                    ".$list_query->order_by." ".$list_query->order_dir." 
                LIMIT $list_query->limit OFFSET $list_query->offset";

        $stmt = $db->query($query);
        if (!$stmt){
            $result_query->error = "error at query one score : ".$stmt->error;
            $db->close();
            return $result_query;
        }

        if($stmt->num_rows == 0){
            $db->close();
            $result_query->data = $all;
            return $result_query;
        }

        while ($result = $stmt->fetch_array()){
            $one = new rank();
            $one->id = (int) $result['id'];
            $one->player_id = $result['player_id'];
            $one->player_name = $result['player_name'];
            $one->player_avatar = $result['player_avatar'];
            $one->player_email = $result['player_email'];
            $one->rank_level = (int) $result['rank_level'];
            array_push($all,$one);
        }
        $result_query->data = $all;

        $db->close();
        return $result_query;
    }
 
    public function update($db) {
        $result_query = new result_query();
        $result_query->data = "ok update";
        $query = "UPDATE rank_table SET player_id = '$this->player_id',player_name = '$this->player_name',player_avatar = '$this->player_avatar',player_email = '$this->player_email',rank_level = '$this->rank_level' WHERE id = '$this->id'";
        $stmt = $db->query($query);
        if (!$stmt){
            $result_query->error = "error at update : ".$stmt->error;
            $result_query->data = "not ok";
            $db->close();
            return $result_query;
        }

        $db->close();
        return $result_query;
    }
    
    public function delete($db) {
        $result_query = new result_query();
        $result_query->data = "ok";
        $query = "DELETE FROM rank_table WHERE id = '$this->id'";
        $stmt = $db->query($query);
        if (!$stmt){
            $result_query->error = "error at delete : ".$stmt->error;
            $result_query->data = "not ok";
            $db->close();
            return $result_query;
        }

        $db->close();
        return $result_query;
    }
}


?>