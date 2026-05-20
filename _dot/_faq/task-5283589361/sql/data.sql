INSERT INTO
    categories (name)
VALUES
    ('Электроника'),
    ('Одежда'),
    ('Книги'),
    ('Спорт');

INSERT INTO
    products (name, price, category_id, in_stock, rating)
VALUES
    ('Смартфон Samsung', 29999.99, 1, TRUE, 4.8),
    ('Футболка синяя', 1499.50, 2, TRUE, 4.2),
    (
        'Книга "PHP для начинающих"',
        899.00,
        3,
        FALSE,
        4.5
    ),
    ('Кроссовки Nike', 5999.75, 4, TRUE, 4.7),
    ('Ноутбук ASUS', 69999.00, 1, TRUE, 4.9);