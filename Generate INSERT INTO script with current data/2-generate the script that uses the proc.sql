-- ***********************************************
--	*2. Run a query that generates the script that
--		will use the procedure just created.
-- ***********************************************

SELECT 'DECLARE @b TABLE (b VARCHAR(8000))'
UNION
SELECT 'DECLARE @query VARCHAR(8000)'
UNION
SELECT 'EXEC spGenerateDataInsertScript_TEMP ''' +  table_name + ''', @query OUTPUT; INSERT @b VALUES (@query); ' 
	FROM information_schema.tables where table_name like 'sam%' -- for this example we filter "Sam" tables
UNION
SELECT 'SELECT * from @b'

-- The result should look similar to this
/*
DECLARE @b TABLE (b VARCHAR(8000))
DECLARE @query VARCHAR(8000)
EXEC spGenerateDataInsertScript_TEMP 'SamApplication', @query OUTPUT; INSERT @b VALUES (@query); 
EXEC spGenerateDataInsertScript_TEMP 'SamAccount', @query OUTPUT; INSERT @b VALUES (@query); 
EXEC spGenerateDataInsertScript_TEMP 'SamGroup', @query OUTPUT; INSERT @b VALUES (@query); 
SELECT * from @b
*/
GO
