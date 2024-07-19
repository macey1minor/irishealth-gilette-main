Include HS.HC

/// <p><a href="https://readycomputing.com/"> <img src="https://readycomputing.com/images/header/headerLogo.png" alt="Ready Computing" >
/// </a></p>
/// Before processing clinical data make sure this is a member we want to consume
Class BCBSSC.Member.ProbSafetyCheck Extends BCBSSC.Member.SafetyCheck [ ClassType = persistent ]
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
					Set pRequest.MRN=tMemberId
					Set pRequest.AssigningAuthority=tMemberIdAA
				}else{
					//Multiple identifiers
					Set tMultipleID=1
					Set tMemberId=tMemberId_","_tIdentifier.Extension
					Set tMemberIdAA=tMemberIdAA_","_tIdentifier.AssigningAuthorityName
					//$$$ThrowStatus($$$ERROR($$$GeneralError,"Multiple identifiers sent, expected only 1."))
				}
			}
		}Else{
			$$$ThrowStatus($$$ERROR($$$GeneralError,"Missing required field: MRN/AssigningAuthority or Identifiers"))					
		}
				
		#;1. Using the MRN/AA see if we can find a MPIID
		Set pRequest.IgnoreSecondaryMPI=1
		Set pRequest.MinMatchPercentage=..MinMatchPercentage
		#; if we dont find an MPIID then set tMPIID=""
		$$$HSTRACE("Search Request","pRequest",pRequest)
		$$$THROWONERROR(tSC,..InvokeHubService("HS.Hub.HSWS.WebServices","HS.Hub.HSWS.WebServicesClient","SearchPatients",.tSC,pRequest,.tResponse))
		$$$HSTRACE("Search Response","tResponse",tResponse)
		Set tMember=""
		Set tMPIID = ..ProcessSearchResponse(tResponse,"",.tMember,.tSubscriber,.tStatus)

		#;2. Using demographics see if we can find a matching MPIID
		If (tMPIID="") {
			#;Clear all possible identifiers
			Set tSC = pRequest.Identifiers.Clear()
			Set pRequest.MRN=""
			Set pRequest.AssigningAuthority=""
			#; if we dont find an MPIID then set tMPIID=""
			$$$HSTRACE("Search Request","pRequest",pRequest)
			Set tSC = ..InvokeHubService("HS.Hub.HSWS.WebServices","HS.Hub.HSWS.WebServicesClient","SearchPatients",.tSC,pRequest,.tResponse)
			$$$HSTRACE("Search Response","tResponse",tResponse)
			Set tMPIID = ..ProcessSearchResponse(tResponse,"",.tMember,.tSubscriber,.tStatus)
		}Else{
			$$$TRACE("Found MPIID by MRN/AA")
		}
		If tMPIID="" $$$ThrowStatus($$$ERROR($$$GeneralError, "Could not determine member. "_tStatus))

		#;1. Call Analytics to get a member or list of members with the found MPIID(s)
		Set tDateOfService=pRequest.AdditionalInfo.GetAt("DateOfService")
		$$$THROWONERROR(tSC,..GetMemberEnrollment(.tResponse,.tMemberMPIID,tMPIID,tMemberIdAA,tDateOfService,"/memberEnrollment/byMPIID/"))

		Set pResponse=tResponse
		If tMemberMPIID=""{
			$$$TRACE("Member Number not found")
		}elseIf ((tMemberMPIID [ ",")&&(tMPIID '[ ",")) && (tMemberMPIID '[ tMPIID){
			$$$TRACE("Member Number not in list")
			Set tMPIID=""
		}elseIf ((tMemberMPIID '[ ",")&&(tMPIID [ ",")) && (tMPIID '[ tMemberMPIID){
			$$$TRACE("Found different Member Number")
			Set tMPIID=""
		}elseIf ((tMemberMPIID '[ ",")&&(tMPIID '[ ",")) && (tMemberMPIID'=tMPIID){
			$$$TRACE("Found different Member Number")
			Set tMPIID=""
		}
		
		#; Check for matching MPIIDs between analytics and demographics
		If tMemberMPIID [ (tMPIID_",") {
			$$$TRACE("MPIID found in member enrollment search")
		}else{
			$$$ThrowStatus($$$ERROR($$$GeneralError, "Could not determine member. "_tStatus))
		}
		
		#;3 Demographic Match 
		#Dim tRespPatMatch As HS.Message.PatientSearchMatch
		Set tRespPatMatch = pResponse.MPIIDList.GetAt(1)
		Set tFirstMatch=0,tLastMatch=0,tDOBMatch=0
		
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
		If pRequest.DOB = tRespPatMatch.DOB {
			$$$TRACE("Patient DOB matches")
			Set tDOBMatch = 1
		}else{
			$$$TRACE("Request Patient DOB "  _ pRequest.DOB _ " does not match " _ tRespPatMatch.DOB)
			Set tDOBMatch = 0
		}
		
		#;Check if patient is a newborn before throwing an error
		Set tIsNewborn = 0
		If ($PIECE($HOROLOG,",") - tRespPatMatch.DOB <= ..NewBornDateRange) {
			//Patient is a newborn with a matching member ID, assign "NEWBORN" AA
			Do pResponse.AdditionalInfo.SetAt("1","IsNewborn")
			Set tIsNewborn=1
		}
		If ('tIsNewborn) && (tFirstMatch=0 || tLastMatch=0 || tDOBMatch=0){
			$$$ThrowStatus($$$ERROR($$$GeneralError,"Demographics mismatch."))
		}
	}
	Catch eException {
		Set tSC=eException.AsStatus()
		Set tStatus=$SYSTEM.Status.GetErrorText(tSC)
		$$$LOGERROR(tStatus)
		Set tSubscriber=""
	}
	If tSubscriber'="" Do pResponse.AdditionalInfo.SetAt(tSubscriber,"SubscriberID")
	Set tSC2 = tAudit.Insert(tUniqueID,tCreatedBy,..%SessionId,tSC,tSC,"Probabilistic")
	If 'tSC2 { $$$LOGERROR("Error auditing message"_$SYSTEM.Status.GetErrorText(tSC2))}
	Quit $$$OK
}

/// Validate required fields
Method ValidateRequest(pRequest As HS.Message.PatientSearchRequest) As %Status
{
	$$$THROWONERROR(tSC,##super(pRequest))
	If (pRequest.Addresses.Count()=0){
		If (pRequest.Street=""){
			$$$ThrowStatus($$$ERROR($$$GeneralError,"Missing required field: Street"))
		}					
	}
	Quit tSC
}

/// Test the functionality of the class
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
            Set tRequest.MRN="R57714470"
            Set tRequest.AssigningAuthority="IDCARD"
            Set tRequest.Street="HERON BAY LOOP"
            Set tRequest.State="SC"
            Do tRequest.AdditionalInfo.SetAt("2024-01-05","DateOfService")
            Do tRequest.AdditionalInfo.SetAt("FEP-TEST-Prob","RecordUniqueID")
        }
        // Next we create an instance of the Process.  GetShadowInstance will return the live instance if the production is running otherwise a static but populated instance
        Set tProcess=##class(Ens.Host).GetShadowInstance("Member.SafetyCheck.Probabilistic")
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
Parameter SrcVer = 8;

}
