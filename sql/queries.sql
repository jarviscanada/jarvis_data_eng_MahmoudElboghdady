-- =============================================================================
-- Modifying Data
-- =============================================================================

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

-- Update a member's telephone number
UPDATE cd.members
SET telephone = '(555) 555-5555'
WHERE memid = 0;

-- Update guest cost with a 10% increase for tennis courts
UPDATE cd.facilities
SET guestcost = guestcost * 1.1
WHERE facid IN (0, 1);

-- Delete all bookings
DELETE FROM cd.bookings;

-- Delete a specific member by memid
DELETE FROM cd.members
WHERE memid = 37;


-- =============================================================================
-- Basics
-- =============================================================================

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


-- =============================================================================
-- Joins
-- =============================================================================

-- Members who have booked a tennis court (name + facility)
SELECT
  mems.firstname,
  mems.surname,
  facs.name AS facility
FROM
  cd.members mems
  JOIN cd.bookings bks ON mems.memid = bks.memid
  JOIN cd.facilities facs ON bks.facid = facs.facid
WHERE
  facs.name IN ('Tennis Court 1', 'Tennis Court 2');

-- Bookings on 2012-09-14 where total cost exceeds 30
SELECT
  mems.firstname || ' ' || mems.surname AS member,
  facs.name AS facility,
  CASE
    WHEN mems.memid = 0 THEN bks.slots * facs.guestcost
    ELSE bks.slots * facs.membercost
  END AS cost
FROM
  cd.members mems
  JOIN cd.bookings bks ON mems.memid = bks.memid
  JOIN cd.facilities facs ON bks.facid = facs.facid
WHERE
  bks.starttime >= '2012-09-14'
  AND bks.starttime < '2012-09-15'
  AND (
    (mems.memid = 0 AND bks.slots * facs.guestcost > 30)
    OR (mems.memid != 0 AND bks.slots * facs.membercost > 30)
  )
ORDER BY
  cost DESC;

-- Each member alongside their recommender using a LEFT JOIN self-join
SELECT
  mems.firstname AS memfname,
  mems.surname AS memsname,
  recs.firstname AS recfname,
  recs.surname AS recsname
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

-- Each member with their recommender name using a correlated subquery
SELECT DISTINCT
  mems.firstname || ' ' || mems.surname AS member,
  (
    SELECT
      recs.firstname || ' ' || recs.surname
    FROM
      cd.members recs
    WHERE
      recs.memid = mems.recommendedby
  ) AS recommender
FROM
  cd.members mems
ORDER BY
  member;


-- =============================================================================
-- Aggregation
-- =============================================================================

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

-- Total slots booked per facility per month in 2012
SELECT
  facid,
  EXTRACT(MONTH FROM starttime) AS month,
  SUM(slots) AS "Total Slots"
FROM
  cd.bookings
WHERE
  EXTRACT(YEAR FROM starttime) = 2012
GROUP BY
  facid,
  month
ORDER BY
  facid,
  month;

-- Total slots per facility and month (multi-column group by)
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

-- Members with 3 or more bookings on tennis courts
SELECT
  mems.firstname || ' ' || mems.surname AS member,
  facs.name AS facility,
  COUNT(*) AS times
FROM
  cd.members mems
  JOIN cd.bookings bks ON mems.memid = bks.memid
  JOIN cd.facilities facs ON bks.facid = facs.facid
WHERE
  facs.name IN ('Tennis Court 1', 'Tennis Court 2')
GROUP BY
  member,
  facility
HAVING
  COUNT(*) >= 3
ORDER BY
  member,
  facility;

-- Running total of members using a window function
SELECT
  COUNT(*) OVER (ORDER BY joindate) AS count,
  firstname,
  surname
FROM
  cd.members
ORDER BY
  joindate;

-- Row number for each member ordered by join date
SELECT
  ROW_NUMBER() OVER (ORDER BY joindate) AS row_number,
  firstname,
  surname
FROM
  cd.members
ORDER BY
  joindate;

-- Top 3 facilities by total revenue
SELECT
  facs.name,
  SUM(
    CASE
      WHEN bks.memid = 0 THEN bks.slots * facs.guestcost
      ELSE bks.slots * facs.membercost
    END
  ) AS revenue
FROM
  cd.bookings bks
  JOIN cd.facilities facs ON bks.facid = facs.facid
GROUP BY
  facs.name
ORDER BY
  revenue DESC
LIMIT
  3;


-- =============================================================================
-- String
-- =============================================================================

-- Format member name as 'Surname, Firstname'
SELECT
  surname || ', ' || firstname AS name
FROM
  cd.members;

-- Members whose surname starts with a vowel
SELECT
  *
FROM
  cd.members
WHERE
  surname ~ '^[aeiouAEIOU]';

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
