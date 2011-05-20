
-- Convert a UNIX timestamp field to Date

CONVERT( VARCHAR(10), DATEADD( s, <COLUMN_NAME>/1000, '01-01-1970'), 120)


