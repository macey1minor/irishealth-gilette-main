/// 
Class IIBAENSEMBLE.MRNConversion.BP Extends Ens.BusinessProcessBPL [ ClassType = persistent, ProcedureBlock ]
{

/// BPL Definition
XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='Ens.Request' height='2000' width='2000' >
<context>
<property name='HL7message' type='EnsLib.HL7.Message' instantiate='0' >
</property>
</context>
<sequence xend='200' yend='1150' >
<trace name='Start' value='"Entering Temp Merge processing"' xpos='200' ypos='250' />
<if name='HL7 message?' condition='$CLASSNAME(request)="EnsLib.HL7.Message"' xpos='200' ypos='350' xend='200' yend='1050' >
<true>
<code name='Check Pocessed Status' xpos='335' ypos='500' >
<![CDATA[
	// get the HL7 merge message from the Merge list.
	
	// declare variables
	#dim tSC as %Status = $$$OK
	
	//set OrgCode = request.GetValueAt("MSH:SendingFacility")
	set OrgCode = "TSH"
	set NewMRN=request.GetValueAt("PID:PatientIDInternalID(1).ID")
	
	// get indexed id if it exists.
	set tSC =##class(IIBAENSEMBLE.MRNConversion.Queue).RefIDExists(OrgCode,NewMRN,.id) Quit:tSC'=$$$OK
	set tMsg=##class(IIBAENSEMBLE.MRNConversion.Queue).RefIDOpen(id,1)
	
	// get mrn change message and mark processedtime.
	if ##Class(%Library.TimeStamp).IsValid(tMsg.ProcessedTime) '= 1
	{
		set context.HL7message=tMsg.ConversionMsg
		set tMsg.ProcessedTime=$ZDT($H,3)
		do tMsg.%Save()
	}	
	
 ]]>
</code>
<if name='Processed?' condition='context.HL7message&apos;=""' xpos='335' ypos='600' xend='335' yend='850' >
<true>
<call name='Send Conversion HL7' target='@process.MergeTargetConfig' async='1' xpos='470' ypos='750' >
<request type='Ens.Request' >
<assign property="callrequest" value="context.HL7message" action="set" />
</request>
</call>
</true>
</if>
<call name='Send Original hl7' target='@process.AdtTargetConfig' async='1' xpos='335' ypos='950' >
<request type='Ens.Request' >
<assign property="callrequest" value="request" action="set" />
</request>
</call>
</true>
</if>
</sequence>
</process>
}

Property MergeTargetConfig As %String;

Property AdtTargetConfig As %String;

Parameter SETTINGS As %String = "MergeTargetConfig:Additional:selector?multiSelect=0&context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId},AdtTargetConfig:Additional:selector?multiSelect=0&context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId}";

ClassMethod OnGetConnections(Output pArray As %String, item As Ens.Config.Item)
{
	Set (tValue,tIndex)="" 
	
	For { 
		Set tIndex = item.Settings.Next(tIndex) Quit:tIndex=""
		Set tSetting = item.Settings.GetAt(tIndex)
		//If ##class(Ens.Util.Functions).In(tSetting.Name,"AdtTargetConfig,MergeTargetConfig") {
		If ((tSetting.Name="AdtTargetConfig") || ( tSetting.Name="MergeTargetConfig")) {
			if (tSetting.Value'="") {
				set:tValue'="" tValue=tValue_","
				Set tValue=tValue_tSetting.Value
			}
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

Storage Default
{
<Data name="BPDefaultData">
<Subscript>"BP"</Subscript>
<Value name="1">
<Value>MergeTargetConfig</Value>
</Value>
<Value name="2">
<Value>AdtTargetConfig</Value>
</Value>
</Data>
<DefaultData>BPDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
