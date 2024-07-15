-- FUNCTION: public.labstafftimeactivities_4_7()

-- DROP FUNCTION IF EXISTS public.labstafftimeactivities_4_7();

CREATE OR REPLACE FUNCTION public.labstafftimeactivities_4_7(
	)
    RETURNS TABLE(amka integer, name character, surname character, timeofactivities integer) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
/*Εύρεση του φόρτου όλου του εργαστηριακού προσωπικού το τρέχον εξάμηνο. Ο φόρτος
υπολογίζεται ως το άθροισμα των ωρών συμμετοχής σε δραστηριότητες που υποστηρίζει
κάθε μέλος του εργαστηριακού προσωπικού. Το αποτέλεσμα είναι ένας πίνακας με στήλες:
(ΑΜΚΑ, επώνυμο, όνομα, άθροισμα ωρών). Κάθε πλειάδα αυτού του πίνακα αντιστοιχεί σε
ένα μέλος εργαστηριακού προσωπικού. Στο αποτέλεσμα πρέπει εμφανίζονται όλα τα μέλη
εργαστηριακού προσωπικού, ακόμη και αν έχουν μηδενικό φόρτο.*/

Begin
return query

select pe.amka,pe.name,pe.surname,pa.end_time-pa.start_time
from 
public."Person" pe
inner join
public."Participates" pa 
on pe.amka=pa.amka
where pe.persontype='labstaff' 
union
select ls.amka,ls.name,ls.surname,0
from
public."LabStaff" ls
where ls.amka not in
(select pe.amka
from 
public."Person" pe
inner join
public."Participates" pa 
on pe.amka=pa.amka
where pe.persontype='labstaff');
end;
$BODY$;

ALTER FUNCTION public.labstafftimeactivities_4_7()
    OWNER TO postgres;
