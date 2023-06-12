<?php

include_once("result_query.php");

class redeem {
    public $id;
    public $prize_id;
    public $player_id;

    public function __construct(){
    }

    public function set($data){
        $this->id = (int) $data->id;
        $this->prize_id = (int) $data->prize_id;
        $this->player_id = (int) $data->player_id;
    }
    
    public function add($db) {
        $result_query = new result_query();
        $result_query->data = "ok add";
        $query = "INSERT INTO redeem_table (prize_id, player_id) VALUES ('$this->prize_id','$this->player_id')";
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
        
        $query = "SELECT id, prize_id, player_id FROM redeem_table WHERE id='$this->id' LIMIT 1";
        $stmt = $db->query($query);
        if (!$stmt){
            $result_query->error = "error at query one : ".$stmt->error;
            $db->close();
            return $result_query;
        }

        $result = mysqli_fetch_assoc($stmt);
        if($result == null){
            $db->close();
            return $result_query;
        }

        if($result['id'] == null){
            $db->close();
            return $result_query;
        }

        $one = new redeem();
        $one->id = (int) $result['id'];
        $one->prize_id = (int) $result['prize_id'];
        $one->player_id = (int) $result['player_id'];
        $result_query->data = $one;
        $db->close();
        return $result_query;
    }
    
    public function all($db,$list_query) {
        $result_query = new result_query();
        $all = array();
        $query = "SELECT 
                    id, prize_id, player_id
                FROM 
                    redeem_table
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
            $one = new redeem();
            $one->id = (int) $result['id'];
            $one->prize_id = (int) $result['prize_id'];
            $one->player_id = (int) $result['player_id'];
            array_push($all,$one);
        }
        $result_query->data = $all;

        $db->close();
        return $result_query;
    }
 
    public function update($db) {
        $result_query = new result_query();
        $result_query->data = "ok update";
        $query = "UPDATE redeem_table SET prize_id = '$this->prize_id',player_id = '$this->player_id' WHERE id = '$this->id'";
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
        $query = "DELETE FROM redeem_table WHERE id = '$this->id'";
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