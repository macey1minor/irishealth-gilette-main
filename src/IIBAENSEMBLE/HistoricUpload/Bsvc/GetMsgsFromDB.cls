Class IIBAENSEMBLE.HistoricUpload.Bsvc.GetMsgsFromDB Extends Ens.BusinessService [ ProcedureBlock ]
{

Parameter ADAPTER = "Ens.InboundAdapter";

Property TargetConfigNames As %String;

Property SourceIdentifier As %String;

Property MessageCount As %String;

Parameter SETTINGS As %String = "TargetConfigNames,SourceIdentifier,MessageCount";

Method OnProcessInput(pInput As %RegisteredObject, pOutput As %RegisteredObject) As %Status
{

	s tSC=$$$OK
	s rs=##class(%ResultSet).%New()
	s qry="select top "_..MessageCount_" * from IIBAENSEMBLE_HistoricUpload.Queue where SourceIdentifier='"_..SourceIdentifier_"' and  Processed=0"
	//s qry="select top "_..MessageCount_" * from IIBAENSEMBLE_HistoricUpload.Queue where SourceIdentifier='"_..SourceIdentifier_"' and  Processed=0 order by MessageId Desc"
	$$$TRACE(qry)
	d rs.Prepare(qry)
	d rs.Execute()
	
	while (rs.Next()) {
		
		s MessageId=rs.Get("MessageId")
		if (MessageId'="") {
			s HL7msg=##class(EnsLib.HL7.Message).%OpenId(MessageId)
			For i=1:1:$L(..TargetConfigNames,",") {
				S target=$P(..TargetConfigNames,",",i)
				$$$TRACE("Sending HL7 Message '"_MessageId_"' To '"_target_"'.")
			
				set tSC=..SendRequestAsync(target,HL7msg)
				Q:$$$ISERR(tSC)
			}
		}
		
		s source=..SourceIdentifier
		&sql( update IIBAENSEMBLE_HistoricUpload.Queue set Processed=1 
				where SourceIdentifier = :source
				and   MessageId = :MessageId
			)
		
		if (SQLCODE'=0) {
			$$$TRACE("Update failed")
			Q
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

}
