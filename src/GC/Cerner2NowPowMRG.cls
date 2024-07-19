Class GC.Cerner2NowPowMRG Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ADT_A34' targetDocType='231.Cerner:ADT_A34' create='new' language='objectscript' >
<code>
<![CDATA[ 
	//  Last Updated: 11/11/2019 Al Johnson
	//  Last Updated in Prod: 12/04/2019 Al Johnson
	//  Create: 11/11/2019  Al Johnson
	//
	//  Description:  New Interface - ADT Merge to NowPow
	//   NowPow does not process merges but will report out on their side A34 patient merges
	//
]]></code>
<assign value='source.{MSH}' property='target.{MSH}' action='set' />
<assign value='source.{MSH:3.1}' property='target.{MSH:3.2}' action='set' />
<assign value='source.{MSH:4.1}' property='target.{MSH:4.2}' action='set' />
<assign value='source.{MSH:5.1}' property='target.{MSH:5.2}' action='set' />
<assign value='source.{MSH:6.1}' property='target.{MSH:6.2}' action='set' />
<assign value='source.{EVN}' property='target.{EVN}' action='set' />
<assign value='source.{PID}' property='target.{PID}' action='set' />
<assign value='source.{MSH:4.1}' property='target.{PID:3.4.2}' action='set' />
<assign value='"MR"' property='target.{PID:3.5}' action='set' />

<assign value='source.{MRG}' property='target.{MRG}' action='set' />
<assign value='source.{MRG:1.1}' property='target.{MRG:1}' action='set' />
<assign value='source.{MSH:4.1}' property='target.{MRG:1.4.2}' action='set' />
<assign value='"MR"' property='target.{MRG:1.5}' action='set' />

</transform>
}

}
