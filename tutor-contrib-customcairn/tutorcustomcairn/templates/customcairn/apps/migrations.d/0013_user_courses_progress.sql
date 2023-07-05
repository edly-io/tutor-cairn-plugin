-- enable live views
set allow_experimental_live_view = 1;

CREATE LIVE VIEW user_courses_progress WITH PERIODIC REFRESH 30 AS 
SELECT 
  _openedx_block_completion.user_id AS user_id, 
  _openedx_block_completion.course_key AS course_id, 
  courses_units.course_title AS course_title, 
  courses_units.total_units AS total_units, 
  COUNT (
    DISTINCT (
      _openedx_block_completion.block_key
    )
  ) filter (
    WHERE 
      _openedx_block_completion.completion = 1
  ) As total_completed_units, 
  COUNT (
    DISTINCT (
      _openedx_block_completion.block_key
    )
  ) filter (
    WHERE 
      _openedx_block_completion.completion = 1 
      AND course_blocks.graded = '1'
  ) As total_graded_completed_units, 
  CONCAT(
    CAST(
      ROUND(
        (
          total_graded_completed_units / total_units
        ), 
        1
      ) * 100 AS VARCHAR
    ), 
    ' %'
  ) AS graded_course_progress, 
  CONCAT(
    CAST(
      ROUND(
        (
          total_completed_units / total_units
        ), 
        1
      ) * 100 AS VARCHAR
    ), 
    ' %'
  ) AS total_course_progress 
FROM 
  course_blocks 
  JOIN _openedx_block_completion ON course_blocks.course_id = _openedx_block_completion.course_key 
  JOIN courses_units ON course_blocks.course_id = courses_units.course_id 
WHERE 
  ROUND (
    (
      LENGTH(course_blocks.full_name) - LENGTH(
        REPLACE (course_blocks.full_name, '>', '')
      )
    ) / LENGTH('>')
  ) = 4 
GROUP BY 
  user_id, 
  course_id, 
  course_title, 
  total_units;

-- Grant everyone access to the view
CREATE ROW POLICY common ON user_courses_progress FOR SELECT USING 1 TO ALL;
