CREATE DATABASE IF NOT EXISTS food_reviews;
USE food_reviews;

CREATE TABLE  User(
    userID INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL
    
);


CREATE TABLE  FoodSpot(
    spotID INT PRIMARY KEY AUTO_INCREMENT,
    picture VARCHAR(255), /* stores the file name dont want to store iamges in database isntead speerate folder to then grab when needed isntead */
    address VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL
);


CREATE TABLE  Review(
    reviewID INT PRIMARY KEY AUTO_INCREMENT,
    rating INT NOT NULL, 
    comment VARCHAR(1000), 
    reviewDate DATETIME,
    userID INT,
    spotID INT,
    FOREIGN KEY (spotID) REFERENCES FoodSpot(spotID),
    FOREIGN KEY (userID) REFERENCES User(userID)


);
