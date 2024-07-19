/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.csp.MsgFields Extends %CSP.Page [ ProcedureBlock ]
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
	var m_Parent = dialogArguments;

	function ReturnField(ItemSpan,Field) {
		m_Parent.SetField(ItemSpan,Field)
		window.close();
	}
  -->
   </script>
  >
}

ClassMethod html()
{
	set sMsgClass = %request.Get("MsgClass")
	set sItemSpan = %request.Get("ItemSpan")

	Set rsMsgClass = ##class(%ResultSet).%New()
	Do rsMsgClass.Prepare("Select Name from %Dictionary.PropertyDefinition where UCASE(parent) = UCASE('"_sMsgClass_"') Order by Name")
	do rsMsgClass.Execute()

	set propcount = 1

	w "<table><tr><td>"

	w "<input type=""radio"" name=""MsgFieldRadio"" id=""MsgFieldRadio"" value="""" onclick=ReturnField('"_sItemSpan_"',this.value)><font size=""2"">All</font><br>"	

	While (rsMsgClass.Next()) {

		set propertyname = rsMsgClass.Get("Name") 
	
		w "<input type=""radio"" name=""MsgFieldRadio"" id=""MsgFieldRadio"" value="""_propertyname_""" onclick=ReturnField('"_sItemSpan_"',this.value)><font size=""2"">"_propertyname_"</font><br>"
	
		set propcount = propcount + 1
	
		If propcount = 35 {
		
			w "</td><td>"
			set propcount = 0
		}
	

	}

	w "</td></tr></table>"
}

}
