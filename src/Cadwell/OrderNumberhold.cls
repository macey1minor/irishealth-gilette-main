/// Cadwell ORU- Store Order_id to check for OBR;25
Class Cadwell.OrderNumberhold Extends %Persistent
{

Index OrderNumberIDX On OrderNumber [ IdKey ];

Property OrderNumber As %String;

ClassMethod Find(pOrderNumber As %String) As %Boolean
{
	q $ISOBJECT( ..%OpenId(pOrderNumber) )
}

ClassMethod Insert(pOrderNumber As %String) As %Status
{
    #dim tSC As %Status = $$$OK
    s newOrder = ##class(Cadwell.OrderNumberhold).%New()
    s newOrder.OrderNumber = pOrderNumber
    s tSC = newOrder.%Save()
    q tSC
}

Storage Default
{
<Data name="OrderNumberDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>OrderNumber</Value>
</Value>
</Data>
<DataLocation>^Cadwell.OrderNumberholdD</DataLocation>
<DefaultData>OrderNumberDefaultData</DefaultData>
<IdLocation>^Cadwell.OrderNumberholdD</IdLocation>
<IndexLocation>^Cadwell.OrderNumberholdI</IndexLocation>
<StreamLocation>^Cadwell.OrderNumberholdS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
