CREATE INDEX idx_player_attr ON player_attributes(player_api_id, date);

WITH
-- 1) Все игроки стартовых 11 обеих команд + дата матча и сторона
players AS (
  SELECT match_api_id, date AS match_date, 'H' AS side, home_player_1  AS player_id FROM match
  UNION ALL SELECT match_api_id, date, 'H', home_player_2  FROM match
  UNION ALL SELECT match_api_id, date, 'H', home_player_3  FROM match
  UNION ALL SELECT match_api_id, date, 'H', home_player_4  FROM match
  UNION ALL SELECT match_api_id, date, 'H', home_player_5  FROM match
  UNION ALL SELECT match_api_id, date, 'H', home_player_6  FROM match
  UNION ALL SELECT match_api_id, date, 'H', home_player_7  FROM match
  UNION ALL SELECT match_api_id, date, 'H', home_player_8  FROM match
  UNION ALL SELECT match_api_id, date, 'H', home_player_9  FROM match
  UNION ALL SELECT match_api_id, date, 'H', home_player_10 FROM match
  UNION ALL SELECT match_api_id, date, 'H', home_player_11 FROM match
  UNION ALL SELECT match_api_id, date, 'A', away_player_1  FROM match
  UNION ALL SELECT match_api_id, date, 'A', away_player_2  FROM match
  UNION ALL SELECT match_api_id, date, 'A', away_player_3  FROM match
  UNION ALL SELECT match_api_id, date, 'A', away_player_4  FROM match
  UNION ALL SELECT match_api_id, date, 'A', away_player_5  FROM match
  UNION ALL SELECT match_api_id, date, 'A', away_player_6  FROM match
  UNION ALL SELECT match_api_id, date, 'A', away_player_7  FROM match
  UNION ALL SELECT match_api_id, date, 'A', away_player_8  FROM match
  UNION ALL SELECT match_api_id, date, 'A', away_player_9  FROM match
  UNION ALL SELECT match_api_id, date, 'A', away_player_10 FROM match
  UNION ALL SELECT match_api_id, date, 'A', away_player_11 FROM match
),
-- 2) Для каждой пары (match, player) берём ПОСЛЕДНИЙ overall_rating до даты матча
-- Замена DISTINCT ON на GROUP BY с MAX(date)
latest_attr AS (
  SELECT p.match_api_id, p.side, pa.overall_rating
  FROM players p
  JOIN player_attributes pa
    ON pa.player_api_id = p.player_id
   AND pa.date <= p.match_date
  WHERE pa.date = (
    SELECT MAX(pa2.date)
    FROM player_attributes pa2
    WHERE pa2.player_api_id = p.player_id
      AND pa2.date <= p.match_date
  )
),
-- 3) Средний рейтинг по сторонам матча (замена FILTER на CASE WHEN)
overalls AS (
  SELECT match_api_id,
         AVG(CASE WHEN side = 'H' THEN overall_rating END) AS home_overall_rating,
         AVG(CASE WHEN side = 'A' THEN overall_rating END) AS away_overall_rating
  FROM latest_attr
  GROUP BY match_api_id
),
-- 4) Счётчики верхнего уровня из XML
xml_counts AS (
  SELECT
    m.match_api_id,
    NULLIF((length(coalesce(m.shoton,''))     - length(replace(coalesce(m.shoton,''),     '<value>',''))) / length('<value>'), 0) AS shoton_cnt,
    NULLIF((length(coalesce(m.shotoff,''))    - length(replace(coalesce(m.shotoff,''),    '<value>',''))) / length('<value>'), 0) AS shotoff_cnt,
    NULLIF((length(coalesce(m.foulcommit,'')) - length(replace(coalesce(m.foulcommit,''), '<value>',''))) / length('<value>'), 0) AS foulcommit_cnt,
    NULLIF((length(coalesce(m.card,''))       - length(replace(coalesce(m.card,''),       '<value>',''))) / length('<value>'), 0) AS card_cnt,
    NULLIF((length(coalesce(m.cross,''))      - length(replace(coalesce(m.cross,''),      '<value>',''))) / length('<value>'), 0) AS cross_cnt,
    NULLIF((length(coalesce(m.corner,''))     - length(replace(coalesce(m.corner,''),     '<value>',''))) / length('<value>'), 0) AS corner_cnt,
    NULLIF((length(coalesce(m.possession,'')) - length(replace(coalesce(m.possession,''), '<value>',''))) / length('<value>'), 0) AS possession_cnt
  FROM match m
),
-- 5) Вероятности из коэффициентов (нормировка 1/odds / сумма(1/odds))
odds_pct AS (
  SELECT
    m.match_api_id,
    -- Bet365
    CASE WHEN m.b365h IS NOT NULL AND m.b365d IS NOT NULL AND m.b365a IS NOT NULL
      THEN (1.0/m.b365h)/((1.0/m.b365h)+(1.0/m.b365d)+(1.0/m.b365a)) END AS b365_home_pct,
    CASE WHEN m.b365h IS NOT NULL AND m.b365d IS NOT NULL AND m.b365a IS NOT NULL
      THEN (1.0/m.b365d)/((1.0/m.b365h)+(1.0/m.b365d)+(1.0/m.b365a)) END AS b365_draw_pct,
    CASE WHEN m.b365h IS NOT NULL AND m.b365d IS NOT NULL AND m.b365a IS NOT NULL
      THEN (1.0/m.b365a)/((1.0/m.b365h)+(1.0/m.b365d)+(1.0/m.b365a)) END AS b365_away_pct,
    -- Bet&Win (BW)
    CASE WHEN m.bwh IS NOT NULL AND m.bwd IS NOT NULL AND m.bwa IS NOT NULL
      THEN (1.0/m.bwh)/((1.0/m.bwh)+(1.0/m.bwd)+(1.0/m.bwa)) END AS bw_home_pct,
    CASE WHEN m.bwh IS NOT NULL AND m.bwd IS NOT NULL AND m.bwa IS NOT NULL
      THEN (1.0/m.bwd)/((1.0/m.bwh)+(1.0/m.bwd)+(1.0/m.bwa)) END AS bw_draw_pct,
    CASE WHEN m.bwh IS NOT NULL AND m.bwd IS NOT NULL AND m.bwa IS NOT NULL
      THEN (1.0/m.bwa)/((1.0/m.bwh)+(1.0/m.bwd)+(1.0/m.bwa)) END AS bw_away_pct,
    -- Interwetten (IW)
    CASE WHEN m.iwh IS NOT NULL AND m.iwd IS NOT NULL AND m.iwa IS NOT NULL
      THEN (1.0/m.iwh)/((1.0/m.iwh)+(1.0/m.iwd)+(1.0/m.iwa)) END AS iw_home_pct,
    CASE WHEN m.iwh IS NOT NULL AND m.iwd IS NOT NULL AND m.iwa IS NOT NULL
      THEN (1.0/m.iwd)/((1.0/m.iwh)+(1.0/m.iwd)+(1.0/m.iwa)) END AS iw_draw_pct,
    CASE WHEN m.iwh IS NOT NULL AND m.iwd IS NOT NULL AND m.iwa IS NOT NULL
      THEN (1.0/m.iwa)/((1.0/m.iwh)+(1.0/m.iwd)+(1.0/m.iwa)) END AS iw_away_pct,
    -- Ladbrokes (LB)
    CASE WHEN m.lbh IS NOT NULL AND m.lbd IS NOT NULL AND m.lba IS NOT NULL
      THEN (1.0/m.lbh)/((1.0/m.lbh)+(1.0/m.lbd)+(1.0/m.lba)) END AS lb_home_pct,
    CASE WHEN m.lbh IS NOT NULL AND m.lbd IS NOT NULL AND m.lba IS NOT NULL
      THEN (1.0/m.lbd)/((1.0/m.lbh)+(1.0/m.lbd)+(1.0/m.lba)) END AS lb_draw_pct,
    CASE WHEN m.lbh IS NOT NULL AND m.lbd IS NOT NULL AND m.lba IS NOT NULL
      THEN (1.0/m.lba)/((1.0/m.lbh)+(1.0/m.lbd)+(1.0/m.lba)) END AS lb_away_pct,
    -- Pinnacle Sports (PS)
    CASE WHEN m.psh IS NOT NULL AND m.psd IS NOT NULL AND m.psa IS NOT NULL
      THEN (1.0/m.psh)/((1.0/m.psh)+(1.0/m.psd)+(1.0/m.psa)) END AS ps_home_pct,
    CASE WHEN m.psh IS NOT NULL AND m.psd IS NOT NULL AND m.psa IS NOT NULL
      THEN (1.0/m.psd)/((1.0/m.psh)+(1.0/m.psd)+(1.0/m.psa)) END AS ps_draw_pct,
    CASE WHEN m.psh IS NOT NULL AND m.psd IS NOT NULL AND m.psa IS NOT NULL
      THEN (1.0/m.psa)/((1.0/m.psh)+(1.0/m.psd)+(1.0/m.psa)) END AS ps_away_pct,
    -- William Hill (WH)
    CASE WHEN m.whh IS NOT NULL AND m.whd IS NOT NULL AND m.wha IS NOT NULL
      THEN (1.0/m.whh)/((1.0/m.whh)+(1.0/m.whd)+(1.0/m.wha)) END AS wh_home_pct,
    CASE WHEN m.whh IS NOT NULL AND m.whd IS NOT NULL AND m.wha IS NOT NULL
      THEN (1.0/m.whd)/((1.0/m.whh)+(1.0/m.whd)+(1.0/m.wha)) END AS wh_draw_pct,
    CASE WHEN m.whh IS NOT NULL AND m.whd IS NOT NULL AND m.wha IS NOT NULL
      THEN (1.0/m.wha)/((1.0/m.whh)+(1.0/m.whd)+(1.0/m.wha)) END AS wh_away_pct,
    -- Stan James (SJ)
    CASE WHEN m.sjh IS NOT NULL AND m.sjd IS NOT NULL AND m.sja IS NOT NULL
      THEN (1.0/m.sjh)/((1.0/m.sjh)+(1.0/m.sjd)+(1.0/m.sja)) END AS sj_home_pct,
    CASE WHEN m.sjh IS NOT NULL AND m.sjd IS NOT NULL AND m.sja IS NOT NULL
      THEN (1.0/m.sjd)/((1.0/m.sjh)+(1.0/m.sjd)+(1.0/m.sja)) END AS sj_draw_pct,
    CASE WHEN m.sjh IS NOT NULL AND m.sjd IS NOT NULL AND m.sja IS NOT NULL
      THEN (1.0/m.sja)/((1.0/m.sjh)+(1.0/m.sjd)+(1.0/m.sja)) END AS sj_away_pct,
    -- VC Bet (VC)
    CASE WHEN m.vch IS NOT NULL AND m.vcd IS NOT NULL AND m.vca IS NOT NULL
      THEN (1.0/m.vch)/((1.0/m.vch)+(1.0/m.vcd)+(1.0/m.vca)) END AS vc_home_pct,
    CASE WHEN m.vch IS NOT NULL AND m.vcd IS NOT NULL AND m.vca IS NOT NULL
      THEN (1.0/m.vcd)/((1.0/m.vch)+(1.0/m.vcd)+(1.0/m.vca)) END AS vc_draw_pct,
    CASE WHEN m.vch IS NOT NULL AND m.vcd IS NOT NULL AND m.vca IS NOT NULL
      THEN (1.0/m.vca)/((1.0/m.vch)+(1.0/m.vcd)+(1.0/m.vca)) END AS vc_away_pct,
    -- Gamebookers (GB)
    CASE WHEN m.gbh IS NOT NULL AND m.gbd IS NOT NULL AND m.gba IS NOT NULL
      THEN (1.0/m.gbh)/((1.0/m.gbh)+(1.0/m.gbd)+(1.0/m.gba)) END AS gb_home_pct,
    CASE WHEN m.gbh IS NOT NULL AND m.gbd IS NOT NULL AND m.gba IS NOT NULL
      THEN (1.0/m.gbd)/((1.0/m.gbh)+(1.0/m.gbd)+(1.0/m.gba)) END AS gb_draw_pct,
    CASE WHEN m.gbh IS NOT NULL AND m.gbd IS NOT NULL AND m.gba IS NOT NULL
      THEN (1.0/m.gba)/((1.0/m.gbh)+(1.0/m.gbd)+(1.0/m.gba)) END AS gb_away_pct,
    -- Blue Square (BS)
    CASE WHEN m.bsh IS NOT NULL AND m.bsd IS NOT NULL AND m.bsa IS NOT NULL
      THEN (1.0/m.bsh)/((1.0/m.bsh)+(1.0/m.bsd)+(1.0/m.bsa)) END AS bs_home_pct,
    CASE WHEN m.bsh IS NOT NULL AND m.bsd IS NOT NULL AND m.bsa IS NOT NULL
      THEN (1.0/m.bsd)/((1.0/m.bsh)+(1.0/m.bsd)+(1.0/m.bsa)) END AS bs_draw_pct,
    CASE WHEN m.bsh IS NOT NULL AND m.bsd IS NOT NULL AND m.bsa IS NOT NULL
      THEN (1.0/m.bsa)/((1.0/m.bsh)+(1.0/m.bsd)+(1.0/m.bsa)) END AS bs_away_pct
  FROM match m
)
SELECT
  -- базовое
  m.season, m.date,
  m.home_team_goal, m.away_team_goal,
  -- средние рейтинги команд
  ov.home_overall_rating, ov.away_overall_rating,
  -- имена команд
  ht.team_long_name  AS home_team_long_name,
  ht.team_short_name AS home_team_short_name,
  at.team_long_name  AS away_team_long_name,
  at.team_short_name AS away_team_short_name,
  -- события из XML
  x.shoton_cnt, x.shotoff_cnt, x.foulcommit_cnt, x.card_cnt, x.cross_cnt, x.corner_cnt, x.possession_cnt,
  -- проценты букмекеров
  o.b365_home_pct, o.b365_draw_pct, o.b365_away_pct,
  o.bw_home_pct,   o.bw_draw_pct,   o.bw_away_pct,
  o.iw_home_pct,   o.iw_draw_pct,   o.iw_away_pct,
  o.lb_home_pct,   o.lb_draw_pct,   o.lb_away_pct,
  o.ps_home_pct,   o.ps_draw_pct,   o.ps_away_pct,
  o.wh_home_pct,   o.wh_draw_pct,   o.wh_away_pct,
  o.sj_home_pct,   o.sj_draw_pct,   o.sj_away_pct,
  o.vc_home_pct,   o.vc_draw_pct,   o.vc_away_pct,
  o.gb_home_pct,   o.gb_draw_pct,   o.gb_away_pct,
  o.bs_home_pct,   o.bs_draw_pct,   o.bs_away_pct,
  -- техполя в конце
  m.home_team_api_id, m.away_team_api_id,
  l.id AS league_id, l.name AS league_name,
  c.id AS country_id, c.name AS country_name,
  m.match_api_id
FROM match m
LEFT JOIN overalls   ov ON ov.match_api_id = m.match_api_id
LEFT JOIN xml_counts x  ON x.match_api_id  = m.match_api_id
LEFT JOIN odds_pct   o  ON o.match_api_id  = m.match_api_id
LEFT JOIN team       ht ON ht.team_api_id  = m.home_team_api_id
LEFT JOIN team       at ON at.team_api_id  = m.away_team_api_id
LEFT JOIN league     l  ON l.id            = m.league_id
LEFT JOIN country    c  ON c.id            = l.country_id;
