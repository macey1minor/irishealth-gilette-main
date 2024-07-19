Class GC.eDOCS.TildeReplace2 Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ORU_R01' targetDocType='231.Cerner:ORU_R01' create='copy' language='objectscript' >
<foreach property='target.{ORCgrp(1).OBXgrp()}' key='k1'>
<assign value='$REPLACE(target.{ORCgrp(1).OBXgrp(k1).OBX:5},"~","/")' property='target.{ORCgrp(1).OBXgrp(k1).OBX:5}' action='set' />
<assign value='$REPLACE(target.{ORCgrp(1).OBXgrp(k1).OBX:5},"/^^RTF^^","/")' property='target.{ORCgrp(1).OBXgrp(k1).OBX:5}' action='set' />
<assign value='$REPLACE(target.{ORCgrp(1).OBXgrp(k1).OBX:5},"/.br/","/ ")' property='target.{ORCgrp(1).OBXgrp(k1).OBX:5}' action='set' />
</foreach>
</transform>
}

}
