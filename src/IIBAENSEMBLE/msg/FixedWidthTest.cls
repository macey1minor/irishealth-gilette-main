Class IIBAENSEMBLE.msg.FixedWidthTest Extends Ens.Request
{

Property NewProperty1 As %String(CAPTION = "L ", MAXLEN = 12);

Property NewProperty2 As %String(CAPTION = "R ", MAXLEN = 10);

Property NewProperty3 As %String(CAPTION = "L ", MAXLEN = 20);

Storage Default
{
<Data name="FixedWidthTestDefaultData">
<Subscript>"FixedWidthTest"</Subscript>
<Value name="1">
<Value>NewProperty1</Value>
</Value>
<Value name="2">
<Value>NewProperty2</Value>
</Value>
<Value name="3">
<Value>NewProperty3</Value>
</Value>
</Data>
<DefaultData>FixedWidthTestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
