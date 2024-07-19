Class GC.Xltek.PV1 Extends (%Persistent, %Populate, %XML.Adaptor, Ens.Response) [ ClassType = persistent, Inheritance = right ]
{

Property ReferringPhysicianFirstName As %String;

Property ReferringPhysicianLastName As %String;

Property VisitNumber As %String;

Storage Default
{
<Data name="PV1DefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ReferringPhysicianFirstName</Value>
</Value>
<Value name="3">
<Value>ReferringPhysicianLastName</Value>
</Value>
<Value name="4">
<Value>VisitNumber</Value>
</Value>
</Data>
<DataLocation>^GC.Xltek.PV1D</DataLocation>
<DefaultData>PV1DefaultData</DefaultData>
<ExtentSize>2000000</ExtentSize>
<IdLocation>^GC.Xltek.PV1D</IdLocation>
<IndexLocation>^GC.Xltek.PV1I</IndexLocation>
<StreamLocation>^GC.Xltek.PV1S</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
