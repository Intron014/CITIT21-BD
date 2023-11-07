SET autocommit = 0;

START TRANSACTION;
INSERT INTO peliculas.film (title, description, release_date, language_id, original_language_id, length_minutes)
VALUE ('Pulp Fiction', 'Pulp Fiction is a movie', '1994-05-21', 'es', 'en', 154);
SELECT *
FROM film
WHERE title LIKE ('Pulp%');
COMMIT;

START TRANSACTION;
DELETE FROM film
    WHERE film_id = 6001;

ROLLBACK;
START TRANSACTION;
SELECT *
FROM film
WHERE title LIKE ('Pulp%');
COMMIT;