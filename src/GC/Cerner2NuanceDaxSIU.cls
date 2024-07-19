Class GC.Cerner2NuanceDaxSIU Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:SIU_S12' targetDocType='231.Cerner:SIU_S12' create='new' language='objectscript' >
<code>
<![CDATA[ 
	//  Last Updated: 11/19/2021 Al Johnson
	//  Last Updated in Prod: 12/03/2021 Al Johnson
	//  Create: 11/19/2021  Al Johnson
	//
	//  Description:  New Interface - ADT and SIU to NuanceDax
	//   Used for doctors to dictate
	//
	//  Send MSH, PID, SCH, PV1 and RGSgrp RGS, AIS, AIG, AIL, AIP
	//  New Interface RFC SD-107657
]]></code>
<assign value='source.{MSH}' property='target.{MSH}' action='set' />

<assign value='source.{PIDgrp(1).PID}' property='target.{PIDgrp(1).PID}' action='set' />
<assign value='"MRN"' property='target.{PIDgrp(1).PID:3.5}' action='set' />
<assign value='""' property='target.{PIDgrp(1).PID:19}' action='set' />

<assign value='source.{PIDgrp(1).PV1}' property='target.{PIDgrp(1).PV1}' action='set' />

<code>
<![CDATA[ 
    // AIP:3.1 send npi
    // Remove decimal points on siu schedule id
]]></code>
<assign value='source.{SCH}' property='target.{SCH}' action='set' />

<assign value='source.{SCH:7.1}' property='target.{SCH:8}' action='set' />

<assign value='$PIECE(source.{SCH:1.1},".",1)' property='holdschid' action='set' />
<assign value='holdschid' property='target.{SCH:1}' action='set' />
<assign value='holdschid' property='target.{PIDgrp(1).PV1:19}' action='set' />

<if condition='target.{PIDgrp(1).PV1:44}=""' >
<true>
<assign value='source.{SCH:11.4}' property='target.{PIDgrp(1).PV1:44}' action='set' />
</true>
</if>

<assign value='source.{RGSgrp(1).RGS}' property='target.{RGSgrp(1).RGS}' action='set' />

<foreach property='source.{RGSgrp(1).AISgrp()}' key='k1' >
<assign value='source.{RGSgrp(1).AISgrp(k1).AIS}' property='target.{RGSgrp(1).AISgrp(k1).AIS}' action='set' />
</foreach>

<foreach property='source.{RGSgrp(1).AIGgrp()}' key='k2' >
<assign value='source.{RGSgrp(1).AIGgrp(k2).AIG}' property='target.{RGSgrp(1).AIGgrp(k2).AIG}' action='set' />
</foreach>

<foreach property='source.{RGSgrp(1).AILgrp()}' key='k3' >
<assign value='source.{RGSgrp(1).AILgrp(k3).AIL}' property='target.{RGSgrp(1).AILgrp(k3).AIL}' action='set' />
</foreach>

<foreach property='source.{RGSgrp(1).AIPgrp()}' key='k4' >
<assign value='source.{RGSgrp(1).AIPgrp(k4).AIP:1}' property='target.{RGSgrp(1).AIPgrp(k4).AIP:1}' action='set' />
<assign value='source.{RGSgrp(1).AIPgrp(k4).AIP:2}' property='target.{RGSgrp(1).AIPgrp(k4).AIP:2}' action='set' />
<assign value='source.{RGSgrp(1).AIPgrp(k4).AIP:4}' property='target.{RGSgrp(1).AIPgrp(k4).AIP:4}' action='set' />
<assign value='source.{RGSgrp(1).AIPgrp(k4).AIP:5}' property='target.{RGSgrp(1).AIPgrp(k4).AIP:5}' action='set' />
<assign value='source.{RGSgrp(1).AIPgrp(k4).AIP:6}' property='target.{RGSgrp(1).AIPgrp(k4).AIP:6}' action='set' />
<assign value='source.{RGSgrp(1).AIPgrp(k4).AIP:7}' property='target.{RGSgrp(1).AIPgrp(k4).AIP:7}' action='set' />
<assign value='source.{RGSgrp(1).AIPgrp(k4).AIP:8}' property='target.{RGSgrp(1).AIPgrp(k4).AIP:8}' action='set' />
<assign value='source.{RGSgrp(1).AIPgrp(k4).AIP:9}' property='target.{RGSgrp(1).AIPgrp(k4).AIP:9}' action='set' />
<assign value='source.{RGSgrp(1).AIPgrp(k4).AIP:10}' property='target.{RGSgrp(1).AIPgrp(k4).AIP:10}' action='set' />
<assign value='source.{RGSgrp(1).AIPgrp(k4).AIP:11}' property='target.{RGSgrp(1).AIPgrp(k4).AIP:11}' action='set' />
<assign value='source.{RGSgrp(1).AIPgrp(k4).AIP:12}' property='target.{RGSgrp(1).AIPgrp(k4).AIP:12}' action='set' />
<assign value='""' property='tmpnpi' action='set' />
<assign value='""' property='tmpdoc' action='set' />

<foreach property='source.{RGSgrp(1).AIPgrp(k4).AIP:3()}' key='k5' >
<if condition='source.{RGSgrp(1).AIPgrp(k4).AIP:3(k5).9}="National Provider Identifier"' >
<true>
<assign value='source.{RGSgrp(1).AIPgrp(k4).AIP:3(k5)}' property='tmpnpi' action='set' />
</true>
</if>
<if condition='source.{RGSgrp(1).AIPgrp(k4).AIP:3(k5)}="Doctor Nbr"' >
<true>
<assign value='source.{RGSgrp(1).AIPgrp(k4).AIP:3(k5)}' property='tmpdoc' action='set' />
</true>
</if>
</foreach>
<if condition='tmpnpi=""' >
<false>
<assign value='tmpnpi' property='target.{RGSgrp(1).AIPgrp(k4).AIP:3}' action='set' />
</false>
<true>
<if condition='tmpdoc=""' >
<false>
<assign value='tmpdoc' property='target.{RGSgrp(1).AIPgrp(k4).AIP:3}' action='set' />
</false>
<true>
<assign value='source.{RGSgrp(1).AIPgrp(k4).AIP:3(1)}' property='target.{RGSgrp(1).AIPgrp(k4).AIP:3}' action='set' />
</true>
</if>
</true>
</if>
</foreach>

</transform>
}

}
