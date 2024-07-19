Class GC.PS360toCernerORU Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ORU_R01' targetDocType='231.Cerner:ORU_R01' create='copy' language='objectscript' >
<code>
<![CDATA[ 
	// Last Updated: Al Johnson 10/25/2017 
	// Last Updated in Prod: Al Johnson 10/25/2017 
	// Create By: Al Johnson 10/25/2017
	// *** Description:
	// Critical Results out of Cerner to Pacs are splitting the report into two fields
	//  PS360 result sending /F/ Cerner is translating to "|", change it to space
]]></code>

<assign value='""' property='tmpReport' action='set' />
<foreach property='source.{ORCgrp(1).OBXgrp()}' key='k1' >
<assign value='$REPLACE(source.{ORCgrp(1).OBXgrp(k1).OBX:5},"\F\"," ")' property='target.{ORCgrp(1).OBXgrp(k1).OBX:5}' action='set' />
</foreach>

</transform>
}

}
