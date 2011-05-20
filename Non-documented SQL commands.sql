
-- =====================================================================================

exec sp_MSForEachDB @command1='print ''?'' ' ,
                    @command2='DBCC CHECKDB (''?'')'

/*
The parameters are:

Parameter
 Required?
 Objective
 
@command1
 Yes
 First command to execute 
 
@command2
 No
 Second command to execute
 
@command3
 No
 Third command to execute
 
@replacechar
 No
 Character to be replaced by database name in @command1 2 and 3. The '?' is the default.

@precommand
 No
 What will be executed BEFORE @command1
 
@poscommand
 No
 What will be executed AFTER @command3
 
*/

-- =====================================================================================

EXEC sp_MSforeachTable @command1='print ''>>>Table: ?'''
		@command2='DBCC dbreindex (''?'')'

use NorthWind
go
EXEC sp_MSforeachTable @command1='print ''>>>Table: ?'' ', 
                 @command2='DBCC dbreindex (''?'')'
                 @whereand=' and left(name,2)=''Or'' '

-- =====================================================================================

use master
exec xp_RegRead 
                  'HKEY_LOCAL_MACHINE',
                  'SOFTWARE\Microsoft\Microsoft SQL Server\80\registration\',
                  'CD_KEY'
--
Value          Data
CD_KEY      XXXXX-YYYYY-ZZZZZ-YT9P5-DAG6F

-- =====================================================================================

exec master..xp_FileExist 'c:\autoexec.bat' 
--
File Exists         File is a Directory         Parent Directory Exists 
------------      ------------------         ------------------------
1                          0                                      1 

set nocount on
create table #file (file_exists bit, file_directory bit, parent_directory_exists bit)
insert into #file
exec master..xp_fileexist 'c:\autoexec.bat' 

if (select file_exists from #file) = 1
begin
    exec master..xp_CMDShell 'DTSRun ........'
end

-- =====================================================================================
