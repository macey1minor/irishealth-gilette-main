/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.cspTask.ReportQueueMaint Extends %CSP.Page [ ProcedureBlock ]
{

ClassMethod CheckPermissions()
{
	set Allowed = 0
	if ##class(%SYSTEM.Security).Check("%All") = "READ,WRITE,USE" { set Allowed = 1 }
	
	Quit Allowed
}

ClassMethod html()
{
    w "<table width=800px><tr><td width=700px>"
    w "Report Attach Maintenance "
	w "</td><td>"
	w "<Input Type=""Button"" Name=""btnProvider"" id=""btnProvider"" Value=""Open"" onclick='window.open(""/csp/IIBACLINspt/IIBASupport.csp?PageName=reportattachmaint"")'>"
	w "</td></tr></table>"
}

}
