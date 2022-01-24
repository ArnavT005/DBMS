--1--
WITH temp1 AS (
    SELECT driverId AS driverid, forename, surname, nationality, milliseconds AS time
    FROM (
        SELECT driverId, forename, surname, nationality, milliseconds, circuitId
        FROM (
            SELECT DISTINCT drivers.driverId AS driverId, forename, surname, nationality, raceId, milliseconds
            FROM drivers, lapTimes
            WHERE drivers.driverId = lapTimes.driverId
        ) AS R1, races
        WHERE (
            R1.raceId = races.raceId AND
            year = 2017
        )
    ) AS R2, circuits
    WHERE (
        R2.circuitId = circuits.circuitId AND
        country = 'Monaco'
    )
)
SELECT *
FROM temp1
WHERE (
    temp1.time = (
        SELECT MAX(time)
        FROM temp1
    )
)
ORDER BY forename, surname, nationality;
--2--
SELECT name AS constructor_name, R1.constructorId AS constructorid, nationality, points
FROM (
    SELECT constructorId, SUM(points) AS points
    FROM constructorResults, races
    WHERE (
        constructorResults.raceId = races.raceId AND
        year = 2012
    )
    GROUP BY constructorId

) AS R1, constructors
WHERE R1.constructorId = constructors.constructorId
ORDER BY points DESC, constructor_name, nationality, constructorid
LIMIT 5;
--3--
WITH temp1 AS (
    SELECT driverId, SUM(points) AS points
    FROM results, races
    WHERE (
        results.raceId = races.raceId AND
        year > 2000 AND year < 2021
    )
    GROUP BY driverId
)
SELECT temp1.driverId AS driverid, forename, surname, points
FROM temp1, drivers
WHERE (
    temp1.driverId = drivers.driverId AND
    temp1.points = (
        SELECT MAX(points)
        FROM temp1
    )
)
ORDER BY forename, surname, driverid;
--4--
WITH temp1 AS (
    SELECT constructorId, SUM(points) AS points
    FROM constructorResults, races
    WHERE (
        constructorResults.raceId = races.raceId AND
        year > 2009 AND year < 2021
    )
    GROUP BY constructorId
)
SELECT temp1.constructorId AS constructorid, name, nationality, points
FROM temp1, constructors
WHERE (
    temp1.constructorId = constructors.constructorId AND
    temp1.points = (
        SELECT MAX(points)
        FROM temp1
    )
)
ORDER BY name, nationality, constructorid;
--5--
WITH temp1 AS (
    SELECT drivers.driverId AS driverid, COUNT(drivers.driverId) AS race_wins
    FROM drivers, results
    WHERE (
        drivers.driverId = results.driverId AND
        positionOrder = 1
    )
    GROUP BY drivers.driverId
)
SELECT temp1.driverid AS driverid, forename, surname, race_wins
FROM temp1, drivers
WHERE (
    temp1.driverid = drivers.driverid AND
    temp1.race_wins = (
        SELECT MAX(race_wins)
        FROM temp1
    )
)
ORDER BY forename, surname, driverid;
--6--
WITH temp1 AS (
    SELECT constructorId, COUNT(constructorId) AS num_wins
    FROM (
        SELECT raceId, MAX(points) AS points
        FROM constructorResults
        GROUP BY raceId
    ) AS R1, constructorResults
    WHERE (
        R1.raceId = constructorResults.raceId AND
        constructorResults.points = R1.points
    )
    GROUP BY constructorId
)
SELECT temp1.constructorId AS constructorid, name, num_wins
FROM temp1, constructors
WHERE (
    temp1.constructorId = constructors.constructorId AND
    temp1.num_wins = (
        SELECT MAX(num_wins)
        FROM temp1
    )
)
ORDER BY name, constructorid;
--7--
WITH temp1 AS (
    SELECT year, driverId, SUM(points) AS points
    FROM results, races
    WHERE results.raceId = races.raceId
    GROUP BY year, driverId
)
SELECT R2.driverId as driverid, forename, surname, points
FROM (
    SELECT driverId, SUM(points) AS points
    FROM results
    WHERE (
        driverId NOT IN (
            SELECT driverId
            FROM temp1, (
                SELECT year, MAX(points) as points
                FROM temp1
                GROUP BY year
            ) AS R1
            WHERE (
                temp1.year = R1.year AND
                temp1.points = R1.points
            )
            GROUP BY driverId
        )
    )
    GROUP BY driverId
) AS R2, drivers
WHERE R2.driverId = drivers.driverId
ORDER BY points DESC, forename, surname, driverid
LIMIT 3;
--8--
WITH temp1 AS (
    SELECT driverId, COUNT(driverId) AS num_countries
    FROM (
        SELECT DISTINCT driverId, country
        FROM results, (
            SELECT races.raceId AS raceId, country
            FROM races, circuits
            WHERE races.circuitId = circuits.circuitId
        ) AS R1
        WHERE (
            results.raceId = R1.raceId AND
            positionOrder = 1
        )
    ) AS R2
    GROUP BY driverId
)
SELECT temp1.driverId as driverid, forename, surname, num_countries
FROM temp1, drivers
WHERE (
    drivers.driverId = temp1.driverId AND
    num_countries = (
        SELECT MAX(num_countries)
        FROM temp1
    )
)
ORDER BY forename, surname, driverid;
--9--
SELECT R1.driverId AS driverid, forename, surname, num_wins
FROM drivers, (
    SELECT driverId, COUNT(driverId) AS num_wins
    FROM results
    WHERE (
        grid = 1 AND
        positionOrder = 1
    )
    GROUP BY driverId
) AS R1
WHERE R1.driverId = drivers.driverId
ORDER BY num_wins DESC, forename, surname, driverid
LIMIT 3;
--10--
WITH temp1 AS (
    SELECT R1.raceId AS raceid, num_stops, R1.driverId AS driverid, forename, surname, races.circuitId AS circuitid, circuits.name AS name
    FROM races, drivers, circuits, (
        SELECT results.raceId as raceId, results.driverId AS driverId, COUNT(*) AS num_stops
        FROM results, pitStops
        WHERE (
            results.raceId = pitStops.raceId AND
            results.driverId = pitStops.driverId AND
            positionOrder = 1
        )
        GROUP BY results.raceId, results.driverId
    ) AS R1
    WHERE (
        races.raceId = R1.raceId AND
        circuits.circuitId = races.circuitId AND 
        drivers.driverId = R1.driverId
    )
)
SELECT *
FROM temp1
WHERE (
    R2.num_stops = (
        SELECT MAX(num_stops)
        FROM temp1
    )
)
ORDER BY forename, surname, name, circuitid, driverid;
--11--
WITH temp1 AS (
    SELECT R1.raceId as raceid, circuits.name AS name, location, num_collisions
    FROM circuits, races, (
        SELECT raceId, COUNT(raceId) as num_collisions
        FROM results
        WHERE statusId = 4
        GROUP BY raceId
    ) AS R1
    WHERE (
        R1.raceId = races.raceId AND
        races.circuitId = circuits.circuitId
    )
)
SELECT * 
FROM temp1
WHERE (
    temp1.num_collisions = (
        SELECT MAX(num_collisions)
        FROM temp1
    )
)
ORDER BY name, location, raceid;
--12--
WITH temp1 AS (
    SELECT driverId, COUNT(driverId) AS count
    FROM results
    WHERE (
        positionOrder = 1 AND
        rank = 1
    )
    GROUP BY driverId
)
SELECT temp1.driverId AS driverid, forename, surname, count
FROM temp1, drivers
WHERE (
    drivers.driverId = temp1.driverId AND
    temp1.count = (
        SELECT MAX(count)
        FROM temp1
    )
)
ORDER BY forename, surname, driverid;
--13-- to be cleaned
SELECT R11.year AS year, (points_1 - points_2) AS point_diff, constructorId_1, name_1 AS constructor1_name, constructorId_2, name_2 AS constructor2_name
FROM (
    SELECT R1.year AS year, R7.constructorId AS constructorId_2, name AS name_2, R1.points AS points_2
    FROM (
        SELECT R2.year AS year, MAX(R2.points) AS points
        FROM (
            SELECT year, constructorId, SUM(points) AS points
            FROM races, constructorResults
            WHERE races.raceId = constructorResults.raceId
            GROUP BY year, constructorId
        ) AS R2, (
            SELECT R3.year as year, constructorId, R3.points AS points
            FROM (
                SELECT year, constructorId, SUM(points) AS points
                FROM races, constructorResults
                WHERE races.raceId = constructorResults.raceId
                GROUP BY year, constructorId
            ) AS R3, (
                SELECT year, MAX(points) AS points
                FROM (
                    SELECT year, constructorId, SUM(points) AS points
                    FROM races, constructorResults
                    WHERE races.raceId = constructorResults.raceId
                    GROUP BY year, constructorId
                ) AS R4
                GROUP BY year
            ) AS R5
            WHERE (
                R3.year = R5.year AND
                R3.points = R5.points
            )
        ) AS R6
        WHERE (
            R2.year = R6.year AND
            NOT (R2.constructorId = R6.constructorId) 
        )
        GROUP BY R2.year
    ) AS R1, (
        SELECT year, constructorId, SUM(points) AS points
        FROM races, constructorResults
        WHERE races.raceId = constructorResults.raceId
        GROUP BY year, constructorId
    ) AS R7, constructors
    WHERE (
        constructors.constructorId = R7.constructorId AND
        R1.year = R7.year AND
        R1.points = R7.points
    )
) AS R11, (
    SELECT R8.year as year, R8.constructorId AS constructorId_1, name AS name_1, R8.points AS points_1
    FROM (
        SELECT year, constructorId, SUM(points) AS points
        FROM races, constructorResults
        WHERE races.raceId = constructorResults.raceId
        GROUP BY year, constructorId
    ) AS R8, (
        SELECT year, MAX(points) AS points
        FROM (
            SELECT year, constructorId, SUM(points) AS points
            FROM races, constructorResults
            WHERE races.raceId = constructorResults.raceId
            GROUP BY year, constructorId
        ) AS R9
        GROUP BY year
    ) AS R10, constructors
    WHERE (
        R8.constructorId = constructors.constructorId AND
        R8.year = R10.year AND
        R8.points = R10.points
    )
) AS R12
WHERE R11.year = R12.year
ORDER BY point_diff DESC, constructor1_name, constructor2_name, constructorId_1, constructorId_2
LIMIT 1;
--14--
WITH temp1 AS (
    SELECT R1.driverId AS driverid, forename, surname, R1.circuitId AS circuitid, country, pos
    FROM drivers, circuits, (
        SELECT  circuitId, driverId, grid AS pos
        FROM results, races
        WHERE (
            results.raceId = races.raceId AND
            year = 2018 AND
            positionOrder = 1
        )
    ) AS R1
    WHERE (
        drivers.driverId = R1.driverId AND
        circuits.circuitId = R1.circuitId
    )
)
SELECT *
FROM temp1
WHERE (
    temp1.pos = (
        SELECT MAX(pos)
        FROM temp1
    )
)
ORDER BY forename DESC, surname, country, driverid, circuitid;
--15--
WITH temp1 AS (
    SELECT constructorId, COUNT(constructorId) AS num
    FROM races, results
    WHERE (
        races.raceId = results.raceId AND
        year >= 2000 AND
        year <= 2021 AND
        statusId = 5
    )
    GROUP BY constructorId
)
SELECT temp1.constructorId AS constructorid, name, num
FROM temp1, constructors
WHERE (
    constructors.constructorId = temp1.constructorId AND
    temp1.num = (
        SELECT MAX(num)
        FROM temp1
    )
)
ORDER BY name, constructorid;
--16--
SELECT DISTINCT results.driverId AS driverid, forename, surname
FROM results, races, circuits, drivers
WHERE (
    results.raceId = races.raceId AND
    races.circuitId = circuits.circuitId AND
    results.driverId = drivers.driverId AND
    positionOrder = 1 AND
    country = 'USA' AND
    nationality = 'American'
)
ORDER BY forename, surname, driverid
LIMIT 5;
--17--
SELECT R2.constructorId AS constructorid, name, count
FROM constructors, (
    SELECT constructorId, COUNT(*)
    FROM (
        SELECT raceId, constructorId, COUNT(*) AS count
        FROM results
        WHERE positionOrder <= 2
        GROUP BY raceId, constructorId
    ) AS R1
    WHERE count = 2
    GROUP BY constructorId
) AS R2
WHERE (
    R2.constructorId = constructors.constructorId AND
    R2.count = (
        SELECT MAX(count)
        FROM (
            SELECT constructorId, COUNT(*)
            FROM (
                SELECT raceId, constructorId, COUNT(*) AS count
                FROM results
                WHERE positionOrder <= 2
                GROUP BY raceId, constructorId
            ) AS R3
            WHERE count = 2
            GROUP BY constructorId    
        ) AS R4
    )
)
ORDER BY name, constructorid;

SELECT R1.driverId AS driverid, forename, surname, num_laps
FROM drivers, (
    SELECT driverId, COUNT(*) AS num_laps
    FROM lapTimes
    WHERE position = 1
    GROUP BY driverId
) AS R1
WHERE (
    R1.driverId = drivers.driverId AND
    R1.num_laps = (
        SELECT MAX(num_laps)
        FROM (
            SELECT driverId, COUNT(*) AS num_laps
            FROM lapTimes
            WHERE position = 1
            GROUP BY driverId
        ) AS R2
    )
)
ORDER BY forename, surname, driverid;

SELECT R1.driverId, forename, surname, count
FROM drivers, (
    SELECT driverId, COUNT(*) AS count
    FROM results
    WHERE positionOrder <= 3
    GROUP BY driverId
) AS R1
WHERE (
    drivers.driverId = R1.driverId AND
    R1.count = (
        SELECT MAX(count)
        FROM (
            SELECT driverId, COUNT(*) AS count
            FROM results
            WHERE positionOrder <= 3
            GROUP BY driverId
        ) AS R2
    )
)
ORDER BY forename, surname DESC, driverid;

SELECT R5.driverId AS driverid, forename, surname, num_champs
FROM (
    SELECT R2.driverId AS driverId, COUNT(*) AS num_champs
    FROM (
        SELECT year, driverId, SUM(points) AS points
        FROM races, results
        WHERE races.raceId = results.raceId
        GROUP BY year, driverId
    ) AS R2, (
        SELECT year, MAX(points) AS points
        FROM (
            SELECT year, driverId, SUM(points) AS points
            FROM races, results
            WHERE races.raceId = results.raceId
            GROUP BY year, driverId
        ) AS R3
        GROUP BY year
    ) AS R4
    WHERE (
        R2.year = R4.year AND
        R2.points = R4.points
    )
    GROUP BY R2.driverId
) AS R5, drivers
WHERE R5.driverId = drivers.driverId
ORDER BY num_champs DESC, forename, surname DESC, driverid
LIMIT 5;














