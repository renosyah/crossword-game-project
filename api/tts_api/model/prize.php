<?php

include_once("result_query.php");

class prize {
    public $id;
    public $prize_name;
    public $prize_image_url;
    public $prize_level;
    public $background_color;

    public function __construct(){
    }

    public function set($data){
        $this->id = (int) $data->id;
        $this->prize_name = $data->prize_name;
        $this->prize_image_url = $data->prize_image_url;
        $this->prize_level = $data->prize_level;
        $this->background_color = $data->background_color;
    }
    
    public function add($db) {
        $result_query = new result_query();
        $result_query->data = "ok add";
        $query = "INSERT INTO prize_table (prize_name,prize_image_url,prize_level, background_color) VALUES ('$this->prize_name','$this->prize_image_url','$this->prize_level', '$this->background_color')";
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
        
        $query = "SELECT id,prize_name,prize_image_url,prize_level,background_color FROM prize_table WHERE id='$this->id' LIMIT 1";
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

        $one = new prize();
        $one->id = (int) $result['id'];
        $one->prize_name = $result['prize_name'];
        $one->prize_image_url = $result['prize_image_url'];
        $one->prize_level = $result['prize_level'];
        $one->background_color = $result['background_color'];
        $result_query->data = $one;
        $db->close();
        return $result_query;
    }
    
    public function all($db,$list_query) {
        $result_query = new result_query();
        $all = array();
        $query = "SELECT 
                    id,prize_name,prize_image_url,prize_level,background_color
                FROM 
                    prize_table
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
            $one = new prize();
            $one->id = (int) $result['id'];
            $one->prize_name = $result['prize_name'];
            $one->prize_image_url = $result['prize_image_url'];
            $one->prize_level = $result['prize_level'];
            $one->background_color = $result['background_color'];
            array_push($all,$one);
        }
        $result_query->data = $all;

        $db->close();
        return $result_query;
    }
 
    public function update($db) {
        $result_query = new result_query();
        $result_query->data = "ok update";
        $query = "UPDATE prize_table SET prize_name = '$this->prize_name',prize_image_url = '$this->prize_image_url',prize_level = '$this->prize_level', background_color = '$this->background_color' WHERE id = '$this->id'";
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
        $query = "DELETE FROM prize_table WHERE id = '$this->id'";
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