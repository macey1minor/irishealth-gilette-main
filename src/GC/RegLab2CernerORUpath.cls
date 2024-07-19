Class GC.RegLab2CernerORUpath Extends Ens.DataTransformDTL
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<?xml version="1.0" ?>
<transform targetClass='EnsLib.HL7.Message' targetDocType='22.RegLab:ORU_R01' sourceClass='EnsLib.HL7.Message' sourceDocType='22.RegLab:ORU_R01' create='copy' language='objectscript'>
<code>
<![CDATA[ 
	//  Created 10/06/2016 Al Johnson
	//  Last Moved to Prod:  07/22/15
    //  Created 10/06/2016 Al Johnson
    //   started with copy of GCH.RegLab2QcprORUmb from old interfaces
    //   copy Regions Message to Cerner output
    //   remove OBXgrp
    //   string together OBX result messages for Cerner
    //   write one OBX with new data
    //  12/12/2016  send TX in OBX-2, not ST. String has a limit of 255 characters so PowerChart display is bad.
]]>
</code>

<if condition='(source.{OBR:ResultStatus} = "") || (source.{OBR:ResultStatus} = "I")'>
<true>
<assign property='target.{OBR:ResultStatus}' value='"P"' action='set'/>
</true>
</if>

<code>
<![CDATA[
    //  Remove OBX segments copied from source
]]>
</code>

<foreach property='target.{OBXgrp()}' key='k1'>
<assign value='' property='target.{OBXgrp(k1)}' action='remove' />
</foreach>

<code>
<![CDATA[
    //  String descriptions together, remove ~ from col 1 add performed at line
]]>
</code>

<assign property='holdOBXdesc' value='""' action='set' />
<assign property='holdOBXdesc1' value='""' action='set' />
<foreach property='source.{OBXgrp()}' key='k1'>
<assign property='holdOBXdesc1' value='$TR(source.{OBXgrp(k1).OBX:5},"^"," ")' action='set'/>
<assign property='holdOBXdesc' value='(holdOBXdesc_"~"_holdOBXdesc1)' action='set' />
</foreach>

<code>
<![CDATA[
   set holdOBXdesc=$REPLACE(holdOBXdesc,"~","",1,1)
]]>
</code>

<assign property='PERFlab' value='source.{OBXgrp(1).OBX:15}' action='set'/>
<assign property='holdOBXdesc' value='(holdOBXdesc_"~"_PERFlab)' action='set' />

<assign property='target.{OBR:4}' value='""' action='set' />
<assign property='target.{OBR:4.1}' value='source.{OBR:4.2}' action='set' />
<assign property='target.{OBR:4.2}' value='source.{OBR:4.2}' action='set' />
<assign property='target.{OBR:24}' value='"CoPath"' action='set' />
<assign property='target.{OBXgrp(1).OBX:SetIDOBX}' value='"1"' action='set'/>
<assign property='target.{OBXgrp(1).OBX:ValueType}' value='"TX"' action='set'/>
<assign property='target.{OBXgrp(1).OBX:ObservationIdentifier.identifier}' value='source.{OBR:4.2}' action='set' />
<assign property='target.{OBXgrp(1).OBX:ObservationIdentifier.text}' value='source.{OBR:4.2}' action='set' />
<assign property='target.{OBXgrp(1).OBX:5}' value='holdOBXdesc' action='set' />
<assign property='target.{OBXgrp(1).OBX:ObservResultStatus}' value='target.{OBR:ResultStatus}' action='set' />
<assign property='target.{OBXgrp(1).OBX:15}' value='source.{OBXgrp(1).OBX:15}' action='set'/>


</transform>
}

}
