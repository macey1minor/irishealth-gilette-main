Class GC.Ps3602CernerORUfix Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ORU_R01' targetDocType='231.Cerner:ORU_R01' create='copy' language='objectscript' >
<code>
<![CDATA[ 
	// Last Updated: Al Johnson 07/24/2017 
	// Last Updated in Prod: Al Johnson 07/24/2017 
	// Create By: Al Johnson 07/24/2017
	// *** Description:
	// PS360 Operative Reports were coming out of Cerner unsigned
	//  Configuration was added to Cerner, messages from go live to present needed to be replayed
	//   as corrections.  2/12 - 7/16 (7/17 - 7/19 manually fixed and replayed)
	//  Change OBR-25 ResultStatus to 'C' and append initials to MSH-10 MessageControlID 	 
]]></code>

<assign value='source.{MSH:MessageControlID}' property='holdmsh10' action='set' />
<assign value='holdmsh10_"ALJ1"' property='target.{MSH:MessageControlID}' action='set' />
<assign value='"C"' property='target.{ORCgrp(1).OBR:25}' action='set' />

</transform>
}

}
