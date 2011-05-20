-- ***********************************************
--	1. Create procedure 
--		spGenerateDataInsertScript_TEMP
--		in the database.
-- ***********************************************
GO
CREATE PROC dbo.spGenerateDataInsertScript_TEMP
@TableName VARCHAR(100)
, @query VARCHAR(8000) OUTPUT
AS
/*
2008-08-18: Generates Insert script for the table specified.
2008-10-16: Fix. When data has ' sign. (apostrophe)
2009-12-09: Increase variable sizes
*/
SET NOCOUNT ON

DECLARE -- @TableName VARCHAR(100)
-- 		, 
@i INT
		, @j INT
		, @r VARCHAR(8000)
		, @insertClause VARCHAR(3000)
		, @valueClause VARCHAR(7000)
		, @TableHasIdentity BIT
SELECT @TableHasIdentity = OBJECTPROPERTY( OBJECT_ID(@TableName), 'TableHasIdentity')

DECLARE @a TABLE ( ID INT IDENTITY(1,1), [Order] INT, ColumnName VARCHAR(200), DataType VARCHAR(50)
				, IsNullable BIT, IsNumber BIT ) 

INSERT INTO @a
SELECT Ordinal_Position, Column_Name, Data_Type, CASE WHEN IS_Nullable = 'Yes' THEN 1 ELSE 0 END IsNullable
, CASE WHEN Data_Type = 'int' 
			OR Data_Type = 'float'
			OR Data_Type = 'decimal'
			OR Data_Type = 'numeric'
			OR Data_Type = 'bit'
		THEN 1 ELSE 0 END AS IsNumber 
FROM information_schema.columns WHERE table_name like @TableName ORDER BY Ordinal_Position

-- SELECT * FROM @a

SELECT @i = 1, @j = max(ID), @r = ' ', @insertClause = ' ', @valueClause = ' ' FROM @a 

WHILE @i <= @j 
BEGIN 
    SELECT @insertClause = @insertClause + '[' + ColumnName + ']' + CASE WHEN @i = @j THEN '' ELSE ', ' END FROM @a WHERE ID = @i 
	-- SELECT @insertClause

    SELECT @valueClause = @valueClause
		+ ' ISNULL( '
		+ CASE WHEN IsNumber = 1 
			THEN ' CONVERT( VARCHAR(50), ' 
-- 			ELSE ''''''''' + RTRIM(LTRIM(' 
			ELSE ''''''''' + REPLACE( RTRIM(LTRIM(' 
			END 
		+ '[' + ColumnName + ']' 
		+ CASE WHEN IsNumber = 1 
			THEN ')'
--			ELSE ')) + ''''''''' 
			ELSE ')), '''''''', '''''''''''') + ''''''''' 
			END 
		+ ', ''NULL'')'
		+ CASE WHEN @i = @j THEN '' ELSE ' + '', '' + ' END 
		FROM @a WHERE ID = @i 
	-- SELECT @valueClause

    SET @i = @i + 1 
END 

SELECT @r = 'SELECT '' INSERT INTO ' 
			+ @TableName + ' (' 
			+ @insertClause + ') VALUES ('' + ' 
			+ @valueClause + ' + '')'' FROM ' 
			+ @TableName
			-- + '; '

SELECT @r = CASE WHEN @TableHasIdentity = 1 
			THEN 'SELECT ''   SET IDENTITY_INSERT [' + @TableName + '] ON; '' UNION ' ELSE '' END
			+ @r
			+ CASE WHEN @TableHasIdentity = 1 
			THEN ' UNION SELECT '' SET IDENTITY_INSERT [' + @TableName + '] OFF; '' ' ELSE '' END

SELECT @query = @r
GO