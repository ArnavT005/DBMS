CREATE TABLE  IF NOT EXISTS appearances (
    gameid bigint NOT NULL,
    playerid bigint NOT NULL,
    leagueid bigint,
    goals bigint,
    owngoals bigint,
    assists bigint,
    keypasses bigint,
    shots bigint,
    CONSTRAINT appearance_key PRIMARY KEY (gameid, playerid)
);

CREATE TABLE  IF NOT EXISTS leagues (
    leagueid bigint NOT NULL,
    name text,
    CONSTRAINT league_key PRIMARY KEY (leagueid)
);

CREATE TABLE  IF NOT EXISTS players (
    playerid bigint NOT NULL,
    name text,
    CONSTRAINT player_key PRIMARY KEY (playerid)
);

CREATE TABLE  IF NOT EXISTS teams (
    teamid bigint NOT NULL,
    name text,
    CONSTRAINT team_key PRIMARY KEY (teamid)
);

CREATE table IF NOT EXISTS games(
    gameid bigint NOT NULL,
    leagueid bigint,
    hometeamid bigint,
    awayteamid bigint,
    year bigint,
    homegoals bigint,
    awaygoals bigint,
    CONSTRAINT game_key PRIMARY KEY (gameid),
    CONSTRAINT hometeam_ref FOREIGN KEY (hometeamid) REFERENCES teams(teamid),
    CONSTRAINT awayteam_ref FOREIGN KEY (awayteamid) REFERENCES teams(teamid)  
);