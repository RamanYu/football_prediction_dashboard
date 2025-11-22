SELECT
    m.match_api_id,
    m.season,
    m.date,
    m.home_team_goal,
    m.away_team_goal,
    ht.team_long_name  AS home_team,
    at.team_long_name  AS away_team,
    l.name AS league,
    c.name AS country,
    -- атрибуты домашней команды
    (SELECT ta.buildUpPlaySpeed FROM team_attributes ta
     WHERE ta.team_api_id = m.home_team_api_id AND ta.date <= m.date
     ORDER BY ta.date DESC LIMIT 1) AS home_buildUpPlaySpeed,
    (SELECT ta.buildUpPlayPassing FROM team_attributes ta
     WHERE ta.team_api_id = m.home_team_api_id AND ta.date <= m.date
     ORDER BY ta.date DESC LIMIT 1) AS home_buildUpPlayPassing,
    (SELECT ta.buildUpPlayDribbling FROM team_attributes ta
     WHERE ta.team_api_id = m.home_team_api_id AND ta.date <= m.date
     ORDER BY ta.date DESC LIMIT 1) AS home_buildUpPlayDribbling,
    (SELECT ta.chanceCreationPassing FROM team_attributes ta
     WHERE ta.team_api_id = m.home_team_api_id AND ta.date <= m.date
     ORDER BY ta.date DESC LIMIT 1) AS home_chanceCreationPassing,
    (SELECT ta.chanceCreationShooting FROM team_attributes ta
     WHERE ta.team_api_id = m.home_team_api_id AND ta.date <= m.date
     ORDER BY ta.date DESC LIMIT 1) AS home_chanceCreationShooting,
    (SELECT ta.chanceCreationCrossing FROM team_attributes ta
     WHERE ta.team_api_id = m.home_team_api_id AND ta.date <= m.date
     ORDER BY ta.date DESC LIMIT 1) AS home_chanceCreationCrossing,
    (SELECT ta.defencePressure FROM team_attributes ta
     WHERE ta.team_api_id = m.home_team_api_id AND ta.date <= m.date
     ORDER BY ta.date DESC LIMIT 1) AS home_defencePressure,
    (SELECT ta.defenceAggression FROM team_attributes ta
     WHERE ta.team_api_id = m.home_team_api_id AND ta.date <= m.date
     ORDER BY ta.date DESC LIMIT 1) AS home_defenceAggression,
    (SELECT ta.defenceTeamWidth FROM team_attributes ta
     WHERE ta.team_api_id = m.home_team_api_id AND ta.date <= m.date
     ORDER BY ta.date DESC LIMIT 1) AS home_defenceTeamWidth,
    -- маппинг классов для home
    CASE WHEN (SELECT ta.buildUpPlaySpeedClass FROM team_attributes ta
               WHERE ta.team_api_id = m.home_team_api_id AND ta.date <= m.date
               ORDER BY ta.date DESC LIMIT 1)='Balanced' THEN 1
         WHEN (SELECT ta.buildUpPlaySpeedClass FROM team_attributes ta
               WHERE ta.team_api_id = m.home_team_api_id AND ta.date <= m.date
               ORDER BY ta.date DESC LIMIT 1)='Fast' THEN 2 ELSE 0 END AS home_buildUpPlaySpeedClass,
    CASE WHEN (SELECT ta.buildUpPlayPositioningClass FROM team_attributes ta
               WHERE ta.team_api_id = m.home_team_api_id AND ta.date <= m.date
               ORDER BY ta.date DESC LIMIT 1)='Organised' THEN 1
         WHEN (SELECT ta.buildUpPlayPositioningClass FROM team_attributes ta
               WHERE ta.team_api_id = m.home_team_api_id AND ta.date <= m.date
               ORDER BY ta.date DESC LIMIT 1)='Free Form' THEN 0 END AS home_buildUpPlayPositioningClass,
    -- атрибуты гостевой команды
    (SELECT ta.buildUpPlaySpeed FROM team_attributes ta
     WHERE ta.team_api_id = m.away_team_api_id AND ta.date <= m.date
     ORDER BY ta.date DESC LIMIT 1) AS away_buildUpPlaySpeed,
    (SELECT ta.buildUpPlayPassing FROM team_attributes ta
     WHERE ta.team_api_id = m.away_team_api_id AND ta.date <= m.date
     ORDER BY ta.date DESC LIMIT 1) AS away_buildUpPlayPassing,
    (SELECT ta.buildUpPlayDribbling FROM team_attributes ta
     WHERE ta.team_api_id = m.away_team_api_id AND ta.date <= m.date
     ORDER BY ta.date DESC LIMIT 1) AS away_buildUpPlayDribbling,
    (SELECT ta.chanceCreationPassing FROM team_attributes ta
     WHERE ta.team_api_id = m.away_team_api_id AND ta.date <= m.date
     ORDER BY ta.date DESC LIMIT 1) AS away_chanceCreationPassing,
    (SELECT ta.chanceCreationShooting FROM team_attributes ta
     WHERE ta.team_api_id = m.away_team_api_id AND ta.date <= m.date
     ORDER BY ta.date DESC LIMIT 1) AS away_chanceCreationShooting,
    (SELECT ta.chanceCreationCrossing FROM team_attributes ta
     WHERE ta.team_api_id = m.away_team_api_id AND ta.date <= m.date
     ORDER BY ta.date DESC LIMIT 1) AS away_chanceCreationCrossing,
    (SELECT ta.defencePressure FROM team_attributes ta
     WHERE ta.team_api_id = m.away_team_api_id AND ta.date <= m.date
     ORDER BY ta.date DESC LIMIT 1) AS away_defencePressure,
    (SELECT ta.defenceAggression FROM team_attributes ta
     WHERE ta.team_api_id = m.away_team_api_id AND ta.date <= m.date
     ORDER BY ta.date DESC LIMIT 1) AS away_defenceAggression,
    (SELECT ta.defenceTeamWidth FROM team_attributes ta
     WHERE ta.team_api_id = m.away_team_api_id AND ta.date <= m.date
     ORDER BY ta.date DESC LIMIT 1) AS away_defenceTeamWidth,
    -- маппинг классов для away
    CASE WHEN (SELECT ta.buildUpPlaySpeedClass FROM team_attributes ta
               WHERE ta.team_api_id = m.away_team_api_id AND ta.date <= m.date
               ORDER BY ta.date DESC LIMIT 1)='Balanced' THEN 1
         WHEN (SELECT ta.buildUpPlaySpeedClass FROM team_attributes ta
               WHERE ta.team_api_id = m.away_team_api_id AND ta.date <= m.date
               ORDER BY ta.date DESC LIMIT 1)='Fast' THEN 2 ELSE 0 END AS away_buildUpPlaySpeedClass,
    CASE WHEN (SELECT ta.buildUpPlayPositioningClass FROM team_attributes ta
               WHERE ta.team_api_id = m.away_team_api_id AND ta.date <= m.date
               ORDER BY ta.date DESC LIMIT 1)='Organised' THEN 1
         WHEN (SELECT ta.buildUpPlayPositioningClass FROM team_attributes ta
               WHERE ta.team_api_id = m.away_team_api_id AND ta.date <= m.date
               ORDER BY ta.date DESC LIMIT 1)='Free Form' THEN 0 END AS away_buildUpPlayPositioningClass
FROM "match" m
LEFT JOIN team ht ON ht.team_api_id = m.home_team_api_id
LEFT JOIN team at ON at.team_api_id = m.away_team_api_id
LEFT JOIN league l ON l.id = m.league_id
LEFT JOIN country c ON c.id = l.country_id;


