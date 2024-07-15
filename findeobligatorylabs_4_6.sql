-- FUNCTION: public.findeobligatorylabs_4_6()

-- DROP FUNCTION IF EXISTS public.findeobligatorylabs_4_6();

CREATE OR REPLACE FUNCTION public.findeobligatorylabs_4_6(
	)
    RETURNS TABLE(course_code character, obligatory boolean, semesterrushin integer, room_type typeofroom) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
/*Ανάκτηση όλων των υποχρεωτικών μαθημάτων (κωδικός και τίτλος) που προβλέπονται να
έχουν εργαστηριακό μέρος αλλά στο τρέχον εξάμηνο δεν χρησιμοποιούν αίθουσες τύπου
“lab_room”.*/

begin

return query

select a.course_code,a.obligatory,b.semesterrunsin,a.room_type
from
(select*
 from
(select *
from
public."learningactivity" l
 inner join
 public."room" r
 on l.activity_room_id=r.room_id
 where r.room_type='lab_room')as la
inner join
public."Course" c
on c.course_code=la.activity_course_code) as a
inner join
(select *
from
public."CourseRun" cr
inner join
public."Semester" s
on cr.semesterrunsin=s.semester_id
where s.semester_status='present') as b
on a.course_code=b.course_code;
end;
$BODY$;

ALTER FUNCTION public.findeobligatorylabs_4_6()
    OWNER TO postgres;
