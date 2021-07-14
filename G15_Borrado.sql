
-- Borrado triggers

drop function trfn_gr15_controlprofesorsimple() cascade;
drop function trfn_gr15_controlprofesorexclusivo cascade ;
drop function trfn_gr15_controlprofesor cascade ;
drop function trfn_gr15_delactualizarcantidad cascade ;
drop function trfn_gr15_insactualizarcantidad cascade ;
drop function trfn_gr15_updactualizarcantidad cascade ;

-- Borrado funciones

drop function fn_gr15_actualizarcantidad(integer, bigint, char, integer) cascade;
drop function fn_gr15_getcantidadprofesor(integer, char, integer) cascade;

-- Borrado tablas

drop table gr15_asignatura_profesor cascade ;
drop table gr15_asignatura cascade ;
drop table gr15_profesor cascade ;
drop table gr15_prof_exclusivo cascade ;
drop table gr15_prof_simple cascade ;