# SQL Project

## Introduction

This project is a structured set of SQL exercises built on top of a PostgreSQL
database representing a fictional sports club. The database tracks members,
facility bookings, and facility details across three related tables. I worked
through queries covering everything from basic filtering and UNION operations
to multi-table joins, self-joins, aggregation with GROUP BY and HAVING, window
functions, and string manipulation. The setup runs on a Rocky Linux 9 GCP
instance with PostgreSQL inside a Docker container. I used DBeaver as my SQL
IDE and managed all the work through Git with a Gitflow branching strategy.

## Quick Start

```bash
# Pull the PostgreSQL image and start a container
docker pull postgres
docker run --name sql-exercises \
  -e POSTGRES_PASSWORD=password \
  -p 5432:5432 -d postgres

# Load the sample data
psql -h localhost -U postgres -f sql/clubdata.sql -d postgres -x -q

# Connect and verify
psql -h localhost -p 5432 -U postgres -d exercises
\dt cd.*
```

---

## SQL Queries

### Table Setup (DDL)

```sql
CREATE TABLE cd.members (
  memid         INTEGER      NOT NULL,
  surname       VARCHAR(200) NOT NULL,
  firstname     VARCHAR(200) NOT NULL,
  address       VARCHAR(300) NOT NULL,
  zipcode       INTEGER      NOT NULL,
  telephone     VARCHAR(20)  NOT NULL,
  recommendedby INTEGER,
  joindate      TIMESTAMP    NOT NULL,
  CONSTRAINT members_pk PRIMARY KEY (memid),
  CONSTRAINT fk_members_recommendedby FOREIGN KEY (recommendedby)
    REFERENCES cd.members (memid)
);

CREATE TABLE cd.facilities (
  facid              INTEGER NOT NULL,
  name               VARCHAR(100) NOT NULL,
  membercost         NUMERIC NOT NULL,
  guestcost          NUMERIC NOT NULL,
  initialoutlay      NUMERIC NOT NULL,
  monthlymaintenance NUMERIC NOT NULL,
  CONSTRAINT facilities_pk PRIMARY KEY (facid)
);

CREATE TABLE cd.bookings (
  bookid    INTEGER   NOT NULL,
  facid     INTEGER   NOT NULL,
  memid     INTEGER   NOT NULL,
  starttime TIMESTAMP NOT NULL,
  slots     INTEGER   NOT NULL,
  CONSTRAINT bookings_pk PRIMARY KEY (bookid),
  CONSTRAINT fk_bookings_facid FOREIGN KEY (facid)
    REFERENCES cd.facilities (facid),
  CONSTRAINT fk_bookings_memid FOREIGN KEY (memid)
    REFERENCES cd.members (memid)
);
```

---

### Modifying Data

**Question 1: Insert a new facility**

```sql
INSERT INTO cd.facilities
  (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
VALUES
  (9, 'Spa', 20, 30, 100000, 800);
```

**Question 2: Insert using SELECT to auto-generate the primary key**

```sql
INSERT INTO cd.facilities
  (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
SELECT
  (SELECT MAX(facid) FROM cd.facilities) + 1,
  'Spa', 20, 30, 100000, 800;
```

**Question 3: Fix the initial outlay for the second tennis court**

```sql
UPDATE cd.facilities
SET initialoutlay = 10000
WHERE facid = 1;
```

**Question 4: Increase second tennis court costs by 10% based on first court**

```sql
UPDATE cd.facilities
SET membercost = (SELECT membercost * 1.1 FROM cd.facilities WHERE facid = 0),
    guestcost  = (SELECT guestcost  * 1.1 FROM cd.facilities WHERE facid = 0)
WHERE facid = 1;
```

**Question 5: Delete all bookings**

```sql
DELETE FROM cd.bookings;
```

**Question 6: Delete a specific member**

```sql
DELETE FROM cd.members
WHERE memid = 37;
```

---

### Basics

**Question 1: Facilities where member cost is under 1/50th of monthly maintenance**

```sql
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
```

**Question 2: Facilities with 'Tennis' in the name**

```sql
SELECT
  *
FROM
  cd.facilities
WHERE
  name LIKE '%Tennis%';
```

**Question 3: Retrieve specific facilities by ID**

```sql
SELECT
  *
FROM
  cd.facilities
WHERE
  facid IN (1, 5);
```

**Question 4: Members who joined on or after September 2012**

```sql
SELECT
  memid,
  surname,
  firstname,
  joindate
FROM
  cd.members
WHERE
  joindate >= '2012-09-01';
```

**Question 5: Combined list of member surnames and facility names**

```sql
SELECT surname FROM cd.members
UNION
SELECT name FROM cd.facilities;
```

---

### Joins

**Question 1: Start times for bookings by David Farrell**

```sql
SELECT
  bks.starttime
FROM
  cd.bookings bks
  JOIN cd.members mems ON mems.memid = bks.memid
WHERE
  mems.firstname = 'David'
  AND mems.surname = 'Farrell';
```

**Question 2: Start times for tennis court bookings on 2012-09-21**

```sql
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
```

**Question 3: Each member with their recommender using a self-join**

```sql
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
```

**Question 4: Members who have recommended at least one person**

```sql
SELECT DISTINCT
  recs.firstname,
  recs.surname
FROM
  cd.members mems
  JOIN cd.members recs ON recs.memid = mems.recommendedby
ORDER BY
  recs.surname,
  recs.firstname;
```

**Question 5: Members with their recommender using a correlated subquery**

```sql
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
```

---

### Aggregation

**Question 1: Number of recommendations per member**

```sql
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
```

**Question 2: Total slots booked per facility**

```sql
SELECT
  facid,
  SUM(slots) AS "Total Slots"
FROM
  cd.bookings
GROUP BY
  facid
ORDER BY
  facid;
```

**Question 3: Total slots per facility in September 2012**

```sql
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
```

**Question 4: Total slots per facility per month in 2012**

```sql
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
```

**Question 5: Count of distinct members with at least one booking**

```sql
SELECT
  COUNT(DISTINCT memid) AS count
FROM
  cd.bookings;
```

**Question 6: Each member's name, id, and first booking after 2012-09-01**

```sql
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
```

**Question 7: Total member count in every row using a window function**

```sql
SELECT
  COUNT(*) OVER () AS count,
  firstname,
  surname
FROM
  cd.members
ORDER BY
  joindate;
```

**Question 8: Monotonically increasing row number ordered by join date**

```sql
SELECT
  ROW_NUMBER() OVER (ORDER BY joindate) AS row_number,
  firstname,
  surname
FROM
  cd.members
ORDER BY
  joindate;
```

**Question 9: Facility with the highest number of slots booked, including ties**

```sql
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
```

---

### String

**Question 1: Format member names as 'Surname, Firstname'**

```sql
SELECT
  surname || ', ' || firstname AS name
FROM
  cd.members;
```

**Question 2: Members with parentheses in their telephone number**

```sql
SELECT
  memid,
  telephone
FROM
  cd.members
WHERE
  telephone ~ '[()]'
ORDER BY
  memid;
```

**Question 3: Count of members grouped by first letter of surname**

```sql
SELECT
  SUBSTR(surname, 1, 1) AS letter,
  COUNT(*) AS count
FROM
  cd.members
GROUP BY
  letter
ORDER BY
  letter;
```
