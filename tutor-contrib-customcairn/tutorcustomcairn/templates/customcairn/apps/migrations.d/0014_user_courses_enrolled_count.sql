-- enable live views
set allow_experimental_live_view = 1;

CREATE LIVE VIEW user_courses_enrolled_count WITH PERIODIC REFRESH 30 AS 
SELECT 
  user_id, 
  COUNT (enrollment_created) AS courses_enrolled 
from 
  course_enrollments 
GROUP BY 
  user_id;


-- Grant everyone access to the view
CREATE ROW POLICY common ON user_courses_enrolled_count FOR SELECT USING 1 TO ALL;
