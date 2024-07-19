/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.csp.SystemStatus Extends %CSP.Page [ ProcedureBlock ]
{

ClassMethod CheckPermissions()
{
	set Allowed = 0
	//Req#5 - PHegel Tab Security Use for page name
	if ##class(%SYSTEM.Security).Check("SystemStatus","USE"){ 
		set Allowed = 1 
	}
	Quit Allowed
}

ClassMethod jsfunction()
{
  &html<
   <script language=javascript>
	<!--
	function Initialize()
	{

	}
	
function popup(mylink, windowname)
{
if (! window.focus)return true;
var href;
if (typeof(mylink) == 'string')
   href=mylink;
else
   href=mylink.href;
window.open(href, windowname, 'width=400,height=200,scrollbars=yes');
return false;
}


//-->
  
   </script>
  >
}

ClassMethod html()
{
		
	Set ProductionName=""
	Set ProductionStatus=""
	set status = ##class(Ens.Director).GetProductionStatus(.ProductionName,.ProductionStatus)

	W "<H3>Production Status: "
	
	IF (ProductionStatus '= 1) {
		W "<FONT Color=red>"
	}
	
	W $P("Running,Stopped,Suspended,Troubled",",",ProductionStatus)
	
	IF (ProductionStatus '= 1) {
		W "</FONT>"
	}	
	W "</H3>"
	
	do ##class(IIBAENSEMBLE.csp.components).troubleditems(1)
}

}
