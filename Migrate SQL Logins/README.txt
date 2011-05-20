
---------------------

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

---------------------

