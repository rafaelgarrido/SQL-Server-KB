/*

This is a way keep a nice execution plan using the linkedserver.
It isolates the query in the remote server.


*/


SET NOCOUNT ON

CREATE TABLE #temp (
	[Account Number] varchar(50) NULL,
	[Amt] money NULL
	)

DECLARE @query1_Select VARCHAR(2000)
DECLARE @query2_OpenQuery VARCHAR(2300)
DECLARE @query3_InsertTemp VARCHAR(2400)

SELECT @query1_Select = 'SELECT [Account Number], [Amt] FROM Statement '
+ CHAR(13) + 'WHERE Country LIKE ''''USA'''' '

SELECT @query2_OpenQuery	= 'SELECT * FROM OPENQUERY(<LinkedServerName>, ''' + @query1_Select + ''')'
SELECT @query3_InsertTemp	= 'INSERT INTO #temp ' + @query2_OpenQuery
-- PRINT @query3_InsertTemp
EXEC (@query3_InsertTemp)
-- SELECT * FROM #temp

