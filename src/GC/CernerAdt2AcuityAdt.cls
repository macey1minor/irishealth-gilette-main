Class GC.CernerAdt2AcuityAdt Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ADT_A01' targetDocType='231.Cerner:ADT_A01' create='new' language='objectscript' >
<code>
<![CDATA[ 
  // Last Updated 05/28/2020 Al Johnson
  // Moved to Prod 06/05/2020 Al Johnson
  // Description:
  //    Translation was reading table and updating the unit
  //    If no record, wrote blank unit
  //    Changed to check inpatient and pass unit thru if no table entry
  //    Mulitple overflow units created for COVID19 - 5/28/2020 CNR-20406
]]></code>

<assign value='source.{MSH}' property='target.{MSH}' action='set' />
<assign value='source.{EVN}' property='target.{EVN}' action='set' />
<assign value='source.{PID}' property='target.{PID}' action='set' />
<assign value='source.{PV1}' property='target.{PV1}' action='set' />

<assign value='""' property='wtableunitresult' action='set' />
<assign value='..Lookup("T_Cr2Acuity_Unit",source.{PV1:AssignedPatientLocation.pointofcare})' property='wtableunitresult' action='set' />

<if condition='wtableunitresult=""' >
<false>
<assign value='wtableunitresult' property='target.{PV1:AssignedPatientLocation.pointofcare}' action='set' />
</false>
<true>
<if condition='source.{PV1:PatientClass}="I"' >
<true>
<assign value='source.{PV1:AssignedPatientLocation.pointofcare}' property='target.{PV1:AssignedPatientLocation.pointofcare}' action='set' />
</true>
<false>
<assign value='""' property='target.{PV1:AssignedPatientLocation.pointofcare}' action='set' />
</false>
</if>
</true>
</if>

</transform>
}

}
