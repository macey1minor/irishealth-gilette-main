/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.cspTask.MedicalisMonitor Extends %CSP.Page [ ProcedureBlock ]
{

ClassMethod CheckPermissions()
{
	set Allowed = 1
		
	if (%session.Username="ddpaxton")
		||(%session.Username="ddpaxton")
		||(%session.Username="dpaxton") {
			set Allowed = 1
		}
	
	Quit Allowed
}

ClassMethod html()
{
		
    w "<table width=800px><tr><td width=700px>"
    w "<p>Medicalis Monitor</p><td>"
	//w "<Input Type='Button' Name='btnView' id='btnView' Value='View' onclick='window.open(""/csp/"_$ZNSPACE_"/Medicalis.Metric.ZenView.cls"")'>"
	w "<Input Type='Button' Name='btnView' id='btnView' Value='View' onclick='alert(""Sorry, this page is temporarily disabled."");'>"
	w "</td></tr></table>"
}

}
