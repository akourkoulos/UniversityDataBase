-- FUNCTION: public.activity_check_5_2()

-- DROP FUNCTION IF EXISTS public.activity_check_5_2();

CREATE OR REPLACE FUNCTION public.activity_check_5_2()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
/*Κατά την εισαγωγή και ενημέρωση δραστηριοτήτων ελέγχονται τα
παρακάτω:
1 Οι τιμές στα πεδία weekday, start_time, end_time θα πρέπει να είναι έγκυρες.
2 Η αίθουσα όπου λαμβάνει χώρα η δραστηριότητα που εισάγεται ή ενημερώνεται
θα πρέπει να είναι ελεύθερη την συγκεκριμένη ημέρα της εβδομάδας και για τις
ώρες διεξαγωγής της δραστηριότητας.*/

DECLARE x integer;
BEGIN

	IF (TG_OP = 'UPDATE' or TG_OP= 'INSERT') THEN
		   IF (NEW.weekday='monday'or NEW.weekday='tusday' or NEW.weekday='wednesday' or NEW.weekday='thursday' or NEW.weekday='friday') THEN
				
				select ro.room_id into x
				from
					public."learningactivity" la
					inner join
					public."room" ro
				
				on la.activity_room_id=ro.room_id
				where(new.weekday=weekday and new.activity_room_id=ro.room_id and ((end_time >new.start_time and start_time <= new.start_time  )or(start_time < new.end_time and end_time >= new.end_time)or(start_time >= new.start_time and end_time <= new.end_time) )); 
				
				if(x is null and new.start_time>=8 and new.start_time<=24 and new.end_time>=8 and new.end_time<=24 and new.start_time<new.end_time) then
				RETURN NEW;
				else 
				return NULL;
				end if;
		   ELSE
			RETURN NULL;
		   END IF;
	end if;

END;
$BODY$;

ALTER FUNCTION public.activity_check_5_2()
    OWNER TO postgres;
