Class GC.Cerner2RegLabBkrSub Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ADT_A01' targetDocType='231.Cerner:ADT_A01' create='existing' language='objectscript' >
<code>
<![CDATA[ 
    //  Last Updated 01/25/2022 Al Johnson
	//  Last Updated in Prod: 03/13/2022 Al Johnson
	//  Create: 07/16/2018  Al Johnson
	//  Copied from GC.Cerner2RegLabsub 
	//  Description:  ADT Subroutine for Epic Beaker Lab
	//  (orignal - ) logic either Cerner alias or Cerner modobject
	//   changed from new to copy - include guarantor, insurance
	//   remove z segments
	//
	// Changed the transform create to "EXISTING"
	//  Then works from dtl - but does not work on individual test
	//
	// Created:  Started with copy of Cerner2RegLabSub  
	//  Description
	//    05/29/14 Only send 1st race code in PID-10  - ALJ
	// convert all PID chars to CAPS set PID:2.1 to C and prefix MRN with G
	// set PID:3.2 and 3.3 to 1 - set PID:3.4 to 2
	// clear PID:4 PID:9 and PV1_10
	// remove PV1:10 Hosp Serv Code
    // Inpatient if hosp service code is 0IP or 0ss or current unit is 0NU,0AU,0RU,0OSU,0OSE,0OSW,00IC,0ND or 07W
	// set PV1_2 to A and PV1_18 to N for inpatient other wise
	// set PV1_2 to O PV1_18 to S PV1_3 to GILL for outpatient 
	// Rooms Add Prefix of C if starts with 4, Prefix of G if starts with 7
	// Prefix Room with 0
	// Translate both Assigned and Previous Patient Location
	// 0AIM to GAIM; 0WR to GSDS; 07W to G7W; and 0PAN,0PAC,0OR,REG,REGS all to GOR
	// If 4OP then set Assigned Patient Location to GLSH
	//   01/20/17 Lifetime use GLSH, Phalen 2nd floor use GLSH
	// If 0SDS then set Assigned Patient Location to GSDS
	// Coding to send Regions Company account as account number for XCOM
    //           if PV1:14 = 10 send GPHS in PV1:3
	// If PV1:10 is XCOM and Guarantor Name contains :  move PID:18 to PID:3.2
	// Take data after : in GT1:3 and move to PID:18
	// If XEH then set PID:18 to C828 and move PID:18 to PID:3.2
	// Send patient location for GPHS Gillette Pediatric Home service *********
	// If PV1:14 is 10 than set PV1:3 to GPHS
	//
	//  PV1-2 must be IP, OP, ER, or OS per Todd Sommer - Regions 11/21/2016
	//  PV1-3.1 or PV1-6.1 GCSH - send GOR  02/15/2017
	//  PV1-3.1 or PV1-6.1 GCSH Main OR - send GOR  02/17/2017
	//  PV1-3.1 or PV1-6.1 PACU - send GOR  02/17/2017
	//  PV1-3.1 or PV1-6.1 GCSH Periop - send GOR  02/17/2017
	//  PV1-8 Referring Doc 11845887^Conversion^BlankProvider - remove 02/17/2017
	//  PV1-8 Add leading E to referring doctor number - 03/08/2017
	//   GOR unit needs GOR99 for room GOR^GOR99 - 03/27/2017
	//
	//  Remove 'E' prefix on PV1-7, PV1-8, PV1-17
	//
	//  Send actual event for Epic Beaker - Cerner Sunquest sending A28 on update
	//  Change back if EVN different
	//  Do Not change PV1-2 from I to IP for inpatient
	//  Do Not change PV1-2 from O to OP
	//
	//  Prefix GT1-2 person-id with 'G' 
	//
	//  Cerner Modobject changes MSH on A06/A07 - change back based on EVN - 08/30/2018
	//  Cerner Modobject changes MSH to A11 on A23 - change EVN from A23 to A11 - 08/30/2018
	//
	//  Send Observation as Inpatient 9/18/2018
	//
	//    Check for swing bed - change unit - table T_Swingbed_Lab
	//
	//  Send Observation and Outpatient in a Bed (A04 -> A01 and A06 -> A08) - 11/20/2018 (not chged yet)
	//
	//  Pass thru PV1-18 patient types from Cerner 12/12/2018
	//
    //   Ensure Regions receives HNA500 for ADT in MSH-4 - 1/21/2019
    //
    //  Send Day Surgery and Sleep Study (A04 -> A01) - 03/29/2019
    //
    //  Remove the "G" prefix on IN1-49 - 4/5/2019
    //  Remove the "G" prefix on IN2-25 - 4/5/2019
    //
    //  Infusion Therapy - leave as A04 -5/9/2019
    //  Change PV1-18 to InfusionTherapy so outpatient ADT can be sent to Regions - 5/9/2019
    //
    //  SameDaySurgery patient checked in for Observation being sent to Regions as A07 Inpatient to Outpatient - 5/29/2019
    //    This is because of EVN segment - in this case send as A08 update - 5/29/2019
    //
    //  Updated POC system (Glucomoters) in Regions needs outpatient GILL etc in PV1-3.4 8/17/2021 CNR-22075 RFC SD-94409
    //
    //  POC system does not process transfer correctly, creates second reg if diff facility in PV1-3.4
    //  Change to always send GCH Regions Beaker does not process PV1-3.4 so ok with them SD-98366 RFC SD-101391
    //
    //  New Patient Type "Overnight Outpatient" send as A01 and Inpatient CNR-22738 RFC SD-118497
    //
]]></code>
<assign value='source.{MSH}' property='target.{MSH}' action='set' />
<assign value='"2.3"' property='target.{MSH:VersionID}' action='set' />
<assign value='"HNA500"' property='target.{MSH:4}' action='set' />
<assign value='"Beaker"' property='target.{MSH:5}' action='set' />
<assign value='"RLAB"' property='target.{MSH:6}' action='set' />
<assign value='"Cerner2RegLabBkrSub"' property='target.{MSH:16}' action='set' />
<assign value='' property='target.{EVN}' action='remove' />
<assign value='source.{EVN:1}' property='target.{EVN:1}' action='set' />
<assign value='source.{EVN:2}' property='target.{EVN:2}' action='set' />
<assign value='source.{EVN:3}' property='target.{EVN:3}' action='set' />
<assign value='source.{EVN:4}' property='target.{EVN:4}' action='set' />
<assign value='source.{EVN:5(1).1}' property='target.{EVN:5(1).1}' action='set' />
<assign value='source.{EVN:5(1).2}' property='target.{EVN:5(1).2}' action='set' />
<assign value='source.{EVN:5(1).3}' property='target.{EVN:5(1).3}' action='set' />
<assign value='source.{EVN:6}' property='target.{EVN:6}' action='set' />
<assign value='source.{PID}' property='target.{PID}' action='set' />
<assign value='source.{PV1}' property='target.{PV1}' action='set' />
<assign value='' property='target.{PID:9}' action='remove' />
<assign value='""' property='target.{PID:10}' action='set' />
<assign value='source.{PID:10(1)}' property='target.{PID:10}' action='set' />
<assign value='' property='target.{PV1:HospitalService}' action='remove' />

<assign value='' property='target.{ZPI}' action='remove' />
<assign value='' property='target.{ZEI}' action='remove' />
<assign value='' property='target.{ZVI}' action='remove' />
<assign value='' property='target.{ZBE}' action='remove' />
<assign value='' property='target.{ZFP}' action='remove' />
<assign value='' property='target.{ZVF}' action='remove' />
<assign value='' property='target.{ZFM}' action='remove' />
<assign value='' property='target.{ZFD}' action='remove' />
<assign value='' property='target.{ZAC}' action='remove' />

<code>
<![CDATA[ 
	// Cerner for Sunquest changing to A28 - put back to original for Epic Beaker 8/08/2018
]]></code>
<if condition='(source.{MSH:9.2}="A28")' >
<true>
<if condition='(source.{EVN:EventTypeCode}="")' >
<false>
<assign value='source.{EVN:EventTypeCode}' property='target.{MSH:9.2}' action='set' />
</false>
</if>
</true>
</if>

<code>
<![CDATA[ 
	// Change Observation and Outpatient In a Bed A04 to A01 for Epic Beaker 11/20/2018
	// Send Day Surgery and Sleep Study (A04 -> A01) - 03/29/2019
	// Infusion Therapy being sent as Outpatient In a Bed - see logic below nested if - 5/9/2019
	// Change Overnight Outpatient A04 to A01 - 1/25/2022
]]></code>
<if condition='(source.{EVN:EventTypeCode}="A04")' >
<true>
<if condition='(source.{PV1:18}="Observation")||(source.{PV1:18}="Outpatient in a Bed")' >
<true>
<assign value='"A01"' property='target.{MSH:9.2}' action='set' />
<assign value='"A01"' property='target.{EVN:EventTypeCode}' action='set' />
</true>
</if>
<if condition='(source.{PV1:18}="Day Surgery")||(source.{PV1:18}="Sleep Study")' >
<true>
<assign value='"A01"' property='target.{MSH:9.2}' action='set' />
<assign value='"A01"' property='target.{EVN:EventTypeCode}' action='set' />
</true>
</if>
<if condition='(source.{PV1:18}="Overnight Outpatient")' >
<true>
<assign value='"A01"' property='target.{MSH:9.2}' action='set' />
<assign value='"A01"' property='target.{EVN:EventTypeCode}' action='set' />
</true>
</if>
</true>
</if>

<code>
<![CDATA[ 
	// Infusion Therapy being sent as Outpatient In a Bed - leave as A04 - 5/9/2019
	// Infusion Therapy change PV1-18 for identification - 5/9/2019
]]></code>
<if condition='source.{PV1:3.1}="Infusion Therapy"' >
<true>
<assign value='"InfusionTherapy"' property='target.{PV1:18}' action='set' />
<if condition='source.{EVN:EventTypeCode}="A04"' >
<true>
<assign value='"A04"' property='target.{MSH:9.2}' action='set' />
<assign value='"A04"' property='target.{EVN:EventTypeCode}' action='set' />
</true>
</if>
</true>
</if>

<code>
<![CDATA[ 
	// Cerner for Sunquest changing A06/A07 to A01/A04 - put back to original for Epic Beaker 8/30/2018
	//  A06 outpatient to inpatient - change to A08, A04 changed to A01 on reg 11/20/2018
	// <if condition='(source.{EVN:EventTypeCode}="A06" || (source.{EVN:EventTypeCode}="A07"))' >
	//
	//  A07 change to A08 for Observation, Outpatient in a Bed, Day Surgery or Sleep Study - 5/29/2019
	//  A07 logic add Overnight Outpatient - 1/25/2022
]]></code>
<if condition='(source.{EVN:EventTypeCode}="A06")' >
<true>
<assign value='"A08"' property='target.{MSH:9.2}' action='set' />
<assign value='"A08"' property='target.{EVN:EventTypeCode}' action='set' />
</true>
<false>
<if condition='(source.{EVN:EventTypeCode}="A07")' >
<true>
<if condition='(source.{PV1:18}="Observation")||(source.{PV1:18}="Outpatient in a Bed")' >
<true>
<assign value='"A08"' property='target.{MSH:9.2}' action='set' />
<assign value='"A08"' property='target.{EVN:EventTypeCode}' action='set' />
</true>
<false>
<if condition='(source.{PV1:18}="Day Surgery")||(source.{PV1:18}="Sleep Study")' >
<true>
<assign value='"A08"' property='target.{MSH:9.2}' action='set' />
<assign value='"A08"' property='target.{EVN:EventTypeCode}' action='set' />
</true>
<false>
<if condition='(source.{PV1:18}="Overnight Outpatient")' >
<true>
<assign value='"A08"' property='target.{MSH:9.2}' action='set' />
<assign value='"A08"' property='target.{EVN:EventTypeCode}' action='set' />
</true>
<false>
<assign value='source.{EVN:EventTypeCode}' property='target.{MSH:9.2}' action='set' />
</false>
</if>
</false>
</if>
</false>
</if>
</true>
</if>
</false>
</if>

<code>
<![CDATA[ 
	// Cerner for Sunquest changing to A23 to A11 - change EVN to A11 for Epic Beaker 8/30/2018
]]></code>
<if condition='(source.{MSH:9.2}="A11")' >
<true>
<assign value='"A11"' property='target.{EVN:EventTypeCode}' action='set' />
</true>
</if>

    
<foreach property='target.{ZKI()}' key='k1' >
<assign value='' property='target.{ZKI(k1)}' action='remove' />
</foreach>

<foreach property='target.{AL1grp()}' key='k1' >
<assign value='' property='target.{AL1grp(k1).ZAL}' action='remove' />
</foreach>

<foreach property='target.{ZQA()}' key='k1' >
<assign value='' property='target.{ZQA(k1)}' action='remove' />
</foreach>

<code>
<![CDATA[
    // <assign value='target.{IN1grp(k1).IN2:25(1).1}' property='holdpayerid' action='set' />
    // <assign value='"G"_holdpayerid' property='holdpayerid1' action='set' />
    // <assign value='holdpayerid1' property='target.{IN1grp(k1).IN2:25}' action='set' />
    // <assign value='holdpayerid1' property='target.{IN1grp(k1).IN1:49}' action='set' />
 ]]></code>

<foreach property='target.{IN1grp()}' key='k1' >
<assign value='' property='target.{IN1grp(k1).ZNI}' action='remove' />
<assign value='' property='target.{IN1grp(k1).ZN2}' action='remove' />
<foreach property='target.{IN1grp(k1).IN3grp()}' key='k2' >
<assign value='' property='target.{IN1grp(k1).IN3grp(k2).ZN3}' action='remove' />
</foreach>
</foreach>

<code>
<![CDATA[ 
	// *******************   IP vs OP Location Logic ***********************************************
	// If hosp service code is 0IP or 0ss or current unit is 0NU,0AU,0RU,0OSU,0OSE,0OSW,00IC,0ND or 07W
	// set PV1_2 to A and PV1_18 to N for inpatient other wise - pass thru 12/12/2018
	// set PV1_2 to O PV1_18 to S PV1_3 to GILL for outpatient - pass thru 12/12/2018
	//  PV1-3.1 or PV1-6.1 GCSH - send GOR  02/15/2017
	//  PV1-3.1 or PV1-6.1 GCSH Main OR - send GOR  02/17/2017
	//  PV1-3.1 or PV1-6.1 PACU - send GOR  02/17/2017
	//  PV1-3.1 or PV1-6.1 GCSH Periop - send GOR  02/17/2017
	//   <assign value='"N"' property='target.{PV1:PatientType}' action='set' />
]]></code>
<if condition='..In(source.{PV1:18},"Observation,PreObservation,Overnight Outpatient,PreOvernight Outpatient")' >
<true>
<assign value='"I"' property='target.{PV1:PatientClass}' action='set' />
</true>
<false>
<if condition='..In(source.{PV1:18},"Inpatient,PreInpatient,Sleep Study,PreSleepStudy") || ..In(source.{PV1:3.1},"0NU,0AU,0RU,0OSU,0OSE,0OSW,0IC,0ND,G7W")' >
<true>
<assign value='"I"' property='target.{PV1:PatientClass}' action='set' />
</true>
<false>
<if condition='..In(source.{PV1:3.1},"GCSH,GCSH Main OR,PACU,GCSH Periop")' >
<true>
<assign value='"I"' property='target.{PV1:PatientClass}' action='set' />
<assign value='""' property='target.{PV1:AssignedPatientLocation}' action='clear' />
<assign value='"GOR"' property='target.{PV1:AssignedPatientLocation.pointofcare}' action='set' />
<assign value='"GOR99"' property='target.{PV1:AssignedPatientLocation.room}' action='set' />
<assign value='"GCH"' property='target.{PV1:AssignedPatientLocation.facilityHD}' action='set' />
</true>
<false>
<assign value='"O"' property='target.{PV1:PatientClass}' action='set' />
<assign value='""' property='target.{PV1:AssignedPatientLocation}' action='clear' />
<assign value='"GILL"' property='target.{PV1:AssignedPatientLocation.pointofcare}' action='set' />
<assign value='"GCH"' property='target.{PV1:AssignedPatientLocation.facilityHD}' action='set' />
<assign value='""' property='target.{PV1:PriorPatientLocation}' action='set' />
</false>
</if>
</false>
</if>
</false>
</if>
<if condition='..In(source.{PV1:3.1},"GCSH,GCSH Main OR,PACU,GCSH Periop")' >
<true>
<assign value='"I"' property='target.{PV1:PatientClass}' action='set' />
<assign value='""' property='target.{PV1:AssignedPatientLocation}' action='clear' />
<assign value='"GOR"' property='target.{PV1:AssignedPatientLocation.pointofcare}' action='set' />
<assign value='"GOR99"' property='target.{PV1:AssignedPatientLocation.room}' action='set' />
<assign value='"GCH"' property='target.{PV1:AssignedPatientLocation.facilityHD}' action='set' />
</true>
</if>
<if condition='..In(source.{PV1:6.1},"GCSH,GCSH Main OR,PACU,GCSH Periop")' >
<true>
<assign value='"I"' property='target.{PV1:PatientClass}' action='set' />
<assign value='""' property='target.{PV1:PriorPatientLocation}' action='clear' />
<assign value='"GOR"' property='target.{PV1:PriorPatientLocation.pointofcare}' action='set' />
<assign value='"GOR99"' property='target.{PV1:PriorPatientLocation.room}' action='set' />
<assign value='"GCH"' property='target.{PV1:PriorPatientLocation.facilityHD}' action='set' />
</true>
</if>
<if condition='source.{PV1:8(1).1}="11845887"' >
<true>
<assign value='""' property='target.{PV1:8(1)}' action='set' />
</true>
</if>

<assign value='source.{PV1:7.1}' property='tempdocid' action='set' />
<assign value='$Translate(tempdocid,"E","")' property='tempdocid2' action='set' />
<assign value='tempdocid2' property='target.{PV1:7.1}' action='set' />
<assign value='source.{PV1:8.1}' property='tempdocid' action='set' />
<assign value='$Translate(tempdocid,"E","")' property='tempdocid2' action='set' />
<assign value='tempdocid2' property='target.{PV1:8.1}' action='set' />
<assign value='source.{PV1:17.1}' property='tempdocid' action='set' />
<assign value='$Translate(tempdocid,"E","")' property='tempdocid2' action='set' />
<assign value='tempdocid2' property='target.{PV1:17.1}' action='set' />

<code>
<![CDATA[ 
	// *******************   Other Location Logic ***********************************
	// Prefix Room with 0
	// Translate both Assigned and Previous Patient Location
	// 0AIM to GAIM; 0WR to GSDS; 07W to G7W; and 0PAN,0PAC,0OR,REG,REGS all to GOR
	// 
]]></code>
<if condition='..Contains(source.{PV1:AssignedPatientLocation.pointofcare},"0AIM")' >
<true>
<assign value='""' property='target.{PV1:AssignedPatientLocation}' action='set' />
<assign value='"GAIM"' property='target.{PV1:AssignedPatientLocation.pointofcare}' action='set' />
</true>
</if>
<if condition='..Contains(source.{PV1:AssignedPatientLocation.pointofcare},"0WR") || ..In(source.{PV1:18},"Day Surgery,PreDaySurgery")' >
<true>
<assign value='""' property='target.{PV1:AssignedPatientLocation}' action='set' />
<assign value='"GSDS"' property='target.{PV1:AssignedPatientLocation.pointofcare}' action='set' />
<assign value='"GCH"' property='target.{PV1:AssignedPatientLocation.facilityHD}' action='set' />
</true>
</if>
<if condition='(source.{PV1:AssignedPatientLocation.pointofcare} = "07W")' >
<true>
<assign value='"G7W"' property='target.{PV1:AssignedPatientLocation.pointofcare}' action='set' />
</true>
</if>
<if condition='..In(source.{PV1:AssignedPatientLocation.pointofcare},"0PAN,0PAC,0OR,REG,REGS")' >
<true>
<assign value='""' property='target.{PV1:AssignedPatientLocation}' action='set' />
<assign value='"GOR"' property='target.{PV1:AssignedPatientLocation.pointofcare}' action='set' />
<assign value='"GCH"' property='target.{PV1:AssignedPatientLocation.facilityHD}' action='set' />
</true>
</if>
<code>
<![CDATA[ 
	// *******************   Prior Location Logic **********************************************************
]]></code>
<if condition='..Contains(source.{PV1:PriorPatientLocation.pointofcare},"0AIM")' >
<true>
<assign value='""' property='target.{PV1:PriorPatientLocation}' action='set' />
<assign value='"GAIM"' property='target.{PV1:PriorPatientLocation.pointofcare}' action='set' />
</true>
</if>
<if condition='..Contains(source.{PV1:PriorPatientLocation.pointofcare},"0WR")' >
<true>
<assign value='""' property='target.{PV1:PriorPatientLocation}' action='set' />
<assign value='"GSDS"' property='target.{PV1:PriorPatientLocation.pointofcare}' action='set' />
<assign value='"GCH"' property='target.{PV1:PriorPatientLocation.facilityHD}' action='set' />
</true>
</if>
<if condition='(source.{PV1:PriorPatientLocation.pointofcare} = "07W")' >
<true>
<assign value='"G7W"' property='target.{PV1:PriorPatientLocation.pointofcare}' action='set' />
</true>
</if>
<if condition='..In(source.{PV1:PriorPatientLocation.pointofcare},"0PAN,0PAC,0OR,REG,REGS")' >
<true>
<assign value='""' property='target.{PV1:PriorPatientLocation}' action='set' />
<assign value='"GOR"' property='target.{PV1:PriorPatientLocation.pointofcare}' action='set' />
<assign value='"GCH"' property='target.{PV1:PriorPatientLocation.facilityHD}' action='set' />
</true>
</if>
<code>
<![CDATA[ 
	// *******************   Hosptial Service Logic *******************************
	// If 4OP then set Assigned Patient Location to GLSH
	//   01/20/17 Lifetime use GLSH, Phalen 2nd floor use GLSH
	// If 0SDS then set Assigned Patient Location to GSDS
	// If XEH then set PID:18 to C828 and move PID:18 to PID:3.2
]]></code>
<if condition='..In(source.{PV1:AssignedPatientLocation.facilityHD},"LTC")' >
<true>
<if condition='..In(source.{PV1:18},"Recurring,PreRecurring")' >
<false>
<assign value='""' property='target.{PV1:AssignedPatientLocation}' action='clear' />
<assign value='"GLSH"' property='target.{PV1:AssignedPatientLocation.pointofcare}' action='set' />
<assign value='""' property='target.{PV1:PriorPatientLocation}' action='set' />
</false>
</if>
</true>
</if>
<if condition='..In(source.{PV1:AssignedPatientLocation.facilityHD},"PGC")' >
<true>
<if condition='..In(source.{PV1:18},"Recurring,PreRecurring")' >
<false>
<assign value='""' property='target.{PV1:AssignedPatientLocation}' action='clear' />
<assign value='"GPSH"' property='target.{PV1:AssignedPatientLocation.pointofcare}' action='set' />
<assign value='""' property='target.{PV1:PriorPatientLocation}' action='set' />
</false>
</if>
</true>
</if>
<if condition='..Contains(source.{PV1:HospitalService},"XEH")' >
<true>
<assign value='source.{PID:PatientAccountNumber}' property='target.{PID:PatientIdentifierList(1).checkdigit}' action='set' />
<assign value='"C828"' property='target.{PID:PatientAccountNumber}' action='set' />
</true>
</if>
<if condition='..Contains(source.{PV1:HospitalService},"0SDS") || ..In(source.{PV1:18},"Day Surgery,PreDaySurgery")' >
<true>
<assign value='""' property='target.{PV1:AssignedPatientLocation}' action='set' />
<assign value='"GSDS"' property='target.{PV1:AssignedPatientLocation.pointofcare}' action='set' />
<assign value='"GCH"' property='target.{PV1:AssignedPatientLocation.facilityHD}' action='set' />
</true>
</if>
<code>
<![CDATA[ 
	// **********  Special Coding to send patient location for GPHS Gillette Pediatric Home service *********
	// If PV1:14 is 10 than set PV1:3 to GPHS
]]></code>
<if condition='source.{PV1:AdmitSource} = 10' >
<true>
<assign value='""' property='target.{PV1:AssignedPatientLocation}' action='clear' />
<assign value='"GPHS"' property='target.{PV1:AssignedPatientLocation.pointofcare}' action='set' />
<assign value='"GCH"' property='target.{PV1:AssignedPatientLocation.facilityHD}' action='set' />
<assign value='""' property='target.{PV1:PriorPatientLocation}' action='set' />
</true>
</if>
<code>
<![CDATA[ 
	// ********** Coding to send Company Account as account for XCOM Hosp Service Codes **********
	// If PV1:10 is XCOM and Guarantor Name contains :  move PID:18 to PID:3.2
	// Take data after : in GT1:3 and move to PID:18
]]></code>
<if condition='(..Contains(source.{PV1:HospitalService},"XCOM")) &amp; (..Contains(source.{GT1(1):3},":"))' >
<true>
<assign value='source.{PID:PatientAccountNumber}' property='target.{PID:PatientIDInternalID(1).Checkdigit}' action='set' />
<assign value='$P(source.{GT1(1):3},":",2)' property='target.{PID:PatientAccountNumber}' action='set' />
</true>
</if>

<code>
<![CDATA[ 
    //  08/20/2018 - prefix guarantor (person id) with 'G'
	]]></code>	
<if condition='target.{GT1(1):GuarantorNumber(1).ID}=""' >
<false>
<assign value='target.{GT1(1):GuarantorNumber(1).ID}' property='holdpersonid' action='set' />
<assign value='"G"_holdpersonid' property='holdpersonid1' action='set' />
<assign value='holdpersonid1' property='target.{GT1(1):GuarantorNumber(1).ID}' action='set' />
</false>
</if>

<code>
<![CDATA[ 
	// ********** convert all PID chars to CAPS
]]></code>
<assign value='$ZCONVERT(target.{PID},"U" )' property='target.{PID}' action='set' />
<assign value='' property='target.{PV1:HospitalService}' action='remove' />
<assign value='' property='target.{PV1:52}' action='remove' />

<code>
<![CDATA[ 
    //  09/25/2018 - check location for swingbed
    //
	//  Read table T_Swingbed_Lab - unit^room^bed is key to table
	//  If found, replace unit number
	//  Check PV1-3 location and PV1-6 prior location
	]]></code>

<assign value='""' property='wTableKey' action='set' />
<assign value='""' property='temproom' action='set' />
<assign value='""' property='tempbed' action='set' />
<assign value='source.{PV1:AssignedPatientLocation.pointofcare}' property='tempunit' action='set' />
<assign value='source.{PV1:AssignedPatientLocation.room}' property='temproom' action='set' />
<assign value='source.{PV1:AssignedPatientLocation.bed}' property='tempbed' action='set' />
<assign value='tempunit_"^"_temproom_"^"_tempbed' property='wTableKey' action='set' />

<assign value='""' property='wTableData' action='set' />
<assign value='""' property='wtableresult' action='set' />
<assign value='..Lookup("T_Swingbed_Lab",wTableKey)' property='wtableresult' action='set' />
<if condition='wtableresult=""' >
<false>
<assign value='wtableresult' property='target.{PV1:AssignedPatientLocation.pointofcare}' action='set' />
</false>
</if>

<assign value='""' property='wTableKey' action='set' />
<assign value='""' property='temproom' action='set' />
<assign value='""' property='tempbed' action='set' />
<assign value='source.{PV1:PriorPatientLocation.pointofcare}' property='tempunit' action='set' />
<assign value='source.{PV1:PriorPatientLocation.room}' property='temproom' action='set' />
<assign value='source.{PV1:PriorPatientLocation.bed}' property='tempbed' action='set' />
<assign value='tempunit_"^"_temproom_"^"_tempbed' property='wTableKey' action='set' />

<assign value='""' property='wTableData' action='set' />
<assign value='""' property='wtableresult' action='set' />
<assign value='..Lookup("T_Swingbed_Lab",wTableKey)' property='wtableresult' action='set' />
<if condition='wtableresult=""' >
<false>
<assign value='wtableresult' property='target.{PV1:PriorPatientLocation.pointofcare}' action='set' />
</false>
</if>

</transform>
}

}
