/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Task.TaskItemDefinition Extends %Persistent
{

Property NameSpace As %String;

Property ItemType As %String(MAXLEN = 256);

Property ItemName As %String(MAXLEN = 256);

Property ItemValue As %String(MAXLEN = 256);

Query GetTaskItemNames(NameSpace As %String, ItemType As %String = "TaskMgmtMethods") As %SQLQuery
{
SELECT distinct ItemName FROM TaskItemDefinition
 WHERE ((NameSpace = :NameSpace OR NameSpace = 'All') AND ItemType = :ItemType)
 ORDER BY ItemName
}

Query GetTaskItemValues(NameSpace As %String, ItemName As %String, ItemType As %String = "TaskMgmtMethods") As %SQLQuery
{
SELECT ItemValue FROM TaskItemDefinition
 WHERE (ItemName = :ItemName AND ItemType = :ItemType AND (NameSpace = :NameSpace OR NameSpace = 'All'))
 ORDER BY ItemValue
}

ClassMethod setTaskItemDefinitiontoDefaults()
{
	
	&SQL(
	
		delete from IIBAENSEMBLE_Task.TaskItemDefinition 
		where 
		(	ItemName in (

			'04^WorkflowTaskPurge'
			,'10^TaskItems'
			,'20^SupportPages'
			,'11^MsgClassDefUpdate'
			,'30^TCP Port List'
			)
			and NameSpace <> 'All'
		)
		or 
		(
			ItemName NOT in (
			'04^WorkflowTaskPurge'
			,'10^TaskItems'
			,'20^SupportPages'
			,'11^MsgClassDefUpdate'
			,'30^TCP Port List'
			)
		)
	)
}

Storage Default
{
<Data name="TaskItemDefinitionDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ItemName</Value>
</Value>
<Value name="3">
<Value>ItemType</Value>
</Value>
<Value name="4">
<Value>ItemValue</Value>
</Value>
<Value name="5">
<Value>NameSpace</Value>
</Value>
</Data>
<DataLocation>^IIBAENSEMBL521.TaskItemDefi72BD</DataLocation>
<DefaultData>TaskItemDefinitionDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^IIBAENSEMBL521.TaskItemDefi72BD</IdLocation>
<IndexLocation>^IIBAENSEMBL521.TaskItemDefi72BI</IndexLocation>
<StreamLocation>^IIBAENSEMBL521.TaskItemDefi72BS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
