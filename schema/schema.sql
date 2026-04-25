CREATE DATABASE IF NOT EXISTS food_reviews;
USE food_reviews;



CREATE TABLE User (
    userID       INT PRIMARY KEY AUTO_INCREMENT,
    username     VARCHAR(255) NOT NULL UNIQUE,
    email        VARCHAR(255) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL
);

CREATE TABLE FoodSpot (
    spotID  INT PRIMARY KEY AUTO_INCREMENT,
    name    VARCHAR(255) NOT NULL,
    address VARCHAR(255) NOT NULL,
    picture VARCHAR(255)  -- stores filename; NULL allowed
);



CREATE TABLE Review (
    reviewID   INT PRIMARY KEY AUTO_INCREMENT,
    rating     INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment    VARCHAR(1000),
    reviewDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    userID     INT NOT NULL,
    spotID     INT NOT NULL,
    FOREIGN KEY (userID) REFERENCES User(userID) ON DELETE CASCADE,
    FOREIGN KEY (spotID) REFERENCES FoodSpot(spotID) ON DELETE CASCADE
);

DELIMITER //

CREATE PROCEDURE addReview (rating INT, comment VARCHAR(1000),  userID INT,  spotID INT) BEGIN
INSERT INTO Review (rating, comment, userID, spotID) VALUES(rating, comment, userID, spotID);
END //

DELIMITER ;

CREATE VIEW RestaurantLeaderboard AS               
SELECT AVG(rating) AS avg_rating, FoodSpot.spotID, name, address, picture
FROM FoodSpot
JOIN Review
ON FoodSpot.spotID = Review.spotID
GROUP BY FoodSpot.spotID, name, address, picture;


CREATE VIEW userSummary AS               
SELECT  
    AVG(rating ) AS avgRatingGiven, 
    COUNT(spotID) AS  totalReviews, username, User.userID
FROM Review
JOIN User
ON User.userID = Review.userID
GROUP BY User.userID, username;


-- Sample data
INSERT INTO User (username, email, PasswordHash) VALUES
    ('kevin_a',  'kevin@example.com',  'hash1'),
    ('nolwen_b', 'nolwen@example.com', 'hash2'),
    ('bryan_b',  'bryan@example.com',  'hash3');

INSERT INTO FoodSpot (name, address, picture) VALUES
    ('La Teresita',       '3248 W Columbus Dr, Tampa, FL',     NULL),
    ('Ulele',             '1810 N Highland Ave, Tampa, FL',    NULL),
    ('Taco Bus',          '913 E Hillsborough Ave, Tampa, FL', NULL),
    ('Burger Monger',     '4306 W Boy Scout Blvd, Tampa, FL',  NULL),
    ('Oxford Exchange',   '420 W Kennedy Blvd, Tampa, FL',     NULL);

INSERT INTO Review (rating, comment, reviewDate, userID, spotID) VALUES
    (5, 'Best Cuban food in Tampa!',        '2026-03-15 12:00:00', 1, 1),
    (4, 'Great ambiance, solid food.',      '2026-03-20 18:30:00', 2, 2),
    (5, 'Tacos are amazing, very cheap.',   '2026-03-22 13:00:00', 3, 3),
    (3, 'Decent burgers, nothing special.', '2026-04-01 11:00:00', 1, 4),
    (4, 'Lovely brunch spot.',              '2026-04-05 09:30:00', 2, 5),
    (5, 'Came back three times in a week.', '2026-04-07 20:00:00', 3, 1);

