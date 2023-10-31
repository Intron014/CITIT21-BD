SELECT DISTINCT(codC) FROM trabajos WHERE codP IN ('P02', 'P04');
SELECT DISTINCT(codC) FROM trabajos WHERE codP='P02' AND codC IN(SELECT DISTINCT(codC) FROM trabajos WHERE codP='P04');

# Ejercicios de Clase
## 1
    SELECT nombre, fecha
    FROM conductores JOIN reformas.trabajos ON conductores.codC = trabajos.codC
    AND fecha='2019-09-12 00:00:00';
## 2 Trabajadores que hayan trabajado en todos los proyectos
    SELECT c.nombre
    FROM conductores c
    WHERE NOT EXISTS(
        SELECT p.CodP
        FROM proyectos p
        WHERE p.codP NOT IN (SELECT t.CodP
                             FROM trabajos t
                             WHERE t.codC = c.codC));


# Ejercicios Paper
##01
    SELECT nombre FROM conductores WHERE categoria>15;
##02
    SELECT DISTINCT descripcion
    FROM proyectos INNER JOIN trabajos
    ON proyectos.codP=trabajos.codP
    WHERE fecha BETWEEN '2019-09-11 00:00:00' AND  '2019-09-15 00:00:00';
##03
    SELECT DISTINCT nombre
    FROM trabajos INNER JOIN conductores ON trabajos.codC=conductores.codC
    WHERE codM='M02'
    ORDER BY nombre DESC;
##04
    SELECT DISTINCT nombre
    FROM conductores
        RIGHT JOIN reformas.trabajos t on conductores.codC = t.codC
        RIGHT JOIN reformas.proyectos p on p.codP = t.codP
    WHERE codM='M02' && p.localidad='Arganda';
##05
    SELECT DISTINCT nombre, descripcion
    FROM conductores
        RIGHT JOIN reformas.trabajos t on conductores.codC = t.codC
        RIGHT JOIN reformas.proyectos p on p.codP = t.codP
    WHERE codM = 'M02' AND fecha BETWEEN '2019-09-12 00:00:00' AND '2019-09-17 00:00:00' AND p.localidad = 'Arganda';
##06
    SELECT DISTINCT conductores.codC
    FROM conductores
        JOIN reformas.trabajos t on conductores.codC = t.codC
        JOIN reformas.proyectos p on p.codP = t.codP
    WHERE cliente = 'José Pérez';
##07
    SELECT DISTINCT conductores.localidad, nombre
    FROM conductores WHERE codC NOT IN (SELECT codC FROM trabajos WHERE codP = 'P02');
##08
    SELECT *
    FROM proyectos
    WHERE localidad = 'Rivas' or cliente LIKE 'José%';
##09
    SELECT codC
    FROM conductores WHERE codC IN (SELECT codC FROM trabajos WHERE tiempo is null);
##10
    SELECT c.codC AS ID, c.nombre AS Nombre, c.localidad AS Localidad, p.localidad AS LocalidadProyecto
    FROM conductores c
             JOIN reformas.trabajos t ON c.codC = t.codC
             JOIN reformas.proyectos p ON p.codP = t.codP
    WHERE c.nombre LIKE '%Pérez%'
      AND c.localidad NOT IN (
        SELECT DISTINCT p.localidad
        FROM reformas.proyectos p
        WHERE p.codP IN (SELECT t.codP FROM reformas.trabajos t WHERE t.codC = c.codC)
    );
##11
    SELECT DISTINCT c.nombre, c.localidad, p.localidad
    FROM conductores c
        JOIN reformas.trabajos t on c.codC = t.codC
        JOIN reformas.proyectos p on p.codP = t.codP
        JOIN reformas.maquinas m on m.codM = t.codM
    WHERE t.codM IN (SELECT m.codM FROM reformas.maquinas m WHERE precioHora BETWEEN 60 AND 90);
##12
    SELECT c.nombre, c.localidad, p.localidad
    FROM conductores c
        JOIN reformas.trabajos t on c.codC = t.codC
        JOIN reformas.proyectos p on t.codP = p.codP
        JOIN reformas.maquinas m on t.codM = m.codM
    WHERE p.localidad = 'Rivas'  AND m.nombre NOT IN ('Hormigonera', 'Excavadora');
##13
    SELECT p.*, c.nombre, c.localidad
    FROM proyectos p
        JOIN reformas.trabajos t on p.codP = t.codP
        JOIN reformas.conductores c on t.codC = c.codC
    WHERE t.fecha = '2019-09-15 00:00:00';
##14
    SELECT c.nombre, p.cliente, p.localidad
    FROM conductores c
        JOIN reformas.trabajos t on c.codC = t.codC
        JOIN reformas.proyectos p on p.codP = t.codP
    WHERE t.codM = 'M04';
##15
    SELECT p.*
    FROM proyectos p
    WHERE p.codP = all (select MIN(m.precioHora) from reformas.maquinas m);
##16
    SELECT DISTINCT p.*
    FROM proyectos p
        JOIN reformas.trabajos t on p.codP = t.codP
        JOIN reformas.conductores c on c.codC = t.codC
    WHERE c.categoria IN (SELECT MAX(c.categoria) FROM conductores c);
##17
    SELECT p.cliente,SUM(t.tiempo) as time
    FROM proyectos p
        JOIN reformas.trabajos t on p.codP = t.codP
    GROUP BY p.cliente;
##18
    SELECT p.codP,p.descripcion, p.cliente, SUM(m.precioHora*t.tiempo) as coste, SUM(m.precioHora*t.tiempo*1.21)as iva
    FROM proyectos p
        JOIN reformas.trabajos t on p.codP = t.codP
        JOIN reformas.maquinas m on t.codM = m.codM
    GROUP BY p.codP
    ORDER BY iva DESC;
##19
    SELECT *
    FROM(SELECT p.codP as CodP, p.descripcion as Descr, p.cliente as Cliente, SUM(m.precioHora*t.tiempo) as coste, SUM(m.precioHora*t.tiempo*1.21)as iva
         FROM proyectos p
                  JOIN reformas.trabajos t on p.codP = t.codP
                  JOIN reformas.maquinas m on t.codM = m.codM
         GROUP BY p.codP) as patata
    WHERE coste = (select max(coste)
                   FROM(SELECT p.codP as CodP, p.descripcion as Descr, p.cliente as Cliente, SUM(m.precioHora*t.tiempo) as coste, SUM(m.precioHora*t.tiempo*1.21)as iva
                        FROM proyectos p
                                 JOIN reformas.trabajos t on p.codP = t.codP
                                 JOIN reformas.maquinas m on t.codM = m.codM
                        GROUP BY p.codP) as pimiento);
##20
    SELECT DISTINCT c.*
    FROM conductores c
    WHERE NOT EXISTS (
        SELECT p.codP
        FROM reformas.proyectos p
        WHERE p.localidad = 'Arganda'
        EXCEPT
        SELECT t.codP
        FROM reformas.trabajos t
        WHERE t.codC = c.codC
    );
##21
    SELECT p.codP, MAX(t.tiempo) as max_tiempo, COUNT(t.codC) as counts
    FROM proyectos p
        JOIN reformas.trabajos t ON p.codP = t.codP
    GROUP BY p.codP
    HAVING counts>1;
##22
    SELECT p.codP, COUNT(t.codP) as splits
    FROM proyectos p
             JOIN reformas.trabajos t ON p.codP = t.codP
    GROUP BY p.codP
    HAVING splits > 1
    ORDER BY splits DESC;

    SELECT DISTINCT t.codP, COUNT(t.codP) as splits, p.cliente, p.descripcion
         FROM trabajos t
         JOIN reformas.proyectos p on p.codP = t.codP
         GROUP BY t.codP
    HAVING splits = (SELECT MAX(splits)
                    FROM (SELECT DISTINCT t.codP, COUNT(t.codP) as splits
                          FROM trabajos t
                          GROUP BY t.codP) as pimiento);

##23
    SELECT distinct c.localidad
    FROM conductores c
        JOIN reformas.trabajos t on c.codC = t.codC
    GROUP BY t.codC
    HAVING COUNT(t.codP) > 2;
##24
    CREATE TABLE reformas.maquinasBig AS SELECT * FROM reformas.maquinas
    WHERE precioHora = (SELECT max(precioHora) FROM reformas.maquinas);
    UPDATE reformas.maquinas
    SET precioHora = precioHora*1.1
    WHERE codM NOT IN (SELECT r.codM
                       FROM (SELECT codM, precioHora FROM reformas.maquinasBig) as r
                       WHERE precioHora = (SELECT max(precioHora) FROM reformas.maquinasBig));
    DROP TABLE maquinasBig;