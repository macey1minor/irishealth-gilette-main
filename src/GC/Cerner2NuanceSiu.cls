Class GC.Cerner2NuanceSiu Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:SIU_S12' targetDocType='231.Cerner:SIU_S12' create='copy' language='objectscript' >
<code>
<![CDATA[ 
	//  Last Updated 11/01/2019 Al Johnson
	//  Last Moved to Prod: 12/18/2019 Al Johnson
	//  Create: 11/01/2019  Al Johnson 
	//  Description:  Check table for combined appt type
	//  If on table load table id value to AIP(1) and shift other AIP segments down
	//  Nuance Mobile App uses so multiple doctors can see appt schedule
]]></code>

<code>
<![CDATA[
     // Read table T_Escription_Comb_Appt_Type for combined appt type
]]></code>
<assign value='""' property='tempseq' action='set' />
<assign value='target.{SCH:7.1}' property='wTableAliasKey' action='set' />
<assign value='""' property='wtablealiasresult' action='set' />
<assign value='..Lookup("T_Escription_Comb_Appt_Type",wTableAliasKey)' property='wtablealiasresult' action='set' />
<if condition='wtablealiasresult=""' >
<false>
<foreach property='source.{RGSgrp(1).AIPgrp()}' key='k1' >
<assign value='source.{RGSgrp(1).AIPgrp(k1).AIP:1}' property='tempseq' action='set' />
<assign value='tempseq+1' property='tempseq' action='set' />
<assign value='source.{RGSgrp(1).AIPgrp(k1)}' property='target.{RGSgrp(1).AIPgrp(k1+1)}' action='set' />
<assign value='tempseq' property='target.{RGSgrp(1).AIPgrp(k1+1).AIP:1}' action='set' />
</foreach>
<assign value='"1"' property='target.{RGSgrp(1).AIPgrp(1).AIP:1}' action='set' />
<assign value='wtablealiasresult' property='target.{RGSgrp(1).AIPgrp(1).AIP:3}' action='set' />
</false>
</if> 

</transform>
}

}
