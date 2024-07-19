Class GC.AcuityMRGtoADTa08 Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ADT_A35' targetDocType='231.Cerner:ADT_A08' create='new' language='objectscript' >
<annotation>Need to generate an A08 after Merge is sent to get the correct location in Acuity</annotation>
<assign value='source.{MSH}' property='target.{MSH}' action='set' />
<if condition='source.{MSH:MessageType.triggerevent} = "A35"' >
<true>
<assign value='"A08"' property='target.{MSH:MessageType.triggerevent}' action='set' />
</true>
</if>
<assign value='source.{EVN}' property='target.{EVN}' action='set' />
<if condition='source.{EVN:EventTypeCode}= "A35"' >
<true>
<assign value='"A08"' property='target.{EVN:EventTypeCode}' action='set' />
</true>
</if>
<assign value='source.{PID}' property='target.{PID}' action='set' />
<assign value='source.{PV1}' property='target.{PV1}' action='set' />
<assign value='..Lookup("T_Cr2Acuity_Unit",source.{PV1:AssignedPatientLocation.pointofcare})' property='target.{PV1:AssignedPatientLocation.pointofcare}' action='set' />
</transform>
}

}
