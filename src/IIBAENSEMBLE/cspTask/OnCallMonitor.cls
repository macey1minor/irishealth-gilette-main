/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.cspTask.OnCallMonitor Extends %CSP.Page [ ProcedureBlock ]
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
	//d ##class(IIBAENSEMBLE.Zen.OnCallMonitor.Home).GetErrorCount(1,.count)
	//d ##class(IIBAENSEMBLE.Zen.OnCallMonitor.Home).GetErrorCount(0,.msg)
	
    w "<table width=800px><tr><td width=700px>"
    //w "<p>Errors: "_count_"</p>"
	w "<p>On-Call Monitor</p></td><td>"
	s tDefaultApp = $SYSTEM.CSP.GetDefaultApp($NAMESPACE)
	w "<Input Type='Button' Name='btnView' id='btnView' Value='View' onclick='window.open("""_tDefaultApp_"/IIBAENSEMBLE.Zen.OnCallMonitor.Home.cls"")'>"

	w "</td></tr></table>"
}

}
