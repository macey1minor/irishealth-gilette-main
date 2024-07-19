Class GC.Cerner2PyxisMrg2ADT03 Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ADT_A35' targetDocType='231.Cerner:ADT_A03' create='new' language='objectscript' >
<annotation>sending an A03 for the nonsurviving FIN when an A34/A42 is sent from Cerner to Pyxis</annotation>
<code>
<![CDATA[ //sending an A03 to discharge the non-surviving FIN in Pyxis when A35 is sent_9.25.17 mmw]]></code>
<assign value='source.{MSH}' property='target.{MSH}' action='set' />
<assign value='"A03"' property='target.{MSH:MessageType.triggerevent}' action='set' />
<assign value='source.{PID}' property='target.{PID}' action='set' />
<assign value='source.{MRG:PriorPatientAccountNumber.ID}' property='target.{PID:PatientAccountNumber.ID}' action='set' />
<assign value='source.{PD1}' property='target.{PD1}' action='set' />
<assign value='source.{PV1}' property='target.{PV1}' action='set' />
</transform>
}

}
