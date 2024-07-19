Class GC.Cerner2RegLabORMsub Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ORM_O01' targetDocType='22.RegLab:ORM_O01' create='new' language='objectscript' >
<code>
<![CDATA[ 
	//  Last Updated: 01/21/2019 Al Johnson
	//  Last Updated in Prod: 01/21/2019 Al Johnson
	//  Create: 11/02/16  Al Johnson
	//  Copied from GCH.Qcpr2RegLabORMsub 
	//  Description:  Copy all code from Qcpr2RegLabSub
	//  (orignal - ) logic either Cerner alias or Cerner modobject
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
	//  Send Observation as Inpatient  9/18/2018
	//
	//    Check for swing bed - change unit - table T_Swingbed_Lab 9/25/2018
	//
	//  Send Outpatient in a Bed as Inpatient  12/19/2018
	//
	//   Ensure Regions receives HNA in MSH-4 - 1/21/2019
]]></code>
<code>
<![CDATA[ 
	// *********************** Copy all code from Qcpr2RegLabSub ********************************
]]></code>
<assign value='source.{MSH}' property='target.{MSH}' action='set' />
<assign value='"HNA"' property='target.{MSH:4}' action='set' />
<assign value='"2.2"' property='target.{MSH:VersionID}' action='set' />
<assign value='source.{PID}' property='target.{PID}' action='set' />
<assign value='source.{ORCgrp(1).ORC}' property='target.{ORC}' action='set' />
<assign value='source.{PV1}' property='target.{PV1}' action='set' />
<assign value='"SQ"' property='target.{MSH:5}' action='set' />
<assign value='"RLAB"' property='target.{MSH:6}' action='set' />
<assign value='"Cerner2RegORMsub"' property='target.{MSH:16}' action='set' />
<assign value='' property='target.{PID:9}' action='clear' />

<assign value='""' property='target.{PID:10}' action='set' />
<assign value='source.{PID:10(1)}' property='target.{PID:10}' action='set' />

<assign value='$ZCONVERT(target.{PID},"U" )' property='target.{PID}' action='set' />

<assign value='' property='target.{PV1:HospitalService}' action='remove' />

<code>
<![CDATA[ 
	// *******************   IP vs OP Location Logic ***********************************************
]]></code>
<if condition='..In(source.{PV1:18},"Observation,PreObservation,Outpatient in a Bed,PreOutpatient in a Bed")' >
<true>
<assign value='"IP"' property='target.{PV1:PatientClass}' action='set' />
<assign value='"N"' property='target.{PV1:PatientType}' action='set' />
</true>
<false>
<if condition='..In(source.{PV1:18},"Inpatient,PreInpatient,Sleep Study,PreSleepStudy") || ..In(source.{PV1:3.1},"0NU,0AU,0RU,0OSU,0OSE,0OSW,0IC,0ND,G7W")' >
<true>
<assign value='"IP"' property='target.{PV1:PatientClass}' action='set' />
<assign value='"N"' property='target.{PV1:PatientType}' action='set' />
</true>
<false>
<if condition='..In(source.{PV1:3.1},"GCSH,GCSH Main OR,PACU,GCSH Periop")' >
<true>
<assign value='"IP"' property='target.{PV1:PatientClass}' action='set' />
<assign value='"N"' property='target.{PV1:PatientType}' action='set' />
<assign value='""' property='target.{PV1:AssignedPatientLocation}' action='clear' />
<assign value='"GOR"' property='target.{PV1:AssignedPatientLocation.pointofcareID}' action='set' />
<assign value='"GOR99"' property='target.{PV1:AssignedPatientLocation.room}' action='set' />
</true>
<false>
<assign value='"OP"' property='target.{PV1:PatientClass}' action='set' />
<assign value='"S"' property='target.{PV1:PatientType}' action='set' />
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
<assign value='"IP"' property='target.{PV1:PatientClass}' action='set' />
<assign value='"N"' property='target.{PV1:PatientType}' action='set' />
<assign value='""' property='target.{PV1:AssignedPatientLocation}' action='clear' />
<assign value='"GOR"' property='target.{PV1:AssignedPatientLocation.pointofcareID}' action='set' />
<assign value='"GOR99"' property='target.{PV1:AssignedPatientLocation.room}' action='set' />
</true>
</if>

<if condition='..In(source.{PV1:6.1},"GCSH,GCSH Main OR,PACU,GCSH Periop")' >
<true>
<assign value='"IP"' property='target.{PV1:PatientClass}' action='set' />
<assign value='"N"' property='target.{PV1:PatientType}' action='set' />
<assign value='""' property='target.{PV1:PriorPatientLocation}' action='clear' />
<assign value='"GOR"' property='target.{PV1:PriorPatientLocation.pointofcareID}' action='set' />
<assign value='"GOR99"' property='target.{PV1:PriorPatientLocation.room}' action='set' />
</true>
</if>

<assign value='""' property='target.{ORC:13}' action='set' />

<if condition='source.{PV1:8(1).1}="11845887"' >
<true>
<assign value='""' property='target.{PV1:8(1)}' action='set' />
</true>
</if>

<if condition='target.{PV1:8(1).1}=""' >
<false>
<if condition='$EXTRACT(target.{PV1:8(1).1},1,1)="E"' >
<false>
<assign value='target.{PV1:8(1)}' property='tmprefdoc' action='set' />
<assign value='"E"_tmprefdoc' property='target.{PV1:8(1)}' action='set' />
</false>
</if>
</false>
</if>

<code>
<![CDATA[ 
	// *******************   Other Location Logic **********************************************************
]]></code>
<if condition='..Contains(source.{PV1:AssignedPatientLocation.pointofcare},"0AIM")' >
<true>
<assign value='""' property='target.{PV1:AssignedPatientLocation}' action='set' />
<assign value='"GAIM"' property='target.{PV1:AssignedPatientLocation.pointofcareID}' action='set' />
</true>
</if>
<if condition='..Contains(source.{PV1:AssignedPatientLocation.pointofcare},"0WR") || ..In(source.{PV1:18},"Day Surgery,PreDaySurgery")' >
<true>
<assign value='""' property='target.{PV1:AssignedPatientLocation}' action='set' />
<assign value='"GSDS"' property='target.{PV1:AssignedPatientLocation.pointofcareID}' action='set' />
</true>
</if>
<if condition='(source.{PV1:AssignedPatientLocation.pointofcare} = "07W")' >
<true>
<assign value='"G7W"' property='target.{PV1:AssignedPatientLocation.pointofcareID}' action='set' />
</true>
</if>
<if condition='..In(source.{PV1:AssignedPatientLocation.pointofcare},"0PAN,0PAC,0OR,REG,REGS")' >
<true>
<assign value='""' property='target.{PV1:AssignedPatientLocation}' action='set' />
<assign value='"GOR"' property='target.{PV1:AssignedPatientLocation.pointofcareID}' action='set' />
</true>
</if>

<code>
<![CDATA[ 
	// *******************   Prior Location Logic **********************************************************
]]></code>
<if condition='..Contains(source.{PV1:PriorPatientLocation.pointofcare},"0AIM")' >
<true>
<assign value='""' property='target.{PV1:PriorPatientLocation}' action='set' />
<assign value='"GAIM"' property='target.{PV1:PriorPatientLocation.pointofcareID}' action='set' />
</true>
</if>
<if condition='..Contains(source.{PV1:PriorPatientLocation.pointofcare},"0WR") || ..In(source.{PV1:18},"Day Surgery,PreDaySurgery")' >
<true>
<assign value='""' property='target.{PV1:PriorPatientLocation}' action='set' />
<assign value='"GSDS"' property='target.{PV1:PriorPatientLocation.pointofcareID}' action='set' />
</true>
</if>
<if condition='(source.{PV1:PriorPatientLocation.pointofcare} = "07W")' >
<true>
<assign value='"G7W"' property='target.{PV1:PriorPatientLocation.pointofcareID}' action='set' />
</true>
</if>
<if condition='..In(source.{PV1:PriorPatientLocation.pointofcare},"0PAN,0PAC,0OR,REG,REGS")' >
<true>
<assign value='""' property='target.{PV1:PriorPatientLocation}' action='set' />
<assign value='"GOR"' property='target.{PV1:PriorPatientLocation.pointofcareID}' action='set' />
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
<assign value='"GLSH"' property='target.{PV1:AssignedPatientLocation.pointofcareID}' action='set' />
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
<assign value='"GPSH"' property='target.{PV1:AssignedPatientLocation.pointofcareID}' action='set' />
<assign value='""' property='target.{PV1:PriorPatientLocation}' action='set' />
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
<assign value='"GSDS"' property='target.{PV1:AssignedPatientLocation.pointofcareID}' action='set' />
</true>
</if>

<code>
<![CDATA[ 
	// **********  Special Coding to send patient location for GPHS Gillette Pediatric Home service ***************
]]></code>
<if condition='source.{PV1:AdmitSource} = 10' >
<true>
<assign value='""' property='target.{PV1:AssignedPatientLocation}' action='clear' />
<assign value='"GPHS"' property='target.{PV1:AssignedPatientLocation.pointofcareID}' action='set' />
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
<assign value='source.{PID:PatientAccountNumber}' property='target.{PID:PatientIDInternalID(1).Checkdigit}' action='set' />
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
	]]></code>
<if condition='..Contains(source.{PID:3(1).2},"C") ' >
<true>
<assign value='source.{PID:PatientAccountNumber}' property='target.{PID:PatientIDInternalID(1).Checkdigit}' action='set' />
<assign value='source.{PID:3(1).2}' property='target.{PID:18.1}' action='set' />
</true>
</if>

<assign value='source.{ORCgrp(1).OBRgrp.OBR}' property='target.{OBR}' action='set' />
<foreach property='source.{ORCgrp(1).OBRgrp.NTE()}' key='k4' >
<assign value='source.{ORCgrp(1).OBRgrp.NTE(k4)}' property='target.{NTEi2(k4)}' action='set' />
</foreach>

<code>
<![CDATA[ 
	//  OBR-27.6 = 'RO' Timing Priority = Routine and not cancel or discontinue
	//    If OBR-11 = "L"   set OBR-7 = ORC-9
	//    If OBR-11 Not = "L" set OBR-7 = ORC-15
	]]></code>
	
<if condition='target.{OBR:27.6}="RO"' >
<true>
<if condition='(target.{ORC:1}="CA") || (target.{ORC:1}="DC")' >
<false>
<if condition='(target.{OBR:11}="L")' >
<true>
<assign value='target.{ORC:9.1}' property='target.{OBR:7}' />
</true>
<false>
<assign value='target.{ORC:15.1}' property='target.{OBR:7}' />
</false>
</if>
</false>
</if>
</true>
</if>

<assign property="tempOBX" value='""' action='set' />
<foreach property='source.{ORCgrp(1).OBRgrp.OBXgrp()}' key='k1' >
<assign property='tempOBX' value='tempOBX+1' />
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX}' property='target.{OBX(tempOBX)}' action='set' />
</foreach>

<foreach property='source.{ORCgrp(1).OBRgrp.OBXgrp()}' key='k2' >
<foreach property='source.{ORCgrp(1).OBRgrp.OBXgrp(k2).NTE()}' key='k3' >
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k2).NTE(k3)}' property='target.{NTEi3(k3)}' action='set' />
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
	
<assign property='tempCernerOrder' value='source.{ORCgrp(1).ORC:2.1}' action='set' />
<assign property='tempORC12' value='source.{ORCgrp(1).ORC:12}' action='set' />
<assign property='tempOBR16' value='source.{ORCgrp(1).OBRgrp.OBR:16(1)}' action='set' />

<assign property='tempInORC12id' value='source.{ORCgrp(1).ORC:12.1}' action='set' />
<assign property='tempInOBR16id' value='source.{ORCgrp(1).OBRgrp.OBR:16(1).1}' action='set' />

<assign property='tempDateAdd' value='$ZDATE($NOW(),8)' action='set' />
<assign property='tempDateResult' value='""' action='set' />
<assign property='tempDateCancel' value='""' action='set' />
<if condition='(source.{ORCgrp(1).ORC:1}="CA")||(source.{ORCgrp(1).ORC:1}="DC")' >
<true>
<assign property='tempDateCancel' value='$ZDATE($NOW(),8)' action='set' />
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
<assign value='wtableresult' property='target.{PV1:AssignedPatientLocation.pointofcareID}' action='set' />
</false>
</if>

<code>
<![CDATA[ 
     // $$$TRACE("pv1-3 read= "_wTableKey) 
     // $$$TRACE("pv1-3 return= "_wtableresult)   
     // $$$TRACE("pv1-3 target= "_holdtarg)  
]]></code>

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
<assign value='wtableresult' property='target.{PV1:PriorPatientLocation.pointofcareID}' action='set' />
</false>
</if>

</transform>
}

}
