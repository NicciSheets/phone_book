<?php case 'get_employee':
 	$id = isset($params['id']) && $params['id'] !='' ? $params['id'] : 0;
	$empCls->getEmployee($id);
 break;
function getEmployee($id) {
    $sql = "SELECT * FROM employee Where id=".$id;
	$queryRecords = pg_query($this->conn, $sql) or die("error to fetch employees data");
	$data = pg_fetch_object($queryRecords);
	echo json_encode($data);
  }
  case 'get_employee':
 	$id = isset($params['id']) && $params['id'] !='' ? $params['id'] : 0;
	$empCls->getEmployee($id);
 break;
function getEmployee($id) {
    $sql = "SELECT * FROM employee Where id=".$id;
	$queryRecords = pg_query($this->conn, $sql) or die("error to fetch employees data"); ?>

<?php case 'get_employee':
 	$id = isset($params['id']) && $params['id'] !='' ? $params['id'] : 0;
	$empCls->getEmployee($id);
 break;
function getEmployee($id) {
    $sql = "SELECT * FROM employee Where id=".$id;
	$queryRecords = pg_query($this->conn, $sql) or die("error to fetch employees data");
	$data = pg_fetch_object($queryRecords);
	echo json_encode($data);
  }
  case 'get_employee':
 	$id = isset($params['id']) && $params['id'] !='' ? $params['id'] : 0;
	$empCls->getEmployee($id);
 break;
function getEmployee($id) {
    $sql = "SELECT * FROM employee Where id=".$id;
	$queryRecords = pg_query($this->conn, $sql) or die("error to fetch employees data");
?>


