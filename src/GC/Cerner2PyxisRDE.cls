Class GC.Cerner2PyxisRDE Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 0;

Parameter REPORTERRORS = 0;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cernerbase:RDE_O01' targetDocType='231.Cernerbase:RDE_O01' create='copy' language='objectscript' >
<code>
<![CDATA[ 
    // Created: 08/19/2016 Al Johnson
	// Last Updated: 08/05/2020 Al Johnson
	// Moved to Prod: 08/05/2020
	//    Description:
	//     For IV solutions: (original thought - RXE-2.5 contains Premix) - changed to check routing of IV RXR-4.1
	//     Search RXC components.  If either additive or base is 0 id, remove RXC and update RXE-2.1 drug id and RXE-2.2 description from valid RXC
	//updated 1/10/2017 Mia/Added: copy 1st iteration RXE.2.1 & RXE.2.2 to RXC.2.1 & RXC.2.2 respectivly.
	//
	//     Check for swing bed - change unit - table T_Swingbed_All 9/26/2018
	//
	//  remove explicit times (ORC-7.2.2 and RXE-1.2.2) if PRN code 8/5/2020 SD-50837 RFC SD-51056
	//
]]></code>
<assign value='""' property='holdupdatesw' action='set' />
<assign value='""' property='holdmedid' action='set' />
<assign value='""' property='holdmediddesc' action='set' />
<assign value='""' property='holddeletek2' action='set' />
<assign value='""' property='testRXR' action='set' />
<foreach property='target.{ORCgrp(1).RXR()}' key='k1' >
<if condition='target.{ORCgrp(1).RXR(k1):AdministrationMethod.identifier} = "IV"' >
<true>
<assign value='"IV"' property='testRXR' action='set' />
</true>
</if>
</foreach>
<if condition='testRXR="IV"' >
<true>
<foreach property='target.{ORCgrp(1).RXC()}' key='k2' >
<if condition='(target.{ORCgrp(1).RXC(k2):ComponentCode.Identifier}="0")||(target.{ORCgrp(1).RXC(k2):ComponentCode.Identifier}="")' >
<true>
<assign value='"X"' property='holdupdatesw' action='set' />
<assign value='k2' property='holddeletek2' action='set' />
</true>
<false>
<assign value='target.{ORCgrp(1).RXC(k2):ComponentCode.Identifier}' property='holdmedid' action='set' />
<assign value='target.{ORCgrp(1).RXC(k2):ComponentCode.Text}' property='holdmediddesc' action='set' />
</false>
</if>
</foreach>
</true>
</if>
<if condition='holdupdatesw="X"' >
<true>
<assign value='holdmedid' property='target.{ORCgrp(1).RXE:GiveCode.Identifier}' action='set' />
<assign value='holdmediddesc' property='target.{ORCgrp(1).RXE:GiveCode.text}' action='set' />
<assign value='' property='target.{ORCgrp(1).RXC(holddeletek2)}' action='remove' />
</true>
</if>
<if condition='source.{ORCgrp(1).RXC(1):ComponentCode.identifier}' >
<true>
<assign value='source.{ORCgrp(1).RXC(1):ComponentCode.identifier}' property='target.{ORCgrp(1).RXE:GiveCode.identifier}' action='set' />
</true>
</if>

<code>
<![CDATA[ 
    //  08/05/2020 - new PRN code
    //  remove explicit times (ORC-7.2.2 and RXE-1.2.2) if PRN code
	]]></code>
	
	<if condition='source.{ORCgrp(1).ORC:7.7}="PRN"' >
	<true>
	<assign value='""' property='target.{ORCgrp(1).ORC:7.2.2}' action='set' />
	</true>
	</if>
	
	<if condition='source.{ORCgrp(1).RXE:1.7}="PRN"' >
	<true>
	<assign value='""' property='target.{ORCgrp(1).RXE:1.2.2}' action='set' />
	</true>
	</if>
	
<code>
<![CDATA[ 
    //  09/26/2018 - check location for swingbed
    //
	//  Read table T_Swingbed_All - unit^room^bed is key to table
	//  If found, replace unit number
	//  Check PV1-3 location and PV1-6 prior location
	]]></code>

<assign value='""' property='wTableKey' action='set' />
<assign value='""' property='temproom' action='set' />
<assign value='""' property='tempbed' action='set' />
<assign value='source.{PIDgrp.PV1grp.PV1:AssignedPatientLocation.pointofcare}' property='tempunit' action='set' />
<assign value='source.{PIDgrp.PV1grp.PV1:AssignedPatientLocation.room}' property='temproom' action='set' />
<assign value='source.{PIDgrp.PV1grp.PV1:AssignedPatientLocation.bed}' property='tempbed' action='set' />
<assign value='tempunit_"^"_temproom_"^"_tempbed' property='wTableKey' action='set' />

<assign value='""' property='wTableData' action='set' />
<assign value='""' property='wtableresult' action='set' />
<assign value='..Lookup("T_Swingbed_All",wTableKey)' property='wtableresult' action='set' />
<if condition='wtableresult=""' >
<false>
<assign value='wtableresult' property='target.{PIDgrp.PV1grp.PV1:AssignedPatientLocation.pointofcare}' action='set' />
</false>
</if>

<assign value='""' property='wTableKey' action='set' />
<assign value='""' property='temproom' action='set' />
<assign value='""' property='tempbed' action='set' />
<assign value='source.{PIDgrp.PV1grp.PV1:PriorPatientLocation.pointofcare}' property='tempunit' action='set' />
<assign value='source.{PIDgrp.PV1grp.PV1:PriorPatientLocation.room}' property='temproom' action='set' />
<assign value='source.{PIDgrp.PV1grp.PV1:PriorPatientLocation.bed}' property='tempbed' action='set' />
<assign value='tempunit_"^"_temproom_"^"_tempbed' property='wTableKey' action='set' />

<assign value='""' property='wTableData' action='set' />
<assign value='""' property='wtableresult' action='set' />
<assign value='..Lookup("T_Swingbed_All",wTableKey)' property='wtableresult' action='set' />
<if condition='wtableresult=""' >
<false>
<assign value='wtableresult' property='target.{PIDgrp.PV1grp.PV1:PriorPatientLocation.pointofcare}' action='set' />
</false>
</if>
</transform>
}

}
