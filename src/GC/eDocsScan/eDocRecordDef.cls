Class GC.eDocsScan.eDocRecordDef Extends Ens.Request
{

Property rank As %String;

Property systemID As %String;

Property creationDate As %String;

Property mrn As %String;

Property account As %String;

Property firstName As %String;

Property lastName As %String;

Property DOB As %String;

Property documentTypeID As %String(MAXLEN = 500);

Property documentType As %String(MAXLEN = 500);

Property docDescription As %String(MAXLEN = 500);

Property admitDate As %String;

Property dischargeDate As %String;

Property linkUrl As %String(MAXLEN = 500);

Property versionNbr As %String;

Property msgID As %String(MAXLEN = 500);

Storage Default
{
<Data name="eDocRecordDefDefaultData">
<Subscript>"eDocRecordDef"</Subscript>
<Value name="1">
<Value>rank</Value>
</Value>
<Value name="2">
<Value>systemID</Value>
</Value>
<Value name="3">
<Value>creationDate</Value>
</Value>
<Value name="4">
<Value>mrn</Value>
</Value>
<Value name="5">
<Value>account</Value>
</Value>
<Value name="6">
<Value>firstName</Value>
</Value>
<Value name="7">
<Value>lastName</Value>
</Value>
<Value name="8">
<Value>DOB</Value>
</Value>
<Value name="9">
<Value>documentTypeID</Value>
</Value>
<Value name="10">
<Value>documentType</Value>
</Value>
<Value name="11">
<Value>docDescription</Value>
</Value>
<Value name="12">
<Value>admitDate</Value>
</Value>
<Value name="13">
<Value>dischargeDate</Value>
</Value>
<Value name="14">
<Value>linkUrl</Value>
</Value>
<Value name="15">
<Value>versionNbr</Value>
</Value>
<Value name="16">
<Value>msgID</Value>
</Value>
</Data>
<DefaultData>eDocRecordDefDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
