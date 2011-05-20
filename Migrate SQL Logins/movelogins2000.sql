/*
Script Function: This script is designed to help move logins from one SQL Server
                            to another.  For example, if you wish to move an SQL Server and 
                            its databases from one server to another.  It creates a Transact-SQL 
                            script of both Windows and SQL Server Logins.  It copies the 
                            SID and Password for the SQL Server Logins.  The script also sets 
                            the appropriate Server Roles for all logins.  
Output:                The output is a file of Transact-SQL statements to add logins,
                             grant logins or deny logins based on settings in the source
                             SQL Server Master database. 
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

SELECT 
CASE  	WHEN xstatus & 0x04 = 4 -- Create sp_grantlogin for Windows Logins
	THEN CHAR(13) + CHAR(10) + '-- ADD WINDOWS LOGIN ' + name  
		+ CHAR(13) + CHAR(10) + 'exec sp_grantlogin @loginame = ['
		+ name + ']'
		+ CHAR(13) + CHAR(10) + '-- ADD DEFAULT DB TO WINDOWS LOGIN ' + name  
		+ CHAR(13) + CHAR(10) + 'exec sp_defaultdb @loginame = ['
		+ name + ']'
		+ CHAR(13) + CHAR(10) + CHAR(9) + ', @defdb = [' 
		+ coalesce(db_name(dbid), 'MASTER') + ']'
		+ CHAR(13) + CHAR(10) + '-- ADD DEFAULT LANGUAGE TO WINDOWS LOGIN ' + name  
		+ CHAR(13) + CHAR(10) + 'exec sp_defaultlanguage @loginame = ['
		+ name + ']'
		+ CHAR(13) + CHAR(10) + CHAR(9) + ', @language = ' 
		+ coalesce(language, 'NULL' ) 
	WHEN xstatus & 0x02 = 2   -- Create sp_addlogin for SQL Server logins
	THEN CHAR(13) + CHAR(10) + '-- ADD SQL LOGIN ' + name  
		+ CHAR(13) + CHAR(10) + 'exec sp_addlogin @loginame = ['
		+ name + ']'
		+ CHAR(13) + CHAR(10) + CHAR(9) + ', @passwd = ' 
		+ coalesce(dbo.fn_varbintohexstr(password), 'NULL') 
		+ CHAR(13) + CHAR(10) + CHAR(9) + ', @defdb = ['
		+ coalesce(db_name(dbid), 'MASTER') + ']'
		+ CHAR(13) + CHAR(10) + CHAR(9) + ', @deflanguage  = ' 
		+ coalesce(language, 'NULL' )
		+ CHAR(13) + CHAR(10) + CHAR(9) + ', @sid = '
		+ dbo.fn_varbintohexstr(sid) 
		+ CASE 
		         WHEN xstatus & 0x800 = 0
		           THEN CHAR(13) + CHAR(10) + CHAR(9) + ', @encryptopt = skip_encryption' 
  		           ELSE CHAR(13) + CHAR(10) + CHAR(9) + ', @encryptopt = skip_encryption_old' 
   		   END
	ELSE ''
	END
FROM sysxlogins
WHERE  name <> 'sa' AND name NOT IN ( 'builtin\administrators', 'nt authority\system') 
UNION ALL
-- Create sp_denylogin for Windows Login
SELECT  CHAR(13) + CHAR(10) + '-- DENY WINDOWS LOGIN ' + name  
		+ CHAR(13) + CHAR(10)  + 'exec sp_denylogin @loginame = ['
		+ name + ']'
FROM sysxlogins
WHERE xstatus & 0x01 = 1
  AND name <> 'sa' AND name NOT IN ( 'builtin\administrators', 'nt authority\system')
UNION ALL
-- Create sp_addsrvrolemember for Sysadmin
SELECT  CHAR(13) + CHAR(10) + '-- ADD SYSADMIN ROLE TO LOGIN ' + name  
		+ CHAR(13) + CHAR(10)  + 'exec sp_addsrvrolemember @loginame = ['
		+ name + ']'
		+ CHAR(13) + CHAR(10) + CHAR(9) + ', @rolename = SYSADMIN'
FROM sysxlogins
WHERE xstatus & 0x10 = 16
  AND name <> 'sa' AND name NOT IN ( 'builtin\administrators', 'nt authority\system')
UNION ALL
-- Create sp_addsrvrolemember for SecurityAdmin
SELECT   CHAR(13) + CHAR(10) + '-- ADD SECURITYADMIN ROLE TO LOGIN ' + name  
		+ CHAR(13) + CHAR(10)  + 'exec sp_addsrvrolemember @loginame = ['
		+ name + ']'
		+ CHAR(13) + CHAR(10) + CHAR(9) + ', @rolename = SECURITYADMIN'
FROM sysxlogins
WHERE xstatus & 0x20 = 32 
  AND name <> 'sa' AND name NOT IN ( 'builtin\administrators', 'nt authority\system')
UNION ALL
-- Create sp_addsrvrolemember for ServerAdmin
SELECT  CHAR(13) + CHAR(10) + '-- ADD SERVERADMIN ROLE TO LOGIN ' + name  
		+ CHAR(13) + CHAR(10)  + 'exec sp_addsrvrolemember @loginame = ['
		+ name + ']'
		+ CHAR(13) + CHAR(10) + CHAR(9) + ', @rolename = SERVERADMIN'
FROM sysxlogins
WHERE xstatus & 0x40 = 64 
  AND name <> 'sa' AND name NOT IN ( 'builtin\administrators', 'nt authority\system')
UNION ALL
-- Create sp_addsrvrolemember for SetupAdmin
SELECT  CHAR(13) + CHAR(10) + '-- ADD SETUPADMIN ROLE TO LOGIN ' + name  
		+ CHAR(13) + CHAR(10)  + 'exec sp_addsrvrolemember @loginame = ['
		+ name + ']'
		+ CHAR(13) + CHAR(10) + CHAR(9) + ', @rolename = SETUPADMIN'
FROM sysxlogins
WHERE xstatus & 0x80 = 128
  AND name <> 'sa' AND name NOT IN ( 'builtin\administrators', 'nt authority\system')
UNION ALL
-- Create sp_addsrvrolemember for ProcessAdmin
SELECT  CHAR(13) + CHAR(10) + '-- ADD PROCESSADMIN ROLE TO LOGIN ' + name  
		+ CHAR(13) + CHAR(10)  + 'exec sp_addsrvrolemember @loginame = ['
		+ name + ']'
		+ CHAR(13) + CHAR(10) + CHAR(9) + ', @rolename = PROCESSADMIN'
FROM sysxlogins
WHERE xstatus & 0x100 = 256 
  AND name <> 'sa' AND name NOT IN ( 'builtin\administrators', 'nt authority\system')
UNION ALL
-- Create sp_addsrvrolemember for DiskAdmin
SELECT  CHAR(13) + CHAR(10) + '-- ADD DISKADMIN ROLE TO LOGIN ' + name  
		+ CHAR(13) + CHAR(10)  + 'exec sp_addsrvrolemember @loginame = ['
		+ name + ']'
		+ CHAR(13) + CHAR(10) + CHAR(9) + ', @rolename = DISKADMIN'
FROM sysxlogins
WHERE xstatus & 0x200 = 512 
  AND name <> 'sa' AND name NOT IN ( 'builtin\administrators', 'nt authority\system')
UNION ALL
-- Create sp_addsrvrolemember for DBCreator
SELECT  CHAR(13) + CHAR(10) + '-- ADD DBCREATOR ROLE TO LOGIN ' + name  
		+ CHAR(13) + CHAR(10)  + 'exec sp_addsrvrolemember @loginame = ['
		+ name + ']'
		+ CHAR(13) + CHAR(10) + CHAR(9) + ', @rolename = DBCREATOR'
FROM sysxlogins
WHERE xstatus & 0x400 = 1024
  AND name <> 'sa' AND name NOT IN ( 'builtin\administrators', 'nt authority\system')
UNION ALL
-- Create sp_addsrvrolemember for BulkAdmin
SELECT  CHAR(13) + CHAR(10) + '-- ADD BULKADMIN ROLE TO LOGIN ' + name  
		+ CHAR(13) + CHAR(10)  + 'exec sp_addsrvrolemember @loginame = ['
		+ name + ']'
		+ CHAR(13) + CHAR(10) + CHAR(9) + ', @rolename = BULKADMIN'
FROM sysxlogins
WHERE xstatus & 0x800 = 2048 
  AND name <> 'sa' AND name NOT IN ( 'builtin\administrators', 'nt authority\system')
GO