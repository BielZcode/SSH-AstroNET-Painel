<?php
// Defina suas credenciais de banco de dados
$servername = "localhost"; // ou o endereço do seu servidor de banco de dados
$username = "root";
$password = "";
$database = "clientes";

// Cria a conexão
$conn = new mysqli($servername, $username, $password, $database);

// Verifica a conexão
if ($conn->connect_error) {
    die("Erro na conexão: " . $conn->connect_error);
}

// Agora você pode usar $conn para executar suas consultas SQL
?>
