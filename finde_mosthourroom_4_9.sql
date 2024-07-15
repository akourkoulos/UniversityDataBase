-- FUNCTION: public.finde_mosthourroom_4_9()

-- DROP FUNCTION IF EXISTS public.finde_mosthourroom_4_9();

CREATE OR REPLACE FUNCTION public.finde_mosthourroom_4_9(
	)
    RETURNS TABLE(rid integer, stime integer, etime integer, wday character) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
/*Εύρεση της μέγιστης διάρκειας συνεχόμενης λειτουργίας κάθε αίθουσας ανά ημέρα
εβδομάδας. Το αποτέλεσμα εμφανίζει τα εξής πεδία: κωδικός αίθουσας, ημέρα εβδομάδας,
χρόνος έναρξης, χρόνος λήξης. Για παράδειγμα μια πλειάδα της μορφής (‘145Π58’,1,8,13)
σημαίνει ότι η αίθουσα ‘145Π58’ κάθε Δευτέρα είναι δεσμευμένη από τις 8:00 το πρωί μέχρι
τις 13:00 το μεσημέρι. Οι ημέρες της εβδομάδας αντιστοιχούν σε αριθμητικούς κωδικούς ως
εξής: 0 -> Κυριακή, 1-> Δευτέρα .... 6 -> Σάββατο.*/

BEGIN

return query
WITH RECURSIVE Rec(anc,des,wday,rid) AS (
select start_time  as anc,end_time as des,weekday as wday,activity_room_id as rid  from public."learningactivity"
UNION
select r.anc as anc ,d.end_time as des,r.wday,r.rid  as wday
from Rec r,public."learningactivity" d 
where r.des=d.start_time and r.wday=d.weekday and r.rid=d.activity_room_id
)

select re.rid,re.anc as stime,re.des as etime,re.wday	from Rec as re 	where (re.rid,re.anc,re.des,re.wday) not in
	(select a.rid,a.start,a.end,a.wday
	from
		(select re.rid,re.anc as start,re.des as end,re.wday
		from Rec as re 
		order by re.des-re.anc desc)as a ,
		(select re.rid,re.anc as start,re.des as end,re.wday
		from Rec as re 
		order by re.des-re.anc desc)as b
	where a.rid=b.rid and a.end-a.start<b.end-b.start and a.wday=b.wday)
order by rid,wday;
end;
$BODY$;

ALTER FUNCTION public.finde_mosthourroom_4_9()
    OWNER TO postgres;
