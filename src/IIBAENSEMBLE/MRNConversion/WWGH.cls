Class IIBAENSEMBLE.MRNConversion.WWGH Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='WWGH:MDM_T02' targetDocType='WWGH:MDM_T02' create='copy' language='objectscript' >
<assign value='source.{PID:PatientIDInternalID(1).ID}' property='MRN' action='set' />
<assign value='"WWG"' property='OrgCode' action='set' />
<code>
<![CDATA[ 
	// *  Assign NewMRN if OldMRN is being sent in Result message.
	
	//check if RefID exists.
	
	if (##class(IIBAENSEMBLE.MRNConversion.Queue).OldMRNExists(OrgCode,MRN,.RefId)=1) {
		
		set tMsg=##class(IIBAENSEMBLE.MRNConversion.Queue).RefIDOpen(RefId,1)
		set MRN = tMsg.NewMRN
		
	}
	
		
]]></code>
<assign value='MRN' property='target.{PID:PatientIDInternalID(1).ID}' action='set' />

</transform>
}

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

}
