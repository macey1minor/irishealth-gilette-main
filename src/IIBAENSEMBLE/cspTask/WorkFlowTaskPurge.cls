/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.cspTask.WorkFlowTaskPurge Extends %CSP.Page [ ProcedureBlock ]
{

ClassMethod html()
{
    w "<table width=800px><tr><td width=700px>"
    w "Workflow Task Purge "
	w "</td><td>"
	s tDefaultApp = $SYSTEM.CSP.GetDefaultApp($NAMESPACE)
	w "<Input Type=""Button"" Name=""btnWorkflowPurge"" id=""btnWorkflowPurge"" Value=""Open"" onclick='location.href="""_tDefaultApp_"/IIBASupport.csp?PageName=WorkflowPurge""'>"
	w "</td></tr></table>"
}

}
