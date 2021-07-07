-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
CREATE VIEW q0(era) 
AS
  SELECT MAX(era)
  FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE weight > 300;
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear 
  FROM people
  WHERE namefirst LIKE '% %';
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height),  count(*)
  FROM people
  GROUP BY birthyear
  ORDER BY birthyear ASC;
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height),  count(*)
  FROM people
  GROUP BY birthyear
  HAVING AVG(height) > 70
  ORDER BY birthyear ASC
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid) 
AS
  SELECT p.namefirst, p.namelast, h.playerid, h.yearid
  FROM people AS p INNER JOIN HallOfFame AS h
  ON p.playerid = h.playerid 
  WHERE h.inducted = 'Y'
  ORDER BY h.yearid DESC, h.playerid
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT p.namefirst, p.namelast, h.playerid, c.schoolid, h.yearid
  FROM people AS p, HallOfFame AS h, Schools AS s, CollegePlaying AS c
  WHERE p.playerid = h.playerid AND h.inducted = 'Y' AND
        p.playerid = c.playerid AND c.schoolid = s.schoolid AND s.state = 'CA'
  ORDER BY h.yearid DESC, s.schoolid, p.playerid
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT h.playerid, p.namefirst, p.namelast, c.schoolid
  FROM people AS p INNER JOIN HallOfFame AS h ON p.playerid = h.playerid
    LEFT OUTER JOIN CollegePlaying AS c ON p.playerid = c.playerid
  WHERE h.inducted = 'Y'
  ORDER BY p.playerid DESC, c.schoolid
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT p.playerid, p.namefirst, p.namelast, b.yearid, 
    CAST(((h - h2b - h3b - hr + 2.0 * h2b + 3.0 * h3b + 4.0 * hr) / ab) AS FLOAT) AS slg
  FROM people AS p INNER JOIN Batting AS b ON p.playerid = b.playerid 
  WHERE b.ab > 50
  ORDER BY slg DESC, b.yearid, b.playerid
  LIMIT 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT p.playerid, p.namefirst, p.namelast, 
    CAST((SUM(h - h2b - h3b - hr + 2.0 * h2b + 3.0 * h3b + 4.0 * hr) / SUM(ab)) AS FLOAT) AS lslg
  FROM people AS p INNER JOIN Batting AS b ON p.playerid = b.playerid
  GROUP BY p.playerid
  HAVING SUM(ab) > 50
  ORDER BY lslg DESC, p.playerid
  LIMIT 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  WITH life AS (
    SELECT CAST((SUM(h - h2b - h3b - hr + 2.0 * h2b + 3.0 * h3b + 4.0 * hr) / SUM(ab)) AS FLOAT) AS lslg, playerid
    FROM Batting
    GROUP BY playerid
    HAVING SUM(ab) > 50
  )
  SELECT p.namefirst, p.namelast, l.lslg
  FROM life AS l INNER JOIN people AS p ON l.playerid = p.playerid
  WHERE l.lslg > (SELECT lslg FROM life WHERE playerid = 'mayswi01')
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearid, MIN(salary), MAX(salary), AVG(salary)
  FROM Salaries
  GROUP BY yearid
  ORDER BY yearid;
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  WITH A(binid, low, high, width) AS
    (SELECT 0 AS binid, min, min + (max - min)/10, (max - min)/10
     FROM q4i WHERE yearid = '2016' UNION
     SELECT binid + 1, high, 
     CASE WHEN binid < 8 THEN high + width ELSE high + width + 1 END, width FROM A
     WHERE binid <= 9)
  SELECT binid, low, high, COUNT(*)
  FROM A INNER JOIN Salaries AS s ON s.salary >= A.low AND s.salary < A.high 
  WHERE yearid = '2016'
  GROUP BY binid, low, high
  ORDER BY binid
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  SELECT m.yearid, m.min - n.min, m.max - n.max, m.avg - n.avg
  FROM q4i AS m INNER JOIN q4i AS n ON m.yearid = n.yearid + 1
  ORDER BY m.yearid
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT p.playerid, p.namefirst, p.namelast, s.salary, s.yearid
  FROM people As p INNER JOIN Salaries AS s ON p.playerid = s.playerid 
  WHERE ((s.yearid = 2000 AND s.salary = (SELECT max(salary) FROM Salaries WHERE yearid = 2000)) 
    OR (s.yearid = 2001 AND s.salary = (SELECT max(salary) FROM Salaries WHERE yearid = 2001)))
;

-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  SELECT a.teamid, MAX(s.salary) - MIN(s.salary) AS diffAvg
  FROM AllstarFull AS a INNER JOIN Salaries AS s ON a.playerid = s.playerid
  WHERE a.yearid = 2016 AND s.yearid = 2016
  GROUP BY a.teamid
  ORDER BY a.teamid
;


