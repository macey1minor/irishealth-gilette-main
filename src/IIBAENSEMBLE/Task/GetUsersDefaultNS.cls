/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Task.GetUsersDefaultNS Extends %SYS.Task.Definition
{

Parameter TaskName = "GetUsersDefaultNS";

Method OnTask() As %Status
{
	&sql(delete from IIBAENSEMBLE_Task.TaskItemDefinition WHERE ItemType = 'DefaultNS')
	
	set rs = ##class(%ResultSet).%New("Security.Users:Detail")
	do rs.Execute("*","*","*")
	While rs.Next() {
		set sName="",sNS=""
		set sName = rs.Data("Name")
		set sNS=rs.Data("Namespace")
		&sql(insert into IIBAENSEMBLE_Task.TaskItemDefinition (NameSpace, ItemType, ItemName, ItemValue) VALUES('All','DefaultNS',:sName,:sNS))
		
		
	
	}
	
	
	
	Quit $$$OK
}

}
