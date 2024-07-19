Class BCBSSC.Router.TMCS.TMCSDischargeProcess Extends Ens.BusinessProcess
{

/// CNR: Need to add a property that will look for the Subscriber ID
/// It should be added in the ZEX|TMCS| segment. So the location would be ZEX:2
/// PatientId number location in message. Format expected: IN1:36
Property PatientIdLocation As %String [ InitialExpression = "ZEX:3" ];

/// AuthorizationNumber location in message. Format expected: IN1:2
Property AuthorizationNumberLocation As %String [ InitialExpression = "IN1:14.1" ];

/// DateOfDischarge number location in message. Format expected: PV1:44
Property DateOfDischargeLocation As %String [ InitialExpression = "PV1:45" ];

/// DateOfAdmition location in message. Format expected: PID:5.2
Property DateOfAdmitionLocation As %String [ InitialExpression = "PV1:44" ];

/// DischargeStatus location in message. Format expected: PID:5.1
Property DischargeStatusLocation As %String [ InitialExpression = "PV1:36" ];

/// Date of Source  location in message. Format expected: MSH:4
Property SourceLocation As %String [ InitialExpression = "MSH:4" ];

/// Subscriber Id location in message. Format expected: ZEX:2
Property SubscriberId As %String [ InitialExpression = "ZEX:2" ];

/// Date of Source  location in message. Format expected: PID:7
Property TargetConfigNames As %String;

Parameter SETTINGS = "SubscriberId:Basic,PatientIdLocation:Basic,AuthorizationNumberLocation:Basic,DateOfDischargeLocation:Basic,DateOfAdmitionLocation:Basic,DischargeStatusLocation:Basic,SourceLocation:Basic,TargetConfigNames:Basic";

Method OnRequest(pRequest As EnsLib.HL7.Message, Output pResponse As EnsLib.HL7.Message) As %Status
{
        Set tSC = $$$OK  
        Try {
            //Code for pRequest as EnsLib.HL7.Message 
            Set tSeparators = "|^~\&"_$Char(13,10)
            Set inputStream = ##class(%Stream.GlobalCharacter).%New()
            do pRequest.OutputToLibraryStream(.inputStream, tSeparators) 


            // do ..GetLocationValue(inputStream, "MSH:9.1",.eventType) 

            // Use the adapted GetLocationValue method
            // Suggestion: Create copy of GetLocationValue to call special for Subscriber number and AA
            do ..GetLocationValue(inputStream, ..SubscriberId, .subscriberId)
            do ..GetLocationValue(inputStream, ..PatientIdLocation, .patientId)
            do ..GetLocationValue(inputStream, ..AuthorizationNumberLocation, .authorizationNumber)
            do ..GetLocationValue(inputStream, ..DateOfDischargeLocation, .dateOfDischarge)
            do ..GetLocationValue(inputStream, ..DateOfAdmitionLocation, .dateOfAdmition)
            do ..GetLocationValue(inputStream, ..DischargeStatusLocation, .dischargeStatus)
            do ..GetLocationValue(inputStream, ..SourceLocation, .source)

            if authorizationNumber'=""{
 	           	//This class needs to be imported into this namespace before this will run
   		       	Set pResult = ##class(BCBSSC.EG.TMCS.REST.Model.Discharge).%New()
	           	set pResult.subscriberId = subscriberId 
    	       	set pResult.patientId = patientId 
            	set pResult.authorizationNumber = authorizationNumber 
            	set pResult.admitDate = ..DateFormat(dateOfAdmition) 
            	set pResult.dischargeDate = ..DateFormat(dateOfDischarge) 
            	set pResult.dischargeStatus = dischargeStatus 
            	set pResult.source = source 

	            set tSC = ..SendRequestAsync(..TargetConfigNames, pResult, .pResponse)
            }	
            else {
				//$$$HSTRACE("No Authorization Number found in: "_..AuthorizationNumberLocation)
                //NH This should really be a trace, but for now sticking with error
                $$$LOGERROR("No Authorization Number found in: "_..AuthorizationNumberLocation)
		    }		
        }
        Catch ex {
            // Handle any exceptions here
            Set tSC = ex.AsStatus()
		    $$$LOGERROR(tSC)
        }
        
        Quit tSC
}

// Helper method to format date: YYYYMMDDHHMMSS to YYYY-MM-DD

ClassMethod DateFormat(pInput As %String) As %String
{
	Set retVal = pInput
	
	if $LENGTH(pInput) >= 8 {
		set retVal = $EXTRACT(pInput, 1,4)_"-"_$EXTRACT(pInput, 5, 6)_"-"_$EXTRACT(pInput, 7,8)	
	}
	quit retVal
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

    //Looking at one segment at a time:
    //IN1|1|BCCBS Group||||||
    //ZIN|
    //IN1
    //ZIN
    //Suggestion: Build a Comma separated string for IN1:36 and IN1:2

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
                    } Else {
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

Storage Default
{
<Data name="TMCSDischargeProcessDefaultData">
<Subscript>"TMCSDischargeProcess"</Subscript>
<Value name="1">
<Value>PatientIdLocation</Value>
</Value>
<Value name="2">
<Value>AuthorizationNumberLocation</Value>
</Value>
<Value name="3">
<Value>DateOfDischargeLocation</Value>
</Value>
<Value name="4">
<Value>DateOfAdmitionLocation</Value>
</Value>
<Value name="5">
<Value>DischargeStatusLocation</Value>
</Value>
<Value name="6">
<Value>SourceLocation</Value>
</Value>
<Value name="7">
<Value>TargetConfigNames</Value>
</Value>
<Value name="8">
<Value>SubscriberId</Value>
</Value>
</Data>
<DefaultData>TMCSDischargeProcessDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

/// Revision number of this class
Parameter SrcVer = 21;

}
