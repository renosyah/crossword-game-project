<?php

include_once("result_query.php");

class banner {
    public $id;
    public $banner_name;
    public $banner_image_url;

    public function __construct(){
    }

    public function set($data){
        $this->id = (int) $data->id;
        $this->banner_name = $data->banner_name;
        $this->banner_image_url = $data->banner_image_url;
    }
    
    public function add($db) {
        $result_query = new result_query();
        $result_query->data = "ok add";
        $query = "INSERT INTO banner_table (banner_name,banner_image_url) VALUES ('$this->banner_name','$this->banner_image_url')";
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
        
        $query = "SELECT id,banner_name,banner_image_url FROM banner_table WHERE id='$this->id' LIMIT 1";
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

        $one = new banner();
        $one->id = (int) $result['id'];
        $one->banner_name = $result['banner_name'];
        $one->banner_image_url = $result['banner_image_url'];
        $result_query->data = $one;
        $db->close();
        return $result_query;
    }
    
    public function all($db,$list_query) {
        $result_query = new result_query();
        $all = array();
        $query = "SELECT 
                    id,banner_name,banner_image_url
                FROM 
                    banner_table
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
            $one = new banner();
            $one->id = (int) $result['id'];
            $one->banner_name = $result['banner_name'];
            $one->banner_image_url = $result['banner_image_url'];
            array_push($all,$one);
        }
        $result_query->data = $all;

        $db->close();
        return $result_query;
    }
 
    public function update($db) {
        $result_query = new result_query();
        $result_query->data = "ok update";
        $query = "UPDATE banner_table SET banner_name = '$this->banner_name',banner_image_url = '$this->banner_image_url' WHERE id = '$this->id'";
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
        $query = "DELETE FROM banner_table WHERE id = '$this->id'";
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