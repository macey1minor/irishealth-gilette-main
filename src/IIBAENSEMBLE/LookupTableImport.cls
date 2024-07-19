/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.LookupTableImport Extends %Persistent [ SqlTableName = LookupTableImport ]
{

Property SessionID As %String(MAXLEN = 255);

Property LookupID As %String(MAXLEN = 255);

Property LeftID1 As %String(MAXLEN = 255);

Property LeftID2 As %String(MAXLEN = 255);

Property LeftID3 As %String(MAXLEN = 255);

Property RightID As %String(MAXLEN = 4000);

Storage Default
{
<Data name="LookupTableImportDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>LeftID1</Value>
</Value>
<Value name="3">
<Value>LeftID2</Value>
</Value>
<Value name="4">
<Value>LeftID3</Value>
</Value>
<Value name="5">
<Value>LookupID</Value>
</Value>
<Value name="6">
<Value>RightID</Value>
</Value>
<Value name="7">
<Value>SessionID</Value>
</Value>
</Data>
<DataLocation>^IIBAENSEMBLE.LookupTableI6DDD</DataLocation>
<DefaultData>LookupTableImportDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^IIBAENSEMBLE.LookupTableI6DDD</IdLocation>
<IndexLocation>^IIBAENSEMBLE.LookupTableI6DDI</IndexLocation>
<StreamLocation>^IIBAENSEMBLE.LookupTableI6DDS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
