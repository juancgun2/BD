--EJECUTAR EN CASO DE TENER LAS TABLAS YA CREADAS
    --drop table asignatura cascade ;
    --drop table profesor cascade ;
    --drop table asignatura_profesor cascade ;
    --drop table prof_exclusivo cascade ;
    --drop table prof_simple cascade ;

-- EJECUTAR EN CASO DE TENER DATOS EN LAS TABLAS GR15_
    --delete from gr15_asignatura;
    --delete from gr15_profesor;
    --delete from gr15_asignatura_profesor;
    --delete from gr15_prof_exclusivo;
    --delete from gr15_prof_simple

                    -- ATENCION !!!
-- EL SIGUIENTE SCRIPT YA TIENE AGREGADO LAS COLUMNAS:
    -- ACTIVO                   BOOLEAN DEFAULT FALSE
    -- CANTIDAD_PROF_SIMPLES    INT     DEFAULT 0
    -- CANTIDAD_PROF_EXCLUSIVOS INT     DEFAULT 0

-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2021-05-17 13:35:11.621

-- tables
-- Table: ASIGNATURA
CREATE TABLE ASIGNATURA (
    tipo_asig char(2)  NOT NULL,
    cod_asig int  NOT NULL,
    nombre_asig varchar(40)  NOT NULL,
    cant_hs_t int  NOT NULL,
    cant_hs_p int  NOT NULL,
    cantidad_prof_simples int DEFAULT 0,
    cantidad_prof_exclusivos int DEFAULT 0,
    CONSTRAINT PK_ASIGNATURA PRIMARY KEY (tipo_asig,cod_asig)
);

-- Table: ASIGNATURA_PROFESOR
CREATE TABLE ASIGNATURA_PROFESOR (
    dni int  NOT NULL,
    tipo_asig char(2)  NOT NULL,
    cod_asig int  NOT NULL,
    cuatrimestre int  NOT NULL,
    cantidad_horas int  NOT NULL,
    activo boolean DEFAULT FALSE,
    CONSTRAINT PK_ASIGNATURA_PROFESOR PRIMARY KEY (dni,tipo_asig,cod_asig)
);

-- Table: PROFESOR
CREATE TABLE PROFESOR (
    dni int  NOT NULL,
    apellido varchar(50)  NOT NULL,
    nombre varchar(30)  NOT NULL,
    titulo varchar(30)  NULL,
    departamento int  NOT NULL,
    tipo_prof int  NOT NULL,
    CONSTRAINT PK_PROFESOR PRIMARY KEY (dni)
);

-- Table: PROF_EXCLUSIVO
CREATE TABLE PROF_EXCLUSIVO (
    dni int  NOT NULL,
    proy_investig varchar(20) DEFAULT 'proyecto' NOT NULL,
    CONSTRAINT PK_PROF_EXCLUSIVO PRIMARY KEY (dni)
);

-- Table: PROF_SIMPLE
CREATE TABLE PROF_SIMPLE (
    dni int  NOT NULL,
    perfil varchar(120) DEFAULT 'perfil' NOT NULL ,
    CONSTRAINT PK_PROF_SIMPLE PRIMARY KEY (dni)
);

-- foreign keys
-- Reference: FK_ASIGNATURA_PROFESOR_ASIGNATURA (table: ASIGNATURA_PROFESOR)
ALTER TABLE ASIGNATURA_PROFESOR ADD CONSTRAINT FK_ASIGNATURA_PROFESOR_ASIGNATURA
    FOREIGN KEY (tipo_asig, cod_asig)
    REFERENCES ASIGNATURA (tipo_asig, cod_asig)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_ASIGNATURA_PROFESOR_PROFESOR (table: ASIGNATURA_PROFESOR)
ALTER TABLE ASIGNATURA_PROFESOR ADD CONSTRAINT FK_ASIGNATURA_PROFESOR_PROFESOR
    FOREIGN KEY (dni)
    REFERENCES PROFESOR (dni)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_PROF_EXCLUSIVO_PROFESOR (table: PROF_EXCLUSIVO)
ALTER TABLE PROF_EXCLUSIVO ADD CONSTRAINT FK_PROF_EXCLUSIVO_PROFESOR
    FOREIGN KEY (dni)
    REFERENCES PROFESOR (dni)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_PROF_SIMPLE_PROFESOR (table: PROF_SIMPLE)
ALTER TABLE PROF_SIMPLE ADD CONSTRAINT FK_PROF_SIMPLE_PROFESOR
    FOREIGN KEY (dni)
    REFERENCES PROFESOR (dni)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- End of file.


-- LLenar tabla asignatura
insert into asignatura values ( 'a',1,'ja',10,15,default,default);
insert into asignatura values ( 'a',2,'ja',10,15,default,default);
insert into asignatura values ( 'a',3,'ja',10,15,default,default);
insert into asignatura values ( 'a',4,'ja',10,15,default,default);
insert into asignatura values ( 'a',5,'ja',10,15,default,default);
insert into asignatura values ( 'a',6,'ja',10,15,default,default);
insert into asignatura values ( 'a',7,'ja',10,15,default,default);

--LLenar tabla profesor
insert into profesor values (1,'apell','nombre','titulo',5,0);
insert into profesor values (2,'apell','nombre','titulo',5,1);
insert into profesor values (3,'apell','nombre','titulo',5,0);
insert into profesor values (4,'apell','nombre','titulo',5,1);
insert into profesor values (5,'apell','nombre','titulo',5,0);
insert into profesor values (6,'apell','nombre','titulo',5,1);
insert into profesor values (7,'apell','nombre','titulo',5,0);
insert into profesor values (8,'apell','nombre','titulo',5,1);
insert into profesor values (9,'apell','nombre','titulo',5,0);
insert into profesor values (10,'apell','nombre','titulo',5,1);

--LLenar tabla prof_simple
insert into prof_simple ( select dni from profesor where tipo_prof = 0 );

--LLenar tabla prof_exclusivo
insert into prof_exclusivo ( select dni from profesor where tipo_prof = 1);

-- LLenar tabla asignatura-profesor
insert into asignatura_profesor values ( 1,'a',1,1,12,true);
insert into asignatura_profesor values ( 1,'a',2,1,65,true);
insert into asignatura_profesor values ( 1,'a',3,2,56,true);
insert into asignatura_profesor values ( 1,'a',4,2,43,true);
insert into asignatura_profesor values ( 2,'a',1,1,34,true);
insert into asignatura_profesor values ( 2,'a',2,1,67,true);
insert into asignatura_profesor values ( 2,'a',3,2,88,true);
insert into asignatura_profesor values ( 2,'a',4,2,98,true);
insert into asignatura_profesor values ( 3,'a',1,1,23,true);
insert into asignatura_profesor values ( 3,'a',2,1,23,true);
insert into asignatura_profesor values ( 3,'a',3,2,87,true);
insert into asignatura_profesor values ( 3,'a',4,1,34,true);
insert into asignatura_profesor values ( 4,'a',1,1,76,true);
insert into asignatura_profesor values ( 4,'a',2,2,67,true);
insert into asignatura_profesor values ( 4,'a',3,2,78,true);
insert into asignatura_profesor values ( 4,'a',4,1,83,true);

--LLenar las tablas gr15_
insert into gr15_asignatura ( select * from asignatura);
insert into gr15_profesor ( select * from profesor);
insert into gr15_asignatura_profesor ( select * from asignatura_profesor);
insert into gr15_prof_simple ( select * from prof_simple);
insert into gr15_prof_exclusivo ( select * from prof_exclusivo);
