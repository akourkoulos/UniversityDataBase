-- FUNCTION: public.findofficehours_4_2()

-- DROP FUNCTION IF EXISTS public.findofficehours_4_2();

CREATE OR REPLACE FUNCTION public.findofficehours_4_2(
	)
    RETURNS TABLE(course_title character, start_time integer, end_time integer, name character, surname character, weekday character, activity_room_id integer) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
/*Εμφάνιση πληροφορίας για τους καθηγητές και τις ώρες γραφείου των μαθημάτων που
διδάσκουν το τρέχον εξάμηνο. Ως αποτέλεσμα εμφανίζεται το ονοματεπώνυμο του
καθηγητή, ο τίτλος του μαθήματος και αντίστοιχες μέρες και ώρες των ωρών γραφείου. Τα
αποτελέσματα εμφανίζονται ταξινομημένα αλφαβητικά ως προς το ονοματεπώνυμο του
καθηγητή.*/
Begin

RETURN QUERY
select y.course_title,x.start_time,x.end_time,x.name,x.surname,x.weekday,x.activity_room_id
from(public."Course" y
	inner join
	(select distinct b.activity_course_code,b.start_time,b.end_time,a.name,a.surname,a.weekday,a.activity_room_id
	from(
		public."learningactivity" b
		inner join
		(select *
		from
		public."Person"
		inner join
		public."Participates" 
		 on public."Person".amka=public."Participates".amka
		where(role='responsible'))as a on (a.activity_course_code=b.activity_course_code and a.activity_room_id=b.activity_room_id and a.start_time=b.start_time and a.end_time=b.end_time))
		where(b.activity_type='office_hours')
		order by a.name )as x on x.activity_course_code=y.course_code);

end;
$BODY$;

ALTER FUNCTION public.findofficehours_4_2()
    OWNER TO postgres;
