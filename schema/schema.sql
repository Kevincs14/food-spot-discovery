CREATE DATABASE IF NOT EXISTS food_reviews;
USE food_reviews;



CREATE TABLE User (
    userID       INT PRIMARY KEY AUTO_INCREMENT,
    username     VARCHAR(255) NOT NULL UNIQUE,
    email        VARCHAR(255) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    is_admin     TINYINT(1)   NOT NULL DEFAULT 0
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
INSERT INTO User (username, email, PasswordHash, is_admin) VALUES
    ('admin',     'admin@localhost',      'password', 1);

INSERT INTO User (username, email, PasswordHash) VALUES
    ('kevin_a',   'kevin@example.com',   'hash1'),
    ('nolwen_b',  'nolwen@example.com',  'hash2'),
    ('bryan_b',   'bryan@example.com',   'hash3'),
    ('sara_c',    'sara@example.com',    'hash4'),
    ('marcus_d',  'marcus@example.com',  'hash5');

INSERT INTO FoodSpot (name, address, picture) VALUES
    ('La Teresita',          '3248 W Columbus Dr, Tampa, FL',          NULL),
    ('Ulele',                '1810 N Highland Ave, Tampa, FL',         NULL),
    ('Taco Bus',             '913 E Hillsborough Ave, Tampa, FL',      NULL),
    ('Burger Monger',        '4306 W Boy Scout Blvd, Tampa, FL',       NULL),
    ('Oxford Exchange',      '420 W Kennedy Blvd, Tampa, FL',          NULL),
    ('Bern''s Steak House',  '1208 S Howard Ave, Tampa, FL',           NULL),
    ('The Refinery',         '442 W Kennedy Blvd, Tampa, FL',          NULL),
    ('Rooster & the Till',   '1812 N 15th St, Tampa, FL',              NULL),
    ('Ichicoro Ramen',       '5229 N Florida Ave, Tampa, FL',          NULL),
    ('Datz',                 '2616 S MacDill Ave, Tampa, FL',          NULL);

INSERT INTO Review (rating, comment, reviewDate, userID, spotID) VALUES
    -- La Teresita (spotID 1)
    (5, 'Best Cuban food in Tampa!',              '2026-03-15 12:00:00', 1, 1),
    (5, 'Came back three times in a week.',       '2026-04-07 20:00:00', 3, 1),
    (4, 'Authentic Cuban, great prices.',         '2026-04-10 13:30:00', 4, 1),
    (5, 'Cuban sandwich is unbeatable.',          '2026-04-18 12:15:00', 5, 1),
    -- Ulele (spotID 2)
    (4, 'Great ambiance, solid food.',            '2026-03-20 18:30:00', 2, 2),
    (5, 'Gorgeous river views, loved the ribs.',  '2026-04-02 19:00:00', 4, 2),
    (3, 'A bit pricey but tasty.',                '2026-04-12 18:00:00', 1, 2),
    -- Taco Bus (spotID 3)
    (5, 'Tacos are amazing, very cheap.',         '2026-03-22 13:00:00', 3, 3),
    (5, 'Open late, best street tacos around.',   '2026-04-08 23:00:00', 2, 3),
    (4, 'Consistent and delicious every time.',   '2026-04-15 14:00:00', 5, 3),
    (4, 'Love the al pastor tacos.',              '2026-04-20 13:00:00', 1, 3),
    -- Burger Monger (spotID 4)
    (3, 'Decent burgers, nothing special.',       '2026-04-01 11:00:00', 1, 4),
    (4, 'Good smash burgers, fast service.',      '2026-04-11 12:30:00', 3, 4),
    (2, 'Overpriced for what you get.',           '2026-04-22 11:45:00', 5, 4),
    -- Oxford Exchange (spotID 5)
    (4, 'Lovely brunch spot.',                    '2026-04-05 09:30:00', 2, 5),
    (5, 'Beautiful space, great coffee.',         '2026-04-09 10:00:00', 4, 5),
    (4, 'Perfect for a weekend morning.',         '2026-04-17 09:00:00', 1, 5),
    -- Bern's Steak House (spotID 6)
    (5, 'Best steak I have ever had.',            '2026-03-28 20:00:00', 2, 6),
    (5, 'Legendary wine selection.',              '2026-04-03 21:00:00', 5, 6),
    (4, 'Expensive but worth it for special occasions.', '2026-04-14 19:30:00', 1, 6),
    -- The Refinery (spotID 7)
    (4, 'Farm-to-table done right.',              '2026-04-06 19:00:00', 3, 7),
    (5, 'Menu changes weekly, always exciting.',  '2026-04-16 19:30:00', 2, 7),
    (4, 'Cozy atmosphere and creative dishes.',   '2026-04-21 20:00:00', 4, 7),
    -- Rooster & the Till (spotID 8)
    (5, 'Hidden gem, absolutely loved it.',       '2026-04-04 19:00:00', 1, 8),
    (4, 'Small menu but every dish is excellent.',  '2026-04-13 18:30:00', 3, 8),
    (5, 'Best cocktails in Tampa alongside great food.', '2026-04-19 21:00:00', 5, 8),
    -- Ichicoro Ramen (spotID 9)
    (5, 'Rich broth, perfect noodles.',           '2026-04-07 19:00:00', 4, 9),
    (5, 'Best ramen in the city, no contest.',    '2026-04-15 20:00:00', 2, 9),
    (4, 'Long wait but absolutely worth it.',     '2026-04-23 19:30:00', 3, 9),
    -- Datz (spotID 10)
    (4, 'Fun comfort food spot.',                 '2026-04-08 12:00:00', 5, 10),
    (5, 'Mac and cheese is legendary.',           '2026-04-16 13:00:00', 1, 10),
    (4, 'Great burger options and big portions.', '2026-04-24 12:30:00', 2, 10);

