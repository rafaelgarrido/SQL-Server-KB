
-- Convert a UNIX timestamp field to Date

CONVERT( VARCHAR(10), DATEADD( s, <COLUMN_NAME>/1000, '01-01-1970'), 120)


-- UTC timespan
DECLARE @FIELD AS BIGINT
SET @FIELD = 1315009095883

-- Calculate date for UTC timespan with GMT
DECLARE @GMT AS BIGINT
SELECT @GMT = DATEDIFF(second, GETUTCDATE(), GETDATE())
SELECT DATEADD(second, @GMT, DATEADD(second, @FIELD / 1000, '1970-01-01 00:00:00')) AS [GMT]

-- Calculate date for UTC timespan without GMT
SELECT DATEADD(second, @FIELD / 1000, '1970-01-01 00:00:00') AS [UTC]

-- How to discover GMT from current machine
SELECT DATEDIFF(hour, GETUTCDATE(), GETDATE()) AS [GMT Hours], DATEDIFF(second, GETUTCDATE(), GETDATE()) AS [GMT Seconds]


