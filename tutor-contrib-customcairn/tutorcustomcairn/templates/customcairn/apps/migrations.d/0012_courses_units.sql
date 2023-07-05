-- enable live views
set allow_experimental_live_view = 1;

CREATE LIVE VIEW courses_units WITH PERIODIC REFRESH 30 AS 
SELECT 
  course_id, 
  SUBSTRING(
    full_name, 
    1, 
    POSITION('>' IN full_name) -1
  ) AS course_title, 
  COUNT (
    DISTINCT (block_key)
  ) AS total_units 
from 
  course_blocks 
WHERE 
  ROUND (
    (
      LENGTH(full_name) - LENGTH(
        REPLACE (full_name, '>', '')
      )
    ) / LENGTH('>')
  ) = 4 
GROUP BY 
  course_id, 
  course_title;

-- Grant everyone access to the view
CREATE ROW POLICY common ON courses_units FOR SELECT USING 1 TO ALL;
