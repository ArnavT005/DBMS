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
    SELECT DISTINCT ARRAY[destination_station_name] AS path, destination_station_name AS station, 0 AS hopCount, distance AS dist, day_of_departure AS day
    FROM train_info
    WHERE (
        train_info.source_station_name = 'DADAR' AND
        train_info.day_of_arrival = train_info.day_of_departure
    )
    UNION ALL
    SELECT DISTINCT (path || destination_station_name) AS path, destination_station_name AS station, (1 + hopCount) AS hopCount, (dist + distance) AS dist, day_of_departure AS day
    FROM train_info, hops
    WHERE (
        train_info.source_station_name = hops.station AND
        hops.hopCount <= 1 AND
        train_info.day_of_departure = train_info.day_of_arrival AND
        train_info.day_of_departure = hops.day AND
        train_info.destination_station_name <> ALL(path) AND
        train_info.destination_station_name <> 'DADAR'
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
--12--
WITH temp1 AS (
    SELECT DISTINCT teamid AS id
    FROM teams
    WHERE teams.name = 'Arsenal'
), temp2 AS (
    SELECT DISTINCT awayteamid AS id
    FROM games
    WHERE (
        games.hometeamid IN (
            SELECT *
            FROM temp1
        )
    )
), temp3 AS (
    SELECT DISTINCT hometeamid AS id
    FROM games
    WHERE (
        games.hometeamid NOT IN (
            SELECT *
            FROM temp1
        ) AND
        games.awayteamid IN (
            SELECT *
            FROM temp2
        )
    )
)
SELECT DISTINCT name AS teamnames
FROM teams, temp3
WHERE teams.teamid = temp3.id
ORDER BY teamnames;
--13--
WITH temp1 AS (
    SELECT hometeamid AS id, SUM(homegoals) AS goals
    FROM games
    GROUP BY hometeamid
), temp2 AS (
    SELECT awayteamid AS id, SUM(awaygoals) AS goals
    FROM games
    GROUP BY awayteamid
), temp3 AS (
    SELECT temp1.id AS id, (temp1.goals + temp2.goals) AS goals
    FROM temp1, temp2
    WHERE temp1.id = temp2.id
), temp4 AS (
    SELECT id, goals
    FROM temp1
    WHERE (
        temp1.id NOT IN (
            SELECT id 
            FROM temp3
        ) 
    )
), temp5 AS (
    SELECT id, goals
    FROM temp2
    WHERE (
        temp2.id NOT IN (
            SELECT id
            FROM temp3
        ) 
    )
), temp6 AS (
    SELECT *
    FROM temp3
    UNION
    SELECT *
    FROM temp4
    UNION
    SELECT *
    FROM temp5
), temp7 AS (
    SELECT DISTINCT awayteamid AS id
    FROM games
    WHERE (
        games.hometeamid IN (
            SELECT DISTINCT teamid AS id
            FROM teams
            WHERE teams.name = 'Arsenal'
        )
    )
), temp8 AS (
    SELECT hometeamid AS id, MIN(year) AS year
    FROM games
    WHERE (
        games.awayteamid IN (
            SELECT *
            FROM temp7
        ) AND
        games.hometeamid NOT IN (
            SELECT DISTINCT teamid AS id
            FROM teams
            WHERE teams.name = 'Arsenal'
        )
    )
    GROUP BY hometeamid
), temp9 AS (
    SELECT temp8.id AS id, year, goals
    FROM temp6, temp8
    WHERE temp8.id = temp6.id
), temp10 AS (
    SELECT name AS teamnames, goals, year
    FROM teams, temp9
    WHERE teams.teamid = temp9.id
), temp11 AS (
    SELECT *
    FROM temp10
    WHERE (
        temp10.goals = (
            SELECT MAX(goals)
            FROM temp10
        )
    )
), temp12 AS (
    SELECT *
    FROM temp11
    WHERE (
        temp11.year = (
            SELECT MIN(year)
            FROM temp11
        )
    )
)
SELECT *
FROM temp12
ORDER BY teamnames;
--14--
WITH hops AS (
    SELECT *
    FROM games
    WHERE year = 2015
), temp1 AS (
    SELECT teamid AS id
    FROM teams
    WHERE teams.name = 'Leicester'
), temp2 AS (
    SELECT DISTINCT awayteamid AS id
    FROM hops
    WHERE (
        hops.hometeamid IN (
            SELECT *
            FROM temp1
        )
    )
), temp3 AS (
    SELECT DISTINCT hometeamid AS id
    FROM hops
    WHERE (
        hops.hometeamid NOT IN (
            SELECT *
            FROM temp1
        ) AND
        hops.awayteamid IN (
            SELECT *
            FROM temp2
        )
    )
), temp4 AS (
    SELECT hometeamid AS id, (homegoals - awaygoals) AS goals
    FROM hops
    WHERE (
        hops.hometeamid IN (
            SELECT *
            FROM temp3
        ) --AND
        -- hops.awayteamid IN (
        --     SELECT *
        --     FROM temp2
        -- )
    )
)
SELECT DISTINCT name AS teamnames, goals AS goaldiff
FROM temp4, teams
WHERE (
    temp4.id = teams.teamid AND
    temp4.goals > 3
)
ORDER BY goaldiff, teamnames;
--15--
WITH temp1 AS (
    SELECT teamid AS id
    FROM teams
    WHERE teams.name = 'Valencia'
), temp2 AS (
    SELECT DISTINCT awayteamid AS id
    FROM games
    WHERE (
        games.hometeamid IN (
            SELECT *
            FROM temp1
        )
    )
), temp3 AS (
    SELECT DISTINCT hometeamid AS id
    FROM games
    WHERE (
        games.hometeamid NOT IN (
            SELECT *
            FROM temp1
        ) AND
        games.awayteamid IN (
            SELECT *
            FROM temp2
        )
    )
), temp4 AS (
    SELECT gameid
    FROM games
    WHERE (
        games.hometeamid IN (
            SELECT *
            FROM temp3
        ) AND 
        games.awayteamid IN (
            SELECT *
            FROM temp2
        )
    )
), temp5 AS (
    SELECT playerid, SUM(goals) AS goals
    FROM temp4, appearances
    WHERE temp4.gameid = appearances.gameid
    GROUP BY playerid
), temp6 AS (
    SELECT *
    FROM temp5
    WHERE (
        temp5.goals = (
            SELECT MAX(goals)
            FROM temp5
        )
    )
)
SELECT name AS playernames, goals
FROM players, temp6
WHERE players.playerid = temp6.playerid
ORDER BY name;
--16--
WITH temp1 AS (
    SELECT teamid AS id
    FROM teams
    WHERE teams.name = 'Everton'
), temp2 AS (
    SELECT DISTINCT awayteamid AS id
    FROM games
    WHERE (
        games.hometeamid IN (
            SELECT *
            FROM temp1
        )
    )
), temp3 AS (
    SELECT DISTINCT hometeamid AS id
    FROM games
    WHERE (
        games.hometeamid NOT IN (
            SELECT *
            FROM temp1
        ) AND
        games.awayteamid IN (
            SELECT *
            FROM temp2
        )
    )
), temp6 AS (
    SELECT *
    FROM temp3
), temp7 AS (
    SELECT gameid
    FROM games
    WHERE (
        games.hometeamid IN (
            SELECT *
            FROM temp6
        ) AND
        games.awayteamid IN (
            SELECT *
            FROM temp2
        )
    )
), temp8 AS (
    SELECT playerid, SUM(assists) AS assists
    FROM temp7, appearances
    WHERE temp7.gameid = appearances.gameid
    GROUP BY playerid
), temp9 AS (
    SELECT *
    FROM temp8
    WHERE (
        temp8.assists = (
            SELECT MAX(assists)
            FROM temp8
        )
    )
)
SELECT name AS playernames, assists AS assistscount
FROM temp9, players
WHERE temp9.playerid = players.playerid
ORDER BY playernames;
--17--
WITH hops AS (
    SELECT *
    FROM games
    WHERE year = 2016
), temp1 AS (
    SELECT teamid AS id
    FROM teams
    WHERE teams.name = 'AC Milan'
), temp4 AS (
    SELECT DISTINCT hometeamid AS id
    FROM hops
    WHERE (
        hops.awayteamid IN (
            SELECT *
            FROM temp1
        )
    )
), temp5 AS (
    SELECT DISTINCT awayteamid AS id
    FROM hops
    WHERE (
        hops.awayteamid NOT IN (
            SELECT *
            FROM temp1
        ) AND
        hops.hometeamid IN (
            SELECT *
            FROM temp4
        )
    )
), temp6 AS (
    SELECT *
    FROM temp5
), temp7 AS (
    SELECT gameid
    FROM hops
    WHERE (
        hops.awayteamid IN (
            SELECT *
            FROM temp6
        ) AND
        hops.hometeamid IN (
            SELECT *
            FROM temp4
        )
    )
), temp8 AS (
    SELECT playerid, SUM(shots) AS shots
    FROM appearances, temp7
    WHERE temp7.gameid = appearances.gameid
    GROUP BY playerid
), temp9 AS (
    SELECT *
    FROM temp8
    WHERE (
        temp8.shots = (
            SELECT MAX(shots)
            FROM temp8
        )
    )
)
SELECT name AS playernames, shots AS shotscount
FROM players, temp9
WHERE players.playerid = temp9.playerid
ORDER BY playernames;
--18--
WITH temp AS (
    SELECT awayteamid, SUM(awaygoals) AS goals
    FROM games
    WHERE year = 2020
    GROUP BY awayteamid
), temp2 AS (
    SELECT DISTINCT awayteamid
    FROM temp
    WHERE temp.goals = 0
)
SELECT name AS teamname, 2020 AS year
FROM teams, temp2
WHERE teams.teamid = temp2.awayteamid
ORDER BY teamname
LIMIT 5;
--19--
WITH temp1 AS (
    SELECT *
    FROM games
    WHERE games.year = 2019
), temp2 AS (
    SELECT MAX(leagueid) AS leagueid, hometeamid AS id, SUM(homegoals) AS goals
    FROM temp1
    GROUP BY hometeamid
), temp3 AS (
    SELECT MAX(leagueid) AS leagueid, awayteamid AS id, SUM(awaygoals) AS goals
    FROM temp1
    GROUP BY awayteamid
), temp4 AS (
    SELECT temp2.leagueid AS leagueid, temp2.id AS id, (temp2.goals + temp3.goals) AS goals
    FROM temp2, temp3
    WHERE temp2.id = temp3.id
), temp5 AS (
    SELECT *
    FROM temp2
    WHERE (
        temp2.id NOT IN (
            SELECT id
            FROM temp4
        )
    )
), temp6 AS (
    SELECT *
    FROM temp3
    WHERE (
        temp3.id NOT IN (
            SELECT id
            FROM temp4
        )
    )
), temp7 AS (
    SELECT *
    FROM temp4
    UNION
    SELECT *
    FROM temp5
    UNION
    SELECT *
    FROM temp6
), temp8 AS (
    SELECT leagueid, MAX(goals) AS goals
    FROM temp7
    GROUP BY leagueid
), temp9 AS (
    SELECT DISTINCT temp7.leagueid AS leagueid, id, temp7.goals AS goals
    FROM temp7, temp8
    WHERE (
        temp7.leagueid = temp8.leagueid AND
        temp7.goals = temp8.goals
    )
), temp10 AS (
    SELECT DISTINCT awayteamid AS id
    FROM temp1
    WHERE (
        temp1.hometeamid IN (
            SELECT id
            FROM temp9
        )
    )
), temp11 AS (
    SELECT DISTINCT leagueid, hometeamid AS id
    FROM temp1
    WHERE (
        temp1.hometeamid NOT IN (
            SELECT id
            FROM temp9
        ) AND
        temp1.awayteamid IN (
            SELECT *
            FROM temp10
        )
    )
), temp14 AS (
    SELECT *
    FROM temp11
), temp15 AS (
    SELECT gameid
    FROM temp1
    WHERE (
        temp1.hometeamid IN (
            SELECT id
            FROM temp14
        ) AND
        temp1.awayteamid IN (
            SELECT *
            FROM temp10
        )
    )
), temp16 AS (
    SELECT MAX(leagueid) AS leagueid, playerid, SUM(goals) AS goals
    FROM appearances, temp15
    WHERE appearances.gameid = temp15.gameid
    GROUP BY playerid
), temp17 AS (
    SELECT leagueid, MAX(goals) AS goals
    FROM temp16
    GROUP BY leagueid
), temp18 AS (
    SELECT DISTINCT temp16.leagueid AS leagueid, playerid, temp16.goals AS goals
    FROM temp16, temp17
    WHERE (
        temp16.goals = temp17.goals AND
        temp16.leagueid = temp17.leagueid
    )
), temp19 AS (
    SELECT temp9.leagueid AS leagueid, temp18.playerid AS playerid, temp18.goals AS playertopscore, temp9.id AS id, temp9.goals AS teamtopscore
    FROM temp9, temp18
    WHERE temp9.leagueid = temp18.leagueid
)
SELECT leagues.name AS leaguename, players.name AS playernames, playertopscore, teams.name AS teamname, teamtopscore
FROM temp19, leagues, players, teams
WHERE (
    temp19.leagueid = leagues.leagueid AND
    temp19.playerid = players.playerid AND
    temp19.id = teams.teamid
)
ORDER BY playertopscore DESC, teamtopscore DESC, playernames, teamname;
--20--
WITH RECURSIVE temp1 AS (
    SELECT teamid AS source
    FROM teams
    WHERE teams.name = 'Manchester United'
), temp2 AS (
    SELECT teamid AS sink
    FROM teams
    WHERE teams.name = 'Manchester City'
), temp3 AS (
    SELECT DISTINCT (ARRAY[temp1.source] || awayteamid) AS path, awayteamid AS lastTeam, 1 AS length
    FROM temp1, games
    WHERE games.hometeamid = temp1.source
    UNION ALL
    SELECT DISTINCT (path || awayteamid) AS path, awayteamid AS lastTeam, (length + 1) AS length
    FROM games, temp3
    WHERE (
        games.hometeamid = temp3.lastTeam AND
        games.awayteamid <> ALL(temp3.path) AND
        temp3.lastTeam NOT IN (
            SELECT sink
            FROM temp2
        )
    ) 
), temp4 AS (
    SELECT length AS count
    FROM temp3
    WHERE (
        temp3.lastTeam IN (
            SELECT sink
            FROM temp2
        ) 
    )
)
SELECT MAX(count) AS count
FROM temp4;
--21--
WITH RECURSIVE temp1 AS (
    SELECT teamid AS source
    FROM teams
    WHERE teams.name = 'Manchester United'
), temp2 AS (
    SELECT teamid AS sink
    FROM teams
    WHERE teams.name = 'Manchester City'
), temp3 AS (
    SELECT DISTINCT (ARRAY[temp1.source] || awayteamid) AS path, awayteamid AS lastTeam
    FROM temp1, games
    WHERE games.hometeamid = temp1.source
    UNION ALL
    SELECT DISTINCT (path || awayteamid) AS path, awayteamid AS lastTeam
    FROM games, temp3
    WHERE (
        games.hometeamid = temp3.lastTeam AND
        games.awayteamid <> ALL(temp3.path) AND
        temp3.lastTeam NOT IN (
            SELECT sink
            FROM temp2
        )
    ) 
), temp4 AS (
    SELECT DISTINCT path
    FROM temp3
    WHERE (
        temp3.lastTeam IN (
            SELECT sink
            FROM temp2
        ) 
    )
)
SELECT COUNT(*) AS count
FROM temp4;
--22--
WITH RECURSIVE temp1 AS (
    SELECT DISTINCT leagueid AS id, hometeamid AS startTeam, (ARRAY[hometeamid] || awayteamid) AS path, awayteamid AS endTeam, 1 AS length
    FROM games
    UNION ALL
    SELECT DISTINCT leagueid AS id, startTeam, (path || awayteamid) AS path, awayteamid AS endTeam, (1 + length) AS length
    FROM games, temp1
    WHERE (
        games.hometeamid = temp1.endTeam AND
        games.awayteamid <> ALL(temp1.path)
    )
), temp2 AS (
    SELECT id, MAX(length) AS length
    FROM temp1
    GROUP BY id
), temp3 AS (
    SELECT DISTINCT temp1.id AS id, startTeam, endTeam, temp1.length AS length
    FROM temp1, temp2
    WHERE (
        temp2.id = temp1.id AND
        temp1.length = temp2.length
    )
), temp4 AS (
    SELECT leagues.name AS leaguename, teams.name AS teamAname, endTeam, length AS count
    FROM temp3, leagues, teams
    WHERE (
        temp3.id = leagues.leagueid AND
        temp3.startTeam = teams.teamid
    )
)
SELECT leaguename, teamAname, teams.name AS teamBname, count
FROM temp4, teams
WHERE temp4.endTeam = teams.teamid
ORDER BY count DESC, teamAname, teamBname;
