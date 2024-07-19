Class BCBSSC.Router.HL7.MemberEligibilityCheckProcess Extends (Ens.BusinessProcess, EnsLib.HL7.Util.IOFraming)
{

/// Message Source
/// Typically set to the Facility ID
Property MessageSource As %String;

/// Subscriber number location in message. Format expected: IN1:36
Property SubscriberNumberLocation As %String [ InitialExpression = "IN1:36" ];

/// AssigningAuthority location in message. Format expected: IN1:2
Property AssigningAuthorityLocation As %String [ InitialExpression = "IN1:2.1" ];

/// Subscriber number location in message. Format expected: PV1:44
Property DateOfServiceLocation As %String [ InitialExpression = "PV1:44" ];

/// FirstName location in message. Format expected: PID:5.2
Property FirstNameLocation As %String [ InitialExpression = "PID:5.2" ];

/// LastName location in message. Format expected: PID:5.1
Property LastNameLocation As %String [ InitialExpression = "PID:5.1" ];

/// MiddleName location in message. Format expected: PID:5.3
Property MiddleNameLocation As %String [ InitialExpression = "PID:5.3" ];

/// Date of Birth location in message. Format expected: PID:7
Property DateOfBirthLocation As %String [ InitialExpression = "PID:7" ];

/// Street location in message. Format expected: PID:7
Property StreetLocation As %String [ InitialExpression = "PID:11.1" ];

/// State location in message. Format expected: PID:7
Property StateLocation As %String [ InitialExpression = "PID:11.4" ];

/// Record Unique ID location in message. Format expected: MSH:10
Property RecordUniqueIDLocation As %String [ InitialExpression = "MSH:10" ];

/// Record Source location in message. 
Property RecordSourceLocation As %String [ InitialExpression = "MSH:4" ];

/// Configuration item to send Deterministic checks
/// If both Deterministic and Probablistic Targets are set will send to Probablistic
/// only after Deterministic returns nothing
Property DeterministicCheckTarget As Ens.DataType.ConfigName;

/// Configuration item to send Probablistic checks
/// If both Deterministic and Probablistic Targets are set will send to Probablistic
/// only after Deterministic returns nothing
Property ProbablisticCheckTarget As Ens.DataType.ConfigName;

/// Newborn Rule - if checked, Newborns will be allowed to pass member check
/// A newborn is detected if the PatientSearchResponse contains "newborn" in the SubscriberId value
/// Additional handling will be added in order to append "-newborn" to the ID card. 
Property NewbornRule As %Boolean [ InitialExpression = 1 ];

/// Configuration item(s) to which to send file stream messages
Property EligibleMessageTarget As Ens.DataType.ConfigName;

/// Configuration item(s) to which to send file stream messages
Property DiscardedMessageTarget As Ens.DataType.ConfigName;

/// If populated, forward A03 messages to target
Property TMCSAuthTarget As Ens.DataType.ConfigName;

/// Configuration item to which to send reporting message
Property ReportingTarget As Ens.DataType.ConfigName;

/// Configuration item(s) to which to send file stream messages
/// Deprecated: No longer used
Property TargetConfigNames As %String(MAXLEN = 1000);

/// Store a set of searchable properties associated with each HL7 message processed. <br/>
/// These records will be stored in the named SearchTable class, if any.
Property SearchTableClass As %String(MAXLEN = 128) [ InitialExpression = "EnsLib.HL7.SearchTable" ];

/// For Testing:Override for different schema
Parameter HL7Schema = "2.5.1:ADT_A01";

Parameter NewLine = 10;

Parameter SETTINGS = "NewbornRule:Basic,MessageSource:Basic,SubscriberNumberLocation:Basic,AssigningAuthorityLocation:Basic,DateOfServiceLocation:Basic,FirstNameLocation:Basic,LastNameLocation:Basic,MiddleNameLocation:Basic,DateOfBirthLocation:Basic,StreetLocation:Basic,StateLocation:Basic,RecordUniqueIDLocation:Basic,RecordSourceLocation:Basic,DeterministicCheckTarget:Connection:selector?multiSelect=1&context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId},ProbablisticCheckTarget:Connection:selector?multiSelect=1&context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId},EligibleMessageTarget:Connection:selector?multiSelect=1&context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId},DiscardedMessageTarget:Connection:selector?multiSelect=1&context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId},ReportingTarget:Connection:selector?multiSelect=1&context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId},TMCSAuthTarget:Connection:selector?multiSelect=1&context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId}";

// CNR: Changing signature to Persistent for inheritance trickery -- this may be a crime against humanity

// Method OnRequest(pRequest As EnsLib.HL7.Message, Output pResponse As EnsLib.HL7.Message) As %Status

Method OnRequest(pRequest As %Persistent, Output pResponse As %Persistent) As %Status
{
        Set tSC = $$$OK  
        Try {

            //Code for pRequest as EnsLib.HL7.Message 
            Set tSeparators = "|^~\&"_$Char(13,10)
            Set inputStream = ##class(%Stream.GlobalCharacter).%New()
            do pRequest.OutputToLibraryStream(.inputStream, tSeparators) 


            do ..GetLocationValue(inputStream, "MSH:9.1",.eventType) 
            do ..GetLocationValue(inputStream, "MSH:9.2",.msgType)
           

            // Access the stream directly from StreamContainer
            //Set inputStream = pRequest.Stream
            //do inputStream.Rewind()

            // Use the adapted GetLocationValue method
            do ..GetLocationValue(inputStream, ..SubscriberNumberLocation, .subscriberNumber)
            do ..GetLocationValue(inputStream, ..AssigningAuthorityLocation, .assigningAuthority)
            do ..GetLocationValue(inputStream, ..DateOfServiceLocation, .dateOfService)
            do ..GetLocationValue(inputStream, ..FirstNameLocation, .firstName)
            do ..GetLocationValue(inputStream, ..LastNameLocation, .lastName)
            do ..GetLocationValue(inputStream, ..MiddleNameLocation, .middleName)
            do ..GetLocationValue(inputStream, ..DateOfBirthLocation, .dateOfBirth)
            do ..GetLocationValue(inputStream, ..RecordUniqueIDLocation, .recordUniqueID)
            do ..GetLocationValue(inputStream, ..RecordSourceLocation, .recordSource)
            do ..GetLocationValue(inputStream, ..StreetLocation, .streetValue)
            do ..GetLocationValue(inputStream, ..StateLocation, .stateValue)
            
            Set IDList = subscriberNumber
            Set AAList = assigningAuthority
            Set ResultList = ""
            
            For i=1:1:$L(IDList, ",") {
                Set IDValues = $PIECE(IDList, ",", i)
                Set AAValues = $PIECE(AAList, ",", i)
                Set ResultList = ResultList _ IDValues _ "," _ AAValues _ ","
            }
            Set ResultList = $Extract(ResultList, 1, $LENGTH(ResultList)-1)

            // BuildMemberEligibilityRequest is unchanged assuming it works with the provided properties
            do ..BuildMemberEligibilityRequest(subscriberNumber, assigningAuthority, firstName, lastName, middleName,dateOfBirth, dateOfService, recordUniqueID, ..MessageSource, streetValue,stateValue, .searchRequest, ResultList)
            
            //Even if required fields are missing, still sending through to check process as downstream
            //Reporting is based on results of member check 
            Set tSC = ..MemberEligibilityCheck(pRequest,searchRequest,eventType,msgType, .tResponse, .RouteEligibleMessage, .RouteBadMessage, .IsNewborn)

            if RouteEligibleMessage{ 
	            //Append Z-segment to all messages
                //CNR: This segment needs to be added onto the HL7 message that is sent to edges for notification
                Set SubscriberID = $PIECE(tResponse.AdditionalInfo.GetAt("SubscriberID"),"-",0,1)
                Set PatientID = $PIECE(tResponse.AdditionalInfo.GetAt("SubscriberID"),"-",2)
                Set ZSegment = "ZEX|TMCS|"_SubscriberID_"|"_PatientID
                Set newZSegment = ##class(EnsLib.HL7.Segment).ImportFromString(ZSegment)
                            
                //CNR: Cloning pRequest
                #dim tClonedRequest as EnsLib.HL7.Message
				set tClonedRequest=pRequest.%ConstructClone(1)
                set tSC =  tClonedRequest.AppendSegment(newZSegment)  
	            
	            //if Newborn, we append to the IDCard value
	            if IsNewborn=1 {
		             //if the message is a newborn, call update to append "-newborn" to IDcard value 
		             $$$ThrowOnError(..UpdateNewBornRequest(tClonedRequest, ..SubscriberNumberLocation,pSearchResponse.AdditionalInfo.GetAt("SubscriberID") , .tClonedRequest))
		        }
	              
	             
                ;Send the Patient message to Target
                For iTarget=1:1:$L(..EligibleMessageTarget, ",") { 
                    Set tOneTarget=$ZStrip($P(..EligibleMessageTarget,",",iTarget),"<>W")  Continue:""=tOneTarget
        			Set tSC1=..SendRequestAsync(tOneTarget,tClonedRequest, .pResponse)  Set:$$$ISERR(tSC1) tSC=$$$ADDSC(tSC,tSC1)
	            }
	            
	            //If conditions are met for TMCS Auth. Do not send TMCS Auth for Newborns currently
                if (..TMCSAuthTarget '= "") && (msgType = "A03") && (IsNewborn=0) {                        
                	Set tSC=..SendRequestAsync(..TMCSAuthTarget,clone, .pResponse)
                }
	                   
              }
              elseif RouteBadMessage
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

Method MemberEligibilityCheck(ByRef pRequest As %Library.Persistent, pSearchRequest As %Library.Persistent, pEventType As %String = "", pMsgType As %String = "", ByRef pSearchResponse As %Library.Persistent, Output RouteEligibleMessage As %Boolean, Output RouteBadMessage As %Boolean, Output IsNewborn As %Boolean) As %Status
{
            //Even if required fields are missing, still sending through to check process as downstream
            //Reporting is based on results of member check 
            Set tSC = $$$OK
            Set RouteBadMessage = 1
            Set RouteEligibleMessage = 0
            Set DeterministicCheckDone = 0
            Set ProbablisticCheckDone = 0
            Set IsNewborn = 0
            
            //Format Message Type
            if pMsgType '= "" {
	        	Set MessageType = pEventType_"_"_pMsgType    
	        }
	        else {
		        Set MessageType = pEventType
		    }
            
            //First check is deterministic or probablistic
            if pSearchRequest {
                if ..DeterministicCheckTarget '= "" {
    			    Set tSC=..SendRequestSync(..DeterministicCheckTarget,pSearchRequest, .pSearchResponse)
                	Set DeterministicCheckDone = 1
                }
                elseif ..ProbablisticCheckTarget '= "" {
                    Set tSC=..SendRequestSync(..ProbablisticCheckTarget,pSearchRequest, .pSearchResponse)
                    Set ProbablisticCheckDone = 1 
                }
                
                //Check pResponse and send message to next target if check returns positive result
                if '$ISOBJECT(pSearchResponse){
	                //Report on failure of member check
                }
                else {
	                //Report on the member check which can be det or prob, success or fail
	                
                    if ((pSearchResponse.ResultsCount > 0) && (pSearchResponse.AdditionalInfo.GetAt("SubscriberID") '= "" )){
                        //Route to Edge
                        Set RouteBadMessage = 0
                        Set RouteEligibleMessage = 1
                 		
                 		//Report 
                 		//$$$LOGINFO("Building Report: Pass")
 						set dataType = $SELECT(DeterministicCheckDone:"DET",1:"PROB")
 						if ..ReportingTarget'="" {
                 			do ..BuildMemberCheckResult(pSearchRequest,..MessageSource,"Pass",MessageType, dataType,,.tResult) 
                 			set tSC = ..SendRequestAsync(..ReportingTarget, tResult)
 						}  
                    }
                    elseif (..NewbornRule=1) && ($FIND(pSearchResponse.AdditionalInfo.GetAt("SubscriberID"),"newborn")>0) {
	                    //if the member check failed, but the Subscriber ID is tagged with "- newborn"
	                    //allow the record to pass and also append "- newborn" to the ID card
	                  	set IsNewborn = 1
		                Set RouteBadMessage = 0
		                Set RouteEligibleMessage = 1
		                set dataType = $SELECT(DeterministicCheckDone:"DET",1:"PROB")
 							
 						//report new born in status	
 						if ..ReportingTarget'="" {
                 			do ..BuildMemberCheckResult(pSearchRequest,..MessageSource,"Pass",MessageType,dataType,"Newborn rule",.tResult) 
                 			set tSC = ..SendRequestAsync(..ReportingTarget, tResult)
 						}
		                
	                }
                    elseif DeterministicCheckDone=1 && ..DeterministicCheckTarget '="" && ..ProbablisticCheckTarget '="" {
                        if ..ReportingTarget'="" {
                        	//Report fail on deterministic check
                        	do ..BuildMemberCheckResult(pSearchRequest,..MessageSource,"Fail",MessageType,"DET",,.tResult) 
                 			set tSC = ..SendRequestAsync(..ReportingTarget, tResult)
                        }
                        
                        //last chance - try with probablistic match as backup if both populated           
                        Set tSC=..SendRequestSync(..ProbablisticCheckTarget,pSearchRequest, .pSearchResponse)
            			
                        //Check pResponse and send message to next target if check returns positive result
                        if '$ISOBJECT(pSearchResponse){
                            Throw $$$ERROR("Invalid response received")
                        }
                        else {
	                       
                            if ((pSearchResponse.ResultsCount > 0) && (pSearchResponse.AdditionalInfo.GetAt("SubscriberID") '= "")){
                                Set RouteBadMessage = 0
                                Set RouteEligibleMessage = 1
                            }
                            elseif ..NewbornRule=1 {
	                    	//if the member check failed, but the Subscriber ID is tagged with "- newborn"
	                    	//allow the record to pass and also append "- newborn" to the ID card
	                    	if $FIND(pSearchResponse.AdditionalInfo.GetAt("SubscriberID"),"newborn")>0 {
		                    	set IsNewborn = 1
		                    	Set RouteBadMessage = 0
		                    	Set RouteEligibleMessage = 1						

		                 }
	                }
                        }
                        
                        if ..ReportingTarget'="" {
                        	//Report on the results of the secondary check which is always prob
                    		Set status = $SELECT(RouteEligibleMessage:"Pass",1: "Fail")
                    		set statusText = $SELECT(IsNewborn:"Newborn rule",1: "")
                        	do ..BuildMemberCheckResult(pSearchRequest,..MessageSource,status,MessageType,"PROB",statusText,.tResult) 
                 			set tSC = ..SendRequestAsync(..ReportingTarget, tResult)
                        }
                    }
                }
            }
            else {
                $$$LOGINFO("Member Eligibility request not built")
            }

        Quit tSC
}

/// pLocation can be set as format PID:3 for field Level, PID:3.1 for subfield. 
ClassMethod GetLocationValue2(pStream As %Stream.Object, pLocation As %String, ByRef pValue As %String)
{
    Set pValue = ""

    // Parse location
    Set SegmentId = $PIECE(pLocation, ":", 1)
    Set LocationIndex = $PIECE(pLocation, ":", 2)

    // Handle different numbering in MSH vs other segments
    If SegmentId '= "MSH" {
        Set LocationIndex = LocationIndex + 1
    }

    // Check for subfield specification
    Set SubfieldIndex = ""
    If $LENGTH(LocationIndex, ".") >= 2 {
        Set SubfieldIndex = $PIECE(LocationIndex, ".", 2)
    }

    While 'pStream.AtEnd {
        Set line = pStream.ReadLine()

        // Check if the segment matches
        If $EXTRACT(line, 1, 3) = SegmentId {
            // Parse the line based on the pipes
            Set FieldList = $LISTFROMSTRING(line, "|")

            // Get the field value
            Set FieldValue = $LISTGET(FieldList, LocationIndex, "")
            //$$$LOGINFO("SegmentId = "_SegmentId)
            //$$$LOGINFO("FieldValue :"_FieldValue)
            // Check for subfield specification
            If SubfieldIndex'="" {
                // Parse the field based on the carat delimiters
                Set SubfieldList = $LISTFROMSTRING(FieldValue, "^")
                Set pValue = $LISTGET(SubfieldList, SubfieldIndex, "")
            } Else {
                // No subfield specified, return the entire field
                Set pValue = FieldValue
            }
        }
    }

    // Rewind the stream
    Do pStream.Rewind()
}

ClassMethod GetLocationValue(pStream As %Stream.Object, pLocation As %String, ByRef pValue As %String)
{
    
    Set IN1List = ""
    Set pValue = ""

    // Parse location
    Set SegmentId = $PIECE(pLocation, ":", 1)
    Set LocationIndex = $PIECE(pLocation, ":", 2)

    // Handle different numbering in MSH vs other segments
    If SegmentId '= "MSH" {
        Set LocationIndex = LocationIndex + 1
    }

    // Check for subfield specification
    Set SubfieldIndex = ""
    If $LENGTH(LocationIndex, ".") >= 2 {
        Set SubfieldIndex = $PIECE(LocationIndex, ".", 2)
    }
	
    While 'pStream.AtEnd {
        Set line = pStream.ReadLine()

        // Check if the segment matches
        If ($EXTRACT(line, 1, 3) = SegmentId) {
                // Parse the line based on the pipes
                Set FieldList = $LISTFROMSTRING(line, "|")

                // Get the field value
                Set FieldValue = $LISTGET(FieldList, LocationIndex, "")
                //$$$LOGINFO("SegmentId = "_SegmentId)
                //$$$LOGINFO("FieldValue :"_FieldValue)
                // Check for subfield specification
                If SubfieldIndex'="" {
                    // Parse the field based on the carat delimiters
                    Set SubfieldList = $LISTFROMSTRING(FieldValue, "^")
                    Set pValue = $LISTGET(SubfieldList, SubfieldIndex, "")
                } 
                    If SegmentId = "IN1" {
                        	if FieldValue'="" {
                    		Set pValue = FieldValue
                    		}
                            If SubfieldIndex'="" {
                    // Parse the field based on the carat delimiters
                    Set SubfieldList = $LISTFROMSTRING(FieldValue, "^")
                    Set pValue = $LISTGET(SubfieldList, SubfieldIndex, "")
                }
                            If IN1List = "" {
                                set IN1List = $LISTBUILD(pValue)
                            } Else {
                                //Convert existing list to string
                                Set IN1ListString = $LISTTOSTRING(IN1List, ",")
                                If $Find(IN1ListString, pValue) = 0 {
                                //Append list
                                Set IN1ListString = IN1ListString _ "," _ pValue
                                Set pValue = IN1ListString
                                Set IN1List = $LISTFROMSTRING(IN1ListString, ",")
                                }
                            }
                    } ElseIf SubfieldIndex'="" {
                    // Parse the field based on the carat delimiters
                    Set SubfieldList = $LISTFROMSTRING(FieldValue, "^")
                    Set pValue = $LISTGET(SubfieldList, SubfieldIndex, "")
                } Else{
                    // No subfield specified, return the entire field
                    if (FieldValue'="")&&(SegmentId'="IN1") {
                    Set pValue = FieldValue
                    }
                }        
            }
        }
    // Rewind the stream
    Do pStream.Rewind()
}

// Optional pIdentifiers can be passed in with format: "ZCS76560722,BCBS FEDERAL,RC97891234,MEDICARE ADVANTAGE"

ClassMethod BuildMemberEligibilityRequest(pSubscriberNumber, pAssigningAuthority, pFirstName, pLastName, pMiddleName, pDateOfBirth, pDateOfService, pRecordUniqueID, pRecordSource, pStreet, pState, ByRef pResult As HS.Message.PatientSearchRequest, pIdentifiers As %String = "") As %Status
{
   
    Set pResult = ##class(HS.Message.PatientSearchRequest).%New()

    // Set single SubscriberNumber and AA
    if pIdentifiers = ""{
        set pResult.MRN = pSubscriberNumber 
        set pResult.AssigningAuthority = pAssigningAuthority
    }
    else {
        // Parse Identifiers and set the property
        Set identifiersArray = $LISTFROMSTRING(pIdentifiers, ",")
        Set identifiersList = ##class(%Library.ListOfObjects).%New("")
        For i = 1:2:$LISTLENGTH(identifiersArray) {
            Set identifierObj = ##class(HS.Types.Identifier).%New()
            //$$$LOGINFO($LIST(identifiersArray, i))
            Set identifierObj.Extension = $LIST(identifiersArray, i)
            //$$$LOGINFO($LIST(identifiersArray, i+1))
            Set identifierObj.AssigningAuthorityName = $LIST(identifiersArray, i+1)
            Do identifiersList.Insert(identifierObj)
        }
    Set pResult.Identifiers = identifiersList
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
    Do pResult.AdditionalInfo.SetAt(..FormatDate(pDateOfService), "DateOfService")
    Do pResult.AdditionalInfo.SetAt(pRecordUniqueID, "RecordUniqueID")
    Do pResult.AdditionalInfo.SetAt(pRecordSource, "RecordSource")

    Quit $$$OK
}

// Helper method builds a reporting message to be sent to member check reporting namespace

ClassMethod BuildMemberCheckResult(pRequest As HS.Message.PatientSearchRequest, pMessageSource As %String, pStatus As %String, pMessageType As %String, pCheckType As %String, pStatusText As %String = "", ByRef pResult As HS.Message.PatientSearchRequest) As %Status
{
	//clone the request   
    Set pResult = pRequest.%ConstructClone(1)
	
	//Blank out demographics - no tracking of PHI
    // Set standard properties
    Set pResult.FirstName = ""
    Set pResult.LastName = ""
    Set pResult.DOB = ""
    Set pResult.CreatedBy = ""
    Set pResult.Street = ""
    Set pResult.State = ""
	
	// Set custom properties in AdditionalInfo
    Do pResult.AdditionalInfo.SetAt(pStatus, "Status")
    Do pResult.AdditionalInfo.SetAt(pCheckType, "CheckType")
    Do pResult.AdditionalInfo.SetAt(pMessageType, "MessageType")
    Do pResult.AdditionalInfo.SetAt(pStatusText, "StatusText")
    Do pResult.AdditionalInfo.SetAt($ZDATETIME($HOROLOG), "RecordCreatedTimeStamp")
    Set sessionId = $get($$$JobSessionId)
    Do pResult.AdditionalInfo.SetAt(sessionId, "SessionID")
    Do pResult.AdditionalInfo.SetAt(pMessageSource, "MessageSource")

    Quit $$$OK
}

ClassMethod UpdateNewBornRequest(pRequest As EnsLib.HL7.Message, pSubscriberNumberLocation As %String, pSubscriberID As %String, Output tRequest As EnsLib.HL7.Message) As %Status
{
	set tSC = $$$OK
	
	try {
		
		//Clone HL7 message and update the SubscriberNumber Location
		set tRequest=pRequest.%ConstructClone(1)
		
		set segment = $PIECE(pSubscriberNumberLocation,":",1)
		set location = $PIECE(pSubscriberNumberLocation,":",2)
		//Get the list of segment indices - to handle multiple segments
		set tValues = tRequest.FindSegmentValues(pSubscriberNumberLocation,,"|",.tStatus,,.tIndices)
		if $$$ISOK(tStatus){ 
			//loop through indices
			Set indexList = $LISTFROMSTRING(tIndices,"|")
			FOR i=1:1:$LISTLENGTH(indexList) {
				set targetSegment = tRequest.GetSegmentAt($NUMBER($LISTGET(indexList,i),"I"))
   				set subscriberNumber = targetSegment.GetValueAt(location)
		
				//Check to see if the current subscriberNumber is contained in the pSubscriberNumber replacement value
				if $FIND(pSubscriberID, subscriberNumber) {
					$$$ThrowOnError(targetSegment.SetValueAt(pSubscriberID, location))
				}
			}
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
    set processName = "MUSC.Adt.MemberCheckHL7"

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
	Quit tSC
}

// Unit Test to test NewBorn update

// To run: HSCUSTOM> w ##class(BCBSSC.Router.HL7.MemberEligibilityCheckProcess).TestUpdateNewBornRequest()

ClassMethod TestUpdateNewBornRequest() As %Status [ Internal ]
{
	#dim tSC 			As %Status=$$$OK
	#dim eException  	As %Exception.AbstractException
    #dim tRequest as EnsLib.HL7.Message
    
    Set SubscriberNumberLocation = "IN1:36"
    Set SubscriberID = "CP0091792 - newborn"
	Try {
        #;First we load an HL7 message
	    set HL7Message=..GetMessage("SourceMessageA01")
	    if '$IsObject(HL7Message) {
             Throw $$$ERROR(5001,"Failed to correlate Xdata for Source Message")
        }
    	//w "Input HL7Message is: "_HL7Message.OutputToString()
    	#;Pass the HL7 message into the UpdateNewBornRequest call in order to get an updated copy
    	$$$ThrowOnError(##class(BCBSSC.Router.HL7.MemberEligibilityCheckProcess).UpdateNewBornRequest(HL7Message,SubscriberNumberLocation,SubscriberID,.tRequest))

		w "Output tRequest is: "_tRequest.OutputToString(),!
  	}
	Catch eException {
		Set tSC=eException.AsStatus()
	}
	Quit tSC
}

ClassMethod TestBuildMemberCheckResult() As %Status
{
   
   
   Set pRequest = ##class(HS.Message.PatientSearchRequest).%New()
   
   Quit $$$OK
}

/****Helper Methods ****/
ClassMethod GetMessage(XDataName As %String) As EnsLib.HL7.Message
{
	#dim SourceMessage as EnsLib.HL7.Message
	set xdata=##class(%Dictionary.CompiledXData).%OpenId(..%ClassName(1)_"||"_XDataName,0)
	quit:'$IsObject(xdata) $$$NULLOREF
	set lines=""
	while 'xdata.Data.AtEnd
	{
		set line=$ZSTRIP(xdata.Data.ReadLine(),"<w")
		continue:line=""
		continue:$Extract(line,1)="<" // ignore opening or closing XML tags and start CData tag
		continue:$Extract(line,1)="]" // ignore ]]> closing CDATA
		set lines=lines_($S($L(lines)=0:"",1:$C(..#NewLine)))_line
	}
	set SourceMessage=##class(EnsLib.HL7.Message).ImportFromString(lines,.tSC)
	quit:$$$ISERR(tSC) $$$NULLOREF
	set SourceMessage.DocType=..#HL7Schema
	set tSC=SourceMessage.PokeDocType(..#HL7Schema)
	quit SourceMessage
}

XData SourceMessageA01MemberExists
{
<test><![CDATA[
MSH|^~\&|Epic|MUSC||BCBSSC|20230911060119|RUBBLE|ADT^A01|249509431|P|2.2
EVN|A01|20230911060119||ADT_EVENT|RUBBLE^MATTHEW^BARNEY^D^^^^^MUSC^^^^^UH|20230911060000|PHL^PHL^ADTEDI
ZVN||LS23450^LS-23450^^^^RTL
PID|1|000163400^^^MRN^MRN|000163400^^^MRN^MRN||SELF^LOREL^||20070313|F||B|100 BEDROCK WAY^^NORTH CHARLESTON^SC^29420-8707^US^P^^CHARLESTON|CHAR|(555)609-0969^P^PH^^^555^6090969~^NET^Internet^ANNAC1@YAHOO.COM~(555)609-0969^P^CP^^^555^6090969||ENG|M|CHR|555443333|260-61-5801|||1|||||Non Veteran|||N
ZPD||MYCH||AC|||N||N
PD1|||MUSC HOLLINGS CANCER CENTER^^10003|1134107873^LINK^MICHAEL^J^^^^^EPIC^^^^PNPI
ROL|1|UP|GENERAL|1134107873^LINK^MICHAEL^J^^^^^EPIC^^^^PNPI|20211115
NK1|1|GABLE^BETTY|PARENT||(555)763-5651^^PH^^^555^7635651||Emergency Contact 1
NK1|2|FLINTSTONE^FRED|Spouse|100 Bedrock way^^REMBERT^SC^29128^US|(888)222-2222^^PH^^^888^2222222|(888)222-3333^^PH^^^888^2223333|Emergency Contact 2
PV1|1|O|R1OR^RTOR^07^RT^R^^^^MUSC RT OR|EL|||1386757342^HALSTEAD^LUCINDA^A.^^^^^EPIC^^^^PNPI|1386757342^HALSTEAD^LUCINDA^A.^^^^^EPIC^^^^PNPI||OTO||||PHYS|||1386757342^HALSTEAD^LUCINDA^A.^^^^^EPIC^^^^PNPI|SO|1197112023|BCBS|||||||||||||||||||||ADMCONF|||20231118060000
PV2||PRV||||||20230911||||HOSP ENC|||||||||N|N||||||||||N
ZPV||||||||||||20230911060000
OBX|1|NM|PRIMARYCSN|1|1197112023||||||F
AL1|1|DA|900525^FISH CONTAINING PRODUCTS^DAM|3|Anaphylaxis|20210823
AL1|2|DA|568^PEANUT^HIC|3|Anaphylaxis|20221209
AL1|3|DA|12753^TREE NUT^HIC|3|Anaphylaxis|20221209
AL1|4|DA|1193^TREE NUTS^DAM|3|Anaphylaxis|20130524
AL1|5|DA|1554^HYDROCODONE^HIC||Other|20210728
AL1|6|DA|3102^POLLEN EXTRACTS^HIC||Other|20201204
AL1|7|DA|11754^SHELLFISH DERIVED^HIC||Other|20210728
DG1|1|I10|Q85.02^Neurofibromatosis, type 2^I10|Neurofibromatosis, type 2||ADMISSION DIAGNOSIS (CODED)
DG1|2|I10|D33.3^Benign neoplasm of cranial nerves^I10|Benign neoplasm of cranial nerves||ADMISSION DIAGNOSIS (CODED)
DG1|3|I10|J38.01^Paralysis of vocal cords and larynx, unilateral^I10|Paralysis of vocal cords and larynx, unilateral||ADMISSION DIAGNOSIS (CODED)
DG1|4||^NF2 (neurofibromatosis 2) [Q85.02]|NF2 (neurofibromatosis 2) [Q85.02]||ADMISSION DIAGNOSIS (TEXT)
DG1|5||^Acoustic neuroma [D33.3]|Acoustic neuroma [D33.3]||ADMISSION DIAGNOSIS (TEXT)
DG1|6||^Unilateral complete paralysis of vocal cord [J38.01]|Unilateral complete paralysis of vocal cord [J38.01]||ADMISSION DIAGNOSIS (TEXT)
GT1|1|780223|FLINTSTONE^ANNA^WILMA^^^^L||100 BEDROCK WAY^^NORTH CHARLESTON^SC^29420-8707^US^^^CHARLESTON|(555)609-0969^P^PH^^^555^6090969~(555)763-5651^P^CP^^^555^7635651||19690812|F|P/F|SL|248-61-5801|||||^^^^^US|||Full
ZG1||||1
IN1|1|BL90^CES^PLANID||BCBS STATE|ATTN CLAIMS PROCESSING^PO BOX 100605^COLUMBIA^SC^29260-0605||(800)444-4311^^^^^800^4444311|002038404||||20140101||NPR||FLINTSTONE^THOMAS^^V|Sp|19661227|3310 DUBIN RD^^NORTH CHARLESTON^SC^29420^US|||1|||||||||||||1087807|ZCS76560722|||||||M|^^^^^US|||BOTH
IN3|1|||2||20230911|20230911|RUBBLE^MATTHEW^BARNEY^D|||NOT|||||(800)999-0000^^^^^800^9990000~(888)444-5555^^^^^888^4445555
ZIN|||||||FLINTSTONE^THOMAS^^V|||||16871492
]]></test>
}

XData SourceMessageA01
{
<test><![CDATA[
MSH|^~\&|Epic|MUSC||BCBSSC|20230911060119|RUBBLE|ADT^A01|249509431|P|2.2
EVN|A01|20230911060119||ADT_EVENT|RUBBLE^MATTHEW^BARNEY^D^^^^^MUSC^^^^^UH|20230911060000|PHL^PHL^ADTEDI
ZVN||LS23450^LS-23450^^^^RTL
PID|1|000163387^^^MRN^MRN|000163387^^^MRN^MRN||MEDINA^CECILIA^||20111102|F||B|100 BEDROCK WAY^^NORTH CHARLESTON^SC^29420-8707^US^P^^CHARLESTON|CHAR|(555)609-0969^P^PH^^^555^6090969~^NET^Internet^ANNAC1@YAHOO.COM~(555)609-0969^P^CP^^^555^6090969||ENG|M|CHR|555443333|260-61-5801|||1|||||Non Veteran|||N
ZPD||MYCH||AC|||N||N
PD1|||MUSC HOLLINGS CANCER CENTER^^10003|1134107873^LINK^MICHAEL^J^^^^^EPIC^^^^PNPI
ROL|1|UP|GENERAL|1134107873^LINK^MICHAEL^J^^^^^EPIC^^^^PNPI|20211115
NK1|1|GABLE^BETTY|PARENT||(555)763-5651^^PH^^^555^7635651||Emergency Contact 1
NK1|2|FLINTSTONE^FRED|Spouse|100 Bedrock way^^REMBERT^SC^29128^US|(888)222-2222^^PH^^^888^2222222|(888)222-3333^^PH^^^888^2223333|Emergency Contact 2
PV1|1|O|R1OR^RTOR^07^RT^R^^^^MUSC RT OR|EL|||1386757342^HALSTEAD^LUCINDA^A.^^^^^EPIC^^^^PNPI|1386757342^HALSTEAD^LUCINDA^A.^^^^^EPIC^^^^PNPI||OTO||||PHYS|||1386757342^HALSTEAD^LUCINDA^A.^^^^^EPIC^^^^PNPI|SO|1197112023|BCBS|||||||||||||||||||||ADMCONF|||20230911060000
PV2||PRV||||||20230911||||HOSP ENC|||||||||N|N||||||||||N
ZPV||||||||||||20230911060000
OBX|1|NM|PRIMARYCSN|1|1197112023||||||F
AL1|1|DA|900525^FISH CONTAINING PRODUCTS^DAM|3|Anaphylaxis|20210823
AL1|2|DA|568^PEANUT^HIC|3|Anaphylaxis|20221209
AL1|3|DA|12753^TREE NUT^HIC|3|Anaphylaxis|20221209
AL1|4|DA|1193^TREE NUTS^DAM|3|Anaphylaxis|20130524
AL1|5|DA|1554^HYDROCODONE^HIC||Other|20210728
AL1|6|DA|3102^POLLEN EXTRACTS^HIC||Other|20201204
AL1|7|DA|11754^SHELLFISH DERIVED^HIC||Other|20210728
DG1|1|I10|Q85.02^Neurofibromatosis, type 2^I10|Neurofibromatosis, type 2||ADMISSION DIAGNOSIS (CODED)
DG1|2|I10|D33.3^Benign neoplasm of cranial nerves^I10|Benign neoplasm of cranial nerves||ADMISSION DIAGNOSIS (CODED)
DG1|3|I10|J38.01^Paralysis of vocal cords and larynx, unilateral^I10|Paralysis of vocal cords and larynx, unilateral||ADMISSION DIAGNOSIS (CODED)
DG1|4||^NF2 (neurofibromatosis 2) [Q85.02]|NF2 (neurofibromatosis 2) [Q85.02]||ADMISSION DIAGNOSIS (TEXT)
DG1|5||^Acoustic neuroma [D33.3]|Acoustic neuroma [D33.3]||ADMISSION DIAGNOSIS (TEXT)
DG1|6||^Unilateral complete paralysis of vocal cord [J38.01]|Unilateral complete paralysis of vocal cord [J38.01]||ADMISSION DIAGNOSIS (TEXT)
GT1|1|780223|FLINTSTONE^ANNA^WILMA^^^^L||100 BEDROCK WAY^^NORTH CHARLESTON^SC^29420-8707^US^^^CHARLESTON|(555)609-0969^P^PH^^^555^6090969~(555)763-5651^P^CP^^^555^7635651||19690812|F|P/F|SL|248-61-5801|||||^^^^^US|||Full
ZG1||||1
IN1|1|BL90^BCBS STANDARD^PLANID||BCBS STATE|ATTN CLAIMS PROCESSING^PO BOX 100605^COLUMBIA^SC^29260-0605||(800)444-4311^^^^^800^4444311|002038404||||20140101||NPR||FLINTSTONE^THOMAS^^V|Sp|19661227|3310 DUBIN RD^^NORTH CHARLESTON^SC^29420^US|||1|||||||||||||1087807|INS0001|||||||M|^^^^^US|||BOTH
IN1|2|BL90^MA-MEMBER^PLANID||BCBS STATE|ATTN CLAIMS PROCESSING^PO BOX 100605^COLUMBIA^SC^29260-0605||(800)444-4311^^^^^800^4444311|002038404||||20140101||NPR||FLINTSTONE^THOMAS^^V|Sp|19661227|3310 DUBIN RD^^NORTH CHARLESTON^SC^29420^US|||1|||||||||||||1087807|CP0091792|||||||M|^^^^^US|||BOTH
IN3|1|||2||20230911|20230911|RUBBLE^MATTHEW^BARNEY^D|||NOT|||||(800)999-0000^^^^^800^9990000~(888)444-5555^^^^^888^4445555
ZIN|||||||FLINTSTONE^THOMAS^^V|||||16871492
]]></test>
}

/// Revision number of this class
Parameter SrcVer = 177;

Storage Default
{
<Data name="MemberEligibilityCheckProcessDefaultData">
<Subscript>"MemberEligibilityCheckProcess"</Subscript>
<Value name="1">
<Value>Framing</Value>
</Value>
<Value name="2">
<Value>AssigningAuthorityLocation</Value>
</Value>
<Value name="3">
<Value>DateOfServiceLocation</Value>
</Value>
<Value name="4">
<Value>%outFraming</Value>
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
<Value>DeterministicCheckTarget</Value>
</Value>
<Value name="10">
<Value>ProbablisticCheckTarget</Value>
</Value>
<Value name="11">
<Value>EligibleMessageTarget</Value>
</Value>
<Value name="12">
<Value>DiscardedMessageTarget</Value>
</Value>
<Value name="13">
<Value>TMCSAuthTarget</Value>
</Value>
<Value name="14">
<Value>TargetConfigNames</Value>
</Value>
<Value name="15">
<Value>SearchTableClass</Value>
</Value>
<Value name="16">
<Value>DefCharEncoding</Value>
</Value>
<Value name="17">
<Value>FirstNameLocation</Value>
</Value>
<Value name="18">
<Value>SubscriberNumberLocation</Value>
</Value>
<Value name="19">
<Value>StreetLocation</Value>
</Value>
<Value name="20">
<Value>StateLocation</Value>
</Value>
<Value name="21">
<Value>ReportingTarget</Value>
</Value>
<Value name="22">
<Value>MessageSource</Value>
</Value>
<Value name="23">
<Value>MiddleNameLocation</Value>
</Value>
<Value name="24">
<Value>NewbornRule</Value>
</Value>
</Data>
<DefaultData>MemberEligibilityCheckProcessDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
