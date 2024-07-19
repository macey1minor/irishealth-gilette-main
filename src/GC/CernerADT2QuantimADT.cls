Class GC.CernerADT2QuantimADT Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ADT_A01' targetDocType='231.Cerner:ADT_A01' create='new' language='objectscript' >
<assign value='source.{MSH}' property='target.{MSH}' action='set' />
<assign value='"REG"' property='target.{MSH:SendingApplication.namespaceID}' action='set' />
<assign value='"GCS"' property='target.{MSH:SendingFacility.namespaceID}' action='set' />
<assign value='""' property='target.{MSH:ReceivingApplication.namespaceID}' action='set' />
<assign value='"GCS"' property='target.{MSH:ReceivingFacility.namespaceID}' action='set' />
<assign value='source.{EVN}' property='target.{EVN}' action='set' />
<assign value='source.{PID}' property='target.{PID}' action='set' />
<assign value='..Lookup("T_CrQuantimCountryCodes",source.{PID:PatientAddress().country})' property='target.{PID:PatientAddress().country}' action='set' />
<assign value='source.{NK1(1)}' property='target.{NK1(1)}' action='set' />
<assign value='source.{PV1}' property='target.{PV1}' action='set' />
<assign value='source.{PV2}' property='target.{PV2}' action='set' />
<assign value='source.{IN1grp().IN1}' property='target.{IN1grp().IN1}' action='set' />
<assign value='source.{IN1grp().IN2}' property='target.{IN1grp().IN2}' action='set' />
</transform>
}

}
