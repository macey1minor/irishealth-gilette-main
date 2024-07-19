/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Task.SetToolkitFavorite Extends %SYS.Task.Definition
{

Parameter TaskName = "SetToolkitFavorite";

Method OnTask(username As %String = "All") As %Status
{
	&sql(delete from IIBAENSEMBLE_Task.TaskItemDefinition WHERE ItemType = 'DefaultNS')
	
	set rs = ##class(%ResultSet).%New("Security.Users:Detail")
	do rs.Execute("*","*","*")
	While rs.Next() {
		set sName="",sNS=""
		set sName = rs.Data("Name")
		set sNS=rs.Data("Namespace")
		
		if ( (username="All") || (sName=username) ) {
			//Add toolkit shortcut to favorites
			s obj=##class(%SYS.Portal.Users).%New()
			s obj.Username=sName
			s tDefaultApp = $SYSTEM.CSP.GetDefaultApp(sNS)
			s obj.Page=$P(tDefaultApp,"/",3)_" / Nuvo Toolkit"
			s obj.Data=tDefaultApp_"/IIBASupport.csp?PageName=SystemStatus"
			d obj.%Save()
		}
	
	}
	
	
	
	Quit $$$OK
}

}
