-- View: public.roomslessonprogram_6_2

-- DROP VIEW public.roomslessonprogram_6_2;

CREATE OR REPLACE VIEW public.roomslessonprogram_6_2
 AS
 SELECT activity_room_id,
    weekday,
    start_time,
    end_time,
    amka,
    activity_course_code
   FROM "Participates"
  WHERE role = 'responsible'::roletype
  ORDER BY activity_room_id, weekday, start_time;

ALTER TABLE public.roomslessonprogram_6_2
    OWNER TO postgres;

