-- FUNCTION: public.set_grades_3_2(integer)

-- DROP FUNCTION IF EXISTS public.set_grades_3_2(integer);

CREATE OR REPLACE FUNCTION public.set_grades_3_2(
	serialnumber integer)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
/*Εισαγωγή βαθμολογίας για εγγεγραμμένους φοιτητές σε μαθήματα συγκεκριμένου εξαμήνου
το οποίο δίνεται ως παράμετρος. Εισάγεται ένας τυχαίος ακέραιος αριθμός από το 1 έως
και το 10 ως βαθμός γραπτής εξέτασης. Αν υπάρχουν ήδη βαθμολογίες για κάποιους
φοιτητές, δεν γίνεται ενημέρωση για αυτές. Για την βαθμολογία εργαστηρίου εισάγεται ο
βαθμός του πιο πρόσφατου εξαμήνου (που είχε εγγραφεί ο φοιτητής) εφόσον υπάρχει και
είναι μεγαλύτερος ή ίσος του 5. Διαφορετικά εισάγεται ένας τυχαίος ακέραιος αριθμός
από το 1 έως και το 10.*/

Begin

UPDATE public."Register"
SET lab_grade=CEIL(RANDOM()*10)::integer
WHERE ((serial_number=serialnumber)and(exam_grade < 11)and(lab_grade<5)and register_status='approved');

UPDATE public."Register"
SET exam_grade = CEIL(RANDOM()*10)::integer, lab_grade=CEIL(RANDOM()*10)::integer
WHERE ((serial_number=serialnumber )and(exam_grade is null)and(lab_grade<5)and register_status='approved') ;
					

UPDATE public."Register"
SET exam_grade = CEIL(RANDOM()*10)::integer, lab_grade=CEIL(RANDOM()*10)::integer
WHERE ((serial_number=serialnumber )and(exam_grade is null)and(lab_grade is null)and register_status='approved') ;
					
UPDATE public."Register"
SET exam_grade=CEIL(RANDOM()*10)::integer
WHERE((serial_number=serialnumber )and(exam_grade is null)and(lab_grade>5)and register_status='approved') ;

end;
$BODY$;

ALTER FUNCTION public.set_grades_3_2(integer)
    OWNER TO postgres;
