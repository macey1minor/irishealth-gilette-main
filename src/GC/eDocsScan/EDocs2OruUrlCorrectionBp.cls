Class GC.eDocsScan.EDocs2OruUrlCorrectionBp Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

// Last Updated: 

// Moved to Prod - xx/xx/xxxx

// copied from Dev 

// last update in Dev 02/14/2017 

// Create: 02/14/2017 Ellen Leichtman

//    Description: Used for Resend to Cerner

//    Make all corrections and fix URL form Dev to PROd  

// 

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ORU_R01' targetDocType='231.Cerner:ORU_R01' create='copy' language='objectscript' >
<assign value='$REPLACE(target.{ORCgrp(1).OBXgrp(1).OBX:5},"gcshdmedocsde01","gcshdmedocspr01")' property='target.{ORCgrp(1).OBXgrp(1).OBX:5}' action='set' />
<assign value='"C"' property='target.{ORCgrp(1).OBR:ResultStatus}' action='set' />
<assign value='"C"' property='target.{ORCgrp(1).OBXgrp(1).OBX:ObservationResultStatus}' action='set' />

</transform>
}

}
