Class GC.Cerner2RegDietADT Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ADT_A01' targetDocType='231.Cerner:ADT_A01' create='copy' language='objectscript' >
<code>
<![CDATA[ 
  // Last Updated 09/25/2018 Al Johnson
  // Moved to Prod 09/27/2018 Al Johnson
  // Create: 02/16/2018 Al Johnson
  // Description:
  //    Set aliased Pid-15.1 language to Pid-15.2 language text
  //    Remove Pid-15.1
  //    Jim Beersman put preferred language in Pid-15.5, use that if exists
  //
  //    Check for swing bed - change unit - table T_Swingbed_Diet - 09/27/2018
]]></code>

<assign value='""' property='target.{PID:15}' action='set' />
<assign value='source.{PID:15.1}' property='target.{PID:15.2}' action='set' />
<assign value='""' property='target.{PID:15.1}' action='set' />

<if condition='(source.{PID:15.5} = "")' >
<false>
<assign value='source.{PID:15.5}' property='target.{PID:15.2}' action='set' />
</false>
</if>

<code>
<![CDATA[ 
    //  09/25/2018 - check location for swingbed
    //
	//  Read table T_Swingbed_Diet - unit^room^bed is key to table
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
<assign value='..Lookup("T_Swingbed_Diet",wTableKey)' property='wtableresult' action='set' />
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
<assign value='..Lookup("T_Swingbed_Diet",wTableKey)' property='wtableresult' action='set' />
<if condition='wtableresult=""' >
<false>
<assign value='wtableresult' property='target.{PV1:PriorPatientLocation.pointofcare}' action='set' />
</false>
</if>

</transform>
}

}
