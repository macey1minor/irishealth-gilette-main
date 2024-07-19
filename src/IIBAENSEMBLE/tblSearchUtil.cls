/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.tblSearchUtil Extends %Persistent [ SqlTableName = tblSearchUtil ]
{

Property cspsessionID As %String(MAXLEN = 255);

Property msgbodyID As %String(MAXLEN = 255);

Property msgID As %String(MAXLEN = 255);

Property msgsessionID As %String(MAXLEN = 255);

Property sourceID As %String(MAXLEN = 255);

Property Status As Ens.DataType.MessageStatus;

Property TimeCreated As Ens.DataType.UTC;

Property TimeProcessed As Ens.DataType.UTC;

Storage Default
{
<Data name="tblSearchUtilDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>cspsessionID</Value>
</Value>
<Value name="3">
<Value>msgID</Value>
</Value>
<Value name="4">
<Value>msgbodyID</Value>
</Value>
<Value name="5">
<Value>msgsessionID</Value>
</Value>
<Value name="6">
<Value>sourceID</Value>
</Value>
<Value name="7">
<Value>TimeCreated</Value>
</Value>
<Value name="8">
<Value>TimeProcessed</Value>
</Value>
<Value name="9">
<Value>Status</Value>
</Value>
</Data>
<DataLocation>^IIBAENSEMBLE.tblSearchUtilD</DataLocation>
<DefaultData>tblSearchUtilDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^IIBAENSEMBLE.tblSearchUtilD</IdLocation>
<IndexLocation>^IIBAENSEMBLE.tblSearchUtilI</IndexLocation>
<StreamLocation>^IIBAENSEMBLE.tblSearchUtilS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
