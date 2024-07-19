Class GC.Cerner2RegLabSub Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ADT_A01' targetDocType='231.Cerner:ADT_A01' create='new' language='objectscript' >
<code>
<![CDATA[ 
    //    Last Updated 01/21/2019 Al Johnson
    //    Moved to Prod 01/21/2019 Al Johnson
	// Created:  Started with copy of QCPR2RegLabSub  
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
	//  Send Observation as Inpatient  9/18/2018
	//
	//    Check for swing bed - change unit - table T_Swingbed_Lab 9/25/2018
	//
	//  Send Outpatient in a Bed as Inpatient  12/19/2018
	//
    //   Ensure Regions receives HNA500 for ADT in MSH-4 - 1/21/2019
]]></code>
<assign value='source.{MSH}' property='target.{MSH}' action='set' />
<assign value='"2.2"' property='target.{MSH:VersionID}' action='set' />
<assign value='"HNA500"' property='target.{MSH:4}' action='set' />
<assign value='"SQ"' property='target.{MSH:5}' action='set' />
<assign value='"RLAB"' property='target.{MSH:6}' action='set' />
<assign value='"Cerner2RegLabSub"' property='target.{MSH:16}' action='set' />

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

<code>
<![CDATA[ 
	// *******************   IP vs OP Location Logic ***********************************************
	// If hosp service code is 0IP or 0ss or current unit is 0NU,0AU,0RU,0OSU,0OSE,0OSW,00IC,0ND or 07W
	// set PV1_2 to A and PV1_18 to N for inpatient other wise
	// set PV1_2 to O PV1_18 to S PV1_3 to GILL for outpatient 
	//  PV1-3.1 or PV1-6.1 GCSH - send GOR  02/15/2017
	//  PV1-3.1 or PV1-6.1 GCSH Main OR - send GOR  02/17/2017
	//  PV1-3.1 or PV1-6.1 PACU - send GOR  02/17/2017
	//  PV1-3.1 or PV1-6.1 GCSH Periop - send GOR  02/17/2017
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
<assign value='"GOR"' property='target.{PV1:AssignedPatientLocation.pointofcare}' action='set' />
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
<assign value='"GOR"' property='target.{PV1:AssignedPatientLocation.pointofcare}' action='set' />
<assign value='"GOR99"' property='target.{PV1:AssignedPatientLocation.room}' action='set' />
</true>
</if>

<if condition='..In(source.{PV1:6.1},"GCSH,GCSH Main OR,PACU,GCSH Periop")' >
<true>
<assign value='"IP"' property='target.{PV1:PatientClass}' action='set' />
<assign value='"N"' property='target.{PV1:PatientType}' action='set' />
<assign value='""' property='target.{PV1:PriorPatientLocation}' action='clear' />
<assign value='"GOR"' property='target.{PV1:PriorPatientLocation.pointofcare}' action='set' />
<assign value='"GOR99"' property='target.{PV1:PriorPatientLocation.room}' action='set' />
</true>
</if>

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
<if condition='..Contains(source.{PV1:PriorPatientLocation.pointofcare},"0WR")' >
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
