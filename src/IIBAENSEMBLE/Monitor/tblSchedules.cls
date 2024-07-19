/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Monitor.tblSchedules Extends %Persistent
{

Property ParameterID As %Integer;

Property HourStart As %Integer;

Property HourEnd As %Integer;

Property M As %Boolean;

Property T As %Boolean;

Property W As %Boolean;

Property Th As %Boolean;

Property F As %Boolean;

Property Sa As %Boolean;

Property Su As %Boolean;

Storage Default
{
<Data name="tblSchedulesDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>F</Value>
</Value>
<Value name="3">
<Value>HourEnd</Value>
</Value>
<Value name="4">
<Value>HourStart</Value>
</Value>
<Value name="5">
<Value>M</Value>
</Value>
<Value name="6">
<Value>ParameterID</Value>
</Value>
<Value name="7">
<Value>Sa</Value>
</Value>
<Value name="8">
<Value>Su</Value>
</Value>
<Value name="9">
<Value>T</Value>
</Value>
<Value name="10">
<Value>Th</Value>
</Value>
<Value name="11">
<Value>W</Value>
</Value>
</Data>
<DataLocation>^IIBAENSEMBLE.M676.tblSchedulesD</DataLocation>
<DefaultData>tblSchedulesDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^IIBAENSEMBLE.M676.tblSchedulesD</IdLocation>
<IndexLocation>^IIBAENSEMBLE.M676.tblSchedulesI</IndexLocation>
<StreamLocation>^IIBAENSEMBLE.M676.tblSchedulesS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
