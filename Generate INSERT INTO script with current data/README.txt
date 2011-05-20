
There is a nice free tool that does it:
www.ssmstoolspack.com


But I created this T-SQL based version:

-- *******************************************************************
		STEPS TO GENERATE "INSERT INTO xxxxxx VALUES yyyyyyy"

	0. Connect to the database to be scripted.
	1. Create procedure [spGenerateDataInsertScript_TEMP]
		in the database. See "1-spGenerateDataInsertScript_TEMP.sql"
	2. Run a query that generates the script that
		will use the procedure just created. 
		See "2-generate the script that uses the proc.sql"
		Remember to change the WHERE clause for the desired tables.
	3. Copy the result (generated script) and paste
		in a new Query Window.
	4. Sort the queries putting independent objects before
		the dependent ones and avoid FK violation.
		In case of multiple tables, of course.
	5. Certify that your result panel accepts 2000 characters
		or more, depend on the table you scan.
	6. The result, copy to another Query Window,
		add the "SET NOCOUNT ON" before the pasted code,
		set the result to come in TEXT instead of GRID
		and run it.
		This last result should be the desired script.
	7. Drop the procedure
		DROP PROC [spGenerateDataInsertScript_TEMP]
-- *******************************************************************



