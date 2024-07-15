-- FUNCTION: public.afternoonlessons_4_5()

-- DROP FUNCTION IF EXISTS public.afternoonlessons_4_5();

CREATE OR REPLACE FUNCTION public.afternoonlessons_4_5(
	)
    RETURNS TABLE(course_code character, afternoonlesson text) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
/*Ανάκτηση όλων των κωδικών όλων των υποχρεωτικών μαθημάτων με την ένδειξη ΝΑΙ ή
ΌΧΙ ανάλογα με τον αν περιλαμβάνουν δραστηριότητες οι οποίες εκπονούνται
απογευματινές ώρες (στο διάστημα 16:00-20:00)*/
Begin
return query
select distinct c.course_code,'OXI'
from 
public."Course" c
inner join
public."learningactivity" la
on la.activity_course_code=c.course_code
where(c.course_code not in(select distinct c.course_code
							from 
							public."Course" c
							inner join
							public."learningactivity" la
							on la.activity_course_code=c.course_code
							where c.obligatory = true and (la.start_time>=4 and la.start_time<8 and la.end_time<=8 )))
union
select distinct c.course_code,'NAI'
from 
public."Course" c
inner join
public."learningactivity" la
on la.activity_course_code=c.course_code
where c.obligatory = true and (la.start_time>=4 and la.start_time<8 and la.end_time<=8 );
end;
$BODY$;

ALTER FUNCTION public.afternoonlessons_4_5()
    OWNER TO postgres;
