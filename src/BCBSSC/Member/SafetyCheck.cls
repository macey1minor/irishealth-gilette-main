Include HS.HC

/// <p><a href="https://readycomputing.com/"> <img src="https://readycomputing.com/images/header/headerLogo.png" alt="Ready Computing" >
/// </a></p>
/// Before processing clinical data make sure this is a member we want to consume
Class BCBSSC.Member.SafetyCheck Extends (Ens.BusinessProcess, HS.HC.Util.Trace.Helper) [ ClassType = persistent ]
{

Property HSANALYTICSService As %String [ InitialExpression = "HSANALYTICS REST Services" ];

Property HSANALYTICSRetries As %String [ InitialExpression = "5" ];

Property MemberResponse As %String [ InitialExpression = "BCBSSC.Member.SafetyResponse" ];

Property DemographicSearch As %Boolean [ InitialExpression = 1 ];

Property MinMatchPercentage As %String [ InitialExpression = "20" ];

/// How many days back from today are they considered newborn, default is 60 days
Property NewBornDateRange As %String [ InitialExpression = "60" ];

Parameter SETTINGS = "HSANALYTICSService,HSANALYTICSRetries,MemberResponse,MinMatchPercentage,NewBornDateRange";

Method OnRequest(pRequest As HS.Message.PatientSearchRequest, Output pResponse As HS.Message.PatientSearchResponse) As %Status
{
	//Implement this on your class
	Quit $$$OK
}

Method ValidateRequest(pRequest As HS.Message.PatientSearchRequest) As %Status
{
	If (pRequest.%ClassName(1)'="HS.Message.PatientSearchRequest"){
		$$$ThrowStatus($$$ERROR($$$GeneralError,"Invalid Request sent, expected HS.Message.PatientSearchRequest. Got "_pRequest.%ClassName(1)))
	}
	If (pRequest.FirstName=""){
		$$$ThrowStatus($$$ERROR($$$GeneralError,"Missing required field: FirstName"))					
	}elseIf $L(pRequest.FirstName)>60{
		$$$ThrowStatus($$$ERROR($$$GeneralError,"Invalid Length: FirstName, Max 60"))					
	}
	//Validate LastName
	If (pRequest.LastName=""){
		$$$ThrowStatus($$$ERROR($$$GeneralError,"Missing required field: LastName"))					
	}elseIf $L(pRequest.FirstName)>60{
		$$$ThrowStatus($$$ERROR($$$GeneralError,"Invalid Length("_$L(pRequest.FirstName)_"): LastName, Max 80"))					
	}
	//Validate DOB
	If (pRequest.DOB=""){
		$$$ThrowStatus($$$ERROR($$$GeneralError,"Missing required field: DOB"))					
	}elseIf ($L(pRequest.DOB)<3)||($L(pRequest.DOB)>10){
		$$$ThrowStatus($$$ERROR($$$GeneralError,"Invalid Length("_$L(pRequest.DOB)_"): DOB"))					
	}
	
	Set tCreatedBy = pRequest.CreatedBy
	If tCreatedBy=""{
		$$$ThrowStatus($$$ERROR($$$GeneralError,"Missing Required field: CreatedBy"))		
	}
	Set tUniqueID=pRequest.AdditionalInfo.GetAt("RecordUniqueID")
	If tUniqueID=""{
		$$$ThrowStatus($$$ERROR($$$GeneralError,"Missing required field: AdditionalInfo(RecordUniqueID)"))			
	}
	Set tDateOfService=pRequest.AdditionalInfo.GetAt("DateOfService")
	If tDateOfService=""{
		$$$ThrowStatus($$$ERROR($$$GeneralError,"Missing required field: AdditionalInfo(DateOfService)"))					
	}else{
		//Check format for DOS, throw error if invalid
		If ($LENGTH(tDateOfService)>10){
			$$$ThrowStatus($$$ERROR($$$GeneralError,"Received incorrect format for AdditionalInfo(DateOfService) expected : YYYY-MM-DD got "_tDateOfService))			
		}ElseIf ($LENGTH(tDateOfService)<10){
			If ($LENGTH(tDateOfService)=8)&&(tDateOfService'["-"){
				Set tDateOfService=$EXTRACT(tDateOfService,1,4)_"-"_$EXTRACT(tDateOfService,5,6)_"-"_$EXTRACT(tDateOfService,7,8)
			}else{
				$$$ThrowStatus($$$ERROR($$$GeneralError,"Received incorrect format for AdditionalInfo(DateOfService) expected : YYYY-MM-DD got "_tDateOfService))			
			}
		}
	}
	Quit $$$OK
}

Method GetMemberEnrollment(ByRef pResponse As HS.Message.PatientSearchResponse, ByRef pPatient As %String, ByRef pMemberId As %String = "", pMemberAA As %String = "", pDOS As %String = "", pURL = "/memberEnrollment/byCarrierMember/") As %Status
{
	#dim tSC 			As %Status=$$$OK
	#dim eException  	As %Exception.AbstractException
	#dim checkMemberEnrollment As %Boolean=1
	Try {
		Set tMemberId=pMemberId,tMemberIdAA=pMemberAA,tDateOfService=pDOS,tFoundMember=""
		Set tServiceObj = ##class(HS.Registry.Service.Abstract).EndPointForNameType(..HSANALYTICSService, "HTTP")
		If tServiceObj="" $$$ThrowStatus($$$ERROR($$$GeneralError,"Could not determine Service entry."))
		Set tHttpRequest=##class(%Net.HttpRequest).%New()
		If tServiceObj.HTTPCredentialsConfig'="" {
			Set tCredentials=##class(Ens.Config.Credentials).%OpenId(tServiceObj.HTTPCredentialsConfig,0)
			If tCredentials'="" {
				Set tHttpRequest.Username=tCredentials.Username
				Set tHttpRequest.Password=tCredentials.Password
			}
		}
		Set tHttpRequest.Server=tServiceObj.Host
		Set tHttpRequest.Port=tServiceObj.Port
		If tServiceObj.SSLConfig'="" {
			Set tHttpRequest.Https=1
			Set tHttpRequest.SSLConfiguration=tServiceObj.SSLConfig
		}
		Do tHttpRequest.SetHeader("Accept","*/*")
		Set tHttpRequest.ContentType="application/json"

		#;Get information for HSANALYTICS about member enrollment
		Set tHSAASend = 0
		While checkMemberEnrollment{
			Set tMemberURL=pURL
			If (tHSAASend < ..HSANALYTICSRetries){
				$$$THROWONERROR(tSC,tHttpRequest.Get(tServiceObj.URL_tMemberURL_tMemberId))
				$$$TRACE("GET:  "_tHttpRequest.Server_":"_tHttpRequest.Port_tServiceObj.URL_tMemberURL_tMemberId)
				Set tHSAASend =tHSAASend+1
				If (tHttpRequest.HttpResponse.StatusCode=200) {Set checkMemberEnrollment=0}
				ElseIf tHttpRequest.HttpResponse.StatusCode=404 {$$$ThrowStatus($$$ERROR($$$GeneralError, "Analytics API Service not available."))}
				ElseIf (tHttpRequest.HttpResponse.StatusCode=500){ $$$LOGWARNING("Problem contacting analytics.")}
				ElseIf (tHttpRequest.HttpResponse.StatusCode'=200){ $$$ThrowStatus($$$ERROR($$$GeneralError, "Could not Get Member Enrollment. "_tHttpRequest.HttpResponse.StatusLine))}
			}Else{
				$$$ThrowStatus($$$ERROR($$$GeneralError, "Problem contacting Analytics. Member Enrollment for "_tMemberId_" from "_tMemberIdAA_" not found"))
			}
		}
		#;With the Response from analytics get tMemberEnrollments which is an array of records
		Set tStream=tHttpRequest.HttpResponse.Data
		If (tStream.Size>0){
			$$$TRACE("Got member enrollment for: "_tMemberId_" from "_tMemberIdAA)
			$$$HSTRACE("Response","Size,tStream",tStream.Size,tStream.Read(1000)) Do tStream.Rewind()
			Set tMemberFromTime="",tMemberToTime="",tMemberStatus=""
			Set tMemberSafetyResponse=$classmethod(..MemberResponse,"%New")
			$$$THROWONERROR(tSC,tMemberSafetyResponse.%JSONImport(tStream))
			$$$TRACE("Found "_tMemberSafetyResponse.MemberEnrollments.Count()_" member enrollments")
			Set tHasCoverage=0,tPatient="",tMemberMatch=0,tSubscriberID=""
			If tMemberSafetyResponse.MemberEnrollments.Count() = 0 {
				$$$ThrowStatus($$$ERROR($$$GeneralError, "Member Enrollment for "_tMemberId_" from "_tMemberIdAA_" not found"))
			}
			For m=1:1:tMemberSafetyResponse.MemberEnrollments.Count(){
				Set tMemberEnrollment = tMemberSafetyResponse.MemberEnrollments.GetAt(m)
				$$$TRACE("("_m_") - From:"_tMemberEnrollment.FromTime_" Status:"_tMemberEnrollment.MemberStatus)
				If m=1{
					//First Member Enrollment
					Set tMemberFromTime = tMemberEnrollment.FromTime
					Set tMemberToTime = tMemberEnrollment.ToTime
					Set tMemberStatus = $ZCVT(tMemberEnrollment.MemberStatus,"L")
					Set tHasCoverage=..HasCoverage(tDateOfService,tMemberFromTime,tMemberToTime)
					If tHasCoverage{
						Set tFoundMember = tMemberEnrollment.CarrierSpecificMemberID
						Set tSubscriberID = tMemberEnrollment.SubscriberID
						Set tPatient = tMemberEnrollment.PatientID
						Set tMemberMatch=tMemberMatch+1
					}
				}
				Else{
					//If (tMemberStatus="active") && ($ZCVT(tMemberEnrollment.MemberStatus,"L")="active"){
					Set NewIsGreater=$ZDatetimeh(tMemberEnrollment.FromTime,3,3)>=$ZDatetimeh(tMemberFromTime,3,3)
					$$$TRACE("Compare dates of 2 member enrollments: "_tMemberFromTime_"<="_tMemberEnrollment.FromTime_"?"_NewIsGreater)
					if NewIsGreater {
						Set tMemberFromTime = tMemberEnrollment.FromTime
						Set tMemberToTime = tMemberEnrollment.ToTime
						Set tHasCoverage=..HasCoverage(tDateOfService,tMemberFromTime,tMemberToTime)
						If tHasCoverage{
							If tPatient '[ tMemberEnrollment.PatientID {
								Set tMemberMatch=tMemberMatch+1
								Set tPatient=tPatient_","_tMemberEnrollment.PatientID
								Set tSubscriberID=tSubscriberID_","_tMemberEnrollment.SubscriberID
								If tFoundMember '[ tMemberEnrollment.CarrierSpecificMemberID{
									Set tFoundMember=tFoundMember_","_tMemberEnrollment.CarrierSpecificMemberID
								}
							}
						}
					}
				}
				//}
			}
			If ('tHasCoverage){
				Do pResponse.Results.Clear()
				Do pResponse.MPIIDList.Clear()
				$$$ThrowStatus($$$ERROR($$$GeneralError,"Member Enrollment for "_tMemberEnrollment.CarrierSpecificMemberID_" not active or has no coverage"))
			}
			#; Append a comma for a later contains search
			If tPatient'="" Set tPatient=tPatient_","
			Set pPatient=tPatient
			Set pMemberId=tFoundMember
			Do pResponse.AdditionalInfo.SetAt(tFoundMember,"CarrierSpecificMemberID")
		}Else{
			$$$ThrowStatus($$$ERROR($$$GeneralError,"Member Enrollment for "_tMemberId_" not found"))
		}
	}
	Catch eException {
		Set tSC=eException.AsStatus()
	}
	Quit tSC
}

Method ProcessSearchResponse(tResponse As HS.Message.PatientSearchResponse, tPatient As %String = "", ByRef tMember, ByRef tSubscriber, ByRef tStatus) As %String
{
	Set tFoundMember=tMember,tMPIID="",tStatus="",tMember="",tSubscriber="",tRemoveMPI=""
	If (tResponse.ResultsCount=0){
		Set tStatus="There are no matches"
		Quit tMPIID
	}
	If (tResponse.ResultsCount=1)&&(tResponse.MPIIDList.Count()=1){
		#; There is only one patient match, check the rank
		Set tMPIID = tResponse.MPIIDList.GetAt(1).MPIID
		Set tRank = tResponse.MPIIDList.GetAt(1).Rank
		$$$TRACE("There is 1 match with "_tRank_" and "_tResponse.Results.Count()_" MRNs")
		Set tStatus="There is 1 match with "_tRank_" and "_tResponse.Results.Count()_" MRNs"
		If (tPatient'=""){
			If (tMPIID=tPatient) { 
				$$$TRACE("MPIIDs match.")
			}ElseIf (tPatient '[ tMPIID) {
				Set tStatus="Patient found with demographics ("_tMPIID_"), not found in analytics ("_tPatient_")"
				Set tSC = tResponse.MPIIDList.Clear()
				Set tMPIID=""
			}
		}
	}ElseIf (tResponse.ResultsCount>1){
		Set tTotResults = tResponse.ResultsCount, tTotalRem=0
		Set tStatus="There are "_tTotResults_" matches"
		For m=1:1:tResponse.MPIIDList.Count(){
			Set tRecordMPIID=tResponse.MPIIDList.GetAt(m).MPIID
			If (tPatient '= "") && (tPatient '[ (tRecordMPIID_",")){
				Set tRemoveMPI=tRemoveMPI_m_","	
				Set tTotalRem = tTotalRem + 1		
			}else{
				If tMPIID="" {Set tMPIID=tRecordMPIID}
				else {Set tMPIID=tMPIID_","_tRecordMPIID}
			}
		}
		If (tRemoveMPI'=""){
			Set tRemoveList = $LFS(tRemoveMPI,",")
			For r=$LL(tRemoveList):-1:1{
				Set tN = $LIST(tRemoveList,r)
				If tN '="" Set tSC = tResponse.MPIIDList.RemoveAt(tN)
			}
		}
	}
	Set tRemove=""
	For i=1:1:tResponse.Results.Count(){
		#Dim tMatch As HS.Message.PatientSearchMatch
		Set tMatch=tResponse.Results.GetAt(i)
		Set tCheckIdentifiers=1,tMatchID=0,tTempSubs=""
		If (tPatient '= "") && (tPatient '[ (tMatch.MPIID_",")) {
			Set tCheckIdentifiers=0
			Set tRemove = tRemove_i_","
		}
		If tCheckIdentifiers{
			For ident=1:1:tMatch.Identifiers.Count(){
				Set tIdent = tMatch.Identifiers.GetAt(ident)
				If (tIdent.AssigningAuthorityName="IDCARD"){
					If (tFoundMember'="") && (tFoundMember=tIdent.Extension){
						Set tMember=tIdent.Extension
						Set tMatchID=1
					}elseIf (tFoundMember=""){
						If tMember="" {Set tMember=tIdent.Extension}
						Else {Set tMember=tMember_","_tIdent.Extension}
						Set tMatchID=1
					}
				}ElseIf (tIdent.AssigningAuthorityName="PATID"){
					Set tTempSubs=tIdent.Extension
				}
			}
		}
		If tMatchID=0{
			Set tRemove = tRemove_i_","
		}else{
			If (tFoundMember=""){
				If tSubscriber="" {Set tSubscriber=tTempSubs}
				Else {Set tSubscriber=tSubscriber_","_tTempSubs}
			}Else{
				Set tSubscriber=tTempSubs
			}
		}
	}
	If (tRemove'=""){
		Set tRemoveList = $LFS(tRemove,",")
		For r=$LL(tRemoveList):-1:1{
			Set tN = $LIST(tRemoveList,r)
			If tN '="" Set tSC = tResponse.Results.RemoveAt(tN)
		}
		Set tResponse.ResultsCount=tResponse.Results.Count()
		If tResponse.Results.Count()=0 Set tMPIID=""
	}
	Quit tMPIID
}

/// Check that Date of Service is within the coverage range
Method HasCoverage(pDOS, pStart, pEnd) As %Boolean
{
	Set tHasCoverage=0,pDOSDate=""
	If pDOS=""{
		$$$LOGERROR("Date of Service is required.")
	}Else{
		Set pDOSDate=$ZDATEH($PIECE(pDOS," "),3)
	}
	If pStart'=""{
		Set pStartDate=$ZDATEH($PIECE(pStart," "),3)
		//Check if DOS is greater than or equal to Coverage Start Date
		If (pDOSDate >= pStartDate){
			Set tHasCoverage=1
		}
	}
	Set pEndDate=$PIECE(pEnd," ")
	If (pEnd="") || (pEndDate="9999-12-31"){
		Set tHasCoverage=1	
	}ElseIf pEnd'=""{
		//Check that DOS is less than or equal to Coverage End Date.
		Set pEndDate=$ZDATEH(pEndDate,3)
		If (pDOSDate <= pEndDate){
			Set tHasCoverage=1
		}Else{
			Set tHasCoverage=0	
		}
	}
	Quit tHasCoverage
}

/// Test the functionality when multiple identifiers are returned
ClassMethod TestMemberExistsMultipleIDs(tMessage As %String = "") As %Status [ Internal ]
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
            Set tRequest.DOB="13/03/2007"
            Set tRequest.CreatedBy="RecordSource"
            Do tRequest.AdditionalInfo.SetAt("2023-11-18","DateOfService")
            Do tRequest.AdditionalInfo.SetAt("TESTIdentMult-1","RecordUniqueID")
            
            Set tIdentifier = ##class(HS.Types.Identifier).%New()
            Set tIdentifier.Use="MRN"
            Set tIdentifier.Extension="ZCS76560722"
            Set tIdentifier.AssigningAuthorityName="BCBS STATE HEALTH PLAN"
            Set tIdentifier.Status="A"
            Do tRequest.Identifiers.Insert(tIdentifier)
            
            Set tIdentifier = ##class(HS.Types.Identifier).%New()
            Set tIdentifier.Use="MRN"
            Set tIdentifier.Extension="ZCS7656"
            Set tIdentifier.AssigningAuthorityName="MEDICARE"
            Set tIdentifier.Status="A"
            Do tRequest.Identifiers.Insert(tIdentifier)
            
        }
        // Next we create an instance of the Process.  GetShadowInstance will return the live instance if the production is running otherwise a static but populated instance
        Set tProcess=##class(Ens.Host).GetShadowInstance("Member.SafetyCheck")
        Do tProcess.OnInit()

        //Since the business item is a process, the method to call is always OnRequest
        Set tSC = tProcess.OnRequest(tRequest,.tResponse)
  	}
	Catch eException {
		Set tSC=eException.AsStatus()
	}
	Quit tSC
}

/// Test the functionality with a newborn
ClassMethod TestNewbornExists(tMessage As %String = "") As %Status [ Internal ]
{
	#dim tSC 			As %Status=$$$OK
	#dim eException  	As %Exception.AbstractException
	Try {
        #;First we grab a previous request using the message body ID from the message viewer/visual trace
        Set tRequest=##class(HS.Message.PatientSearchRequest).%New()
        If tMessage '= ""{
            Set tRequest=##class(HS.Message.PatientSearchRequest).%OpenId(tMessage)
        }Else{
            Set tRequest.LastName="SCHEETZ"
            Set tRequest.FirstName="QUINTEN"
            Set tRequest.DOB="11/08/2023"
            Set tRequest.MRN="Z111804576-111"
            Set tRequest.AssigningAuthority="CES"
            Set tRequest.CreatedBy="RecordSource"
            Do tRequest.AdditionalInfo.SetAt("","DateOfService")
            Do tRequest.AdditionalInfo.SetAt("","RecordUniqueID")
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
        Set tProcess=##class(Ens.Host).GetShadowInstance("Member.SafetyCheck")
        Do tProcess.OnInit()

        //Since the business item is a process, the method to call is always OnRequest
        Set tSC = tProcess.OnRequest(tRequest,.tResponse)
  	}
	Catch eException {
		Set tSC=eException.AsStatus()
	}
	Quit tSC
}

ClassMethod TestMultipleMemberExists(tMessage As %String = "") As %Status [ Internal ]
{
	#dim tSC 			As %Status=$$$OK
	#dim eException  	As %Exception.AbstractException
	Try {
        #;First we grab a previous request using the message body ID from the message viewer/visual trace
        Set tRequest=##class(HS.Message.PatientSearchRequest).%New()
        If tMessage '= ""{
            Set tRequest=##class(HS.Message.PatientSearchRequest).%OpenId(tMessage)
        }Else{
            Set tRequest.LastName="FILKER"
            Set tRequest.FirstName="KELLEN"
            Set tRequest.DOB="02/28/2005"
            Set tRequest.MRN="029925105641"
            Set tRequest.AssigningAuthority="CES"
            Set tRequest.CreatedBy="RecordSource"
            Do tRequest.AdditionalInfo.SetAt("2023-11-18","DateOfService")
            Do tRequest.AdditionalInfo.SetAt("TESTMult-1","RecordUniqueID")
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
        Set tProcess=##class(Ens.Host).GetShadowInstance("Member.SafetyCheck")
        Do tProcess.OnInit()

        //Since the business item is a process, the method to call is always OnRequest
        Set tSC = tProcess.OnRequest(tRequest,.tResponse)
  	}
	Catch eException {
		Set tSC=eException.AsStatus()
	}
	Quit tSC
}

Method InvokeHubService(pServiceClassName As %String, pProxyClassName As %String, pMethodName As %String, Output pResponse, pArgs...) As %Status
{
	Try{
		If ($namespace[ "ROUTER"){
			//Need to read the Hub information from the service registry
			#dim tConfig as HS.Registry.Service.SOAP = ##class(HS.Registry.Service.SOAP).EndPointForNameType("HSREGISTRY","SOAP")
			If $isObject(tConfig) {
				Set pURL = $p(tConfig.EndPoint,"/",1,$l(tConfig.EndPoint,"/")-1)
				Set pSSLConfig=tConfig.SSLConfig
				Set tEnsembleUser = tConfig.UsernameTokenProfileConfig
				Set tSC = ##class(Ens.Config.Credentials).GetCredentialsObj(.tCredentials, $classname(), "Ens.Config.Credentials", tEnsembleUser)
				Quit:$$$ISERR(tSC)
				Set pUser=tCredentials.Username, pPW=tCredentials.Password
				Set tSoap=$zobjclassmethod(pProxyClassName,"%New")
				Set tSoap.Location=pURL_"/"_pServiceClassName_".cls"
				Set tSC=tSoap.WSSecurityLogin(pUser,pPW) QUIT:'tSC
				Set tSoap.SSLConfiguration=pSSLConfig
				Set pResponse=$zobjmethod(tSoap,pMethodName,pArgs...),tSC=$$$OK
			} Else {
				Set tSC = $$$ERROR($$$HSErrComponentNotConfigured,"HSREGISTRY SOAP Service")
				Quit
			}
		}else{
			//If on a gateway or Hub
			Set tSC = ##class(HS.Util.HubServices).InvokeHubService(pServiceClassName,pProxyClassName,pMethodName,.tSC,pRequest,.tResponse)
		}
	}
	Catch eException {
		Set tSC=eException.AsStatus()
	}
	Quit tSC
}

Storage Default
{
<Data name="SafetyCheckDefaultData">
<Subscript>"SafetyCheck"</Subscript>
<Value name="1">
<Value>HSANALYTICSService</Value>
</Value>
<Value name="2">
<Value>HSANALYTICSRetries</Value>
</Value>
<Value name="3">
<Value>TraceOperations</Value>
</Value>
<Value name="4">
<Value>MemberResponse</Value>
</Value>
<Value name="5">
<Value>DemographicsSearch</Value>
</Value>
<Value name="6">
<Value>DemographicSearch</Value>
</Value>
<Value name="7">
<Value>MinimumWeight</Value>
</Value>
<Value name="8">
<Value>MinMatchPercentage</Value>
</Value>
<Value name="9">
<Value>NewBornDateRange</Value>
</Value>
</Data>
<DefaultData>SafetyCheckDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

/// Revision number of this class
Parameter SrcVer = 15;

}
