-- FUNCTION: public.courserun_update_5_3()

-- DROP FUNCTION IF EXISTS public.courserun_update_5_3();

CREATE OR REPLACE FUNCTION public.courserun_update_5_3()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
/*Κατά την εισαγωγή νέου μελλοντικού εξάμηνου (κατάσταση future) 
γίνεται αυτόματα η εισαγωγή εξαμηνιαίων μαθημάτων. Δημιουργείται ένα εξαμηνιαίο
μάθημα (CourseRun) για κάθε μάθημα (Course) το οποίο έχει typical_season ίση με το
academic_season του εν λόγω εξαμήνου. Οι κανόνες βαθμολόγησης (grade_rules), οι
διδάσκοντες καθηγητές και (για εργαστηριακά μαθήματα) το εργαστηριακό προσωπικό
και το εργαστήριο (Lab) αντιγράφονται από το πιο πρόσφατο εξαμηνιαίο μάθημα για το
ίδιο μάθημα (Course).
*/
	BEGIN

INSERT into public."CourseRun"(course_code ,serial_number,exam_min,lab_min,exam_percentage,labuses,semesterrunsin ,amka_prof1,amka_prof2)
select course_code,new.semester_id as serial_number ,exam_min,lab_min,exam_percentage,labuses,new.semester_id as semesterrunsin,amka_prof1,amka_prof2
from public."CourseRun" cr
where (cr.course_code,cr.serial_number) not in
	(select distinct x.course_code,x.serial_number
	from
	(select b.course_code, serial_number,exam_min,lab_min,exam_percentage,labuses, semesterrunsin,amka_prof1,amka_prof2
	from
	public."CourseRun" cr,(select distinct course_code from public."Course" where typical_season=new.academic_season) b
	where cr.course_code=b.course_code
	order by serial_number desc)as x
	inner join
	(select b.course_code, serial_number,exam_min,lab_min,exam_percentage,labuses, semesterrunsin,amka_prof1,amka_prof2
	from
	public."CourseRun" cr,(select distinct course_code from public."Course" where typical_season=new.academic_season) b
	where cr.course_code=b.course_code
	order by serial_number desc)as y
	on x.course_code=y.course_code
	where x.serial_number<y.serial_number
	) and cr.course_code in (select distinct course_code from public."Course" where typical_season=new.academic_season);

	RETURN NEW;
END;
$BODY$;

ALTER FUNCTION public.courserun_update_5_3()
    OWNER TO postgres;
