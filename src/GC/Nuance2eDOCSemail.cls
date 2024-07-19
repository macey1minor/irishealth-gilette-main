Class GC.Nuance2eDOCSemail Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ORU_R01' targetDocType='231.Cerner:ORU_R01' create='new' language='objectscript' >
<code>
<![CDATA[ 
  // Last Updated 04/08/2020 Al Johnson
  // Moved to Prod 04/08/2020 Al Johnson
  // Create: 04/08/2020 Al Johnson
  // Description:
  //    Create hl7 to email when addendums
  //    There is a problem when addendums trail the original document
]]></code>
<assign value='source.{MSH}' property='target.{MSH}' action='set' />
<assign value='source.{PID:PatientIdentifierList()}' property='target.{PID:PatientIdentifierList()}' action='set' />
<assign value='source.{PID:PatientName()}' property='target.{PID:PatientName()}' action='set' />
<assign value='source.{PID:PatientAccountNumber}' property='target.{PID:PatientAccountNumber}' action='set' />

<assign value='source.{ORCgrp(1).ORC:3}' property='target.{ORCgrp(1).ORC:3}' action='set' />
<assign value='source.{ORCgrp(1).ORC:9}' property='target.{ORCgrp(1).ORC:9}' action='set' />
<assign value='source.{ORCgrp(1).OBR:3}' property='target.{ORCgrp(1).OBR:3}' action='set' />
<assign value='source.{ORCgrp(1).OBR:4}' property='target.{ORCgrp(1).OBR:4}' action='set' />

<foreach property='source.{ORCgrp(1).OBXgrp().OBX}' key='k3' >
<code>
<![CDATA[
     // email signature line and partial obx
     ]]></code>
  <assign value='source.{ORCgrp(1).OBXgrp(k3).OBX:1}' property='target.{ORCgrp(1).OBXgrp(k3).OBX:1}' action='set' />
 <assign value='source.{ORCgrp(1).OBXgrp(k3).OBX:2}' property='target.{ORCgrp(1).OBXgrp(k3).OBX:2}' action='set' />
 <assign value='source.{ORCgrp(1).OBXgrp(k3).OBX:3}' property='target.{ORCgrp(1).OBXgrp(k3).OBX:3}' action='set' />
<foreach property='source.{ORCgrp(1).OBXgrp(k3).NTE()}' key='k7' >
<assign value='source.{ORCgrp(1).OBXgrp(k3).NTE(k7)}' property='target.{ORCgrp(1).OBXgrp(k3).NTE(k7)}' action='set' />
</foreach>
</foreach>

</transform>
}

}
