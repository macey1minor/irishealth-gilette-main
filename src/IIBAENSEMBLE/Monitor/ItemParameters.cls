/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Monitor.ItemParameters Extends %Persistent
{

Property ItemName As %String(MAXLEN = 255) [ Required ];

Property Parameter As %String(MAXLEN = 255) [ Required ];

Property Threshold As %String(MAXLEN = 255);

Property ThresholdID As %Integer;

Property ThresholdDuration As %Integer;

Property AlertDuration As %Integer;

Property Schedule As %String(MAXLEN = 2048);

Property Active As %Boolean;

Property NotificationEmail As %String(MAXLEN = 255);

Property Holidays As %String(MAXLEN = 255);

Property HolidayOnly As %String(MAXLEN = 255);

Property EmailText As %String(MAXLEN = 255);

Storage Default
{
<Data name="ItemParametersDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Active</Value>
</Value>
<Value name="3">
<Value>AlertDuration</Value>
</Value>
<Value name="4">
<Value>ItemName</Value>
</Value>
<Value name="5">
<Value>Parameter</Value>
</Value>
<Value name="6">
<Value>Schedule</Value>
</Value>
<Value name="7">
<Value>Threshold</Value>
</Value>
<Value name="8">
<Value>ThresholdDuration</Value>
</Value>
<Value name="9">
<Value>NotificationEmail</Value>
</Value>
<Value name="10">
<Value>ThresholdID</Value>
</Value>
<Value name="11">
<Value>HolidayOnly</Value>
</Value>
<Value name="12">
<Value>Holidays</Value>
</Value>
<Value name="13">
<Value>EmailText</Value>
</Value>
</Data>
<DataLocation>^IIBAENSEMBLE676.ItemParametersD</DataLocation>
<DefaultData>ItemParametersDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^IIBAENSEMBLE676.ItemParametersD</IdLocation>
<IndexLocation>^IIBAENSEMBLE676.ItemParametersI</IndexLocation>
<StreamLocation>^IIBAENSEMBLE676.ItemParametersS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
