-- FUNCTION: public.findegrades4_3(integer, character)

-- DROP FUNCTION IF EXISTS public.findegrades4_3(integer, character);

CREATE OR REPLACE FUNCTION public.findegrades4_3(
	whatsemester integer,
	typeofgrade character)
    RETURNS TABLE(course_code character, gradetype numeric, semester_id integer) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
/*Ανάκτηση της μέγιστης βαθμολογίας για κάθε μάθημα ενός συγκεκριμένου εξαμήνου του
προγράμματος σπουδών. Δίνεται σαν είσοδος το εξάμηνο καθώς και η επιθυμητή
κατηγορία βαθμολογίας, δηλαδή γραπτής εξέτασης, βαθμός εργαστηρίου ή τελική
βαθμολογία. Τα αποτελέσματα εμφανίζονται με φθίνουσα σειρά βαθμολογίας.*/
Begin

if(typeofgrade='exam_grade') then

return query
select x.course_code,y.exam_grade,x.semester_id
from
public."Register" y
inner join
	(select*
	from
	public."CourseRun" cr
	inner join
	public."Semester" se
	on cr.semesterrunsin=se.semester_id
	 where se.semester_id = whatsemester
	order by  se.semester_id)as x
on y.course_code=x.course_code and x.serial_number=y.serial_number
order by  y.exam_grade Desc;

elseif(typeofgrade='lab_grade') then
return query
select x.course_code,y.lab_grade,x.semester_id
from
public."Register" y
inner join
	(select*
	from
	public."CourseRun" cr
	inner join
	public."Semester" se
	on cr.semesterrunsin=se.semester_id
	 where se.semester_id = whatsemester
	order by  se.semester_id)as x
on y.course_code=x.course_code and x.serial_number=y.serial_number
order by  y.lab_grade Desc;

else
return query

select x.course_code,y.final_grade,x.semester_id
from
public."Register" y
inner join
	(select*
	from
	public."CourseRun" cr
	inner join
	public."Semester" se
	on cr.semesterrunsin=se.semester_id
	 where se.semester_id = whatsemester
	order by  se.semester_id)as x
on y.course_code=x.course_code and x.serial_number=y.serial_number
order by  y.final_grade Desc;

end if;
end;
$BODY$;

ALTER FUNCTION public.findegrades4_3(integer, character)
    OWNER TO postgres;
