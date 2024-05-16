
-- ---------------------------------- ADD NEW USER & WORKOUT INFO ----------------------------------------------------------------------
-- INSERT USER
-- CALL InsertUser('john_doe', 33, 'Male');

-- INSERT WORKOUT
-- CALL InsertWorkout('john_doe','Strength', '2023-12-5');

-- INSERT EXERCISE 
-- CALL InsertExercise('Shoudler Press', 'Upward pressing exercise', 'Shoulders');
-- OR VIEW CURRENT EXERCIES
-- SELECT * FROM workoutdb.exercise;

-- INSERT WORKOUTEXERCISE
-- CALL InsertWorkoutExercise('Alex Jones Sr.', '2023-11-23', 'Shoulder Press', 3, 12, '120 lbs', '30 min');

-- ------------------------------------- REVIEW WORKOUTS ----------------------------------------------------
-- REVIEW BY DATE AND ID
-- CALL ReviewPastWorkoutsByDate('Alex Jones Sr.', '2023-11-23');

-- REVIEW BY BODY PART NAME AND USERNAME
-- ReviewPastWorkoutsByBodyPartName('john_doe', 'Legs');

-- REVIEW BY EXERCISE NAME AND ID
-- Review past workouts by exercise name
-- CALL ReviewPastWorkoutsByExerciseName('john_doe', 'Split Squat');

-- ------------------------------------ DELETE QUERIES -------------------------------------------------------
-- Delete user with UserName = 'john_doe'
-- CALL DeleteUser('john_doe');

-- Delete exercise with ExerciseName = 'Bench Press'
-- CALL DeleteExercise('Deadlift'); 

-- Delete workouts for user with UserName = 'john_doe' on date '2023-11-22'
-- CALL DeleteWorkout('Alex Jones', '2023-11-22');


-- Delete workout exercises for user with UserName = 'john_doe', on date '2023-11-22', and for exercise 'Bench Press'
-- CALL DeleteWorkoutExercise('Alex Jones Sr.', '2023-11-23', 'Bicep Curl');


-- ------------------------------- MODIFY QUERIES ----------------------------------------------------------------------
-- Modify user with UserName = 'john_doe'
-- CALL ModifyUser('Alex Jones', 'Alex Jones Sr.', 55, 'Male');


-- Modify exercise with ExerciseName = 'Bench Press'
-- CALL ModifyExercise('Deadlift', 'Deadlift', 'Hip hinging exercise', 'Legs');


-- Modify workouts for user with UserName = 'john_doe' on date '2023-11-22'
-- CALL ModifyWorkout('Alex Jones Sr.', '2023-11-23', 'Mobility');


-- Modify workout exercises for user with UserName = 'john_doe', on date '2023-11-22', and for exercise 'Bench Press'
-- CALL ModifyWorkoutExercise('Alex Jones Sr.', '2023-11-23', 'Preacher Curl', 3, 125, '30 lbs', '20 min');


