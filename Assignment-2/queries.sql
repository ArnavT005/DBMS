--12--
WITH temp1 AS (
    SELECT DISTINCT awayteamid AS id
    FROM games
    WHERE (
        games.hometeamid IN (
            SELECT DISTINCT teamid AS id
            FROM teams
            WHERE teams.name = 'Arsenal'
        )
    )
)
SELECT DISTINCT name AS teamnames
FROM teams, games, temp1
WHERE (
    games.hometeamid = teams.teamid AND
    teams.name <> 'Arsenal' AND
    games.awayteamid IN (
        SELECT *
        FROM temp1
    )
)
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
    WHERE (
        teams.teamid = temp9.id AND
        teams.name <> 'Arsenal'
    )
), temp11 AS (
    SELECT *
    FROM temp10
    WHERE (
        temp10.year = (
            SELECT MIN(year)
            FROM temp10
        )
    )
), temp12 AS (
    SELECT *
    FROM temp11
    WHERE (
        temp11.goals = (
            SELECT MAX(goals)
            FROM temp11
        )
    )
)
SELECT *
FROM temp12
ORDER BY year, goals DESC, teamnames
LIMIT 1;
--14--
WITH temp1 AS (
    SELECT teamid AS id
    FROM teams
    WHERE teams.name = 'Leicester'
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
    SELECT hometeamid AS id, (homegoals - awaygoals) AS goals
    FROM games
    WHERE (
        games.hometeamid IN (
            SELECT *
            FROM temp3
        ) AND
        games.year = 2015
    )
)
SELECT name AS teamnames, goals
FROM temp4, teams
WHERE (
    temp4.id = teams.teamid AND
    temp4.goals > 3
)
ORDER BY goals, teamnames;
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
        games.awayteamid IN (
            SELECT *
            FROM temp3
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
SELECT name AS playernames, goals AS score
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
), temp4 AS (
    SELECT DISTINCT hometeamid AS id
    FROM games
    WHERE (
        games.awayteamid IN (
            SELECT *
            FROM temp1
        )
    )
), temp5 AS (
    SELECT DISTINCT awayteamid AS id
    FROM games
    WHERE (
        games.awayteamid NOT IN (
            SELECT *
            FROM temp1
        ) AND
        games.hometeamid IN (
            SELECT *
            FROM temp4
        )
    )
), temp6 AS (
    SELECT *
    FROM temp3
    UNION
    SELECT *
    FROM temp5
), temp7 AS (
    SELECT gameid
    FROM games
    WHERE (
        games.hometeamid IN (
            SELECT *
            FROM temp6
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
WITH temp1 AS (
    SELECT teamid AS id
    FROM teams
    WHERE teams.name = 'AC Milan'
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
    SELECT DISTINCT hometeamid AS id
    FROM games
    WHERE (
        games.awayteamid IN (
            SELECT *
            FROM temp1
        )
    )
), temp5 AS (
    SELECT DISTINCT awayteamid AS id
    FROM games
    WHERE (
        games.awayteamid NOT IN (
            SELECT *
            FROM temp1
        ) AND
        games.hometeamid IN (
            SELECT *
            FROM temp4
        )
    )
), temp6 AS (
    SELECT *
    FROM temp3
    UNION
    SELECT *
    FROM temp5
), temp7 AS (
    SELECT gameid
    FROM games
    WHERE (
        games.awayteamid IN (
            SELECT *
            FROM temp6
        ) AND
        games.year = 2016
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
WITH temp1 AS (
    SELECT teamid AS id
    FROM teams
    WHERE teams.name = 'AC Milan'
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
    SELECT DISTINCT hometeamid AS id
    FROM games
    WHERE (
        games.awayteamid IN (
            SELECT *
            FROM temp1
        )
    )
), temp5 AS (
    SELECT DISTINCT awayteamid AS id
    FROM games
    WHERE (
        games.awayteamid NOT IN (
            SELECT *
            FROM temp1
        ) AND
        games.hometeamid IN (
            SELECT *
            FROM temp4
        )
    )
), temp6 AS (
    SELECT *
    FROM temp3
    UNION
    SELECT *
    FROM temp5
), temp7 AS (
    SELECT DISTINCT awayteamid AS id
    FROM games
    WHERE (
        games.year = 2020 AND
        games.awaygoals = 0 AND 
        games.awayteamid IN (
            SELECT *
            FROM temp6
        )
    )
)
SELECT name AS teamname, 2020 AS year
FROM teams, temp7
WHERE teams.teamid = temp7.id
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
    SELECT temp7.leagueid AS leagueid, id, temp7.goals AS goals
    FROM temp7, temp8
    WHERE (
        temp7.leagueid = temp8.leagueid AND
        temp7.goals = temp8.goals
    )
), temp10 AS (
    SELECT DISTINCT awayteamid AS id
    FROM games
    WHERE (
        games.hometeamid IN (
            SELECT id
            FROM temp9
        )
    )
), temp11 AS (
    SELECT DISTINCT leagueid, hometeamid AS id
    FROM games
    WHERE (
        games.hometeamid NOT IN (
            SELECT id
            FROM temp9
        ) AND
        games.awayteamid IN (
            SELECT *
            FROM temp10
        )
    )
), temp12 AS (
    SELECT DISTINCT hometeamid AS id
    FROM games
    WHERE (
        games.awayteamid IN (
            SELECT id
            FROM temp9
        )
    )
), temp13 AS (
    SELECT DISTINCT leagueid, awayteamid AS id
    FROM games
    WHERE (
        games.awayteamid NOT IN (
            SELECT id
            FROM temp9
        ) AND
        games.hometeamid IN (
            SELECT *
            FROM temp12
        )
    )
), temp14 AS (
    SELECT *
    FROM temp11
    UNION
    SELECT *
    FROM temp13
), temp15 AS (
    SELECT gameid
    FROM games
    WHERE (
        games.awayteamid IN (
            SELECT id
            FROM temp14
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
    SELECT temp16.leagueid AS leagueid, temp16.playerid AS playerid, temp16.goals AS goals
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
ORDER BY teamtopscore;
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
    SELECT DISTINCT leagueid
    FROM games
    WHERE (
        games.awayteamid = (
            SELECT source
            FROM temp1
        ) OR
        games.awayteamid = (
            SELECT sink
            FROM temp2
        ) OR
        games.hometeamid = (
            SELECT source
            FROM temp1
        ) OR
        games.hometeamid = (
            SELECT sink
            FROM temp2
        ) 
    )
), temp4 AS (
    SELECT DISTINCT hometeamid, awayteamid
    FROM games
    WHERE (
        games.leagueid IN (
            SELECT leagueid
            FROM temp3
        )
    )
), temp5 AS (
    SELECT ARRAY[temp1.source] AS path, temp1.source AS node, 0 AS length
    FROM temp1
    UNION ALL
    SELECT (path || temp4.awayteamid) AS path, temp4.awayteamid AS node, (length + 1) AS length
    FROM temp4, temp5
    WHERE (
        temp5.node = temp4.hometeamid AND
        NOT (temp4.awayteamid = ALL(temp5.path)) AND
        NOT (temp5.node = (
                SELECT sink
                FROM temp2
            )
        )
    ) 
)
-- SELECT *
-- FROM temp4;
SELECT length AS count
FROM temp5
WHERE (
    temp5.node = (
        SELECT sink
        FROM temp2
    )
)
ORDER BY count DESC
LIMIT 1;