<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');

// Конфигурация БД
$host = 'localhost';
$dbname = 'your_database';
$username = 'your_username';
$password = 'your_password';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Database connection failed']);
    exit;
}

// Параметры пагинации
$page = isset($_GET['page']) ? (int) $_GET['page'] : 1;
$limit = isset($_GET['limit']) ? (int) $_GET['limit'] : 10;
$offset = ($page - 1) * $limit;

// Фильтрация
$where = [];
$params = [];

if (isset($_GET['q']) && !empty($_GET['q'])) {
    $search = '%' . $_GET['q'] . '%';
    $where[] = 'name LIKE ?';
    $params[] = $search;
}

if (isset($_GET['price_from'])) {
    $where[] = 'price >= ?';
    $params[] = (float) $_GET['price_from'];
}

if (isset($_GET['price_to'])) {
    $where[] = 'price <= ?';
    $params[] = (float) $_GET['price_to'];
}

if (isset($_GET['category_id'])) {
    $where[] = 'category_id = ?';
    $params[] = (int) $_GET['category_id'];
}

if (isset($_GET['in_stock'])) {
    $inStock = filter_var($_GET['in_stock'], FILTER_VALIDATE_BOOLEAN);
    $where[] = 'in_stock = ?';
    $params[] = $inStock ? 1 : 0;
}

if (isset($_GET['rating_from'])) {
    $where[] = 'rating >= ?';
    $params[] = (float) $_GET['rating_from'];
}

$whereClause = !empty($where) ? 'WHERE ' . implode(' AND ', $where) : '';

// Сортировка
$sort = isset($_GET['sort']) ? $_GET['sort'] : 'newest';
$orderBy = match ($sort) {
    'price_asc' => 'price ASC',
    'price_desc' => 'price DESC',
    'rating_desc' => 'rating DESC',
    'newest' => 'created_at DESC',
    default => 'created_at DESC'
};

// Основной запрос для получения товаров
$sql = "SELECT * FROM products $whereClause ORDER BY $orderBy LIMIT ? OFFSET ?";
$stmt = $pdo->prepare($sql);
$stmt->execute(array_merge($params, [$limit, $offset]));
$products = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Запрос для подсчёта общего количества товаров
$countSql = "SELECT COUNT(*) FROM products $whereClause";
$countStmt = $pdo->prepare($countSql);
$countStmt->execute($params);
$totalCount = $countStmt->fetchColumn();

// Формирование ответа
$response = [
    'data' => $products,
    'pagination' => [
        'current_page' => $page,
        'per_page' => $limit,
        'total' => $totalCount,
        'total_pages' => ceil($totalCount / $limit)
    ]
];

echo json_encode($response, JSON_UNESCAPED_UNICODE);
?>