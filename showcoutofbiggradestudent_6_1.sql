-- View: public.showcoutofbiggradestudent_6_1

-- DROP VIEW public.showcoutofbiggradestudent_6_1;

CREATE OR REPLACE VIEW public.showcoutofbiggradestudent_6_1
 AS
 SELECT count(*) AS count,
    course_code,
    serial_number
   FROM "Register"
  WHERE register_status = 'pass'::register_status_type AND lab_grade > 8::numeric
  GROUP BY course_code, serial_number;

ALTER TABLE public.showcoutofbiggradestudent_6_1
    OWNER TO postgres;

