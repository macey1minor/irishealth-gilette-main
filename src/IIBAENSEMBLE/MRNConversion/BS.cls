Class IIBAENSEMBLE.MRNConversion.BS Extends (Ens.BusinessService, Ens.ContextSearch)
{

Parameter ADAPTER = "Ens.InboundAdapter";

Property TargetConfigNames As %String;

Property MessageCount As %String;

/// Select OrgCodes to process.
Property FacilityCodes As %String;

Parameter SETTINGS As %String = "TargetConfigNames:Additional:selector?multiSelect=0&context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId},MessageCount,FacilityCodes:Additional:selector?multiSelect=0&context={IIBAENSEMBLE.MRNConversion.BS/ClientSearch?targets=1&productionName=@productionId}";

Method OnProcessInput(pInput As %RegisteredObject, pOutput As %RegisteredObject) As %Status
{

	s tSC=$$$OK
	s rs=##class(%ResultSet).%New()
	if $L(..FacilityCodes,",")'=1
	{
		s tAndOr = $Replace(..FacilityCodes,",","' OR OrgCode = '")_"'"
	}
	else
	{
		s tAndOr = ..FacilityCodes_"'"
	}
	s qry="select top "_..MessageCount_" * from IIBAENSEMBLE_MRNConversion.Queue where  ProcessedTime is NULL AND (OrgCode = '"_tAndOr_") Order By LastServiceDate DESC"
	$$$TRACE(qry)
	d rs.Prepare(qry)
	d rs.Execute()
	
	while (rs.Next()) {
		
		s RefID=rs.Get("ID")
		$$$TRACE("Processing MRN: "_RefID)
		if (RefID'="") {
			s MergeRequest=##class(IIBAENSEMBLE.MRNConversion.Queue).%OpenId(RefID)
			s MergeRequest.ProcessedTime = $ZDT($H,3)
			d MergeRequest.%Save()
			For i=1:1:$L(..TargetConfigNames,",") {
				S target=$P(..TargetConfigNames,",",i)
				$$$TRACE("Sending HL7 Message '"_RefID_"' To '"_target_"'.")
				if MergeRequest.RegistrationMsg '= ""
				{
					set tSC=..SendRequestAsync(target,MergeRequest.RegistrationMsg)
				}
				set tSC=..SendRequestAsync(target,MergeRequest.ConversionMsg)
				Q:$$$ISERR(tSC)
			}
		}
		
	
	}
	
	Quit tSC
}

ClassMethod OnGetConnections(Output pArray As %String, item As Ens.Config.Item)
{
	Set (tValue,tIndex)="" 
	For { 
		Set tIndex = item.Settings.Next(tIndex) Quit:tIndex=""
		Set tSetting = item.Settings.GetAt(tIndex)
		If tSetting.Name="TargetConfigNames" {
			Set tValue=tSetting.Value
		}
	}
	
	For i=1:1:$L(tValue,",") { 
		Set tOne=$P(tValue,",",i)
		If (tOne '= "" ) {
			Set pArray(tOne)=""
		}
	}
	Quit
}

ClassMethod ClientSearch(Output pCaption As %String, Output pTopResults, Output pResults, ByRef pParms As %String, pSearchKey As %String = "") As %Status
{
	s RS = ##class(%ResultSet).%New()
	s sql = "Select Distinct OrgCode from IIBAENSEMBLE_MRNConversion.Queue where ProcessedTime is NULL"
	do RS.Prepare(sql)
	do RS.Execute()
	s pResults = 0
	s tcount = 0
		
	while RS.Next()
	{
		s pResults = pResults + 1
		&sql(select Count("OrgCode") into :tcount from IIBAENSEMBLE_MRNConversion.Queue where OrgCode = :RS.Get("OrgCode"))
		s pResults(pResults) = RS.Get("OrgCode")
	
		//RS.Get("OrgCode")_"("_tcount_")"
		s pCaption = "Please Select OrgCodes"
	}
	Quit $$$OK
}

}
