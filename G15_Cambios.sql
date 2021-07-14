-- CAMBIOS
ALTER TABLE gr15_asignatura
add column cantidad_prof_simples int DEFAULT 0 NOT NULL ;

ALTER TABLE gr15_asignatura
add column cantidad_prof_exclusivos int DEFAULT 0 NOT NULL ;

ALTER TABLE gr15_asignatura_profesor
add column activo boolean DEFAULT FALSE NOT NULL ;

-- Para que sólo ingrese cuatrimestre "reales", por ej: no existe un cuatrimestre 4
ALTER TABLE gr15_asignatura_profesor
ADD CONSTRAINT ck_cuatrimestre_gr15_asignatura_profesor
CHECK (cuatrimestre = 1 or cuatrimestre = 2);

-- tipo_prof solo puede contener valores 0 o 1
ALTER TABLE gr15_profesor
ADD CONSTRAINT ck_tipo_prof_gr15_profesor
CHECK (tipo_prof = 0 or tipo_prof = 1);

-- modifico todas las fk -> ON UPDATE,DELETE = CASCADE
    ALTER TABLE gr15_asignatura_profesor
    DROP CONSTRAINT fk_gr15_asignatura_profesor_asignatura;

    ALTER TABLE gr15_asignatura_profesor
    ADD CONSTRAINT fk_gr15_asignatura_profesor_asignatura
        FOREIGN KEY (cod_asig,tipo_asig)
        REFERENCES gr15_asignatura(cod_asig,tipo_asig)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT;

    ALTER TABLE gr15_asignatura_profesor
    DROP CONSTRAINT fk_gr15_asignatura_profesor_profesor;

    ALTER TABLE gr15_asignatura_profesor
    ADD CONSTRAINT fk_gr15_asignatura_profesor_profesor
        FOREIGN KEY (dni)
        REFERENCES gr15_profesor(dni)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT;

    ALTER TABLE gr15_prof_simple
    DROP CONSTRAINT fk_gr15_prof_simple_profesor;

    ALTER TABLE gr15_prof_simple
    ADD CONSTRAINT fk_gr15_prof_simple_profesor
        FOREIGN KEY (dni)
        REFERENCES gr15_profesor(dni)
        ON UPDATE CASCADE
        ON DELETE CASCADE;

    ALTER TABLE gr15_prof_exclusivo
    DROP CONSTRAINT fk_gr15_prof_exclusivo_profesor;

    ALTER TABLE gr15_prof_exclusivo
    ADD CONSTRAINT fk_gr15_prof_exclusivo_profesor
        FOREIGN KEY (dni)
        REFERENCES gr15_profesor(dni)
        ON UPDATE CASCADE
        ON DELETE CASCADE;

-- A1
-- Obtener cantidad de profesores
create or replace function fn_gr15_getCantidadProfesor(tipo integer, tipo_a char, cod integer)
returns bigint as  $$
    declare cantidad integer;
        begin
            if (tipo = 0) then
                select cantidad_prof_simples into cantidad from gr15_asignatura a
                    where a.cod_asig = cod and a.tipo_asig = tipo_a;
            else
                select cantidad_prof_exclusivos into cantidad from gr15_asignatura a
                    where a.cod_asig = cod and a.tipo_asig = tipo_a;
            end if;
            return cantidad;
        end;
$$ language 'plpgsql';

-- Actualizar cantidad
create or replace function fn_gr15_actualizarCantidad(tipo integer, cantidad bigint, tipo_a char, cod integer)
returns void as $$
    begin
        if (tipo = 0) then
            update gr15_asignatura a set cantidad_prof_simples = cantidad
                where a.cod_asig = cod and a.tipo_asig = tipo_a;
        else
            update gr15_asignatura a set cantidad_prof_exclusivos = cantidad
                where a.cod_asig = cod and a.tipo_asig = tipo_a;
        end if;
    end;
$$ language 'plpgsql';

-- insert
create or replace function trfn_gr15_insActualizarCantidad()
returns trigger as $$
    declare cantidad integer;
    declare rec record;
    declare tipo integer;
    begin
        for rec in ( select * from newTable ) LOOP
            select tipo_prof into tipo from gr15_profesor where dni = rec.dni;
            if ( rec.activo = true ) THEN
                cantidad = fn_gr15_getCantidadProfesor( tipo, rec.tipo_asig, rec.cod_asig);
                cantidad = cantidad + 1;
                if ( tipo = 0 ) THEN
                    PERFORM fn_gr15_actualizarCantidad( 0,cantidad,rec.tipo_asig, rec.cod_asig);
                elseif ( tipo = 1 ) THEN
                    PERFORM fn_gr15_actualizarCantidad( 1,cantidad,rec.tipo_asig, rec.cod_asig);
                end if;
            end if;
        END LOOP;
        RETURN NEW;
    END
    $$ language 'plpgsql';

create trigger tr_gr15_asignatura_profesor_insertActualizarCantidad
after insert on gr15_asignatura_profesor
REFERENCING NEW TABLE AS newTable
for each statement
execute procedure trfn_gr15_insActualizarCantidad();

-- update :
create or replace function trfn_gr15_updActualizarCantidad()
returns trigger as $$
    declare ntable record;
    declare otable record;
    declare tipoProf integer;
    declare cantidad integer;
    begin
        select * INTO ntable
        from newTable;
        FOR ntable IN ( select * from newTable) LOOP
            if ( ntable.activo = true ) THEN
                select tipo_prof into tipoProf from gr15_profesor where dni = ntable.dni;
                cantidad = fn_gr15_getCantidadProfesor( tipoProf, ntable.tipo_asig, ntable.cod_asig);
                cantidad = cantidad + 1;
                if ( tipoProf = 0 ) THEN
                    PERFORM fn_gr15_actualizarCantidad( 0, cantidad,ntable.tipo_asig,ntable.cod_asig);
                else
                    PERFORM fn_gr15_actualizarCantidad( 1, cantidad,ntable.tipo_asig,ntable.cod_asig);
                end if;
            end if;
        END LOOP;
        FOR otable IN ( select * from oldTable) LOOP
            if ( otable.activo = true ) THEN
                select tipo_prof into tipoProf from gr15_profesor where dni = otable.dni;
                cantidad = fn_gr15_getCantidadProfesor( tipoProf, otable.tipo_asig, otable.cod_asig);
                raise notice ' cantidad = %', cantidad;
                if ( cantidad > 0 ) THEN
                    cantidad = cantidad-1;
                end if;
                raise notice ' cantidad = %', cantidad;
                if ( tipoProf = 0 ) THEN
                    PERFORM fn_gr15_actualizarCantidad( 0, cantidad,otable.tipo_asig,otable.cod_asig);
                else
                    PERFORM fn_gr15_actualizarCantidad( 1, cantidad,otable.tipo_asig,otable.cod_asig);
                end if;
            end if;
        END LOOP;
        RETURN NEW;
    end
$$ language 'plpgsql';

create trigger tr_gr15_asignatura_profesor_updActualizarCantidad
after update on gr15_asignatura_profesor
REFERENCING NEW TABLE AS newTable OLD TABLE AS oldTable
for each statement
execute procedure trfn_gr15_updActualizarCantidad();

create or replace function trfn_gr15_delActualizarCantidad()
returns trigger as $$
    declare otable record;
    declare tipoProf int;
    declare cantidad integer;
    begin
        for otable in ( select * from oldTable ) LOOP
            if ( otable.activo = true ) THEN
                select tipo_prof into tipoProf from gr15_profesor where dni = otable.dni;
                cantidad = fn_gr15_getCantidadProfesor( tipoProf, otable.tipo_asig, otable.cod_asig);
                if ( cantidad > 0 ) THEN
                    cantidad = cantidad-1;
                end if;
                if ( tipoProf = 0 ) THEN
                    PERFORM fn_gr15_actualizarCantidad( 0, cantidad,otable.tipo_asig,otable.cod_asig);
                else
                    PERFORM fn_gr15_actualizarCantidad( 1, cantidad,otable.tipo_asig,otable.cod_asig);
                end if;
            end if;
        end loop;
        RETURN OLD;
    end;
$$ language 'plpgsql';

create trigger tr_gr15_asignatura_profesor_delActualizarCantidad
after delete on gr15_asignatura_profesor
REFERENCING OLD TABLE AS oldTable
for each statement
execute procedure trfn_gr15_delActualizarCantidad();

    -- A2
-- VISTA PROF_SIMPLE

CREATE VIEW GR15_V_PROF_SIMPLE
AS SELECT ps.dni,ps.perfil,p.apellido,p.nombre,p.titulo,p.departamento,p.tipo_prof
    FROM gr15_prof_simple ps JOIN gr15_profesor p ON ( ps.dni = p.dni);

--Vista no actualizable en postGresql porque contiene 2 tablas en el from

-- VISTA PROF_EXCLUSIVO

CREATE VIEW GR15_V_PROF_EXCLUSIVO
AS SELECT pe.dni,pe.proy_investig,p.apellido,p.nombre,p.titulo,p.departamento,p.tipo_prof
    FROM gr15_prof_exclusivo pe JOIN gr15_profesor p ON ( pe.dni = p.dni);

--Vista no actualizable en postGresql porque contiene 2 tablas en el from

    --A2
-- TRIGGERS
create or replace function trfn_gr15_controlProfesorSimple()
returns trigger as $$
    BEGIN
        if ( TG_OP = 'INSERT') THEN
            insert into gr15_profesor
                values ( NEW.dni,NEW.apellido,NEW.nombre,NEW.titulo,NEW.departamento,0);
            insert into gr15_prof_simple values ( NEW.dni, NEW.perfil);
        elseif ( TG_OP = 'UPDATE') THEN
            update gr15_profesor
                set apellido = NEW.apellido, nombre = NEW.nombre,
                    titulo = NEW.titulo, departamento = NEW.departamento
                where dni = OLD.dni;
            update gr15_prof_simple
                set perfil = NEW.perfil
                where dni = OLD.dni;
        elseif ( TG_OP = 'DELETE' ) THEN
            delete from gr15_prof_simple ps where ps.dni = OLD.dni;
            delete from gr15_profesor p where p.dni = OLD.dni;
            RETURN OLD;
        end if;
        RETURN NEW;
    END;
$$ language 'plpgsql';

create trigger tr_gr15_v_prof_simple_controlProfSimple
instead of insert or update or delete on GR15_V_PROF_SIMPLE
for each row execute procedure trfn_gr15_controlProfesorSimple();

create or replace function trfn_gr15_controlProfesorExclusivo()
returns trigger as $$
    BEGIN
        if ( TG_OP = 'INSERT') THEN
            insert into gr15_profesor
                values ( NEW.dni,NEW.apellido,NEW.nombre,NEW.titulo,NEW.departamento,1);
            insert into gr15_prof_exclusivo values ( NEW.dni, NEW.proy_investig);
        elseif ( TG_OP = 'UPDATE') THEN
            update gr15_profesor
                set apellido = NEW.apellido, nombre = NEW.nombre,
                    titulo = NEW.titulo, departamento = NEW.departamento
                where dni = OLD.dni;
            update gr15_prof_exclusivo
                set proy_investig = NEW.proy_investig
                where dni = OLD.dni;
        elseif ( TG_OP = 'DELETE' ) THEN
            delete from gr15_prof_exclusivo ps where ps.dni = OLD.dni;
            delete from gr15_profesor p where p.dni = OLD.dni;
            RETURN OLD;
        end if;
        RETURN NEW;
    END;
$$ language 'plpgsql';

create trigger tr_gr15_v_prof_exclusivo_controlProfExclusivo
instead of insert or update or delete on GR15_V_PROF_EXCLUSIVO
for each row execute procedure trfn_gr15_controlProfesorExclusivo();

-- No se puede actualizar el campo tipo_prof en PROFESOR
create or replace function trfn_gr15_controlProfesor()
returns trigger as $$
    begin
        raise exception ' Can not update tipo_prof ';
    END;
$$ language 'plpgsql';

create trigger tr_gr15_profesor_controlTipoProf
before update of tipo_prof on gr15_profesor
for each row execute procedure trfn_gr15_controlProfesor();

-- B1

CREATE VIEW GR15_V_ASIGNATURAS_SIMPLE
AS SELECT *
    FROM gr15_asignatura a
    WHERE (a.tipo_asig, a.cod_asig) IN (
              SELECT tipo_asig,cod_asig
              FROM gr15_asignatura_profesor aas
                WHERE aas.dni IN (
                    SELECT dni
                    FROM gr15_profesor
                    where tipo_prof = 0
                    )
        );

-- Esta vista es actualizable porque no utiliza funciones de agregación ni funciones de grupo, no incluye la cláusula DISTINCT, no incluye subconsultas
-- en el select, conserva la PK y en cada "from" -- tiene una sola tabla.

-- B2

CREATE VIEW GR15_V_PROFESORES_ASIG
AS SELECT dni,tipo_asig,cod_asig,cuatrimestre, cantidad_horas, sum(cantidad_horas) OVER cuatri
    FROM gr15_asignatura_profesor
    WINDOW cuatri AS ( PARTITION BY dni,cuatrimestre)
ORDER BY dni, cuatrimestre;

-- Esta vista no es actualizable porque utiliza funciones de agregación.
