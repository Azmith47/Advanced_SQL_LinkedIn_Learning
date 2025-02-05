-- SQL Code
/*
    Show adoption rows including fees.
    MAX fee ever paid.
    Discount from MAX in percent.
*/
SELECT MAX(Adoption_Fee) Max_Fee
FROM Adoptions;

SELECT 
    *,
    (SELECT MAX(Adoption_Fee) FROM Adoptions) Max_Fee,
    CONCAT((((SELECT MAX(Adoption_Fee) FROM Adoptions)
    - Adoption_Fee) * 100)
    / (SELECT MAX(Adoption_Fee) FROM Adoptions), '%')Discount_Percent
FROM Adoptions;

-- MAX fee per species instead of overall
SELECT 
    *,
    (SELECT MAX(Adoption_Fee) FROM Adoptions A2 WHERE A2.Species = A1.Species) Max_Fee,
    CONCAT((((SELECT MAX(Adoption_Fee) FROM Adoptions A2 WHERE A2.Species = A1.Species)
    - Adoption_Fee) * 100)
    / (SELECT MAX(Adoption_Fee) FROM Adoptions A2 WHERE A2.Species = A1.Species), '%')Discount_Percent
FROM Adoptions A1;

-- Show people who adopted at least one animal. Show all Attributes
SELECT DISTINCT P.*
FROM Persons P
INNER JOIN Adoptions A
ON P.Email = A.Adopter_Email;

-- Same as above
SELECT *
FROM Persons
WHERE Email IN (SELECT Adopter_Email FROM Adoptions);

-- Same as above
SELECT *
FROM Persons P
WHERE EXISTS (
                SELECT NULL
                FROM Adoptions A
                WHERE A.Adopter_Email = P.Email
                );

-- Find Animals that were not adpoted
SELECT DISTINCT AN.Name, AN.Species
FROM Animals AN
LEFT JOIN Adoptions AD
ON AN.Name = AD.Name AND AN.Species = AD.Species
WHERE AD.Name IS NULL;

-- Same as above using EXISTS
SELECT AN.Name, AN.Species
FROM Animals AN
WHERE NOT EXISTS (
                    SELECT NULL
                    FROM Adoptions AD
                    WHERE AD.Name = AN.Name
                    AND AD.Species = AN.Species
                );

-- Same as above using EXCEPT Set Operator
SELECT Name, Species
FROM Animals
EXCEPT
SELECT Name, Species
FROM Adoptions;


/*
    Challenge

    Show which breeds were never adopted.
    NULL breeds need to be considered carefully.
    The answer is that only Turkish Angora cats were never adopted.
*/
SELECT DISTINCT Species , Breed
FROM Animals
EXCEPT
SELECT AN.Species, AN.Breed
FROM Animals AN
INNER JOIN Adoptions AD
ON AN.Species = AD.Species
AND AN.Name = AD.Name;

-- Show adopters who adopted 2 animals in 1 day.
SELECT  A1.Adopter_Email, A1.Adoption_Date,
        A1.Name Name1, A1.Species Species1,
        A2.Name Name2, A2.Species Species2
FROM Adoptions A1
JOIN Adoptions A2
ON A1.Adopter_Email = A2.Adopter_Email
AND A1.Adoption_Date = A2.Adoption_Date
AND ( 
        (A1.Name = A2.Name AND A1.Species > A2.Species)
        OR
        (A1.Name > A2.Name AND A1.Species = A2.Species)
        OR
        (A1.Name > A2.Name AND A1.Species <> A2.Species)
    )
ORDER BY A1.Adopter_Email, A1.Adoption_Date;


-- Show All animals and their most recent vaccination.
SELECT 
        A.Name,
        A.Species,
        A.Primary_Color,
        A.Breed,
        Last_Vaccinations.*
FROM    Animals A
            CROSS JOIN LATERAL
            (   SELECT  V.Vaccine, V.Vaccination_Time
                FROM    Vaccinations V
                WHERE   V.Name = A.Name
                        AND
                        V.Species = A.Species
                ORDER BY V.Vaccination_Time DESC
                LIMIT 3 OFFSET 0
            ) Last_Vaccinations;

/*
    Challenge

    Our shelter has been experiencing financial difficulties.
    !!! PLEASE consider donating to your local animal shelter !!!
    The board of directors decided to explore additional revenue sources and came up with an idea.
    Instead of spaying and neutering all animals, the shelter should consider responsible breeding of purebred animals.
    !!!	This is a hypothetical question – ALWAYS spay and neuter your pets !!! 

    Your challenge is to figure out which animals are breeding candidates.
*/

SELECT 
        A1.Species,
        A1.Breed AS Breed,
        A1.Name AS Male,
        A2.Name AS Female
FROM Animals A1
INNER JOIN Animals A2
        ON  A1.Species = A2.Species
            AND
            A1.Breed = A2.Breed
            AND
            A1.Name > A2.Name
            AND A1.Gender > A2.Gender
ORDER BY A1.Species, A1.Breed;

-- Rank Animals based on number of vaccinations received
WITH Vaccination_Ranking AS
        (
            SELECT 
                    Name,
                    Species,
                    COUNT(*) AS Num_V
            FROM    Vaccinations
            GROUP BY Name, Species
        )
SELECT  Species, 
        MAX(Num_V) MAX_V, 
        MIN(Num_V) MIN_V,
        ROUND(AVG(Num_V), 2) AS AVG_V
FROM Vaccination_Ranking
GROUP BY Species;

-- GROUPING SETS Example
SELECT  YEAR(Adoption_Date) AS Year, 
        Adopter_Email,
        COUNT(*) AS Monthly_Adoptions
FROM Adoptions
GROUP BY GROUPING SETS (
                            YEAR(Adoption_Date),
                            Adopter_Email
                        );


SELECT  COALESE(Species, 'All') AS Species, 
        CASE
            WHEN GROUPING(Breed) = 1
            THEN 'All'
            ELSE Breed 
        END AS Breed,
        GROUPING(Breed) AS Is_This_All_Breeds,
        COUNT(*) AS Number_of_Animals
FROM Animals
GROUP BY GROUPING SETS (
                            Species,
                            Breed,
                            ()
                        )
ORDER BY Species, Breed;


/*
    Challenge

    Count the number of vaccinations per:
    Year            Staff member
    Species         Staff member and species
    Species and year
    Latest vaccination year for each group
*/
SELECT          
        COALESCE(CAST(YEAR(V.Vaccination_Time) AS VARCHAR(10)), 'All Years') Year,
        COALESCE(V.Species, 'All Species') Species,
        COALESCE(V.Email, 'All Staff') Email,
        CASE WHEN GROUPING(V.Email) = 0
            THEN MAX(P.First_Name)
            ELSE ''
            END AS First_Name,
        CASE WHEN GROUPING(V.Email) = 0
            THEN MAX(P.Last_Name)
            ELSE ''
            END AS Last_Name,
        COUNT(*) AS Number_Of_Vaccinations,
        MAX(YEAR(V.Vaccination_Time)) AS Latest_Vaccination_Year
FROM    Vaccinations V
JOIN    Persons P
ON      V.Email = P.Email
GROUP BY GROUPING SETS (
                            (),
                            YEAR(V.Vaccination_Time),
                            V.Species,
                            (YEAR(V.Vaccination_Time), V.Species)
                            V.Email,
                            (V.Email, V.Species)
                        )
ORDER BY 
            Year,
            Species,
            First_Name,
            Last_Name;


-- Recursive with
SELECT CAST(day AS DATE) AS day
FROM generate_series(   '2019-01-01'::date, -- Start::Type
                        '2019-12-31',       -- End
                        '1 Day'             -- Interval
                    ) AS days_of_2019(day)
ORDER BY day ASC;

WITH days_of_2019(day) AS
    (   SELECT CAST('20190101' AS DATE)
        UNION ALL
        SELECT CAST(day+INTERVAL '1 DAY' AS DATE)
        FROM days_of_2019
        WHERE day < CAST('20191231' AS DATE)
    )
SELECT *
FROM days_of_2019
ORDER BY day ASC
OPTION(MAXRECURSION 365);