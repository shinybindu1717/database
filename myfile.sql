-- ============================================================
-- FRUITS MARKET DATABASE
-- Consolidated SQL file: schema, data, and queries
-- ============================================================

-- ------------------------------------------------------------
-- 1. DATABASE SETUP
-- ------------------------------------------------------------
DROP DATABASE IF EXISTS fruits_market;
CREATE DATABASE fruits_market;
USE fruits_market;

-- ------------------------------------------------------------
-- 2. TABLE DEFINITIONS
-- ------------------------------------------------------------

-- Categories table (e.g., Citrus, Tropical, Berries)
CREATE TABLE categories (
    category_id     INT AUTO_INCREMENT PRIMARY KEY,
    category_name   VARCHAR(50) NOT NULL UNIQUE,
    description     VARCHAR(255)
);

-- Suppliers table
CREATE TABLE suppliers (
    supplier_id     INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name   VARCHAR(100) NOT NULL,
    country         VARCHAR(50),
    contact_email   VARCHAR(100)
);

-- Fruits table
CREATE TABLE fruits (
    fruit_id        INT AUTO_INCREMENT PRIMARY KEY,
    fruit_name      VARCHAR(50) NOT NULL,
    category_id     INT,
    supplier_id     INT,
    unit            ENUM('kg','lb','piece','dozen') DEFAULT 'kg',
    stock_quantity  INT DEFAULT 0,
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

-- Prices table (historical pricing)
CREATE TABLE prices (
    price_id        INT AUTO_INCREMENT PRIMARY KEY,
    fruit_id        INT NOT NULL,
    price           DECIMAL(8,2) NOT NULL,
    market_location VARCHAR(100),
    recorded_date   DATE NOT NULL,
    FOREIGN KEY (fruit_id) REFERENCES fruits(fruit_id) ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- 3. SAMPLE DATA
-- ------------------------------------------------------------

INSERT INTO categories (category_name, description) VALUES
('Citrus',   'Fruits rich in citric acid'),
('Tropical', 'Fruits grown in tropical climates'),
('Berries',  'Small, pulpy, edible fruits'),
('Stone',    'Fruits with a single hard stone/seed'),
('Pome',     'Fruits with a central seed core');

INSERT INTO suppliers (supplier_name, country, contact_email) VALUES
('FreshFarms Co.',   'USA',    'sales@freshfarms.com'),
('Tropical Harvest', 'Mexico', 'info@tropicalharvest.mx'),
('EuroFruit Ltd.',   'Spain',  'orders@eurofruit.es'),
('AsiaFresh Inc.',   'India',  'contact@asiafresh.in');

INSERT INTO fruits (fruit_name, category_id, supplier_id, unit, stock_quantity) VALUES
('Orange',      1, 1, 'kg',     500),
('Lemon',       1, 3, 'kg',     300),
('Lime',        1, 2, 'kg',     200),
('Banana',      2, 2, 'kg',     800),
('Mango',       2, 4, 'kg',     450),
('Pineapple',   2, 2, 'piece',  150),
('Strawberry',  3, 1, 'kg',     120),
('Blueberry',   3, 3, 'kg',     90),
('Raspberry',   3, 1, 'kg',     75),
('Peach',       4, 3, 'kg',     260),
('Plum',        4, 3, 'kg',     180),
('Cherry',      4, 1, 'kg',     140),
('Apple',       5, 1, 'kg',     700),
('Pear',        5, 3, 'kg',     350);

INSERT INTO prices (fruit_id, price, market_location, recorded_date) VALUES
(1,  2.50, 'New York',    '2024-01-15'),
(1,  2.75, 'New York',    '2024-02-15'),
(2,  3.00, 'New York',    '2024-01-15'),
(3,  2.20, 'Los Angeles', '2024-01-15'),
(4,  1.10, 'New York',    '2024-01-15'),
(4,  1.25, 'New York',    '2024-02-15'),
(5,  4.50, 'Los Angeles', '2024-01-15'),
(6,  3.75, 'Miami',       '2024-01-15'),
(7,  5.00, 'New York',    '2024-01-15'),
(8,  8.50, 'New York',    '2024-01-15'),
(9,  7.20, 'Chicago',     '2024-01-15'),
(10, 3.40, 'Chicago',     '2024-01-15'),
(11, 2.90, 'Chicago',     '2024-01-15'),
(12, 6.80, 'New York',    '2024-01-15'),
(13, 1.80, 'New York',    '2024-01-15'),
(14, 2.10, 'Chicago',     '2024-01-15');

-- ------------------------------------------------------------
-- 4. QUERIES
-- ------------------------------------------------------------

-- Q1: List all fruits with category and unit
SELECT f.fruit_id, f.fruit_name, c.category_name, f.unit, f.stock_quantity
FROM fruits f
JOIN categories c ON f.category_id = c.category_id
ORDER BY c.category_name, f.fruit_name;

-- Q2: Current price list for each fruit (latest recorded price)
SELECT f.fruit_name, p.price, f.unit, p.market_location, p.recorded_date
FROM fruits f
JOIN prices p ON f.fruit_id = p.fruit_id
WHERE p.recorded_date = (
    SELECT MAX(p2.recorded_date)
    FROM prices p2
    WHERE p2.fruit_id = f.fruit_id
)
ORDER BY f.fruit_name;

-- Q3: Average price per fruit
SELECT f.fruit_name, ROUND(AVG(p.price), 2) AS avg_price
FROM fruits f
JOIN prices p ON f.fruit_id = p.fruit_id
GROUP BY f.fruit_name
ORDER BY avg_price DESC;

-- Q4: Average price per category
SELECT c.category_name, ROUND(AVG(p.price), 2) AS avg_price
FROM categories c
JOIN fruits f   ON c.category_id = f.category_id
JOIN prices p   ON f.fruit_id    = p.fruit_id
GROUP BY c.category_name
ORDER BY avg_price DESC;

-- Q5: Fruits with price above overall average
SELECT f.fruit_name, p.price
FROM fruits f
JOIN prices p ON f.fruit_id = p.fruit_id
WHERE p.price > (SELECT AVG(price) FROM prices)
ORDER BY p.price DESC;

-- Q6: Cheapest fruit per market location
SELECT p.market_location, f.fruit_name, MIN(p.price) AS cheapest_price
FROM prices p
JOIN fruits f ON p.fruit_id = f.fruit_id
GROUP BY p.market_location
ORDER BY p.market_location;

-- Q7: Price change (increase/decrease) between records
SELECT f.fruit_name,
       p1.recorded_date AS old_date,
       p1.price         AS old_price,
       p2.recorded_date AS new_date,
       p2.price         AS new_price,
       (p2.price - p1.price) AS price_change
FROM prices p1
JOIN prices p2 ON p1.fruit_id = p2.fruit_id AND p2.recorded_date > p1.recorded_date
JOIN fruits f  ON f.fruit_id  = p1.fruit_id
ORDER BY f.fruit_name, p2.recorded_date;

-- Q8: Fruits supplied by each supplier
SELECT s.supplier_name, s.country, GROUP_CONCAT(f.fruit_name SEPARATOR ', ') AS fruits
FROM suppliers s
LEFT JOIN fruits f ON s.supplier_id = f.supplier_id
GROUP BY s.supplier_id;

-- Q9: Total inventory value per fruit (latest price * stock)
SELECT f.fruit_name,
       f.stock_quantity,
       (SELECT p.price FROM prices p
        WHERE p.fruit_id = f.fruit_id
        ORDER BY p.recorded_date DESC LIMIT 1) AS latest_price,
       f.stock_quantity * (SELECT p.price FROM prices p
                           WHERE p.fruit_id = f.fruit_id
                           ORDER BY p.recorded_date DESC LIMIT 1) AS inventory_value
FROM fruits f
ORDER BY inventory_value DESC;

-- Q10: Price range (min, max, avg) per category
SELECT c.category_name,
       MIN(p.price) AS min_price,
       MAX(p.price) AS max_price,
       ROUND(AVG(p.price), 2) AS avg_price
FROM categories c
JOIN fruits f ON c.category_id = f.category_id
JOIN prices p ON f.fruit_id    = p.fruit_id
GROUP BY c.category_name;

-- Q11: Fruits with no recorded prices
SELECT f.fruit_name
FROM fruits f
LEFT JOIN prices p ON f.fruit_id = p.fruit_id
WHERE p.price_id IS NULL;

-- Q12: Most expensive fruit overall
SELECT f.fruit_name, p.price, p.market_location, p.recorded_date
FROM prices p
JOIN fruits f ON f.fruit_id = p.fruit_id
ORDER BY p.price DESC
LIMIT 1;

-- Q13: Total stock grouped by unit type
SELECT unit, SUM(stock_quantity) AS total_stock
FROM fruits
GROUP BY unit;

-- Q14: Search fruits by name (parameterized example)
-- Replace ? with desired search term, e.g., 'ber'
SELECT fruit_name, unit, stock_quantity
FROM fruits
WHERE fruit_name LIKE '%?%';

-- Q15: Update price for a specific fruit and date
-- Example: raise Orange price by 10%
UPDATE prices
SET price = price * 1.10
WHERE fruit_id = (SELECT fruit_id FROM fruits WHERE fruit_name = 'Orange')
  AND recorded_date = '2024-02-15';

-- Q16: Insert a new price record
INSERT INTO prices (fruit_id, price, market_location, recorded_date)
VALUES ((SELECT fruit_id FROM fruits WHERE fruit_name = 'Apple'),
        2.00, 'Boston', CURDATE());

-- Q17: Delete prices older than a given date
DELETE FROM prices
WHERE recorded_date < '2023-01-01';

-- ------------------------------------------------------------
-- 5. VIEWS
-- ------------------------------------------------------------

CREATE OR REPLACE VIEW v_current_prices AS
SELECT f.fruit_id, f.fruit_name, c.category_name, p.price, f.unit,
       p.market_location, p.recorded_date
FROM fruits f
JOIN categories c ON f.category_id = c.category_id
JOIN prices p     ON f.fruit_id    = p.fruit_id
WHERE p.recorded_date = (
    SELECT MAX(p2.recorded_date) FROM prices p2 WHERE p2.fruit_id = f.fruit_id
);

-- Usage: SELECT * FROM v_current_prices ORDER BY price DESC;

CREATE OR REPLACE VIEW v_category_summary AS
SELECT c.category_name,
       COUNT(DISTINCT f.fruit_id) AS fruit_count,
       ROUND(AVG(p.price), 2)     AS avg_price
FROM categories c
JOIN fruits f ON c.category_id = f.category_id
JOIN prices p ON f.fruit_id    = p.fruit_id
GROUP BY c.category_name;

-- Usage: SELECT * FROM v_category_summary;

-- ------------------------------------------------------------
-- END OF FILE
-- ------------------------------------------------------------
