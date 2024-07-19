Include HS.HC

/// <p><a href="https://readycomputing.com/"> <img src="https://readycomputing.com/images/header/headerLogo.png" alt="Ready Computing" >
/// </a></p>
/// Before processing clinical data make sure this is a member we want to consume
Class BCBSSC.Member.DetSafetyCheck Extends BCBSSC.Member.SafetyCheck [ ClassType = persistent ]
{

Method OnRequest(pRequest As HS.Message.PatientSearchRequest, Output pResponse As HS.Message.PatientSearchResponse) As %Status
{
	#dim tSC			As %Status=$$$OK
	#dim eException		As %Exception.AbstractException
	#dim i				As %Integer
	#dim tMemberId		As %String=""
	#dim tMemberIdAA	As %String=""
	#dim tSubscriber    As %String=""
	#dim tCarrier		As %String=""
	#dim tIdentifier	As  HS.Types.Identifier
	#dim tMPIID			As %String=""
	#dim tServiceObj	As HS.Registry.Service.HTTP
	#dim tOrg			As %String=""
	#dim tStatus		As %String=""
	#dim tDateOfService As %TimeStamp
	#dim tUniqueID		As %String=""
	#dim tCreatedBy  	As %String=""
	Set tAudit = ##class(BCBSSC.Member.Audit).%New()
	Try {
		Set tStart = $ZDT($H)
		Set pRequest.SearchMode="PIXPDQ"
		Set pResponse=##class(HS.Message.PatientSearchResponse).%New()
		Set pResponse.AdditionalInfo = pRequest.AdditionalInfo
		
		$$$THROWONERROR(tSC,..ValidateRequest(pRequest))
		
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
					if ($ZCVT(tIdentifier.AssigningAuthorityName,"l") = "healthy blue medicaid"){
						Set tMemberId=tMemberId_",ZCD"_tIdentifier.Extension
						Set tMemberIdAA=tMemberIdAA_","_tIdentifier.AssigningAuthorityName						
					}
				}
			}
		}Else{
			$$$ThrowStatus($$$ERROR($$$GeneralError,"Missing required field: MRN/AssigningAuthority or Identifiers"))					
		}
		
		#;1. Call Analytics to get a member or list of members with the received Card Identifier(s)
		Set tDateOfService=pRequest.AdditionalInfo.GetAt("DateOfService")
		Set tFoundMember = tMemberId
		$$$THROWONERROR(tSC,..GetMemberEnrollment(.pResponse,.tPatient,.tFoundMember,tMemberIdAA,tDateOfService))
		
		#;2. Using the demographics see if we can find a matching MPIID
		If (tMemberId'="") {
			#;Clear all possible identifiers
			Set tSC = pRequest.Identifiers.Clear()
			Set pRequest.MRN=""
			Set pRequest.AssigningAuthority=""
			Set pRequest.IgnoreSecondaryMPI=1
			Set pRequest.MinMatchPercentage=..MinMatchPercentage
			#; if we dont find an MPIID then set tMPIID=""
			$$$HSTRACE("Search Request","pRequest",pRequest)
			$$$THROWONERROR(tSC,..InvokeHubService("HS.Hub.HSWS.WebServices","HS.Hub.HSWS.WebServicesClient","SearchPatients",.tSC,pRequest,.tResponse))
			$$$HSTRACE("Search Response","tResponse",tResponse)
			Set tMember = tFoundMember
			Set tMPIID = ..ProcessSearchResponse(tResponse,tPatient,.tMember,.tSubscriber,.tStatus)
		}Else{
			$$$TRACE("No Member ID received")
		}

		Set tIsNewborn = 0
		Set pResponse=tResponse
		If tMember=""{
			$$$TRACE("Member Number not found with demographics")
		}elseIf (tMemberId [ ",") && (tMemberId '[ tMember){
			$$$TRACE("Member Number not in list")
			Set tMPIID=""
		}elseIf (tMemberId '[ ",") && (tMemberId'=tMember){
			$$$TRACE("Found different Member Number")
			Set tMPIID=""
		}
		If (tMPIID="") {
			//We did not find the patient registered, check if it is a newborn.
			//$$$ThrowStatus($$$ERROR($$$GeneralError, "Could not determine member. "_tStatus))
			$$$LOGWARNING("Member not found with demographics")
			#;Check if patient is a newborn before throwing an error
			If (($PIECE($HOROLOG,",") - pRequest.DOB) <= ..NewBornDateRange) {
				//Patient is a newborn with a matching member ID, assign "NEWBORN" AA
				Do pResponse.AdditionalInfo.SetAt("1","IsNewborn")
				Set tSubscriber=tFoundMember_" - newborn"
				Set tIsNewborn=1
			}
			If ('tIsNewborn) {
				$$$ThrowStatus($$$ERROR($$$GeneralError, "Could not determine member. "_tStatus))
			}
		}else{
			#; Check for matching MPIIDs between analytics and demographics
			If tPatient [ (tMPIID_",") {
				$$$TRACE("MPIID found in member enrollment search")
			}elseIf (tMPIID_",")[ tPatient{
				$$$TRACE("MPIID found in member enrollment search")
			}else{
				$$$ThrowStatus($$$ERROR($$$GeneralError, "Could not determine member. No match between analytics and demographics. "_tStatus))
			}
		}
		#;3 Demographic Match 
		If ('tIsNewborn){
			#Dim tRespPatMatch As HS.Message.PatientSearchMatch
			Set tRespPatMatch = pResponse.MPIIDList.GetAt(1)

			#; Match First Letter of First Name exactly
			If $EXTRACT(pRequest.FirstName) = $EXTRACT(tRespPatMatch.FirstName){
				$$$TRACE("Patient first name initial matches.")
				Set tFirstMatch = 1
			}else{
				$$$TRACE("Patient first name initial does not match")
				Set tFirstMatch = 0
			}
			#; Match First 5 Letters of Last Name exactly 
			If $EXTRACT(pRequest.LastName,1,5) = $EXTRACT(tRespPatMatch.LastName,1,5){
				$$$TRACE("Patient last name first five characters match.")
				Set tLastMatch = 1
			}else{
				$$$TRACE("Patient last name first five characters do not match.")
				Set tLastMatch = 0
			}
			#; Match DOB exactly		
			//Set tRespDOB = $ZDATE(tRespPatMatch.DOB,3)
			If pRequest.DOB = tRespPatMatch.DOB {
				$$$TRACE("Patient DOB matches")
				Set tDOBMatch = 1
			}else{
				$$$TRACE("Patient DOB does not match.")
				Set tDOBMatch = 0
			}
			
			#;Check if patient is a newborn before throwing an error
			Set tIsNewborn = 0
			If ($PIECE($HOROLOG,",") - tRespPatMatch.DOB <= 3) {
				//Patient is a newborn with a matching member ID, assign "NEWBORN" AA
				Do pResponse.AdditionalInfo.SetAt("1","IsNewborn")
				Set tIsNewborn=1
			}
			If ('tIsNewborn) && (tFirstMatch=0 || tLastMatch=0 || tDOBMatch=0){
				$$$ThrowStatus($$$ERROR($$$GeneralError,"Demographics mismatch."))
			}
		}
	}
	Catch eException {
		Set tSC=eException.AsStatus()
		Set tStatus=$SYSTEM.Status.GetErrorText(tSC)
		Set pResponse.ErrStatus=tStatus
		$$$LOGERROR(tStatus)
	}
	If tSubscriber'="" Do pResponse.AdditionalInfo.SetAt(tSubscriber,"SubscriberID")
	Set tSC2 = tAudit.Insert(tUniqueID,tCreatedBy,..%SessionId,tSC,tSC,"Deterministic")
	If 'tSC2 { $$$LOGERROR("Error auditing message"_$SYSTEM.Status.GetErrorText(tSC2))}
	Quit $$$OK
}

/// Test the behaviour of the class
ClassMethod Test(tMessage As %String = "") As %Status [ Internal ]
{
	#dim tSC 			As %Status=$$$OK
	#dim eException  	As %Exception.AbstractException
	Try {
        #;First we grab a previous request using the message body ID from the message viewer/visual trace
        Set tRequest=##class(HS.Message.PatientSearchRequest).%New()
        If tMessage '= ""{
            Set tRequest=##class(HS.Message.PatientSearchRequest).%OpenId(tMessage)
        }Else{
            Set tRequest.LastName="DUKES"
            Set tRequest.FirstName="RAYE"
            Set tRequest.MiddleName="M"
            Set tRequest.DOB="1936-10-04"
            Set tRequest.CreatedBy="FEP"
            Set tIdentifier = ##class(HS.Types.Identifier).%New()
            Set tIdentifier.Use="XX"
            Set tIdentifier.Extension="R57714470"
            Set tIdentifier.AssigningAuthorityName="FEP"
            Set tIdentifier.Status="A"
            Do tRequest.Identifiers.Insert(tIdentifier)
            Do tRequest.AdditionalInfo.SetAt("2024-01-05","DateOfService")
            Do tRequest.AdditionalInfo.SetAt("FEP-TEST","RecordUniqueID")
        }
        // Next we create an instance of the Process.  GetShadowInstance will return the live instance if the production is running otherwise a static but populated instance
        Set tProcess=##class(Ens.Host).GetShadowInstance("Member.SafetyCheck.Deterministic")
        Do tProcess.OnInit()

        //Since the business item is a process, the method to call is always OnRequest
        Set tSC = tProcess.OnRequest(tRequest,.tResponse)
  	}
	Catch eException {
		Set tSC=eException.AsStatus()
	}
	Quit tSC
}

/// Method used to test the functionality of the class, a Message id is needed, or a default message will be created
ClassMethod TestMemberExists(tMessage As %String = "") As %Status [ Internal ]
{
	#dim tSC 			As %Status=$$$OK
	#dim eException  	As %Exception.AbstractException
	Try {
        #;First we grab a previous request using the message body ID from the message viewer/visual trace
        Set tRequest=##class(HS.Message.PatientSearchRequest).%New()
        If tMessage '= ""{
            Set tRequest=##class(HS.Message.PatientSearchRequest).%OpenId(tMessage)
        }Else{
            Set tRequest.LastName="SELF"
            Set tRequest.FirstName="LOREL"
            Set tRequest.DOB="2007-03-13"
            Set tRequest.MRN="ZCS76560722"
            Set tRequest.AssigningAuthority="CES"
            Set tRequest.CreatedBy="RecordSource"
            Do tRequest.AdditionalInfo.SetAt("2023-11-18","DateOfService")
            Do tRequest.AdditionalInfo.SetAt("TEST-1","RecordUniqueID")
            /*
            Set tIdentifier = ##class(HS.Types.Identifier).%New()
            Set tIdentifier.Use="MRN"
            Set tIdentifier.Extension="K005804576-005"
            Set tIdentifier.AssigningAuthorityName="CES"
            Set tIdentifier.Status="A"
            Do tRequest.Identifiers.Insert(tIdentifier)
            */
        }
        // Next we create an instance of the Process.  GetShadowInstance will return the live instance if the production is running otherwise a static but populated instance
        Set tProcess=##class(Ens.Host).GetShadowInstance("Member.SafetyCheck.Deterministic")
        Do tProcess.OnInit()

        //Since the business item is a process, the method to call is always OnRequest
        Set tSC = tProcess.OnRequest(tRequest,.tResponse)
  	}
	Catch eException {
		Set tSC=eException.AsStatus()
	}
	Quit tSC
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

/// Revision number of this class
Parameter SrcVer = 11;

}
