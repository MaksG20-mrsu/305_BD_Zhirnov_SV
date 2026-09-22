import csv
import re
from pathlib import Path


BASE_DIR = Path(__file__).parent
DATASET_DIR = BASE_DIR / "dataset"
SQL_FILE = BASE_DIR / "db_init.sql"


def sql_value(value):
    """Подготавливает значение для SQL."""
    if value is None or value == "":
        return "NULL"

    value = str(value).replace("'", "''")
    return f"'{value}'"


def get_movie_data(title):
    """Извлекает год из названия фильма."""
    match = re.search(r"\((\d{4})\)\s*$", title)

    if match:
        year = match.group(1)
        clean_title = title[:match.start()].strip()
        return clean_title, year

    return title, None


def main():
    sql = []

    sql.append("PRAGMA foreign_keys = OFF;")
    sql.append("DROP TABLE IF EXISTS movies;")
    sql.append("DROP TABLE IF EXISTS ratings;")
    sql.append("DROP TABLE IF EXISTS tags;")
    sql.append("DROP TABLE IF EXISTS users;")

    sql.append("""
CREATE TABLE movies (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    year INTEGER,
    genres TEXT
);
""")

    sql.append("""
CREATE TABLE ratings (
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    movie_id INTEGER,
    rating REAL,
    timestamp INTEGER
);
""")

    sql.append("""
CREATE TABLE tags (
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    movie_id INTEGER,
    tag TEXT,
    timestamp INTEGER
);
""")

    sql.append("""
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    name TEXT,
    email TEXT,
    gender TEXT,
    register_date TEXT,
    occupation TEXT
);
""")

    with open(DATASET_DIR / "movies.csv", encoding="utf-8", newline="") as file:
        reader = csv.DictReader(file)

        for row in reader:
            title, year = get_movie_data(row["title"])

            sql.append(
                "INSERT INTO movies (id, title, year, genres) VALUES "
                f"({row['movieId']}, {sql_value(title)}, "
                f"{year if year else 'NULL'}, {sql_value(row['genres'])});"
            )

    with open(DATASET_DIR / "ratings.csv", encoding="utf-8", newline="") as file:
        reader = csv.DictReader(file)

        for index, row in enumerate(reader, start=1):
            sql.append(
                "INSERT INTO ratings "
                "(id, user_id, movie_id, rating, timestamp) VALUES "
                f"({index}, {row['userId']}, {row['movieId']}, "
                f"{row['rating']}, {row['timestamp']});"
            )

    with open(DATASET_DIR / "tags.csv", encoding="utf-8", newline="") as file:
        reader = csv.DictReader(file)

        for index, row in enumerate(reader, start=1):
            sql.append(
                "INSERT INTO tags "
                "(id, user_id, movie_id, tag, timestamp) VALUES "
                f"({index}, {row['userId']}, {row['movieId']}, "
                f"{sql_value(row['tag'])}, {row['timestamp']});"
            )

    with open(DATASET_DIR / "users.txt", encoding="utf-8") as file:
        for line in file:
            line = line.strip()

            if not line:
                continue

            user_id, name, email, gender, register_date, occupation = line.split("|")

            sql.append(
                "INSERT INTO users "
                "(id, name, email, gender, register_date, occupation) VALUES "
                f"({user_id}, {sql_value(name)}, {sql_value(email)}, "
                f"{sql_value(gender)}, {sql_value(register_date)}, "
                f"{sql_value(occupation)});"
            )

    sql.append("PRAGMA foreign_keys = ON;")

    SQL_FILE.write_text("\n".join(sql), encoding="utf-8")

    print(f"SQL-файл создан: {SQL_FILE}")


if __name__ == "__main__":
    main()
