Class GC.Nuance2eDOCSTagRevA Extends Ens.DataTransformDTL [ DependsOn = (EnsLib.HL7.Message, GC.eDOCS.TAGDelimitedFileNuance) ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='GC.eDOCS.TAGDelimitedFileNuance' sourceDocType='231.Cerner:ORU_R01' create='new' language='objectscript' >
<code>
<![CDATA[ 
	// Last Updated: 02/03/2017 Al Johnson
	// Moved to Prod: 02/10/2017
	//    Description: 
	//  Map results to customer fields which will be used to create Tag and Doc files for OpenText eDOCS
	//    Cerner upgrade - Nuance sends documents to Cerner, they are signed in Cerner then sent to eDOCS
	//                     Nuance sends MDM, Cerner sends ORU with rtf in OBX(1)-5.5
	//                     Additional documents originate in Cerner and are sent to eDOCS
	//               Imaging Documents are handled by GC.Carestream2eDOCSTag.dtl
	//
	//     Requested Tag fields PatientMRN, PatientLastName, PatientFirstName, PatientDOB, EncounterID, DateOfService, CernerDocumentID,
	//                          SourceSystem, AuthorID, DocumentType
	//                    Questioned - AttendingProvider, AdditionalProvider, EventDate, AdmitDate
	//                    NiceToHave - TranscriptionistID, TranscriptionistLastName, TranscriptionistFirtName
	//                                 ExtSourceDocumentID, RevisionCount, VersionComment, LastModifiedTime, AuthorLastName, AuthorFirstName
	//
	//  Trans.ID send XSPRT if blank otherwise use Lookup Table T_eDOCS_TnscrptCode to send Intials
	//  Send status of result into DocumentVersionComment and zAmmendedLabel by OBR_25 
	//      also if Addend is found in any OBX
	//  transcriptionist date obr 20 - FillerField1
	//  Send in results found in OBX as Findings
	//  updated Addend logic to add Admend
	//
	//  Signature will come in on NTE segment
	//
	//  Take author name from OBR-32 do not populate authorid
]]></code>
<assign value='""' property='NLchar' action='set' />
<assign value='$char(13,10)' property='NLchar' action='set' />
<assign value='"PatientMRN="_source.{PID:PatientIdentifierList().ID}_NLchar' property='target.PatientMRN' action='set' />
<assign value='"PatientLastName="_source.{PID:PatientName().familylastname.familyname}_NLchar' property='target.PatientLastName' action='set' />
<assign value='"PatientFirstName="_source.{PID:PatientName().givenname}_NLchar' property='target.PatientFirstName' action='set' />
<assign value='"PatientMiddleInitial="_source.{PID:PatientName().middleinitialorname}_NLchar' property='target.PatientMiddleInitial' action='set' />
<if condition='source.{PID:DateTimeOfBirth.timeofanevent} = "" ' >
<true>
<assign value='"PatientDOB="_NLchar' property='target.PatientDOB' action='set' />
</true>
<false>
<assign value='source.{PID:DateofTimeBirth}' property='datein' action='set' />
<assign value='..SubString(source.{PID:DateTimeOfBirth.timeofanevent},5,6)_"/"_..SubString(source.{PID:DateTimeOfBirth.timeofanevent},7,8)_"/"_..SubString(source.{PID:DateTimeOfBirth.timeofanevent},1,4)' property='dob' action='set' />
<assign value='"PatientDOB="_dob_NLchar' property='target.PatientDOB' action='set' />
</false>
</if>

<assign value=' "EncounterID="_source.{PID:18}_NLchar ' property='target.EncounterID' action='set' />

<assign value='..SubString(source.{ORCgrp(1).OBR:7},5,6)_"/"_..SubString(source.{ORCgrp(1).OBR:7},7,8)_"/"_..SubString(source.{ORCgrp(1).OBR:7},1,4)' property='dos' action='set' />
<assign value=' "DateOfService="_dos_NLchar ' property='target.DateOfService' action='set' />

<assign value=' "SourceSystem=CERNER"_NLchar ' property='target.SourceSystem' action='set' />

<assign value=' "DocumentType="_source.{ORCgrp(1).OBR:4.1}_NLchar ' property='target.DocumentType' action='set' />

<assign property='OBXcount' value='source.{ORCgrp(1).OBXgrp(*)}' action='set'/>
<assign value=' "RevisionCount="_OBXcount_NLchar ' property='target.RevisionCount' action='set' />
<assign value=' "VersionComment="_NLchar ' property='target.VersionComment' action='set' />

<assign value='""' property='tmpCernerMSHkeys' action='set' />
<assign value='(source.{MSH:DateTimeOfMessage.timeofanevent})_(source.{MSH:MessageControlID})' property='tmpCernerMSHkeys' action='set' />
<assign value='""' property='tmpCernerID' action='set' />
<assign value='""' property='tmpNuanceTID' action='set' />
<foreach property='source.{ORCgrp(1).ORC:3()}' key='k1' >
<if condition='source.{ORCgrp(1).ORC:FillerOrderNumber(k1).namespaceID} = "HNAM_CEREF"' >
<true>
<assign value='source.{ORCgrp(1).ORC:FillerOrderNumber(k1).entityidentifier}' property='tmpNuanceTID' action='set' />
</true>
<false>
<if condition='source.{ORCgrp(1).ORC:FillerOrderNumber(k1).namespaceID} = "HNAM_EVENTID"' >
<true>
<assign value='source.{ORCgrp(1).ORC:FillerOrderNumber(k1).entityidentifier}' property='tmpCernerID' action='set' />
</true>
</if>
</false>
</if>
</foreach>
<assign value=' "ExtSourceDocumentID="_tmpNuanceTID_NLchar ' property='target.ExtSourceDocumentID' action='set' />
<assign value=' "CernerDocumentID="_tmpCernerID_NLchar ' property='target.CernerDocumentID' action='set' />

<code>
<![CDATA[
    // set zTagfilename to unique Cerner id - use to name doc and tag file
    // set zMSH10andMSH7 to MSH-10 and MSH-7.1 to make unique name for doc and tag
]]></code>
<assign value='tmpCernerID' property='target.zTagfilename' action='set' />
<assign value='tmpCernerMSHkeys' property='target.zMSH10andMSH7' action='set' />

<code>
<![CDATA[ 
	// Send status of result into DocumentVersionComment and zAmmendedLabel by OBR_25 
	//  also if Addend is found in any OBX
	// <assign value='source.{ORCgrp(1).OBR:25}' property='VersionComment' action='set' />
    // <assign value=' "Document.VersionComment="_VersionComment_NLchar ' property='target.DocumentVersionComment' action='set' />
    //
    //  take author form zds perform, if blank take obr-34 Technician
    //   obr-34 principal result interpreter - joel is populating signed by - if he has it
    //  removed author from zds perform - take from obr-32
    //  <foreach property='source.{ORCgrp(1).ZDS(k2):ClinicalStaff()}' key='k4' >
    //  <if condition='source.{ORCgrp(1).ZDS(k2):ClinicalStaff(k4).assigningauthority} = "Doctor Nbr"' >
    //  <true>
    //  <assign value='source.{ORCgrp(1).ZDS(k2):ClinicalStaff(k4).IDNumberST}' property='tmpAuthorID' action='set' />
    //  <assign value='source.{ORCgrp(1).ZDS(k2):ClinicalStaff(k4).familyname}' property='tmpAuthorLastNM' action='set' />
    //  <assign value='source.{ORCgrp(1).ZDS(k2):ClinicalStaff(k4).givenname}' property='tmpAuthorFirstNM' action='set' />
    //  </true>
    //  </if>
    //  </foreach>
]]></code>

<assign value='""' property='tmpAuthorID' action='set' />
<assign value='""' property='tmpAuthorLastNM' action='set' />
<assign value='""' property='tmpAuthorFirstNM' action='set' />
<assign value='""' property='tmpTransID' action='set' />
<assign value='""' property='tmpTransLastNM' action='set' />
<assign value='""' property='tmpTransFirstNM' action='set' />
<assign value='""' property='tmpSignID' action='set' />
<assign value='""' property='tmpSignLastNM' action='set' />
<assign value='""' property='tmpSignFirstNM' action='set' />



<foreach property='source.{ORCgrp(1).ZDS()}' key='k2' >
<if condition='source.{ORCgrp(1).ZDS(k2):ActionCode} = "Perform"' >
<true>
<foreach property='source.{ORCgrp(1).ZDS(k2):ClinicalStaff()}' key='k4' >
<if condition='source.{ORCgrp(1).ZDS(k2):ClinicalStaff(k4).assigningauthority} = "Doctor Nbr"' >
<true>
<assign value='source.{ORCgrp(1).ZDS(k2):ClinicalStaff(k4).IDNumberST}' property='tmpAuthorID' action='set' />
<assign value='source.{ORCgrp(1).ZDS(k2):ClinicalStaff(k4).familyname}' property='tmpAuthorLastNM' action='set' />
<assign value='source.{ORCgrp(1).ZDS(k2):ClinicalStaff(k4).givenname}' property='tmpAuthorFirstNM' action='set' />
</true>
</if>
</foreach>
</true>
<false>
<if condition='source.{ORCgrp(1).ZDS(k2):ActionCode} = "Transcribe"' >
<true>
<foreach property='source.{ORCgrp(1).ZDS(k2):ClinicalStaff()}' key='k5' >
<if condition='source.{ORCgrp(1).ZDS(k2):ClinicalStaff(k5).assigningauthority} = "Doctor Nbr"' >
<true>
<assign value='source.{ORCgrp(1).ZDS(k2):ClinicalStaff(k5).IDNumberST}' property='tmpTransID' action='set' />
<assign value='source.{ORCgrp(1).ZDS(k2):ClinicalStaff(k5).familyname}' property='tmpTransLastNM' action='set' />
<assign value='source.{ORCgrp(1).ZDS(k2):ClinicalStaff(k5).givenname}' property='tmpTransFirstNM' action='set' />
</true>
</if>
</foreach>
</true>
<false>
<if condition='source.{ORCgrp(1).ZDS(k2):ActionCode} = "Sign"' >
<true>
<foreach property='source.{ORCgrp(1).ZDS(k2):ClinicalStaff()}' key='k6' >
<if condition='source.{ORCgrp(1).ZDS(k2):ClinicalStaff(k6).assigningauthority} = "Doctor Nbr"' >
<true>
<assign value='source.{ORCgrp(1).ZDS(k2):ClinicalStaff(k6).IDNumberST}' property='tmpSignID' action='set' />
<assign value='source.{ORCgrp(1).ZDS(k2):ClinicalStaff(k6).familyname}' property='tmpSignLastNM' action='set' />
<assign value='source.{ORCgrp(1).ZDS(k2):ClinicalStaff(k6).givenname}' property='tmpSignFirstNM' action='set' />
</true>
</if>
</foreach>
</true>
</if>
</false>
</if>
</false>
</if>
</foreach>

<if condition='tmpAuthorLastNM=""' >
<true>
<assign value='source.{ORCgrp(1).OBR:Technician(1).name.familyname}' property='tmpAuthorLastNM' action='set' />
<assign value='source.{ORCgrp(1).OBR:Technician(1).name.givenname}' property='tmpAuthorFirstNM' action='set' />
</true>
</if>

<if condition='tmpAuthorLastNM=""' >
<true>
<assign value='source.{ORCgrp(1).OBR:PrincipalResultInterpreter.name.familyname}' property='tmpAuthorLastNM' action='set' />
<assign value='source.{ORCgrp(1).OBR:PrincipalResultInterpreter.name.givenname}' property='tmpAuthorFirstNM' action='set' />
</true>
</if>

<assign value=' "AuthorID="_tmpAuthorID_NLchar ' property='target.AuthorID' action='set' />
<assign value=' "AuthorLastName="_tmpAuthorLastNM_NLchar ' property='target.AuthorLastName' action='set' />
<assign value=' "AuthorFirstName="_tmpAuthorFirstNM_NLchar ' property='target.AuthorFirstName' action='set' />

<assign value=' "TranscriptionistID="_tmpTransID_NLchar ' property='target.TranscriptionistID' action='set' />
<assign value=' "TranscriptionistLastName="_tmpTransLastNM_NLchar ' property='target.TranscriptionistLastName' action='set' />
<assign value=' "TranscriptionistFirstName="_tmpTransFirstNM_NLchar ' property='target.TranscriptionistFirstName' action='set' />

<code>
<![CDATA[ 
  $$$TRACE("Sign="_tmpSignID_" "_tmpTransID_" "_tmpAuthorID)
  //  Trans.ID send XSPRT if blank otherwise use Lookup Table T_eDOCS_TnscrptCode to send Intials
  //   -- ? Nuance Data
]]></code>
<code>
<![CDATA[ 
  // <assign value='""' property='tmpTransID' action='set' />
  // <assign value='..Lookup("T_eDOCS_TnscrptCode",source.{ORCgrp(1).OBR:35(1).1},source.{ORCgrp(1).OBR:35(1).1})' property='tmpTransID' action='set' />
  // <if condition='$LENGTH(tmpTransID) &lt; 1  ' >
  // <true>
  // <assign value='"Trans.ID=XSPRT"_NLchar' property='target.TransID' action='set' />
  // </true>
  // <false>
  // <assign value='"Trans.ID="_tmpTransID_NLchar' property='target.TransID' action='set' />
  // </false>
  // </if>
]]></code>

<if condition='source.{ORCgrp(1).OBR:ResultsRptStatusChngDateTime.timeofanevent} = "" ' >
<true>
<assign value='"LastModifiedTime="_NLchar' property='target.LastModifiedTime' action='set' />
</true>
<false>
<assign value='"LastModifiedTime="_..SubString(source.{ORCgrp(1).OBR:ResultsRptStatusChngDateTime.timeofanevent},5,6)_"/"_..SubString(source.{ORCgrp(1).OBR:ResultsRptStatusChngDateTime.timeofanevent},7,8)_"/"_..SubString(source.{ORCgrp(1).OBR:ResultsRptStatusChngDateTime.timeofanevent},1,4)_" "_..SubString(source.{ORCgrp(1).OBR:ResultsRptStatusChngDateTime.timeofanevent},9,10)_":"_..SubString(source.{ORCgrp(1).OBR:ResultsRptStatusChngDateTime.timeofanevent},11,12)_":"_..SubString(source.{ORCgrp(1).OBR:ResultsRptStatusChngDateTime.timeofanevent},13,14)_NLchar' property='target.LastModifiedTime' action='set' />
</false>
</if>

<code>
<![CDATA[ 
	// Send in results found in OBX as Findings
	// Find signature line in NTE segment
	// rtf in OBX(1)-5.5 ends in }; insert signature line
	// rtf has ~ - removed by GC.TildeReplace
	//  if problems parsing out 5.5 check orig data for ~,^ that would cause truncation
	// <assign value='source.{ORCgrp(1).OBXgrp(1).OBX:5()}' property='target.zFindings' action='set' />
	
	//  extract each obx in its entirety, remove beginning { and ending }
	//  append signature line
	//  repeat for each obx/nte group
	//  add beginning { and ending } when done
	
	//   HIM,REGISTRATION\line MRN: 201504 \line DOB/Age/Sex: 06/06/2006   10 years   Female\line\line FIN:  20001721\line\line}
]]></code>

<assign value='"{\par Gillette Childrens Specialty Hospital\line\line Patient: "' property='holdhdg1a' action='set' />
<assign value='"\line MRN: "' property='holdhdg1b' action='set' />
<assign value='" \line DOB: "' property='holdhdg1c' action='set' />
<assign value='"\line\line FIN: "' property='holdhdg1d' action='set' />

<assign value='""' property='holdhdg1derr' action='set' />
<if condition='source.{ORCgrp(1).OBR:ResultStatus}="INERROR"' >
<true>
<assign value='"\line\line ** IN ERROR ** "' property='holdhdg1derr' action='set' />
</true>
</if>

<assign value='source.{PID:PatientIdentifierList().ID}' property='hdg1MRN' action='set' />
<assign value='source.{PID:PatientName().familylastname.familyname}' property='hdg1LastNM' action='set' />
<assign value='source.{PID:PatientName().givenname}' property='hdg1FirstNM' action='set' />

<if condition='source.{PID:DateTimeOfBirth.timeofanevent} = "" ' >
<true>
<assign value='"  /  /    "' property='hdg1DOB' action='set' />
</true>
<false>
<assign value='..SubString(source.{PID:DateTimeOfBirth.timeofanevent},5,6)_"/"_..SubString(source.{PID:DateTimeOfBirth.timeofanevent},7,8)_"/"_..SubString(source.{PID:DateTimeOfBirth.timeofanevent},1,4)' property='hdg1DOB' action='set' />
</false>
</if>

<assign value='source.{PID:18}' property='hdg1FIN' action='set' />

<assign value='holdhdg1a_hdg1LastNM_","_hdg1FirstNM_holdhdg1b_hdg1MRN_holdhdg1c_hdg1DOB_"  "_holdhdg1d_hdg1FIN_holdhdg1derr_"\line\par}"' property='tmphdg' action='set' />

<assign value='""' property='target.zNTESign' action='set' />
<assign value='""' property='target.zFindings' action='set' />
<assign value='""' property='target.zFindingsComb' action='set' />

<assign value='""' property='tmprtfdoc' action='set' />
<foreach property='source.{ORCgrp(1).OBXgrp().OBX}' key='k3' >
<assign value='""' property='tmprtflength' action='set' />
<assign value='""' property='tmprtfdoc1' action='set' />
<assign value='$LENGTH(source.{ORCgrp(1).OBXgrp(k3).OBX:5(1).5})' property='tmprtflength' action='set' />
<assign value='$EXTRACT(source.{ORCgrp(1).OBXgrp(k3).OBX:5(1).5},2,tmprtflength-1)' property='tmprtfdoc1' action='set' />
<assign value='tmprtfdoc_tmprtfdoc1' property='tmprtfdoc' action='set' />
<assign value='""' property='tmpNote' action='set' />
<foreach property='source.{ORCgrp(1).OBXgrp(k3).NTE()}' key='k7' >
<if condition='source.{ORCgrp(1).OBXgrp(k3).NTE(k7):SourceOfComment(1)} = "SIGN LINE"' >
<true>
<assign value='source.{ORCgrp(1).OBXgrp(k3).NTE(k7):Comment(1)}' property='tmpNote' action='set' />
<assign value='tmpNote_"\line\line"' property='tmpNote' action='set' />
<assign value='$REPLACE(tmpNote,"\.br\","\par ")' property='tmpNote' action='set' />
<assign value='tmpNote' property='target.zNTESign' action='set' />
<assign value='tmprtfdoc_tmpNote' property='tmprtfdoc' action='set' />
</true>
</if>
</foreach>
</foreach>

<code>
<![CDATA[ 
	// $FIND returns next character posistion following returned column
	// inserting hdg after 1st {\*\generator TX_RTF32 18.0.541.501;}
	//  <assign value='"{"_tmprtfdoc_"}"' property='target.zFindingsComb' action='set' />
]]></code>
<assign value='$LENGTH(tmprtfdoc)' property='tmprtftotallength' action='set' />
<assign value='$FIND(tmprtfdoc,"\generator")' property='tmpgeneratorpos' action='set' />
<assign value='$FIND(tmprtfdoc,"}",tmpgeneratorpos)' property='tmpgeneratorposbrk' action='set' />

<assign value='$EXTRACT(tmprtfdoc,1,tmpgeneratorposbrk-1)' property='tmprtfpart1' action='set' />
<assign value='$EXTRACT(tmprtfdoc,tmpgeneratorposbrk,tmprtftotallength)' property='tmprtfpart2' action='set' />
<assign value='"{"_tmprtfpart1_tmphdg_tmprtfpart2_"}"' property='target.zFindingsComb' action='set' />

</transform>
}

}
