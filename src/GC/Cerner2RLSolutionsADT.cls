Class GC.Cerner2RLSolutionsADT Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ADT_A01' targetDocType='231.Cerner:ADT_A01' create='new' language='objectscript' >
<code>
<![CDATA[ 
	//  Last Updated: 12/13/2018 Al Johnson
	//  Last Updated in Prod: 02/12/2019 Al Johnson
	//  Create: 12/13/2018  Al Johnson
	//
	//  Description:  New Interface - ADT to RL Solutions for Occurence Reporting
	//
]]></code>

<assign value='source.{MSH}' property='target.{MSH}' action='set' />
<assign value='source.{EVN}' property='target.{EVN}' action='set' />
<assign value='source.{PID}' property='target.{PID}' action='set' />
<assign value='source.{PV1}' property='target.{PV1}' action='set' />

</transform>
}

}
