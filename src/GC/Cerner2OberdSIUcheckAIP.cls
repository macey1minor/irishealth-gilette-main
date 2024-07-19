Class GC.Cerner2OberdSIUcheckAIP Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:SIU_S12' targetDocType='231.Cerner:SIU_S12' create='copy' language='objectscript' >
<code>
<![CDATA[ 
	//  Last Updated: 02/25/2021 Al Johnson
	//  Last Updated in Prod: 03/03/2021 Al Johnson
	//  Create: 11/26/2019  Al Johnson
	//
	//  Description:  New Interface - SIU to Oberd
	//   Used to direct surveys for specific doctors and schedules
	//
	//  There are appointment groups which have multiple physicians
	//  Go thru all AIP segments checking for valid Oberd doc, if found set MSH-14 to YES
	//
	//  Appt Type Ortho Gait Lab - if no doctor add 60690^Georgiadis^Andrew^^^MD
	//   Handle above in GC.Cerner2OberdSIUGaitLab
	//  Remove decimal points on siu schedule id
	//
	//  Sending last valid doc (tabled) when checking AIP segments - not primary surgeon 8/21/2020 SD-52572 Story CNR-20608 RFC SD-55071
	//  Change logic if surgery appointment - must be main surgeon on procedure
	//  Non surgery will take first valid doctor (multple docs outpatient not flagged i.e. Spasticity Clinic)
	//
	//  Change logice on Gait Labs - check for three appointment types
	//     1. Gait and Motion Analysis - Complete
	//     2. Gait and Motion Analysis - Physical Exam and Video
	//     3. Gait and Motion Analysis - Video
	//  Update using dummy provider ID# 99, first name "Doctor", last name "Gait Lab" 12/07/2020 CNR-20874 RFC SD-66890
	//
	//  Change logice on Gait Labs - appointment types  1/18/2021 CE-1790 RFC SD-69944
	//     1. Remove - Gait and Motion Analysis - Video
	//     2. Leave - Gait and Motion Analysis - Physical Exam and Video
	//     3. Leave - Gait and Motion Analysis - Complete
	//     4. Add - Gait and Motion Analysis - MD
	//     5. Add - Gait and Motion Analysis - Spasticity
	//
	//  Add 10 appointment type for Gait Labs (spoke with Becky ok to change from specific types to all starting Gait and Motion Analysis)
	//    Jira 2/25/2021 CNR-21232 Cert CNR-21234 Prod RFC SD-74627
	//      Gait and Motion Analysis - CMD Split Screen Video Plus Physical Exam	 	 
    //      Gait and Motion Analysis - Complex Mvmt Disorder Video	 	 
    //      Gait and Motion Analysis - Direct SetUp Activity Monitoring	 	 
    //      Gait and Motion Analysis - EMG only	 	 
    //      Gait and Motion Analysis - Fitness Monitoring	 	 
    //      Gait and Motion Analysis - Motion Lab O2 only	 	 
    //      Gait and Motion Analysis - Plantar Pressure	 	 
    //      Gait and Motion Analysis - Split Screen Video Plus O2	 	 
    //      Gait and Motion Analysis - Upper Extremity	 	 
    //      Gait and Motion Analysis - Video
]]></code>

<code>
<![CDATA[ 
    // initialize MSH-14 to "NO"
    // set to "YES" if AIP doc found or if Gait Lab
    // 39827^Healy^Michael^T^^MD^^^Doctor Nbr^Personnel^^^ORGANIZATION DOCTOR
]]></code>
<assign value='"NO"' property='target.{MSH:14}' action='set' />

<assign value='"Doctor Nbr"' property='holddoctype' action='set' />
<assign value='""' property='holddocid' action='set' />
<assign value='""' property='holddocname1' action='set' />
<assign value='""' property='holddocname2' action='set' />
<assign value='""' property='holddocname3' action='set' />
<assign value='""' property='holddocname4' action='set' />
<assign value='""' property='holddocname5' action='set' />
<assign value='"External Id"' property='holddoctype' action='set' />
<assign value='""' property='holddocid' action='set' />
<assign value='""' property='holddocname1' action='set' />
<assign value='""' property='holddocname2' action='set' />
<assign value='""' property='holddocname3' action='set' />
<assign value='""' property='holddocname4' action='set' />
<assign value='""' property='holddocname5' action='set' />

<code>
<![CDATA[ 
    // Oberd can only accept one doc
    // Surgery appts only send main surgeon - if multiple procedures send 1st valid main surgeon
    // Not Surgery - send first valid doctor
]]></code>
<foreach property='source.{RGSgrp(1).AIPgrp()}' key='k1' >
<if condition='holddocid=""' >
<true>
<foreach property='source.{RGSgrp(1).AIPgrp(k1).AIP:3()}' key='k2' >
<if condition='source.{RGSgrp(1).AIPgrp(k1).AIP:3(k2).9}="Doctor Nbr"' >
<true>
<if condition='(source.{SCH:7.1}="Surgery")||(source.{SCH:7.1}="Surgery Rapid")' >
<true>
<if condition='source.{RGSgrp(1).AIPgrp(k1).AIP:4.1}="Surgeon"' >
<true>
<assign value='""' property='wTableData' action='set' />
<assign value='""' property='wtableresult' action='set' />
<assign value='source.{RGSgrp(1).AIPgrp(k1).AIP:3(k2).1}' property='wTableKey' action='set' />
<assign value='..Lookup("T_Oberd_SIUdocs",wTableKey)' property='wtableresult' action='set' />
<if condition='wtableresult=""' >
<false>
<code>
<![CDATA[ 
    // table entry found - change AIP in msg and update MSH
    //  only change AIP if first valid doc found
]]></code>
<assign value='source.{RGSgrp(1).AIPgrp(k1).AIP:3(k2).1}' property='holddocid' action='set' />
<assign value='source.{RGSgrp(1).AIPgrp(k1).AIP:3(k2).2}' property='holddocname1' action='set' />
<assign value='source.{RGSgrp(1).AIPgrp(k1).AIP:3(k2).3}' property='holddocname2' action='set' />
<assign value='source.{RGSgrp(1).AIPgrp(k1).AIP:3(k2).4}' property='holddocname3' action='set' />
<assign value='source.{RGSgrp(1).AIPgrp(k1).AIP:3(k2).5}' property='holddocname4' action='set' />
<assign value='source.{RGSgrp(1).AIPgrp(k1).AIP:3(k2).6}' property='holddocname5' action='set' />
<assign value='"YES"' property='target.{MSH:14}' action='set' />
</false>
</if>
</true>
</if>
</true>
<false>
<assign value='""' property='wTableData' action='set' />
<assign value='""' property='wtableresult' action='set' />
<assign value='source.{RGSgrp(1).AIPgrp(k1).AIP:3(k2).1}' property='wTableKey' action='set' />
<assign value='..Lookup("T_Oberd_SIUdocs",wTableKey)' property='wtableresult' action='set' />
<if condition='wtableresult=""' >
<false>
<code>
<![CDATA[ 
    // table entry found - change AIP in msg and update MSH
    //  only change AIP if first valid doc found
]]></code>
<assign value='source.{RGSgrp(1).AIPgrp(k1).AIP:3(k2).1}' property='holddocid' action='set' />
<assign value='source.{RGSgrp(1).AIPgrp(k1).AIP:3(k2).2}' property='holddocname1' action='set' />
<assign value='source.{RGSgrp(1).AIPgrp(k1).AIP:3(k2).3}' property='holddocname2' action='set' />
<assign value='source.{RGSgrp(1).AIPgrp(k1).AIP:3(k2).4}' property='holddocname3' action='set' />
<assign value='source.{RGSgrp(1).AIPgrp(k1).AIP:3(k2).5}' property='holddocname4' action='set' />
<assign value='source.{RGSgrp(1).AIPgrp(k1).AIP:3(k2).6}' property='holddocname5' action='set' />
<assign value='"YES"' property='target.{MSH:14}' action='set' />
</false>
</if>
</false>
</if>
</true>
</if>
</foreach>
</true>
</if>
</foreach>

<foreach property='target.{RGSgrp(1).AIPgrp()}' key='k3' >
<assign value='' property='target.{RGSgrp(1).AIPgrp(k3)}' action='remove' />
</foreach>

<if condition='holddocid=""' >
<false>
<assign value='"1"' property='target.{RGSgrp(1).AIPgrp(1).AIP:1}' action='set' />
<assign value='holddocid' property='target.{RGSgrp(1).AIPgrp(1).AIP:3.1}' action='set' />
<assign value='holddocname1' property='target.{RGSgrp(1).AIPgrp(1).AIP:3.2}' action='set' />
<assign value='holddocname2' property='target.{RGSgrp(1).AIPgrp(1).AIP:3.3}' action='set' />
<assign value='holddocname3' property='target.{RGSgrp(1).AIPgrp(1).AIP:3.4}' action='set' />
<assign value='holddocname4' property='target.{RGSgrp(1).AIPgrp(1).AIP:3.5}' action='set' />
<assign value='holddocname5' property='target.{RGSgrp(1).AIPgrp(1).AIP:3.6}' action='set' />
</false>
</if>

<code>
<![CDATA[ 
    // SIU is for GaitLab and does not have valid doc
    // Add 60690^Georgiadis^Andrew^^^MD
    // <assign value='source.{RGSgrp(1).AIPgrp(1).AIP}' property='target.{RGSgrp(1).AIPgrp(1).AIP}' action='set' />
    // 12/7/2020 CNR-20874 send dummy doc on these 3 (do not send 60690)
    //   1. Gait and Motion Analysis - Complete
	//   2. Gait and Motion Analysis - Physical Exam and Video
	//   3. Gait and Motion Analysis - Video
	//  Update using dummy provider ID# 99, first name "Doctor", last name "Gait Lab" 12/07/2020 CNR-20874
	//
	//  2/25/2021 CNR-21232  (Jira has 10 new types, ok to use starts with per Becky)
	//  Update change from specific appointment value to starting with Gait and Motion Analysis
	//  orig <if condition='source.{SCH:7.1}="Gait and Motion Analysis - Complete"' > then next if on false condition
]]></code>
<assign value='"99^Gait Lab^Doctor^^^MD"' property='tmpdocid' action='set' />
<assign value='source.{SCH:7.1}' property='tempapptreason' action='set' />
<if condition='(..StartsWith(tempapptreason,"Gait and Motion Analysis -"))' >
<true>
<assign value='tmpdocid' property='target.{PIDgrp(1).PV1:7}' action='set' />
<assign value='tmpdocid' property='target.{RGSgrp(1).AIPgrp(1).AIP:3(1)}' action='set' />
<assign value='"1"' property='target.{RGSgrp(1).AIPgrp(1).AIP:1}' action='set' />
<assign value='"YES"' property='target.{MSH:14}' action='set' />
</true>
</if>

</transform>
}

}
