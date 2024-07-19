Class GC.Xltek.ORMXML Extends (%Persistent, %Populate, %XML.Adaptor, Ens.Request) [ ClassType = persistent, Inheritance = right ]
{

Parameter XMLNAME As %String = "HL7";

Property HL7Message As GC.Xltek.HL7Message;

Storage Default
{
<Data name="ORMXMLDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>HL7Message</Value>
</Value>
</Data>
<DataLocation>^GC.Xltek.ORMXMLD</DataLocation>
<DefaultData>ORMXMLDefaultData</DefaultData>
<ExtentSize>2000000</ExtentSize>
<IdLocation>^GC.Xltek.ORMXMLD</IdLocation>
<IndexLocation>^GC.Xltek.ORMXMLI</IndexLocation>
<StreamLocation>^GC.Xltek.ORMXMLS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
