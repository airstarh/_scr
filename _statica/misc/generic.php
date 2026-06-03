<?php

// Однострочный комментарий
# Альтернативный однострочный комментарий

/*
 * Многострочный комментарий
 * Для демонстрации подсветки комментариев разных типов
 */

/**
 * DocBlock-комментарий
 * Тестирует подсветку документации
 */

// Константы
define('APP_NAME', 'Test Application');
const MAX_ITEMS = 100;
const DEFAULT_OPTIONS = [
    'debug' => true,
    'timeout' => 30,
    'retries' => 3,
];

// Переменные разных типов
$stringVar = "Hello, World!";
$intVar = 42;
$floatVar = 3.14159;
$boolVar = true;
$nullVar = null;
$arrayVar = [1, 2, 3, 'key' => 'value'];
$objectVar = new stdClass();

// Ассоциативный массив с разными типами данных
$complexArray = [
    'strings' => ['apple', 'banana', 'cherry'],
    'numbers' => [1, 2, 3, 4.5, 6.7],
    'booleans' => [true, false, true],
    'nested' => [
        'level1' => [
            'level2' => ['deep' => 'value']
        ]
    ],
    'mixed' => [null, 'text', 123, [1, 2]],
];

// Анонимная функция
$anonymousFunction = function ($param1, $param2 = 'default') use ($stringVar) {
    return $param1 . ' ' . $param2 . ' ' . $stringVar;
};

// Стрелочная функция (PHP 7.4+)
$arrowFunction = fn($x, $y) => $x * $y;

// Условные конструкции
if ($boolVar && $intVar > 0) {
    echo "Condition 1 met";
} elseif (!$nullVar || $floatVar < 10) {
    echo "Condition 2 met";
} else {
    echo "Default condition";
}

// Switch-case
switch ($intVar) {
    case 42:
        echo "The answer";
        break;
    case 100:
        echo "Big number";
        break;
    default:
        echo "Something else";
}

// Циклы
for ($i = 0; $i < 5; $i++) {
    echo "For loop iteration: $i";
}

$j = 0;
while ($j < 3) {
    echo "While loop iteration: $j";
    $j++;
}

do {
    echo "Do-while loop";
} while (false);

foreach ($arrayVar as $key => $value) {
    echo "Key: $key, Value: $value";
}

// Оператор match (PHP 8.0+)
$result = match ($intVar) {
    42 => 'The ultimate answer',
    100 => 'Maximum value',
    default => 'Unknown value',
};

// Try-catch-finally
try {
    if (rand(0, 1)) {
        throw new Exception("Random exception occurred");
    }
    echo "Try block executed";
} catch (Exception $e) {
    echo "Caught exception: " . $e->getMessage();
} catch (InvalidArgumentException $e) {
    echo "Invalid argument: " . $e->getMessage();
} finally {
    echo "Finally block always executes";
}

// Объявление класса
class TestClass
{
    // Константы класса
    public const CLASS_CONST = 'class constant';
    private const PRIVATE_CONST = 'private constant';

    // Свойства
    public $publicProperty = 'public';
    protected $protectedProperty = 'protected';
    private $privateProperty = 'private';
    public static $staticProperty = 'static';

    /**
     * Summary of __construct
     * @param mixed $param
     */
    public function __construct($param = null)
    {
        $this->publicProperty = $param ?? 'default';
    }

    // Деструктор
    public function __destruct()
    {
        // Пустой деструктор
    }

    // Магические методы
    public function __get($name)
    {
        $a = 'never used';
        return $this->$name ?? null;
    }

    public function __set($name, $value)
    {
        $this->$name = $value;
    }

    // Обычный метод
    public function regularMethod(string $param1, int $param2 = 0): array
    {
        return [
            'param1' => $param1,
            'param2' => $param2,
            'timestamp' => time(),
        ];
    }

    // Статический метод
    public static function staticMethod(): string
    {
        return self::CLASS_CONST;
    }
}

// Интерфейс
interface TestInterface
{
    public function requiredMethod(string $input): bool;
    public function anotherMethod(): void;
}

// Трейт
trait TestTrait
{
    public function traitMethod(): string
    {
        return "This method comes from a trait";
    }
}

// Класс, использующий интерфейс и трейт
class ImplementingClass implements TestInterface
{
    use TestTrait;

    public function requiredMethod(string $input): bool
    {
        return strlen($input) > 0;
    }

    public function anotherMethod(): void
    {
        echo "Implementation of anotherMethod";
    }
}

// Анонимный класс
$anonymousClass = new class extends TestClass {
    public function customMethod(): string
    {
        return "Method from anonymous class";
    }
};

// Работа с исключениями
function throwExceptionIfNeeded(bool $shouldThrow): void
{
    if ($shouldThrow) {
        throw new RuntimeException("Something went wrong");
    }
}

// Вызов функций
try {
    throwExceptionIfNeeded(false);
} catch (RuntimeException $e) {
    error_log("Error: " . $e->getMessage());
}

// Closure и использование переменных по ссылке
$counter = 0;
$increment = function () use (&$counter) {
    $counter++;
    return $counter;
};

echo $increment(); // 1
echo $increment(); // 2

// Завершение скрипта
exit(0);

?>