/// CCD/XML Member Process extends HL7 Process in order to inherit the conditional logic for Member Checking Routine
Class BCBSSC.Router.IHE.MemberEligibilityCheckProcessXML Extends BCBSSC.Router.HL7.MemberEligibilityCheckProcess
{

/// Message Source
/// Typically set to the Facility ID
Property MessageSource As %String;

/// Subscriber number location in message. 
/// Format expected: /hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section[hl7:templateId/@root='2.16.840.1.113883.10.20.22.2.18']/hl7:entry/hl7:act/hl7:entryRelationship/hl7:act/hl7:participant[@typeCode='COV']/hl7:participantRole/hl7:id/@extension
/// Enter xPath to the collection: If there are mutliple instances, all IDs will be sent
Property SubscriberNumberLocation As %String(MAXLEN = 1024) [ InitialExpression = "/hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section[hl7:templateId/@root='2.16.840.1.113883.10.20.22.2.18']/hl7:entry/hl7:act/hl7:entryRelationship/hl7:act/hl7:participant[@typeCode='COV']/hl7:participantRole/hl7:id/@extension" ];

/// AssigningAuthority location in message. Group Name
/// Format expected: /hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section[hl7:templateId/@root="2.16.840.1.113883.10.20.22.2.18"]/hl7:entry/hl7:act/hl7:entryRelationship/hl7:act//hl7:code/@displayName
Property AssigningAuthorityLocation As %String(MAXLEN = 1024) [ InitialExpression = "/hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section[hl7:templateId/@root='2.16.840.1.113883.10.20.22.2.18']/hl7:entry/hl7:act/hl7:entryRelationship/hl7:act/hl7:code/@displayName" ];

/// DateOfService location in message. If an Encounter History section is provided, use the max effectiveTime  
/// Format expected: /hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section[hl7:templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/hl7:entry/hl7:encounter/hl7:effectiveTime/@value"
/// Enter Xpath to the collection - the most recent date will be used
/// If the effectiveTime is not found, will also check for 'low' subnode
Property DateOfServiceLocation As %String(MAXLEN = 1024) [ InitialExpression = "/hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section[hl7:templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/hl7:entry/hl7:encounter/hl7:effectiveTime/@value" ];

/// EncompassingEncounterDate location in message. Optional. If populated, will check first Encounter History use as DateOfService and then check Encompassing Encounter if the DateOfService is empty  
/// Format expected: /hl7:ClinicalDocument/hl7:component/hl7:encompassingEncounter/hl7:effectiveTime/hl7:low/@value"
Property EncompassingEncounterDateLocation As %String(MAXLEN = 1024) [ InitialExpression = "/hl7:ClinicalDocument/hl7:component/hl7:encompassingEncounter/hl7:effectiveTime/hl7:low/@value" ];

/// FirstName location in message. 
/// Format expected: /hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:patient/hl7:name/hl7:given[1]
Property FirstNameLocation As %String(MAXLEN = 1024) [ InitialExpression = "/hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:patient/hl7:name/hl7:given[1]" ];

/// LastName location in message. 
/// Format expected: /hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:patient/hl7:name/hl7:family
Property LastNameLocation As %String(MAXLEN = 1024) [ InitialExpression = "/hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:patient/hl7:name/hl7:family" ];

/// MiddleName location in message. 
/// Format expected: /hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:patient/hl7:name/hl7:given[2]
Property MiddleNameLocation As %String(MAXLEN = 1024) [ InitialExpression = "/hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:patient/hl7:name/hl7:given[2]" ];

/// Date of Birth location in message. 
/// Format expected: /hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:patient/hl7:birthTime/@value
Property DateOfBirthLocation As %String(MAXLEN = 1024) [ InitialExpression = "/hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:patient/hl7:birthTime/@value" ];

/// Street location in message. Format expected: /hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:addr/hl7:streetAddressLine
Property StreetLocation As %String(MAXLEN = 1024) [ InitialExpression = "/hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:addr/hl7:streetAddressLine" ];

/// State location in message. Format expected: /hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:addr/hl7:state
Property StateLocation As %String(MAXLEN = 1024) [ InitialExpression = "P/hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:addr/hl7:state" ];

/// Record Unique ID Location - Found on PNR Header for HS.Message.XMLMessage 
Property RecordUniqueIDLocation As %String(MAXLEN = 1024);

/// Record Source Location - Not used. Found on PNR Header 
Property RecordSourceLocation As %String;

/// Record Source to be recorded in message check audit 
Property RecordSource As %String;

/// Store a set of searchable properties associated with each message processed. <br/>
/// These records will be stored in the named SearchTable class, if any.
Property SearchTableClass As %String(MAXLEN = 128) [ InitialExpression = "EnsLib.EDI.XML.SearchTable" ];

Parameter SETTINGS = "MessageSource:Basic,RecordSource:Basic,SubscriberNumberLocation:Basic,AssigningAuthorityLocation:Basic,EncompassingEncounterDateLocation:Basic,DateOfServiceLocation:Basic,FirstNameLocation:Basic,LastNameLocation:Basic,DateOfBirthLocation:Basic,,StreetLocation:Basic,StateLocation:Basic";

Method OnRequest(pRequest As %Persistent, Output pResponse As Ens.StreamContainer) As %Status
{
        Set tSC = $$$OK  
        Try {

            Set inputStream = ##class(%Stream.GlobalCharacter).%New()

            #; There are two possible messages types: HS.Message.XMLMessage (XDR) or HS.Message.IHE.XDSb.ProvideAndRegisterRequest (File-based/SDA CCDs)

            if pRequest.%IsA("HS.Message.IHE.XDSb.ProvideAndRegisterRequest") {
                // Access the stream directly from Body of ProvideAndRegisterRequest
                If 'pRequest.Documents.Count() Set tStatus = $$$ERROR($$$GeneralError, "No documents found in input request") $$$ThrowOnError(tStatus)
		        If 'pRequest.Documents.GetAt(1).Body.Size Set tStatus = $$$ERROR($$$GeneralError, "Empty document found in input request") $$$ThrowOnError(tStatus)

                //Unique ID is found on the PnR
                Set tRecordUniqueID = pRequest.UniqueId

		        #; Get document body - the other values are in the CCD
		        Set tDocumentStream = pRequest.Documents.GetAt(1).Body
            }
            elseif pRequest.%IsA("HS.Message.XMLMessage"){
                if 'pRequest.StreamCollection.Count() Set tStatus = $$$ERROR($$$GeneralError, "No documents found in input request") $$$ThrowOnError(tStatus)
            	#; if there are streams, send over MTOM  (catch HS and EnsLib versions)
		        If pRequest.StreamCollection.Count()>0 {
			        If 'pRequest.StreamCollection.GetAt(1).Body.Size Set tStatus = $$$ERROR($$$GeneralError, "Empty document found in input request") $$$ThrowOnError(tStatus)
    
                    //Get the tRecordUniqueID from the ContentStream
                  
					Set tRecordUniqueID = ""
					Set tExpression = "//rim:ExternalIdentifier[@identificationScheme='urn:uuid:96fdda7c-d067-4183-912e-bf5ee74998a8']"
					Set tItem = "@value"
					Set tStatus = ##class(HS.IHE.Util).GetXPathValue(pRequest.ContentStream,tExpression,tItem,.tRecordUniqueID)
					$$$ThrowOnError(tStatus)

                    Set tDocumentStream = pRequest.StreamCollection.GetAt(1).Body    
			    }
            }
            else {
                Set tStatus = $$$ERROR($$$GeneralError, "Unrecognized message type received. Expecting HS.Message.XMLMessage or HS.Message.IHE.XDSb.ProvideAndRegisterRequest") $$$ThrowOnError(tStatus)
            }

            // Use the adapted GetLocationValue method
            do ..GetLocationValue(tDocumentStream, ..FirstNameLocation, .tFirstName)
            do ..GetLocationValue(tDocumentStream, ..LastNameLocation, .tLastName)
            do ..GetLocationValue(tDocumentStream, ..MiddleNameLocation, .tMiddleName)
            do ..GetLocationValue(tDocumentStream, ..DateOfBirthLocation, .tDateOfBirth)
            do ..GetLocationValue(tDocumentStream, ..StreetLocation, .tStreet)
            do ..GetLocationValue(tDocumentStream, ..StateLocation, .tState)
            do ..GetLocationValue(tDocumentStream, ..EncompassingEncounterDateLocation, .tEncompassingEncounterDate)
            
            //Get possible list values for DateOfServce which is in Encounter History 
            //and Payer IDs which is in Payers
            do ..GetLocationValuesMultiple(tDocumentStream, ..DateOfServiceLocation, .tDateOfService)
			if tDateOfService.Count()=0 {
				set tAltDateOfServiceLocation = $REPLACE(..DateOfServiceLocation,"@value", "hl7:low/@value")
				//$$$LOGINFO("alternative DateOfServiceLocation is:"_tAltDateOfServiceLocation)
				do ..GetLocationValuesMultiple(tDocumentStream, tAltDateOfServiceLocation, .tDateOfService)
			}
            do ..GetLocationValuesMultiple(tDocumentStream, ..SubscriberNumberLocation, .tSubscriberNumber)
            do ..GetLocationValuesMultiple(tDocumentStream, ..AssigningAuthorityLocation, .tAssigningAuthority)
            
            // BuildMemberEligibilityRequest handles lists and strings    
            set tSC = ..BuildMemberEligibilityRequestCCDA(tSubscriberNumber, tAssigningAuthority, tFirstName, tMiddleName, tLastName, tDateOfBirth,  tDateOfService, tRecordUniqueID, ..MessageSource, tStreet, tState, tEncompassingEncounterDate, .tSearchRequest)
            $$$ThrowOnError(tSC)
            //Even if required fields are missing, still sending through to check process as downstream
            //Reporting is based on results of member check 
            Set tSC = ..MemberEligibilityCheck(pRequest,tSearchRequest, "CCDA",, .tResponse, .tRouteEligibleMessage, .tRouteBadMessage, .tIsNewborn)
            $$$ThrowOnError(tSC)
			//Respond to return value from MemberEligibilityCheck call
			if tRouteEligibleMessage{ 
	            //Append subscriber ID to AdditionalInfo
                //CNR: This segment needs to be added onto the HL7 message that is sent to edges for notification
                Set tSubscriberID = $PIECE(tResponse.AdditionalInfo.GetAt("SubscriberID"),"-",0,1)
                Set tPatientID = $PIECE(tResponse.AdditionalInfo.GetAt("SubscriberID"),"-",2)
                            
                //CNR: Cloning pRequest
                #dim tClonedRequest as Ens.Request
				set tClonedRequest=pRequest.%ConstructClone(1)
				do tClonedRequest.AdditionalInfo.SetAt(tSubscriberID, "SubscriberID")
				do tClonedRequest.AdditionalInfo.SetAt(tPatientID, "PatientID")
	            
	            // CNR: if Newborn, we replace the ID card value in CCD. Replace the CCD in Body or DocumentStream
	            if tIsNewborn=1 {
		             //if the message is a newborn, call update to append "-newborn" to IDcard value 
		             $$$ThrowOnError(..UpdateNewBornRequestCCDA(tClonedRequest, tResponse.AdditionalInfo.GetAt("SubscriberID"),..SubscriberNumberLocation , .tUpdatedRequest))
					 Set tClonedRequest = tUpdatedRequest
                }    
                ;Send the Patient message to Target
                For iTarget=1:1:$L(..EligibleMessageTarget, ",") { 
                    Set tOneTarget=$ZStrip($P(..EligibleMessageTarget,",",iTarget),"<>W")  Continue:""=tOneTarget
        			Set tSC1=..SendRequestAsync(tOneTarget,tClonedRequest, .pResponse)  Set:$$$ISERR(tSC1) tSC=$$$ADDSC(tSC,tSC1)
	            }     
              }
              elseif tRouteBadMessage
              {
                  //route original message to Bad Message Handler
                  For iTarget=1:1:$L(..DiscardedMessageTarget, ",") { 
                      Set tOneTarget=$ZStrip($P(..DiscardedMessageTarget,",",iTarget),"<>W")  Continue:""=tOneTarget    	    
    			      Set tSC1=..SendRequestAsync(tOneTarget,pRequest, .pResponse)  Set:$$$ISERR(tSC1) tSC=$$$ADDSC(tSC,tSC1)
                  }
              }
        }
        Catch ex {
            // Handle any exceptions here
            Set tSC = ex.AsStatus()
		    $$$LOGERROR(tSC)
        }
        
        Quit tSC
}

Method OnResponse(request As %Library.Persistent, ByRef response As %Library.Persistent, callrequest As %Library.Persistent, callresponse As %Library.Persistent, pCompletionKey As %String) As %Status
{
	//handle async response
	Quit $$$OK
}

/// pLocation can be set using XPATH
ClassMethod GetLocationValue(pStream As %Stream.Object, pLocation As %String, ByRef pValue As %String)
{
    Set pValue = ""

	If '$isObject(pStream) || (pStream.Size=0) { 
			$$$LOGERROR("ContentStream is empty")
			Quit
		}
	
    //parse location for @attribute at the end in order to format arguments correctly for GetXpathValue call

    Set tLen = $LENGTH(pLocation, "/@")

    if tLen = 1 {
        Set tExpression = pLocation
        Set tItem = ""
    }
    else {
        Set tExpression = $PIECE(pLocation, "/@", 1, tLen-1)
        Set tItem = $PIECE(pLocation, "/@", tLen)
    }
    if tItem="" {
        Set tItem = "text()"
    }
    else {
        Set tItem = "@"_tItem
    }
    //$$$LOGINFO("tExpression is: "_tExpression)
    //$$$LOGINFO("tItem is: "_tItem)
	//Get location using XPATH 
	$$$ThrowOnError(##class(HS.IHE.Util).GetXPathValue(pStream, tExpression,tItem,.pValue,.tDocObject))

    // Rewind the stream
    Do pStream.Rewind()
}

ClassMethod GetLocationValuesMultiple(pStream As %Stream.Object, pLocation As %String, ByRef pValue As %String)
{
    Set pValue = ""

	If '$isObject(pStream) || (pStream.Size=0) { 
			$$$LOGERROR("ContentStream is empty")
			Quit
		}
	
    //parse location for @attribute at the end in order to format arguments correctly for GetXpathValue call

    Set tLen = $LENGTH(pLocation, "/@")

    if tLen = 1 {
        Set tExpression = pLocation
        Set tItem = ""
    }
    else {
        //determine if the attribute symbol is at the end or not by checking if there are further slashes in second section
        if $PIECE(pLocation, "/@", tLen) [ "/" {
            //There was one enmbedded attribute but it wasn't the trailing item
            Set tExpression = pLocation
            Set tItem = ""
        }
        else {
            Set tExpression = $PIECE(pLocation, "/@", 1, tLen-1)
            Set tItem = $PIECE(pLocation, "/@", tLen)
        }
    }
    if tItem="" {
        Set tItem = "text()"
    }
    else {
        Set tItem = "@"_tItem
    }
	//Get location using XPATH 
	$$$ThrowOnError(##class(HS.IHE.Util).GetXPathExpression(pStream, tExpression,tItem,.pValue,.tDocObject))

    // Rewind the stream
    Do pStream.Rewind()
}

// pSubscriberNumber and pDateOfService may contain a List

ClassMethod BuildMemberEligibilityRequestCCDA(pSubscriberNumber, pAssigningAuthority, pFirstName, pMiddleName, pLastName, pDateOfBirth, pDateOfService, pRecordUniqueID, pRecordSource, pStreet, pState, pEncompassingEncounterDate, ByRef pResult As HS.Message.PatientSearchRequest) As %Status
{
    
    Set pResult = ##class(HS.Message.PatientSearchRequest).%New()

    //Process pSubscriberNumber and AssigningAuthority
    if pSubscriberNumber.Count() > 0 {
       
        Set identifiersList = ##class(%ListOfObjects).%New()
        for i=1:1:pSubscriberNumber.Count() {
           
         Set identifierObj = ##class(HS.Types.Identifier).%New()
            Set identifierObj.Extension = pSubscriberNumber.GetAt(i).Value
            //assuming if the AA value is a list, that it matches length of the subscriber number list
            //$$$LOGINFO("Count of AAs:"_pAssigningAuthority.Count())
            if pAssigningAuthority.Count() >= i {
                Set identifierObj.AssigningAuthorityName = pAssigningAuthority.GetAt(i).Value
            }
            else {
                //default to the Data Source name if no AssigningAuthority found
                set pResult.AssigningAuthority = pRecordSource
            }
            Do identifiersList.Insert(identifierObj)
        }
        Set pResult.Identifiers = identifiersList
        
    }
    else {
        // Set single SubscriberNumber and AA
        set pResult.AssigningAuthority = pAssigningAuthority
        set pResult.MRN = pSubscriberNumber
    }

    //Process Date of Service - First check for value of EncompassingEncounterDate. If not present, then check DateOfService from Encounter History
    //$$$LOGINFO("Count of DateOfService:"_pDateOfService.Count())
    
    //Process Date of Service - First check for value of History of Encounters
    //If no history, use EncompassingEncounterDate. 
    //$$$LOGINFO("pDateOfService:"_pDateOfService)
    //$$$LOGINFO("Count of DateOfService:"_pDateOfService.Count())

    if pDateOfService.Count() > 0 {
       // $$$LOGINFO("Inside loop")
        //if any return found, parse through list to get the most recent
        //Initialize
        set mostRecentDate = pDateOfService.GetAt(1).ValueGet()
        //$$$LOGINFO("Count:"_pDateOfService.Count())
        //$$$LOGINFO("Most Recent Date initialize: "_mostRecentDate)
        for i=2:1:pDateOfService.Count() {
            if pDateOfService.GetAt(i).ValueGet() > mostRecentDate {
                set mostRecentDate = pDateOfService.GetAt(i).ValueGet()
            }
        }
        //$$$LOGINFO("Most Recent Date is: "_mostRecentDate)
        Do pResult.AdditionalInfo.SetAt(..FormatDate(mostRecentDate), "DateOfService")
    }
    else {
        if pDateOfService '="" {
            Do pResult.AdditionalInfo.SetAt(..FormatDate(pDateOfService), "DateOfService")
        }
        elseif pEncompassingEncounterDate '= ""{
          //$$$LOGINFO("Encompassing Date Found: "_pEncompassingEncounterDate)
          Do pResult.AdditionalInfo.SetAt(..FormatDate(pEncompassingEncounterDate), "DateOfService")
    	}
    	//No Date of Service -- will send an empty value to the Member Eligibility Check
    }

    // Set standard properties
    Set pResult.FirstName = pFirstName
    Set pResult.LastName = pLastName
    Set pResult.MiddleName = pMiddleName
    Set pResult.DOB = $ZDATEH($EXTRACT(pDateOfBirth,1,8),8)
    Set pResult.CreatedBy = pRecordSource
    Set pResult.Street = pStreet
    Set pResult.State = pState

    // Set custom properties in AdditionalInfo
    Do pResult.AdditionalInfo.SetAt(pRecordUniqueID, "RecordUniqueID")
    Do pResult.AdditionalInfo.SetAt(pRecordSource, "RecordSource")

    Quit $$$OK
}

// UpdateNewBornRequestCCDA: Takes in Input request and calls the XSL to replace subscriber ID

// then writes updated DocumentStream into pOutputRequest and updates Subscriber ID

// with new newborn subscriberId in the matching location

ClassMethod UpdateNewBornRequestCCDA(pInput As Ens.Request, pSubscriberID As %String, pSubscriberNumberLocation As %String, Output pOutput As Ens.Request) As %Status
{
	set tSC = $$$OK
	
	try {
		if pInput.%IsA("HS.Message.IHE.XDSb.ProvideAndRegisterRequest") {
			#; set input stream
			Set tInputStream = pInput.Documents.GetAt(1).Body 
		}
        elseif pRequest.%IsA("HS.Message.XMLMessage"){
			Set tInputStream = pInput.StreamCollection.GetAt(1).Body 
        }       
        //CNR: Use an XSL - take in target subscriberID with -newborn as parameter
        $$$ThrowOnError(..ReplaceSubscriberID(tInputStream,pSubscriberID, pSubscriberNumberLocation, .tOutputStream))
		
		Set pOutput = pInput.%ConstructClone(1)
		//Replace the CCD in the output
		if pInput.%IsA("HS.Message.IHE.XDSb.ProvideAndRegisterRequest") {
		   #; Set document body with new document
		   Set pOutput.Documents.GetAt(1).Body = tOutputStream
        }
        elseif pInput.%IsA("HS.Message.XMLMessage"){
		   Set pOutput.StreamCollection.GetAt(1).Body = tOutputStream
        }       
	}
	Catch ex {
            // Handle any exceptions here
            Set tSC = ex.AsStatus()
		    w "error:"_tSC,!
    }
        
    Quit tSC
}

ClassMethod FormatDate(pDate As %String, pFormat As %String = "YYYY-MM-DD") As %String
{
    Set resultDate = ""
    if $LENGTH(pDate) >= 8 {
        Set resultDate = $EXTRACT(pDate,1,4)_"-"_$EXTRACT(pDate,5,6)_"-"_$EXTRACT(pDate,7,8)
    }
    Quit resultDate
}

// Unit Test to send a positive case through

ClassMethod Test(tMessage As %String = "") As %Status [ Internal ]
{
	#dim tSC 			As %Status=$$$OK
	#dim eException  	As %Exception.AbstractException
    #dim tRequest as EnsLib.HL7.Message
    set processName = ""
    /*
	Try {
        #;First we grab a previous request using the message body ID from the message viewer/visual trace
        Set tRequest=##class(EnsLib.HL7.Message).%New()
        If tMessage '= ""{
            Set tRequest=##class(EnsLib.HL7.Message).%OpenId(tMessage)
        }
        Else{

            // Load HL7Message per UnitTest
	        set HL7Message=..GetMessage("SourceMessageA01")
	        if '$IsObject(HL7Message) {
                Throw $$$ERROR(5001,"Failed to correlate Xdata for Source Message")
            }
    	    set tRequest=HL7Message.%ConstructClone(1)
        }
      
        // Next we create an instance of the Process.  GetShadowInstance will return the live instance if the production is running otherwise a static but populated instance
        Set tProcess=##class(Ens.Host).GetShadowInstance(processName)
        Do tProcess.OnInit()

        //Since the business item is a process, the method to call is always OnRequest
        Set tSC = tProcess.OnRequest(tRequest,.tResponse)
  	}
	Catch eException {
		Set tSC=eException.AsStatus()
	}
    */
	Quit tSC
}

/****Helper Methods ****/
/// USE CASE #1: ReplaceFacilityInDocument: Method to be called to replace the OID in CCD with the input parameter
ClassMethod ReplaceSubscriberID(pStream As %Stream.Object, pSubscriberID As %String, pSubscriberNumberLocation As %String, ByRef pOutputStream As %Stream.Object) As %Status
{
	Set tParams = ""
	Set tParams("NewSubscriberID") = "'"_pSubscriberID_"'"

    set tParamName = "NewSubscriberID"
   
    //Format XPATH for matching based on SubscriberNumberLocation
    set updateXPath = ..FormatXPathContains(pSubscriberNumberLocation, tParamName)
	
    // Get the base for the XSL Transform 
	Set tStatus = ##class(Ens.Util.URLStream).GetURLStream("xdata://" _ $THIS _ ":ReplaceSubscriberID", .tXSL)
	$$$ThrowOnError(tStatus)

    //Replace the XPATH in XSL with formatted path and param name
    set tXSLStream = ..ReplaceInStream(tXSL, "{XPATH}", updateXPath)
    //Replace the PARAM
    set tXSLStream = ..ReplaceInStream(tXSLStream,"{PARAM}", tParamName)

    // Use the updated XSL in the Transform
	Set tStatus = ##class(%XML.XSLT.CompiledStyleSheet).CreateFromStream(tXSLStream, .tCompiledStyleSheet)
	$$$ThrowOnError(tStatus)
	Set tStatus = ##class(%XML.XSLT.Transformer).TransformStreamWithCompiledXSL(pStream, tCompiledStyleSheet, .pOutputStream,, .tParams, ##class(HS.Util.XSLTHelper).%New())
	$$$ThrowOnError(tStatus)

	Quit tStatus
}

// Format the XPATH by adding [XXX and contains($NewSubscriberID, XXX)] where XXX is the attribute at the end of the XPATH

ClassMethod FormatXPathContains(pXPath As %String, pParamName As %String) As %String
{
    // Calculate the number of pieces up to the last slash
    set tPiecesCount = $LENGTH(pXPath, "/")

    // Extract the last part using $PIECE
    set tAttribute = $PIECE(pXPath, "/",tPiecesCount )

    // Extract the path up to the last slash
    set tStartXPath = $PIECE(pXPath, "/", 1, tPiecesCount - 1)

    set tUpdatedXPath = tStartXPath_"["_tAttribute_" and contains($"_pParamName_", "_tAttribute_")]/"_tAttribute
    return tUpdatedXPath
}

// Search and replace with STreams

ClassMethod ReplaceInStream(originalStream As %Stream.Object, oldValue As %String, newValue As %String) As %Stream.Object
{
    // Create a new stream to hold the modified content
    set newStream = ##class(%Stream.GlobalCharacter).%New()

    // Ensure the original stream is at the beginning
    do originalStream.Rewind()

    // Variables to handle reading from the stream
    set chunkSize = 32000  // Adjust chunk size based on expected data sizes
    set buffer = ""
    
    while 'originalStream.AtEnd {
        set buffer = originalStream.Read(chunkSize)  // Read chunks from the original stream
       // set buffer = $ZCONVERT(buffer, "O", "UTF8")   // Ensure correct character encoding if needed
        set buffer = $REPLACE(buffer, oldValue, newValue)  // Replace the old value with the new value
        do newStream.Write(buffer)  // Write the modified chunk to the new stream
    }

    // Return the new stream containing the updated data
    return newStream
}

ClassMethod TestFormatXPathContains()
{
    set testXPath = "/hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section[hl7:templateId/@root='2.16.840.1.113883.10.20.22.2.18']/hl7:entry/hl7:act/hl7:entryRelationship/hl7:act/hl7:participant[@typeCode='COV']/hl7:participantRole/hl7:id/@extension"
    set tParamName = "NewSubscriberID"
    
    w ..FormatXPathContains(testXPath, tParamName)
}

ClassMethod TestReplaceSubscriberID()
{
    #dim message as HS.Message.XMLMessage
	Set ClassName = "BCBSSC.Util.CCDAMessage02"
	Set XDataBody = "CCDABody"
	Set XDataHeader = "CCDAPnRHeader"
	Set OutputDirectory = "c:/temp/"
    set testXPath = "/hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section[hl7:templateId/@root='2.16.840.1.113883.10.20.22.2.18']/hl7:entry/hl7:act/hl7:entryRelationship/hl7:act/hl7:participant[@typeCode='COV']/hl7:participantRole/hl7:id/@extension"
	
	//Load CCDABody and CCDAHeader from XDATA blocks in <ClassName> class
	Set tStatus = ##class(Ens.Util.URLStream).GetURLStream("xdata://" _ ClassName _ ":"_XDataBody, .CCDABody)
	$$$ThrowOnError(tStatus)


    do ..ReplaceSubscriberID(CCDABody, "ID123456-newborn", testXPath, .pOutput)

    do ##class("BCBSSC.Util.XSLTester").WriteContentToFile("C:/temp/output.xml", pOutput)
}

ClassMethod TestUpdateNewBornRequestCCDA()
{

	#dim tSC 			As %Status=$$$OK
	#dim eException  	As %Exception.AbstractException
    #dim tRequest as HS.Message.IHE.XDSb.ProvideAndRegisterRequest
    
    Set ClassName = "BCBSSC.Util.CCDAMessage02"
	Set XDataBody = "CCDABody"
	Set XDataHeader = "CCDAPnRHeader"
	Set OutputDirectory = "c:/temp/"
    set testXPath = "/hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section[hl7:templateId/@root='2.16.840.1.113883.10.20.22.2.18']/hl7:entry/hl7:act/hl7:entryRelationship/hl7:act/hl7:participant[@typeCode='COV']/hl7:participantRole/hl7:id/@extension"
	

	//Load CCDABody and CCDAHeader from XDATA blocks in <ClassName> class
	Set tStatus = ##class(Ens.Util.URLStream).GetURLStream("xdata://" _ ClassName _ ":"_XDataBody, .CCDABody)
	//$$$ThrowOnError(tStatus)
    if $$$ISERR(tStatus) { 
        w "Error reading CCD Stream",!
        quit tSC
    }
    //Construct the PnR request in an HS.Message.IHE.XDSb.ProvideAndRegisterRequest
    set tStatus = ..AddProvideAndRegisterHeader( CCDABody, .tRequest)

    if $$$ISERR(tStatus) { 
        w "Error in AddProvideAndRegister",!
        quit tSC
    }
    else {
        set tStatus = ..UpdateNewBornRequestCCDA(tRequest, "ID123456-newborn",testXPath , .tUpdatedRequest)
         if $$$ISERR(tStatus) {
            w "Error in UpdateNewBornRequestCCDA call",!
            quit tSC
         }
         else {
             do ##class("BCBSSC.Util.XSLTester").WriteContentToFile("C:/temp/output.xml", tUpdatedRequest.GetAt(1).Body)
         }
    }
   
	//Call UpdateNewBornRequestCCDA
	//Check output
	
	//..UpdateNewBornRequestCCDA(tClonedRequest, tResponse.AdditionalInfo.GetAt("SubscriberID"),..SubscriberNumberLocation , .tUpdatedRequest)
}

/// CNR: Swimming through ObjectScript samples to find the easiest way to attach a header
/// grabbing code from the IHE tester classes now
ClassMethod AddProvideAndRegisterHeader(pInput As %Stream.Object, ByRef pResponse As HS.Message.IHE.XDSb.ProvideAndRegisterRequest)
{
    set SOAPAction  = "urn:ihe:iti:2007:ProvideAndRegisterDocumentSet-b" 

    set DocumentContentType  = "text/xml"

	
	try {
		set tSC = $$$OK

		set tStream =pInput
		
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
		Set pResponse = ##class(HS.Message.IHE.XDSb.ProvideAndRegisterRequest).%New()
		Set pResponse.SOAPAction = SOAPAction
		Set pResponse.PatientId=tPatientId
		Set pResponse.SourcePatientId = tPatientId
		
	
	
		Set pResponse.SourceId=tSourceOID
		Set tDocument = ##class(HS.Message.IHE.XDSb.Document).%New()

		set tAuthor = ##class(HS.IHE.XDSb.Types.Author).%New()
    	set tAuthor.AuthorPerson = "^Smitty^Gerald^^^"
		set tSC= tDocument.Author.Insert(tAuthor)
		Do pResponse.Author.Insert(tAuthor)
		Set tDocument.SourcePatientId=tPatientId
		
		//CNR: Let's just create and set this
		do ##class(BCBSSC.Util.CCDHelper).GetCodedEntryDefaultValue("ContentTypeCode", .tCodedContentEntry)
		Set pResponse.ContentTypeCode = tCodedContentEntry

																		
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
		Set tDocument.MimeType=DocumentContentType

		
		Set tDocument.Availability=1
		Do pResponse.Documents.Insert(tDocument)
			
		//Set pResponse.Name = "XDSb_ProvideAndRegisterRequest"
		//attempt to convert tRequest to a stream
		//$$$ThrowOnError(tRequest.XMLExportToStream(.tRequestStream,"ProvideAndRegisterRequest"))
		//Do pResponse.ContentStream.CopyFrom(tRequestStream)
		//Do pResponse.AdditionalInfo.SetAt(..SOAPAction, "SOAPAction")
	}
	catch ex {
		Set tSC = ex.AsStatus()
		$$$LOGERROR(tSC)
	}

	Quit tSC
}

ClassMethod GetMessageCCDA(XDataName As %String) As Ens.StreamContainer
{
    #dim SourceMessage as Ens.StreamContainer
    Set SourceMessage = ##class(Ens.StreamContainer).%New()
    
    quit SourceMessage
}

/// Replace SubscriberID: XSL embedded in XDATA block
/// We will use some trickery to replace the value of XPATH with a dynamically
/// generated XPATH location for replacement before compiling the stylesheet
XData ReplaceSubscriberID
{
<?xml version="1.0"?>

<xsl:stylesheet xmlns:hl7="urn:hl7-org:v3"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:lcm="urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0"
	xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" version="1.0" exclude-result-prefixes="rim">

	<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
	<xsl:param name="{PARAM}" />

	<!--<xsl:value-of select="root()/xs:schema/namespace::node()[.=parent::*/@targetNamespace]/name()"/>-->
	<!--This is the identity template that copies everything to output -->
	<xsl:template match="//@* | //node()">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>

	<!-- Template to identify and replace the subscriberID -->
	<xsl:template match="{XPATH}">
	   <xsl:value-of select="${PARAM}"/>
	</xsl:template>

</xsl:stylesheet>
}

Storage Default
{
<Data name="MemberEligibilityCheckProcessXMLDefaultData">
<Subscript>"MemberEligibilityCheckProcessXML"</Subscript>
<Value name="1">
<Value>SubscriberNumberLocation</Value>
</Value>
<Value name="2">
<Value>AssigningAuthorityLocation</Value>
</Value>
<Value name="3">
<Value>DateOfServiceLocation</Value>
</Value>
<Value name="4">
<Value>FirstNameLocation</Value>
</Value>
<Value name="5">
<Value>LastNameLocation</Value>
</Value>
<Value name="6">
<Value>DateOfBirthLocation</Value>
</Value>
<Value name="7">
<Value>RecordUniqueIDLocation</Value>
</Value>
<Value name="8">
<Value>RecordSourceLocation</Value>
</Value>
<Value name="9">
<Value>TargetConfigNames</Value>
</Value>
<Value name="10">
<Value>SearchTableClass</Value>
</Value>
<Value name="11">
<Value>RecordSource</Value>
</Value>
<Value name="12">
<Value>EligibleMessageTarget</Value>
</Value>
<Value name="13">
<Value>DiscardedMessageTarget</Value>
</Value>
<Value name="14">
<Value>DeterministicCheckTarget</Value>
</Value>
<Value name="15">
<Value>ProbablisticCheckTarget</Value>
</Value>
<Value name="16">
<Value>MessageSource</Value>
</Value>
<Value name="17">
<Value>StreetLocation</Value>
</Value>
<Value name="18">
<Value>StateLocation</Value>
</Value>
<Value name="19">
<Value>ReportingTarget</Value>
</Value>
<Value name="20">
<Value>EncompassingEncounterDateLocation</Value>
</Value>
</Data>
<DefaultData>MemberEligibilityCheckProcessXMLDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

/// Revision number of this class
Parameter SrcVer = 39;

}
