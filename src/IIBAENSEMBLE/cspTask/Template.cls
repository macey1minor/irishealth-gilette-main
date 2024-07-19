/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.cspTask.Template Extends %CSP.Page [ ProcedureBlock ]
{

ClassMethod CheckPermissions()
{
	set Allowed = 0
	if ##class(%SYSTEM.Security).Check("%All") = "READ,WRITE,USE" { set Allowed = 1 }
	
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
  -->
   </script>
  >
}

ClassMethod html()
{
    w "<table width=800px><tr><td width=700px>"
    w "Title of Task "
	w "</td><td>"
	w "<Input Type=""Button"" Name=""Button"" Value=""Start"" onclick='jsfunction()'>"
	w "</td></tr></table>"
}

ClassMethod cosmethod(param As %String)
{
	
	&js<alert('Hello');>
	Quit 1
}

}
