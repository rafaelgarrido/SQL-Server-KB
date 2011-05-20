/*
Script Function: This script is designed to help move logins from one SQL Server 2005 system
                            to another.  For example, if you wish to move an SQL Server and 
                            its databases from one server to another.  It creates a Transact-SQL 
                            script of both Windows and SQL Server Logins.  It copies the 
                            SID and Password for the SQL Server Logins.  The script also sets 
                            the appropriate Server Roles for all logins.  
Output:                The output is a file of Transact-SQL statements to add logins,
                             grant logins or deny logins based on settings in the source
                             SQL Server Master database. This script will not disable the SA account
Developed by Jeff Jones 
             JBJ Group. 
             
Disclaimer: This script is offered with no implied support nor has it been extensively tested.  
You should thoroughly review the script generated before applying it to your system.  
You can use this script for the intended purpose and also as a model for how you can use SQL 
to write scripts using a database table as the source. 

*/
USE MASTER
GO
SET NOCOUNT ON    -- Turn off Rows Affected Message in output script

SELECT  -- Create Windows Logins
		CHAR(13) + CHAR(10) + '-- ADD WINDOWS LOGIN ' + name  
		+ CHAR(13) + CHAR(10) + 'CREATE LOGIN ['
		+ name + '] FROM WINDOWS'
		+ CHAR(13) + CHAR(10) + CHAR(9) + 'WITH DEFAULT_DATABASE = [' 
		+ default_database_name + ']'
		+ CHAR(13) + CHAR(10) + CHAR(9) + ', DEFAULT_LANGUAGE = [' 
		+ default_language_name + ']'

FROM sys.server_principals
WHERE   name NOT IN ( 'builtin\administrators', 'nt authority\system', 'NT Authority\network service') 
	AND TYPE_DESC IN ('WINDOWS_LOGIN', 'WINDOWS_GROUP')
	AND name NOT LIKE '%\SQLServer2005MSFTEUser$%'
	AND name NOT LIKE '%\SQLServer2005MSSQLUser$%'
	AND name NOT LIKE '%\SQLServer2005SQLAgentUser$%'
UNION ALL

SELECT 
-- Create SQL Server logins
		CHAR(13) + CHAR(10) + '-- ADD SQL LOGIN ' + name  
		+ CHAR(13) + CHAR(10) + 'CREATE LOGIN ['
		+ name + ']'
		+ CHAR(13) + CHAR(10) + CHAR(9) + 'WITH PASSWORD = ' 
		+ coalesce(dbo.fn_varbintohexstr(password_hash), 'NULL') + ' HASHED' 
		+ CHAR(13) + CHAR(10) + CHAR(9) + ', DEFAULT_DATABASE = ['
		+ default_database_name + ']'
		+ CHAR(13) + CHAR(10) + CHAR(9) + ', DEFAULT_LANGUAGE = [' 
		+ default_language_name + ']'
		+ CHAR(13) + CHAR(10) + CHAR(9) + ', SID = '
		+ dbo.fn_varbintohexstr(sid) 
		+ CHAR(13) + CHAR(10) + CHAR(9) + ', CHECK_EXPIRATION = ' 
		+ CASE is_expiration_checked 
			WHEN 1 THEN 'ON' 
			WHEN 0 THEN 'OFF'
			ELSE ''
		  END	
		+ CHAR(13) + CHAR(10) + CHAR(9) + ', CHECK_POLICY = ' 
		+ CASE is_policy_checked 
			WHEN 1 THEN 'ON' 
			WHEN 0 THEN 'OFF'
			ELSE ''
		  END	
FROM sys.sql_logins
WHERE  name <> 'sa'
UNION ALL
-- Create sp_denylogin for Windows Login
SELECT  CHAR(13) + CHAR(10) + '-- Disable LOGIN ' + name  
		+ CHAR(13) + CHAR(10)  + 'ALTER LOGIN ['
		+ name + '] DISABLE'
FROM sys.server_principals
WHERE is_disabled = 1
  AND name <> 'sa' 
  AND name NOT IN ( 'builtin\administrators', 'nt authority\system', 'NT Authority\network service')
  AND name NOT LIKE '%\SQLServer2005MSFTEUser$%'
  AND name NOT LIKE '%\SQLServer2005MSSQLUser$%'
  AND name NOT LIKE '%\SQLServer2005SQLAgentUser$%'
UNION ALL
-- Create sp_addsrvrolemember 
SELECT  CHAR(13) + CHAR(10) + '-- ADD SERVER ROLE TO LOGIN ' + sp1.name  
		+ CHAR(13) + CHAR(10)  + 'exec sp_addsrvrolemember @loginame = ['
		+ sp1.name + ']'
		+ CHAR(13) + CHAR(10) + CHAR(9) + ', @rolename = ' + sp2.name
FROM sys.server_principals sp1
	INNER JOIN sys.server_role_members rm
		ON sp1.principal_id = rm.member_principal_id
	INNER JOIN sys.server_principals sp2
		ON rm.role_principal_id = sp2.principal_id
WHERE sp1.name <> 'sa' 
  AND sp1.name NOT IN ( 'builtin\administrators', 'nt authority\system', 'NT Authority\network service')
  AND sp1.name NOT LIKE '%\SQLServer2005MSFTEUser$%'
  AND sp1.name NOT LIKE '%\SQLServer2005MSSQLUser$%'
  AND sp1.name NOT LIKE '%\SQLServer2005SQLAgentUser$%'


