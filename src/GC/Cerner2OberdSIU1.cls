Class GC.Cerner2OberdSIU1 Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:SIU_S12' targetDocType='231.Cerner:SIU_S12' create='new' language='objectscript' >
<code>
<![CDATA[ 
	//  Last Updated: 07/24/2020 Al Johnson
	//  Last Updated in Prod: 07/28/2020 Al Johnson
	//  Create: 11/11/2019  Al Johnson
	//
	//  Description:  New Interface - SIU to Oberd
	//   Used to direct surveys for specific doctors and schedules
	//
	//  Schedule Spec for SIU shows PID, SCH, PV1, AIL, AIP
	//  Events S12 new appt, S14 update and S15 cancel
	//
	//  Send reschedule as update
	//  Send S26 Noshow as S14 update; load "NO SHOW" in SCH-25.2
	//
	//  Appt Type Ortho Gait Lab - if no doctor add 60690^Georgiadis^Andrew^^^MD
	//   Handle above in GC.Cerner2OberdSIUGaitLab
	//  Remove decimal points on siu schedule id
	//
	//  Send Preferred Language in PID-15 01/30/2020
	//   Modobject in Cerner changed to send OBX with PREFERRED_LA  this value is aliased
	//   PID-15.1 is sent with aliased Primary Language
	//   PID-15.5 is unaliased (text) of Preferred Language
	//   SIU does not have OBX in Cerner schema so modobject sending text in PID-15.5
	//     Crosswalk to alias is Ensemble table T_Oberd_Language_Preferred
	//   ADT A34 Merge also does not have OBX segments - Oberd is taking language off each ADT and SIU
	//
	//  On Cerner upgrade, Cerner didnot convert multiple emails correctly.   7/24/2020 SD-49862 RFC SD-49907
	//  If multiples sent, need to take the first email in PID-11.
	//
]]></code>
<assign value='source.{MSH}' property='target.{MSH}' action='set' />
<assign value='source.{MSH:3.1}' property='target.{MSH:3.2}' action='set' />
<assign value='source.{MSH:4.1}' property='target.{MSH:4.2}' action='set' />
<assign value='source.{MSH:5.1}' property='target.{MSH:5.2}' action='set' />
<assign value='source.{MSH:6.1}' property='target.{MSH:6.2}' action='set' />
<code>
<![CDATA[ 
    // Oberd MSH spec
    // S12 New Appt
    // S14 Update Appt
    // S15 Cancel Appt
    // S17 Appt Delete - Send S15
    // S26 No Show - Send S14
]]></code>
<assign value='source.{MSH:9.2}' property='tmsh92' action='set' />
<if condition='(tmsh92="S13")||(tmsh92="S26")' >
<true>
<assign value='"S14"' property='target.{MSH:9.2}' action='set' />
</true>
<false>
<if condition='(tmsh92="S17")' >
<true>
<assign value='"S15"' property='target.{MSH:9.2}' action='set' />
</true>
</if>
</false>
</if>

<code>
<![CDATA[ 
    // Oberd PID spec
    // PID:2 patient id
    // PID:5 name
    // PID:7 date of birth
    // PID:8 gender
    // PID:11 address
    // PID:13.1 home phone
    // PID:13.4 email
    // PID:14.1 cell phone
]]></code>
<assign value='source.{PIDgrp(1).PID:3}' property='target.{PIDgrp(1).PID:2}' action='set' />
<assign value='source.{PIDgrp(1).PID:3}' property='target.{PIDgrp(1).PID:3}' action='set' />
<assign value='source.{PIDgrp(1).PID:5}' property='target.{PIDgrp(1).PID:5}' action='set' />
<assign value='source.{PIDgrp(1).PID:7}' property='target.{PIDgrp(1).PID:7}' action='set' />
<assign value='source.{PIDgrp(1).PID:8}' property='target.{PIDgrp(1).PID:8}' action='set' />
<assign value='source.{PIDgrp(1).PID:18}' property='target.{PIDgrp(1).PID:18}' action='set' />
<assign value='""' property='target.{PIDgrp(1).PID:19}' action='set' />

<assign value='""' property='tmpemail' action='set' />
<assign value='""' property='tmphomephone' action='set' />

<foreach property='source.{PIDgrp(1).PID:11()}' key='k1' >
<if condition='source.{PIDgrp(1).PID:11(k1).7}="E-mail"' >
<true>
<if condition='tmpemail=""' >
<true>
<assign value='source.{PIDgrp(1).PID:11(k1).1}' property='tmpemail' action='set' />
</true>
</if>
</true>
<false>
<if condition='source.{PIDgrp(1).PID:11(k1).7}="Home"' >
<true>
<assign value='source.{PIDgrp(1).PID:11(k1)}' property='target.{PIDgrp(1).PID:11(1)}' action='set' />
</true>
</if>
</false>
</if>
</foreach>

<foreach property='source.{PIDgrp(1).PID:13()}' key='k2' >
<if condition='source.{PIDgrp(1).PID:13(k2).2}="Home"' >
<true>
<if condition='tmphomephone=""' >
<true>
<assign value='source.{PIDgrp(1).PID:13(k2).1}' property='tmphomephone' action='set' />
</true>
</if>
</true>
<false>
<if condition='source.{PIDgrp(1).PID:13(k2).2}="CP"' >
<true>
<assign value='source.{PIDgrp(1).PID:13(k2).1}' property='target.{PIDgrp(1).PID:14(1).1}' action='set' />
</true>
</if>
</false>
</if>
</foreach>

<assign value='tmpemail' property='target.{PIDgrp(1).PID:13(1).4}' action='set' />
<assign value='tmphomephone' property='target.{PIDgrp(1).PID:13(1).1}' action='set' />

<code>
<![CDATA[ 
    // Oberd SIU spec
    // SCH.1 / PV1.19 Appt ID
    // SCH:8 Appt Type
    // AIL:3.1 Appt Location
    // SCH:11.4 / PV1:44 Appt Date and Time
    // AIP:3.1 / PV1:7 Physician ID
    // --- CPT (Gillette will not send)
    // Remove decimal points on siu schedule id
]]></code>
<assign value='source.{SCH}' property='target.{SCH}' action='set' />
<assign value='source.{PIDgrp(1).PV1}' property='target.{PIDgrp(1).PV1}' action='set' />

<assign value='source.{SCH:7.1}' property='target.{SCH:8}' action='set' />

<assign value='$PIECE(source.{SCH:1.1},".",1)' property='holdschid' action='set' />
<assign value='holdschid' property='target.{SCH:1}' action='set' />
<assign value='holdschid' property='target.{PIDgrp(1).PV1:19}' action='set' />

<assign value='source.{SCH:11.4}' property='target.{PIDgrp(1).PV1:44}' action='set' />
<assign value='source.{RGSgrp(1).AIPgrp(1).AIP:3(1)}' property='target.{PIDgrp(1).PV1:7}' action='set' />

<assign value='source.{RGSgrp(1).RGS}' property='target.{RGSgrp(1).RGS}' action='set' />

<if condition='(source.{SCH:7.1}="Surgery")||(source.{SCH:7.1}="Surgery Rapid")' >
<true>
<foreach property='source.{RGSgrp(1).AISgrp()}' key='k3' >
<assign value='source.{RGSgrp(1).AISgrp(k3).AIS}' property='target.{RGSgrp(1).AISgrp(k3).AIS}' action='set' />
</foreach>
</true>
</if>

<if condition='source.{MSH:9.2}="S26"' >
<true>
<assign value='"NO SHOW"' property='target.{SCH:25.2}' action='set' />
</true>
</if>

<assign value='source.{RGSgrp(1).AIPgrp(1).AIP}' property='target.{RGSgrp(1).AIPgrp(1).AIP}' action='set' />
<assign value='source.{RGSgrp(1).AILgrp(1).AIL}' property='target.{RGSgrp(1).AILgrp(1).AIL}' action='set' />

<code>
<![CDATA[
    // Send Prefferd Language
    //  1. off OBX PREFERRED_LA
    //  2. Crosswalk PID-15.5 preferred text to alias
    //  3. send primary language PID-15.1
]]></code>

<assign value='""' property='tmplang' action='set' />
<foreach property='source.{PIDgrp(1).OBX()}' key='k4' >
<if condition='source.{PIDgrp(1).OBX(k4):3}="PREFERRED_LA"' >
<true>
<assign value='source.{PIDgrp(1).OBX(k4):5(1)}' property='tmplang' action='set' />
</true>
</if>
</foreach>

<if condition='tmplang=""' >
<true>
<assign value='""' property='wTableData' action='set' />
<assign value='""' property='wtableresult' action='set' />
<assign value='source.{PIDgrp(1).PID:15.5}' property='wTableKey' action='set' />
<assign value='..Lookup("T_Oberd_Language_Preferred",wTableKey)' property='wtableresult' action='set' />
<if condition='wtableresult=""' >
<true>
<assign value='source.{PIDgrp(1).PID:15.1}' property='tmplang' action='set' />
</true>
<false>
<assign value='wtableresult' property='tmplang' action='set' />
</false>
</if>
</true>
</if>

<assign value='tmplang' property='target.{PIDgrp(1).PID:15}' action='set' />

</transform>
}

}
