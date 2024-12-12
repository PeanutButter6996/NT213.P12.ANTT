<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $url = $_POST['url'] ?? '';

    echo "<pre>";
    echo "Sending request to: " . htmlspecialchars($url) . "\n";

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_FAILONERROR, true);

    // Execute the request
    $response = curl_exec($ch);

    // Check for errors
    if ($response === false) {
        echo "cURL Error: " . curl_error($ch) . "\n";
    } else {
        echo htmlspecialchars($response);
    }
    // Close the cURL handle
    curl_close($ch);
    echo "</pre>";
    } 
    
    else {
    echo "Invalid URL. Please ensure it includes a valid protocol (http, https, gopher).";
    }

?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SSRF Challenge</title>
</head>
<body>
    <h1>SSRF Challenge</h1>
    <form method="POST">
        <label for="url">Enter URL:</label>
        <input type="text" id="url" name="url" placeholder="e.g., Enter something here ..." required>
        <button type="submit">Fetch</button>
    </form>
</body>
</html>

