/// 
Class IIBAENSEMBLE.msg.xRefImport Extends Ens.Request [ ClassType = persistent, ProcedureBlock ]
{

Property SessionId As %String;

Property filetimestamp As %String;

Property filename As %String(MAXLEN = 255);

Property importType As %String;

Storage Default
{
<Data name="xRefImportDefaultData">
<Subscript>"xRefImport"</Subscript>
<Value name="1">
<Value>SessionId</Value>
</Value>
<Value name="2">
<Value>filename</Value>
</Value>
<Value name="3">
<Value>filetimestamp</Value>
</Value>
<Value name="4">
<Value>importType</Value>
</Value>
</Data>
<DefaultData>xRefImportDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
