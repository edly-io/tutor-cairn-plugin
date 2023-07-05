-- enable live views
set allow_experimental_live_view = 1;

CREATE LIVE VIEW user_courses_completed_count WITH PERIODIC REFRESH 30 AS 
SELECT 
  A.user_id, 
  COUNT (C.course_id) filter(
    where 
      total_course_progress = '100 %'
  ) AS courses_completed 
FROM 
  openedx_user_info_detail AS A 
  JOIN user_courses_progress AS C ON A.user_id = C.user_id 
GROUP BY 
  A.user_id;

-- Grant everyone access to the view
CREATE ROW POLICY common ON user_courses_completed_count FOR SELECT USING 1 TO ALL;
