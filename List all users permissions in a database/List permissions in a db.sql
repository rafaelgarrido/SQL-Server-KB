
-- The script does NOT consider Deny
Declare @DB VARCHAR(30)
Set @DB = db_name()

-- Direct permission
select @DB AS DB, sysusers.name as Name
, CASE WHEN isSQLRole = 1 THEN 'Role' WHEN issqluser = 1 THEN 'SQL User' WHEN isntgroup = 1 THEN 'NT Group' WHEN isntuser = 1 THEN 'NT User' ELSE '<n/a>' END AS Type
, '(n/a)' as RoleName
-- ,sysusers.gid
, sysobjects.name as objectname --, sysobjects.id
, CASE WHEN sysprotects_1.action is null THEN CASE WHEN sysobjects.xtype = 'P' THEN 'N/A' ELSE 'No' END ELSE 'Yes' END as 'SELECT', CASE WHEN sysprotects_2.action is null THEN CASE WHEN sysobjects.xtype = 'P' THEN 'N/A' ELSE 'No' END ELSE 'Yes' END as 'INSERT'
, CASE WHEN sysprotects_3.action is null THEN CASE WHEN sysobjects.xtype = 'P' THEN 'N/A' ELSE 'No' END ELSE 'Yes' END as 'UPDATE', CASE WHEN sysprotects_4.action is null THEN CASE WHEN sysobjects.xtype = 'P' THEN 'N/A' ELSE 'No' END ELSE 'Yes' END as 'DELETE'
, CASE WHEN sysprotects_5.action is null THEN CASE WHEN sysobjects.xtype IN ('U', 'V') THEN 'N/A' ELSE 'No' END ELSE 'Yes' END as 'EXECUTE'
from sysusers full 
join sysobjects on ( sysobjects.xtype in ( 'P', 'U', 'V' ) and sysobjects.Name NOT LIKE 'dt%' ) 
left join sysprotects as sysprotects_1  on sysprotects_1.uid = sysusers.uid and sysprotects_1.id = sysobjects.id and sysprotects_1.action = 193 and sysprotects_1.protecttype in ( 204, 205 ) 
left join sysprotects as sysprotects_2  on sysprotects_2.uid = sysusers.uid and sysprotects_2.id = sysobjects.id and sysprotects_2.action = 195 and sysprotects_2.protecttype in ( 204, 205 ) 
left join sysprotects as sysprotects_3  on sysprotects_3.uid = sysusers.uid and sysprotects_3.id = sysobjects.id and sysprotects_3.action = 197 and sysprotects_3.protecttype in ( 204, 205 ) 
left join sysprotects as sysprotects_4  on sysprotects_4.uid = sysusers.uid and sysprotects_4.id = sysobjects.id and sysprotects_4.action = 196 and sysprotects_4.protecttype in ( 204, 205 ) 
left join sysprotects as sysprotects_5  on sysprotects_5.uid = sysusers.uid and sysprotects_5.id = sysobjects.id and sysprotects_5.action = 224 and sysprotects_5.protecttype in ( 204, 205 )
where (sysprotects_1.action is not null or sysprotects_2.action is not null or sysprotects_3.action is not null or sysprotects_4.action is not null or sysprotects_5.action is not null)
AND (isSQLRole <> 1 OR isSQLRole IS NULL) -- Exclude Roles because we show it in the "Through Role Permission" query
-- order by sysusers.name, sysobjects.name

UNION

-- Through Role Permission
select @DB AS DB, u.name as Name
, CASE WHEN u.isSQLRole = 1 THEN 'Role' WHEN u.issqluser = 1 THEN 'SQL User' WHEN u.isntgroup = 1 THEN 'NT Group' WHEN u.isntuser = 1 THEN 'NT User' ELSE '<n/a>' END AS Type
, sysusers.name as RoleName
-- ,sysusers.gid
, sysobjects.name as objectname --, sysobjects.id
, CASE WHEN sysprotects_1.action is null THEN CASE WHEN sysobjects.xtype = 'P' THEN 'N/A' ELSE 'No' END ELSE 'Yes' END as 'SELECT', CASE WHEN sysprotects_2.action is null THEN CASE WHEN sysobjects.xtype = 'P' THEN 'N/A' ELSE 'No' END ELSE 'Yes' END as 'INSERT'
, CASE WHEN sysprotects_3.action is null THEN CASE WHEN sysobjects.xtype = 'P' THEN 'N/A' ELSE 'No' END ELSE 'Yes' END as 'UPDATE', CASE WHEN sysprotects_4.action is null THEN CASE WHEN sysobjects.xtype = 'P' THEN 'N/A' ELSE 'No' END ELSE 'Yes' END as 'DELETE'
, CASE WHEN sysprotects_5.action is null THEN CASE WHEN sysobjects.xtype IN ('U', 'V') THEN 'N/A' ELSE 'No' END ELSE 'Yes' END as 'EXECUTE'
from sysusers u
join sysmembers ON sysmembers.memberuid = u.uid
join sysusers on sysusers.uid = sysmembers.groupuid
full join sysobjects on ( sysobjects.xtype in ( 'P', 'U', 'V') and sysobjects.Name NOT LIKE 'dt%' ) 
left join sysprotects as sysprotects_1  on sysprotects_1.uid = sysusers.uid and sysprotects_1.id = sysobjects.id and sysprotects_1.action = 193 and sysprotects_1.protecttype in ( 204, 205 ) 
left join sysprotects as sysprotects_2  on sysprotects_2.uid = sysusers.uid and sysprotects_2.id = sysobjects.id and sysprotects_2.action = 195 and sysprotects_2.protecttype in ( 204, 205 ) 
left join sysprotects as sysprotects_3  on sysprotects_3.uid = sysusers.uid and sysprotects_3.id = sysobjects.id and sysprotects_3.action = 197 and sysprotects_3.protecttype in ( 204, 205 ) 
left join sysprotects as sysprotects_4  on sysprotects_4.uid = sysusers.uid and sysprotects_4.id = sysobjects.id and sysprotects_4.action = 196 and sysprotects_4.protecttype in ( 204, 205 ) 
left join sysprotects as sysprotects_5  on sysprotects_5.uid = sysusers.uid and sysprotects_5.id = sysobjects.id and sysprotects_5.action = 224 and sysprotects_5.protecttype in ( 204, 205 )
where (sysprotects_1.action is not null or sysprotects_2.action is not null or sysprotects_3.action is not null or sysprotects_4.action is not null or sysprotects_5.action is not null)


UNION

-- Database System Roles
select @DB as DB, u.name as Name
, CASE WHEN u.isSQLRole = 1 THEN 'Role' WHEN u.issqluser = 1 THEN 'SQL User' WHEN u.isntgroup = 1 THEN 'NT Group' WHEN u.isntuser = 1 THEN 'NT User' ELSE '<n/a>' END AS Type
, r.name as RoleName
--, NULL [gid]
, '(all database objects)' [objectname] --, NULL [id]
, CASE WHEN r.name IN ('db_datareader', 'db_owner') THEN 'Yes' ELSE 'No' END [SELECT]
, CASE WHEN r.name IN ('db_datawriter', 'db_owner') THEN 'Yes' ELSE 'No' END [INSERT]
, CASE WHEN r.name IN ('db_datawriter', 'db_owner') THEN 'Yes' ELSE 'No' END [UPDATE]
, CASE WHEN r.name IN ('db_datawriter', 'db_owner') THEN 'Yes' ELSE 'No' END [DELETE]
, CASE WHEN r.name IN ('db_owner') THEN 'Yes' ELSE 'No' END [EXECUTE]
from sysusers u
join sysmembers ON sysmembers.memberuid = u.uid
join sysusers r on r.uid = sysmembers.groupuid
where r.name like 'db[_]%'


UNION

-- Sysadmin Users
select @DB as DB, 
name as Name
, CASE WHEN u.isntgroup = 1 THEN 'NT Group' WHEN u.isntuser = 1 THEN 'NT User' ELSE 'SQL User' END AS Type
, 'sysadmin' as RoleName
--, NULL [gid]
, '(all databases and its objects)' [objectname] --, NULL [id]
, 'Yes' as [SELECT]
, 'Yes' as [INSERT]
, 'Yes' as [UPDATE]
, 'Yes' as [DELETE]
, 'Yes' as [EXECUTE]
FROM master.dbo.syslogins u WHERE sysadmin = 1 and hasaccess = 1

order by Name, RoleName, ObjectName
