-- SECTION 1: DATABASE CREATION

CREATE DATABASE IF NOT EXISTS hotel_reservation_db;
USE hotel_reservation_db;

-- SECTION 2: TABLE CREATION

-- Table 1: ROOM_TYPES
CREATE TABLE room_types (
    type_id        INT            PRIMARY KEY AUTO_INCREMENT,
    type_name      VARCHAR(50)    NOT NULL UNIQUE,
    description    TEXT,
    max_occupancy  INT            NOT NULL CHECK (max_occupancy > 0),
    created_at     TIMESTAMP      DEFAULT CURRENT_TIMESTAMP
);

-- Table 2: ROOMS
CREATE TABLE rooms (
    room_id         INT            PRIMARY KEY AUTO_INCREMENT,
    type_id         INT            NOT NULL,
    room_number     VARCHAR(10)    NOT NULL UNIQUE,
    floor_number    INT            NOT NULL CHECK (floor_number >= 0),
    price_per_night DECIMAL(10,2)  NOT NULL CHECK (price_per_night > 0),
    status          ENUM('available','occupied','maintenance') DEFAULT 'available',
    view_type       VARCHAR(50),
    created_at      TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (type_id) REFERENCES room_types(type_id) ON DELETE RESTRICT
);

-- Table 3: CUSTOMERS
CREATE TABLE customers (
    customer_id   INT           PRIMARY KEY AUTO_INCREMENT,
    full_name     VARCHAR(100)  NOT NULL,
    email         VARCHAR(100)  NOT NULL UNIQUE,
    phone         VARCHAR(20),
    city          VARCHAR(100),
    country       VARCHAR(50)   DEFAULT 'Germany',
    date_of_birth DATE,
    created_at    TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
);

-- Table 4: EMPLOYEES
CREATE TABLE employees (
    employee_id  INT           PRIMARY KEY AUTO_INCREMENT,
    full_name    VARCHAR(100)  NOT NULL,
    role         VARCHAR(50)   NOT NULL,
    department   VARCHAR(50),
    phone        VARCHAR(20),
    email        VARCHAR(100)  UNIQUE,
    salary       DECIMAL(10,2) CHECK (salary > 0),
    hire_date    DATE,
    created_at   TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
);

-- Table 5: BOOKINGS
CREATE TABLE bookings (
    booking_id     INT          PRIMARY KEY AUTO_INCREMENT,
    customer_id    INT          NOT NULL,
    room_id        INT          NOT NULL,
    employee_id    INT,
    check_in_date  DATE         NOT NULL,
    check_out_date DATE         NOT NULL,
    num_guests     INT          NOT NULL DEFAULT 1 CHECK (num_guests > 0),
    status         ENUM('confirmed','cancelled','completed','no-show') DEFAULT 'confirmed',
    special_notes  TEXT,
    created_at     TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE RESTRICT,
    FOREIGN KEY (room_id)     REFERENCES rooms(room_id)         ON DELETE RESTRICT,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE SET NULL,
    CHECK (check_out_date > check_in_date)
);

-- Table 6: PAYMENTS
CREATE TABLE payments (
    payment_id     INT            PRIMARY KEY AUTO_INCREMENT,
    booking_id     INT            NOT NULL UNIQUE,
    amount         DECIMAL(10,2)  NOT NULL CHECK (amount > 0),
    payment_method ENUM('credit_card','debit_card','bank_transfer','cash','paypal') NOT NULL,
    payment_status ENUM('pending','completed','refunded','failed') DEFAULT 'pending',
    payment_date   DATETIME       DEFAULT CURRENT_TIMESTAMP,
    transaction_id VARCHAR(100),
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE
);

-- SECTION 3: INDEXES FOR PERFORMANCE

CREATE INDEX idx_bookings_customer   ON bookings(customer_id);
CREATE INDEX idx_bookings_room       ON bookings(room_id);
CREATE INDEX idx_bookings_dates      ON bookings(check_in_date, check_out_date);
CREATE INDEX idx_bookings_status     ON bookings(status);
CREATE INDEX idx_rooms_type          ON rooms(type_id);
CREATE INDEX idx_rooms_status        ON rooms(status);
CREATE INDEX idx_payments_status     ON payments(payment_status);
CREATE INDEX idx_customers_email     ON customers(email);

-- SECTION 4: DATA INSERTION

-- 4.1 Room Types (6 types)
INSERT INTO room_types (type_name, description, max_occupancy) VALUES
('Standard Single',  'Comfortable single room with basic amenities',                     1),
('Standard Double',  'Spacious room with one double bed, ideal for couples',              2),
('Twin Room',        'Room with two single beds, ideal for friends or colleagues',        2),
('Deluxe Suite',     'Luxurious suite with separate living area and premium amenities',   3),
('Family Room',      'Large room designed for families with extra beds available',        4),
('Penthouse Suite',  'Top-floor suite with panoramic city view and private terrace',      4);

-- 4.2 Rooms (18 rooms)
INSERT INTO rooms (type_id, room_number, floor_number, price_per_night, status, view_type) VALUES
(1, '101', 1,  89.00,  'available',    'Garden view'),
(1, '102', 1,  89.00,  'available',    'Street view'),
(2, '201', 2, 129.00,  'occupied',     'Garden view'),
(2, '202', 2, 135.00,  'available',    'City view'),
(2, '203', 2, 130.00,  'available',    'Street view'),
(3, '204', 2, 120.00,  'available',    'Garden view'),
(3, '301', 3, 125.00,  'occupied',     'City view'),
(3, '302', 3, 120.00,  'maintenance',  'Street view'),
(4, '401', 4, 249.00,  'available',    'City view'),
(4, '402', 4, 259.00,  'occupied',     'River view'),
(4, '403', 4, 245.00,  'available',    'City view'),
(5, '501', 5, 199.00,  'available',    'Garden view'),
(5, '502', 5, 205.00,  'occupied',     'City view'),
(5, '503', 5, 199.00,  'available',    'Street view'),
(6, '601', 6, 499.00,  'available',    'Panoramic city view'),
(6, '602', 6, 549.00,  'occupied',     'Panoramic river view'),
(2, '103', 1, 119.00,  'available',    'Garden view'),
(1, '104', 1,  85.00,  'available',    'Courtyard view');

-- 4.3 Customers (18 customers)
INSERT INTO customers (full_name, email, phone, city, date_of_birth) VALUES
('Klaus Müller',       'k.mueller@gmail.com',      '+49 30 12345678',  'Berlin',        '1985-03-14'),
('Sabine Hoffmann',    's.hoffmann@web.de',         '+49 89 23456789',  'München',       '1990-07-22'),
('Thomas Schneider',   't.schneider@gmx.de',        '+49 40 34567890',  'Hamburg',       '1978-11-05'),
('Erika Fischer',      'e.fischer@t-online.de',     '+49 221 4567890',  'Köln',          '1995-01-30'),
('Wolfgang Wagner',    'w.wagner@outlook.de',       '+49 711 5678901',  'Stuttgart',     '1982-09-18'),
('Heike Becker',       'h.becker@freenet.de',       '+49 201 6789012',  'Essen',         '1988-05-25'),
('Jürgen Braun',       'j.braun@posteo.de',         '+49 351 7890123',  'Dresden',       '1975-12-08'),
('Monika Weber',       'm.weber@yahoo.de',          '+49 511 8901234',  'Hannover',      '1992-04-16'),
('Günter Koch',        'g.koch@protonmail.com',     '+49 431 9012345',  'Kiel',          '1980-08-29'),
('Ursula Bauer',       'u.bauer@gmail.com',         '+49 621 0123456',  'Mannheim',      '1993-02-11'),
('Dieter Richter',     'd.richter@web.de',          '+49 911 1234560',  'Nürnberg',      '1970-06-03'),
('Inge Schäfer',       'i.schaefer@gmx.de',         '+49 341 2345671',  'Leipzig',       '1987-10-20'),
('Ralf Zimmermann',    'r.zimmermann@t-online.de',  '+49 471 3456782',  'Bremerhaven',   '1983-07-14'),
('Gisela Lehmann',     'g.lehmann@freenet.de',      '+49 631 4567893',  'Kaiserslautern','1996-03-07'),
('Manfred Krause',     'm.krause@outlook.de',       '+49 731 5678904',  'Ulm',           '1977-11-28'),
('Petra Walter',       'p.walter@posteo.de',        '+49 821 6789015',  'Augsburg',      '1991-09-02'),
('Heinrich Meyer',     'h.meyer@yahoo.de',          '+49 261 7890126',  'Koblenz',       '1984-04-19'),
('Renate Schulz',      'r.schulz@gmail.com',        '+49 551 8901237',  'Göttingen',     '1989-08-11');

-- 4.4 Employees (16 employees)
INSERT INTO employees (full_name, role, department, phone, email, salary, hire_date) VALUES
('Friedrich Hartmann',  'General Manager',       'Management',    '+49 555 1001', 'f.hartmann@hotel.de',   6500.00, '2010-01-15'),
('Annelise Lange',      'Front Desk Manager',    'Reception',     '+49 555 1002', 'a.lange@hotel.de',      3800.00, '2013-03-20'),
('Bernhard Kohl',       'Front Desk Agent',      'Reception',     '+49 555 1003', 'b.kohl@hotel.de',       2600.00, '2015-06-10'),
('Hildegard Fuchs',     'Front Desk Agent',      'Reception',     '+49 555 1004', 'h.fuchs@hotel.de',      2600.00, '2016-09-05'),
('Rudolf Berger',       'Head Chef',             'Restaurant',    '+49 555 1005', 'r.berger@hotel.de',     4200.00, '2012-02-28'),
('Edeltraud Gross',     'Sous Chef',             'Restaurant',    '+49 555 1006', 'e.gross@hotel.de',      3100.00, '2014-07-15'),
('Gerhard Wolf',        'Housekeeping Manager',  'Housekeeping',  '+49 555 1007', 'g.wolf@hotel.de',       3200.00, '2011-11-01'),
('Waltraud Schreiber',  'Housekeeper',           'Housekeeping',  '+49 555 1008', 'w.schreiber@hotel.de',  2200.00, '2017-04-12'),
('Ernst Neumann',       'Concierge',             'Reception',     '+49 555 1009', 'e.neumann@hotel.de',    2900.00, '2014-08-22'),
('Margarethe Schwarz',  'Sales Manager',         'Sales',         '+49 555 1010', 'm.schwarz@hotel.de',    4000.00, '2013-05-18'),
('Karl Werner',         'Accountant',            'Finance',       '+49 555 1011', 'k.werner@hotel.de',     3600.00, '2012-09-30'),
('Elfriede Schmitt',    'Receptionist',          'Reception',     '+49 555 1012', 'e.schmitt@hotel.de',    2500.00, '2018-01-08'),
('Horst Klein',         'Security Officer',      'Security',      '+49 555 1013', 'h.klein@hotel.de',      2700.00, '2015-12-03'),
('Ingeborg Braun',      'Spa Manager',           'Wellness',      '+49 555 1014', 'i.braun@hotel.de',      3500.00, '2016-03-14'),
('Lothar König',        'Maintenance Technician','Maintenance',   '+49 555 1015', 'l.koenig@hotel.de',     2800.00, '2014-06-27'),
('Hannelore Bauer',     'Night Auditor',         'Finance',       '+49 555 1016', 'h.bauer@hotel.de',      2750.00, '2017-10-19');

-- 4.5 Bookings (18 bookings)
INSERT INTO bookings (customer_id, room_id, employee_id, check_in_date, check_out_date, num_guests, status, special_notes) VALUES
(1,  3,  3, '2024-01-10', '2024-01-14', 2, 'completed',  'Anniversary couple, request champagne'),
(2,  10, 4, '2024-01-15', '2024-01-18', 1, 'completed',  'Business trip, early check-in requested'),
(3,  7,  3, '2024-02-01', '2024-02-05', 2, 'completed',  'Quiet room preferred'),
(4,  1,  12,  '2024-02-14','2024-02-16',1, 'completed',  'Valentine Day stay'),
(5,  13, 4, '2024-03-05', '2024-03-10', 3, 'completed',  'Family with young child'),
(6,  16, 3, '2024-03-20', '2024-03-23', 2, 'completed',  'River view requested'),
(7,  4,  12, '2024-04-01', '2024-04-03', 2, 'cancelled',  'Cancelled due to illness'),
(8,  9,  4, '2024-04-10', '2024-04-14', 2, 'completed',  'Non-smoking room only'),
(9,  6,  3, '2024-05-01', '2024-05-04', 2, 'completed',  'Late check-out needed'),
(10, 11, 12, '2024-05-15', '2024-05-17', 1, 'completed', 'Vegetarian meal plan'),
(11, 14, 4, '2024-06-01', '2024-06-07', 4, 'completed',  'Family reunion, extra towels'),
(12, 2,  3, '2024-06-20', '2024-06-22', 1, 'no-show',    'Did not arrive, prepaid'),
(13, 5,  12, '2024-07-04', '2024-07-08', 2, 'completed', 'Honeymoon package'),
(14, 15, 4, '2024-07-15', '2024-07-20', 2, 'completed',  'Penthouse, VIP treatment'),
(15, 8,  3, '2024-08-01', '2024-08-03', 2, 'cancelled',  'Room under maintenance'),
(16, 17, 12, '2024-08-20', '2024-08-25', 2, 'completed', 'Parking space required'),
(17, 12, 4, '2024-09-10', '2024-09-14', 3, 'completed',  'Allergy to feather pillows'),
(18, 18, 3, '2024-09-25', '2024-09-27', 1, 'confirmed',  'Early arrival around 10am');

-- 4.6 Payments (18 payments)
INSERT INTO payments (booking_id, amount, payment_method, payment_status, payment_date, transaction_id) VALUES
(1,  516.00,  'credit_card',   'completed', '2024-01-10 14:32:00', 'TXN-DE-100001'),
(2,  387.00,  'bank_transfer', 'completed', '2024-01-13 09:15:00', 'TXN-DE-100002'),
(3,  500.00,  'debit_card',    'completed', '2024-02-01 11:00:00', 'TXN-DE-100003'),
(4,  178.00,  'credit_card',   'completed', '2024-02-14 15:45:00', 'TXN-DE-100004'),
(5,  1025.00, 'paypal',        'completed', '2024-03-05 10:20:00', 'TXN-DE-100005'),
(6,  1647.00, 'credit_card',   'completed', '2024-03-20 13:10:00', 'TXN-DE-100006'),
(7,  270.00,  'debit_card',    'refunded',  '2024-04-01 09:00:00', 'TXN-DE-100007'),
(8,  996.00,  'credit_card',   'completed', '2024-04-10 16:30:00', 'TXN-DE-100008'),
(9,  375.00,  'cash',          'completed', '2024-05-01 12:00:00', 'TXN-DE-100009'),
(10, 490.00,  'bank_transfer', 'completed', '2024-05-15 08:45:00', 'TXN-DE-100010'),
(11, 1194.00, 'credit_card',   'completed', '2024-06-01 14:15:00', 'TXN-DE-100011'),
(12, 178.00,  'credit_card',   'completed', '2024-06-20 10:00:00', 'TXN-DE-100012'),
(13, 520.00,  'paypal',        'completed', '2024-07-04 11:30:00', 'TXN-DE-100013'),
(14, 2495.00, 'bank_transfer', 'completed', '2024-07-15 09:00:00', 'TXN-DE-100014'),
(15, 250.00,  'debit_card',    'refunded',  '2024-08-01 10:00:00', 'TXN-DE-100015'),
(16, 595.00,  'credit_card',   'completed', '2024-08-20 13:00:00', 'TXN-DE-100016'),
(17, 796.00,  'bank_transfer', 'completed', '2024-09-10 15:00:00', 'TXN-DE-100017'),
(18, 170.00,  'credit_card',   'pending',   '2024-09-25 09:30:00', 'TXN-DE-100018');

-- SECTION 5: SQL QUERIES

-- 5.1 BASIC CRUD QUERIES

-- Q1: View all customers
SELECT * FROM customers ORDER BY full_name;

-- Q2: View all available rooms with type info
SELECT
    r.room_number,
    rt.type_name,
    r.floor_number,
    r.price_per_night,
    r.view_type,
    r.status
FROM rooms r
JOIN room_types rt ON r.type_id = rt.type_id
WHERE r.status = 'available'
ORDER BY r.price_per_night;

-- Q3: View all bookings with customer and room details
SELECT
    b.booking_id,
    c.full_name        AS customer_name,
    r.room_number,
    rt.type_name       AS room_type,
    b.check_in_date,
    b.check_out_date,
    DATEDIFF(b.check_out_date, b.check_in_date) AS nights,
    b.num_guests,
    b.status
FROM bookings b
JOIN customers c    ON b.customer_id = c.customer_id
JOIN rooms r        ON b.room_id = r.room_id
JOIN room_types rt  ON r.type_id = rt.type_id
ORDER BY b.check_in_date;

-- Q4: Update a room status (e.g., mark a room as under maintenance)
UPDATE rooms
SET status = 'maintenance'
WHERE room_number = '302';

-- Q5: Delete a cancelled booking (example with safe check)
DELETE FROM bookings
WHERE status = 'cancelled'
  AND booking_id = 7;

-- Q6: Insert a new customer
INSERT INTO customers (full_name, email, phone, city, date_of_birth)
VALUES ('Hans Albrecht', 'h.albrecht@gmail.com', '+49 30 99887766', 'Berlin', '1986-04-22');

-- 5.2 AGGREGATION QUERIES

-- Q7: Total revenue by payment method
SELECT
    payment_method,
    COUNT(*)            AS total_transactions,
    SUM(amount)         AS total_revenue,
    AVG(amount)         AS avg_payment
FROM payments
WHERE payment_status = 'completed'
GROUP BY payment_method
ORDER BY total_revenue DESC;

-- Q8: Revenue per month
SELECT
    DATE_FORMAT(payment_date, '%Y-%m')  AS month,
    COUNT(*)                            AS bookings_paid,
    SUM(amount)                         AS monthly_revenue
FROM payments
WHERE payment_status = 'completed'
GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
ORDER BY month;

-- Q9: Number of bookings per room type
SELECT
    rt.type_name,
    COUNT(b.booking_id)  AS total_bookings,
    SUM(DATEDIFF(b.check_out_date, b.check_in_date)) AS total_nights_sold
FROM bookings b
JOIN rooms r       ON b.room_id = r.room_id
JOIN room_types rt ON r.type_id = rt.type_id
GROUP BY rt.type_name
ORDER BY total_bookings DESC;

-- Q10: Average booking duration by room type
SELECT
    rt.type_name,
    ROUND(AVG(DATEDIFF(b.check_out_date, b.check_in_date)), 2) AS avg_nights,
    MIN(DATEDIFF(b.check_out_date, b.check_in_date))           AS min_nights,
    MAX(DATEDIFF(b.check_out_date, b.check_in_date))           AS max_nights
FROM bookings b
JOIN rooms r       ON b.room_id = r.room_id
JOIN room_types rt ON r.type_id = rt.type_id
WHERE b.status = 'completed'
GROUP BY rt.type_name;

-- 5.3 JOIN QUERIES

-- Q11: Full booking report (all tables joined)
SELECT
    b.booking_id,
    c.full_name                                                 AS customer,
    c.city                                                      AS customer_city,
    r.room_number,
    rt.type_name                                                AS room_type,
    r.price_per_night,
    b.check_in_date,
    b.check_out_date,
    DATEDIFF(b.check_out_date, b.check_in_date)                AS nights,
    b.num_guests,
    b.status                                                    AS booking_status,
    p.amount                                                    AS amount_paid,
    p.payment_method,
    p.payment_status,
    e.full_name                                                 AS handled_by
FROM bookings b
JOIN customers c    ON b.customer_id = c.customer_id
JOIN rooms r        ON b.room_id = r.room_id
JOIN room_types rt  ON r.type_id = rt.type_id
LEFT JOIN payments p ON b.booking_id = p.booking_id
LEFT JOIN employees e ON b.employee_id = e.employee_id
ORDER BY b.booking_id;

-- Q12: Employees and number of bookings they managed
SELECT
    e.full_name,
    e.role,
    e.department,
    COUNT(b.booking_id)  AS bookings_managed
FROM employees e
LEFT JOIN bookings b ON e.employee_id = b.employee_id
GROUP BY e.employee_id, e.full_name, e.role, e.department
ORDER BY bookings_managed DESC;

-- Q13: Customers with their total spending (only completed payments)
SELECT
    c.customer_id,
    c.full_name,
    c.city,
    COUNT(b.booking_id)    AS total_bookings,
    COALESCE(SUM(p.amount), 0)  AS total_spent
FROM customers c
LEFT JOIN bookings b  ON c.customer_id = b.customer_id
LEFT JOIN payments p  ON b.booking_id = p.booking_id AND p.payment_status = 'completed'
GROUP BY c.customer_id, c.full_name, c.city
ORDER BY total_spent DESC;

-- 5.4 ADVANCED / BUSINESS LOGIC QUERIES

-- Q14: Rooms currently occupied (with current guest details)
SELECT
    r.room_number,
    rt.type_name,
    r.price_per_night,
    c.full_name        AS guest_name,
    b.check_in_date,
    b.check_out_date,
    DATEDIFF(b.check_out_date, CURDATE()) AS nights_remaining
FROM bookings b
JOIN rooms r        ON b.room_id = r.room_id
JOIN room_types rt  ON r.type_id = rt.type_id
JOIN customers c    ON b.customer_id = c.customer_id
WHERE b.status = 'confirmed'
   OR (b.status = 'completed' AND b.check_out_date >= CURDATE());

-- Q15: Top 5 highest-spending customers
SELECT
    c.full_name,
    c.city,
    c.email,
    SUM(p.amount)       AS total_spent,
    COUNT(b.booking_id) AS bookings
FROM customers c
JOIN bookings b  ON c.customer_id = b.customer_id
JOIN payments p  ON b.booking_id  = p.booking_id
WHERE p.payment_status = 'completed'
GROUP BY c.customer_id, c.full_name, c.city, c.email
ORDER BY total_spent DESC
LIMIT 5;

-- Q16: Revenue per room with occupancy rate
SELECT
    r.room_number,
    rt.type_name,
    r.price_per_night,
    COUNT(b.booking_id)                                         AS times_booked,
    SUM(DATEDIFF(b.check_out_date, b.check_in_date))           AS total_nights_occupied,
    COALESCE(SUM(p.amount), 0)                                  AS total_revenue
FROM rooms r
JOIN room_types rt  ON r.type_id = rt.type_id
LEFT JOIN bookings b ON r.room_id = b.room_id AND b.status != 'cancelled'
LEFT JOIN payments p ON b.booking_id = p.booking_id AND p.payment_status = 'completed'
GROUP BY r.room_id, r.room_number, rt.type_name, r.price_per_night
ORDER BY total_revenue DESC;

-- Q17: Booking cancellation and no-show report
SELECT
    b.booking_id,
    c.full_name       AS customer,
    r.room_number,
    b.check_in_date,
    b.status,
    p.amount          AS amount_charged,
    p.payment_status
FROM bookings b
JOIN customers c ON b.customer_id = c.customer_id
JOIN rooms r     ON b.room_id = r.room_id
LEFT JOIN payments p ON b.booking_id = p.booking_id
WHERE b.status IN ('cancelled', 'no-show')
ORDER BY b.check_in_date;

-- Q18: Monthly booking trend summary
SELECT
    DATE_FORMAT(b.check_in_date, '%Y-%m')  AS month,
    COUNT(b.booking_id)                     AS total_bookings,
    SUM(CASE WHEN b.status = 'completed'  THEN 1 ELSE 0 END) AS completed,
    SUM(CASE WHEN b.status = 'cancelled'  THEN 1 ELSE 0 END) AS cancelled,
    SUM(CASE WHEN b.status = 'no-show'    THEN 1 ELSE 0 END) AS no_shows,
    SUM(CASE WHEN b.status = 'confirmed'  THEN 1 ELSE 0 END) AS upcoming
FROM bookings b
GROUP BY DATE_FORMAT(b.check_in_date, '%Y-%m')
ORDER BY month;

-- Q19: Find rooms available between two specific dates
SELECT
    r.room_number,
    rt.type_name,
    r.floor_number,
    r.price_per_night,
    r.view_type
FROM rooms r
JOIN room_types rt ON r.type_id = rt.type_id
WHERE r.status = 'available'
  AND r.room_id NOT IN (
      SELECT room_id FROM bookings
      WHERE status NOT IN ('cancelled')
        AND check_in_date  < '2024-10-15'
        AND check_out_date > '2024-10-10'
  )
ORDER BY r.price_per_night;

-- Q20: Department salary summary
SELECT
    department,
    COUNT(employee_id)   AS headcount,
    MIN(salary)          AS min_salary,
    MAX(salary)          AS max_salary,
    ROUND(AVG(salary),2) AS avg_salary,
    SUM(salary)          AS total_payroll
FROM employees
GROUP BY department
ORDER BY total_payroll DESC;


-- Q21: Refunded payments with booking details
SELECT
    p.transaction_id,
    c.full_name     AS customer,
    r.room_number,
    b.check_in_date,
    b.status        AS booking_status,
    p.amount        AS refunded_amount,
    p.payment_method,
    p.payment_date  AS refund_date
FROM payments p
JOIN bookings b  ON p.booking_id = p.booking_id
JOIN customers c ON b.customer_id = c.customer_id
JOIN rooms r     ON b.room_id = r.room_id
WHERE p.payment_status = 'refunded';

-- Q22: Room type popularity with average revenue per booking
SELECT
    rt.type_name,
    rt.max_occupancy,
    COUNT(b.booking_id)                       AS total_bookings,
    ROUND(AVG(p.amount), 2)                   AS avg_revenue_per_booking,
    SUM(p.amount)                             AS total_revenue
FROM room_types rt
JOIN rooms r        ON rt.type_id = r.type_id
LEFT JOIN bookings b ON r.room_id = b.room_id AND b.status = 'completed'
LEFT JOIN payments p ON b.booking_id = p.booking_id AND p.payment_status = 'completed'
GROUP BY rt.type_id, rt.type_name, rt.max_occupancy
ORDER BY total_revenue DESC;

-- Q23: Pending payments that need follow-up
SELECT
    p.payment_id,
    p.transaction_id,
    c.full_name        AS customer,
    c.email,
    c.phone,
    b.check_in_date,
    b.check_out_date,
    p.amount,
    p.payment_method,
    p.payment_date
FROM payments p
JOIN bookings b  ON p.booking_id = b.booking_id
JOIN customers c ON b.customer_id = c.customer_id
WHERE p.payment_status = 'pending'
ORDER BY p.payment_date;

-- Q24: View summary — database statistics
SELECT
    (SELECT COUNT(*) FROM customers)  AS total_customers,
    (SELECT COUNT(*) FROM rooms)      AS total_rooms,
    (SELECT COUNT(*) FROM bookings)   AS total_bookings,
    (SELECT COUNT(*) FROM payments WHERE payment_status = 'completed') AS completed_payments,
    (SELECT SUM(amount) FROM payments WHERE payment_status = 'completed') AS total_revenue,
    (SELECT COUNT(*) FROM rooms WHERE status = 'available')  AS available_rooms,
    (SELECT COUNT(*) FROM rooms WHERE status = 'occupied')   AS occupied_rooms,
    (SELECT COUNT(*) FROM employees) AS total_employees;
    
    
--   SECTION 6: TRIGGERS

-- TRIGGER 1: Automatically update room status to 'occupied'
--            when a new booking is confirmed
DELIMITER $$

CREATE TRIGGER trg_room_occupied_on_booking
AFTER INSERT ON bookings
FOR EACH ROW
BEGIN
    IF NEW.status = 'confirmed' THEN
        UPDATE rooms
        SET status = 'occupied'
        WHERE room_id = NEW.room_id;
    END IF;
END$$

DELIMITER ;


-- TRIGGER 2: Automatically set room status back to 'available'
--            when a booking is cancelled or completed
DELIMITER $$

CREATE TRIGGER trg_room_available_on_update
AFTER UPDATE ON bookings
FOR EACH ROW
BEGIN
    IF NEW.status IN ('cancelled', 'completed', 'no-show')
       AND OLD.status = 'confirmed' THEN
        UPDATE rooms
        SET status = 'available'
        WHERE room_id = NEW.room_id;
    END IF;
END$$

DELIMITER ;


-- TRIGGER 3: Prevent double-booking the same room
--            on overlapping dates (BEFORE INSERT guard)
DELIMITER $$

CREATE TRIGGER trg_prevent_double_booking
BEFORE INSERT ON bookings
FOR EACH ROW
BEGIN
    DECLARE conflict_count INT;

    SELECT COUNT(*) INTO conflict_count
    FROM bookings
    WHERE room_id = NEW.room_id
      AND status NOT IN ('cancelled', 'no-show')
      AND check_in_date  < NEW.check_out_date
      AND check_out_date > NEW.check_in_date;

    IF conflict_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: Room is already booked for the selected dates.';
    END IF;
END$$

DELIMITER ;


-- TRIGGER 4: Auto-set payment amount based on room price × nights
--            when a new payment row is inserted with amount = 0
DELIMITER $$

CREATE TRIGGER trg_auto_calculate_payment
BEFORE INSERT ON payments
FOR EACH ROW
BEGIN
    DECLARE calculated_amount DECIMAL(10,2);

    IF NEW.amount = 0 THEN
        SELECT r.price_per_night * DATEDIFF(b.check_out_date, b.check_in_date)
        INTO calculated_amount
        FROM bookings b
        JOIN rooms r ON b.room_id = r.room_id
        WHERE b.booking_id = NEW.booking_id;

        SET NEW.amount = calculated_amount;
    END IF;
END$$

DELIMITER ;


-- TRIGGER 5: Log a warning note into special_notes
--            when a no-show booking is recorded
DELIMITER $$

CREATE TRIGGER trg_flag_no_show
AFTER UPDATE ON bookings
FOR EACH ROW
BEGIN
    IF NEW.status = 'no-show' AND OLD.status != 'no-show' THEN
        UPDATE bookings
        SET special_notes = CONCAT(
            COALESCE(special_notes, ''),
            ' | ⚠ NO-SHOW recorded on ', NOW()
        )
        WHERE booking_id = NEW.booking_id;
    END IF;
END$$

DELIMITER ;

--   SECTION 7: VIEWS

-- VIEW 1: Full booking summary (most useful everyday view)
CREATE OR REPLACE VIEW vw_booking_summary AS
SELECT
    b.booking_id,
    c.full_name                                             AS customer_name,
    c.email                                                 AS customer_email,
    c.city                                                  AS customer_city,
    r.room_number,
    rt.type_name                                            AS room_type,
    r.price_per_night,
    b.check_in_date,
    b.check_out_date,
    DATEDIFF(b.check_out_date, b.check_in_date)            AS nights_stayed,
    b.num_guests,
    b.status                                                AS booking_status,
    p.amount                                                AS amount_paid,
    p.payment_method,
    p.payment_status,
    e.full_name                                             AS handled_by_employee
FROM bookings b
JOIN customers  c   ON b.customer_id = c.customer_id
JOIN rooms      r   ON b.room_id     = r.room_id
JOIN room_types rt  ON r.type_id     = rt.type_id
LEFT JOIN payments  p ON b.booking_id  = p.booking_id
LEFT JOIN employees e ON b.employee_id = e.employee_id;

-- Usage:
SELECT * FROM vw_booking_summary;
SELECT * FROM vw_booking_summary WHERE booking_status = 'completed';
SELECT * FROM vw_booking_summary WHERE customer_city = 'Berlin';


-- VIEW 2: Room availability dashboard
CREATE OR REPLACE VIEW vw_room_availability AS
SELECT
    r.room_number,
    rt.type_name                AS room_type,
    rt.max_occupancy,
    r.floor_number,
    r.price_per_night,
    r.view_type,
    r.status,
    CASE
        WHEN r.status = 'available'   THEN 'Ready to book'
        WHEN r.status = 'occupied'    THEN 'Currently occupied'
        WHEN r.status = 'maintenance' THEN 'Under maintenance'
    END                         AS status_description
FROM rooms r
JOIN room_types rt ON r.type_id = rt.type_id
ORDER BY r.floor_number, r.room_number;

-- Usage:
SELECT * FROM vw_room_availability;
SELECT * FROM vw_room_availability WHERE status = 'available';
SELECT * FROM vw_room_availability WHERE price_per_night < 150.00;


-- VIEW 3: Customer revenue report
CREATE OR REPLACE VIEW vw_customer_revenue AS
SELECT
    c.customer_id,
    c.full_name,
    c.email,
    c.city,
    COUNT(b.booking_id)              AS total_bookings,
    SUM(DATEDIFF(b.check_out_date,
                 b.check_in_date))   AS total_nights,
    COALESCE(SUM(p.amount), 0)       AS total_spent,
    COALESCE(MAX(p.amount), 0)       AS highest_single_payment,
    MAX(b.check_in_date)             AS last_stay_date
FROM customers c
LEFT JOIN bookings b
       ON c.customer_id = b.customer_id
      AND b.status = 'completed'
LEFT JOIN payments p
       ON b.booking_id = p.booking_id
      AND p.payment_status = 'completed'
GROUP BY c.customer_id, c.full_name, c.email, c.city;

-- Usage:
SELECT * FROM vw_customer_revenue ORDER BY total_spent DESC;
SELECT * FROM vw_customer_revenue WHERE total_bookings > 1;


-- VIEW 4: Monthly revenue and occupancy report
CREATE OR REPLACE VIEW vw_monthly_report AS
SELECT
    DATE_FORMAT(b.check_in_date, '%Y-%m')       AS month,
    COUNT(b.booking_id)                          AS total_bookings,
    SUM(CASE WHEN b.status='completed' THEN 1 ELSE 0 END) AS completed,
    SUM(CASE WHEN b.status='cancelled' THEN 1 ELSE 0 END) AS cancelled,
    SUM(CASE WHEN b.status='no-show'   THEN 1 ELSE 0 END) AS no_shows,
    COALESCE(SUM(p.amount), 0)                   AS total_revenue,
    ROUND(AVG(p.amount), 2)                      AS avg_booking_value
FROM bookings b
LEFT JOIN payments p
       ON b.booking_id = p.booking_id
      AND p.payment_status = 'completed'
GROUP BY DATE_FORMAT(b.check_in_date, '%Y-%m')
ORDER BY month;

-- Usage:
SELECT * FROM vw_monthly_report;


-- VIEW 5: Employee performance view
CREATE OR REPLACE VIEW vw_employee_performance AS
SELECT
    e.employee_id,
    e.full_name,
    e.role,
    e.department,
    e.salary,
    COUNT(b.booking_id)          AS bookings_handled,
    COALESCE(SUM(p.amount), 0)   AS revenue_generated
FROM employees e
LEFT JOIN bookings b  ON e.employee_id = b.employee_id
LEFT JOIN payments p
       ON b.booking_id = p.booking_id
      AND p.payment_status = 'completed'
GROUP BY e.employee_id, e.full_name, e.role, e.department, e.salary
ORDER BY bookings_handled DESC;

-- Usage:
SELECT * FROM vw_employee_performance;
SELECT * FROM vw_employee_performance WHERE department = 'Reception';


--   SECTION 8: STORED PROCEDURES


-- PROCEDURE 1: Make a new booking (full reservation workflow)
DELIMITER $$

CREATE PROCEDURE sp_make_booking(
    IN  p_customer_id    INT,
    IN  p_room_id        INT,
    IN  p_employee_id    INT,
    IN  p_check_in       DATE,
    IN  p_check_out      DATE,
    IN  p_num_guests     INT,
    IN  p_notes          TEXT,
    IN  p_payment_method VARCHAR(20),
    OUT p_booking_id     INT,
    OUT p_total_amount   DECIMAL(10,2),
    OUT p_message        VARCHAR(255)
)
BEGIN
    DECLARE v_price_per_night DECIMAL(10,2);
    DECLARE v_nights INT;
    DECLARE v_conflict INT DEFAULT 0;

    -- Validate dates
    IF p_check_out <= p_check_in THEN
        SET p_message = 'ERROR: Check-out must be after check-in.';
        SET p_booking_id = -1;
        SET p_total_amount = 0;
    ELSE
        -- Check conflicts
        SELECT COUNT(*) INTO v_conflict
        FROM bookings
        WHERE room_id = p_room_id
          AND status NOT IN ('cancelled','no-show')
          AND check_in_date < p_check_out
          AND check_out_date > p_check_in;

        IF v_conflict > 0 THEN
            SET p_message = 'ERROR: Room not available.';
            SET p_booking_id = -1;
            SET p_total_amount = 0;
        ELSE
            -- Get price
            SELECT price_per_night INTO v_price_per_night
            FROM rooms WHERE room_id = p_room_id;

            SET v_nights = DATEDIFF(p_check_out, p_check_in);
            SET p_total_amount = v_price_per_night * v_nights;

            -- Insert booking
            INSERT INTO bookings (
                customer_id, room_id, employee_id,
                check_in_date, check_out_date, num_guests,
                status, special_notes
            )
            VALUES (
                p_customer_id, p_room_id, p_employee_id,
                p_check_in, p_check_out, p_num_guests,
                'confirmed', p_notes
            );

            SET p_booking_id = LAST_INSERT_ID();

            -- Insert payment
            INSERT INTO payments (booking_id, amount, payment_method, payment_status)
            VALUES (p_booking_id, p_total_amount, p_payment_method, 'pending');

            SET p_message = CONCAT(
                'SUCCESS: Booking #', p_booking_id,
                ' | Total EUR ', p_total_amount
            );
        END IF;
    END IF;
END$$

DELIMITER ;


-- PROCEDURE 2: Cancel a booking and process refund
DELIMITER $$

CREATE PROCEDURE sp_cancel_booking(
    IN  p_booking_id INT,
    OUT p_message    VARCHAR(255)
)
BEGIN
    DECLARE v_status VARCHAR(20);
    DECLARE v_pay_status VARCHAR(20);
    DECLARE v_pay_id INT;

    -- Get booking status
    SELECT status INTO v_status
    FROM bookings
    WHERE booking_id = p_booking_id;

    IF v_status IS NULL THEN
        SET p_message = 'ERROR: Booking not found.';
    ELSEIF v_status IN ('cancelled','completed','no-show') THEN
        SET p_message = CONCAT('ERROR: Cannot cancel (', v_status, ')');
    ELSE
        -- Cancel booking
        UPDATE bookings
        SET status = 'cancelled'
        WHERE booking_id = p_booking_id;

        -- Get payment
        SELECT payment_id, payment_status
        INTO v_pay_id, v_pay_status
        FROM payments
        WHERE booking_id = p_booking_id;

        IF v_pay_status = 'completed' THEN
            UPDATE payments
            SET payment_status = 'refunded'
            WHERE payment_id = v_pay_id;

            SET p_message = 'SUCCESS: Booking cancelled & refunded.';
        ELSE
            UPDATE payments
            SET payment_status = 'failed'
            WHERE payment_id = v_pay_id;

            SET p_message = 'SUCCESS: Booking cancelled (no charge).';
        END IF;
    END IF;
END$$

DELIMITER ;


-- PROCEDURE 3: Get full report for a specific customer
DELIMITER $$

CREATE PROCEDURE sp_customer_report(
    IN p_customer_id INT
)
BEGIN
    -- Customer profile
    SELECT
        customer_id, full_name, email,
        phone, city, date_of_birth
    FROM customers
    WHERE customer_id = p_customer_id;

    -- All bookings
    SELECT
        b.booking_id,
        r.room_number,
        rt.type_name,
        b.check_in_date,
        b.check_out_date,
        DATEDIFF(b.check_out_date, b.check_in_date) AS nights,
        b.status,
        p.amount,
        p.payment_status
    FROM bookings b
    JOIN rooms      r  ON b.room_id    = r.room_id
    JOIN room_types rt ON r.type_id    = rt.type_id
    LEFT JOIN payments p ON b.booking_id = p.booking_id
    WHERE b.customer_id = p_customer_id
    ORDER BY b.check_in_date;

    -- Spending summary
    SELECT
        COUNT(b.booking_id)       AS total_bookings,
        SUM(p.amount)             AS total_spent,
        AVG(p.amount)             AS avg_per_booking
    FROM bookings b
    JOIN payments p ON b.booking_id = p.booking_id
    WHERE b.customer_id   = p_customer_id
      AND p.payment_status = 'completed';
END$$

DELIMITER ;

-- PROCEDURE 4: Search available rooms by date and type
DELIMITER $$

CREATE PROCEDURE sp_search_available_rooms(
    IN p_check_in DATE,
    IN p_check_out DATE,
    IN p_type_name VARCHAR(50),
    IN p_max_price DECIMAL(10,2)
)
BEGIN
    IF p_check_out <= p_check_in THEN
        SELECT 'ERROR: Invalid dates' AS message;
    ELSE
        SELECT
            r.room_number,
            rt.type_name,
            r.price_per_night,
            DATEDIFF(p_check_out, p_check_in) * r.price_per_night AS total_cost
        FROM rooms r
        JOIN room_types rt ON r.type_id = rt.type_id
        WHERE r.status = 'available'
          AND (p_type_name IS NULL OR rt.type_name = p_type_name)
          AND (p_max_price IS NULL OR r.price_per_night <= p_max_price)
          AND r.room_id NOT IN (
              SELECT room_id FROM bookings
              WHERE status NOT IN ('cancelled','no-show')
                AND check_in_date < p_check_out
                AND check_out_date > p_check_in
          );
    END IF;
END$$

DELIMITER ;


-- PROCEDURE 5: Monthly revenue summary report
DELIMITER $$

CREATE PROCEDURE sp_monthly_revenue_report(
    IN p_year INT
)
BEGIN
    SELECT
        DATE_FORMAT(b.check_in_date, '%M')          AS month_name,
        DATE_FORMAT(b.check_in_date, '%Y-%m')        AS month,
        COUNT(b.booking_id)                          AS total_bookings,
        SUM(CASE WHEN b.status='completed' THEN 1 ELSE 0 END) AS completed,
        SUM(CASE WHEN b.status='cancelled' THEN 1 ELSE 0 END) AS cancelled,
        COALESCE(SUM(p.amount), 0)                   AS revenue_eur,
        ROUND(COALESCE(AVG(p.amount), 0), 2)         AS avg_booking_value
    FROM bookings b
    LEFT JOIN payments p
           ON b.booking_id    = p.booking_id
          AND p.payment_status = 'completed'
    WHERE YEAR(b.check_in_date) = p_year
    GROUP BY DATE_FORMAT(b.check_in_date, '%Y-%m'),
             DATE_FORMAT(b.check_in_date, '%M')
    ORDER BY month;
END$$

DELIMITER ;

-- Usage:
CALL sp_monthly_revenue_report(2024);