CREATE SCHEMA reformas
  DEFAULT CHARACTER SET utf8
  COLLATE utf8_spanish2_ci;

CREATE TABLE reformas.proyectos (
  codP VARCHAR(3) UNIQUE NOT NULL,
  descripcion VARCHAR(20) NOT NULL,
  localidad VARCHAR(20) NOT NULL,
  cliente VARCHAR(40) NOT NULL,
  telefono INTEGER,
  PRIMARY KEY (codP)
);

CREATE TABLE reformas.conductores (
  codC VARCHAR(3) UNIQUE NOT NULL,
  nombre VARCHAR(40) NOT NULL,
  localidad VARCHAR(20) NOT NULL,
  categoria INTEGER NOT NULL,
  PRIMARY KEY (codC)
);

CREATE TABLE reformas.maquinas (
  codM VARCHAR(3) UNIQUE NOT NULL,
  nombre VARCHAR(30) NOT NULL,
  precioHora INTEGER NOT NULL,
  PRIMARY KEY (codM)
);

CREATE TABLE reformas.trabajos (
  codC VARCHAR(3) NOT NULL,
  codM VARCHAR(3) NOT NULL,
  codP VARCHAR(3) NOT NULL,
  fecha DATETIME NOT NULL,
  tiempo INTEGER,
  PRIMARY KEY (codC, codM, codP, fecha),
  CONSTRAINT
    FOREIGN KEY (codC)
    REFERENCES reformas.conductores (codC),
  CONSTRAINT
    FOREIGN KEY (codM)
    REFERENCES reformas.maquinas (codM),
  CONSTRAINT
    FOREIGN KEY (codP)
    REFERENCES reformas.proyectos (codP)
);

INSERT INTO reformas.proyectos VALUES
  ('P01', 'Garaje', 'Arganda', 'Felipe Sol', 600111111),
  ('P02', 'Solado', 'Rivas', 'José Pérez', 912222222),
  ('P03', 'Garaje', 'Arganda', 'Rosa López', 666999666),
  ('P04', 'Techado', 'Loeches', 'Felipe Sol', 913333333),
  ('P05', 'Buhardilla', 'Rivas', 'Ana Botijo', NULL);

INSERT INTO reformas.conductores VALUES
  ('C01', 'José Sánchez', 'Arganda', 18),
  ('C02', 'Manuel Díaz', 'Arganda', 15),
  ('C03', 'Juan Pérez', 'Rivas', 20),
  ('C04', 'Luis Ortiz', 'Arganda', 18),
  ('C05', 'Javier Martín', 'Loeches', 12),
  ('C06', 'Carmen Pérez', 'Rivas', 15);

INSERT INTO reformas.maquinas VALUES
  ('M01', 'Excavadora', 90),
  ('M02', 'Hormigonera', 60),
  ('M03', 'Volquete', 70),
  ('M04', 'Apisonadora', 110);

INSERT INTO reformas.trabajos VALUES
  ('C02', 'M03', 'P01', '2019-09-10', 100),
  ('C03', 'M01', 'P02', '2019-09-10', 200),
  ('C05', 'M03', 'P02', '2019-09-10', 150),
  ('C04', 'M03', 'P02', '2019-09-10', 90),
  ('C01', 'M02', 'P02', '2019-09-12', 120),
  ('C02', 'M03', 'P03', '2019-09-13', 30),
  ('C03', 'M01', 'P04', '2019-09-15', 300),
  ('C02', 'M03', 'P02', '2019-09-15', NULL),
  ('C01', 'M03', 'P04', '2019-09-15', 180),
  ('C05', 'M03', 'P04', '2019-09-15', 90),
  ('C01', 'M02', 'P04', '2019-09-17', NULL),
  ('C02', 'M03', 'P01', '2019-09-18', NULL);
