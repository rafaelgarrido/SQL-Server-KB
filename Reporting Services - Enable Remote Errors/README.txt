
Enable Remote Errors in SQL Reporting Services
==============================================
SQL Server 2005

The easiest way is:

Copy the "EnableRemoteErrors.rss" file attached to the disk (ie. C:\  ),
go to command prompt where the file is and run (you can do it remotely):

rs -i EnableRemoteErrors.rss -s http://<ServerName>/ReportServer

Done, it should make effect immediately.


FYI
Content of the "EnableRemoteErrors.rss" file 
----------------------------------
Public Sub Main()
Dim P As New [Property]()
P.Name = "EnableRemoteErrors"
P.Value = True
Dim Properties(0) As [Property]
Properties(0) = P
Try
rs.SetSystemProperties(Properties)
Console.WriteLine("Remote errors enabled.")
Catch SE As SoapException
Console.WriteLine(SE.Detail.OuterXml)
End Try
End Sub
----------------------------------
