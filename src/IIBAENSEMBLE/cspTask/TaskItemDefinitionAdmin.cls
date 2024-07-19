/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.cspTask.TaskItemDefinitionAdmin Extends %CSP.Page [ ProcedureBlock ]
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
    w "Task Item Definition Admin "
	w "</td><td>"
	s tDefaultApp = $SYSTEM.CSP.GetDefaultApp($NAMESPACE)
	w "<Input Type=""Button"" Name=""btnProvider"" id=""btnProvider"" Value=""Open"" onclick='window.open("""_tDefaultApp_"/IIBAENSEMBLE.Task.TaskItemDefinitionAdmin.Home.cls"")'>"
	w "</td></tr></table>"
}

}
