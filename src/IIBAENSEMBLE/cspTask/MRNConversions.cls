/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.cspTask.MRNConversions Extends %CSP.Page [ ProcedureBlock ]
{

ClassMethod CheckPermissions()
{
	set Allowed = 0
		
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
    w "Conversion Monitor "
	w "</td><td>"
	//w "<Input Type='Button' Name='btnMRNcTool' id='btnMRNcTool' Value='Open' onclick='window.open(""/csp/"_$ZNSPACE_"/IIBAENSEMBLE.Zen.MRNConversion.cls"")'>"
	w "</td><td>"
	s tDefaultApp = $SYSTEM.CSP.GetDefaultApp($NAMESPACE)
	w "<Input Type='Button' Name='btnMRNcView' id='btnMRNcView' Value='View' onclick='window.open("""_tDefaultApp_"/IIBAENSEMBLE.Zen.StatsConversion.cls"")'>"
	w "</td></tr></table>"
}

}
