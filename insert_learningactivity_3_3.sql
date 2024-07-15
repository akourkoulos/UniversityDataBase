-- FUNCTION: public.insert_learningactivity_3_3(character)

-- DROP FUNCTION IF EXISTS public.insert_learningactivity_3_3(character);

CREATE OR REPLACE FUNCTION public.insert_learningactivity_3_3(
	course_codein character)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
/*Αυτόματη εισαγωγή δραστηριοτήτων για συγκεκριμένο μάθημα εξαμήνου σύμφωνα με
το πρόγραμμα σπουδών. Η διαδικασία αναζητά τις διαθέσιμες αίθουσες για διαλέξεις,
φροντιστήρια και εργαστήρια και δημιουργεί τις κατάλληλες δραστηριότητες μάθησης.
Για απλοποίηση θεωρειται ότι όλοι οι φοιτητές που θα παρακολουθήσουν το μάθημα
αποτελούν ένα ενιαίο τμήμα τόσο για τα φροντιστήρια και εργαστήρια όσο και για τις
διαλέξεις του μαθήματος. Επίσης θεωρειται ότι κάθε τύπος δραστηριότητας εκτελείται σε
συνεχόμενες ώρες στην ίδια αίθουσα. Για παράδειγμα για το μάθημα «ΠΛΗ 302» θα
δεσμευτούν 3 συνεχόμενες ώρες μιας αίθουσας διαλέξεων για την θεωρία, 2 συνεχόμενες
ώρες μιας αίθουσας διαλέξεων για το φροντιστήριο και 1 ώρα αίθουσας υπολογιστών για το
εργαστήριο.*/
begin

if (select course_code from public."CourseRun" where (serial_number=(select semester_id from public."Semester" where semester_status='present') and course_code=course_codeIN) ) is null then
return false;
else
	if (select lecture_hours =2 from public."Course" c where c.course_code=course_codeIN) Then
		insert into public."learningactivity" (activity_type,start_time,end_time,weekday,activity_course_code,activity_room_id,activity_serial_number)
		select 'lecture'as activity_type,a.start_time,b.end_time,a.weekday,course_codeIN as activity_course_code ,a.room_id as activity_room_id,(select semester_id from public."Semester" where semester_status='present') as serial_number
		from
			(select* from finde_Free_hours('lecture_room'))as a,(select* from finde_Free_hours('lecture_room'))as b
		where a.end_time=b.start_time and a.weekday=b.weekday and a.room_id=b.room_id
		limit 1;

	elseif (select lecture_hours =3 from public."Course" c where c.course_code=course_codeIN) Then
		insert into public."learningactivity" (activity_type,start_time,end_time,weekday,activity_course_code,activity_room_id,activity_serial_number)
		select 'lecture'as activity_type,x.start_time,c.end_time,c.weekday,course_codeIN as activity_course_code ,c.room_id as activity_room_id,(select semester_id from public."Semester" where semester_status='present') as serial_number
		from
		(select a.start_time,b.end_time,a.weekday,a.room_id
		from
			(select* from finde_Free_hours('lecture_room')) as a,(select* from finde_Free_hours('lecture_room'))as b
		where a.end_time=b.start_time and a.weekday=b.weekday and a.room_id=b.room_id
		)as x,(select* from finde_Free_hours('lecture_room')) as c
		where x.end_time=c.start_time and x.weekday=c.weekday and x.room_id=c.room_id
		limit 1;

	elseif (select lecture_hours =4 from public."Course" c where c.course_code=course_codeIN) Then
		insert into public."learningactivity" (activity_type,start_time,end_time,weekday,activity_course_code,activity_room_id,activity_serial_number)
		select 'lecture'as activity_type,y.start_time,z.end_time,z.weekday,course_codeIN as activity_course_code ,z.room_id as activity_room_id,(select semester_id from public."Semester" where semester_status='present') as serial_number
		from
			(select x.start_time,c.end_time,c.weekday,c.room_id
			from
			(select a.start_time,b.end_time,a.weekday,a.room_id
			from
				(select* from finde_Free_hours('lecture_room')) as a,(select* from finde_Free_hours('lecture_room'))as b
			where a.end_time=b.start_time and a.weekday=b.weekday and a.room_id=b.room_id
			)as x,(select* from finde_Free_hours('lecture_room')) as c
			where x.end_time=c.start_time and x.weekday=c.weekday and x.room_id=c.room_id)as y,
			(select* from finde_Free_hours('lecture_room')) as z
		where y.end_time=z.start_time and y.weekday=z.weekday and y.room_id=z.room_id
		limit 1;
	else
		return false;
	end if;

	if(select les='ΠΛΗ' from Left(course_codeIN,3) as les) then

		if (select lab_hours =1 from public."Course" c where c.course_code=course_codeIN) Then
			insert into public."learningactivity" (activity_type,start_time,end_time,weekday,activity_course_code,activity_room_id,activity_serial_number)
			select 'computer_lab'as activity_type,a.start_time,a.end_time,a.weekday,course_codeIN as activity_course_code ,a.room_id as activity_room_id,(select semester_id from public."Semester" where semester_status='present') as serial_number
			from
				(select* from finde_Free_hours('computer_room')) as a
			limit 1;
		elseif (select lab_hours =2 from public."Course" c where c.course_code=course_codeIN) Then
			insert into public."learningactivity" (activity_type,start_time,end_time,weekday,activity_course_code,activity_room_id,activity_serial_number)
			select 'computer_lab'as activity_type,a.start_time,b.end_time,a.weekday,course_codeIN as activity_course_code ,a.room_id as activity_room_id,(select semester_id from public."Semester" where semester_status='present') as serial_number
			from
				(select* from finde_Free_hours('computer_room')) as a,(select* from finde_Free_hours('computer_room'))as b
			where a.end_time=b.start_time and a.weekday=b.weekday and a.room_id=b.room_id
			limit 1;

		elseif (select lab_hours =3 from public."Course" c where c.course_code=course_codeIN) Then
			insert into public."learningactivity" (activity_type,start_time,end_time,weekday,activity_course_code,activity_room_id,activity_serial_number)
			select 'computer_lab'as activity_type,x.start_time,c.end_time,c.weekday,course_codeIN as activity_course_code ,c.room_id as activity_room_id,(select semester_id from public."Semester" where semester_status='present') as serial_number
			from
			(select a.start_time,b.end_time,a.weekday,a.room_id
			from
				(select* from finde_Free_hours('computer_room')) as a,(select* from finde_Free_hours('computer_room'))as b
			where a.end_time=b.start_time and a.weekday=b.weekday and a.room_id=b.room_id
			)as x,(select* from finde_Free_hours('computer_room')) as c
			where x.end_time=c.start_time and x.weekday=c.weekday and x.room_id=c.room_id
			limit 1;
		end if;

	else

		if (select lab_hours =1 from public."Course" c where c.course_code=course_codeIN) Then
			insert into public."learningactivity" (activity_type,start_time,end_time,weekday,activity_course_code,activity_room_id,activity_serial_number)
			select 'lab'as activity_type,a.start_time,a.end_time,a.weekday,course_codeIN as activity_course_code ,a.room_id as activity_room_id,(select semester_id from public."Semester" where semester_status='present') as serial_number
			from
				(select* from finde_Free_hours('lab_room')) as a
			limit 1;
		elseif (select lab_hours =2 from public."Course" c where c.course_code=course_codeIN) Then
			insert into public."learningactivity" (activity_type,start_time,end_time,weekday,activity_course_code,activity_room_id,activity_serial_number)
			select 'lab'as activity_type,a.start_time,b.end_time,a.weekday,course_codeIN as activity_course_code ,a.room_id as activity_room_id,(select semester_id from public."Semester" where semester_status='present') as serial_number
			from
				(select* from finde_Free_hours('lab_room')) as a,(select* from finde_Free_hours('lab_room'))as b
			where a.end_time=b.start_time and a.weekday=b.weekday and a.room_id=b.room_id
			limit 1;

		elseif (select lab_hours =3 from public."Course" c where c.course_code=course_codeIN) Then
			insert into public."learningactivity" (activity_type,start_time,end_time,weekday,activity_course_code,activity_room_id,activity_serial_number)
			select 'lab'as activity_type,x.start_time,c.end_time,c.weekday,course_codeIN as activity_course_code ,c.room_id as activity_room_id,(select semester_id from public."Semester" where semester_status='present') as serial_number
			from
			(select a.start_time,b.end_time,a.weekday,a.room_id
			from
				(select* from finde_Free_hours('lab_room')) as a,(select* from finde_Free_hours('lab_room'))as b
			where a.end_time=b.start_time and a.weekday=b.weekday and a.room_id=b.room_id
			)as x,(select* from finde_Free_hours('lab_room')) as c
			where x.end_time=c.start_time and x.weekday=c.weekday and x.room_id=c.room_id
			limit 1;
		end if;
	end if;

	if (select tutorial_hours =1 from public."Course" c where c.course_code=course_codeIN) Then
		insert into public."learningactivity" (activity_type,start_time,end_time,weekday,activity_course_code,activity_room_id,activity_serial_number)
		select 'tutorial'as activity_type,a.start_time,a.end_time,a.weekday,course_codeIN as activity_course_code ,a.room_id as activity_room_id,(select semester_id from public."Semester" where semester_status='present') as serial_number
		from
			(select* from finde_Free_hours('lecture_room')) as a
		limit 1;
	elseif (select tutorial_hours =2 from public."Course" c where c.course_code=course_codeIN) Then
		insert into public."learningactivity" (activity_type,start_time,end_time,weekday,activity_course_code,activity_room_id,activity_serial_number)
		select 'tutorial'as activity_type,a.start_time,b.end_time,a.weekday,course_codeIN as activity_course_code ,a.room_id as activity_room_id,(select semester_id from public."Semester" where semester_status='present') as serial_number
		from
			(select* from finde_Free_hours('lecture_room')) as a,(select* from finde_Free_hours('lecture_room'))as b
		where a.end_time=b.start_time and a.weekday=b.weekday and a.room_id=b.room_id
		limit 1;

	elseif (select tutorial_hours =3 from public."Course" c where c.course_code=course_codeIN) Then
		insert into public."learningactivity" (activity_type,start_time,end_time,weekday,activity_course_code,activity_room_id,activity_serial_number)
		select 'tutorial'as activity_type,x.start_time,c.end_time,c.weekday,course_codeIN as activity_course_code ,c.room_id as activity_room_id,(select semester_id from public."Semester" where semester_status='present') as serial_number
		from
		(select a.start_time,b.end_time,a.weekday,a.room_id
		from
			(select* from finde_Free_hours('lecture_room')) as a,(select* from finde_Free_hours('lecture_room'))as b
		where a.end_time=b.start_time and a.weekday=b.weekday and a.room_id=b.room_id
		)as x,(select* from finde_Free_hours('lecture_room')) as c
		where x.end_time=c.start_time and x.weekday=c.weekday and x.room_id=c.room_id
		limit 1;
	end if;

	return true;
end if;
end;
$BODY$;

ALTER FUNCTION public.insert_learningactivity_3_3(character)
    OWNER TO postgres;
