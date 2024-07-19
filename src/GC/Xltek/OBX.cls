Class GC.Xltek.OBX Extends (%Persistent, %Populate, %XML.Adaptor, Ens.Response) [ ClassType = persistent, Inheritance = right ]
{

Property ObservationValue As %String;

Storage Default
{
<Data name="OBXDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ObservationValue</Value>
</Value>
</Data>
<DataLocation>^GC.Xltek.OBXD</DataLocation>
<DefaultData>OBXDefaultData</DefaultData>
<ExtentSize>2000000</ExtentSize>
<IdLocation>^GC.Xltek.OBXD</IdLocation>
<IndexLocation>^GC.Xltek.OBXI</IndexLocation>
<StreamLocation>^GC.Xltek.OBXS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
