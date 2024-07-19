Class GC.Cerner2RegLabBkrORMsub Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ORM_O01' targetDocType='231.Cerner:ORM_O01' create='existing' language='objectscript' >
<code>
<![CDATA[ 
	//  Last Updated: 11/01/2019 Al Johnson
	//  Last Updated in Prod: 11/12/2019 Al Johnson
	//  Create: 07/16/2018  Al Johnson
	//  Copied from GC.Cerner2RegLabORMsub 
	//  Description:  Orders DTL Subroutine for Epic Beaker Lab
	//  (orignal - ) logic either Cerner alias or Cerner modobject
	//   original output schema 22.Reglab changed to 231.Cerner for Epic Beaker
	//   changed from new to copy
	//   remove z segments
	//
	// Changed the transform create to "EXISTING"
	//  Then works from dtl - but does not work on individual test
	//
	// convert all PID chars to CAPS
	//
	// original - set PID:2.1 to C and prefix MRN with G  (set in Cerner ModObject)
	// original - set PID:3.2 and 3.3 to 1 - set PID:3.4 to 2 (set in Cerner ModObject)
	// original - clear PID:4 PID:9 and PV1_10 (set in Cerner ModObject)
	// original - remove PV1:10 Hosp Serv Code (set in Cerner ModObject)
    // original - Inpatient if hosp service code is 0IP or 0ss or current unit is 0NU,0AU,0RU,0OSU,0OSE,0OSW,00IC,0ND or 07W
	// original - set PV1_2 to A and PV1_18 to N for inpatient other wise (set in Cerner ModObject)
	// original - set PV1_2 to O PV1_18 to S PV1_3 to GILL for outpatient (set in Cerner ModObject) 
	// original - Rooms Add Prefix of C if starts with 4, Prefix of G if starts with 7 (set in Cerner Aliasing)
	// original - Prefix Room with 0 (set in Cerner Aliasing)
	// 
	// Translate both Assigned and Previous Patient Location (set in Cerner ModObject) (set in Cerner ModObject)
	// 0AIM to GAIM; 0WR to GSDS; 07W to G7W; and 0PAN,0PAC,0OR,REG,REGS all to GOR
	// If 4OP then set Assigned Patient Location to GLSH
	//   01/20/17 send GLSH for Lifetime and GPSH for Phalen second floor
	// If 0SDS then set Assigned Patient Location to GSDS
	//
	// Coding to send Regions Company account as account number for XCOM
    //           if PV1:14 = 10 send GPHS in PV1:3
	// If PV1:10 is XCOM and Guarantor Name contains :  move PID:18 to PID:3.2
	// Take data after : in GT1:3 and move to PID:18
	// If XEH then set PID:18 to C828 and move PID:18 to PID:3.2
	//
	// Send patient location for GPHS Gillette Pediatric Home service *********
	// If PV1:14 is 10 than set PV1:3 to GPHS
	//
	//  PV1-2 must be IP, OP, ER, or OS per Todd Sommer - Regions 11/21/2016
	//  PV1-3.1 or PV1-6.1 GCSH - send GOR  02/15/2017
	//  PV1-3.1 or PV1-6.1 GCSH Main OR - send GOR  02/17/2017
	//  PV1-3.1 or PV1-6.1 PACU - send GOR  02/17/2017
	//  PV1-3.1 or PV1-6.1 GCSH Periop - send GOR  02/17/2017
	//  PV1-8 Referring Doc 11845887^Conversion^BlankProvider - remove 02/17/2017
	//
	//  Remove value from ORC-13 Point of Care - receiving LTC Cline and PGC Clinic 03/07/2017
	//  Add E to PV1-8 referring doctor - PV1-8 was not sent out of QCPR  03/07/2017
	//   GOR unit needs GOR99 for room GOR^GOR99 - 03/27/2017
	//
	//  OBR-27.6 = 'RO' Timing Priority = Routine and not cancel or discontinue
	//    If OBR-11 = "L"   set OBR-7 = ORC-9
	//    If OBR-11 Not = "L" set OBR-7 = ORC-15
	//
	//  Regions consolidating lab orders under one accession when within a certain time period
	//    not sure the time period, but thought 5 - 30 minutes (Sunquest Labs)
	//  Table ordering provider out of Cerner ORC-12, OBR-16, key is Cerner order number
	//  Read ORU from Regions and update to Cerner values
	//
	//  Remove 'E' prefix on PV1-7, PV1-8, PV1-17, ORC-12 and OBR-16
	//
	//  Remove duplicate DG1 DG1-6 = DONOTSEND
	//
	//  Send Observation as Inpatient
	//
	//    Check for swing bed - change unit - table T_Swingbed_Lab
	//
	//   Epic Beaker Orders only accepts ST, TX, NM, DT, RP in OBX-2
	//     Actual list accepted is larger, above list is Epic documentation
	//     Cerner says OBX-2 is a calculated value based on OBX-5 data
	//     Cerner is sending IS which is invalid.  Appears to come out when OBX-5 has a CD:####
	//     Change IS to ST in OBX-2
	//
	//   Do not populate OBR-7
	//
	//   Pass thru PV1-18 from Cerner - 12/12/2018
	//
	//   Ensure Regions receives HNA in MSH-4 - 1/9/2019
	//
	//   Remove carriage return line feed from notes segment "\.br\" - 4/03/2019
	//   PV1:3.1 copy from Sunquest - 22.Reglab schema defined as AssignedPatientLocation.pointofcareID
	//   Cerner 231 schema defined as AssignedPatientLocation.pointofcare  - removed ID from name - 4/04/2019
	//
	//   Remove the "G" prefix on IN1-49 - 4/5/2019
	//   Remove the "G" prefix on IN2-25 - 4/5/2019
	//
	//   Remove DG1 segments on ORM CA cancels and DC discontinues - 11/01/2019 Jira SD-22416
]]></code>
<code>
<![CDATA[ 
	// ******
	// <assign value='' property='target.{PV1:HospitalService}' action='remove' />
]]></code>
<assign value='"Cerner2RegORMBKRsub"' property='target.{MSH:16}' action='set' />
<assign value='"HNA"' property='target.{MSH:4}' action='set' />
<assign value='' property='target.{PID:9}' action='clear' />
<assign value='""' property='target.{PID:10}' action='set' />
<assign value='source.{PID:10(1)}' property='target.{PID:10}' action='set' />
<assign value='$ZCONVERT(target.{PID},"U" )' property='target.{PID}' action='set' />
<assign value='source.{ORCgrp(1).OBRgrp.OBR:16.1}' property='tempdocid' action='set' />
<assign value='$Translate(tempdocid,"E","")' property='tempdocid2' action='set' />
<assign value='tempdocid2' property='target.{ORCgrp(1).OBRgrp.OBR:16.1}' action='set' />
<assign value='source.{ORCgrp(1).ORC:12.1}' property='tempdocid' action='set' />
<assign value='$Translate(tempdocid,"E","")' property='tempdocid2' action='set' />
<assign value='tempdocid2' property='target.{ORCgrp(1).ORC:12.1}' action='set' />
<assign value='source.{PV1:7.1}' property='tempdocid' action='set' />
<assign value='$Translate(tempdocid,"E","")' property='tempdocid2' action='set' />
<assign value='tempdocid2' property='target.{PV1:7.1}' action='set' />
<assign value='source.{PV1:8.1}' property='tempdocid' action='set' />
<assign value='$Translate(tempdocid,"E","")' property='tempdocid2' action='set' />
<assign value='tempdocid2' property='target.{PV1:8.1}' action='set' />
<assign value='source.{PV1:17.1}' property='tempdocid' action='set' />
<assign value='$Translate(tempdocid,"E","")' property='tempdocid2' action='set' />
<assign value='tempdocid2' property='target.{PV1:17.1}' action='set' />

<assign value='' property='target.{ZPI}' action='remove' />
<assign value='' property='target.{ZEI}' action='remove' />
<assign value='' property='target.{ZVI}' action='remove' />

<code>
<![CDATA[ 
	// *******************   IP vs OP Location Logic ***********************************************
	//  <assign value='"N"' property='target.{PV1:PatientType}' action='set' />
]]></code>
<if condition='..In(source.{PV1:18},"Observation,PreObservation")' >
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
</true>
<false>
<assign value='"O"' property='target.{PV1:PatientClass}' action='set' />
<assign value='""' property='target.{PV1:AssignedPatientLocation}' action='clear' />
<assign value='"GILL"' property='target.{PV1:AssignedPatientLocation}' action='set' />
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
</true>
</if>
<if condition='..In(source.{PV1:6.1},"GCSH,GCSH Main OR,PACU,GCSH Periop")' >
<true>
<assign value='"I"' property='target.{PV1:PatientClass}' action='set' />
<assign value='""' property='target.{PV1:PriorPatientLocation}' action='clear' />
<assign value='"GOR"' property='target.{PV1:PriorPatientLocation.pointofcare}' action='set' />
<assign value='"GOR99"' property='target.{PV1:PriorPatientLocation.room}' action='set' />
</true>
</if>
<assign value='""' property='target.{ORCgrp(1).ORC:13}' action='set' />
<if condition='source.{PV1:8(1).1}="11845887"' >
<true>
<assign value='""' property='target.{PV1:8(1)}' action='set' />
</true>
</if>
<code>
<![CDATA[ 
	// *******************   Other Location Logic **********************************************************
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
<if condition='..Contains(source.{PV1:PriorPatientLocation.pointofcare},"0WR") || ..In(source.{PV1:18},"Day Surgery,PreDaySurgery")' >
<true>
<assign value='""' property='target.{PV1:PriorPatientLocation}' action='set' />
<assign value='"GSDS"' property='target.{PV1:PriorPatientLocation.pointofcare}' action='set' />
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
</true>
</if>
<code>
<![CDATA[ 
	// *******************   Hosptial Service Logic ************************************
]]></code>
<if condition='..In(source.{PV1:AssignedPatientLocation.facilityHD},"LTC")' >
<true>
<if condition='..In(source.{PV1:18},"Recurring,PreRecurring")' >
<false>
<assign value='""' property='target.{PV1:AssignedPatientLocation}' action='clear' />
<assign value='"GLSH"' property='target.{PV1:AssignedPatientLocation}' action='set' />
</false>
</if>
</true>
</if>
<if condition='..In(source.{PV1:AssignedPatientLocation.facilityHD},"PGC")' >
<true>
<if condition='..In(source.{PV1:18},"Recurring,PreRecurring")' >
<false>
<assign value='""' property='target.{PV1:AssignedPatientLocation}' action='clear' />
<assign value='"GPSH"' property='target.{PV1:AssignedPatientLocation}' action='set' />
</false>
</if>
</true>
</if>
<if condition='..Contains(source.{PV1:HospitalService},"XEH")' >
<true>
<assign value='source.{PID:PatientAccountNumber}' property='target.{PID:PatientIDInternalID(1).Checkdigit}' action='set' />
<assign value='"C828"' property='target.{PID:PatientAccountNumber}' action='set' />
</true>
</if>
<if condition='..Contains(source.{PV1:HospitalService},"0SDS")' >
<true>
<assign value='""' property='target.{PV1:AssignedPatientLocation}' action='set' />
<assign value='"GSDS"' property='target.{PV1:AssignedPatientLocation.pointofcare}' action='set' />
</true>
</if>
<code>
<![CDATA[ 
	// **********  Special Coding to send patient location for GPHS Gillette Pediatric Home service ***************
]]></code>
<if condition='source.{PV1:AdmitSource} = 10' >
<true>
<assign value='""' property='target.{PV1:AssignedPatientLocation}' action='clear' />
<assign value='"GPHS"' property='target.{PV1:AssignedPatientLocation.pointofcare}' action='set' />
<assign value='""' property='target.{PV1:PriorPatientLocation}' action='set' />
</true>
</if>
<code>
<![CDATA[ 
	// **********  Coding to send Region Company Code as account for XCOM Hosp Service Codes***************
	// **********  If value not found in global then send account number ********* 
]]></code>
<if condition='..Contains(source.{PV1:HospitalService},"XCOM") ' >
<true>
<assign value='""' property='RegCC' action='set' />
<assign value='source.{PID:PatientAccountNumber}' property='target.{PID:3(1).2}' action='set' />
<code>
<![CDATA[ 
  //		s RegCC = ##class(GCH.RegLab.ADTtbl).GetRegLabCAccount(source.GetValueAt("PID:18.1"))
]]></code>
<assign value='RegCC' property='target.{PID:PatientAccountNumber}' action='set' />
</true>
</if>
<code>
<![CDATA[ 
	// **********  Coding to send Region Company Code for LIO orders ***************
	//  <assign value='source.{PID:3(1).2}' property='target.{PID:18.1}' action='set' />
	]]></code>
<if condition='..Contains(source.{PID:3(1).2},"C") ' >
<true>
<assign value='source.{PID:PatientAccountNumber}' property='target.{PID:3(1).2}' action='set' />
</true>
</if>
<code>
<![CDATA[ 
	//  OBR-27.6 = 'RO' Timing Priority = Routine and not cancel or discontinue
	//    If OBR-11 = "L"   set OBR-7 = ORC-9
	//    If OBR-11 Not = "L" set OBR-7 = ORC-15
	]]></code>
	<code>
<![CDATA[
    // <if condition='target.{ORCgrp(1).OBRgrp.OBR:27.6}="RO"' >
    // <true>
    // <if condition='(target.{ORCgrp(1).ORC:1}="CA") || (target.{ORCgrp(1).ORC:1}="DC")' >
    // <false>
    // <if condition='(target.{ORCgrp(1).OBRgrp.OBR:11}="L")' >
    // <true>
    // <assign value='target.{ORCgrp(1).ORC:9.1}' property='target.{ORCgrp(1).OBRgrp.OBR:7}' action='set' />
    // </true>
    // <false>
    // <assign value='target.{ORCgrp(1).ORC:15.1}' property='target.{ORCgrp(1).OBRgrp.OBR:7}' action='set' />
    // </false>
    // </if>
    // </false>
    // </if>
    // </true>
    // </if>
    //
    //  <assign value='target.{IN1grp(k1).IN2:25(1).1}' property='holdpayerid' action='set' />
    //  <assign value='"G"_holdpayerid' property='holdpayerid1' action='set' />
    //  <assign value='holdpayerid1' property='target.{IN1grp(k1).IN2:25}' action='set' />
    //  <assign value='holdpayerid1' property='target.{IN1grp(k1).IN1:49}' action='set' />
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
	// Remove duplicate DG1 ICD9 to Order
	]]></code>
	
<foreach property='target.{ORCgrp(1).OBRgrp.DG1()}' key='k3' >
<if condition='target.{ORCgrp(1).OBRgrp.DG1(k3):DiagnosisType}="DONOTSEND"' >
<true>
<assign value='' property='target.{ORCgrp(1).OBRgrp.DG1(k3)}' action='remove' />
</true>
</if>
</foreach>

<code>
<![CDATA[
	// Remove DG1 on cancels and discontinues
	]]></code>
<if condition='(source.{ORCgrp(1).ORC:1}="CA")||(source.{ORCgrp(1).ORC:1}="DC")' >
<true>
<foreach property='target.{ORCgrp(1).OBRgrp.DG1()}' key='k6' >
<assign value='' property='target.{ORCgrp(1).OBRgrp.DG1(k6)}' action='remove' />
</foreach>
</true>
</if>

<code>
<![CDATA[
	// Remove carriage return from order notes
	]]></code>
	
<assign value='""' property='holdnote' action='set' />
<foreach property='target.{ORCgrp(1).OBRgrp.NTE()}' key='k4' >
<foreach property='target.{ORCgrp(1).OBRgrp.NTE(k4):3()}' key='k5' >
<assign value='target.{ORCgrp(1).OBRgrp.NTE(k4):3(k5)}' property='holdnote' action='set' />
<assign value='$REPLACE(holdnote,"\.br\"," ")' property='holdnote' action='set' />
<assign value='holdnote' property='target.{ORCgrp(1).OBRgrp.NTE(k4):3(k5)}' action='set' />
</foreach>
</foreach>

<code>
<![CDATA[ 
    //  11/22/2017 - table ordering provider
    //
	//  Read table T_RegionsLab_OrderingProvider - Cerner OrderNbr is key to table
	//  to delete specific entry - do ##class(Ens.Util.LookupTable).%RemoveValue(wTableName,wTableKey)
	//  add / update - do ##class(Ens.Util.LookupTable).%UpdateValue(wTableName,wTableKey,wTableData)
	//
	//  table entire field - id and name for result messages
	//   extract just id to check for change
	]]></code>
<assign value='source.{ORCgrp(1).ORC:2.1}' property='tempCernerOrder' action='set' />
<assign value='source.{ORCgrp(1).ORC:12}' property='tempORC12' action='set' />
<assign value='source.{ORCgrp(1).OBRgrp.OBR:16(1)}' property='tempOBR16' action='set' />
<assign value='source.{ORCgrp(1).ORC:12.1}' property='tempInORC12id' action='set' />
<assign value='source.{ORCgrp(1).OBRgrp.OBR:16(1).1}' property='tempInOBR16id' action='set' />
<assign value='$ZDATE($NOW(),8)' property='tempDateAdd' action='set' />
<assign value='""' property='tempDateResult' action='set' />
<assign value='""' property='tempDateCancel' action='set' />
<if condition='(source.{ORCgrp(1).ORC:1}="CA")||(source.{ORCgrp(1).ORC:1}="DC")' >
<true>
<assign value='$ZDATE($NOW(),8)' property='tempDateCancel' action='set' />
</true>
</if>
<assign value='tempCernerOrder' property='wTableKey' action='set' />
<assign value='""' property='wTableData' action='set' />
<assign value='""' property='wtableresult' action='set' />
<assign value='..Lookup("T_RegionsLab_OrderingProvider",wTableKey)' property='wtableresult' action='set' />
<if condition='wtableresult=""' >
<true>
<code>
<![CDATA[ 
    // no entry found - so add new entry
        set wTableData=(tempORC12_"|"_tempOBR16_"|"_tempDateAdd_"|"_tempDateResult_"|"_tempDateCancel_"|") 
        set wTableName="T_RegionsLab_OrderingProvider"
        do ##class(Ens.Util.LookupTable).%UpdateValue(wTableName,wTableKey,wTableData)
	]]></code>
</true>
<false>
<assign value='$PIECE(wtableresult,"|",1)' property='temptblORC12' action='set' />
<assign value='$PIECE(temptblORC12,"^",1)' property='temptblORC12id' action='set' />
<assign value='$PIECE(wtableresult,"|",2)' property='temptblOBR16' action='set' />
<assign value='$PIECE(temptblOBR16,"^",1)' property='temptblOBR16id' action='set' />
<assign value='$PIECE(wtableresult,"|",3)' property='temptblDateAdd' action='set' />
<assign value='$PIECE(wtableresult,"|",4)' property='temptblDateResult' action='set' />
<assign value='$PIECE(wtableresult,"|",5)' property='temptblDateCancel' action='set' />
<if condition='(source.{ORCgrp(1).ORC:1}="CA")||(source.{ORCgrp(1).ORC:1}="DC")' >
<true>
<code>
<![CDATA[ 
    // cancel or discontinue - update table with cancel date
        set wTableData=(tempORC12_"|"_tempOBR16_"|"_temptblDateAdd_"|"_temptblDateResult_"|"_tempDateCancel_"|") 
        set wTableName="T_RegionsLab_OrderingProvider"
        do ##class(Ens.Util.LookupTable).%UpdateValue(wTableName,wTableKey,wTableData)	
	]]></code>
</true>
<false>
<if condition='(tempInORC12id = temptblORC12id)&amp;(tempInOBR16id = temptblOBR16id)' >
<false>
<code>
<![CDATA[ 
    // ordering doc on table differs from order - update table with orm data - update date add
        set wTableData=(tempORC12_"|"_tempOBR16_"|"_tempDateAdd_"|"_temptblDateResult_"|"_temptblDateCancel_"|") 
        set wTableName="T_RegionsLab_OrderingProvider"
        do ##class(Ens.Util.LookupTable).%UpdateValue(wTableName,wTableKey,wTableData)	
	]]></code>
</false>
</if>
</false>
</if>
</false>
</if>

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

<code>
<![CDATA[
    // Epic Beaker Orders only accepts ST, TX, NM, DT, RP in OBX-2
    //  if condition='..In(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:2},"ST,TX,NM,DT,RP")' >
    //    <false>
    //   <assign value='"ST"' property='target.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:2}' action='set' />
    //  </false>
]]></code>
<foreach property='source.{ORCgrp(1).OBRgrp.OBXgrp()}' key='k1' >
<if condition='..In(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:2},"IS")' >
<true>
<assign value='"ST"' property='target.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:2}' action='set' />
</true>
</if>
</foreach>

</transform>
}

}
