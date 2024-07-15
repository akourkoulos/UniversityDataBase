-- FUNCTION: public.computerroomstudents_4_4()

-- DROP FUNCTION IF EXISTS public.computerroomstudents_4_4();

CREATE OR REPLACE FUNCTION public.computerroomstudents_4_4(
	)
    RETURNS TABLE(amka integer, entry_date date, course_code character, room_type typeofroom, semester_status semester_status_type) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
/*Ανάκτηση αριθμού μητρώου και έτους εγγραφής των φοιτητών οι οποίοι είναι
εγγεγραμμένοι στο τρέχον εξάμηνο σε κάποιο μάθημα που περιλαμβάνει δραστηριότητα που
εκτελείται σε αίθουσα με τύπο computer_room (δηλαδή μαθήματα που έχουν ασκήσεις σε
υπολογιστές)*/
Begin
return query
select st.amka,st.entry_date,st.course_code,roo.room_type,st.semester_status
from
(select x.amka,x.entry_date,y.course_code,y.serial_number,y.semester_status
from
	(select r.amka,s.entry_date,r.serial_number,r.course_code
	from
	public."Register" r
	inner join 
	public."Student" s
	on r.amka=s.amka)as x
	inner join
		(select * 
		from 
		public."CourseRun" c
		inner join 
		public."Semester" s
		on c.semesterrunsin=s.semester_id
		where s.semester_status='present'
		order by c.course_code)as y
		on x.serial_number=y.serial_number and x.course_code=y.course_code)as st
		
inner join		
		
(select r.room_id,r.room_type,la.activity_serial_number,la.activity_course_code
from 
public."learningactivity" la
inner join
public."room" r
on r.room_id=la.activity_room_id
where r.room_type='computer_room')as roo
on roo.activity_course_code=st.course_code;
end;
$BODY$;

ALTER FUNCTION public.computerroomstudents_4_4()
    OWNER TO postgres;
