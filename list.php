<?php
    $jsonArray = [];
    $files = scandir('Files/');
    for ($x = 0; $x < count($files); $x++) {
        $fileName = $files[$x];
        $extension = pathinfo($files[$x], PATHINFO_EXTENSION);
        if ($extension == "eff") {
            array_push($jsonArray, $fileName);
        }
    }
    $jsonArray = array("files" => $jsonArray);
    header('Content-type: application/json');
    echo json_encode($jsonArray, JSON_PRETTY_PRINT);
?>