-- FUNCTION: public.create_student_3_1(date, integer)

-- DROP FUNCTION IF EXISTS public.create_student_3_1(date, integer);

CREATE OR REPLACE FUNCTION public.create_student_3_1(
	regdate date,
	num integer)
    RETURNS TABLE(name character, father_name character, surname character, am character, entry_date date) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
/*Στην βάση υπάρχουν 2 πίνακες Name, Surname που περιέχουν ελληνικά
ονόματα και επίθετα. Με βάση τα δεδομένα σε αυτούς τους πίνακες
δημιουργειται η συναρτήση για φοιτητές η οποία επιτρέπει την εισαγωγή προσωπικών δεδομένων
προσώπων με βάση τυχαίες επιλογές ονομάτων και επωνύμων. Οι συναρτήση 
δέχεται ως παράμετρο το πλήθος εγγραφών που θα δημιουργηθούν. Επιπλέον  την
υπάρχει μια παράμετρος για την ημερομηνία εγγραφής στο τμήμα.
Ο αριθμός μητρώου των φοιτητών είναι της μορφής ΕΕΕΕΑΑΑΑΑΑ όπου ΕΕΕΕ, το έτος
της ημερομηνίας εγγραφής και ΑΑΑΑΑΑ ένας μοναδικός (ανά έτος) αύξων αριθμός*/

Begin
insert into public."Student"(name,father_name,surname,am,entry_date)
select m.name,f.name,adapt_surname(m.surname,m.sex),create_am(cast(to_char((regdate),'YYYY')as int),cast(nextval('"student_am"'::regclass)as int)),regdate k
from(
random_fnames(num) f
inner join
(select n.name,sn.surname,n.sex,n.id
from
random_names(num) n
natural join
random_surnames(num) sn) m  
on m.id=f.id);

RETURN QUERY
select m.name,f.name,adapt_surname(m.surname,m.sex),create_am(cast(to_char((regdate),'YYYY')as int),cast(nextval('"student_am"'::regclass)as int)),regdate
from(
random_fnames(num) f
inner join
(select n.name,sn.surname,n.sex,n.id
from
random_names(num) n
natural join
random_surnames(num) sn) m  
on m.id=f.id);
end;
$BODY$;

ALTER FUNCTION public.create_student_3_1(date, integer)
    OWNER TO postgres;
