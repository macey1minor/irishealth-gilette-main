Class GC.Xltek.MSH Extends (%Persistent, %Populate, %XML.Adaptor, Ens.Response) [ ClassType = persistent, Inheritance = right ]
{

Property MessageTypeID As %String;

Property TriggerEventID As %String;

Storage Default
{
<Data name="MSHDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>MessageTypeID</Value>
</Value>
<Value name="3">
<Value>TriggerEventID</Value>
</Value>
</Data>
<DataLocation>^GC.Xltek.MSHD</DataLocation>
<DefaultData>MSHDefaultData</DefaultData>
<ExtentSize>2000000</ExtentSize>
<IdLocation>^GC.Xltek.MSHD</IdLocation>
<IndexLocation>^GC.Xltek.MSHI</IndexLocation>
<StreamLocation>^GC.Xltek.MSHS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
