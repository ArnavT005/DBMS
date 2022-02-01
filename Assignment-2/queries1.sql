--1--
WITH RECURSIVE hops AS (
    SELECT DISTINCT destination_station_name AS station, 0 AS hopCount
    FROM train_info
    WHERE train_info.train_no = 97131
    UNION ALL
    SELECT DISTINCT destination_station_name AS station, (hopCount + 1) AS hopCount
    FROM train_info, hops
    WHERE (
        train_info.source_station_name = hops.station AND
        hops.hopCount <= 1
    )
)
SELECT DISTINCT station AS destination_station_name
FROM hops
ORDER BY destination_station_name;
--2--
WITH RECURSIVE hops AS (
    SELECT DISTINCT destination_station_name AS station, 0 AS hopCount, day_of_departure AS day
    FROM train_info
    WHERE (
        train_info.train_no = 97131 AND
        train_info.day_of_arrival = train_info.day_of_departure
    )
    UNION ALL
    SELECT DISTINCT destination_station_name AS station, (hopCount + 1) AS hopCount, day_of_departure AS day
    FROM train_info, hops
    WHERE (
        train_info.source_station_name = hops.station AND
        hops.hopCount <= 1 AND
        train_info.day_of_arrival = train_info.day_of_departure AND
        train_info.day_of_departure = hops.day
    )
)
SELECT DISTINCT station AS destination_station_name
FROM hops
ORDER BY destination_station_name;
--3--
WITH RECURSIVE hops AS (
    SELECT DISTINCT destination_station_name AS station, 0 AS hopCount, distance AS dist, day_of_departure AS day
    FROM train_info
    WHERE (
        train_info.source_station_name = 'DADAR' AND
        train_info.day_of_arrival = train_info.day_of_departure
    )
    UNION ALL
    SELECT DISTINCT destination_station_name AS station, (1 + hopCount) AS hopCount, (dist + distance) AS dist, day_of_departure AS day
    FROM train_info, hops
    WHERE (
        train_info.source_station_name = hops.station AND
        hops.hopCount <= 1 AND
        train_info.day_of_departure = train_info.day_of_arrival AND
        train_info.day_of_departure = hops.day
    )
)
SELECT DISTINCT station AS destination_station_name, dist AS distance, day
FROM hops
WHERE hops.station <> 'DADAR'
ORDER BY destination_station_name, distance, day;
--4--
WITH RECURSIVE hops AS (
    SELECT DISTINCT destination_station_name AS station, 0 AS hopCount, day_of_arrival AS day, arrival_time AS time
    FROM train_info
    WHERE (
        train_info.source_station_name = 'DADAR' AND
        CASE WHEN train_info.day_of_departure = 'Monday' THEN train_info.day_of_arrival IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')
             WHEN train_info.day_of_departure = 'Tuesday' THEN train_info.day_of_arrival IN ('Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')
             WHEN train_info.day_of_departure = 'Wednesday' THEN train_info.day_of_arrival IN ('Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')
             WHEN train_info.day_of_departure = 'Thursday' THEN train_info.day_of_arrival IN ('Thursday', 'Friday', 'Saturday', 'Sunday')
             WHEN train_info.day_of_departure = 'Friday' THEN train_info.day_of_arrival IN ('Friday', 'Saturday', 'Sunday')
             WHEN train_info.day_of_departure = 'Saturday' THEN train_info.day_of_arrival IN ('Saturday', 'Sunday')
             ELSE train_info.day_of_arrival IN ('Sunday')
        END AND
        (train_info.arrival_time >= train_info.departure_time OR train_info.day_of_departure <> train_info.day_of_arrival)
    )
    UNION ALL
    SELECT DISTINCT destination_station_name AS station, (1 + hopCount) AS hopCount, day_of_arrival AS day, arrival_time AS time
    FROM train_info, hops
    WHERE (
        train_info.source_station_name = hops.station AND
        hops.hopCount <= 1 AND
        CASE WHEN train_info.day_of_departure = 'Monday' THEN train_info.day_of_arrival IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')
             WHEN train_info.day_of_departure = 'Tuesday' THEN train_info.day_of_arrival IN ('Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')
             WHEN train_info.day_of_departure = 'Wednesday' THEN train_info.day_of_arrival IN ('Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')
             WHEN train_info.day_of_departure = 'Thursday' THEN train_info.day_of_arrival IN ('Thursday', 'Friday', 'Saturday', 'Sunday')
             WHEN train_info.day_of_departure = 'Friday' THEN train_info.day_of_arrival IN ('Friday', 'Saturday', 'Sunday')
             WHEN train_info.day_of_departure = 'Saturday' THEN train_info.day_of_arrival IN ('Saturday', 'Sunday')
             ELSE train_info.day_of_arrival IN ('Sunday')
        END AND
        (train_info.arrival_time >= train_info.departure_time OR train_info.day_of_departure <> train_info.day_of_arrival) AND
        CASE WHEN hops.day = 'Monday' THEN train_info.day_of_departure IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')
             WHEN hops.day = 'Tuesday' THEN train_info.day_of_departure IN ('Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')
             WHEN hops.day = 'Wednesday' THEN train_info.day_of_departure IN ('Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')
             WHEN hops.day = 'Thursday' THEN train_info.day_of_departure IN ('Thursday', 'Friday', 'Saturday', 'Sunday')
             WHEN hops.day = 'Friday' THEN train_info.day_of_departure IN ('Friday', 'Saturday', 'Sunday')
             WHEN hops.day = 'Saturday' THEN train_info.day_of_departure IN ('Saturday', 'Sunday')
             ELSE train_info.day_of_departure IN ('Sunday')
        END AND
        (train_info.departure_time >= hops.time OR train_info.day_of_departure <> hops.day)
    )
)
SELECT DISTINCT station AS destination_station_name
FROM hops
WHERE hops.station <> 'DADAR'
ORDER BY destination_station_name;
--5--
WITH RECURSIVE hops AS (
    SELECT DISTINCT ARRAY[train_no] AS trains, destination_station_name AS lastStation, 0 AS hopCount
    FROM train_info
    WHERE train_info.source_station_name = 'CST-MUMBAI'
    UNION ALL
    SELECT DISTINCT (trains || train_no) AS trains, destination_station_name AS lastStation, (1 + hopCount) AS hopCount
    FROM train_info, hops
    WHERE (
        train_info.source_station_name = hops.lastStation AND
        hops.lastStation <> 'VASHI' AND
        hops.lastStation <> 'CST-MUMBAI' AND
        hops.hopCount <= 1
    )
), temp2 AS (
    SELECT DISTINCT trains
    FROM hops
    WHERE hops.lastStation = 'VASHI'
)
SELECT COUNT(trains) AS Count
FROM temp2;
--6--
WITH temp1 AS (
    SELECT source_station_name, destination_station_name, MIN(distance) AS distance
    FROM train_info
    GROUP BY source_station_name, destination_station_name
), temp2 AS (
    SELECT temp1.source_station_name, train_info.destination_station_name, MIN(temp1.distance + train_info.distance) AS distance
    FROM train_info, temp1
    WHERE temp1.destination_station_name = train_info.source_station_name
    GROUP BY temp1.source_station_name, train_info.destination_station_name
), temp3 AS (
    SELECT *
    FROM temp1
    UNION
    SELECT *
    FROM temp2
), temp4 AS (
    SELECT source_station_name, destination_station_name, MIN(distance) AS distance
    FROM temp3
    GROUP BY source_station_name, destination_station_name
), temp5 AS (
    SELECT temp4.source_station_name, train_info.destination_station_name, MIN(temp4.distance + train_info.distance) AS distance
    FROM train_info, temp4
    WHERE temp4.destination_station_name = train_info.source_station_name
    GROUP BY temp4.source_station_name, train_info.destination_station_name
), temp6 AS (
    SELECT *
    FROM temp4
    UNION
    SELECT *
    FROM temp5
), temp7 AS (
    SELECT source_station_name, destination_station_name, MIN(distance) AS distance
    FROM temp6
    GROUP BY source_station_name, destination_station_name
), temp8 AS (
    SELECT temp7.source_station_name, train_info.destination_station_name, MIN(temp7.distance + train_info.distance) AS distance
    FROM train_info, temp7
    WHERE temp7.destination_station_name = train_info.source_station_name
    GROUP BY temp7.source_station_name, train_info.destination_station_name
), temp9 AS (
    SELECT *
    FROM temp7
    UNION
    SELECT *
    FROM temp8
), temp10 AS (
    SELECT source_station_name, destination_station_name, MIN(distance) AS distance
    FROM temp9
    GROUP BY source_station_name, destination_station_name
), temp11 AS (
    SELECT temp10.source_station_name, train_info.destination_station_name, MIN(temp10.distance + train_info.distance) AS distance
    FROM train_info, temp10
    WHERE temp10.destination_station_name = train_info.source_station_name
    GROUP BY temp10.source_station_name, train_info.destination_station_name
), temp12 AS (
    SELECT *
    FROM temp10
    UNION
    SELECT *
    FROM temp11
), temp13 AS (
    SELECT source_station_name, destination_station_name, MIN(distance) AS distance
    FROM temp12
    GROUP BY source_station_name, destination_station_name
), temp14 AS (
    SELECT temp13.source_station_name, train_info.destination_station_name, MIN(temp13.distance + train_info.distance) AS distance
    FROM train_info, temp13
    WHERE temp13.destination_station_name = train_info.source_station_name
    GROUP BY temp13.source_station_name, train_info.destination_station_name
), temp15 AS (
    SELECT *
    FROM temp13
    UNION
    SELECT *
    FROM temp14
), temp16 AS (
    SELECT source_station_name, destination_station_name, MIN(distance) AS distance
    FROM temp15
    GROUP BY source_station_name, destination_station_name
)
SELECT destination_station_name, source_station_name, distance
FROM temp16
WHERE temp16.destination_station_name <> temp16.source_station_name
ORDER BY destination_station_name, source_station_name, distance;
--7--
WITH temp1 AS (
    SELECT source_station_name, destination_station_name
    FROM train_info
    GROUP BY source_station_name, destination_station_name
), temp2 AS (
    SELECT temp1.source_station_name, train_info.destination_station_name
    FROM train_info, temp1
    WHERE temp1.destination_station_name = train_info.source_station_name
    GROUP BY temp1.source_station_name, train_info.destination_station_name
), temp3 AS (
    SELECT *
    FROM temp1
    UNION
    SELECT *
    FROM temp2
), temp4 AS (
    SELECT source_station_name, destination_station_name
    FROM temp3
    GROUP BY source_station_name, destination_station_name
), temp5 AS (
    SELECT temp4.source_station_name, train_info.destination_station_name
    FROM train_info, temp4
    WHERE temp4.destination_station_name = train_info.source_station_name
    GROUP BY temp4.source_station_name, train_info.destination_station_name
), temp6 AS (
    SELECT *
    FROM temp4
    UNION
    SELECT *
    FROM temp5
), temp7 AS (
    SELECT source_station_name, destination_station_name
    FROM temp6
    GROUP BY source_station_name, destination_station_name
), temp8 AS (
    SELECT temp7.source_station_name, train_info.destination_station_name
    FROM train_info, temp7
    WHERE temp7.destination_station_name = train_info.source_station_name
    GROUP BY temp7.source_station_name, train_info.destination_station_name
), temp9 AS (
    SELECT *
    FROM temp7
    UNION
    SELECT *
    FROM temp8
)
SELECT DISTINCT source_station_name, destination_station_name
FROM temp9
WHERE temp9.source_station_name <> temp9.destination_station_name
ORDER BY source_station_name, destination_station_name;
--8--
WITH RECURSIVE hops AS (
    SELECT DISTINCT destination_station_name AS station, day_of_departure AS day
    FROM train_info
    WHERE (
        train_info.source_station_name = 'SHIVAJINAGAR' AND
        train_info.day_of_departure = train_info.day_of_arrival
    )
    UNION ALL
    SELECT DISTINCT destination_station_name AS station, day_of_departure AS day
    FROM train_info, hops
    WHERE (
        train_info.source_station_name = hops.station AND
        train_info.day_of_departure = train_info.day_of_arrival AND
        train_info.day_of_departure = hops.day
    )
)
SELECT DISTINCT station AS destination_station_name
FROM hops
WHERE hops.station <> 'SHIVAJINAGAR'
ORDER BY destination_station_name;
--9--
WITH RECURSIVE temp1 AS (
    SELECT source_station_name, destination_station_name, MIN(distance) AS distance, day_of_departure
    FROM train_info
    WHERE train_info.day_of_departure = train_info.day_of_arrival
    GROUP BY source_station_name, destination_station_name, day_of_departure
), hops AS (
    SELECT DISTINCT (ARRAY[source_station_name] || destination_station_name) AS path, destination_station_name AS lastStation, distance AS dist, day_of_departure AS day
    FROM temp1
    WHERE temp1.source_station_name = 'LONAVLA'
    UNION ALL
    SELECT DISTINCT (path || destination_station_name) AS path, destination_station_name AS lastStation, (distance + dist) AS dist, day_of_departure AS day
    FROM temp1, hops
    WHERE (
        temp1.source_station_name = hops.lastStation AND
        temp1.day_of_departure = hops.day AND
        temp1.destination_station_name <> ALL(hops.path)
    )
)
SELECT lastStation AS destination_station_name, MIN(dist) AS distance, day
FROM hops
WHERE hops.lastStation <> 'LONAVLA'
GROUP BY lastStation, day
ORDER BY distance, destination_station_name, day;
--10--
WITH RECURSIVE hops AS (
    SELECT DISTINCT source_station_name AS startStation, ARRAY[destination_station_name] AS path, destination_station_name AS endStation, distance AS dist
    FROM train_info 
    UNION ALL
    SELECT DISTINCT startStation, (path || destination_station_name) AS path, destination_station_name AS endStation, (distance + dist) AS dist
    FROM train_info, hops
    WHERE (
        train_info.source_station_name = hops.endStation AND
        hops.endStation <> hops.startStation AND
        train_info.destination_station_name <> ALL(path)
    )
), temp2 AS (
    SELECT MAX(dist) AS dist
    FROM hops
    WHERE hops.startStation = hops.endStation
), temp3 AS (
    SELECT startStation, MAX(dist) AS dist
    FROM hops
    WHERE hops.startStation = hops.endStation
    GROUP BY startStation
) 
SELECT startStation AS source_station_name, dist AS distance
FROM temp3
WHERE (
    temp3.dist = (
        SELECT MAX(dist)
        FROM temp2
    )
)
ORDER BY source_station_name, distance;
--11--
WITH temp1 AS (
    SELECT DISTINCT source_station_name, destination_station_name
    FROM train_info
), temp2 AS (
    SELECT DISTINCT temp1.source_station_name, train_info.destination_station_name
    FROM train_info, temp1
    WHERE temp1.destination_station_name = train_info.source_station_name
), temp3 AS (
    SELECT *
    FROM temp1
    UNION
    SELECT *
    FROM temp2
), temp4 AS (
    SELECT DISTINCT source_station_name, destination_station_name
    FROM temp3
    WHERE source_station_name <> destination_station_name
), temp5 AS (
    SELECT source_station_name, COUNT(source_station_name) AS count
    FROM temp4
    GROUP BY source_station_name
), temp6 AS (
    SELECT DISTINCT destination_station_name AS station
    FROM train_info
    UNION
    SELECT DISTINCT source_station_name AS station
    FROM train_info
), temp7 AS (
    SELECT DISTINCT station
    FROM temp6
)
SELECT source_station_name
FROM temp5
WHERE (
    temp5.count = ((SELECT COUNT(*) FROM temp7) - 1)
)
ORDER BY source_station_name;
