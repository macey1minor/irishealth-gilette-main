Class Cadwell.Cadwell2CernerORU Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ORU_R01' targetDocType='231.Cerner:ORU_R01' create='copy' language='objectscript' >
<assign value='"IOMPHYSICIANREPORT"' property='PHYSREPORT' action='set' />
<assign value='0' property='doesOrderNumberExist' action='set' />
<assign value='source.{ORCgrp(1).OBR:UniversalServiceID.identifier}' property='ReportType' action='set' />

<if condition='(ReportType=PHYSREPORT)' >
<true>
<assign value='source.{ORCgrp(1).OBR:PlacerOrderNumber.entityidentifier}' property='HL7OrderNumber' action='set' />
<assign value='##class(Cadwell.OrderNumberhold).Find(HL7OrderNumber)' property='doesOrderNumberExist' action='set' />
<if condition='doesOrderNumberExist' >
<false>
<assign value='"F"' property='target.{ORCgrp(1).OBR:ResultStatus}' action='set' />
<assign value='##class(Cadwell.OrderNumberhold).Insert(HL7OrderNumber)' property='tSC' action='set' />
</false>
</if>
</true>
</if>
</transform>
}

}
