Class IIBAENSEMBLE.HistoricUpload.Queue Extends %Persistent
{

Property SourceIdentifier As %String;

Property MessageId As %String;

Property Processed As %Boolean [ InitialExpression = 0 ];

//set oref.CreatedOn = $ZDT($h,3,1) //Task Item Definitions, ItemType='ClassObjectPurge'

Property CreatedOn As %TimeStamp;

Storage Default
{
<Data name="QueueDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>SourceIdentifier</Value>
</Value>
<Value name="3">
<Value>MessageId</Value>
</Value>
<Value name="4">
<Value>Processed</Value>
</Value>
<Value name="5">
<Value>CreatedOn</Value>
</Value>
</Data>
<DataLocation>^IIBAENSEMBLE.Histori34DC.QueueD</DataLocation>
<DefaultData>QueueDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^IIBAENSEMBLE.Histori34DC.QueueD</IdLocation>
<IndexLocation>^IIBAENSEMBLE.Histori34DC.QueueI</IndexLocation>
<StreamLocation>^IIBAENSEMBLE.Histori34DC.QueueS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
