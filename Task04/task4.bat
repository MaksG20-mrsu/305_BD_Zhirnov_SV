#!/bin/bash
if command -v chcp >/dev/null 2>&1; then
    chcp 65001
fi

sqlite3 movies_rating.db < db_init.sql

echo "1. Найти все пары пользователей, оценивших один и тот же фильм. Исключить дубликаты и пары пользователя с самим собой. Вывести имена пользователей и название фильма. Первые 100 записей."
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "SELECT u1.name AS user1, u2.name AS user2, m.title FROM ratings r1 JOIN ratings r2 ON r1.movie_id = r2.movie_id AND r1.user_id < r2.user_id JOIN users u1 ON u1.id = r1.user_id JOIN users u2 ON u2.id = r2.user_id JOIN movies m ON m.id = r1.movie_id ORDER BY u1.name, u2.name, m.title LIMIT 100;"
echo " "

echo "2. Найти 10 самых свежих оценок от разных пользователей. Вывести фильм, пользователя, оценку и дату в формате ГГГГ-ММ-ДД."
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "WITH ranked AS (SELECT r.*, ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY timestamp DESC, id DESC) AS rn FROM ratings r) SELECT m.title, u.name, r.rating, date(r.timestamp, 'unixepoch') AS rating_date FROM ranked r JOIN movies m ON m.id = r.movie_id JOIN users u ON u.id = r.user_id WHERE r.rn = 1 ORDER BY r.timestamp DESC, r.id DESC LIMIT 10;"
echo " "

echo "3. Вывести все фильмы с максимальным и минимальным средним рейтингом. Для максимального рейтинга указать Да в колонке Рекомендуем, для минимального Нет. Отсортировать по году и названию."
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "WITH avg_ratings AS (SELECT m.id, m.title, m.year, AVG(r.rating) AS avg_rating FROM movies m JOIN ratings r ON r.movie_id = m.id GROUP BY m.id), bounds AS (SELECT MAX(avg_rating) AS max_rating, MIN(avg_rating) AS min_rating FROM avg_ratings) SELECT a.title, a.year, ROUND(a.avg_rating, 3) AS avg_rating, CASE WHEN a.avg_rating = b.max_rating THEN 'Да' ELSE 'Нет' END AS 'Рекомендуем' FROM avg_ratings a CROSS JOIN bounds b WHERE a.avg_rating = b.max_rating OR a.avg_rating = b.min_rating ORDER BY a.year, a.title;"
echo " "

echo "4. Вычислить количество оценок и среднюю оценку, которую дали фильмам женщины в период с 2010 по 2012 год."
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "SELECT COUNT(*) AS rating_count, ROUND(AVG(r.rating), 3) AS average_rating FROM ratings r JOIN users u ON u.id = r.user_id WHERE lower(u.gender) IN ('female', 'f', 'woman') AND date(r.timestamp, 'unixepoch') >= '2010-01-01' AND date(r.timestamp, 'unixepoch') < '2013-01-01';"
echo " "

echo "5. Составить список фильмов со средней оценкой и местом в рейтинге по средней оценке. Отсортировать по году и названию. Первые 20 записей."
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "WITH avg_ratings AS (SELECT m.id, m.title, m.year, AVG(r.rating) AS avg_rating FROM movies m JOIN ratings r ON r.movie_id = m.id GROUP BY m.id), ranked AS (SELECT id, title, year, avg_rating, RANK() OVER (ORDER BY avg_rating DESC) AS rating_rank FROM avg_ratings) SELECT title, year, ROUND(avg_rating, 3) AS avg_rating, rating_rank FROM ranked ORDER BY year, title LIMIT 20;"
echo " "

echo "6. Вывести 10 последних зарегистрированных пользователей в формате Фамилия Имя|Дата регистрации."
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "SELECT substr(name, instr(name, ' ') + 1) || ' ' || substr(name, 1, instr(name, ' ') - 1) || '|' || register_date AS user_info FROM users ORDER BY register_date DESC, id DESC LIMIT 10;"
echo " "

echo "7. С помощью рекурсивного CTE составить таблицу умножения для чисел от 1 до 10."
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE nums(n) AS (VALUES(1) UNION ALL SELECT n + 1 FROM nums WHERE n < 10), multiplication AS (SELECT a.n AS x, b.n AS y FROM nums a CROSS JOIN nums b) SELECT x || 'x' || y || '=' || (x * y) AS multiplication FROM multiplication ORDER BY x, y;"
echo " "

echo "8. С помощью рекурсивного CTE выделить все жанры фильмов, каждый жанр в отдельной строке."
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE split(movie_id, rest, genre) AS (SELECT id, genres || '|', '' FROM movies WHERE genres IS NOT NULL AND genres <> '' UNION ALL SELECT movie_id, substr(rest, instr(rest, '|') + 1), trim(substr(rest, 1, instr(rest, '|') - 1)) FROM split WHERE rest <> ''), all_genres AS (SELECT genre FROM split WHERE genre <> '' AND genre <> '(no genres listed)' UNION SELECT 'no genres listed' FROM movies WHERE genres = '(no genres listed)') SELECT DISTINCT genre FROM all_genres ORDER BY genre;"