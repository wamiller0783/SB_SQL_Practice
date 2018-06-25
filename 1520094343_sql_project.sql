/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT
/* Retrieve name and membercost from Facilities table */
name,
membercost
FROM Facilities

/* Select entries where the cost to members is greater than zero */
WHERE membercost > 0;


/* Q2: How many facilities do not charge a fee to members? */

SELECT
/* Count entries in the Facilities table where the member cost equals 0 */
COUNT(CASE WHEN membercost=0 THEN 1 END) as no_cost_count
FROM Facilities;

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT
/* Retrieve facility ID, facility name, member cost, and monthly
maintenance fee entries from the Facilities table */
facid,
name as facility_name,
membercost,
monthlymaintenance
FROM Facilities
/* Select only entries where the member cost is both greater than zero
and less than 20% of the monthly maintenance cost */
WHERE membercost > 0 AND membercost <(0.20 * monthlymaintenance);

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT
/* Retrieve all entries from the Facilities table */
*
FROM Facilities
/* Select only those entries that have a facility ID in the list "1,5" */
WHERE facid IN (1,5);

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT
/* Retreive the name and monthly maintenance entries from the Facilities table */
name,
monthlymaintenance,

/* If the cost is less than or equal to 100, add the value "cheap" to new column
"maintenance_cost". Else, label it "expensive". */
(CASE WHEN monthlymaintenance <=100 THEN "cheap" ELSE "expensive" END) AS maintenance_cost

FROM Facilities;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT
/* Retrieve columns containing firstname and lastname */
firstname,
surname

/* Inner join members to a constructed table containing only the name of the
latest member to sign up */

FROM Members
INNER JOIN (

/* Select member with most recent join dat. Use memid to exclude guest entries. */
SELECT MIN(joindate) as recent_date
FROM Members
WHERE memid > 0
) AS recentdate
ON recentdate.recent_date = Members.joindate;

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT
/* Concatenate member lastname and firstname into a single column, formatted
"lastname, firstname". Use DISTINCT to avoid duplicate entries. */
DISTINCT CONCAT(surname, ', ', firstname) AS member_name,

/* Retrieve the facility name and assign column name court_name */
Facilities.name AS court_name

/* Join Members table to Bookings table on memid. Join the resulting table
to the Facilities table on facid. */
FROM Members
INNER JOIN Bookings ON Members.memid=Bookings.memid
INNER JOIN Facilities ON Bookings.facid=Facilities.facid

/* Select only the entries where the facility is a tennis court. */
WHERE Facilities.name LIKE 'Tennis Court%'
/* Order the results by member name, ascending. */
ORDER BY member_name ASC;

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT
/* Retrieve the facility name and assign column name facility_name */
Facilities.name AS facility_name,

/* Concatenate member lastname and firstname into a single column, formatted
"lastname, firstname" */
CONCAT(Members.surname, ', ', Members.firstname) as member_name,

/* When the member ID of 0 indicates that the booking is for a guest, multiply
the guestcost times the number of slots they have booked. If the member ID does
not correspond with a guest, multiply the member cost times slots booked. */

CASE WHEN Bookings.memid=0 THEN Facilities.guestcost*Bookings.slots
ELSE Facilities.membercost*Bookings.slots END AS total_cost

/* Join Bookings table to Facilties on facid, the join the resulting table to
members on memid.*/
FROM Bookings
INNER JOIN Facilities ON Bookings.facid=Facilities.facid
INNER JOIN Members ON Bookings.memid=Members.memid

/* Select only the entries for the date 2012-09-14, and only when the total cost
to guest or member is greater than $30 */
WHERE DATE_FORMAT(starttime, '%Y-%m-%d') = '2012-09-14'
AND (CASE WHEN Bookings.memid=0 THEN Facilities.guestcost*Bookings.slots
ELSE Facilities.membercost*Bookings.slots END) > 30

/* Order all results by total cost, descending */
ORDER BY total_cost DESC;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT
/* Perform operations on columns retrieved in subquery */
facility_name,
CONCAT(surname, ', ', firstname) AS member_name,
CASE WHEN memid=0 THEN guestcost*slots ELSE membercost*slots END AS total_cost

FROM
/* Use subquery to perform table joins and select columns to calculate final
output */
(SELECT
/* Columns needed for final output */
Facilities.name AS facility_name,
Members.surname as surname,
Members.firstname as firstname,
Members.memid AS memid,
Facilities.membercost AS membercost,
Facilities.guestcost AS guestcost,
Bookings.slots AS slots

/* Table joins */
FROM Bookings
INNER JOIN Facilities ON Bookings.facid=Facilities.facid
INNER JOIN Members ON Bookings.memid=Members.memid
WHERE DATE_FORMAT(starttime, '%Y-%m-%d') = '2012-09-14'
) sub

/* Return result of operations above where the total cost
to guest or member is greater than $30 */
WHERE (CASE WHEN memid=0 THEN guestcost*slots ELSE membercost*slots END) > 30

/* Order by total cost, descending */
ORDER BY total_cost DESC;

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT
/* Select facility name from subquery */
facility_name,

/* Calculate total revenue depending on whether a guest or member has
booked a facility, then sum the total revenue based on criteria to be
given below. */
SUM(CASE WHEN memid=0 THEN guestcost*slots
ELSE membercost*slots END) AS total_revenue

/* Join tables and retrieve columns necessary to calculate final output */
FROM (
SELECT
/* Retrieve columns */
Members.memid AS memid,
Facilities.name AS facility_name,
Facilities.guestcost AS guestcost,
Facilities.membercost AS membercost,
Bookings.slots AS slots

/* Join Bookings table to Facilties on facid, the join the resulting table to
members on memid. */
FROM Bookings
INNER JOIN Facilities ON Bookings.facid=Facilities.facid
INNER JOIN Members ON Bookings.memid=Members.memid
) sub

/* Sum total_revenue based on facility name */
GROUP BY facility_name

/* Only return summed total revenue values of less than $1000 */
HAVING total_revenue < 1000

/* Order the results by total revenue, descending */
ORDER BY total_revenue DESC;
