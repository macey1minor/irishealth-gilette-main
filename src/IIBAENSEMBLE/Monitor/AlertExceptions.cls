/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Monitor.AlertExceptions Extends (%Persistent, %XML.Adaptor) [ Inheritance = right ]
{

Property ExceptionId As %Integer [ Required ];

Property ItemName As %String(MAXLEN = 255) [ Required ];

Property StartDttm As %TimeStamp [ Required ];

Property EndDttm As %TimeStamp [ Required ];

Property Comment As %String(MAXLEN = 255);

Storage Default
{
<Data name="AlertExceptionsDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Comment</Value>
</Value>
<Value name="3">
<Value>EndDttm</Value>
</Value>
<Value name="4">
<Value>ItemName</Value>
</Value>
<Value name="5">
<Value>StartDttm</Value>
</Value>
<Value name="6">
<Value>ExceptionId</Value>
</Value>
</Data>
<DataLocation>^IIBAENSEMBL676.AlertExcepti61AD</DataLocation>
<DefaultData>AlertExceptionsDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^IIBAENSEMBL676.AlertExcepti61AD</IdLocation>
<IndexLocation>^IIBAENSEMBL676.AlertExcepti61AI</IndexLocation>
<StreamLocation>^IIBAENSEMBL676.AlertExcepti61AS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
