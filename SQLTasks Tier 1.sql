/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */*/

SELECT DISTINCT name
FROM `Facilities`
WHERE membercost >0;

/* Q2: How many facilities do not charge a fee to members? */
SELECT DISTINCT COUNT( name )
FROM `Facilities`
WHERE membercost =0;

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT DISTINCT facid, name, membercost, monthlymaintenance
FROM `Facilities`
WHERE membercost >0
AND membercost < monthlymaintenance * 0.2

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
SELECT *
FROM `Facilities`
WHERE facid
IN ( 1, 5 )

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
SELECT name, monthlymaintenance,
CASE
	WHEN monthlymaintenance > 100 THEN 'expensive'
	ELSE 'cheap'
END AS CheapOrExpensive
FROM `Facilities`;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
SELECT DISTINCT firstname, surname
FROM `Members`
WHERE joindate = (SELECT MAX(joindate) FROM `Members`);

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT DISTINCT 
	Facilities.name, CONCAT(Members.firstname, ' ', Members.surname) AS fullname
FROM 
	`Bookings` , `Facilities` , `Members`
WHERE 
	(Bookings.memid = Members.memid AND Bookings.facid = Facilities.facid)	
	AND (Facilities.name LIKE 'Tennis%')
ORDER BY 
	fullname, Facilities.name;

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT Facilities.name, CONCAT(Members.firstname, ' ', Members.surname) AS fullname,
CASE
	WHEN Members.memid =0 THEN Facilities.guestcost * Bookings.slots
	ELSE Facilities.membercost * Bookings.slots
END AS TotalCost
FROM `Bookings` , `Facilities` , `Members`
WHERE 
	(Bookings.memid = Members.memid AND Bookings.facid = Facilities.facid)
	AND (Bookings.starttime LIKE '2012-09-14%')
	AND (CASE
		WHEN Members.memid =0
			THEN Facilities.guestcost * Bookings.slots
			ELSE Facilities.membercost * Bookings.slots
		END >30)
ORDER BY TotalCost DESC;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT joined.name, CONCAT(firstname, ' ', surname) AS fullname, joined.TotalCost 
    FROM Members
    INNER JOIN 
	(SELECT name, memid,
	CASE
		WHEN memid = 0 THEN guestcost*slots
     	ELSE membercost * slots
	END AS TotalCost
    FROM Bookings
    INNER JOIN Facilities
    ON Bookings.facid = Facilities.facid
    WHERE starttime LIKE '2012-09-14%') AS joined
    ON Members.memid = joined.memid
WHERE joined.TotalCost > 30
ORDER BY joined.TotalCost DESC; 

/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 
QUESTIONS:*/*/
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT name, 
       SUM(CASE WHEN memid = 0 THEN guestcost ELSE membercost END) AS revenue
FROM Facilities
INNER JOIN Bookings
USING (facid)
GROUP BY name
ORDER BY revenue
LIMIT 4;

Results:
('Table Tennis', 90)
('Snooker Table', 115)
('Pool Table', 265)
('Badminton Court', 604.5)

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
SELECT surname, firstname, recommendedby
        FROM Members
        ORDER BY surname, firstname

RESULTS:
11. Members and the member ID of who recommended them.
('Bader', 'Florence', '9')
('Baker', 'Anne', '9')
('Baker', 'Timothy', '13')
('Boothe', 'Tim', '3')
('Butters', 'Gerald', '1')
('Coplin', 'Joan', '16')
('Crumpet', 'Erica', '2')
('Dare', 'Nancy', '4')
('Farrell', 'David', '')
('Farrell', 'Jemima', '')
('GUEST', 'GUEST', '')
('Genting', 'Matthew', '5')
('Hunt', 'John', '30')
('Jones', 'David', '4')
('Jones', 'Douglas', '11')
('Joplette', 'Janice', '1')
('Mackenzie', 'Anna', '1')
('Owen', 'Charles', '1')
('Pinker', 'David', '13')
('Purview', 'Millicent', '2')
('Rownam', 'Tim', '')
('Rumney', 'Henrietta', '20')
('Sarwin', 'Ramnaresh', '15')
('Smith', 'Darren', '')
('Smith', 'Darren', '')
('Smith', 'Jack', '1')
('Smith', 'Tracy', '')
('Stibbons', 'Ponder', '6')
('Tracy', 'Burton', '')
('Tupperware', 'Hyacinth', '')
('Worthington-Smyth', 'Henry', '2')

/* Q12: Find the facilities with their usage by member, but not guests */
SELECT name, 
       COUNT(
           CASE 
               WHEN memid > 0 THEN 1 
               ELSE NULL 
           END
       ) AS facility_usage
FROM Facilities AS f
INNER JOIN Bookings USING (facid)
GROUP BY name
ORDER BY facility_usage DESC;

RESULTS:
12. Facilities and use by members.
('Pool Table', 783)
('Snooker Table', 421)
('Massage Room 1', 421)
('Table Tennis', 385)
('Badminton Court', 344)
('Tennis Court 1', 308)
('Tennis Court 2', 276)
('Squash Court', 195)
('Massage Room 2', 27)

/* Q13: Find the facilities usage by month, but not guests */
SELECT name, 
       DATE_FORMAT(starttime, '%m') AS month, 
       COUNT(
           CASE 
               WHEN memid > 0 THEN 1 
               ELSE NULL 
           END
       ) AS `usage`
FROM Facilities AS f
INNER JOIN Bookings USING (facid)
GROUP BY name, month
ORDER BY `usage` DESC;

RESULTS:
13. Facilities usage per month by members.
('Pool Table', '09', 408)
('Pool Table', '08', 272)
('Snooker Table', '09', 199)
('Table Tennis', '09', 194)
('Massage Room 1', '09', 191)
('Badminton Court', '09', 161)
('Snooker Table', '08', 154)
('Massage Room 1', '08', 153)
('Table Tennis', '08', 143)
('Badminton Court', '08', 132)
('Tennis Court 1', '09', 132)
('Tennis Court 2', '09', 126)
('Tennis Court 1', '08', 111)
('Tennis Court 2', '08', 109)
('Pool Table', '07', 103)
('Squash Court', '09', 87)
('Squash Court', '08', 85)
('Massage Room 1', '07', 77)
('Snooker Table', '07', 68)
('Tennis Court 1', '07', 65)
('Badminton Court', '07', 51)
('Table Tennis', '07', 48)
('Tennis Court 2', '07', 41)
('Squash Court', '07', 23)
('Massage Room 2', '09', 14)
('Massage Room 2', '08', 9)
('Massage Room 2', '07', 4)
