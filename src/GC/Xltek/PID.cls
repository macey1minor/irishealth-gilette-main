Class GC.Xltek.PID Extends (%Persistent, %Populate, %XML.Adaptor, Ens.Response) [ ClassType = persistent, Inheritance = right ]
{

Property PatientIDInternal As %String;

Property PatientLastName As %String;

Property PatientFirstName As %String;

Property PatientDateTimeofBirth As %String;

Property PatientSex As %String;

Property PatientStreetAddress As %String;

Property PatientCity As %String;

Property PatientStateorProvince As %String;

Property PatientZiporPostalCode As %String;

Property PatientCountry As %String;

Property PatientHomePhone As %String;

Property BillingID As %String;

Property ChartNo As %String;

Storage Default
{
<Data name="PIDDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>PatientIDInternal</Value>
</Value>
<Value name="3">
<Value>PatientLastName</Value>
</Value>
<Value name="4">
<Value>PatientFirstName</Value>
</Value>
<Value name="5">
<Value>PatientDateTimeofBirth</Value>
</Value>
<Value name="6">
<Value>PatientSex</Value>
</Value>
<Value name="7">
<Value>PatientStreetAddress</Value>
</Value>
<Value name="8">
<Value>PatientCity</Value>
</Value>
<Value name="9">
<Value>PatientStateorProvince</Value>
</Value>
<Value name="10">
<Value>PatientZiporPostalCode</Value>
</Value>
<Value name="11">
<Value>PatientCountry</Value>
</Value>
<Value name="12">
<Value>PatientHomePhone</Value>
</Value>
<Value name="13">
<Value>BillingID</Value>
</Value>
<Value name="14">
<Value>ChartNo</Value>
</Value>
</Data>
<DataLocation>^GC.Xltek.PIDD</DataLocation>
<DefaultData>PIDDefaultData</DefaultData>
<ExtentSize>2000000</ExtentSize>
<IdLocation>^GC.Xltek.PIDD</IdLocation>
<IndexLocation>^GC.Xltek.PIDI</IndexLocation>
<StreamLocation>^GC.Xltek.PIDS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
