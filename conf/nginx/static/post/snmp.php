<?php
$ip = $_POST['clientips'];
$privkey = $_POST['privkey'];
$authkey = $_POST['authkey'];

$fp = fopen('/ROOT/conf/nginx/static/data/snmpd.xml', 'r+')or die("文件打开失败");
fseek($fp, -10, SEEK_END);
fwrite($fp, "<device ip=\"$ip\" authkey=\"$authkey\" privkey=\"$privkey\" version=\"3\" />\n");
fwrite($fp, "</config>\n");
fclose($fp);
