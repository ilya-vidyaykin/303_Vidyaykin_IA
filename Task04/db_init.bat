#!/bin/bash
chcp 65001

sqlite3 movies_rating.db < db_init.sql

echo "1. Найти все пары пользователей, оценивших один и тот же фильм. Устранить дубликаты, проверить отсутствие пар с самим собой. Для каждой пары должны быть указаны имена пользователей и название фильма, который они ценили."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT users1.title AS Move, users1.name AS Users1, users2.name AS Users2  FROM (SELECT users.name, movies.title, users.id FROM ratings INNER JOIN users ON ratings.user_id = users.id INNER JOIN movies ON ratings.movie_id = movies.id) AS users1 JOIN (SELECT users.name, movies.title, users.id  FROM ratings INNER JOIN users ON ratings.user_id = users.id INNER JOIN movies ON ratings.movie_id = movies.id) AS users2 ON users1.title=users2.title WHERE users1.name < users2.name ORDER BY users1.title, users1.name, users2.name;"
echo " "

echo "2. Найти 10 самых старых оценок от разных пользователей, вывести названия фильмов, имена пользователей, оценку, дату отзыва в формате ГГГГ-ММ-ДД."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT m.title, u.name, r.rating, DATE(r.timestamp, 'unixepoch') AS date FROM (ratings r INNER JOIN users u ON r.user_id = u.id INNER JOIN  movies m  ON r.movie_id = m.id) GROUP BY u.name ORDER BY r.timestamp ASC LIMIT 10;"
echo " "

echo "3. Вывести в одном списке все фильмы с максимальным средним рейтингом и все фильмы с минимальным средним рейтингом. Общий список отсортировать по году выпуска и названию фильма. В зависимости от рейтинга в колонке \"Рекомендуем\" для фильмов должно быть написано \"Да\" или \"Нет\"."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT title, year, (CASE WHEN max = avg_rating then 'Да' ELSE 'Нет' END) AS 'Рекомендуем', avg_rating AS 'Рейтинг' FROM (SELECT title, year, AVG(ratings.rating) AS avg_rating, MAX(AVG(ratings.rating)) OVER() AS max, MIN(AVG(ratings.rating)) OVER() AS min FROM ratings JOIN movies m ON ratings.movie_id = m.id GROUP BY ratings.movie_id) WHERE avg_rating = max OR avg_rating = min ORDER BY year, title;"
echo " "

echo "4. Вычислить количество оценок и среднюю оценку, которую дали фильмам пользователи-мужчины в период с 2011 по 2014 год."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT COUNT(*) AS count, ROUND(AVG(ratings.rating), 2) AS avg_rating FROM (users JOIN ratings ON users.id=ratings.user_id) WHERE (users.gender='male' AND DATE(ratings.timestamp, 'unixepoch')>='2011-01-01' AND DATE(ratings.timestamp, 'unixepoch')<'2014-01-01');"
echo " "

echo "5. Составить список фильмов с указанием средней оценки и количества пользователей, которые их оценили. Полученный список отсортировать по году выпуска и названиям фильмов. В списке оставить первые 20 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT title, year, ROUND(AVG(r.rating), 2) AS avg_rating, COUNT(*) AS count_user FROM movies mov JOIN ratings r ON mov.id = r.movie_id  GROUP BY mov.id ORDER BY year DESC, title LIMIT 20;"
echo " "

echo "6. Определить самый распространенный жанр фильма и количество фильмов в этом жанре. Отдельную таблицу для жанров не использовать, жанры нужно извлекать из таблицы movies."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT genres_name, COUNT() AS count_moveies FROM (WITH RECURSIVE genres_list(genres, str) AS ( SELECT '', movies.genres || '|' FROM movies UNION ALL SELECT SUBSTRING(str, 0, INSTR(str, '|')), SUBSTRING(genres, INSTR(genres, '|') + 1) FROM genres_list WHERE str != '') SELECT genres AS genres_name, str FROM genres_list WHERE genres != '' GROUP BY genres ) gl JOIN movies  mov ON INSTR(mov.genres,  gl.genres_name ) > 0 GROUP BY gl.genres_name ORDER BY count_moveies DESC;"
echo "Самы популярный жанр"
sqlite3 movies_rating.db -box -echo "SELECT genres_name, MAX(count_moveies) as max FROM ( SELECT genres_name, COUNT() AS count_moveies FROM (WITH RECURSIVE genres_list(genres, str) AS ( SELECT '', movies.genres || '|' FROM movies UNION ALL SELECT SUBSTRING(str, 0, INSTR(str, '|')), SUBSTRING(genres, INSTR(genres, '|') + 1) FROM genres_list WHERE str != '') SELECT genres AS genres_name, str FROM genres_list WHERE genres != '' GROUP BY genres ) gl JOIN movies  mov ON INSTR(mov.genres,  gl.genres_name ) > 0 GROUP BY gl.genres_name)"
echo " "

echo "7. Вывести список из 10 последних зарегистрированных пользователей в формате 'Фамилия Имя|Дата регистрации' (сначала фамилия, потом имя)."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT SUBSTRING(users.name, INSTR(users.name, ' ')+1) ||' '|| SUBSTRING(users.name, 1, INSTR(users.name, ' ')-1) AS FIO, users.register_date FROM users ORDER BY register_date DESC LIMIT 10;"
echo " "

echo "8. С помощью рекурсивного CTE определить, на какие дни недели приходился ваш день рождения в каждом году."
echo --------------------------------------------------
echo " "

