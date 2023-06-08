<?php

class list_query {
    public $search_by;
    public $search_value;
    public $order_by;
    public $order_dir;
    public $offset;
    public $limit;

    public function __construct(){
    }

    public function set($data){
        $this->search_by = $data->search_by;
        $this->search_value = $data->search_value;
        $this->order_by = $data->order_by;
        $this->order_dir = $data->order_dir;
        $this->offset = (int)$data->offset;
        $this->limit = (int)$data->limit;
    }
}

?>