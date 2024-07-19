Class GC.Cerner2PacsA34toA40 Extends Ens.DataTransformDTL [ ClassType = "", DependsOn = EnsLib.HL7.Message, ProcedureBlock ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ADT_A34' targetDocType='231.Cerner:ADT_A34' create='new' language='objectscript' >
<code>
<![CDATA[ 
	// Last Updated 06/01/2017 Al Johnson
  	// Last Moved to Prod  06/14/2017
  	// Created 06/01/2017 
 	// Description:
 	// Cerner sends A34 mrn merge, A35 fin merge and A44 mrn and fin merge
 	//  PACS only wants mrn merge.  Send to PACS as A40
]]></code>
<assign value='source.{MSH}' property='target.{MSH}' action='set' />
<assign value='"A40"' property='target.{MSH:MessageType.triggerevent}' action='set' />
<assign value='source.{EVN}' property='target.{EVN}' action='set' />
<assign value='"A40"' property='target.{EVN:EventTypeCode}' action='set' />
<assign value='source.{PID}' property='target.{PID}' action='set' />
<assign value='source.{MRG}' property='target.{MRG}' action='set' />
</transform>
}

}
