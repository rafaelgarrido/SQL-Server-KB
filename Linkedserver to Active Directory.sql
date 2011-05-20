/*
For SQL 2005

Do not forget to set LINKED_SERVER_SECURITY to "Be made using login's current security context"
*/

/*
EXEC sp_addlinkedserver 'ADSI', 'Active Directory Services 2.5', 'ADSDSOObject', 'adsdatasource'
EXEC sp_addlinkedsrvlogin 'ADSI', false
*/

DECLARE @ACCOUNT_DISABLED INT
SET @ACCOUNT_DISABLED  =  0x0002

SELECT cn, sAMAccountName, GivenName, objectGuid, userAccountControl, 
	CASE (userAccountControl & @ACCOUNT_DISABLED) WHEN @ACCOUNT_DISABLED THEN 0 ELSE 1 END 'Active'
	FROM OPENQUERY(ADSI, 
		'SELECT GivenName, 
		sAMAccountName, 
		Department, 
		cn, 
		userAccountControl,
		objectGuid FROM ''LDAP://<domain>''
		where objectCategory = ''Person''') AS MyTable -- objectCategory = ''Computer''
ORDER BY cn
