/// Copyright 2007 by Inland Imaging Business Associates
/// Class used to send emails from Ensemble Productions through IIBAENSEMBLE.Bop.SendEmail operation
Class IIBAENSEMBLE.msg.EmailSendRequest Extends Ens.Request [ ClassType = persistent, ProcedureBlock ]
{

Property Text As %String(MAXLEN = 32768);

/// Email From field can be blank when sending through IIBAENSEMBLE.Bop.SendEmail operation.  It uses the email on that configuration page.
Property From As %String(MAXLEN = 255);

/// Email To field.  Emails should be comma separated when sending through IIBAENSEMBLE.Bop.SendEmail operation.
Property Destination As %String(MAXLEN = 512);

Property Subject As %String(MAXLEN = 255);

Property AttDir As %String(MAXLEN = 255);

Property AttFile As %String(MAXLEN = 255);

Storage Default
{
<Data name="EmailSendRequestDefaultData">
<Subscript>"EmailSendRequest"</Subscript>
<Value name="1">
<Value>Destination</Value>
</Value>
<Value name="2">
<Value>Subject</Value>
</Value>
<Value name="3">
<Value>Text</Value>
</Value>
<Value name="4">
<Value>AttDir</Value>
</Value>
<Value name="5">
<Value>AttFile</Value>
</Value>
<Value name="6">
<Value>From</Value>
</Value>
</Data>
<DefaultData>EmailSendRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
