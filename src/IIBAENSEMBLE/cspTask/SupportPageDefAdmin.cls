/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.cspTask.SupportPageDefAdmin Extends %CSP.Page [ ProcedureBlock ]
{

ClassMethod CheckPermissions()
{
	set Allowed = 0
		
	if (%session.Username="msimpson")
		||(%session.Username="bgraham")
		||(%session.Username="jbendinelli") {
			set Allowed = 1
		}
	
	Quit Allowed
}

ClassMethod html()
{
    w "<table width=800px><tr><td width=700px>"
    w "Support Page Definition Admin "
	w "</td><td>"
	s tDefaultApp = $SYSTEM.CSP.GetDefaultApp($NAMESPACE)
	w "<Input Type=""Button"" Name=""btn"" id=""btn"" Value=""Open"" onclick='window.open("""_tDefaultApp_"/IIBAENSEMBLE.csp.SupportPageDefinition.Home.cls"")'>"
	w "</td></tr></table>"
}

}
