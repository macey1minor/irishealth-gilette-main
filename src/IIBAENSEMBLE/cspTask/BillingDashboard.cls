/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.cspTask.BillingDashboard Extends %CSP.Page [ ProcedureBlock ]
{

ClassMethod CheckPermissions()
{
	Set Allowed=1
	
	Quit Allowed
}

ClassMethod html()
{
    w "<table width=800px><tr><td width=700px>"
    w "TCP Port List "
	w "</td><td>"
	w "<Input Type='Button' Name='btnBillingDashboard' id='btnBillingDashboard' Value='View' onclick='location.href=""/csp/iibabill/BillingDashboard.csp""'>"
	w "</td></tr></table>"
}

}
