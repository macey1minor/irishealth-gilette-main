Class GC.eDOCS.TildeReplace3 Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ORU_R01' targetDocType='231.Cerner:ORU_R01' create='copy' language='objectscript' >
<foreach property='target.{ORCgrp(1).OBXgrp()}' key='k1'>
<code>
<![CDATA[
     // extract the obx into 3 pieces delimited by '{\rtf1\' and '}|'
     //  perform actions on middle
     //  add back delimiters when recreating obx segment
     ]]></code>

<assign value='""' property='holdobxseg' action='set' />
<assign value='target.{ORCgrp(1).OBXgrp(k1).OBX}' property='holdobxseg' action='set' />

<assign value='""' property='holdobxseg1' action='set' />
<assign value='""' property='holdobxseg1a' action='set' />
<assign value='""' property='holdobxseg2' action='set' />
<assign value='""' property='holdobxseg3' action='set' />

<assign value='$PIECE(holdobxseg,"{\rtf1\",1)' property='holdobxseg1' action='set' />
<assign value='$PIECE(holdobxseg,"{\rtf1\",2)' property='holdobxseg1a' action='set' />

<assign value='$PIECE(holdobxseg1a,"}|",1)' property='holdobxseg2' action='set' />
<assign value='$PIECE(holdobxseg1a,"}|",2)' property='holdobxseg3' action='set' />

<assign value='$REPLACE(holdobxseg2,"|"," ")' property='holdobxseg2' action='set' />
<assign value='$REPLACE(holdobxseg2,"~","/")' property='holdobxseg2' action='set' />
<assign value='$REPLACE(holdobxseg2,"/^^RTF^^","/")' property='holdobxseg2' action='set' />
<assign value='$REPLACE(holdobxseg2,"/.br/","/ ")' property='holdobxseg2' action='set' />

<assign value='(holdobxseg1_"{\rtf1\"_holdobxseg2_"}|"_holdobxseg3)' property='target.{ORCgrp(1).OBXgrp(k1).OBX}' action='set' />

</foreach>
</transform>
}

}
