-- Create User table
CREATE TABLE IF NOT EXISTS User (
    UserID INTEGER AUTO_INCREMENT PRIMARY KEY,
    UserName VARCHAR(45) UNIQUE,
    Age INTEGER,
    Gender TEXT
);

-- Create Workout table
CREATE TABLE IF NOT EXISTS Workout (
    WorkoutID INTEGER AUTO_INCREMENT PRIMARY KEY,
    UserID INTEGER,
    WorkoutType VARCHAR(45),
    Date DATE,
    FOREIGN KEY (UserID) REFERENCES User(UserID)
);

-- Create BodyPart table
CREATE TABLE IF NOT EXISTS BodyPart (
    BodyPartID INTEGER AUTO_INCREMENT PRIMARY KEY,
    BodyPartName VARCHAR(45) UNIQUE
);

-- Create Exercise table
CREATE TABLE IF NOT EXISTS Exercise (
    ExerciseID INTEGER AUTO_INCREMENT PRIMARY KEY,
    ExerciseName VARCHAR(45),
    BodyPartID INTEGER,
    Description VARCHAR(45),
    FOREIGN KEY (BodyPartID) REFERENCES BodyPart(BodyPartID)
);

-- Create WorkoutExercise table
CREATE TABLE IF NOT EXISTS WorkoutExercise (
    WorkoutID INTEGER,
    ExerciseID INTEGER,
    Sets INTEGER,
    Reps INTEGER,
    Weight VARCHAR(50),
    Duration VARCHAR(50),
    PRIMARY KEY (WorkoutID, ExerciseID),
    FOREIGN KEY (WorkoutID) REFERENCES Workout(WorkoutID),
    FOREIGN KEY (ExerciseID) REFERENCES Exercise(ExerciseID)
);

-- INSERT A USER
DELIMITER //

CREATE PROCEDURE InsertUser(
    IN p_UserName TEXT,
    IN p_Age INT,
    IN p_Gender TEXT
)
BEGIN
    -- Insert a new user into the User table
    INSERT INTO User (UserName, Age, Gender)
    VALUES (p_UserName, p_Age, p_Gender);
END //

DELIMITER ;

-- INSERT A WORKOUT
DELIMITER //

CREATE PROCEDURE InsertWorkout(
    IN p_UserName VARCHAR(50),
    IN p_WorkoutType VARCHAR(20),
    IN p_Date DATE
)
BEGIN
    DECLARE v_UserID INT;

    -- Get the UserID for the specified user name
    SELECT UserID INTO v_UserID
    FROM User
    WHERE UserName = p_UserName
    LIMIT 1;

    -- If UserID is not found, raise an exception
    IF v_UserID IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User not found';
    ELSE
        -- Insert workout directly using the resolved UserID
        INSERT INTO Workout (UserID, WorkoutType, Date)
        VALUES (v_UserID, p_WorkoutType, p_Date);
    END IF;
END //

DELIMITER ;


-- INSERT AN EXERCISE
DELIMITER //

CREATE PROCEDURE InsertExercise(
    IN p_ExerciseName VARCHAR(50),
    IN p_ExerciseType VARCHAR(50),
    IN p_BodyPartName VARCHAR(50)
)
BEGIN
    DECLARE v_BodyPartID INT;

    -- Get the BodyPartID for the specified body part name
    SELECT BodyPartID INTO v_BodyPartID
    FROM BodyPart
    WHERE BodyPartName = p_BodyPartName
    LIMIT 1;

    -- If BodyPartID is not found, raise an exception
    IF v_BodyPartID IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Body part not found';
    ELSE
        -- Insert exercise directly using the resolved BodyPartID
        INSERT INTO Exercise (ExerciseName, Description, BodyPartID)
        VALUES (p_ExerciseName, p_ExerciseType, v_BodyPartID);
    END IF;
    SELECT * FROM workoutdb.exercise;
END //

DELIMITER ;


-- INSERT AN EXERCISE FOR A WORKOUT
DELIMITER //

CREATE PROCEDURE InsertWorkoutExercise(
    IN p_UserName VARCHAR(50),
    IN p_Date DATE,
    IN p_ExerciseName VARCHAR(50),
    IN p_Sets INT,
    IN p_Reps INT,
    IN p_Weight VARCHAR(50),
    IN p_Duration VARCHAR(50)
)
BEGIN
    DECLARE v_UserID INT;
    DECLARE v_ExerciseID INT;
    DECLARE v_WorkoutID INT;

    -- Get the UserID for the specified user name
    SELECT UserID INTO v_UserID
    FROM User
    WHERE UserName = p_UserName
    LIMIT 1;

    -- If UserID is not found, raise an exception
    IF v_UserID IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User not found';
    ELSE
        -- Get the ExerciseID for the specified exercise name
        SELECT ExerciseID INTO v_ExerciseID
        FROM Exercise
        WHERE ExerciseName = p_ExerciseName
        LIMIT 1;

        -- If ExerciseID is not found, raise an exception
        IF v_ExerciseID IS NULL THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Exercise not found';
        ELSE
            -- Get the WorkoutID for the specified user, date, and exercise
            SELECT WorkoutID INTO v_WorkoutID
            FROM Workout
            WHERE UserID = v_UserID AND Date = p_Date
            LIMIT 1;

            -- If WorkoutID is not found, raise an exception
            IF v_WorkoutID IS NULL THEN
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Workout not found';
            ELSE
                -- Insert workout exercise directly using the resolved UserID, ExerciseID, and WorkoutID
                INSERT INTO WorkoutExercise (WorkoutID, ExerciseID, Sets, Reps, Weight, Duration)
                VALUES (v_WorkoutID, v_ExerciseID, p_Sets, p_Reps, p_Weight, p_Duration);
            END IF;
        END IF;
    END IF;
    CALL ReviewPastWorkoutsByDate(p_UserName, p_Date);
END //

DELIMITER ;





-- REVIEW PAST WORKOUTS BY DATE
DELIMITER //

CREATE PROCEDURE ReviewWorkoutsByDate(
    IN p_UserName VARCHAR(50),
    IN p_Date DATE
)
BEGIN
    -- Get the UserID for the specified user name
    DECLARE v_UserID INT;
    SELECT UserID INTO v_UserID FROM User WHERE UserName = p_UserName LIMIT 1;

    -- If UserID is not found, raise an exception
    IF v_UserID IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User not found';
    ELSE
        -- Retrieve past workouts based on UserID and Date
        SELECT w.Date, w.WorkoutType, e.ExerciseName, we.Sets, we.Reps, we.Weight, we.Duration
        FROM Workout w
        JOIN WorkoutExercise we ON w.WorkoutID = we.WorkoutID
        JOIN Exercise e ON we.ExerciseID = e.ExerciseID
        WHERE w.UserID = v_UserID AND w.Date = p_Date;
    END IF;
END //

DELIMITER ;


-- REVIEW WORKOUT BY BODY PART NAME
DELIMITER //

CREATE PROCEDURE ReviewWorkoutsByBodyPartName(
    IN p_UserName VARCHAR(50),
    IN p_BodyPartName VARCHAR(50)
)
BEGIN
    -- Get the UserID for the specified user name
    DECLARE v_UserID INT;
    SELECT UserID INTO v_UserID FROM User WHERE UserName = p_UserName LIMIT 1;

    -- If UserID is not found, raise an exception
    IF v_UserID IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User not found';
    ELSE
        -- Retrieve past workouts based on UserID and BodyPartName
        SELECT w.Date, w.WorkoutType, e.ExerciseName, we.Sets, we.Reps, we.Weight, we.Duration
        FROM Workout w
        JOIN WorkoutExercise we ON w.WorkoutID = we.WorkoutID
        JOIN Exercise e ON we.ExerciseID = e.ExerciseID
        JOIN BodyPart bp ON e.BodyPartID = bp.BodyPartID
        WHERE w.UserID = v_UserID AND bp.BodyPartName = p_BodyPartName;
    END IF;
END //

-- REVIEW WORKOUT BY EXERCISE NAME
DELIMITER //

CREATE PROCEDURE ReviewWorkoutsByExerciseName(
    IN p_UserName VARCHAR(50),
    IN p_ExerciseName VARCHAR(50)
)
BEGIN
    -- Get the UserID for the specified user name
    DECLARE v_UserID INT;
    SELECT UserID INTO v_UserID FROM User WHERE UserName = p_UserName LIMIT 1;

    -- If UserID is not found, raise an exception
    IF v_UserID IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User not found';
    ELSE
        -- Retrieve past workouts based on UserID and ExerciseName
        SELECT w.Date, w.WorkoutType, e.ExerciseName, we.Sets, we.Reps, we.Weight, we.Duration
        FROM Workout w
        JOIN WorkoutExercise we ON w.WorkoutID = we.WorkoutID
        JOIN Exercise e ON we.ExerciseID = e.ExerciseID
        WHERE w.UserID = v_UserID AND e.ExerciseName = p_ExerciseName;
    END IF;
END //

DELIMITER ;

DELIMITER ;


-- ----------- DELETE USER
DELIMITER //

CREATE PROCEDURE DeleteUser(
    IN p_UserName VARCHAR(50)
)
BEGIN
    -- Get the UserID for the specified user name
    DECLARE v_UserID INT;
    SELECT UserID INTO v_UserID FROM User WHERE UserName = p_UserName LIMIT 1;

    -- If UserID is not found, raise an exception
    IF v_UserID IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User not found';
    ELSE
        -- Delete user and associated data using the WHERE clause with a key column
        DELETE FROM WorkoutExercise
        WHERE WorkoutID IN (SELECT WorkoutID FROM Workout WHERE UserID = v_UserID);

        DELETE FROM Workout WHERE UserID = v_UserID;

        DELETE FROM User WHERE UserID = v_UserID;
    END IF;
END //

DELIMITER ;




-- ---------- MODIFY USER
DELIMITER //

CREATE PROCEDURE ModifyUser(
    IN p_UserName VARCHAR(50),
    IN p_NewName VARCHAR(50),
    IN p_NewAge INT,
    IN p_NewGender VARCHAR(10)
    
)
BEGIN
    -- Modify user details using the WHERE clause with a key column
    UPDATE User
    SET
        UserName = p_NewName,
        Age = p_NewAge,
        Gender = p_NewGender
    WHERE UserName = p_UserName;
    
END //

DELIMITER ;

-- ------------ DELETE EXERCISE
DELIMITER //

CREATE PROCEDURE DeleteExercise(
    IN p_ExerciseName VARCHAR(50)
)
BEGIN
    -- Get the ExerciseID for the specified exercise name
    DECLARE v_ExerciseID INT;
    SELECT ExerciseID INTO v_ExerciseID FROM Exercise WHERE ExerciseName = p_ExerciseName LIMIT 1;

    -- If ExerciseID is not found, raise an exception
    IF v_ExerciseID IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Exercise not found';
    ELSE
        -- Delete exercise using the WHERE clause with a key column
        DELETE FROM Exercise WHERE ExerciseID = v_ExerciseID;
    END IF;
    SELECT * FROM workoutdb.exercise;
END //

DELIMITER ;

-- ------------ MODIFY EXERCISE
DELIMITER //

CREATE PROCEDURE ModifyExercise(
    IN p_ExerciseName VARCHAR(50),
    IN p_NewExerciseName VARCHAR(50),
    IN p_NewExerciseDescription VARCHAR(50),
    IN p_NewBodyPartName VARCHAR(50)
)
BEGIN
    -- Get the ExerciseID for the specified exercise name
    DECLARE v_ExerciseID INT;
    SELECT ExerciseID INTO v_ExerciseID FROM Exercise WHERE ExerciseName = p_ExerciseName LIMIT 1;

    -- If ExerciseID is not found, raise an exception
    IF v_ExerciseID IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Exercise not found';
    ELSE
        -- Modify exercise details using the WHERE clause with a key column
        UPDATE Exercise
        SET
            ExerciseName = p_NewExerciseName,
            Description = p_NewExerciseDescription,
            BodyPartID = (SELECT BodyPartID FROM BodyPart WHERE BodyPartName = p_NewBodyPartName LIMIT 1)
        WHERE ExerciseID = v_ExerciseID;
    END IF;
    SELECT * FROM workoutdb.exercise;
END //

DELIMITER ;


-- -------------- DELETE WORKOUT
DELIMITER //

CREATE PROCEDURE DeleteWorkout(
    IN p_UserName VARCHAR(50),
    IN p_Date DATE
)
BEGIN
    -- Get the UserID for the specified user name
    DECLARE v_UserID INT;
    DECLARE v_WorkoutID INT;

    SELECT UserID INTO v_UserID FROM User WHERE UserName = p_UserName LIMIT 1;

    IF v_UserID IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User not found';
    ELSE
        SELECT WorkoutID INTO v_WorkoutID FROM Workout WHERE UserID = v_UserID AND Date = p_Date LIMIT 1;

        IF v_WorkoutID IS NULL THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Workout not found';
        ELSE
            -- Delete workout using the WHERE clause with key columns
            DELETE FROM Workout WHERE WorkoutID = v_WorkoutID;
        END IF;
    END IF;
END //

DELIMITER ;





-- ----------- MODIFY WORKOUT
DELIMITER //

CREATE PROCEDURE ModifyWorkout(
    IN p_UserName VARCHAR(50),
    IN p_Date DATE,
    IN p_NewWorkoutType VARCHAR(20)
)
BEGIN
    -- Get the UserID for the specified user name
    DECLARE v_UserID INT;
    DECLARE v_WorkoutID INT;

    SELECT UserID INTO v_UserID FROM User WHERE UserName = p_UserName LIMIT 1;

    IF v_UserID IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User not found';
    ELSE
        SELECT WorkoutID INTO v_WorkoutID FROM Workout WHERE UserID = v_UserID AND Date = p_Date LIMIT 1;

        IF v_WorkoutID IS NULL THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Workout not found';
        ELSE
            -- Modify workout details using the WHERE clause with key columns
            UPDATE Workout
            SET WorkoutType = p_NewWorkoutType
            WHERE WorkoutID = v_WorkoutID;
        END IF;
    END IF;
    CALL ReviewPastWorkoutsByDate(p_UserName, p_Date);
END //

DELIMITER ;





-- ------------ DELETE WORKOUTEXERCISE
DELIMITER //

CREATE PROCEDURE DeleteWorkoutExercise(
    IN p_UserName VARCHAR(50),
    IN p_Date DATE,
    IN p_ExerciseName VARCHAR(50)
)
BEGIN
    -- Get the UserID, ExerciseID, and WorkoutID for the specified user, date, and exercise
    DECLARE v_UserID INT;
    DECLARE v_ExerciseID INT;
    DECLARE v_WorkoutID INT;

    SELECT UserID INTO v_UserID FROM User WHERE UserName = p_UserName LIMIT 1;
    SELECT ExerciseID INTO v_ExerciseID FROM Exercise WHERE ExerciseName = p_ExerciseName LIMIT 1;

    IF v_UserID IS NULL OR v_ExerciseID IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User or Exercise not found';
    ELSE
        SELECT WorkoutID INTO v_WorkoutID FROM Workout WHERE UserID = v_UserID AND Date = p_Date LIMIT 1;

        IF v_WorkoutID IS NULL THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Workout not found';
        ELSE
            -- Delete workout exercise using the WHERE clause with key columns
            DELETE FROM WorkoutExercise
            WHERE WorkoutID = v_WorkoutID AND ExerciseID = v_ExerciseID;
        END IF;
    END IF;
END //

DELIMITER ;

-- ----------- MODIFY WORKOUTEXERCISE
DELIMITER //

CREATE PROCEDURE ModifyWorkoutExercise(
    IN p_UserName VARCHAR(50),
    IN p_Date DATE,
    IN p_ExerciseName VARCHAR(50),
    IN p_NewSets INT,
    IN p_NewReps INT,
    IN p_NewWeight VARCHAR(50),
    IN p_NewDuration VARCHAR(50)
)
BEGIN
    -- Get the UserID, ExerciseID, and WorkoutID for the specified user, date, and exercise
    DECLARE v_UserID INT;
    DECLARE v_ExerciseID INT;
    DECLARE v_WorkoutID INT;

    SELECT UserID INTO v_UserID FROM User WHERE UserName = p_UserName LIMIT 1;
    SELECT ExerciseID INTO v_ExerciseID FROM Exercise WHERE ExerciseName = p_ExerciseName LIMIT 1;

    IF v_UserID IS NULL OR v_ExerciseID IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User or Exercise not found';
    ELSE
        SELECT WorkoutID INTO v_WorkoutID FROM Workout WHERE UserID = v_UserID AND Date = p_Date LIMIT 1;

        IF v_WorkoutID IS NULL THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Workout not found';
        ELSE
            -- Modify workout exercise details using the WHERE clause with key columns
            UPDATE WorkoutExercise
            SET
                Sets = p_NewSets,
                Reps = p_NewReps,
                Weight = p_NewWeight,
                Duration = p_NewDuration
            WHERE WorkoutID = v_WorkoutID AND ExerciseID = v_ExerciseID;
        END IF;
    END IF;
    CALL ReviewPastWorkoutsByDate(p_UserName, p_Date);
END //

DELIMITER ;



