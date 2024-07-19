/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Operation.BARTcpOperation Extends EnsLib.HL7.Operation.TCPOperation [ ProcedureBlock ]
{

Property AeRetryCount As %Integer;

Parameter SETTINGS = "AeRetryCount";

Method OnMessage(pRequest As EnsLib.HL7.Message, Output pResponse As EnsLib.HL7.Message) As %Status
{
	#; Send the message and get reply if any
	Set pResponse=$$$NULLOREF
	
	Set tSC=..validateAndIndex(pRequest) Quit:$$$ISERR(tSC) tSC
	
	Set tESN=$G($$$ExpectedSequenceNumber) Set:'tESN tESN=""
	Set tSC=..Adapter.HL7Message(pRequest,.tReplyMsg,tESN) Quit:$$$ISERR(tSC) tSC
	Set:tESN $$$ExpectedSequenceNumber=tESN+1

	If ""'=..SearchTableClass {
		Set tSCStore=$zobjclassmethod(..SearchTableClass,"IndexDoc",pRequest)
		If $$$ISERR(tSCStore) $$$LOGWARNING("Failed to construct SearchTable instance for message "_pRequest_"/"_pRequest.%Id()_" with DocType='"_pRequest.DocType_"' using class '"_..SearchTableClass_"' "_$$$StatusDisplayString(tSCStore))
	}
	If $IsObject(tReplyMsg) {
		Set tControlId=pRequest.GetValueAt("1:10")
		Set tReplyMsg.Source=pRequest.%Id()_$C(13,10)_..Adapter.IPAddress_":"_..Adapter.Port
	} Else { Set tControlId="" }
	Do ..OnReplyDocument(.tReplyMsg)
	If $IsObject(tReplyMsg) {
		Set tAckType=tReplyMsg.Name
		$$$sysTRACE("Got reply message "_tReplyMsg_"/"_tReplyMsg.%Id()_" of type "_tAckType)
		If ..#SetReplyDocType && (""'=..%RequestHeader.ReturnQueueName) && (""=tReplyMsg.DocType) && (""'=pRequest.MessageTypeCategory) {
			Do tReplyMsg.PokeTypeCategory(pRequest.MessageTypeCategory)
			Do ##class(EnsLib.HL7.Schema).ResolveReplyNameAndDocType(pRequest.MessageTypeCategory_":"_pRequest.Name,.tReplyDocName,.tReplyDocType)
			If tReplyDocName'=tAckType {
				Set tReplyDocType=##class(EnsLib.HL7.Schema).ResolveSchemaTypeToDocType(pRequest.MessageTypeCategory,tAckType)
			}
			Do:""'=tReplyDocType tReplyMsg.PokeDocType(tReplyDocType)
		}
		Set tReplyMsg.IsMutable=0
		set tMSA=tReplyMsg.GetSegmentAt(2)
		Set tAckType=$P(tAckType,"_"), tMSACode=$S($IsObject(tMSA)&&("MSA"=tMSA.GetValueAt(0)):tMSA.GetValueAt(1), 1:"No MSA")
		Set tCode=$Case(tMSACode,"No MSA":-1,"AA":0,"CA":0,"AE":1,"CE":1,"AR":2,"CR":2,:3)
		If ..#SaveOKACKs || ("ACK"'=tAckType) || tCode {
			#; Save replies if they are not normal ACKs or if we are built to save all
			If ""'=..SearchTableClass && ..#IndexReplies {
				Set tSCStore=$zobjclassmethod(..SearchTableClass,"IndexDoc",tReplyMsg)
				If $$$ISERR(tSCStore) $$$LOGWARNING("Failed to construct SearchTable instance for message "_tReplyMsg_"/"_tReplyMsg.%Id()_" with DocType='"_tReplyMsg.DocType_"' using class '"_..SearchTableClass_"' "_$$$StatusDisplayString(tSCStore))
			} Else {
				Set tSCStore=tReplyMsg.%Save()
				If $$$ISERR(tSCStore) $$$LOGERROR("Failed to save reply message "_tReplyMsg_"/"_tReplyMsg.%Id()_" with DocType='"_tReplyMsg.DocType_"' "_$$$StatusDisplayString(tSCStore))
			}
		}
		If ..#WarnACKControlId&&(tCode>=0) {
			Set tControlId=$S(""'=tControlId:$P(tControlId,$C(13,10)), 1:pRequest.GetValueAt("1:10"))
			If tControlId'=tMSA.GetValueAt(2) { $$$LOGWARNING("HL7 reply message "_tReplyMsg_"/"_tReplyMsg.%Id()_" MSA:2 ControlId '"_tMSA.GetValueAt(2)_"' does not match original message ControlId '"_tControlId_"'") }
		}
		If tCode=0 {
			Set pResponse = tReplyMsg
		} ElseIf tCode=1 {
			// Set ..Retry=1
			//$$$sysTRACE("Retrying HL7 Message "_pRequest_"/"_pRequest.%Id()_" because ACK "_tReplyMsg_"/"_tReplyMsg.%Id()_" has MSA.AcknowledgementCode = '"_tMSACode_"'")
			set aers=##class(%ResultSet).%New("Ens.Util.Statistics:EnumerateJobStatus")
			s sc=aers.Execute(..%ConfigName)
			d aers.Next()
			s retry=aers.Data("Retry")
			If ( retry<..AeRetryCount) {
				set ..Retry=1
				$$$LOGWARNING("Retry on AE : HL7 Message "_pRequest_"/"_pRequest.%Id())
			} else {
				Set sMsaText=$S($IsObject(tMSA)&&("MSA"=tMSA.GetValueAt(0)):tMSA.GetValueAt(3)_" "_tMSA.GetValueAt(6), 1:"No MSA")
				$$$LOGWARNING("HL7 Message "_pRequest_"/"_pRequest.%Id()_" - ACK "_tReplyMsg_"/"_tReplyMsg.%Id()_" has MSA.AcknowledgementCode = '"_tMSACode_"' / "_sMsaText_" / ")
				Set pResponse = tReplyMsg
			}
		} ElseIf tCode>1 || '..#AllowNonMSA {
			Set ..SuspendMessage=1
			Do ..SendAlert(##Class(Ens.AlertRequest).%New($LB(..%ConfigName,"Suspended HL7 Message "_pRequest_"/"_pRequest.%Id()_" because ACK "_tReplyMsg_"/"_tReplyMsg.%Id()_" has MSA.AcknowledgementCode = '"_tMSACode_"'")))
		} Else { ; tCode<0 && AllowNonMSA
			$$$LOGWARNING("Accepting HL7 reply Message "_tReplyMsg_"/"_tReplyMsg.%Id()_" that has no MSA:1 field; MSH='"_tReplyMsg.GetValueAt(1)_"'")
			Set pResponse = tReplyMsg
		}
	}
	Quit tSC
}

}
