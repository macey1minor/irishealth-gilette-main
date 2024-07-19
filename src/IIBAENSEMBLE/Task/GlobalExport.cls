/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Task.GlobalExport Extends %SYS.Task.Definition
{

Parameter TaskName = "GlobalExport";

/// The globals will be exported to this filename.
Property FileName As %String;

Method OnTask() As %Status
{
	set tSC = 1
	
	do ..GetGlobalList(.GlobalList)
	
	set tSC = ##class(%Library.Global).Export($ZNSPACE,.GlobalList,..FileName,7,"V")
	
	Quit tSC
}

Method GetGlobalList(ByRef GlobalList As %String)
{
	set GlobalList = ""
	
	set x = ""
	
	set i = 0
	
	set NameSpace = $ZNSPACE	
	
	&sql(DECLARE C1 CURSOR FOR
		SELECT ItemName into :x 
		FROM IIBAENSEMBLE_Task.TaskItemDefinition 
		WHERE ItemType = 'GlobalExport' AND NameSpace = :NameSpace)
		
		&sql(OPEN C1)
		&sql(FETCH C1)
		While (SQLCODE = 0) {
			set i = i+1
			set $LIST(GlobalList,i) = x
			&sql(FETCH C1)
		}
	&sql(CLOSE C1)
	
	set GlobalList = $LTS(GlobalList,",")
}

}
