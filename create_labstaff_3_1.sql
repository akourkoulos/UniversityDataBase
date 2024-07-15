-- FUNCTION: public.create_labstaff_3_1(integer)

-- DROP FUNCTION IF EXISTS public.create_labstaff_3_1(integer);

CREATE OR REPLACE FUNCTION public.create_labstaff_3_1(
	num integer)
    RETURNS TABLE(level level_type, name character, father_name character, surname character, labjoins integer) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
/*Στην βάση υπάρχουν 2 πίνακες Name, Surname που περιέχουν ελληνικά
ονόματα και επίθετα. Με βάση τα δεδομένα σε αυτούς τους πίνακες
η συναρτήση γιαεργαστηριακό προσωπικό επιτρέπει την εισαγωγή προσωπικών δεδομένων
προσώπων με βάση τυχαίες επιλογές ονομάτων και επωνύμων. Οι συναρτήση αυτη 
δέχεται ως παράμετρο το πλήθος εγγραφών που θα δημιουργηθούν. Η
βαθμίδα των μελών εργαστηριακού προσωπικού επιλέγεται τυχαία
από το αντίστοιχο σύνολο δυνατών τιμών. Το εργαστήριο στο οποίο εντάσσονται 
επιλέγεται επίσης τυχαία από το σύνολο των καταγεγραμμένων στη βάση
εργαστηρίων*/

Begin

insert into public."LabStaff"(level, name,father_name,  surname, labworks)
select m.level,m.name,f.name,adapt_surname(m.surname,m.sex), CEIL(RANDOM()*10)::integer as labworks
from(
random_fnames(num) f
inner join
(select r.level,n.name,sn.surname,n.sex,r.id 
from
random_names(num) n
natural join
random_level(num) r
natural join
random_surnames(num) sn) m  
on m.id=f.id);

RETURN QUERY
select m.level,m.name,f.name,adapt_surname(m.surname,m.sex),CEIL(RANDOM()*10)::integer as labworks
from(
random_fnames(num) f
inner join
(select r.level,n.name,sn.surname,n.sex,r.id 
from
random_names(num) n
natural join
random_level(num) r
natural join
random_surnames(num) sn) m  
on m.id=f.id);

end;
$BODY$;

ALTER FUNCTION public.create_labstaff_3_1(integer)
    OWNER TO postgres;
