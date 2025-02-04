-- SQL Code
-- Simple String
SELECT 'Hello World' Text;

-- What happens when a string is added to a table
SELECT *, 'SQL IS FUN' AS FACT
FROM Staff;

-- CROSS JOIN tables
SELECT *
FROM Staff
CROSS JOIN Staff_Roles
ORDER BY Role;

-- This is the Same as a CROSS JOIN (Cartesian)
SELECT *
FROM Staff
INNER JOIN Staff_Roles
ON 1=1
ORDER BY Role;

-- CROSS JOIN Animals and Adoptions
SELECT *
FROM Animals A
CROSS JOIN Adoptions AD;

-- ONly Showing Animals Adopted
SELECT AD.*, A.Implant_Chip_ID, A.Breed
FROM Animals A
INNER JOIN Adoptions AD
ON AD.Name = A.Name
AND AD.Species = A.Species;

-- Showing Animals that haven't been adopted as well - ISSUE
SELECT AD.*, A.Implant_Chip_ID, A.Breed
FROM Animals A
LEFT JOIN Adoptions AD
ON AD.Name = A.Name
AND AD.Species = A.Species;

-- Showing Animals that haven't been adopted as well - FIXED above issue
SELECT AD.Adopter_Email, AD.Adoption_Date, A.Name, A.Implant_Chip_ID, A.Breed
FROM Animals A
LEFT JOIN Adoptions AD
ON AD.Name = A.Name
AND AD.Species = A.Species;

-- Joining Multiple Source Data Sets - Only Shows Adopted Animals
SELECT *
FROM Animals A
INNER JOIN Adoptions AD
ON AD.Name = A.Name AND AD.Species = A.Species
INNER JOIN Persons P
ON P.Email = AD.Adopter_Email;

/*
    Joining Multiple Source Data Sets - Only Shows Adopted Animals
    The Left Join gets cut off because the following inner join cuts rows
    Same result as above
*/
SELECT *
FROM Animals A
LEFT JOIN Adoptions AD
ON AD.Name = A.Name AND AD.Species = A.Species
INNER JOIN Persons P
ON P.Email = AD.Adopter_Email;

/* 
    Joining Multiple Source Data Sets - Shows All Animals
    By moving the ON Clause for the Left join to the end
    it now shows the unadopted animals too (Chiastic Order)
*/
SELECT *
FROM Animals A
LEFT JOIN 
    (Adoptions AD
        INNER JOIN 
            Persons P
            ON P.Email = AD.Adopter_Email
    )
ON AD.Name = A.Name AND AD.Species = A.Species;


/*  
    Challenge - Animal vaccination report

    Write a query to report animals and their vaccinations.
    Include animals that have not been vaccinated.
    The report should show the animal's name, species, breed, and primary color, 
    vaccination time and the vaccine name, the staff members first name, last name, and role.
    Use the minimal number of tables required.
    Use the correct logical join types and force join order as needed.
*/
SELECT 
    A.Name,
    A.Species,
    A.Breed,
    A.Primary_Color,
    V.Vaccination_Time,
    V.Vaccine,
    P.First_Name,
    P.Last_Name,
    SA.Role
FROM
    Animals A
LEFT JOIN
    (Vaccinations V
        INNER JOIN Staff_Assignments SA
        ON V.Email = SA.Email
        INNER JOIN Persons P
        ON P.Email = V.Email)
ON A.Name = V.Name AND A.Species = V.Species
ORDER BY 
    A.Name,
    A.Species,
    A.Breed, V.Vaccination_Time;


-- Using Ternary logic to filter getting all Null Values as well
SELECT *
FROM Animals
WHERE Species = 'Dog'
AND Breed IS DISTINCT FROM 'Bullmastiff';

-- Grouping whole table
SELECT COUNT(*) AS COUNT
FROM Adoptions;

-- Grouping by species
SELECT Species, COUNT(*) AS COUNT, GROUP_CONCAT(Name) Names
FROM Animals
GROUP BY Species;

/* 
    INFO About Grouping Functions

    After the data set is grouped, we can only
    reference the grouping expressions since they
    are guaranteed to have the same value for all
    rows within a group.

    All other expressions must be enclosed in an
    aggregate function to guarantee the same.
*/

-- Grouping animals by name and species, Counting vaccinations
SELECT 
    Name,
    Species,
    GROUP_CONCAT(Vaccine) AS Vaccines,
    COUNT(*) AS Num_Vaccinations_Received
FROM Vaccinations
GROUP BY Name, Species;

/*
    Challenge - Animal vaccinations report

    Write a query to report the number of vaccinations each animal
    has received. Include animals that were never vaccinated.
    Exclude rabbits, rabies vaccines, and animals that were last 
    vaccinated on or after October first, 2019.
    The report should show the animals, name, species, primary 
    color breed, and the number of vaccinations.
    Use the correct logical join types and force order if needed.
    Use the correct logical group by expressions.
*/
SELECT
    A.Name,
    A.Species,
    MAX(A.Primary_Color) Primary_Color, -- Dummy aggregate
    MAX(A.Breed) Breed, -- Dummy aggregate
    GROUP_CONCAT(V.Vaccine) Vaccine,
    COUNT(V.Vaccine) Num_Of_Vaccinations
FROM Animals A 
LEFT JOIN Vaccinations V
ON A.Name = V.Name AND A.Species = V.Species
WHERE A.Species <> 'Rabbit'
AND (V.vaccine <> 'Rabies' OR V.Vaccine IS NULL)
GROUP BY
    A.Name,
    A.Species
HAVING MAX(V.Vaccination_Time) < '20191001' OR MAX(V.Vaccination_Time) IS NULL
ORDER BY A.Species, A.Name;


