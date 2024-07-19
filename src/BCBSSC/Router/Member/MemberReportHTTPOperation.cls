Class BCBSSC.Router.Member.MemberReportHTTPOperation Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.HTTP.OutboundAdapter";

Method OnMessage(pRequest As HS.Message.PatientSearchRequest, Output pResponse As %Library.Persistent) As %Status
{
    Try {
        Set tSC = $$$OK
     
        
        //Convert the Patient Search Request to the JSON message: BCBSSC.MemberReport.MemberCheckResult
        Set tRequest = ##class(%DynamicObject).%New()  
        set tRequest.MessageID = pRequest.AdditionalInfo.GetAt("RecordUniqueID")
        
    	// Parse %ListOfObjects into concatenated String
		Set identifiersList = ""
		For i = 1:1:pRequest.Identifiers.Count() {
    		Set object = pRequest.Identifiers.GetAt(i)

    		// Assuming you want to concatenate Extension and AssigningAuthorityName as a string in the %DynamicArray
    		Set identifiersList = identifiersList_object.Extension _ "^" _ object.AssigningAuthorityName _"|"
		}
		set tRequest.Identifiers = identifiersList

        set tRequest.MessageSource = pRequest.AdditionalInfo.GetAt("RecordSource")
        set tRequest.DateOfService = pRequest.AdditionalInfo.GetAt("DateOfService")
        set tRequest.RecordCreatedTimeStamp = pRequest.AdditionalInfo.GetAt("RecordCreatedTimeStamp")
        

        set tRequest.SessionID = pRequest.AdditionalInfo.GetAt("SessionID")
        set tRequest.Status = pRequest.AdditionalInfo.GetAt("Status") 
        set tRequest.StatusText = pRequest.AdditionalInfo.GetAt("StatusText") 
        set tRequest.MessageType = pRequest.AdditionalInfo.GetAt("MessageType")
   		set tRequest.CheckType = pRequest.AdditionalInfo.GetAt("CheckType")

	/*
        //How do we handle JSON lists? 
        //set tRequest.Identifiers = pRequest.admitDate 
        //Try: Create a string for each list object and then convert FromJSON
        
        
        
        /*From member check
        
        Set tMultipleID = 0
		If (pRequest.MRN '= ""){
			$$$TRACE("Got an MRN: "_pRequest.MRN)
			Set tMemberId=pRequest.MRN
			Set tMemberIdAA=pRequest.AssigningAuthority
		}
		ElseIf (pRequest.Identifiers.Count()>0){
			For i=1:1:pRequest.Identifiers.Count(){
				Set tIdentifier=pRequest.Identifiers.GetAt(i)
				If i=1{
					Set tMemberId=tIdentifier.Extension
					Set tMemberIdAA=tIdentifier.AssigningAuthorityName
				}else{
					//Multiple identifiers
					Set tMultipleID=1
					Set tMemberId=tMemberId_","_tIdentifier.Extension
					Set tMemberIdAA=tMemberIdAA_","_tIdentifier.AssigningAuthorityName
				}
			}
		}Else{
			$$$ThrowStatus($$$ERROR($$$GeneralError,"Missing required field: MRN/AssigningAuthority or Identifiers"))					
		}
        */
        		
		//Figure out system timestamp last
		//set tRequest.RecordCreatedTimeStamp 

        set tPayload = tRequest.%ToJSON()

		$$$LOGINFO("Send message to "_..Adapter.URL)
        Set tSC = ..SendMessage(..Adapter.URL, .tHTTPResponse, tPayload)
        
        //NH Error handling for Http. Don't delete when cleaning comments
        if tHTTPResponse.StatusCode '= 200 {
	        $$$LOGINFO("Error code: "_tHTTPResponse.StatusCode)
	        $$$LOGINFO("Reason: "_tHTTPResponse.ReasonPhrase)
	        $$$LOGINFO("DATA: "_tHTTPResponse.Data.Read())
	        }
        
    } Catch ex {
        // Handle any exceptions here
        Set tSC = ex.AsStatus()
        $$$LOGERROR(tSC)
    }
    quit tSC
}

/// Send a POST to the configured Server, Port and URL, sending form data to the named form variables.
Method SendMessage(pURL As %String, Output pResponse As %Net.HttpResponse, pData) As %Status
{
     Try {
          Set tSC = $$$OK
          Set tSC = ..Adapter.PostURL(pURL, .pResponse, , pData)
        
     } Catch ex {
        // Handle any exceptions here
        Set tSC = ex.AsStatus()
        $$$LOGERROR(tSC)
    }
     quit tSC
}

/// Revision number of this class
Parameter SrcVer = 39;

}
