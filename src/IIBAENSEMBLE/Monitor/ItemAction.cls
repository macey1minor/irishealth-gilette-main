/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Monitor.ItemAction Extends %Persistent
{

// ID from the IIBAENSEMBLE_Monitor.ItemParameters table

Property ItemID As %Integer;

// itemdescription from the IIBAENSEMBLE_Monitor.tblItems table

Property ActionID As %String;

Storage Default
{
<Data name="ItemActionDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ActionID</Value>
</Value>
<Value name="3">
<Value>ItemID</Value>
</Value>
</Data>
<DataLocation>^IIBAENSEMBLE.Mon676.ItemActionD</DataLocation>
<DefaultData>ItemActionDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^IIBAENSEMBLE.Mon676.ItemActionD</IdLocation>
<IndexLocation>^IIBAENSEMBLE.Mon676.ItemActionI</IndexLocation>
<StreamLocation>^IIBAENSEMBLE.Mon676.ItemActionS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
