Class IIBAENSEMBLE.MRNConversion.HL7Message Extends Ens.DataTransformDTL [ DependsOn = (IIBAENSEMBLE.MRNConversion.Queue, EnsLib.HL7.Message) ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='IIBAENSEMBLE.MRNConversion.Queue' targetClass='EnsLib.HL7.Message' targetDocType='2.3:ADT_A18' create='new' language='objectscript' >
<code>
<![CDATA[ 
	// ******* Declare Variables *********
]]></code>
<assign value='source.OrgCode' property='OrgID' action='set' />
<assign value='"A18"' property='Trigger' action='set' />
<assign value='"1058"' property='CxRint' action='set' >
<annotation>Need to load balance between CxR interfaces. </annotation>
</assign>
<code>
<![CDATA[ 
	// ******* MSH *********
]]></code>
<assign value='OrgID' property='target.{MSH:SendingFacility}' action='set' />
<assign value='"Inland Imaging"' property='target.{MSH:ReceivingApplication}' action='set' />
<assign value='source.ProcessedTime' property='target.{MSH:DateTimeofMessage}' action='set' />
<assign value='"ADT"' property='target.{MSH:MessageType.messagetype}' action='set' />
<assign value='Trigger' property='target.{MSH:MessageType.triggerevent}' action='set' />
<assign value='source.ConversionMsg.ParentId' property='target.{MSH:MessageControlID}' action='set' />
<assign value='"P"' property='target.{MSH:ProcessingID}' action='set' />
<assign value='"2.3"' property='target.{MSH:VersionID}' action='set' />
<assign value='##Class(ImagecastPacs.Functions).ConnectRLoadBalance(source.NewMRN)' property='target.{MSH:CountryCode}' action='set' />
<assign value='"RADIANT"' property='target.{MSH:SendingApplication}' action='set' />
<code>
<![CDATA[ 
	// ******* EVN *********
]]></code>
<assign value='Trigger' property='target.{EVN:EventTypeCode}' action='set' />
<code>
<![CDATA[ 
	// ******* PID *********
]]></code>
<assign value='source.NewMRN' property='target.{PID:PatientIDInternalID(1).ID}' action='set' />
<assign value='OrgID' property='target.{PID:PatientIDInternalID(1).assigningfacility}' action='set' />
<assign value='source.lName' property='target.{PID:PatientName.familyname}' action='set' />
<assign value='source.fName' property='target.{PID:PatientName.givenname}' action='set' />
<assign value='source.Sex' property='target.{PID:Sex}' action='set' />
<assign value='$P(source.DOB,"/",3)_$CASE($L($P(source.DOB,"/",1)),2:$P(source.DOB,"/",1),1:"0"_$P(source.DOB,"/",1),:$P(source.DOB,"/",1))_$CASE($L($P(source.DOB,"/",1)),2:$P(source.DOB,"/",2),1:"0"_$P(source.DOB,"/",2),:$P(source.DOB,"/",2))' property='target.{PID:DateofBirth.timeofanevent}' action='set' />
<code>
<![CDATA[ 
	// ******* MRG *********
]]></code>
<assign value='source.OldMRN' property='target.{MRG:PriorPatientIDInternal(1)}' action='set' />
</transform>
}

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

}
