SELECT occupation, COUNT() AS count_users FROM users u GROUP BY u.occupation;

--title, genres, INSTR(genres, 'Action') AS count_g,
SELECT INSTR(mov.genres, 'Action') as count_g, COUNT() FROM movies mov 
--WHERE count > 0
GROUP BY count_g;


--genres AS mov_g, COUNT()

--SELECT genres AS mov_g, COUNT() FROM movies mov 
SELECT genres_name, COUNT() AS count FROM
--JOIN
 (
    WITH RECURSIVE genres_list(genres, str) AS 
        (
            SELECT '', movies.genres || '|' FROM movies UNION ALL 
            SELECT SUBSTRING(str, 0, INSTR(str, '|')), SUBSTRING(genres, INSTR(genres, '|') + 1) FROM genres_list 
        --    SELECT movies.genres from movies
            WHERE str != ''
        ) 
    SELECT genres AS genres_name, str FROM genres_list 
    WHERE genres != '' 
    GROUP BY genres
    ) gl 
    JOIN movies  mov
    ON
     INSTR(mov.genres,  gl.genres_name ) > 0 GROUP BY gl.genres_name;
-- genres AS genres_name, str, COUNT( CASE WHEN INSTR( mov_g, genres ) THEN 1 ELSE 0 END) AS count