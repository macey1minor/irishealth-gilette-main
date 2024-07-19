Class GC.AviziaSiu Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:SIU_S12' targetDocType='231.Cerner:SIU_S12' create='new' language='objectscript' >
<assign value='source.{MSH}' property='target.{MSH}' action='set' />
<assign value='source.{SCH}' property='target.{SCH}' action='set' />
<assign value='source.{NTE()}' property='target.{NTE()}' action='set' />
<assign value='source.{ZBX()}' property='target.{ZBX()}' action='set' />
<assign value='source.{PIDgrp()}' property='target.{PIDgrp()}' action='set' />
<assign value='source.{RGSgrp()}' property='target.{RGSgrp()}' action='set' />
<assign value='source.{RGSgrp().RGS}' property='target.{RGSgrp().RGS}' action='set' />
<assign value='source.{RGSgrp().AISgrp()}' property='target.{RGSgrp().AISgrp()}' action='set' />
<assign value='source.{RGSgrp().AIGgrp()}' property='target.{RGSgrp().AIGgrp()}' action='set' />
<assign value='source.{RGSgrp().AILgrp()}' property='target.{RGSgrp().AILgrp()}' action='set' />
<assign value='source.{RGSgrp().AILgrp().AIL}' property='target.{RGSgrp().AILgrp().AIL}' action='set' />
<assign value='source.{RGSgrp().AILgrp().AIL:LocationResourceID.facilityHD}' property='target.{RGSgrp().AILgrp().AIL:LocationResourceID}' action='set' />
<assign value='source.{PIDgrp().PV1:AssignedPatientLocation.facilityHD}' property='target.{PIDgrp().PV1:AssignedPatientLocation}' action='set' />
</transform>
}

}
