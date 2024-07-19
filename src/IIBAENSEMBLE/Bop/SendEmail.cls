/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Bop.SendEmail Extends Ens.BusinessOperation [ ProcedureBlock ]
{

Parameter ADAPTER = "EnsLib.EMail.OutboundAdapter";

Parameter INVOCATION = "Queue";

Method EmailSend(pRequest As IIBAENSEMBLE.msg.EmailSendRequest, Output pResponse As Ens.Response) As %Status
{

	If pRequest.Destination="" $$$TRACE("no email address.") Quit $$$OK
	$$$TRACE("send email to "_pRequest.Destination)
	Set tMailMessage=##class(%Net.MailMessage).%New()
	for i = 1:1:$L(pRequest.Destination,",") {
		Do tMailMessage.To.Insert($P(pRequest.Destination,",",i))
	}
	Set tMailMessage.Subject=pRequest.Subject
	set tMailMessage.Charset="iso-8859-1"
	Set tSC=tMailMessage.TextData.Write(pRequest.Text)  Quit:$$$ISERR(tSC) tSC
	If ((pRequest.AttDir '= "")&&(pRequest.AttFile '= "")){
		set tSC = tMailMessage.AttachFile(pRequest.AttDir, pRequest.AttFile,0,"iso-8859-1",.count) Quit:$$$ISERR(tSC)
	}
	
	if pRequest.From '= "" {
		set tMailMessage.From = pRequest.From
	}
	
	
	Set tSC=..Adapter.SendMail(tMailMessage)
	
	If ((pRequest.AttDir '= "")&&(pRequest.AttFile '= "")){
		set tDelete = ##class(%File).Delete(pRequest.AttDir_"\"_pRequest.AttFile)
		if tDelete '= 1 { $$$LOGERROR("Email File Delete failed for: "_pRequest.AttDir_"\"_pRequest.AttFile) }
	}
	
	Quit tSC
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="IIBAENSEMBLE.msg.EmailSendRequest"> 
		<Method>EmailSend</Method>
	</MapItem>
</MapItems>
}

}
