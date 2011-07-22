/*

List the emails to be sent in Reporting Services subscriptions

*/

USE ReportServer

SELECT DISTINCT  c.Path AS InternalSystemPath, c.Name AS Report 
, 
REPLACE(
SUBSTRING(
	s.ExtensionSettings,

	CHARINDEX('<ParameterValue><Name>TO</Name><Value>', s.ExtensionSettings, 1) + 38,

	CHARINDEX('</Value></ParameterValue>', s.ExtensionSettings, CHARINDEX('<ParameterValue><Name>TO</Name>', s.ExtensionSettings, 1) )
		- (CHARINDEX('<ParameterValue><Name>TO</Name>', s.ExtensionSettings, 1) + 38)
)
,';',',') AS [EmailTO]
, REPLACE(
CASE WHEN s.ExtensionSettings LIKE '%<ParameterValue><Name>CC</Name>%'
THEN
SUBSTRING(
	s.ExtensionSettings,

	CHARINDEX('<ParameterValue><Name>CC</Name>', s.ExtensionSettings, 1) + 38,

	CHARINDEX('</Value></ParameterValue>', s.ExtensionSettings, CHARINDEX('<ParameterValue><Name>CC</Name>', s.ExtensionSettings, 1) )
		- (CHARINDEX('<ParameterValue><Name>CC</Name>', s.ExtensionSettings, 1) + 38)
)
ELSE '' END ,';',',') AS [EmailCC]

FROM dbo.Subscriptions s
join dbo.Catalog c ON s.Report_Oid = c.itemid
WHERE s.ExtensionSettings LIKE '%<ParameterValue><Name>TO</Name>%'
ORDER BY Path, Name