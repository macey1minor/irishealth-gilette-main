Include (HS.IHE.XDSb, HS.IHE.PIX, HS.IHE.PDQ)

Class BCBSSC.Router.IHE.Process.ProvideRouter Extends (Ens.BusinessProcess, HS.HC.Util.Trace.Helper) [ ClassType = persistent ]
{

Parameter SETTINGS = "RouteToFacilityService:Basic,SendToMemberCheck:Basic,SaveToFile:File,FilePath:File,TargetOperation:Target,TargetService:Target:selector?context={HS.Util.ContextSearch/ServiceNameItems},DoPassthrough:Target,VALPassthrough:Target:selector&context={HS.Util.ContextSearch/ServiceNameItems},UATPassthrough:Target:selector&context={HS.Util.ContextSearch/ServiceNameItems},LIVEPassthrough:Target:selector&context={HS.Util.ContextSearch/ServiceNameItems},LIVEPassthroughToVAL:Target:selector&context={HS.Util.ContextSearch/ServiceNameItems},PIXQueryRemoveDataSource:PIX,SearchTableClass";

/// If specified, a copy of the original request will passthrough to
/// another target
Property DoPassthrough As %Boolean;

/// Facility OID Registry Alias used to determine where to send
///  Set to always send to VAL unless STOP or N
/// Enter STOP if no data is to be sent Otherwise enter 1 service to use
Property VALPassthrough As %String(MAXLEN = 30);

/// Facility OID Registry Alias used to determine where to send
///  1st Char =0  and 2nd Char = V sent to VAL
/// Enter STOP if no data is to be sent Otherwise enter 1 service to use
Property UATPassthrough As %String(MAXLEN = 30);

/// Facility OID Registry Alias used to determine where to send
///  1st Char =0  and 4th Char = L sent to LIVE
/// Enter STOP if no data is to be sent Otherwise enter 1 service to use
Property LIVEPassthrough As %String(MAXLEN = 30);

/// Facility OID Registry Alias used to determine where to send
///  1st Char =0  and 4th Char = L sent to LIVE
/// Enter STOP if no data is to be sent Otherwise enter 1 service to use
Property LIVEPassthroughToVAL As %String(MAXLEN = 30);

/// The main target of the messages
Property TargetService As %String(MAXLEN = 512);

/// The Target Operation that will send all the messages out
/// If SendToMemberCheck is checked and TargetOperation is empty
/// The target will be set to <FACILITY>.MemberCheckCCD.Process
Property TargetOperation As Ens.DataType.ConfigName;

// If set to true, will set ServiceName

/// Standard format is EG<FACILITY>.XDSb.Repository
Property RouteToFacilityService As %Boolean [ InitialExpression = 1 ];

// If set to true, will send to the MemberCheckProcess

Property SendToMemberCheck As %Boolean [ InitialExpression = 1 ];

// Used to send to Process for Member Eligbility Check

// If left empty, ProvideRouter will attempt to route to a process name based on the Facility name

// Standard format is <FACILITY>.MemberCheckCCD.Process

/// Boolean to indicate if message should be stored as a file or no
Property SaveToFile As %Boolean [ InitialExpression = 0 ];

/// File Path for the message to be saved as a file
Property FilePath As %String(MAXLEN = 512);

/// Transformer used to create response
Property Transformer As HS.Util.XSLTTransformer;

/// Add OutputSet to return possible errors in response message
Property OutputSet As HS.Types.IHE.Submission;

/// Remove DataSource from the PIX Query
Property PIXQueryRemoveDataSource As %Boolean [ InitialExpression = 1 ];

/// Send a HardCode Success Response
Property SuccessResponse As %Boolean [ InitialExpression = 1 ];

/// SearchTable Class used
Property SearchTableClass As %String(MAXLEN = 512);

/// On Request
Method OnRequest(pRequest As Ens.Request, Output pResponse As Ens.Response) As %Status
{
	Set tStatus = $$$OK, tFacilityOID = "", tFacilityCode = "", tFacilityDesc="", tMRN="", tSendVAL = "X", tSendUAT = "X", tSendLIVE = "X"
	// 20210921 Add PIX and PDQ logic, hard code response for PIXAdd, remove Data Source from PIXQuery
	// updated 07/08/21 to use Facility Name prefix to determine which environment(s) to send CCDA
	// If site can't provide this properly, use a custom router/endpoint
	// 20210712 update logic to use PassThrough for service information
	// 20200713 fix Facility Code logic
	// 20240419 Add routing logic to Member Check for BCBSSC

	Try {
		If (pRequest.%ClassName(1) = "HS.Message.XMLMessage") {
			
			If (pRequest.Name = $$$XDSbProvideAndRegisterRequest)||(pRequest.Name = $$$XDRProvideAndRegisterRequest) { 
				
				set tDocumentID = ""
				Set tExpression = "//xdsb:Document"
				Set tItem = "@id"
				Set tSC = ##class(HS.IHE.Util).GetXPathValue(pRequest.ContentStream,tExpression,tItem,.tDocumentID)

				// Look for the OID in the SubmissionSet.sourceId
				// If site can't provide this properly, use a custom router/endpoint
				
				Set tExpression = "//rim:RegistryObjectList/rim:ExtrinsicObject/rim:Slot[@name='sourcePatientId']/rim:ValueList/rim:Value"
				Set tItem = "text()"
				Set tStatus = ##class(HS.IHE.Util).GetXPathValue(pRequest.ContentStream,tExpression,tItem,.tSourcePatientId)
				$$$ThrowOnError(tStatus)
				$$$LOGINFO("SourcePatientId:  "_tSourcePatientId)
				If tSourcePatientId'="" {
					set tMRN = $P($P(tSourcePatientId, "&", 1), "^", 1)
				}
				
				Set tExpression = "//rim:ExternalIdentifier[@identificationScheme='urn:uuid:554ac39e-e3fe-47fe-b233-965d2a147832']"
				Set tItem = "@value"
				Set tStatus = ##class(HS.IHE.Util).GetXPathValue(pRequest.ContentStream,tExpression,tItem,.tFacilityOID)
				$$$ThrowOnError(tStatus)
				$$$LOGINFO("Facility OID is:  "_tFacilityOID)
				
				// Convert the OID to an HS facility code
				Set tFacilityCode = ##class(HS.Data.OIDMap).CodeForOID(..DeriveRootOID(tFacilityOID,"Facility"),"Facility","")
				$$$LOGINFO("Facility Code = "_tFacilityCode)
				
				//MT Use SourcePatientID if code is null
				If tFacilityCode = ""{
					If tSourcePatientId '= ""{
						Set tFacilityOID = $PIECE(tSourcePatientId,"&",2)
						Set tFacilityCode = ##class(HS.Data.OIDMap).CodeForOID(..DeriveRootOID(tFacilityOID,"Facility"),"Facility","")
						$$$LOGINFO("Facility Code is: "_tFacilityCode)
					}
				}	
	
				//MT Use SourcePatientID if code is null
				if $E(tFacilityCode,1,1) = 0{
					Set tSendVAL = $E(tFacilityCode,2,2)
					Set tSendUAT = $E(tFacilityCode,3,3)
					Set tSendLIVE = $E(tFacilityCode,4,4)
					Set tFacilityCode = $E(tFacilityCode,5,)
				}
				If ..DoPassthrough $$$LOGINFO("Facility SendCodes: "_tFacilityCode_":"_tSendVAL_":"_tSendUAT_":"_tSendLIVE)
		
				
				if (..SaveToFile){
					Set tFac = tFacilityCode
					Set tDocumentUniqueID = ""
					Set:tFac="" tFac=tFacilityOID
					Set tExpression = "//rim:ExternalIdentifier[@identificationScheme='urn:uuid:96fdda7c-d067-4183-912e-bf5ee74998a8']"
					Set tItem = "@value"
					Set tStatus = ##class(HS.IHE.Util).GetXPathValue(pRequest.ContentStream,tExpression,tItem,.tDocumentUniqueID)
					$$$ThrowOnError(tStatus)

					Set tFile = ##class(%Stream.FileCharacter).%New()
					Set tFile.Filename= ..FilePath_tFac_"_"_$System.Util.CreateGUID()_".xml"
					$$$TRACE(..FilePath_tFac_"_"_tDocumentUniqueID_".xml")
					//While 'tRequest.AtEnd{
					Set tSC = tFile.Write(pRequest.XMLExportToStream())
					//}
					Set tSC= tFile.%Save()
				}
				
				If ""'=..SearchTableClass {
					Set tStatus = pRequest.AdditionalInfo.SetAt(tFacilityOID,"FromFacility")
					if tFacilityCode '="" Do pRequest.AdditionalInfo.SetAt(tFacilityCode,"FacilityCode")
					if tMRN '="" Do pRequest.AdditionalInfo.SetAt(tMRN,"MRN")
					TRY {
						Set tObj=pRequest
						Set:$IsObject(tObj) tSCStore=$classmethod(..SearchTableClass,"IndexDoc",tObj)
						If $$$ISERR(tSCStore) $$$LOGWARNING("Failed to construct SearchTable entries for document "_tObj_"/"_tObj.%Id()_" using class '"_..SearchTableClass_"' "_$$$StatusDisplayString(tSCStore))
					} CATCH errobj { $$$LOGWARNING("Failed to invoke SearchTable method "_..SearchTableClass_".IndexDoc() for message "_tObj_"/"_tObj.%Id()_" with DocType='"_tObj.DocType_"' : "_errobj.AsSystemError()) }
				}
				
				If (tFacilityCode = "") {
					Set tExpression = "//rim:RegistryObjectList/rim:ExtrinsicObject/rim:Classification[@classificationScheme='urn:uuid:93606bcf-9494-43ec-9b4e-a7748d1a838d']/rim:Slot[@name='authorInstitution']/rim:ValueList/rim:Value"
					Set tItem = "text()"
					Set tStatus = ##class(HS.IHE.Util).GetXPathValue(pRequest.ContentStream,tExpression,tItem,.tFacilityDesc)
					$$$ThrowOnError(tStatus)
					$$$LOGINFO("Facility OID is:  "_tFacilityOID)
					$$$LOGWARNING("Unknown facility OID. OID: " _ tFacilityOID_" "_tFacilityDesc)
					Set tStatus = $$$ERROR($$$GeneralError,"Unknown facility OID. OID: " _ tFacilityOID_", Description:"_tFacilityDesc)
					$$$ThrowOnError(tStatus)
							
				} Else {
					// Proceed with valid facility code
					$$$HSTRACE("OnRequest","tFacilityCode",tFacilityCode)				
				}

				// If Pass through is set, don't use TargetOperation or MessageCheckProcess				
				IF ..DoPassthrough{
					$$$LOGINFO("Passthrough is enabled, sending to other systems")
					// Send CCD to all environments needed
					IF ((..VALPassthrough '= "STOP") &&  (tSendVAL '= "N" )){
						$$$TRACE("Forward to VAL:"_tSendVAL_" : "_..VALPassthrough)
						Set tStatus = pRequest.AdditionalInfo.SetAt(..VALPassthrough,"ServiceName")
						$$$ThrowOnError(tStatus)
						Set tStatus = ..SendRequestSync(..TargetOperation,pRequest,.tResponse)
						$$$ThrowOnError(tStatus)
					}Else{
						$$$LOGINFO("VAL STOP")
					}


					IF ((..UATPassthrough '= "STOP") &&  (tSendUAT = "U" )){
						$$$TRACE("Forward to UAT: "_..UATPassthrough)
						Set tStatus = pRequest.AdditionalInfo.SetAt(..UATPassthrough,"ServiceName")
						$$$ThrowOnError(tStatus)
						Set tStatus = ..SendRequestSync(..TargetOperation,pRequest,.tResponse)
						$$$ThrowOnError(tStatus)
					}
								
					IF ((..LIVEPassthrough '= "STOP") &&  (tSendLIVE = "L" )){
						$$$TRACE("Forward to LIVE: "_..LIVEPassthrough)
						Set tStatus = pRequest.AdditionalInfo.SetAt(..LIVEPassthrough,"ServiceName")
						$$$ThrowOnError(tStatus)
						Set tStatus = ..SendRequestSync(..TargetOperation,pRequest,.tResponse)
						$$$ThrowOnError(tStatus)
					}
					IF ((..LIVEPassthroughToVAL '= "STOP") &&  (tSendLIVE = "L" )){
						$$$TRACE("Forward to LIVE: "_..LIVEPassthroughToVAL)
						Set tStatus = pRequest.AdditionalInfo.SetAt(..LIVEPassthroughToVAL,"ServiceName")
						$$$ThrowOnError(tStatus)
						Set tStatus = ..SendRequestSync(..TargetOperation,pRequest,.tResponse)
						$$$ThrowOnError(tStatus)
					}														
				}else{

					if ..RouteToFacilityService {
						set tRepositoryName = "EG"_tFacilityCode_".XDSb.Repository"
					}
					else {			
						//// Send to Target
						Set tRepositoryName= ..TargetService
						$$$HSTRACE("OnRequest","tRepositoryName",tRepositoryName)
					}

					//Use the facility code to set the MemberCheckProcess if value is empty string and SendToMemberCheck is true
					set tTargetOperation = ..TargetOperation
					if ..SendToMemberCheck && (..TargetOperation = "") {
						set tMemberCheckTarget = tFacilityCode_".MemberCheckCCD.Process"
						set tTargetOperation = tMemberCheckTarget
					}

					
					#; Find the configured service name for this xds repository
					If (tRepositoryName ] "") {
						//Set tEndPoint = ##class(HS.Registry.Service.SOAP).EndPointForID(tRepositoryName,"Repository",,"SOAP",.tStatus)
						//$$$ThrowOnError(tStatus)
						//If $IsObject(tEndPoint) {
						$$$ThrowOnError(pRequest.AdditionalInfo.SetAt(tFacilityCode,"FacilityCode"))
						$$$ThrowOnError(pRequest.AdditionalInfo.SetAt(tMRN,"MRN"))
						$$$ThrowOnError(pRequest.AdditionalInfo.SetAt(tRepositoryName,"ServiceName"))
						//$$$HSTRACE("OnRequest","tEndPoint.Name",tEndPoint.Name)
						$$$ThrowOnError(..SendRequestSync(tTargetOperation,pRequest,.pResponse))
					} Else {
						Set tStatus = $$$ERROR($$$GeneralError,"Unknown endpoint for repository name: " _ tRepositoryName)
						$$$ThrowOnError(tStatus)
					}
				}
			}
			ElseIf (pRequest.Name = $$$PIXv3QueryRequest)||(pRequest.Name = $$$PIXv3AddRequest)||(pRequest.Name = $$$PDQv3QueryRequest) {
				
				if (pRequest.Name = $$$PIXv3AddRequest){
					//Look for the OID in the patient id
					Set tExpression = "//hl7:patient/hl7:id"
					Set tItem = "@root"
					Set tStatus = ##class(HS.IHE.Util).GetXPathValue(pRequest.ContentStream,tExpression,tItem,.tFacilityOID)
					$$$ThrowOnError(tStatus)
					$$$LOGINFO("PatientIdOID:  "_tFacilityOID)
				}elseIf (pRequest.Name = $$$PIXv3QueryRequest){
					Set tExpression = "//hl7:controlActProcess/hl7:queryByParameter/hl7:parameterList/hl7:patientIdentifier/hl7:value"
					Set tItem = "@root"
					Set tStatus = ##class(HS.IHE.Util).GetXPathValue(pRequest.ContentStream,tExpression,tItem,.tFacilityOID)
					$$$ThrowOnError(tStatus)
					$$$LOGINFO("PatientIdOID:  "_tFacilityOID)
				}elseIf (pRequest.Name = $$$PDQv3QueryRequest){
					/*
					Set tExpression = "//hl7:controlActProcess/hl7:queryByParameter/hl7:parameterList/hl7:patientIdentifier/hl7:value"
					Set tItem = "@root"
					Set tStatus = ##class(HS.IHE.Util).GetXPathValue(pRequest.ContentStream,tExpression,tItem,.tFacilityOID)
					$$$ThrowOnError(tStatus)
					$$$LOGINFO("PatientIdOID:  "_tFacilityOID)*/
				}
				
				Do pRequest.AdditionalInfo.SetAt(tFacilityOID,"FromFacility")
				
				// Convert the OID to an HS facility code
				Set tFacilityCode = ##class(HS.Data.OIDMap).CodeForOID(..DeriveRootOID(tFacilityOID,"Facility"),"Facility","")
				$$$LOGINFO("Facility Code = "_tFacilityCode)
				
				if tFacilityCode '="" Do pRequest.AdditionalInfo.SetAt($E(tFacilityCode,5,),"FacilityCode")
				
				if (..SaveToFile){
					Set tFile = ##class(%Stream.FileCharacter).%New()
					if tFacilityCode '= "" {Set tFile.Filename= ..FilePath_tFacilityCode_"_"_$System.Util.CreateGUID()_".xml"}
					else {Set tFile.Filename= ..FilePath_tFacilityOID_"_"_$System.Util.CreateGUID()_".xml"}
					Set tSC = tFile.Write(pRequest.XMLExportToStream())
					Set tSC= tFile.%Save()
				}
				
				If ""'=..SearchTableClass {
					TRY {
						Set tObj=pRequest
						Set:$IsObject(tObj) tSCStore=$classmethod(..SearchTableClass,"IndexDoc",tObj)
						If $$$ISERR(tSCStore) $$$LOGWARNING("Failed to construct SearchTable entries for document "_tObj_"/"_tObj.%Id()_" using class '"_..SearchTableClass_"' "_$$$StatusDisplayString(tSCStore))
					} CATCH errobj { $$$LOGWARNING("Failed to invoke SearchTable method "_..SearchTableClass_".IndexDoc() for message "_tObj_"/"_tObj.%Id()_" with DocType='"_tObj.DocType_"' : "_errobj.AsSystemError()) }
				}
				
				If (tFacilityCode '= "") {
					if $E(tFacilityCode,1,1) = 0{
						//Query requests can only be sent to one system
						If (pRequest.Name = $$$PIXv3QueryRequest)||(pRequest.Name = $$$PDQv3QueryRequest){
							Set tSend = $E(tFacilityCode,2,4)
							if (tSend = "VUL") {Set tFacilityCode=$REPLACE(tFacilityCode,tSend,"NNL")}
							elseIf (tSend = "NUL") {Set tFacilityCode=$REPLACE(tFacilityCode,tSend,"NNL")}
							elseIf (tSend = "VUN") {Set tFacilityCode=$REPLACE(tFacilityCode,tSend,"NUN")}
							elseIf (tSend = "VNN") {Set tFacilityCode=$REPLACE(tFacilityCode,tSend,"NUN")}
						}
						if (pRequest.Name = $$$PDQv3QueryRequest) Set tFacilityCode="0NUNALL"
						Set tSendVAL = $E(tFacilityCode,2,2)
						Set tSendUAT = $E(tFacilityCode,3,3)
						Set tSendLIVE = $E(tFacilityCode,4,4)
						Set tFacilityCode = $E(tFacilityCode,5,)
						if (pRequest.Name = $$$PIXv3AddRequest) Set tSendUAT = "U"
					}

					$$$LOGINFO("Facility SendCodes: "_tFacilityCode_":"_tSendVAL_":"_tSendUAT_":"_tSendLIVE)
					
					if (pRequest.Name = $$$PIXv3QueryRequest)&&(..PIXQueryRemoveDataSource){
						try{
							Set tExpression = "//hl7:controlActProcess/hl7:queryByParameter/hl7:parameterList/hl7:dataSource/hl7:value"
							Set tItem = "@root"
							Set tStatus = ##class(HS.IHE.Util).GetXPathValue(pRequest.ContentStream,tExpression,tItem,.tDataSource)
							$$$TRACE("tDataSource: "_tDataSource)
							if tDataSource'=""{
								Set tXSLArguments("FacilityCode") = "'"_ tFacilityOID _ "'"
								$$$ThrowOnError(##class(Ens.Util.URLStream).GetURLStream("xdata://" _ ..%ClassName(1) _ ":PIXQueryDataSource", .tPIXQDataSourceTrans))
								$$$ThrowOnError(##class(%XML.XSLT.CompiledStyleSheet).CreateFromStream(tPIXQDataSourceTrans, .tCompiledStyleSheet))
								$$$HSTRACE("PIXv3 Query Received","ContentStream",pRequest.ContentStream)
								$$$ThrowOnError(##class(%XML.XSLT.Transformer).TransformStreamWithCompiledXSL(pRequest.ContentStream, tCompiledStyleSheet,.tTransformedStream,,.tXSLArguments,##class(HS.Util.XSLTHelper).%New()))
								$$$HSTRACE("Final PIXv3 Query","tTransformedStream",tTransformedStream)
								Do pRequest.ContentStream.CopyFrom(tTransformedStream)
							}
						}catch tException{
							$$$LOGERROR(eException)
						}
					}

					IF ..DoPassthrough{
						IF ((..VALPassthrough '= "STOP") &&  (tSendVAL = "V" )){
							$$$TRACE("Forward to VAL:"_tSendVAL_" : "_..VALPassthrough)
							Set tStatus = pRequest.AdditionalInfo.SetAt(..VALPassthrough,"ServiceName")
							$$$ThrowOnError(tStatus)
							Set tStatus = ..SendRequestSync(..TargetOperation,pRequest,.tResponse)
							//if 'tStatus $$$LOGERROR(tStatus)
						}Else{
							$$$LOGINFO("VAL STOP")
						}

						IF ((..UATPassthrough '= "STOP") &&  (tSendUAT = "U" )){
							$$$TRACE("Forward to UAT: "_..UATPassthrough)
							Set tStatus = pRequest.AdditionalInfo.SetAt(..UATPassthrough,"ServiceName")
							$$$ThrowOnError(tStatus)
							Set tStatus = ..SendRequestSync(..TargetOperation,pRequest,.tResponse)
							//if 'tStatus $$$LOGERROR(tStatus)
						}Else{
							$$$LOGINFO("UAT STOP")
						}
							
						IF ((..LIVEPassthrough '= "STOP") &&  (tSendLIVE = "L" )){
							$$$TRACE("Forward to LIVE: "_..LIVEPassthrough)
							Set tStatus = pRequest.AdditionalInfo.SetAt(..LIVEPassthrough,"ServiceName")
							$$$ThrowOnError(tStatus)
							Set tStatus = ..SendRequestSync(..TargetOperation,pRequest,.tResponse)
							//if 'tStatus $$$LOGERROR(tStatus)
						}Else{
							$$$LOGINFO("LIVE STOP")							
						}
						
						IF ((..LIVEPassthroughToVAL '= "STOP") &&  (tSendLIVE = "L" )){
							$$$TRACE("Forward to LIVE: "_..LIVEPassthroughToVAL)
							Set tStatus = pRequest.AdditionalInfo.SetAt(..LIVEPassthroughToVAL,"ServiceName")
							$$$ThrowOnError(tStatus)
							Set tStatus = ..SendRequestSync(..TargetOperation,pRequest,.tResponse)
							//if 'tStatus $$$LOGERROR(tStatus)
						}Else{
							$$$LOGINFO("LIVEtoVAL STOP")							
						}						
					}Else{
						Set tStatus = pRequest.AdditionalInfo.SetAt(..TargetService,"ServiceName")
						Set tStatus = ..SendRequestSync(..TargetOperation,pRequest,.tResponse)
					}
		
				}Else{
					$$$ThrowStatus($$$ERROR($$$GeneralError, "OID "_tFacilityOID_" not recognized: " _ pRequest.Name))
				}		
			} Else {
				$$$ThrowStatus($$$ERROR($$$GeneralError, "Request message name not supported: " _ pRequest.Name))	
			}
			if ..SuccessResponse{
				// Hard-code success response
				// Down the road it may be a better fit to only do this on the Async call to retrieve and provide
				If (pRequest.Name = $$$XDSbProvideAndRegisterRequest) {
					Set tStatus = $$$OK
					$$$TRACE("In Hardcode Success Response")		
							
					//#dim tResponse As HS.Message.XMLMessage
					Set pResponse = ##class(HS.Message.XMLMessage).%New()
					Set pResponse.Name=$$$XDSbProvideAndRegisterResponse
					Set pResponse.DocType = "Status_Response"
					
													   
					Do pResponse.ContentStream.Write("<RegistryResponse xmlns=""urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0"" status=""urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:Success""/>")
					Do pResponse.AdditionalInfo.SetAt(1,"booleanStatus")
				}ElseIf (pRequest.Name = $$$XDRProvideAndRegisterRequest){
					Set tStatus = $$$OK
					$$$TRACE("In Hardcode Success Response")		
							
					//#dim tResponse As HS.Message.XMLMessage
					Set pResponse = ##class(HS.Message.XMLMessage).%New()
					Set pResponse.Name=$$$XDRProvideAndRegisterResponse
					Set pResponse.DocType = "Status_Response"
					
													   
					Do pResponse.ContentStream.Write("<RegistryResponse xmlns=""urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0"" status=""urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:Success""/>")
					Do pResponse.AdditionalInfo.SetAt(1,"booleanStatus")

				}ElseIf (pRequest.Name = $$$PIXv3AddRequest){
					Set tStatus = $$$OK
					Set tMessageOID=""
					$$$TRACE("In Hardcode Success Response")		
					
					Set tExpression = "//hl7:id"
					Set tItem = "@root"
					Set tStatus = ##class(HS.IHE.Util).GetXPathValue(pRequest.ContentStream,tExpression,tItem,.tMessageOID)
					
					//#dim tResponse As HS.Message.XMLMessage
					Set pResponse = ##class(HS.Message.XMLMessage).%New()
					Set pResponse.Name			= $$$PIXv3AddResponse
					Set pResponse.DocType		= "MCCI_IN000002UV01"
					
					Set tContentStream = "<MCCI_IN000002UV01 xmlns:hl7=""urn:hl7-org:v3"" xmlns=""urn:hl7-org:v3"" ITSVersion=""XML_1.0"">"_
					"<id root="""_$System.Util.CreateGUID()_"""></id>"_
					"<creationTime value="""_##class(HS.Util.XSLTHelper).timestamp()_"""></creationTime>"_
					"<interactionId root=""2.16.840.1.113883.1.6"" extension=""MCCI_IN000002UV01""></interactionId>"_
					"<processingCode code=""P""></processingCode>"_
					"<processingModeCode code=""R""></processingModeCode>"_
					"<acceptAckCode code=""NE""></acceptAckCode>"_
					"<hl7:receiver typeCode=""RCV""><device classCode=""DEV"" determinerCode=""INSTANCE""><id root=""""></id></device></hl7:receiver>"_
					"<hl7:sender typeCode=""SND""><device classCode=""DEV"" determinerCode=""INSTANCE""><id root=""""></id></device></hl7:sender>"_
					"<acknowledgement><typeCode code=""CA""></typeCode>"_
					"<targetMessage><id root="""_tMessageOID_"""></id></targetMessage>"_
					"</acknowledgement>"_
					"</MCCI_IN000002UV01>"
					Do pResponse.ContentStream.Write(tContentStream)
				}
				ElseIf (pRequest.Name = $$$PIXv3QueryRequest){
					Set pResponse=tResponse
				}
			}Else{
				Set pResponse=tResponse
			}
		}Else {
			$$$ThrowStatus($$$ERROR($$$GeneralError, "Request message class not supported: " _ pRequest.%ClassName(1)))	
		}
	}
	Catch eException {
		Set tStatus = eException.AsStatus()	
	}	
	Quit tStatus
}

/// Given an OID (such as 1.2.3.4.5), find the root OID (such as 1.2.3.4)
ClassMethod DeriveRootOID(pOIDToConvert As %String, pQualifier As %String) As %String
{
	#sqlcompile mode = deferred

	Set pResult = ""

	Try {
		For tI = $Length(pOIDToConvert, "."):-1:1 {    
			Set tOIDToTest = $Piece(pOIDToConvert, ".", 1, tI)

			&sql(
				Select om.%ID Into :tID From HS_Data.OIDMap as om
				Left Outer Join HS_Data.OIDMap_IdentityTypes as it on om.%ID = it.OIDMap
				Where ((it.IdentityTypes = :pQualifier) Or (om.IdentityType = :pQualifier))
				And om.OID = :tOIDToTest
			)

			If ('SQLCODE) {
				Set pResult = tOIDToTest Quit
			}
		}
	}
	Catch (eException) {
		Set pResult = eException.DisplayString()
	}

	Quit pResult
}

ClassMethod Test(pMessageId As %String = "")
{
	s p=##class(Ens.Host).GetShadowInstance("BCBSSC.Router.IHE.Process.ProvideRouter")
	w p.OnInit()
	s m=##class(HS.Message.XMLMessage).%OpenId(pMessageId)
	w p.OnRequest(m, .out)
}

XData PIXQueryDataSource
{
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" xmlns:isc="http://extension-functions.intersystems.com" version="1.0" xmlns="urn:ihe:iti:xds-b:2007" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:wrapper="http://wrapper.intersystems.com" exclude-result-prefixes="isc wrapper">
	<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
		<xsl:param name="FacilityCode"/>
		<xsl:template match="@* | node()" name="ident">
		  <xsl:copy>
		  <xsl:apply-templates select="@* | node()"/>
		  </xsl:copy>
		  </xsl:template>
		  <xsl:template match="/hl7:PRPA_IN201309UV02/hl7:controlActProcess/hl7:queryByParameter/hl7:parameterList/hl7:dataSource"/>
	</xsl:stylesheet>
}

/// Revision number of this class
Parameter SrcVer = 5;

Storage Default
{
<Data name="ProvideRouterDefaultData">
<Subscript>"ProvideRouter"</Subscript>
<Value name="1">
<Value>DoPassthrough</Value>
</Value>
<Value name="2">
<Value>PassthroughService</Value>
</Value>
<Value name="3">
<Value>VALPassthroughFacilities</Value>
</Value>
<Value name="4">
<Value>UATPassthroughFacilities</Value>
</Value>
<Value name="5">
<Value>TargetService</Value>
</Value>
<Value name="6">
<Value>TargetOperation</Value>
</Value>
<Value name="7">
<Value>Repository</Value>
</Value>
<Value name="8">
<Value>SaveToFile</Value>
</Value>
<Value name="9">
<Value>FilePath</Value>
</Value>
<Value name="10">
<Value>Transformer</Value>
</Value>
<Value name="11">
<Value>OutputSet</Value>
</Value>
<Value name="12">
<Value>TraceOperations</Value>
</Value>
<Value name="13">
<Value>VALPassthrough</Value>
</Value>
<Value name="14">
<Value>UATPassthrough</Value>
</Value>
<Value name="15">
<Value>LIVEPassthrough</Value>
</Value>
<Value name="16">
<Value>LIVEPassthroughToVAL</Value>
</Value>
<Value name="17">
<Value>PIXQueryRemoveDataSource</Value>
</Value>
<Value name="18">
<Value>SuccessResponse</Value>
</Value>
<Value name="19">
<Value>SearchTableClass</Value>
</Value>
<Value name="20">
<Value>SendToMemberCheck</Value>
</Value>
<Value name="21">
<Value>MemberCheckProcess</Value>
</Value>
<Value name="22">
<Value>SendToFacility</Value>
</Value>
<Value name="23">
<Value>RouteToFacilityService</Value>
</Value>
</Data>
<DefaultData>ProvideRouterDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
