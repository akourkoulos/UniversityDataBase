-- FUNCTION: public.findbigroomprofessors_4_1()

-- DROP FUNCTION IF EXISTS public.findbigroomprofessors_4_1();

CREATE OR REPLACE FUNCTION public.findbigroomprofessors_4_1(
	)
    RETURNS TABLE(amka integer) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
/*Ανάκτηση ονοματεπωνύμου και ΑΜΚΑ καθηγητών και εργαστηριακού προσωπικού οι
οποίοι έχουν διδάξει σε αίθουσες με χωρητικότητα μεγαλύτερης των 30 ατόμων.
*/
Begin

RETURN QUERY
select distinct per.amka
from (
public."Person" per
inner join
(select *
from(
public."Participates" pa
inner join
(select*
from (
public."learningactivity" la
inner join
public."room" r
 on la.activity_room_id = r.room_id)
where( r.capacity>30)and (la.activity_type='lecture')and(r.room_type='lecture_room'))as a on a.room_id=pa.activity_room_id)where(pa.role='responsible'))as b on b.amka=per.amka) 
order by amka;
end;
 
$BODY$;

ALTER FUNCTION public.findbigroomprofessors_4_1()
    OWNER TO postgres;
