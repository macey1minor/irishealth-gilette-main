/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Monitor.tblItems Extends %Persistent
{

Property itemtype As %String(MAXLEN = 256);

Property itemvalue As %String(MAXLEN = 256);

Property itemdescription As %String(MAXLEN = 256);

Storage Default
{
<Data name="tblItemsDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>itemname</Value>
</Value>
<Value name="3">
<Value>itemtype</Value>
</Value>
<Value name="4">
<Value>itemdescription</Value>
</Value>
<Value name="5">
<Value>itemvalue</Value>
</Value>
</Data>
<DataLocation>^IIBAENSEMBLE.Monitor.tblItemsD</DataLocation>
<DefaultData>tblItemsDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^IIBAENSEMBLE.Monitor.tblItemsD</IdLocation>
<IndexLocation>^IIBAENSEMBLE.Monitor.tblItemsI</IndexLocation>
<StreamLocation>^IIBAENSEMBLE.Monitor.tblItemsS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
