Class GC.Xltek.HL7Message Extends (%Persistent, %Populate, %XML.Adaptor, Ens.Response) [ ClassType = persistent, Inheritance = right ]
{

Property MSH As GC.Xltek.MSH;

Property PID As GC.Xltek.PID;

Property PV1 As GC.Xltek.PV1;

Property ORC As %String;

Property OBR As %String;

Property OBX As GC.Xltek.OBX;

Storage Default
{
<Data name="HL7MessageDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>MSH</Value>
</Value>
<Value name="3">
<Value>PID</Value>
</Value>
<Value name="4">
<Value>PV1</Value>
</Value>
<Value name="5">
<Value>ORC</Value>
</Value>
<Value name="6">
<Value>OBR</Value>
</Value>
<Value name="7">
<Value>OBX</Value>
</Value>
</Data>
<DataLocation>^GC.Xltek.HL7MessageD</DataLocation>
<DefaultData>HL7MessageDefaultData</DefaultData>
<ExtentSize>2000000</ExtentSize>
<IdLocation>^GC.Xltek.HL7MessageD</IdLocation>
<IndexLocation>^GC.Xltek.HL7MessageI</IndexLocation>
<StreamLocation>^GC.Xltek.HL7MessageS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
