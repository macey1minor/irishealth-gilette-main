/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.cspTask.DTLAutoDoc Extends %CSP.Page [ ProcedureBlock ]
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
	
	function Initialize()
	{

	}
	function LaunchAutoDoc()
	{
		var DTL = '';
		DTL = document.getElementById('TransformsList').options[document.getElementById('TransformsList').options.selectedIndex].value;
		window.open('IIBASupportDetail.csp?PageName=DTLAutoDoc&DTL='+DTL);
	}
	
	
  
   </script>
  >
}

ClassMethod html()
{
    s rs = ##class(%ResultSet).%New()
    s rs.ClassName = "%Dictionary.ClassDefinition"
    s rs.QueryName = "SubclassOf"
    d rs.Execute("Ens.DataTransform")
        
    w "<table width=800px><tr><td width=700px>"
    w "Generate Documentation for Transform: "
    w "<select NAME=""TransformsList"" ID=""TransformsList"">"
    w "<option Value="""">"
    While rs.Next() {
	    w "<option Value="""_rs.Data("Name")_".cls"">"_rs.Data("Name")
    }
    w "</select>"
	w "</td><td>"
	w "<Input Type=""Button"" Name=""Button"" id=""Button"" Value=""Start"" onclick='LaunchAutoDoc()'>"
	w "</td></tr></table>"
}

ClassMethod cosmethod(param As %String)
{
	
	&js<alert('Hello');>
	Quit 1
}

}
