PRAGMA foreign_keys = ON;

-- 1. Мастера
CREATE TABLE masters (
    master_id INTEGER PRIMARY KEY AUTOINCREMENT,
    last_name TEXT NOT NULL,
    first_name TEXT NOT NULL,
    phone TEXT UNIQUE,
    hire_date TEXT NOT NULL,
    dismissal_date TEXT,
    salary_percent REAL NOT NULL DEFAULT 40
        CHECK (salary_percent >= 0 AND salary_percent <= 100),
    CHECK (dismissal_date IS NULL OR dismissal_date >= hire_date)
);

-- 2. График работы мастеров
CREATE TABLE master_schedule (
    schedule_id INTEGER PRIMARY KEY AUTOINCREMENT,
    master_id INTEGER NOT NULL,
    weekday INTEGER NOT NULL CHECK (weekday BETWEEN 1 AND 7),
    start_time TEXT NOT NULL,
    end_time TEXT NOT NULL,
    FOREIGN KEY (master_id) REFERENCES masters(master_id),
    CHECK (start_time < end_time),
    UNIQUE (master_id, weekday)
);

-- 3. Услуги автосервиса
CREATE TABLE services (
    service_id INTEGER PRIMARY KEY AUTOINCREMENT,
    service_name TEXT NOT NULL UNIQUE,
    duration_minutes INTEGER NOT NULL CHECK (duration_minutes > 0),
    price REAL NOT NULL CHECK (price >= 0)
);

-- 4. Клиенты
CREATE TABLE clients (
    client_id INTEGER PRIMARY KEY AUTOINCREMENT,
    full_name TEXT NOT NULL,
    phone TEXT NOT NULL UNIQUE
);

-- 5. Предварительная запись
CREATE TABLE appointments (
    appointment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    client_id INTEGER NOT NULL,
    master_id INTEGER NOT NULL,
    appointment_datetime TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'Запланирована'
        CHECK (status IN ('Запланирована', 'Выполнена', 'Отменена')),
    notes TEXT,
    FOREIGN KEY (client_id) REFERENCES clients(client_id),
    FOREIGN KEY (master_id) REFERENCES masters(master_id)
);

-- 6. Услуги в предварительной записи
CREATE TABLE appointment_services (
    appointment_id INTEGER NOT NULL,
    service_id INTEGER NOT NULL,
    price_at_booking REAL NOT NULL CHECK (price_at_booking >= 0),
    PRIMARY KEY (appointment_id, service_id),
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id),
    FOREIGN KEY (service_id) REFERENCES services(service_id)
);

-- 7. Фактически выполненные услуги
CREATE TABLE completed_services (
    completed_service_id INTEGER PRIMARY KEY AUTOINCREMENT,
    appointment_id INTEGER NOT NULL,
    master_id INTEGER NOT NULL,
    service_id INTEGER NOT NULL,
    completion_datetime TEXT NOT NULL,
    actual_price REAL NOT NULL CHECK (actual_price >= 0),
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id),
    FOREIGN KEY (master_id) REFERENCES masters(master_id),
    FOREIGN KEY (service_id) REFERENCES services(service_id)
);

-- Тестовые мастера
INSERT INTO masters
(last_name, first_name, phone, hire_date, dismissal_date, salary_percent)
VALUES
('Иванов', 'Алексей', '+79990000001', '2023-01-10', NULL, 40),
('Петров', 'Сергей', '+79990000002', '2022-05-15', NULL, 45),
('Сидоров', 'Дмитрий', '+79990000003', '2021-03-01', '2025-06-30', 35);

-- График работы
INSERT INTO master_schedule (master_id, weekday, start_time, end_time)
VALUES
(1, 1, '09:00', '18:00'),
(1, 2, '09:00', '18:00'),
(1, 3, '09:00', '18:00'),
(1, 4, '09:00', '18:00'),
(1, 5, '09:00', '18:00'),
(2, 1, '10:00', '19:00'),
(2, 2, '10:00', '19:00'),
(2, 3, '10:00', '19:00'),
(2, 4, '10:00', '19:00'),
(2, 5, '10:00', '19:00'),
(3, 1, '09:00', '17:00'),
(3, 2, '09:00', '17:00'),
(3, 3, '09:00', '17:00');

-- Справочник услуг
INSERT INTO services (service_name, duration_minutes, price)
VALUES
('Замена масла', 40, 2500),
('Диагностика двигателя', 60, 3500),
('Замена тормозных колодок', 90, 5000),
('Шиномонтаж', 60, 3000),
('Развал-схождение', 50, 2800);

-- Клиенты
INSERT INTO clients (full_name, phone)
VALUES
('Андрей Смирнов', '+79991110001'),
('Мария Кузнецова', '+79991110002'),
('Игорь Волков', '+79991110003');

-- Предварительные записи
INSERT INTO appointments
(client_id, master_id, appointment_datetime, status, notes)
VALUES
(1, 1, '2025-11-24 10:00', 'Выполнена', 'Плановое обслуживание'),
(2, 2, '2025-11-24 12:00', 'Выполнена', 'Проверка автомобиля'),
(3, 1, '2025-11-25 09:00', 'Запланирована', 'Замена масла');

-- Услуги в записях
INSERT INTO appointment_services
(appointment_id, service_id, price_at_booking)
VALUES
(1, 1, 2500),
(1, 2, 3500),
(2, 3, 5000),
(3, 1, 2500);

-- Фактически выполненные работы
INSERT INTO completed_services
(appointment_id, master_id, service_id, completion_datetime, actual_price)
VALUES
(1, 1, 1, '2025-11-24 10:40', 2500),
(1, 1, 2, '2025-11-24 11:30', 3500),
(2, 2, 3, '2025-11-24 13:30', 5000);

-- Индексы для поиска и отчетов
CREATE INDEX idx_appointments_master_date
ON appointments(master_id, appointment_datetime);

CREATE INDEX idx_completed_master_date
ON completed_services(master_id, completion_datetime);