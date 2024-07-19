Class GC.Cerner2NuanceDaxADTA28A31 Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ADT_A31' targetDocType='231.Cerner:ADT_A31' create='new' language='objectscript' >
<code>
<![CDATA[ 
	//  Last Updated: 11/19/2021 Al Johnson
	//  Last Updated in Prod: 12/03/2021 Al Johnson
	//  Create: 11/19/2021  Al Johnson
	//
	//  Description:  New Interface - ADT and SIU to NuanceDax
	//   Used for doctors to dictate
	//  New Interface RFC SD-107657
]]></code>
<assign value='source.{MSH}' property='target.{MSH}' action='set' />
<assign value='source.{PID}' property='target.{PID}' action='set' />
<assign value='"MRN"' property='target.{PID:3.5}' action='set' />
<assign value='""' property='target.{PID:19}' action='set' />
<assign value='source.{EVN}' property='target.{EVN}' action='set' />
<assign value='source.{PV1}' property='target.{PV1}' action='set' />
</transform>
}

}
