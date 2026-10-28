
PRAGMA foreign_keys = ON;
BEGIN TRANSACTION;

-- 1. Пять новых пользователей
INSERT INTO users (first_name, last_name, email, gender, register_date)
VALUES
    ('Alex', 'Morgan', 'alex.morgan.task05@example.com', 'male', date('now')),
    ('Emily', 'Carter', 'emily.carter.task05@example.com', 'female', date('now')),
    ('Daniel', 'Brooks', 'daniel.brooks.task05@example.com', 'male', date('now')),
    ('Sophie', 'Turner', 'sophie.turner.task05@example.com', 'female', date('now')),
    ('Michael', 'Reed', 'michael.reed.task05@example.com', 'male', date('now'));

-- 2. Три новых фильма
INSERT INTO movies (title, year)
SELECT 'The Clockwork Garden', 2022
WHERE NOT EXISTS (SELECT 1 FROM movies WHERE title = 'The Clockwork Garden');

INSERT INTO movies (title, year)
SELECT 'Beyond the Silent Sea', 2023
WHERE NOT EXISTS (SELECT 1 FROM movies WHERE title = 'Beyond the Silent Sea');

INSERT INTO movies (title, year)
SELECT 'The Last Laughing Star', 2024
WHERE NOT EXISTS (SELECT 1 FROM movies WHERE title = 'The Last Laughing Star');

-- 3. Жанры
INSERT INTO genres (name)
SELECT 'Fantasy' WHERE NOT EXISTS (SELECT 1 FROM genres WHERE name = 'Fantasy');

INSERT INTO genres (name)
SELECT 'Drama' WHERE NOT EXISTS (SELECT 1 FROM genres WHERE name = 'Drama');

INSERT INTO genres (name)
SELECT 'Comedy' WHERE NOT EXISTS (SELECT 1 FROM genres WHERE name = 'Comedy');

-- 4. Связи фильмов с жанрами
INSERT INTO movie_genres (movie_id, genre_id)
SELECT m.id, g.id
FROM movies m CROSS JOIN genres g
WHERE m.title = 'The Clockwork Garden' AND g.name = 'Fantasy'
AND NOT EXISTS (
    SELECT 1 FROM movie_genres mg
    WHERE mg.movie_id = m.id AND mg.genre_id = g.id
);

INSERT INTO movie_genres (movie_id, genre_id)
SELECT m.id, g.id
FROM movies m CROSS JOIN genres g
WHERE m.title = 'Beyond the Silent Sea' AND g.name = 'Drama'
AND NOT EXISTS (
    SELECT 1 FROM movie_genres mg
    WHERE mg.movie_id = m.id AND mg.genre_id = g.id
);

INSERT INTO movie_genres (movie_id, genre_id)
SELECT m.id, g.id
FROM movies m CROSS JOIN genres g
WHERE m.title = 'The Last Laughing Star' AND g.name = 'Comedy'
AND NOT EXISTS (
    SELECT 1 FROM movie_genres mg
    WHERE mg.movie_id = m.id AND mg.genre_id = g.id
);

-- 5. Три отзыва от Alex Morgan
INSERT INTO ratings (user_id, movie_id, rating)
SELECT u.id, m.id, 4.5
FROM users u CROSS JOIN movies m
WHERE u.email = 'alex.morgan.task05@example.com'
AND m.title = 'The Clockwork Garden';

INSERT INTO ratings (user_id, movie_id, rating)
SELECT u.id, m.id, 5.0
FROM users u CROSS JOIN movies m
WHERE u.email = 'alex.morgan.task05@example.com'
AND m.title = 'Beyond the Silent Sea';

INSERT INTO ratings (user_id, movie_id, rating)
SELECT u.id, m.id, 4.0
FROM users u CROSS JOIN movies m
WHERE u.email = 'alex.morgan.task05@example.com'
AND m.title = 'The Last Laughing Star';

COMMIT;
