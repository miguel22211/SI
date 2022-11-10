--Crear tabla para el estado del pedido
CREATE TABLE sstatus(
	status_id SERIAL PRIMARY KEY,
	sstatus varchar(14)
);

INSERT INTO sstatus (sstatus)

VALUES (NULL),('Paid'),('Processed'),('Shipped');

--Tabla para relacionar el estado con el ID 
CREATE TABLE estados AS 
	SELECT orderid, orderdate, customerid, netamount, tax, totalamount, status_id AS sstatus
	FROM sstatus NATURAL JOIN orders;
	
DROP TABLE orders;

ALTER TABLE estados RENAME TO orders;

--Tabla para los generos
CREATE TABLE genres(
	genre_id SERIAL PRIMARY KEY,
	genre varchar(20) NOT NULL
);

INSERT INTO genres (genre) 
SELECT genre FROM imdb_moviegenres GROUP BY genre ORDER BY genre ASC;

ALTER TABLE imdb_moviegenres
    ADD COLUMN genre_id INTEGER,
    ADD FOREIGN KEY (genre_id) REFERENCES genres(genre_id);

UPDATE imdb_moviegenres
SET genre_id = genres.genre_id
FROM genres
WHERE genres.genre = imdb_moviegenres.genre;

ALTER TABLE imdb_moviegenres
    DROP COLUMN genre;

--Tabla para el atributo de los paises
CREATE TABLE countries(
	country_id SERIAL PRIMARY KEY,
	country varchar(32) NOT NULL
);

INSERT INTO countries (country) 
SELECT country FROM imdb_moviecountries GROUP BY country ORDER BY country ASC;

ALTER TABLE imdb_moviecountries
    ADD COLUMN country_id INTEGER,
    ADD FOREIGN KEY (country_id) REFERENCES countries(country_id);

UPDATE imdb_moviecountries
SET country_id = countries.country_id
FROM countries 
WHERE countries.country = imdb_moviecountries.country;

ALTER TABLE imdb_moviecountries
    DROP COLUMN country;

--Tabla para el atributo de los lenguajes
CREATE TABLE languagee(
	language_id SERIAL PRIMARY KEY,
	languagee varchar(32) NOT NULL
);

INSERT INTO languagee (languagee) 
SELECT languagee FROM imdb_movielanguages GROUP BY languagee ORDER BY languagee ASC;

ALTER TABLE imdb_movielanguages
    ADD COLUMN language_id INTEGER,
    ADD FOREIGN KEY (language_id) REFERENCES languagee(language_id);

UPDATE imdb_movielanguages
SET language_id = language.language_id
FROM language 
WHERE language.language = imdb_movielanguages.language;

ALTER TABLE imdb_movielanguages
    DROP COLUMN language;


-- Añadir foreign keys a imdb_actormovies
ALTER TABLE imdb_actormovies 
	ADD FOREIGN KEY (actorid) REFERENCES imdb_actors(actorid);

ALTER TABLE imdb_actormovies 
	ADD FOREIGN KEY (movieid) REFERENCES imdb_movies(movieid);

-- Añadir foreign keys a iventoryºº
ALTER TABLE inventory 
	ADD FOREIGN KEY (prod_id) REFERENCES products(prod_id);

-- Añadir primary key a imdb_moviecountries
ALTER TABLE imdb_moviecountries
	ADD PRIMARY KEY (movieid, country_id);

-- Añadir primary key a imdb_moviegenres
ALTER TABLE imdb_moviegenres
	ADD PRIMARY KEY (movieid, genre_id);

-- Añadir primary key a imdb_movielanguages
ALTER TABLE imdb_movielanguages
	ADD PRIMARY KEY (movieid, language_id, extrainformation);

-- Añadir primary key a orderdetail (juntar pedidos con productos del mismo tipo)
CREATE TABLE aux AS 
	SELECT orderid, prod_id, SUM(quantity) AS quantity 
	FROM orderdetail 
	GROUP BY orderid, prod_id;
	
DROP TABLE orderdetail;
ALTER TABLE aux RENAME TO orderdetail;

ALTER TABLE orderdetail
    ADD COLUMN subtotal NUMERIC(10, 2);

ALTER TABLE orderdetail
	ADD PRIMARY KEY (orderid, prod_id);

-- Añadir primary key a orders
ALTER TABLE orders
	ADD PRIMARY KEY (orderid);

-- Añadir foreign key a orders
ALTER TABLE orders 
	ADD FOREIGN KEY (customerid) REFERENCES customers(customerid);

-- Añadir foreign key a orderdetail
ALTER TABLE orderdetail 
	ADD FOREIGN KEY (prod_id) REFERENCES products(prod_id);

-- Debemos concatenar el username y el cutomerid para gestionar usuarios con el mismo nombre
UPDATE customers
SET username = username || customerid
WHERE username IN (SELECT username
	  FROM customers
	  GROUP BY username
	  HAVING COUNT(username) > 1)


ALTER TABLE imdb_actormovies DROP CONSTRAINT actormovies_actorid_fkey;
ALTER TABLE imdb_actormovies ADD CONSTRAINT actormovies_actorid_fkey FOREIGN KEY (actorid) REFERENCES public.imdb_actors(actorid) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE imdb_actormovies DROP CONSTRAINT actormovies_movieid_fkey;
ALTER TABLE imdb_actormovies ADD CONSTRAINT actormovies_movieid_fkey FOREIGN KEY (movieid) REFERENCES public.imdb_movies(movieid) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE;


ALTER TABLE imdb_directormovies DROP CONSTRAINT imdb_directormovies_directorid_fkey;
ALTER TABLE imdb_directormovies ADD CONSTRAINT directormovies_directorid_fkey FOREIGN KEY (directorid) REFERENCES public.imdb_directors(directorid) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE imdb_directormovies DROP CONSTRAINT imdb_directormovies_movieid_fkey;
ALTER TABLE imdb_directormovies ADD CONSTRAINT directormovies_movieid_fkey FOREIGN KEY (movieid) REFERENCES public.imdb_movies(movieid) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE inventory DROP CONSTRAINT inventory_prod_id_fkey;
ALTER TABLE inventory ADD CONSTRAINT inventory_prod_id_fkey FOREIGN KEY (prod_id) REFERENCES public.imdb_products(prod_id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE;

-- ARREGLO MOVIECOUNTRIES
ALTER TABLE imdb_moviecountries DROP CONSTRAINT imdb_moviecountries_movieid_fkey;
ALTER TABLE imdb_moviecountries ADD CONSTRAINT moviecountries_movieid_fkey FOREIGN KEY (movieid) REFERENCES public.imdb_movies(movieid) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE imdb_moviecountries DROP CONSTRAINT moviecountries_country_id_fkey;
ALTER TABLE imdb_moviecountries ADD CONSTRAINT moviecountries_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.countries(country_id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE;

-- ARREGLO MOVIEGENRES
ALTER TABLE imdb_moviegenres DROP CONSTRAINT imdb_moviegenres_movieid_fkey;
ALTER TABLE imdb_moviegenres ADD CONSTRAINT moviegenres_movieid_fkey FOREIGN KEY (movieid) REFERENCES public.imdb_movies(movieid) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE imdb_moviegenres DROP CONSTRAINT moviegenres_genre_id_fkey;
ALTER TABLE imdb_moviegenres ADD CONSTRAINT moviegenres_genre_id_fkey FOREIGN KEY (genre_id) REFERENCES public.genres(genre_id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE;

-- ARREGLO MOVIELANGUAGES
ALTER TABLE imdb_movielanguages DROP CONSTRAINT imdb_movielanguages_movieid_fkey;
ALTER TABLE imdb_movielanguages ADD CONSTRAINT movielanguages_movieid_fkey FOREIGN KEY (movieid) REFERENCES public.imdb_movies(movieid) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE imdb_movielanguages DROP CONSTRAINT movielanguages_language_id_fkey;
ALTER TABLE imdb_movielanguages ADD CONSTRAINT movielanguages_language_id_fkey FOREIGN KEY (language_id) REFERENCES public.language(language_id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE;

-- ARREGLO ORDERDETAIL
ALTER TABLE orderdetail DROP CONSTRAINT orderdetail_prod_id_fkey;
ALTER TABLE orderdetail ADD CONSTRAINT orderdetail_prod_id_fkey FOREIGN KEY (prod_id) REFERENCES public.products(prod_id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE orderdetail DROP CONSTRAINT orderdetail_orderid_fkey;
ALTER TABLE orderdetail ADD CONSTRAINT orderdetail_orderid_fkey FOREIGN KEY (orderid) REFERENCES public.orders(orderid) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE;

-- ARREGLO ORDERS
ALTER TABLE orders DROP CONSTRAINT orders_customerid_fkey;
ALTER TABLE orders ADD CONSTRAINT orders_customerid_fkey FOREIGN KEY (customerid) REFERENCES public.customers(customerid) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE;

-- ARREGLO PRODUCTS
ALTER TABLE products DROP CONSTRAINT products_movieid_fkey;
ALTER TABLE products ADD CONSTRAINT products_movieid_fkey FOREIGN KEY (movieid) REFERENCES public.imdb_movies(movieid) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE;

-- ARREGLO DE SECUENCIAS


-- ARREGLO DE LA TABLA DE PELICULAS PARA GUARDAR EL NOMBRE DE LA IMAGEN QUE SE CORRESPONDE CON LA PELICULA


--ANIADIMOS LAS PELICULAS DEL TOP VENTAS Y AL RESTO DE PELICULAS LE PONEMOS UNA IMAGEN PREDETERMINADA
