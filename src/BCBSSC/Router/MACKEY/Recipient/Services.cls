Include HS.IHE.XDSb

Class BCBSSC.Router.MACKEY.Recipient.Services Extends (HS.IHE.Common.Services.SOAPServer.Base, HS.IHE.Common.Actor.Base) [ Inheritance = right ]
{

/// This is the namespace used by the Service
Parameter NAMESPACE = "urn:ihe:iti:2007";

/// Use xsi:type attribute for literal types.
Parameter OUTPUTTYPEATTRIBUTE = 1;

/// This is the name of the Service
Parameter SERVICENAME = "DocumentRecipient_Service";

Parameter SETTINGS = "ProvideAndRegisterTarget,ProvideAndRegisterResponseTarget";

Property ProvideAndRegisterTarget As Ens.DataType.ConfigName;

Property ProvideAndRegisterResponseTarget As Ens.DataType.ConfigName;

Method OnProcessInput(pRequest As HS.Message.XMLMessage, Output pResponse As HS.Message.XMLMessage = {$$$NULLOREF}) As %Status [ ServerOnly = 1 ]
{
	#dim eException As %Exception.AbstractException
	
	Set tStatus = $$$OK
	//$$$LOGINFO("Process input")
	set ^zDebug = "Process input"
	Try {
		Set tAction = pRequest.AdditionalInfo.GetAt("SOAPAction")
		If ..isAsync Set pResponse = ##class(HS.Message.XMLMessage).%New()

		Set tHeader=..HeadersIn.GetAt("addressBlock")
		If $isObject(tHeader) {
			Do pRequest.AdditionalInfo.SetAt(tHeader.from,"Direct:FROM")
			Set tTo=""
			For tIdx=1:1:tHeader.to.Count() {
				Set tTo=tTo_";"_tHeader.to.GetAt(tIdx)
			}
			Do pRequest.AdditionalInfo.SetAt($e(tTo,2,*),"Direct:TO")
			; can set metadata-level here, but the value in the metadata-level header takes priority over this one
			Do pRequest.AdditionalInfo.SetAt(tHeader.Level,"Direct:METADATA-LEVEL")
		}
		Set tHeader=..HeadersIn.GetAt("metadata-level")
		If $isObject(tHeader) {
			if (tHeader.Level'=""){ ; takes priority over the value in addressBlock
				Do pRequest.AdditionalInfo.SetAt(tHeader.Level,"Direct:METADATA-LEVEL")
			}
		}
		
		If (tAction = $$$XDRProvideAndRegisterAction(1)) {
			Set pRequest.Name = $$$XDRProvideAndRegisterRequest
			Set tStatus = ..ProvideAndRegister(pRequest, .pResponse)
			Throw:$$$ISERR(tStatus) ##class(%Exception.StatusException).CreateFromStatus(tStatus)
		}
		ElseIf (tAction = $$$XDRProvideAndRegisterResponseAction(1)) {
			Set pRequest.Name = $$$XDRProvideAndRegisterResponse
			Set tStatus = ..ProvideAndRegisterResponse(pRequest, .pResponse)
			Throw:$$$ISERR(tStatus) ##class(%Exception.StatusException).CreateFromStatus(tStatus)
		}
		Else {
			Set tStatus = $$$EnsError("Unknown SOAP action:  " _ tAction)
			Throw ##class(%Exception.StatusException).CreateFromStatus(tStatus)
		}
	}
	Catch eException {
		$$$LOGERROR(eException.DisplayString())

		Set tStatus = eException.AsStatus()
	}
	
	Quit tStatus
}

/// DOC_RECIPIENT - ITI-41 
Method ProvideAndRegister(pRequest As HS.Message.XMLMessage, Output pResponse As HS.Message.XMLMessage) As %Status [ ProcedureBlock = 1, SoapAction = "urn:ihe:iti:2007:ProvideAndRegisterDocumentSet-b", SoapBindingStyle = document, SoapBodyUse = literal, WebMethod ]
{
	#dim eException As %Exception.AbstractException
	
	Set tStatus = $$$OK
	set ^zDebug = "Provide and Register"
	Try {
		Do ..SetAddressingOut($$$XDSbProvideAndRegisterResponseAction(1))
		if ..isAsync {
			Set tStatus = ..SendRequestAsync(..ProvideAndRegisterTarget, pRequest)
		} Else {
			Set tStatus = ..SendRequestSync(..ProvideAndRegisterTarget, pRequest, .pResponse)
		}
		Throw:$$$ISERR(tStatus) ##class(%Exception.StatusException).CreateFromStatus(tStatus)
	}
	Catch eException {
		Set tStatus = eException.AsStatus()
	}

	Quit tStatus
}

Method ProvideAndRegisterResponse(pRequest As HS.Message.XMLMessage, Output pResponse As HS.Message.XMLMessage) As %Status [ ProcedureBlock = 1, SoapAction = "urn:ihe:iti:2007:ProvideAndRegisterDocumentSet-bResponse", SoapBindingStyle = document, SoapBodyUse = literal, WebMethod ]
{
	#dim eException As %Exception.AbstractException
	
	Set tStatus = $$$OK
	
	Try {
		if ..isAsync {
			Set tStatus = ..SendRequestAsync(..ProvideAndRegisterResponseTarget, pRequest)
		} Else {
			Set tStatus = ..SendRequestSync(..ProvideAndRegisterResponseTarget, pRequest, .pResponse)
		}
		Throw:$$$ISERR(tStatus) ##class(%Exception.StatusException).CreateFromStatus(tStatus)
	}
	Catch eException {
		Set tStatus = eException.AsStatus()
	}

	Quit tStatus
}

/// Override version in %SOAP.WebService to troubleshoot Mackey header issue
/// Process a SOAP request.  Initialize must be called first.<br>
/// The pAction argument contains the value of SOAPAction header.<br>
/// The request argument contains the SOAP request.  For a normal SOAP request, the request
/// argument will be a stream containing the request.  For a SOAP with Attachments format request,
/// the request argument will be a multidimensional array of %CSP.Streams that is subscripted 
/// by the position in the original multipart message.  request(1) is the SOAP message.<br>
/// The needHeaders argument specifies if HTTP headers need to be output before the SOAP message.
/// Normally the transport class will be responsible for any transport such as HTTP headers.<br>
/// 
/// If the SoapFault property is set up before calling Process, then a SOAP fault is 
/// written instead of calling the web method.<br>
/// The SessionCookie property may be set before calling Process to force value of SessionCookie.
/// 
/// This method is meant to be used by SOAP transport classes.
Method Process(pAction As %String, ByRef request, needHeaders As %Boolean = 1) [ ServerOnly = 1 ]
{
	// Indicate that we are in web service
	Set %cspsoapservice=$this
	Set ^zNew = "In Process method"
	Set sc=$$$OK
	Set ..Action=pAction
	Set ..OneWay=""
	
	Set $zt="ProcessSOAPError"
	Set inProcessBody=0
	
	#; Log Http headers
	$$$SOAPLogInputHTTPHeaders

	//Rmoved this condition: ||
	//		   (tmparray("type")="application/xop+xml" && ($get(tmparray("start-info"))=""))
	$$$SOAPTimer("s1")
	Set requestAttachments=""
	Set ..IsMTOM=0
	If $get(request)="" {
		If $isobject($get(%request)) {
			Set contenttype=%request.CgiEnvs("CONTENT_TYPE")
			If ($zcvt($piece(contenttype,";",1),"L")'="multipart/related") ||
			   ##class(%Net.HttpRequest).ParseContent($piece(contenttype,";",2,$length(contenttype,";")),.tmparray) ||
			   $case($get(tmparray("type")),"text/xml":0,"application/xop+xml":0,"application/soap+xml":0,:1)  {
					Set sc=$$$ERROR($$$SOAPBadMultipart,contenttype_"(type="_$get(tmparray("type"))_")")
					Set FaultCode=$$$FAULTClient
					Set FaultReason=$$$FormatMessage("","%ObjectErrors",$$$ERRORCODE($$$SOAPClientError))
					Goto ProcessSOAPExit
			}
			If tmparray("type")="application/xop+xml" {
				// If no SOAPAction, use the action parameter
				If (pAction="") && (..SoapVersion="1.2") {
					Set pAction=$get(tmparray("action"))
					Set ..Action=pAction
				}
				If ..SoapVersion="" {
					Set ..SoapVersion=$select(tmparray("start-info")'="text/xml":"1.1",1:"1.2")
				}
				Set requestAttachments=..Attachments
				Set ..IsMTOM=1
				Set start=##class(%Net.MIMEPart).NormalizeContentId($get(tmparray("start")))
				Set startindex=$select(start="":1,1:0)
			} ElseIf tmparray("type")="application/soap+xml" {
				// If no SOAPAction, use the action parameter
				If (pAction="") && (..SoapVersion="1.2") {
					Set pAction=$get(tmparray("action"))
					Set ..Action=pAction
				}
				Set requestAttachments=..Attachments
				Set start=##class(%Net.MIMEPart).NormalizeContentId($get(tmparray("start")))
				Set startindex=$select(start="":1,1:0)
			} Else {
				If ..SoapVersion="" {
					Set ..SoapVersion=$select(tmparray("type")'="text/xml":"1.1",1:"1.2")
				}
				Set start=""
				Set startindex=1
			}
		} Else {
			Set ..SoapVersion="1.1"
			Set start=""
			Set startindex=1
		}
		If ..SoapFault'="" Goto ProcessSOAPExit
		
		Set index=$order(request(""))
		While index'="" {
			Set ^zDebug = "While index - processing attachments"
			Set part=##class(%Net.MIMEPart).%New(request(index))
			Do ..Attachments.Insert(part)
			Set headers=$tr(request(index).GetAttribute("Headers"),$c(13),"")
			If headers'="" {
				Set len=$length(headers,$c(10))
				For i=1:1:len {
					Set header=$piece(headers,$c(10),i)
					Set name=$zcvt($zstrip($piece(header,":",1),"<>W"),"U")
					Set value=$zstrip($piece(header,":",2,$length(header,":")),"<>W")
					If name="CONTENT-ID" {
						Set part.ContentId=##class(%Net.MIMEPart).NormalizeContentId(value)
					} ElseIf name="CONTENT-LOCATION" {
						Set part.ContentLocation=##class(%Net.MIMEPart).NormalizeContentLocation(value)
					}
				}
			}
			
			If (startindex=0) && (start=part.ContentId) {
				Set startindex=index
			}
			Set index=$order(request(index))
		}
		If startindex=0 {
			Set sc=$$$ERROR($$$SOAPBadMultipart,contenttype_" (start="_start_")")
			Set FaultCode=$$$FAULTClient
			Set FaultReason=$$$FormatMessage("","%ObjectErrors",$$$ERRORCODE($$$SOAPClientError))
			Goto ProcessSOAPExit
		}
		Set requestStream=request(startindex)
		Set part=..Attachments.GetAt(startindex)
		Set ..ContentId=part.ContentId
		Set ..ContentLocation=part.ContentLocation
		Do ..Attachments.RemoveAt(startindex)
	} Else {
		If $isobject($get(%request)) {
			Set contenttype=$get(%request.CgiEnvs("CONTENT_TYPE"))
			// If no SOAPAction, use the action parameter
			If (pAction="") && (..SoapVersion="1.2") &&
			   ($zcvt($piece(%request.CgiEnvs("CONTENT_TYPE"),";",1),"L")="application/soap+xml") &&
			   '##class(%Net.HttpRequest).ParseContent($piece(contenttype,";",2,$length(contenttype,";")),.tmparray) {
					Set pAction=$get(tmparray("action"))
					Set ..Action=pAction
			}
			If (..SoapVersion="") {
				Set ..SoapVersion=$select($zcvt($piece(contenttype,";",1),"L")="application/soap+xml":"1.2",1:"1.1")
			}
		} Else {
			Set ..SoapVersion="1.1"
		}
		If ..SoapFault'="" Goto ProcessSOAPExit
		Set requestStream=request
	}
	
	#; Process session and security headers
	Set headers=..#SOAPHEADERS
	If headers="" {
		Set headers="CSPCHD:%SOAP.SessionHeader"
	} Else {
		Set headers=","_headers
		If headers'[",CSPCHD:" Set headers=headers_",CSPCHD:%SOAP.SessionHeader"
		Set headers=$extract(headers,2,*)
	}
	Set ..SoapHeaders=headers

	#; Check the SOAP envelope
	$$$SOAPTimer("s2")
	Do ..HeadersIn.Clear()
	Set ^zDebug = "Check SOAP envelope"
	If ..SecurityIn'="" {
		Do ..HeadersIn.SetAt(..SecurityIn,"Security")
		Set ..SecurityContextToken=..SecurityIn.SecurityContextToken
	} Else {
		Set ..SecurityContextToken=""
	}
	Set handler=..ImportHandler
	Set ^zDebug = "Before CheckSOAPEnvelope call"
	Set sc=..CheckSOAPEnvelope(.handler,1,.soapenv,.message,.messageChildlist,.versionMismatch)
	Set ^zDebug = "After CheckSOAPEnvelope call"
	If message="" && $isobject($get(request)) && (request.%Extends("%Library.AbstractStream")||(request.%Extends("%CSP.Stream"))) {
		Set ^zDebug = "Setting requestBody"
		Set requestBody=request.GetAttribute("BodyStream")
		Set:$IsObject(requestBody)&&$system.Status.Equals(sc,$$$ERRORCODE($$$SOAPNoBody)) sc=$$$OK
	} Else { Set requestBody=$$$NULLOREF }
	If $$$ISOK(sc) {
		#; check that incoming message version matches specified SOAPVERSION
		Set requestVersion=..#REQUESTVERSION
		If requestVersion'="",requestVersion'=..SoapVersion {
			Set versionMismatch=-1
			Set sc=$$$ERROR($$$VersionError,$select(requestVersion="1.1":$$$SOAPENVns,1:$$$SOAP12ENVns))
		}
	}
	If $$$ISOK(sc) {
		#; Instantiate a message descriptor class for this web method.
		Set msgService=$this
		Set pAction=$translate(pAction,"""")
		If (pAction="") && $isobject(..AddressingIn) {
			Set pAction=..AddressingIn.Action
			Set ..Action=pAction
		}
		#; User callback
		Set ^zDebug = "Before OnRequestMessage call"
		Do ..OnRequestMessage("SOAP",..Action,requestStream)
		Set ^zDebug = "After OnRequestMessage call"
		If ..SoapFault'="" Goto ProcessSOAPExit
		Set className=..GetMsgClass(pAction,messageChildlist,.methodName,requestBody)
		If className'="" {
			Try {
				Set msgClass=$zobjclassmethod(className_"."_methodName,"%New")
			} Catch {
				Set msgClass=""
			}
		} Else {
			Set msgClass=""
		}
		If $isobject(msgClass) {
			If msgClass.%ResponseName="" Set msgClass.%ResponseName=methodName_"Response"
			Set ..MsgClass=msgClass
			Set ..MethodName=methodName
			Set useProcessBody=$$$comMemberKeyGet($zobjclass(),$$$cCLASSmethod,"ProcessBody",$$$cMETHrunnable)
			Set useProcessBodyNode=$$$comMemberKeyGet($zobjclass(),$$$cCLASSmethod,"ProcessBodyNode",$$$cMETHrunnable)
		} ElseIf message="" {
			// No further checks for body type, if no body
		} ElseIf $$$xmlaGetLocalName(handler.DocumentId,messageChildlist)="RequestSecurityToken",
				 $isobject(..AddressingIn),
				 $case(..AddressingIn.Action,$$$SOAPWSSCTokenRequest:1,$$$SOAPWSSCTokenCancelRequest:1,:0) {
			// If RequestSecurityToken request, process it here.
			Set msgService=##class(%SOAP.WSSC.Service).%New()
			Set (msgService.Action,..Action)=..AddressingIn.Action
			Set msgClass=##class(%SOAP.WSSC.Service.RequestSecurityToken).%New()
			Set msgClass.%ResponseName="RequestSecurityTokenResponseCollection"
			Set ..MsgClass=msgClass
			Set ..MethodName="RequestSecurityToken"
			Set useProcessBody=0
			Set useProcessBodyNode=0
		} ElseIf $$$xmlaGetLocalName(handler.DocumentId,messageChildlist)="CreateSequence",
				 $isobject(..AddressingIn),
				 ..AddressingIn.Action=($$$SOAPWSRMns_"/CreateSequence") {
			// If CreateSequence request, process it here.
			Set msgService=##class(%SOAP.RM.Service).%New()
			Set (msgService.Action,..Action)=..AddressingIn.Action
			Set msgClass=##class(%SOAP.RM.Service.CreateSequence).%New()
			Set msgClass.%ResponseName="CreateSequenceResponse"
			Set ..MsgClass=msgClass
			Set ..MethodName="CreateSequence"
			Set useProcessBody=0
			Set useProcessBodyNode=0
		} ElseIf $$$xmlaGetLocalName(handler.DocumentId,messageChildlist)="CloseSequence",
				 $isobject(..AddressingIn),
				 ..AddressingIn.Action=($$$SOAPWSRMns_"/CloseSequence") {
			// If CloseSequence request, process it here.
			Set msgService=##class(%SOAP.RM.Service).%New()
			Set (msgService.Action,..Action)=..AddressingIn.Action
			Set msgClass=##class(%SOAP.RM.Service.CloseSequence).%New()
			Set msgClass.%ResponseName="CloseSequenceResponse"
			Set ..MsgClass=msgClass
			Set ..MethodName="CloseSequence"
			Set useProcessBody=0
			Set useProcessBodyNode=0
		} ElseIf $$$xmlaGetLocalName(handler.DocumentId,messageChildlist)="TerminateSequence",
				 $isobject(..AddressingIn),
				 ..AddressingIn.Action=($$$SOAPWSRMns_"/TerminateSequence") {
			// If TerminateSequence request, process it here.
			Set msgService=##class(%SOAP.RM.Service).%New()
			Set (msgService.Action,..Action)=..AddressingIn.Action
			Set msgClass=##class(%SOAP.RM.Service.TerminateSequence).%New()
			Set msgClass.%ResponseName="TerminateSequenceResponse"
			Set ..MsgClass=msgClass
			Set ..MethodName="TerminateSequence"
			Set useProcessBody=0
			Set useProcessBodyNode=0
		}
		If $$$ISOK(sc),'$isobject(msgClass) {
			set sc=$$$ERROR($$$SoapActionError,pAction)
		}
	}
	
	If $$$ISOK(sc) {
		Set sc=..ProcessSOAPEnvelope(.handler,soapenv,.message,.messageChildlist,requestAttachments)
	}
	
	Set ..ImportHandler=handler
	If $$$ISERR(sc) {
		If $$$GETERRORCODE(sc)=$$$ERRORCODE($$$HeaderNotSupported) {
			Set FaultReason=$$$FormatMessage("","%ObjectErrors",$$$ERRORCODE($$$SOAPMustUnderstandError))
			Set FaultCode=$$$FAULTMustUnderstand
		} ElseIf ($$$GETERRORCODE(sc)=$$$ERRORCODE($$$SOAPBadEncodingStyle)) && (..SoapVersion="1.2") {
			Do DecomposeStatus^%apiOBJ(sc,.err)
			Set FaultReason=err(1)
			Set FaultCode=$$$FAULTDataEncodingUnknown
		} Else {
			Set FaultReason=$$$FormatMessage("","%ObjectErrors",$$$ERRORCODE($$$SOAPClientError))
			If versionMismatch {
				Set FaultCode=$$$FAULTVersionMismatch
				If versionMismatch=1 {
					// Force the response to be SOAP 1.1 for version mismatch.
					// Use incoming version for unexpected version
					Set ..SoapVersion="1.1"
				}
			} Else {
				Set FaultCode=$$$FAULTClient
			}
		}
		Goto ProcessSOAPExit
	}
	$$$SOAPTimer("senv")
	
	#; Process session and security headers
	Set header=..HeadersIn.GetAt("CSPCHD")
	If (header'="") && ($zobjclass(header)="%SOAP.SessionHeader") {
		Set sc=header.ProcessService($this)
		If $$$ISERR(sc) {
			Set FaultReason=$$$FormatMessage("","%ObjectErrors",$$$ERRORCODE($$$InternalError))
			Set FaultCode=$$$FAULTClient
			Goto ProcessSOAPExit
		}
	}

	#; If SOAPSESSION, then add the SOAP session header
	If (..SessionCookie'="") && $isobject(%session) &&
	   ($extract(..SessionCookie,11,20)'=$extract(%session.CSPSessionCookie,11,20)) {
		Set FaultReason=$$$FormatMessage("","%ObjectErrors",$$$ERRORCODE($$$SOAPServerError))
		Set FaultCode=$$$FAULTServer
		If %session.NewSession {
			Set sc=$$$ERROR($$$SOAPBadNewSession)
		} Else {
			Set sc=$$$ERROR($$$SOAPBadSessionHeader)
		}
		Goto ProcessSOAPExit
	}

	If ..#SOAPSESSION && (..SessionCookie'="") {
		Set sessionHeader=##class(%SOAP.SessionHeader).%New()
		Set sessionHeader.SessionCookie=..SessionCookie
		Do ..HeadersOut.SetAt(sessionHeader,"CSPCHD")
	}
	
	#; Find WS-ReliableMessaging headers
	If '$isobject(..AddressingIn) || (..AddressingIn.Action'[$$$SOAPWSRMns) {
		Set sequence=..HeadersIn.GetAt("Sequence")
		If $classname(sequence)'="%SOAP.RM.Sequence" Set sequence=""
		Set ack=..HeadersIn.GetAt("SequenceAcknowledgement")
		If $classname(ack)'="%SOAP.RM.SequenceAcknowledgement" Set ack=""
	
		If $isobject(sequence) {
			#; Validate Sequence header
			Set ok=1
			Set session=##class(%SYS.RMSession).Open(sequence.Identifier)
			If '$isobject(session) {
				Set ..SoapFault=##class(%SOAP.RM.SequenceFault).MakeFault($this,0,$$$FAULTClient,"UnknownSequence",sequence.Identifier)
				Set ok=0
			}
			If ok,session.Terminated {
				Set ..SoapFault=##class(%SOAP.RM.SequenceFault).MakeFault($this,0,$$$FAULTClient,"SequenceClosed",sequence.Identifier)
				Set ok=0
			}
			#; If RM session, then error check the sequence here.
			If ok {
				If $$$CheckSOAPLogSecurity {
					Set line="sequence.MessageNumber="_sequence.MessageNumber
					Set line=line_",session.MessageNumber="_session.MessageNumber
					Set line=line_",session.GetMessageState="_session.GetMessageState(sequence.MessageNumber)
					Set line=line_",session.CheckGap()="_session.CheckGap()
					Set line=line_",session.DeliveryAssurance="_session.DeliveryAssurance
					Set line=line_",session.DiscardFollowingFirstGap="_session.DiscardFollowingFirstGap
					Set line=line_",session.InOrder="_session.InOrder
					$$$SOAPLogSecurity("    Check RM session: "_line)
				}
				// Maximum message number is defined by how large a bit string can be handled.
				Try {
					Set $bit(dummy,sequence.MessageNumber)=0
				} Catch {
					Set FaultCode=$$$FAULTClient
					Set FaultReason=$$$FormatMessage("","%ObjectErrors",$$$ERRORCODE($$$SOAPClientError))
					Set ..SoapFault=##class(%SOAP.RM.SequenceFault).MakeFault($this,0,$$$FAULTClient,"MessageNumberRollover")
					Set ok=0
				} 
			}
			If ok {	
				If 'session.CheckSCT($this) {
					Set FaultCode=$$$FAULTClient
					Set FaultReason=$$$FormatMessage("","%ObjectErrors",$$$ERRORCODE($$$SOAPClientError))
					Set ..SoapFault=..MakeFault(FaultCode,FaultReason,"SecurityContextToken, "_session.SCTIdentifier_", expected for WS-ReliableMessaging wsrm:Identifier="_session.RequestIdentifier)
					Set ok=0
				} ElseIf session.GetMessageState(sequence.MessageNumber)=1,
				  $case(session.DeliveryAssurance,"ExactlyOnce":1,"AtMostOnce":1,:0) {
					Set FaultCode=$$$FAULTClient
					Set FaultReason=$$$FormatMessage("","%ObjectErrors",$$$ERRORCODE($$$SOAPClientError))
					Set ..SoapFault=..MakeFault(FaultCode,FaultReason,"WS-ReliableMessaging duplicate message constraint violated wsrm:Identifier="_session.RequestIdentifier)
					Set ok=0
				} ElseIf session.CheckGap() || ((session.MessageNumber+1)'=sequence.MessageNumber),
				  $case(session.DeliveryAssurance,"ExactlyOnce":1,"AtLeastOnce":1,:0) || session.DiscardFollowingFirstGap {
					Set FaultCode=$$$FAULTClient
					Set FaultReason=$$$FormatMessage("","%ObjectErrors",$$$ERRORCODE($$$SOAPClientError))
					Set ..SoapFault=..MakeFault(FaultCode,FaultReason,"WS-ReliableMessaging missing message constraint violated wsrm:Identifier="_session.RequestIdentifier)
					Set ok=0
				} ElseIf session.InOrder,session.MessageNumber>=sequence.MessageNumber {
					Set FaultCode=$$$FAULTClient
					Set FaultReason=$$$FormatMessage("","%ObjectErrors",$$$ERRORCODE($$$SOAPClientError))
					Set ..SoapFault=..MakeFault(FaultCode,FaultReason,"WS-ReliableMessaging InOrder constraint violated wsrm:Identifier="_session.RequestIdentifier)
					Set ok=0
				}
				#; Terminate session if client failure
				If 'ok {
					// Terminating RM session, so terminate underlying SOAP session
					Set %session.EndSession=1
					Set session.Terminated=1
					Do session.Save()
				}
			}
			#; Update RM session
			If ok {
				Set session.MessageNumber=sequence.MessageNumber
				Do session.SetMessageState(session.MessageNumber,1)
				Do session.Save()
				Set ..RMSession=session
				#; Add Sequence and SequenceAcknowledgement headers if RM session
				If session.ResponseIdentifier'="" {
					Do ..HeadersOut.SetAt(##class(%SOAP.RM.Sequence).CreateHeader(..RMSession,0),"Sequence")
				}
				Do ..HeadersOut.SetAt(##class(%SOAP.RM.SequenceAcknowledgement).CreateHeader(session,0),"SequenceAcknowledgement")
			} ElseIf $isobject(session) {
				If +session.MessageNumber>0 {
					Do session.SetMessageState(session.MessageNumber,0)
				}
				Do ..FaultHeaders.SetAt(##class(%SOAP.RM.SequenceAcknowledgement).CreateHeader(session,0),"SequenceAcknowledgement")
			}
			If 'ok Goto ProcessSOAPExit
		} ElseIf $isobject(ack) {
			#; SequenceAcknowledgement is not valid without Sequence
			Set ..SoapFault=##class(%SOAP.RM.SequenceFault).MakeFault($this,0,$$$FAULTClient,"InvalidAcknowledgement",ack.Identifier)
			Goto ProcessSOAPExit
		}
	}
	
	#; Validate the WS-Policy policy that applies to this service
	Set sc=##class(%SOAP.Policy).ProcessReceiveAlternative($this,..MethodName,.alternative)
	If $$$ISERR(sc) {
		Set FaultCode=$$$FAULTServer
		Set FaultReason=$$$FormatMessage("","%ObjectErrors",$$$ERRORCODE($$$SOAPServerError))
		// If not a good policy, then terminate underlying SOAP session
		Set %session.EndSession=1
		Goto ProcessSOAPExit
	}
	$$$SOAPTimer("shdr")

	If useProcessBody {
		If $IsObject(requestBody) { Set tHadBodyStream=1 }
		Else {
			Set tHadBodyStream=0
			Set requestBody=##class(%GlobalCharacterStream).%New()
			If message="" {
				Set sc=requestBody.Write("")
				If $$$ISERR(sc) {
					Set FaultCode=$$$FAULTClient
					Set FaultReason=$$$FormatMessage("","%ObjectErrors",$$$ERRORCODE($$$SOAPClientError))
					Goto ProcessSOAPExit
				}
			} Else {
				Set body=$select(message="":"",1:..ImportHandler.GetNode(message))
				Set writer=##class(%XML.Writer).%New()
				Set writer.NoXMLDeclaration=1
				Set sc=writer.OutputToStream(.requestBody)
				If $$$ISOK(sc) Set sc=writer.Canonicalize(body,,1)
				If $$$ISERR(sc) {
					Set FaultCode=$$$FAULTClient
					Set FaultReason=$$$FormatMessage("","%ObjectErrors",$$$ERRORCODE($$$SOAPClientError))
					Goto ProcessSOAPExit
				}
			}
		}
		Set ^zDebug = "Process method in MACKEY Recipient Services"
		Set ^zRequestBody = requestBody.Read()
		do requestBody.Rewind()
		Set responseBody=##class(%GlobalCharacterStream).%New()
		Set inProcessBody=1
		Set BodyProcessed=..ProcessBody(pAction,requestBody,.responseBody)
		Set:'tHadBodyStream requestBody=$$$NULLOREF
		Set inProcessBody=0
	} ElseIf useProcessBodyNode {
		Set responseBody=##class(%GlobalCharacterStream).%New()
		Set body=$select(message="":"",1:..ImportHandler.GetNode(message))
		Set inProcessBody=1
		Set BodyProcessed=..ProcessBodyNode(pAction,body,.responseBody)
		Set inProcessBody=0
	} Else {
		Set BodyProcessed=0
	}

	If 'BodyProcessed {
		Kill responseBody
		If '$IsObject(requestBody) {
			Set sc=..MsgClass.ImportSOAPMessage(..MethodName,"*",..ImportHandler,message,messageChildlist,requestAttachments,..#SOAPCHECKREQUIRED)
		} Else {
			#; Get an XML content handler that parses message into XML DOM 
			Set bodyHandler=##class(%XML.Reader).GetNewDocument(..#USEPPGHANDLER)
			If bodyHandler="" {
				Set sc=$$$ERROR($$$CannotCreateObject,"body %XML.Document")
			} Else {
			 	Set bodyHandler.KeepWhitespace=1 // Need whitespace for XMLImport
				#; and an entity resolver
				Set tResolver=##Class(%XML.SAX.EntityResolver).%New()
				If tResolver="" {
					Set sc=$$$ERROR($$$CannotCreateObject,"%XML.SAX.EntityResolver")
				} Else {
					#; Parse the message into XML DOM
					Set sc=##Class(%XML.SAX.Parser).ParseStream(requestBody,bodyHandler,tResolver,$$$SAXFULLDEFAULT-$$$SAXVALIDATIONSCHEMA+$$$SAXVALIDATIONPROHIBITDTDS)
					If $$$ISOK(sc) {
						Set tree=bodyHandler.DocumentId
						Set root=$$$xmlGetDocumentElement(tree)
						$$$xmlaGetChildList(tree,root,rootChildlist,descriptor)
						$$$xmlaFirstChildElement(tree,root,rootChildlist,bodmessage,d3)
						$$$xmlaGetChildListFromDescriptor(tree,d3,bodmessageChildlist)
						Set sc=..MsgClass.ImportSOAPMessage(..MethodName,"*",bodyHandler,bodmessage,bodmessageChildlist,requestAttachments,..#SOAPCHECKREQUIRED)
					}
				}
			}
		}
		If $$$ISERR(sc) {
			If ..SoapVersion="1.2" {
				Do DecomposeStatus^%apiOBJ(sc,.err)
				Set detail=$c(13,10)_"    <error xmlns='"_..#NAMESPACE_"'>"_$c(13,10)
				Set detail=detail_"     <text>"_$zcvt(err(1),"O","XML")_"</text>"_$c(13,10)
				Set detail=detail_"    </error>"_$c(13,10)
				Set fault=..MakeFault12($$$FAULTSender,"Bad arguments in RPC request",detail)
				Set fault.Code.Subcode=..MakeFault12Code("rpc:BadArguments")
				Set fault.faultPrefixDefinition="xmlns:rpc="""_$$$SOAP12RPC_""""
				Set ..SoapFault=fault
			} Else {
				Set FaultCode=$$$FAULTClient
				Set FaultReason=$$$FormatMessage("","%ObjectErrors",$$$ERRORCODE($$$SOAPClientError))
			}
			Goto ProcessSOAPExit
		}
		
		#; Invoke the web method with arguments in MsgClass
		If '..InvokeMsgClass(..MsgClass,msgService) Goto ProcessSOAPExit
	}
	$$$SOAPTimer("sbody")
	
	#; Restore the TCP device for response
	Do ..%RestoreTCPDevice()

	#; If forced to OneWay, then always empty body
	If ..OneWay Set responseBody=""
	#; If OneWay not set by WebMethod, ProcessBody or ProcessBodyNode, then set from parameter.	
	If ..OneWay="" {
		Set ..OneWay=..MsgClass.%GetParameter("SOAPONEWAY")
	}
	#; Find WS-Policy alternative for response
	Set sc=##class(%SOAP.Policy).ProcessSendAlternative($this,..MethodName,.alternative)
	If $$$ISERR(sc) {
		Set FaultCode=$$$FAULTServer
		Set FaultReason=$$$FormatMessage("","%ObjectErrors",$$$ERRORCODE($$$SOAPServerError))
		Goto ProcessSOAPExit
	}

	#; Setup WS-Addressing if required.
	If '$data(alternative),..AddressingOut="",..AddressingIn'="",$zcvt(..#WSADDRESSING,"U")="AUTO" {
		Set action=##class(%SOAP.WebParameters).GetAction($classname(),..MethodName,"response")
		Set ..AddressingOut=##class(%SOAP.Addressing.Properties).GetDefaultResponseProperties(..AddressingIn,action)
	}

	#; Initialize any WS-Security operations.
	Set wsRequired=..InitializeSecurity(.sc)
	If $$$ISERR(sc) {
		Set FaultCode=$$$FAULTServer
		Set FaultReason=$$$FormatMessage("","%ObjectErrors",$$$ERRORCODE($$$SOAPServerError))
		Goto ProcessSOAPExit
	}
	
	$$$SOAPTimer("spolicy")

	// If one-way message to a service with no headers, then just return empty message
	If '$isobject(r%SecurityOut)||(r%SecurityOut.SecurityElement.Count()=0),
	   ..AddressingOut="",..HeadersOut.Count()=0,..ResponseAttachments.Count()=0,..OneWay {
		If $get(%request)'="" && %request.CSPGatewayRequest {
			Do %response.Abort()
			Set %response.Status="202 Accepted"
			Set %response.ContentType=""
			Set %response.ContentLength=0
			Do %response.WriteHTTPHeader(.dummy)
		}
		$$$SOAPLogOutputHTTPHeaders
		Set sc=$$$OK
		Goto ProcessSOAPExit
	}
	
	#; Output directly to TCP device only if service and no logging and no WS-Security
	If '$$$CheckSOAPLogOutput,'wsRequired {
		$$$XMLUseWrite
	} Else {
		$$$XMLUseGlobal
	}
	
	#; Write the SOAP message
	Set sc=..WriteHTTPContent(..MsgClass,..MsgClass.%ResponseName,1,wsRequired,.responseBody,$select(needHeaders:%response,1:""))
	If $$$ISERR(sc) {
		Set FaultCode=$$$FAULTServer
		Set FaultReason=$$$FormatMessage("","%ObjectErrors",$$$ERRORCODE($$$SOAPServerError))
	}
	If '$$$XMLIsWrite {
		$$$SETIO("RAW")
		If '$$$ISERR(sc) {
			$$$XMLOutputBuffer
		}
		$$$XMLUseRestore
	}
	$$$SOAPLogOutputHTTPHeaders
	
	$$$SOAPTimer("sres")

ProcessSOAPExit	
	Do ..%RestoreTCPDevice()
	If $$$ISERR(sc) && (..SoapFault="") {
		Set ..SoapFault=..MakeStatusFault(FaultCode,FaultReason,sc)
	}
	If ..SoapFault'="" Do ..Fault(..SoapFault)
	If $get(wsRequired) || $isobject(r%SecurityOut) Do ..ResetSecurity()
	Quit

ProcessSOAPError Set $zt=""
	If inProcessBody {
		If $ze'["<ZSOAP>" {
			Set FaultCode=$$$FAULTServer
			Set FaultReason=$$$FormatMessage("","%ObjectErrors",$$$ERRORCODE($$$SOAPServerError))
			Set sc=$$$ERROR($$$ObjectScriptError,$ZE)
		}
	} Else {
		Set FaultCode=$$$FAULTServer
		Set FaultReason=$$$FormatMessage("","%ObjectErrors",$$$ERRORCODE($$$InternalError))
		Set sc=$$$ERROR($$$ObjectScriptError,$ZE)
	}
	Goto ProcessSOAPExit
}

XData WSDL
{
<?xml version="1.0" encoding="utf-8"?>
<definitions xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/" xmlns="http://schemas.xmlsoap.org/wsdl/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:ihe="urn:ihe:iti:xds-b:2007" xmlns:rs="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0" xmlns:soap12="http://schemas.xmlsoap.org/wsdl/soap12/" xmlns:wsaw="http://www.w3.org/2006/05/addressing/wsdl" xmlns:ns="urn:oasis:names:tc:ebxml-regrep:xsd:query:3.0" xmlns:ns1="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" xmlns:ns2="urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" name="DocumentRepository" targetNamespace="urn:ihe:iti:xds-b:2007">
<documentation>IHE XDR Recipient</documentation>
<types>
<xsd:schema elementFormDefault="qualified" targetNamespace="urn:ihe:iti:xds-b:2007" xmlns:ihe="urn:ihe:iti:xds-b:2007">
<!-- Include the message schema -->
<xsd:include schemaLocation="http://www.intersystems.com:80/healthshare/ihe/schema/IHE/XDS.b_DocumentRepository.xsd"/>
</xsd:schema>
<xsd:schema elementFormDefault="qualified" targetNamespace="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0" xmlns:rs="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0">
<!-- Include the message schema -->
<xsd:include schemaLocation="http://www.intersystems.com:80/healthshare/ihe/schema/ebRS/rs.xsd"/>
</xsd:schema>
<!-- While no elements are directly used from these schema in the WSDL, 
they need to be present here in order for
code generating toolkits to work properly -->
<xsd:schema elementFormDefault="qualified" targetNamespace="urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0" xmlns:lcm="urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0">
<!-- Include the message schema -->
<xsd:include schemaLocation="http://www.intersystems.com:80/healthshare/ihe/schema/ebRS/lcm.xsd"/>
</xsd:schema>
<xsd:schema elementFormDefault="qualified" targetNamespace="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" xmlns:lcm="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0">
<!-- Include the message schema -->
<xsd:include schemaLocation="http://www.intersystems.com:80/healthshare/ihe/schema/ebRS/rim.xsd"/>
</xsd:schema>
<!--	Importing all schemas within one seems to confuse some parsers 
and code-generation tools (and may be invalid)	
<xsd:schema elementFormDefault="qualified">
<xsd:import namespace="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0"
schemaLocation="http://www.intersystems.com:80/healthshare/ihe/schema/ebRS/rs.xsd"/>
<xsd:import namespace="urn:ihe:iti:xds-b:2007"
schemaLocation="http://www.intersystems.com:80/healthshare/ihe/schema/IHE/XDS.b_DocumentRepository.xsd"/>
</xsd:schema>
-->
</types>
<message name="RetrieveDocumentSet_Message">
<documentation>Retrieve Document Set</documentation>
<part name="body" element="ihe:RetrieveDocumentSetRequest"/>
</message>
<message name="RetrieveDocumentSetResponse_Message">
<documentation>Retrieve Document Set Response</documentation>
<part name="body" element="ihe:RetrieveDocumentSetResponse"/>
</message>
<message name="ProvideAndRegisterDocumentSet-b_Message">
<documentation>Provide and Register Document Set</documentation>
<part name="body" element="ihe:ProvideAndRegisterDocumentSetRequest"/>
</message>
<message name="ProvideAndRegisterDocumentSet-bResponse_Message">
<documentation>Provide And Register Document Set Response</documentation>
<part name="body" element="rs:RegistryResponse"/>
</message>
<portType name="DocumentRepository_PortType">
<operation name="DocumentRepository_RetrieveDocumentSet">
<input message="ihe:RetrieveDocumentSet_Message" wsaw:Action="urn:ihe:iti:2007:RetrieveDocumentSet"/>
<output message="ihe:RetrieveDocumentSetResponse_Message" wsaw:Action="urn:ihe:iti:2007:RetrieveDocumentSetResponse"/>
</operation>
<operation name="DocumentRepository_ProvideAndRegisterDocumentSet-b">
<input message="ihe:ProvideAndRegisterDocumentSet-b_Message" wsaw:Action="urn:ihe:iti:2007:ProvideAndRegisterDocumentSet-b"/>
<output message="ihe:ProvideAndRegisterDocumentSet-bResponse_Message" wsaw:Action="urn:ihe:iti:2007:ProvideAndRegisterDocumentSet-bResponse"/>
</operation>
</portType>
<binding name="DocumentRepository_Binding" type="ihe:DocumentRepository_PortType">
<soap12:binding style="document" transport="http://schemas.xmlsoap.org/soap/http"/>
<operation name="DocumentRepository_ProvideAndRegisterDocumentSet-b">
<soap12:operation soapAction="urn:ihe:iti:2007:ProvideAndRegisterDocumentSet-b"/>
<input>
<soap12:body use="encoded"/>
</input>
<output>
<soap12:body use="literal"/>
</output>
</operation>
<operation name="DocumentRepository_RetrieveDocumentSet">
<soap12:operation soapAction="urn:ihe:iti:2007:RetrieveDocumentSet"/>
<input>
<soap12:body use="literal"/>
</input>
<output>
<soap12:body use="literal"/>
</output>
</operation>
</binding>
<service name="DocumentRepository_Service">
<port name="DocumentRepository_Port_Soap12" binding="ihe:DocumentRepository_Binding">
<soap12:address location="http://servicelocation/DocumentRepository_Service"/>
</port>
</service>
</definitions>
}

XData service
{
<parameters xmlns="http://www.intersystems.com/configuration">
<method name="ProvideAndRegister">
<request>
<header name="addressBlock" class="HS.IHE.XDSb.Types.AddressBlockHeader"/>
<header name="metadata-level" class="HS.IHE.XDSb.Types.MetadataLevelHeader"/>
</request>
</method>
</parameters>
}

/// Revision number of this class
Parameter SrcVer = 7;

}
