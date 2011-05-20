
SQL Server 2005 SP4

To allow clients to use the Print button from Reporting Services,
requires installation of the updated RSClientPrint.Cab ActiveX file.

There are two ways to do this install :

1.  Run Internet Explorer as a user with local Admin rights and install the ActiveX control once prompted.

OR

2. Silent Install:

For a silent deployment of RSClientPrint.cab, you only need to distribute RSClientPrint.dll file and the .rll files.
copy the files listed below under the folder C:\WINDOWS\system32 for client computers.
RSClientPrint.dll
RSClientPrint_1028.rll
RSClientPrint_1031.rll
RSClientPrint_1033.rll
RSClientPrint_1036.rll
RSClientPrint_1040.rll
RSClientPrint_1041.rll
RSClientPrint_1042.rll
RSClientPrint_1043.rll
RSClientPrint_1046.rll
RSClientPrint_1053.rll
RSClientPrint_2052.rll
RSClientPrint_3082.rll
Register the RSClientPrint.dll dll file by running the regsvr32.exe command on the command prompt shown as below.

c:\regsvr32.exe /s
c:\windows\system32 \rsclientprint.dll


