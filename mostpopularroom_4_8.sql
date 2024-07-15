-- FUNCTION: public.mostpopularroom_4_8()

-- DROP FUNCTION IF EXISTS public.mostpopularroom_4_8();

CREATE OR REPLACE FUNCTION public.mostpopularroom_4_8(
	)
    RETURNS TABLE(activity_room_id integer, count bigint) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
/*Εύρεση της αίθουσας ή των αιθουσών που φιλοξενούν δραστηριότητες από τα περισσότερα
διαφορετικά μαθήματα.*/
begin
return query
select  public."learningactivity".activity_room_id ,count(distinct activity_course_code)
from public."learningactivity"
group by public."learningactivity".activity_room_id
order by count(distinct activity_course_code) desc limit 1;
end;
$BODY$;

ALTER FUNCTION public.mostpopularroom_4_8()
    OWNER TO postgres;
