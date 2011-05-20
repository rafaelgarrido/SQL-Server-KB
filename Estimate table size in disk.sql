/*
Estimate size of a table in the disk. SQL 2000.
Create the table and the indexes you intend to use and run the procedure

CalcSpace '<table name>', <number of rows expected>
*/

CREATE PROCEDURE CalcSpace
/************************************************************************/
/* Stored Procedure: CalcSpace						*/
/* Creation Date: 1999-04-11						*/
/* Copyright: -								*/
/* Written by: Sharon Dooley						*/
/*									*/
/* Purpose: < ;Purpose of the script>					*/
/*	A procedure to estimate the disk space requirements of a table.	*/
/*	Refer to Books OnLine topic "Estimating the size of a table..." */
/*	for a detailed description					*/
/*									*/
/* Input Parameters: <list any input parameters>			*/
/*	@table_name	VARCHAR(30)	Name of table to estimate	*/
/*	@num_rows	INT		Number of rows in the table	*/
/*									*/
/* Output Parameters: <list any output parameters>			*/
/*	-								*/
/*									*/
/* Return Status: <list any return codes>				*/
/*	-								*/
/*									*/
/* Usage: <a sample usage statement>					*/
/*	EXEC CalcSpace 'MyTable', 10000					*/
/*									*/
/* Other info: <other info for this SP>					*/
/*	The is a direct copy from the CalcSpace stored procedure made by*/
/*	Sharon Dooley, 1999-04-11. The only change is the added 	*/
/*	documentation header and a small bug fix mentioned below.	*/
/*									*/
/* Updates: <this section is used to track changes to the script>	*/
/* Date 	Author 			Purpose				*/
/* 2000-07-04	Magnus Andersson	Changed @sysstat from tinyint 	*/
/* 					to int to prevent overflow 	*/
/* 					scenario. Added documentation.	*/
/* 									*/
/************************************************************************/

	(@table_name	varchar(30)=null,-- name of table to estimate 
	 @num_rows	int = 0)	 -- number of rows in the table 
as

declare @msg	varchar(120)

--	Give usage statement if @table_name is null

if @table_name = null or @num_rows = 0
begin
	print 'Usage is:'
	print '   calcspace table_name, no_of_rows'
	print 'where table_name is the name of the table,'
	print '      no_of_rows is the number of rows in the table,' 
	print ' '
	return
end

declare	@num_fixed_col				int,
	@fixed_data_size			int,
	@num_variable_col			int, 
	@max_var_size				int,
	@null_bitmap				int,
	@variable_data_size			int,
	@table_id				int,
	@num_pages				int,
	@table_size_in_bytes			int,
	@table_size_in_meg			real,
	@table_size_in_kbytes			real,
	@sysstat				int,
	@row_size				int,
	@rows_per_page				int,
	@free_rows_per_page			int,
	@fillfactor				int,
 	@num_fixed_ckey_cols 			int,
	@fixed_ckey_size 			int,
	@num_variable_ckey_cols 		int,
	@max_var_ckey_size 			int,
	@cindex_null_bitmap			int,
	@variable_ckey_size			int,
	@cindex_row_size			int,
	@cindex_rows_per_page			int,
	@data_space_used			int,
	@num_pages_clevel_0			int,
	@num_pages_clevel_1			int,
	@num_pages_clevel_x			int,
	@num_pages_clevel_y			int,
	@Num_CIndex_Pages			int,
	@clustered_index_size_in_bytes		int,
	@num_fixed_key_cols 			int,
	@fixed_key_size 			int,
	@num_variable_key_cols 			int,
	@max_var_key_size 			int,
	@index_null_bitmap			int,
	@variable_key_size			int,
	@nl_index_row_size			int,
	@nl_index_rows_per_page			int,
	@index_row_size				int,
	@index_rows_per_page			int,
	@free_index_rows_per_page		int,
	@num_pages_level_0			int,
	@num_pages_level_1			int,
	@num_pages_level_x			int,
	@num_pages_level_y			int,
	@num_index_pages			int,
	@nonclustered_index_size		int,
	@total_num_nonclustered_index_pages	int,
	@free_cindex_rows_per_page		int,
	@tot_pages				int
	
-- initialize variables
select	@num_fixed_col				=0,
	@fixed_data_size			=0,
	@num_variable_col			=0, 
	@max_var_size				=0,
	@null_bitmap				=0,
	@variable_data_size			=0,
	@table_id				=0,
	@num_pages				=0,
	@table_size_in_bytes			=0,
	@table_size_in_meg			=0,
	@table_size_in_kbytes			=0,
	@sysstat				=0,
	@row_size				=0,
	@rows_per_page				=0,
 	@num_fixed_ckey_cols 			=0,
	@fixed_ckey_size 			=0,
	@num_variable_ckey_cols 		=0,
	@max_var_ckey_size 			=0,
	@cindex_null_bitmap			=0,
	@variable_ckey_size			=0,
	@cindex_row_size			=0,
	@cindex_rows_per_page			=0,
	@data_space_used			=0,
	@num_pages_clevel_0			=0,
	@num_pages_clevel_1			=0,
	@Num_CIndex_Pages			=0,
	@clustered_index_size_in_bytes		=0,
	@num_fixed_key_cols 			=0,
	@fixed_key_size 			=0,
	@num_variable_key_cols 			=0,
	@max_var_key_size 			=0,
	@index_null_bitmap			=0,
	@variable_key_size			=0,
	@nl_index_row_size			=0,
	@nl_index_rows_per_page			=0,
	@index_row_size				=0,
	@index_rows_per_page			=0,
	@free_index_rows_per_page		=0,
	@num_pages_level_0			=0,
	@num_pages_level_1			=0,
	@num_pages_level_x			=0,
	@num_pages_level_y			=0,
	@num_index_pages			=0,
	@nonclustered_index_size		=0,
	@total_num_nonclustered_index_pages	=0,
	@free_cindex_rows_per_page		=0,
	@tot_pages				=0

set nocount on

--*********************************************
-- MAKE SURE TABLE EXISTS
--*********************************************

select  @sysstat = sysstat,
	@table_id = id
		from sysobjects where name = @table_name

if @sysstat & 7 not in (1,3)
begin
	select @msg = 'I can''t find the table '+@table_name
	print @msg
	return
end

--*********************************************
-- ESTIMATE SIZE OF TABLE
--*********************************************

-- get total number and total size of fixed-length columns

select 	@num_fixed_col = count(name), 
	@fixed_data_size = sum(length) 
	from 	syscolumns 
	where 	id= @table_id and xtype in 
		(
		select xtype from systypes where variable=0
		)

	if @num_fixed_col= 0 --@fixed_data_size is null.  change to 0
		select @fixed_data_size=0

-- get total number and total maximum size of variable-length columns

select 	@num_variable_col=count(name), 
	@max_var_size= sum(length) 
	from 	syscolumns 
	where 	id= @table_id and xtype in 
		(
		select xtype from systypes where variable=1
		)
	if @num_variable_col= 0 --@max_var_size is null.  change to 0
		select @max_var_size=0

-- get portion of the row used to manage column nullability

select @null_bitmap=2+((@num_fixed_col+7)/8)

-- determine space needed to store variable-length columns 
-- this assumes all variable length columns will be 100% full
if @num_variable_col = 0
	select @variable_data_size=0
else
	select @variable_data_size = 	2 + (@num_variable_col *2 )+ @max_var_size

-- get row size

select @row_size= 	@fixed_data_size + 
			@variable_data_size + 
			@null_bitmap + 4  -- 4 represents the data row header


-- get number of rows per page

select @rows_per_page = (8096) / (@row_size+2)

-- If a clustered index is to be created on the table, 
-- calculate the number of reserved free rows per page, 
-- based on the fill factor specified. 
-- If no clustered index is to be created, specify Fill_Factor as 100. 

select 	@fillfactor = 100 -- initialize it to the maximum
select 	@free_rows_per_page = 0  --initialize to no free rows/page
select 	@fillfactor=OrigFillFactor 
from 	sysindexes 
where 	id = @table_id and indid=1  -- indid of 1 means the index is clustered

if @fillfactor<>0
	-- a 0 fill factor ALMOST fills up the entire page, but not quite.
	--The doc says that fill factor zero leaves 2 empty rows (keys) 
	--in each index page and no free rows in data pages of clustered 
	--indexes and leaf pages of non-clustered. 
	--We are working on the data pages in this section
	select @free_rows_per_page=8096 * ((100-@fillfactor)/100)/@row_size

-- get number of pages needed to store all rows

select @num_pages = ceiling(convert(dec,@num_rows) / (@rows_per_page-@free_rows_per_page))

-- get storage needed for table data

select @data_space_used=8192*@num_pages


--*********************************************
-- COMPUTE SIZE OF CLUSTERED INDEX IF ONE EXISTS
--*********************************************

-- create a temporary table to contain columns in clustered index. System table
-- sysindexkeys has a list of the column numbers contained in the index

select colid into #col_list 
from sysindexkeys where id= @table_id and indid=1  -- indid=1 means clustered

if (select count(*) from #col_list) >0 -- do the following only if clustered index exsists
begin
	-- get total number and total maximum size of fixed-length columns in clustered index

	select 	@num_fixed_ckey_cols=count(name), 
		@fixed_ckey_size= sum(length) 
		from 	syscolumns 
		where 	id= @table_id and xtype in 
		(
		select xtype from systypes where variable=0
		) 
		and colid in (select * from #col_list)

	if @num_fixed_ckey_cols= 0 --@fixed_ckey_size is null.  change to 0
		select @fixed_ckey_size=0

	-- get total number and total maximum size of variable-length columns in clustered index

	select 	@num_variable_ckey_cols=count(name), 
		@max_var_ckey_size= sum(length) 
		from 	syscolumns 
		where 	id= @table_id and xtype in 
		(
		select xtype from systypes where variable=1
		) 
		and colid in (select * from #col_list)

	if @num_variable_ckey_cols= 0 --@max_var_ckey_size is null.  change to 0
		select @max_var_ckey_size=0

	-- If there are fixed-length columns in the clustered index, 
	-- a portion of the index row is reserved for the null bitmap. Calculate its size: 
	if @num_fixed_ckey_cols <> 0
		select @cindex_null_bitmap=2+((@num_fixed_ckey_cols + 7)/8) 
	else	
		select @cindex_null_bitmap=0

	-- If there are variable-length columns in the index, determine how much 
	-- space is used to store the columns within the index row: 
	
	if @num_variable_ckey_cols <> 0
		select @variable_ckey_size=2+(@num_variable_ckey_cols *2)+@max_var_ckey_size
	else	
		select @variable_ckey_size=0

	-- Calculate the index row size

	select @cindex_row_size=@fixed_ckey_size +@variable_ckey_size+@cindex_null_bitmap+1+8

	--Next, calculate the number of index rows per page (8096 free bytes per page): 

	select @cindex_rows_per_page=(8096)/(@cindex_row_size+2)

	-- consider fillfactor
	if @fillfactor=0
		select @free_cindex_rows_per_page = 2
	else
	 	select @free_cindex_rows_per_page= 8096 * ((100-@fillfactor)/100)/@cindex_row_size

	-- Next, calculate the number of pages required to store 
	-- all the index rows at each level of the index. 

	select @num_pages_clevel_0=ceiling(convert(decimal,(@data_space_used/8192))/(@cindex_rows_per_page-@free_cindex_rows_per_page))
	select @Num_CIndex_Pages=@num_pages_clevel_0
	select @num_pages_clevel_x=@num_pages_clevel_0

	while @num_pages_clevel_x <> 1
	begin
		select @num_pages_clevel_y=ceiling(convert(decimal,@num_pages_clevel_x)/(@cindex_rows_per_page-@free_cindex_rows_per_page))
		select @Num_CIndex_Pages=@Num_CIndex_Pages+@num_pages_clevel_y
		select @num_pages_clevel_x=@num_pages_clevel_y
	end
end

--*********************************************
-- END CLUSTERED INDEX SECTION
--*********************************************

--*********************************************
-- BEGIN NON-CLUSTERED INDEX SECTION
--*********************************************

-- create temp table with non-clustered index info

select indid, colid into #col_list2 
from sysindexkeys where id= @table_id and indid<>1 -- indid=1 means clustered

if (select count(*) from #col_list2) >0 -- do the following only if non-clustered indexes exsist
begin
	declare @i int  -- a counter variable
	select @i=1 -- initilize to 2, because 1 is id of clustered index

	while @i< 249 -- max number of non-clustered indexes
	begin
		select @i=@i+1 -- look for the next non-clustered index
		-- reinitialize all numbers
		select 	@num_fixed_key_cols = 0,
			@fixed_key_size = 0,
			@num_variable_key_cols = 0,
			@max_var_key_size = 0,
			@index_null_bitmap = 0,
			@variable_key_size = 0,
			@nl_index_row_size = 0,
			@nl_index_rows_per_page = 0,
			@index_row_size = 0,
			@index_rows_per_page = 0,
			@free_index_rows_per_page = 0,
			@num_pages_level_0 = 0,
			@num_pages_level_x = 0,
			@num_pages_level_y = 0,
			@Num_Index_Pages = 0

		-- get total number and total maximum size 
		-- of fixed-length columns in nonclustered index
		select 	@num_fixed_key_cols=count(name), 
			@fixed_key_size= sum(length) 
			from 	syscolumns 
			where 	id= @table_id and xtype in 
			(
			select xtype from systypes where variable=0
			) 
			and colid in (select colid from #col_list2 where indid=@i)
		if @num_fixed_key_cols= 0 --@fixed_key_size is null.  change to 0
			select @fixed_key_size=0

		-- get total number and total maximum size of variable-length columns in index

		select 	@num_variable_key_cols=count(name), 
			@max_var_key_size= sum(length) 
			from 	syscolumns 
			where 	id= @table_id and xtype in 
			(
			select xtype from systypes where variable=1
			) 
			and colid in  (select colid from #col_list2 where indid=@i)
		if @num_variable_key_cols= 0 --@max_var_key_size is null.  change to 0
			select @max_var_key_size=0

		if @num_fixed_key_cols = 0 and @num_variable_key_cols = 0 --there is no index
			continue
		-- If there are fixed-length columns in the non-clustered index, 
		-- a portion of the index row is reserved for the null bitmap. Calculate its size: 
		if @num_fixed_key_cols <> 0
			select @index_null_bitmap=2+((@num_fixed_key_cols + 7)/ 8)
		else	
			select @index_null_bitmap=0

		-- If there are variable-length columns in the index, determine how much 
		-- space is used to store the columns within the index row: 
	
		if @num_variable_key_cols <> 0
			select @variable_key_size=2+(@num_variable_key_cols *2)+@max_var_key_size
		else	
			select @variable_key_size=0

		-- Calculate the non-leaf index row size
		select @nl_index_row_size=@fixed_key_size +@variable_key_size+@index_null_bitmap+1+8

		--Next, calculate the number of non-leaf index rows per page (8096 free bytes per page): 

		select @nl_index_rows_per_page=(8096)/(@nl_index_row_size+2)

		-- Next, calculate the leaf index row size

		select @index_row_size=@cindex_row_size + @fixed_key_size + @variable_key_size+@index_null_bitmap+1

		-- Next, calculate the number of leaf level index rows per page

		select @index_rows_per_page = 8096/(@index_row_size + 2)

		-- Next, calcuate the number of reserved free index rows/page based on fill factor

		if @fillfactor=0
		-- a 0 fill factor ALMOST fills up the entire page, but not quite.
		--The doc says that fill factor zero leaves 2 empty rows (keys) 
		--in each index page and no free rows in data pages of clustered 
		--indexes and leaf pages of non-clustered. 
		--We are working on the non-clustered index pages in this section
			select @free_index_rows_per_page=0
		else
			select @free_index_rows_per_page= 8096 * ((100-@fillfactor)/100)/@index_row_size

		-- Next, calculate the number of pages required to store 
		-- all the index rows at each level of the index. 

		select @num_pages_level_0=ceiling(convert(decimal,@num_rows)/@index_rows_per_page-@free_index_rows_per_page)

		select @Num_Index_Pages=@num_pages_level_0
		select @num_pages_level_x=@num_pages_level_0

		while @num_pages_level_x <> 1
		begin
			select @num_pages_level_y=ceiling(convert(decimal,@num_pages_level_x)/@nl_index_rows_per_page)
			select @Num_Index_Pages=@Num_Index_Pages+@num_pages_level_y
			select @num_pages_level_x=@num_pages_level_y
		end

		select @total_num_nonclustered_index_pages=@total_num_nonclustered_index_pages+@Num_Index_Pages
	end
end
--*********************************************
-- END NON-CLUSTERED INDEX SECTION
--*********************************************
-- display numbers

select @tot_pages=@num_pages + @Num_CIndex_Pages + @total_num_nonclustered_index_pages
select @table_size_in_bytes= 8192*@tot_pages
select @table_size_in_kbytes= @table_size_in_bytes/1024.0
select @table_size_in_meg= str(@table_size_in_kbytes/1000.0,17,2)

select 	substring(@table_name,1,20) as 'Table Name',
	convert(varchar(10),@table_size_in_meg) as 'MB Estimate',
	@tot_pages as 'Total Pages',
	@num_pages as '#Data Pgs', 
	@Num_CIndex_Pages as '#Clustered Idx Pgs',
	@total_num_nonclustered_index_pages as '#NonClustered Idx Pgs'
