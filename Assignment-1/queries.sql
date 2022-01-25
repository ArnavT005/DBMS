--1--
WITH temp1 AS (
    SELECT lapTimes.driverId AS driverid, forename, surname, nationality, milliseconds AS time
    FROM drivers, lapTimes, races, circuits
    WHERE (
        lapTimes.driverId = drivers.driverId AND
        lapTimes.raceId = races.raceId AND
        races.circuitId = circuits.circuitId AND 
        year = 2017 AND
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
    SELECT drivers.driverId AS driverId, COUNT(drivers.driverId) AS race_wins
    FROM drivers, results
    WHERE (
        drivers.driverId = results.driverId AND
        positionOrder = 1
    )
    GROUP BY drivers.driverId
)
SELECT temp1.driverId AS driverid, forename, surname, race_wins
FROM temp1, drivers
WHERE (
    temp1.driverId = drivers.driverId AND
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
    temp1.num_stops = (
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
--13--
WITH temp1 AS (
    SELECT year, constructorId, SUM(points) AS points
    FROM races, constructorResults
    WHERE races.raceId = constructorResults.raceId
    GROUP BY year, constructorId
), temp2 AS (
    SELECT year, MAX(points) AS points
    FROM temp1
    GROUP BY year
), temp3 AS (
    SELECT temp1.year AS year, temp1.constructorId AS constructorId, name, temp1.points AS points
    FROM temp1, temp2, constructors
    WHERE (
        temp1.year = temp2.year AND
        temp1.points = temp2.points AND
        temp1.constructorId = constructors.constructorId
    )
), temp4 AS (
    SELECT temp1.year AS year, constructorId, temp1.points AS points
    FROM temp1, temp2
    WHERE (
        temp1.year = temp2.year AND
        NOT (temp1.points = temp2.points)
    )
), temp5 AS (
    SELECT year, MAX(points) AS points
    FROM temp4
    GROUP BY year
), temp6 AS (
    SELECT temp4.year AS year, temp4.constructorId AS constructorId, name, temp4.points AS points
    FROM temp4, temp5, constructors
    WHERE (
        temp4.year = temp5.year AND
        temp4.points = temp5.points AND
        temp4.constructorId = constructors.constructorId
    )
), temp7 AS (
    SELECT temp3.year AS year, (temp3.points - temp6.points) AS point_diff, temp3.constructorId AS constructor1_id, temp3.name AS constructor1_name, temp6.constructorId AS constructor2_id, temp6.name AS constructor2_name
    FROM temp3, temp6
    WHERE temp3.year = temp6.year
)
SELECT *
FROM temp7
WHERE (
    temp7.point_diff = (
        SELECT MAX(point_diff)
        FROM temp7
    )
)
ORDER BY constructor1_name, constructor2_name, constructor1_id, constructor2_id;
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
WITH temp1 AS (
    SELECT constructorId, COUNT(constructorId) AS count
    FROM (
        SELECT results.raceId AS raceId, constructorId, COUNT(*) AS count
        FROM results, races
        WHERE (
            results.raceId = races.raceId AND
            positionOrder <= 2 AND
            positionOrder > 0 AND
            year >= 2014
        )
        GROUP BY results.raceId, constructorId
    ) AS R1
    WHERE R1.count = 2
    GROUP BY constructorId
)
SELECT temp1.constructorId AS constructorid, name, count
FROM temp1, constructors
WHERE (
    temp1.constructorId = constructors.constructorId AND
    temp1.count = (
        SELECT MAX(count)
        FROM temp1
    )
)
ORDER BY name, constructorid;
--18--
WITH temp1 AS (
    SELECT driverId, COUNT(driverId) AS num_laps
    FROM lapTimes
    WHERE position = 1
    GROUP BY driverId
)
SELECT temp1.driverId AS driverid, forename, surname, num_laps
FROM temp1, drivers
WHERE (
    temp1.driverId = drivers.driverId AND
    temp1.num_laps = (
        SELECT MAX(num_laps)
        FROM temp1
    )
)
ORDER BY forename, surname, driverid;
--19--
WITH temp1 AS (
    SELECT driverId, COUNT(driverId) AS count
    FROM results
    WHERE (
        positionOrder <= 3 AND 
        positionOrder > 0
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
ORDER BY forename, surname DESC, driverid;
--20--
WITH temp1 AS (
    SELECT year, driverId, SUM(points) AS points
    FROM races, results
    WHERE races.raceId = results.raceId
    GROUP BY year, driverId
)
SELECT R2.driverId AS driverid, forename, surname, num_champs
FROM (
    SELECT temp1.driverId AS driverId, COUNT(temp1.driverId) AS num_champs
    FROM temp1, (
        SELECT year, MAX(points) AS points
        FROM temp1
        GROUP BY year
    ) AS R1
    WHERE (
        temp1.year = R1.year AND
        temp1.points = R1.points
    )
    GROUP BY temp1.driverId
) AS R2, drivers
WHERE R2.driverId = drivers.driverId
ORDER BY num_champs DESC, forename, surname DESC, driverid
LIMIT 5;
