/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Monitor.ItemStatus Extends %Persistent
{

Property ItemName As %String(MAXLEN = 255) [ Required ];

Property Parameter As %String(MAXLEN = 255) [ Required ];

Property LastStatus As %String(MAXLEN = 255);

Property TimeLastStatus As %TimeStamp;

Property LastAlert As %String(MAXLEN = 1024);

Property TimeLastAlert As %TimeStamp;

Property Troubled As %Boolean;

Property NameSpace As %String;

Property EmailText As %String(MAXLEN = 255);

Storage Default
{
<Data name="ItemStatusDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ItemName</Value>
</Value>
<Value name="3">
<Value>LastAlert</Value>
</Value>
<Value name="4">
<Value>LastStatus</Value>
</Value>
<Value name="5">
<Value>Parameter</Value>
</Value>
<Value name="6">
<Value>TimeLastAlert</Value>
</Value>
<Value name="7">
<Value>TimeLastStatus</Value>
</Value>
<Value name="8">
<Value>Troubled</Value>
</Value>
<Value name="9">
<Value>NameSpace</Value>
</Value>
<Value name="10">
<Value>ItemId</Value>
</Value>
<Value name="11">
<Value>EmailText</Value>
</Value>
</Data>
<DataLocation>^IIBAENSEMBLE.Mon676.ItemStatusD</DataLocation>
<DefaultData>ItemStatusDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^IIBAENSEMBLE.Mon676.ItemStatusD</IdLocation>
<IndexLocation>^IIBAENSEMBLE.Mon676.ItemStatusI</IndexLocation>
<StreamLocation>^IIBAENSEMBLE.Mon676.ItemStatusS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
