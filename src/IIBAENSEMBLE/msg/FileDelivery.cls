Class IIBAENSEMBLE.msg.FileDelivery Extends Ens.Request
{

Property FilePath As %String(MAXLEN = 100);

Property FileSpec As %String(MAXLEN = 512);

Property ArchivePath As %String(MAXLEN = 100);

Property ArchiveDays As %String;

Storage Default
{
<Data name="FileDeliveryDefaultData">
<Subscript>"FileDelivery"</Subscript>
<Value name="1">
<Value>FilePath</Value>
</Value>
<Value name="2">
<Value>FileSpec</Value>
</Value>
<Value name="3">
<Value>ArchivePath</Value>
</Value>
<Value name="4">
<Value>ArchiveDays</Value>
</Value>
</Data>
<DefaultData>FileDeliveryDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
