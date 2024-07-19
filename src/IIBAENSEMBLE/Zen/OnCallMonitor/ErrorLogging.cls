Class IIBAENSEMBLE.Zen.OnCallMonitor.ErrorLogging Extends %Persistent
{

Property SessionId As %Integer;

Property InputDateTime As %TimeStamp [ Required ];

Property MessageId As %String [ Required ];

Property NameSpace As %String [ Required ];

Property LogReason As %String;

Index IdKey On MessageId [ IdKey, Unique ];

/// Indexing control methods.
/// set tSC =##class(IIBAENSEMBLE.Zen.OnCallMonitor.ErrorLogging).IdKeyExists(SessionId,.id) Quit:tSC'=$$$OK
/// set tMsg=##class(IIBAENSEMBLE.Zen.OnCallMonitor.ErrorLogging).IdKeyOpen(id,1)
/// set tSC=##class(IIBAENSEMBLE.Zen.OnCallMonitor.ErrorLogging).IdKeyDelete(id,1) Quit:tSC'=$$$OK

Storage Default
{
<Data name="ErrorLoggingDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>InputDateTime</Value>
</Value>
<Value name="3">
<Value>MessageId</Value>
</Value>
<Value name="4">
<Value>NameSpace</Value>
</Value>
<Value name="5">
<Value>LogReason</Value>
</Value>
<Value name="6">
<Value>SessionId</Value>
</Value>
</Data>
<DataLocation>^IIBAENSEMBLEFCC9.ErrorLoggingD</DataLocation>
<DefaultData>ErrorLoggingDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^IIBAENSEMBLEFCC9.ErrorLoggingD</IdLocation>
<IndexLocation>^IIBAENSEMBLEFCC9.ErrorLoggingI</IndexLocation>
<StreamLocation>^IIBAENSEMBLEFCC9.ErrorLoggingS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
