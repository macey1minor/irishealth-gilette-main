Include (HS.IHE.XDSb, HS.IHE.ATNA, HS.HC)

/// Adds XDSb Provide and Register Header to CCDA XML messages received via file transfer
Class BCBSSC.IHE.XDSb.AddHeader.Process Extends (Ens.BusinessProcess, HS.HC.Util.Trace.Helper) [ ClassType = persistent, Inheritance = left ]
{

Parameter HSDEPLOY = 1;

Parameter SETTINGS = "ReplaceFacilityOID:Basic, FacilityID:Basic,TargetConfigNames:Connection:selector?multiSelect=1&context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId},SOAPAction:Basic,RepositoryOperations,RegistryOperations,ProvidePostProcessor,XDSbRetrieveConsentTarget,ProvidePreProcessor,ValidateSizeAndHash,ProvideAndRegisterToRegisterTransform,RegisterResponseTransform,TextToRetrieveDocumentResponseTransform,RemoveDocumentsTransform,RemoveDocumentsTarget";

/* Required header values exposed as properties */
/// Configuration items to which to send Documents
Property TargetConfigNames As Ens.DataType.ConfigName(MAXLEN = 1000);

/// Setting to control whether the incoming CCD faility OID should be replaced. This is used when the incoming data
/// does not have the correct OID value in the doucment patientRole/id/@root attribute
/// This is important as the Facility OID is used to determine behavior in the CCD pipeline
Property ReplaceFacilityOID As %Boolean;

/// Setting is combined with the ReplaceFacilityOID property in order to replace the facility OID value in the 
/// CCDA contents. In order to avoid hard-coding the OID value, the IHE OID registry is used to derive the currently
/// configured OID value from the Facility ID 
Property FacilityID As %String;

Property SOAPAction As %String(MAXLEN = 100) [ InitialExpression = "urn:ihe:iti:2007:ProvideAndRegisterDocumentSet-b" ];

Property DocumentContentType As %String(MAXLEN = 100) [ InitialExpression = "text/xml" ];

Property DocumentDescription As %String(MAXLEN = 100);

Property DocumentFormatCode As %String(MAXLEN = 100) [ InitialExpression = "2.16.840.1.113883.10.20.1" ];

Property DocumentFormatScheme As %String(MAXLEN = 100) [ InitialExpression = "2.16.840.1.113883.3.88" ];

Property DocumentName As %String(MAXLEN = 100) [ InitialExpression = ">Continuity of Care Document (Transition of Care)" ];

/// Host which will handle the Storage of the document.  Typically the HS.IHE.XDSb.Repository.Operations host.
Property RepositoryOperations As Ens.DataType.ConfigName [ InitialExpression = "HS.IHE.XDSb.Repository.Operations" ];

/// Host which will handle the Registration of the document.  Typically the HS.IHE.XDSb.Repository.Operations host.
/// In a situation where the Repository and Registry were in the same production this value would be the HS.IHE.XDSb.Registry.Operations
Property RegistryOperations As Ens.DataType.ConfigName [ InitialExpression = "HS.IHE.XDSb.Repository.Operations" ];

/// Host which will handle the RemoveDocument request.  Typically the HS.IHE.XDSb.Repository.Operations host.
Property RemoveDocumentsTarget As Ens.DataType.ConfigName [ InitialExpression = "HS.IHE.XDSb.Repository.Operations" ];

Property IHEVersion As %Integer [ InitialExpression = 1 ];

Property Transformer As HS.Util.XSLTTransformer;

/// Checks the size and hash values provided against calculated values 
/// and alerts the user to discrepancies. Disabling this option silences 
/// the alert. Whether this option is enabled or disabled, the calculated 
/// values are used for registration.
Property ValidateSizeAndHash As %Boolean [ InitialExpression = 1 ];

/// Property to hold errors generated while processing the message
Property Errors As HS.Types.IHE.Errors;

/// Internal value while processing for this repository, obtained at startup
Property RepositoryOID As %String(MAXLEN = 64);

/// Pre Processor for XDSb_ProvideAndRegisterDocumentSet
Property ProvidePreProcessor As Ens.DataType.ConfigName;

/// Additional processing for documents with a given format code after document registration/store.
/// Will not execute if registration or store failed. Failure of the post processor will not
/// rollback document store.
/// <p>The value is a delimeted list: formatCode^^formatScheme^^targetHost||formatCode^^formatScheme^^targetHost...
/// <p>For example: urn:nhin:names:acp:XACML^^1.3.6.1.4.1.19376.1.2.3^^HS.Consent.XACML.Importer
Property ProvidePostProcessor As %String(MAXLEN = "");

/// ConfigName of the business host for consent evaluation for retrieve responses.
/// By default, consent is not evaluated for retrieve.
Property XDSbRetrieveConsentTarget As Ens.DataType.ConfigName;

/// Stylesheet used to generate the Registry request
Property ProvideAndRegisterToRegisterTransform As %String(MAXLEN = 250) [ InitialExpression = "IHE/XDSb/Version1/ProvideAndRegisterToRegister.xsl" ];

/// Stylesheet used to generate the Provide And Register response
Property RegisterResponseTransform As %String(MAXLEN = 250) [ InitialExpression = "IHE/XDSb/Version1/RegisterResponse.xsl" ];

/// Stylesheet used to build the Retrieve Response
Property TextToRetrieveDocumentResponseTransform As %String(MAXLEN = 250) [ InitialExpression = "IHE/XDSb/Version1/TextToRetrieveDocumentResponse.xsl" ];

/// Stylesheet used to build the DeleteDocumentSetRequest
Property RemoveDocumentsTransform As %String(MAXLEN = 250) [ InitialExpression = "IHE/XDSb/Version1/RMDRequestToRequest.xsl" ];

Method OnRequest(pRequest As %Persistent, Output pResponse As %Persistent) As %Status
{
	Set tSC = $$$OK
	
	Try {
		Set ..Errors = ##class(HS.Types.IHE.Errors).%New()
		$$$GetTransformer(..Transformer)
		
		Set pResponse = ##class(HS.Message.XMLMessage).%New()
		Set tRequest = pRequest.%ConstructClone()

		If pRequest.%IsA("Ens.StreamContainer") {

			//CNR: Option to replace the facility OID
			if ..ReplaceFacilityOID {
				if ..FacilityID="" {
					THROW ##class(%Exception.General).%New("FacilityID Property is required when ReplaceFaclityOID is set to true")
				}
				else{
					Set tOID = ##class("HS.Data.OIDMap").GetOIDForCode(..FacilityID)
					$$$LOGINFO("tOID: "_tOID)
					if tOID'="" {
						$$$THROWONERROR(tSC, ..ReplaceFacilityInDocument(pRequest, tOID, .transformedCCD))
						Set tRequest.Stream = transformedCCD
					}
					else{
						THROW ##class(%Exception.General).%New("No OID found for facility: "_..FacilityID_" in OID Registry. Unable to replace facility OID in CCD.")
					}
				}
			}
			
			
			//CNR: Add the minimal Provide and Register Header to pass on to Document Source Operation
			Set tSC = ..AddProvideAndRegisterHeader(tRequest, .tResponse) 


			For iTarget=1:1:$L(..TargetConfigNames, ",") { Set tOneTarget=$ZStrip($P(..TargetConfigNames,",",iTarget),"<>W")  Continue:""=tOneTarget
				Set tSC1=..SendRequestSync(tOneTarget,tResponse, .pResponse)
				If $$$ISERR(tSC1) Set tSC=$$$ADDSC(tSC,tSC1)
			}
			
		}
	}
	Catch eException {
		Set tSC = eException.AsStatus()
		Do ..Errors.logError("XDSbRepository","Error",$system.Status.GetErrorText(tSC))
	}
	If ..Errors.Errors.Count() {
		$$$HSTRACE("Errors","Errors",..Errors)
		Set tErrorText="",tWarningText=""
		For tIdx=1:1:..Errors.Errors.Count() {
			Set tError = ..Errors.Errors.GetAt(tIdx)
			If tError.Severity="Error" {
				Set tErrorText = tErrorText _ "["_tError.Description_ "]"
			} Else {
				Set tWarningText = tWarningText _ "["_tError.Description_ "]"
			}
		}
		If tErrorText]"" $$$LOGERROR(tErrorText)
		If tWarningText]"" $$$LOGWARNING(tWarningText)
	}
	#; if the message is an erorr, and we have not reported the problem (contentstream is empty) report the problem
	If $$$ISERR(tSC) && (pResponse.ContentStream.Size=0) {
		Do ##class(HS.IHE.XDSb.Util).ErrorResponse(tSC,pResponse.Name,.pResponse,..Transformer)
		Set tSC=$$$OK
	}
	Quit tSC
}

/// OnResponse must be overridden here to avoid error upon response from async request.
Method OnResponse(pRequest As Ens.Request, ByRef pResponse As Ens.Response, pCallrequest As Ens.Request, pCallresponse As Ens.Response, pCompletionKey As %String) As %Status
{
	Quit $$$OK
}

/// ReplaceFacilityInDocument: Method to be called to replace the OID in CCD with the input parameter
Method ReplaceFacilityInDocument(pRequest As Ens.StreamContainer, pOID As %String, ByRef pOutputStream As %Stream.Object) As %Status
{
	Set tParams = ""
	Set tParams("oid") = "'"_pOID_"'"
			
	// Do the XSL Transform
	Set tStatus = ##class(Ens.Util.URLStream).GetURLStream("xdata://" _ ..%ClassName(1) _ ":ReplaceFacilityOIDTransform", .tCCDATransform)
	$$$ThrowOnError(tStatus)
	Set tStatus = ##class(%XML.XSLT.CompiledStyleSheet).CreateFromStream(tCCDATransform, .tCompiledStyleSheet)
	$$$ThrowOnError(tStatus)
	Set tStatus = ##class(%XML.XSLT.Transformer).TransformStreamWithCompiledXSL(pRequest.Stream, tCompiledStyleSheet, .pOutputStream,, .tParams, ##class(HS.Util.XSLTHelper).%New())
	$$$ThrowOnError(tStatus)

	Quit tStatus
}

/// CNR: Swimming through ObjectScript samples to find the easiest way to attach a header
/// grabbing code from the IHE tester classes now
Method AddProvideAndRegisterHeader(pRequest As Ens.StreamContainer, ByRef pResponse As HS.Message.IHE.XDSb.ProvideAndRegisterRequest)
{
	
	try {
		set tSC = $$$OK

		set tStream =pRequest.Stream
		
		If '$isObject(tStream) || (tStream.Size=0) { 
			$$$LOGERROR("ContentStream is empty")
			Quit
		}
		
		//Define MRN and AssigningAuthorityOID using XPATH 
		$$$ThrowOnError(##class(HS.IHE.Util).GetXPathValue(tStream,"/hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:id","@extension",.tMRN,.tDocObject))
		$$$ThrowOnError(##class(HS.IHE.Util).GetXPathValue(tStream,"/hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:id","@root",.tSourceOID,.tDocObject))
		Set tPatientId = tMRN_"^^^&"_tSourceOID_"&ISO"
		
		$$$ThrowOnError(##class(HS.IHE.Util).GetXPathValue(tStream,"/hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:patient/hl7:name/hl7:family","text()",.tPatientSourceLastName, .tDocObject)) 
		$$$ThrowOnError(##class(HS.IHE.Util).GetXPathValue(tStream,"/hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:patient/hl7:name/hl7:given","text()",.tPatientSourceFirstName, .tDocObject))
		$$$ThrowOnError(##class(HS.IHE.Util).GetXPathValue(tStream,"/hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:patient/hl7:birthTime", "@value", .tPatientSourceDOB, .tDocObject))
		$$$ThrowOnError(##class(HS.IHE.Util).GetXPathValue(tStream,"/hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:patient/hl7:administrativeGenderCode","@code",.tPatientSourceSex, .tDocObject))
		$$$ThrowOnError(##class(HS.IHE.Util).GetXPathValue(tStream,"/hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:addr/hl7:streetAddressLine","text()", .tPatientSourceAddressStreetLine1, .tDocObject)) 
		$$$ThrowOnError(##class(HS.IHE.Util).GetXPathValue(tStream,"/hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:addr/hl7:city", "text()", .tPatientSourceAddressCity, .tDocObject))
		$$$ThrowOnError(##class(HS.IHE.Util).GetXPathValue(tStream,"/hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:addr/hl7:state", "text()", .tPatientSourceAddressState, .tDocObject))
		$$$ThrowOnError(##class(HS.IHE.Util).GetXPathValue(tStream,"/hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:addr/hl7:zip", "text()", .tPatientSourceAddressZip, .tDocObject))
		$$$ThrowOnError(##class(HS.IHE.Util).GetXPathValue(tStream,"/hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:addr/hl7:country", "text()", .tPatientSourceAddressCountry, .tDocObject))
	

	
		#; Put together a ProviderAndRegisterRequest
		Set tRequest = ##class(HS.Message.IHE.XDSb.ProvideAndRegisterRequest).%New()
		Set tRequest.SOAPAction = ..SOAPAction
		Set tRequest.PatientId=tPatientId
		Set tRequest.SourcePatientId = tPatientId
		
	
	
		Set tRequest.SourceId=tSourceOID
		Set tDocument = ##class(HS.Message.IHE.XDSb.Document).%New()

		set tAuthor = ##class(HS.IHE.XDSb.Types.Author).%New()
    	set tAuthor.AuthorPerson = "^Smitty^Gerald^^^"
		set tSC= tDocument.Author.Insert(tAuthor)
		Do tRequest.Author.Insert(tAuthor)
		Set tDocument.SourcePatientId=tPatientId
		
		//CNR: Let's just create and set this
		do ##class(BCBSSC.Util.CCDHelper).GetCodedEntryDefaultValue("ContentTypeCode", .tCodedContentEntry)
		Set tRequest.ContentTypeCode = tCodedContentEntry

																		
		do ##class(BCBSSC.Util.CCDHelper).GetCodedEntryDefaultValue("ConfidentialityCode", .tConfidentialityCodeEntry)
		
		Set tCode = tConfidentialityCodeEntry.Code
		Set tScheme = tConfidentialityCodeEntry.Scheme
		Set tDescription = tConfidentialityCodeEntry.Description
		// Document-level confidentialityCode could Local be nullFlavor.  If so, default in N for Normal.
		If tCode="",tScheme="" Set tCode="N",tScheme="2.16.840.1.113883.5.25",tDescription="Normal"

		Do tDocument.ConfidentialityCode.Insert(##class(HS.IHE.XDSb.Types.CodedValue).%New(tCode,tScheme,tDescription))


		do ##class(BCBSSC.Util.CCDHelper).GetCodedEntryDefaultValue("FormatCode", .tCodedFormatEntry)
		Set tDocument.FormatCode = tCodedFormatEntry


		do ##class(BCBSSC.Util.CCDHelper).GetCodedEntryDefaultValue("HealthcareFacilityTypeCode", .tCodedHealthFacilityEntry)
		Set tDocument.HealthcareFacilityTypeCode = tCodedHealthFacilityEntry

		do ##class(BCBSSC.Util.CCDHelper).GetCodedEntryDefaultValue("PracticeSettingCode", .tCodedPracticeEntry)
		Set tDocument.PracticeSettingCode = tCodedPracticeEntry

		do ##class(BCBSSC.Util.CCDHelper).GetCodedEntryDefaultValue("TypeCode", .tCodedTypeEntry)
		Set tDocument.TypeCode = tCodedTypeEntry
		
		do ##class(BCBSSC.Util.CCDHelper).GetCodedEntryDefaultValue("ClassCode", .tCodedClassEntry)
		Set tDocument.ClassCode = tCodedClassEntry
	

		//copy stream to Body property
		Do tDocument.Body.CopyFrom(tStream)
		Do tDocument.Body.Rewind()
		If tDocument.CreationTime="" Set tDocument.CreationTime=##class(HS.Util.XSLTHelper).xmltimestampToUTC($tr($zdt($h,8),": "))
		Set:tDocument.LanguageCode="" tDocument.LanguageCode="en-US"

		// write new message
		Set tDocument.MimeType=..DocumentContentType

		
		Set tDocument.Availability=1
		Do tRequest.Documents.Insert(tDocument)
			
		//Set pResponse.Name = "XDSb_ProvideAndRegisterRequest"
		//attempt to convert tRequest to a stream
		//$$$ThrowOnError(tRequest.XMLExportToStream(.tRequestStream,"ProvideAndRegisterRequest"))
		//Do pResponse.ContentStream.CopyFrom(tRequestStream)
		//Do pResponse.AdditionalInfo.SetAt(..SOAPAction, "SOAPAction")
		

				
		Set pResponse = tRequest
	}
	catch ex {
		Set tSC = ex.AsStatus()
		$$$LOGERROR(tSC)
	}

	Quit tSC
}

ClassMethod OnGetConnections(Output pArray As %String, item As Ens.Config.Item)
{

	Do ##super(.pArray,pItem)
	If item.GetModifiedSetting("TargetConfigNames",.tValue) {
		For i=1:1:$L(tValue,",") { Set tOne=$ZStrip($P(tValue,",",i),"<>W")  Continue:""=tOne  Set pArray(tOne)="" }
	}
}

Method PrepareAndSendAsync(pRequest As HS.Message.XMLMessage, ByRef pResponse As HS.Message.XMLMessage, Output pWebServiceResponse) As %Status
{
	Set tSC=$$$OK
	Try{
		If '$IsObject($G(pResponse)) $$$ThrowStatus($$$ERROR($$$GeneralError,"XDSb repository did not return a response"))
		Set tReplyTo = pRequest.AdditionalInfo.GetAt("ReplyAddress")
		$$$HSTRACE("reply to","tReplyTo",tReplyTo)
		Do pResponse.AdditionalInfo.SetAt(tReplyTo,"ReplyAddress")
		Do pResponse.AdditionalInfo.SetAt(pRequest.AdditionalInfo.GetAt("RelatesTo"),"RelatesTo")
		Set tSC = ..SendRequestSync(..RepositoryOperations,pResponse)
	}
	Catch ex{
		Set tSC = ex.AsStatus
	}
	Quit tSC
}

XData ReplaceFacilityOIDTransform
{
<?xml version="1.0"?>

<xsl:stylesheet xmlns:hl7="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:lcm="urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" version="1.0" exclude-result-prefixes="rim">

<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>

<xsl:param name="oid" />

<!--<xsl:value-of select="root()/xs:schema/namespace::node()[.=parent::*/@targetNamespace]/name()"/>-->
<xsl:template match="//@* | //node()">
<xsl:copy>
<xsl:apply-templates select="@*"/>
<xsl:apply-templates select="node()"/>
</xsl:copy>
</xsl:template>

<!-- Template to replace the first root attribute under patientRole-->
<xsl:template match="/hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:id[1]/@root">
     <xsl:attribute name="root">
      <xsl:value-of select="$oid"/>
    </xsl:attribute>
</xsl:template>

</xsl:stylesheet>
}

Storage Default
{
<Data name="ProcessDefaultData">
<Subscript>"Process"</Subscript>
<Value name="1">
<Value>TraceOperations</Value>
</Value>
<Value name="2">
<Value>RepositoryOperations</Value>
</Value>
<Value name="3">
<Value>RegistryOperations</Value>
</Value>
<Value name="4">
<Value>RemoveDocumentsTarget</Value>
</Value>
<Value name="5">
<Value>IHEVersion</Value>
</Value>
<Value name="6">
<Value>Transformer</Value>
</Value>
<Value name="7">
<Value>ValidateSizeAndHash</Value>
</Value>
<Value name="8">
<Value>Errors</Value>
</Value>
<Value name="9">
<Value>RepositoryOID</Value>
</Value>
<Value name="10">
<Value>ProvidePreProcessor</Value>
</Value>
<Value name="11">
<Value>ProvidePostProcessor</Value>
</Value>
<Value name="12">
<Value>XDSbRetrieveConsentTarget</Value>
</Value>
<Value name="13">
<Value>ProvideAndRegisterToRegisterTransform</Value>
</Value>
<Value name="14">
<Value>RegisterResponseTransform</Value>
</Value>
<Value name="15">
<Value>TextToRetrieveDocumentResponseTransform</Value>
</Value>
<Value name="16">
<Value>RemoveDocumentsTransform</Value>
</Value>
<Value name="17">
<Value>SOAPAction</Value>
</Value>
<Value name="18">
<Value>DocumentContentType</Value>
</Value>
<Value name="19">
<Value>DocumentDescription</Value>
</Value>
<Value name="20">
<Value>DocumentFormatCode</Value>
</Value>
<Value name="21">
<Value>DocumentFormatScheme</Value>
</Value>
<Value name="22">
<Value>DocumentName</Value>
</Value>
<Value name="23">
<Value>TargetConfigNames</Value>
</Value>
<Value name="24">
<Value>ReplaceFacilityOID</Value>
</Value>
<Value name="25">
<Value>FacilityID</Value>
</Value>
</Data>
<DefaultData>ProcessDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

/// Revision number of this class
Parameter SrcVer = 3;

}
