-- FUNCTION: public.participates_update_5_1()

-- DROP FUNCTION IF EXISTS public.participates_update_5_1();

CREATE OR REPLACE FUNCTION public.participates_update_5_1()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
/*Κατά την εισαγωγή και ενημέρωση δεδομένων συμμετοχής προσώπων σε
δραστηριότητες  ελέγχονται τα παρακάτω:
1 Να μην υπάρχει συμμετοχή του προσώπου σε άλλη δραστηριότητα την ίδια μέρα
και ώρα.
2 Αν το πρόσωπο είναι φοιτητής με συμμετοχή σε δραστηριότητα εργαστηρίου
(computer_lab, lab) πρέπει το άθροισμα των εργαστηριακών ωρών να μην
υπερβαίνει τις ώρες εργαστηρίου του συγκεκριμένου μαθήματος όπως ορίζονται
από τον οδηγό σπουδών.*/

DECLARE isfound boolean = false;
DECLARE x char(15);
declare sumOfPerHours integer=0;
declare Chours integer=0;

BEGIN
   
	 
	if (TG_OP = 'INSERT'or TG_OP = 'UPDATE') THEN
		select activity_type into x
		from
		public."Participates" p
		inner join
		public."learningactivity" la
		on la.end_time=p.end_time and la.start_time=p.start_time and la.weekday=p.weekday and p.activity_serial_number=la.activity_serial_number and p.activity_room_id=la.activity_room_id
		where(amka=new.amka);
	
		if((x='lab' or x='computer_lab')) then
		
			select sum(p.end_time - p.start_time) into sumOfPerHours
			from public."Participates" p
			where (p.amka=new.amka and p.activity_course_code=new.activity_course_code);
			
			select lab_hours into Chours
			from public."Course"
			where course_code=new.activity_course_code;
			

			if(sumOfPerHours<Chours or sumOfPerHours is NULL) then
			
				select count(*)>=1 into isfound
				from public."Participates" 
				where ((amka=new.amka and weekday=new.weekday and activity_serial_number=new.activity_serial_number)and((end_time >new.start_time and start_time <= new.start_time  )or(start_time < new.end_time and end_time >= new.end_time)or(start_time >= new.start_time and end_time <= new.end_time) ));

			   IF(isfound =true) THEN
				RETURN null;
			   ELSE
				RETURN NEW;
			   END IF;
			
			else
			return null;
			end if;
			
	
		else
			select count(*)>=1 into isfound
			from public."Participates" 
			where ((amka=new.amka and weekday=new.weekday and activity_serial_number=new.activity_serial_number)and((end_time >new.start_time and start_time <= new.start_time  )or(start_time < new.end_time and end_time >= new.end_time)or(start_time >= new.start_time and end_time <= new.end_time) ));

		   IF(isfound =true) THEN
			RETURN null;
		   ELSE
			RETURN NEW;
		   END IF;
		   end if;
		   
	END IF;
END;
$BODY$;

ALTER FUNCTION public.participates_update_5_1()
    OWNER TO postgres;
