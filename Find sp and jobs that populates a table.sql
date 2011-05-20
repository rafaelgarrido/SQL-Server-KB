
/********************************************

The .Net Developers always ask me this query

********************************************/

-- Lists the objects in a database that contain a specific text

-- If you need to find the SP that appends data to the Customer table, use
-- ie.: ...LIKE '%INSERT%Customer%'

SELECT DISTINCT OBJECT_NAME(id) AS [Name] FROM syscomments WHERE TEXT LIKE '%<table name>%'


-- Lists the jobs which its steps contain a specific text

SELECT Name AS JobName FROM msdb.dbo.sysjobs j
JOIN msdb.dbo.sysjobsteps s ON j.job_id = s.job_id WHERE s.Command LIKE '%<table or sp name>%'


