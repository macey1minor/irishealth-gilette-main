Class GC.eDocsScan.EDocs2ORUb4chg061517 Extends Ens.DataTransformDTL [ DependsOn = (GC.eDocsScan.eDocRecordDef, EnsLib.HL7.Message) ]
{

// Last Updated: 

// Moved to Prod - xx/xx/xxxx

// copied from Dev 

// last update in Dev 02/09/2015

// Create: 12/14/2016 Ellen Leichtman

//    Description: Scanned documnet that are sent to Cerner as ORU 

//                 Send pointer/ URL

// 

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='GC.eDocsScan.eDocRecordDef' targetClass='EnsLib.HL7.Message' targetDocType='231.Cerner:ORU_R01' create='new' language='objectscript' >
<assign value='source.DOB' property='target.{PID:DateTimeOfBirth}' action='set' />
<assign value='"ORU"' property='target.{MSH:MessageType.messagetype}' action='set' />
<assign value='"R01"' property='target.{MSH:MessageType.triggerevent}' action='set' />
<assign value='source.account' property='target.{PV1:VisitNumber}' action='set' />
<assign value='"RP"' property='target.{ORCgrp(1).OBXgrp(1).OBX:ValueType(1) }' action='set' />
<assign value='source.firstName' property='target.{PID:PatientName(1).givenname}' action='set' />
<assign value='""' property='target.{ORCgrp(1).ORC:OrderControl}' action='set' />
<assign value='source.lastName' property='target.{PID:PatientName(1).familylastname.familyname}' action='set' />
<assign value='source.creationDate' property='target.{ORCgrp(1).OBR:ObservationDateTime}' action='set' />
<assign value='""' property='target.{ORCgrp(1).OBR:SetIDOBR}' action='set' />
<assign value='source.mrn' property='target.{PID:PatientIdentifierList(1)}' action='set' />
<assign value='source.linkUrl' property='tmpUrl' action='set' />
<assign value='"&lt;"' property='tmpLT' action='set' />
<assign value='"&gt;"' property='tmpGT' action='set' />
<assign value='"&amp;"' property='tmpAND' action='set' />
<assign value='$REPLACE(tmpUrl,tmpAND,"&amp;")' property='tmpUrl' action='set' />
<assign value='$REPLACE(tmpUrl,tmpLT,"&lt;")' property='tmpUrl' action='set' />
<assign value='$REPLACE(tmpUrl,tmpGT,"&gt;")' property='tmpUrl' action='set' />

<assign value='tmpUrl_"^URL^URL"' property='tmpUrl' action='set' />
<assign value='tmpUrl' property='target.{ORCgrp(1).OBXgrp(1).OBX:5}' action='set' />
<assign value='$REPLACE(target.{ORCgrp(1).OBXgrp(1).OBX:5},"gcshdmedocsde01","gcshdmedocspr01")' property='target.{ORCgrp(1).OBXgrp(1).OBX:5}' action='set' />

<assign value='"GCSH"' property='target.{MSH:SendingFacility}' action='set' />
<assign value='"GCHS"' property='target.{MSH:ReceivingApplication}' action='set' />
<assign value='"GCSH"' property='target.{MSH:ReceivingFacility}' action='set' />
<assign value='"EDOCSSCAN"' property='target.{MSH:SendingApplication}' action='set' />
<assign value='source.msgID' property='target.{MSH:MessageControlID}' action='set' />
<assign value='source.documentType' property='target.{ORCgrp(1).OBR:UniversalServiceID.text}' action='set' />
<assign value='source.documentTypeID' property='target.{ORCgrp(1).OBR:UniversalServiceID.identifier}' action='set' />
<assign value='source.documentTypeID' property='target.{ORCgrp(1).OBXgrp(1).OBX:ObservationIdentifier}' action='set' />
<code>
<![CDATA[ 
	/* *********************************************************************************
	12/14/2016 EJL we do not need this as the pointer is alway pointing to the current doc in edocs.
	               Currently the C is not working with Cerner. Must have F before a C.
	               Joel is looking to see how to send corrections if needed
 	<if condition='source.versionNbr = 1' >
	<true>
	<assign value='"F"' property='target.{ORCgrp(1).OBR:ResultStatus}' action='set' />
	<assign value='"F"' property='target.{ORCgrp(1).OBXgrp(1).OBX:ObservationResultStatus}' action='set' />
	</true>
	<false>
	<assign value='"C"' property='target.{ORCgrp(1).OBR:ResultStatus}' action='set' />
	<assign value='"C"' property='target.{ORCgrp(1).OBXgrp(1).OBX:ObservationResultStatus}' action='set' />
	</false>
	</if>
	****************************************************************************************  */
]]></code>
<assign value='"F"' property='target.{ORCgrp(1).OBR:ResultStatus}' action='set' />
<assign value='"F"' property='target.{ORCgrp(1).OBXgrp(1).OBX:ObservationResultStatus}' action='set' />
<assign value='"MDOC"' property='target.{ORCgrp(1).OBR:DiagnosticServSectID}' action='set' />
<assign value='"EDOCSSCAN"' property='target.{ORCgrp(1).OBR:FillerField1}' action='set' />
<assign value='source.systemID' property='target.{ORCgrp(1).OBR:FillerField2}' action='set' />
<assign value='source.systemID' property='target.{ORCgrp().OBR:FillerOrderNumber}' action='set' />
<assign value='2.3' property='target.{MSH:VersionID}' action='set' />
<assign value='source.creationDate' property='target.{ORCgrp(1).OBXgrp(1).OBX:DateTimeoftheObservation.timeofanevent}' action='set' />

<assign value='source.documentType' property='target.{ORCgrp().OBXgrp(1).OBX:ObservationIdentifier.text}' action='set' />
<code>
<![CDATA[ 
	/* ************************************************
	12/14/2016 EJL Issue with weird ascii character  
	***************************************************  */
]]></code>
<if condition='$LENGTH(source.docDescription) &gt; 2' >
<true>
<assign value='source.docDescription' property='target.{ORCgrp(1).OBR:UniversalServiceID.alternatetext}' action='set' />
</true>
</if>

</transform>
}

}
