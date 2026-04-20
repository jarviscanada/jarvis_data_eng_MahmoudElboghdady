-- 
-- Modifying Data
-- 

-- Insert a new facility
INSERT INTO cd.facilities
  (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
VALUES
  (9, 'Spa', 20, 30, 100000, 800);

-- Insert using SELECT to auto-generate facid
INSERT INTO cd.facilities
  (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
SELECT
  (SELECT MAX(facid) FROM cd.facilities) + 1,
  'Spa', 20, 30, 100000, 800;

-- Fix the initial outlay for the second tennis court
UPDATE cd.facilities
SET initialoutlay = 10000
WHERE facid = 1;

-- Increase second tennis court costs by 10% based on first court values
UPDATE cd.facilities
SET membercost = (SELECT membercost * 1.1 FROM cd.facilities WHERE facid = 0),
    guestcost  = (SELECT guestcost  * 1.1 FROM cd.facilities WHERE facid = 0)
WHERE facid = 1;

-- Delete all bookings
DELETE FROM cd.bookings;

-- Delete a specific member by memid
DELETE FROM cd.members
WHERE memid = 37;


-- 
-- Basics
-- 

-- Facilities where member cost is less than 1/50th of monthly maintenance
SELECT
  facid,
  name,
  membercost,
  monthlymaintenance
FROM
  cd.facilities
WHERE
  membercost > 0
  AND membercost < monthlymaintenance / 50;

-- Facilities with 'Tennis' in the name
SELECT
  *
FROM
  cd.facilities
WHERE
  name LIKE '%Tennis%';

-- Facilities with facid 1 or 5
SELECT
  *
FROM
  cd.facilities
WHERE
  facid IN (1, 5);

-- Members who joined on or after 2012-09-01
SELECT
  memid,
  surname,
  firstname,
  joindate
FROM
  cd.members
WHERE
  joindate >= '2012-09-01';

-- Combined list of member surnames and facility names using UNION
SELECT
  surname
FROM
  cd.members
UNION
SELECT
  name
FROM
  cd.facilities;


-- 
-- Joins
-- 

-- Start times for bookings by David Farrell
SELECT
  bks.starttime
FROM
  cd.bookings bks
  JOIN cd.members mems ON mems.memid = bks.memid
WHERE
  mems.firstname = 'David'
  AND mems.surname = 'Farrell';

-- Start times for tennis court bookings on 2012-09-21
SELECT
  bks.starttime AS start,
  facs.name
FROM
  cd.bookings bks
  JOIN cd.facilities facs ON facs.facid = bks.facid
WHERE
  facs.name IN ('Tennis Court 1', 'Tennis Court 2')
  AND bks.starttime >= '2012-09-21'
  AND bks.starttime < '2012-09-22'
ORDER BY
  bks.starttime;

-- Each member alongside their recommender using a LEFT JOIN self-join
SELECT
  mems.firstname AS memfname,
  mems.surname   AS memsname,
  recs.firstname AS recfname,
  recs.surname   AS recsname
FROM
  cd.members mems
  LEFT JOIN cd.members recs ON recs.memid = mems.recommendedby
ORDER BY
  memsname,
  memfname;

-- Members who have recommended at least one other member
SELECT DISTINCT
  recs.firstname,
  recs.surname
FROM
  cd.members mems
  JOIN cd.members recs ON recs.memid = mems.recommendedby
ORDER BY
  recs.surname,
  recs.firstname;

-- Each member with their recommender using a correlated subquery
SELECT DISTINCT
  mems.firstname || ' ' || mems.surname AS member,
  (
    SELECT recs.firstname || ' ' || recs.surname
    FROM cd.members recs
    WHERE recs.memid = mems.recommendedby
  ) AS recommender
FROM
  cd.members mems
ORDER BY
  member;


-- 
-- Aggregation
-- 

-- Number of recommendations made by each member
SELECT
  recommendedby,
  COUNT(*) AS count
FROM
  cd.members
WHERE
  recommendedby IS NOT NULL
GROUP BY
  recommendedby
ORDER BY
  recommendedby;

-- Total slots booked per facility
SELECT
  facid,
  SUM(slots) AS "Total Slots"
FROM
  cd.bookings
GROUP BY
  facid
ORDER BY
  facid;

-- Total slots booked per facility in September 2012
SELECT
  facid,
  SUM(slots) AS "Total Slots"
FROM
  cd.bookings
WHERE
  starttime >= '2012-09-01'
  AND starttime < '2012-10-01'
GROUP BY
  facid
ORDER BY
  SUM(slots);

-- Total slots per facility per month in 2012
SELECT
  facid,
  EXTRACT(MONTH FROM starttime) AS month,
  SUM(slots) AS "Total Slots"
FROM
  cd.bookings
WHERE
  starttime >= '2012-01-01'
  AND starttime < '2013-01-01'
GROUP BY
  facid,
  month
ORDER BY
  facid,
  month;

-- Count of distinct members who made at least one booking
SELECT
  COUNT(DISTINCT memid) AS count
FROM
  cd.bookings;

-- Each member's name, id, and first booking after 2012-09-01
SELECT
  mems.surname,
  mems.firstname,
  mems.memid,
  MIN(bks.starttime) AS starttime
FROM
  cd.members mems
  JOIN cd.bookings bks ON mems.memid = bks.memid
WHERE
  bks.starttime >= '2012-09-01'
GROUP BY
  mems.surname,
  mems.firstname,
  mems.memid
ORDER BY
  mems.memid;

-- Total member count in every row using a window function
SELECT
  COUNT(*) OVER () AS count,
  firstname,
  surname
FROM
  cd.members
ORDER BY
  joindate;

-- Monotonically increasing row number ordered by join date
SELECT
  ROW_NUMBER() OVER (ORDER BY joindate) AS row_number,
  firstname,
  surname
FROM
  cd.members
ORDER BY
  joindate;

-- Facility with the highest number of slots booked, including ties
SELECT
  facid,
  total
FROM (
  SELECT
    facid,
    SUM(slots) AS total,
    RANK() OVER (ORDER BY SUM(slots) DESC) AS rank
  FROM
    cd.bookings
  GROUP BY
    facid
) ranked
WHERE
  rank = 1;


-- 
-- String
-- 

-- Format member name as 'Surname, Firstname'
SELECT
  surname || ', ' || firstname AS name
FROM
  cd.members;

-- Members with parentheses in their telephone number
SELECT
  memid,
  telephone
FROM
  cd.members
WHERE
  telephone ~ '[()]'
ORDER BY
  memid;

-- Count of members grouped by first letter of surname
SELECT
  SUBSTR(surname, 1, 1) AS letter,
  COUNT(*) AS count
FROM
  cd.members
GROUP BY
  letter
ORDER BY
  letter;

