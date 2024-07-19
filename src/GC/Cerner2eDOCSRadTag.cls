Class GC.Cerner2eDOCSRadTag Extends Ens.DataTransformDTL [ DependsOn = (EnsLib.HL7.Message, GC.eDOCS.RadTagDelimitedFile) ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='GC.eDOCS.RadTagDelimitedFile' sourceDocType='231.Cerner:ORU_R01' create='new' language='objectscript' >
<code>
<![CDATA[ 
	// Created 2016-12-08
	// For Cerner Radiology Results
	// Modified  :  
	// Moved to Prod: xx/xx/xxxx
	//  Source is readable multiple OBX's
	//  Map results to customer fields which will be used to create Tag and Doc files for OpenText eDOCS
	//  use lookup table T_eDOCS_IMGtype  to set DocumentWorktypeInit or default to first char of procedure code
	//  use lookup table T_CS_PatServCodes to set zPatientHospSrvCode
	//  Removed for Cerner: Trans.ID send XSPRT if blank otherwise use Lookup Table T_eDOCS_TnscrptCode to send Intials
	//  Send status of result into DocumentVersionComment and zAmmendedLabel by OBR_25 
	//      also if Addend is found in any OBX
	//  transcriptionist date obr 20 - FillerField1
	//  Send in results found in OBX as Findings
	// 	Send only 1 blank OBX if more than one found in a row
	//  Remove OBX if equals "[ " or "]"
	//  Format Observation datetime as "DATE OF SERVICE:  OCTOBER 07, 2009 0702"
	//  PID_18 Clear field if does not start with 6 or 5 (prod and dev account numbers)
	//  updated Addend logic to add Admend
	//  Check OBX_5 for for starting with "Electronically Signed" and use for DocumentDictator info
	//    note this logic needs to be tested with both PROD and DEV data as the templates may be different


]]></code>
<assign value='""' property='NLchar' action='set' />
<assign value='$char(13,10)' property='NLchar' action='set' />
<assign value='"CernerDocumentID="_NLchar' property='target.CernerDocumentID' action='set' />
<assign value='"PatientMRN="_source.{PID:PatientIdentifierList().ID}_NLchar' property='target.PatientMRN' action='set' />
<assign value='"PatientFirstName="_source.{PID:PatientName().givenname}_NLchar' property='target.PatientFirstName' action='set' />
<assign value='"PatientLastName="_source.{PID:PatientName().familylastname.familyname}_NLchar' property='target.PatientLastName' action='set' />
<assign value='"PatientMiddleInitial="_source.{PID:PatientName().middleinitialorname}_NLchar' property='target.PatientMiddleInitial' action='set' />
<if condition='source.{PID:DateTimeOfBirth.timeofanevent} = "" ' >
<true>
<assign value='"PatientDOB="_NLchar' property='target.PatientDOB' action='set' />
<assign value='""' property='target.zPatientDob' action='set' />
</true>
<false>
<assign value='source.{PID:DateofTimeBirth}' property='datein' action='set' />
<assign value='..SubString(source.{PID:DateTimeOfBirth.timeofanevent},5,6)_"/"_..SubString(source.{PID:DateTimeOfBirth.timeofanevent},7,8)_"/"_..SubString(source.{PID:DateTimeOfBirth.timeofanevent},1,4)' property='dob' action='set' />
<assign value='"PatientDOB="_dob_NLchar' property='target.PatientDOB' action='set' />
<assign value='dob' property='target.zPatientDob' action='set' />
</false>
</if>
<if condition='..StartsWith(source.{PID:18},"6") || ..StartsWith(source.{PID:18},"5" )|| ..StartsWith(source.{PID:18},"2" )' >
<true>
<assign value=' "EncounterID="_source.{PID:18}_NLchar ' property='target.EncounterID' action='set' />
</true>
<false>
<assign value=' "EncounterID="_NLchar ' property='target.EncounterID' action='set' />
</false>
</if>
<assign value=' "CernerDocumentID = "_NLchar ' property='target.CernerDocumentID ' action='set' />
<assign value='..SubString(source.{ORCgrp(1).OBR:7},5,6)_"/"_..SubString(source.{ORCgrp(1).OBR:7},7,8)_"/"_..SubString(source.{ORCgrp(1).OBR:7},1,4)' property='dos' action='set' />
<assign value=' "DateOfService="_dos_NLchar ' property='target.DateOfService' action='set' />
<assign value=' "ExtSourceDocumentID="_NLchar ' property='target.ExtSourceDocumentID' action='set' />
<assign value=' "SourceSystem=CernerPowerscribe"_NLchar ' property='target.SourceSystem' action='set' />
<assign value=' "RevisionCount= "_NLchar ' property='target.RevisionCount' action='set' />
<assign value=' "LastModifiedTime="_NLchar ' property='target.LastModifiedTime' action='set' />
<code>
<![CDATA[ 
  //  Check OBX_5 for for starting with "Electronically Signed" and use for DocumentDictator info
]]></code>
<assign value='""' property='tmpDictID' action='set' />
<assign value='""' property='tmpDictLast' action='set' />
<assign value='""' property='tmpDictFirst' action='set' />
<assign value=' "AuthorID= "_NLchar' property='target.AuthorID' action='set' />
<assign value=' "TranscriptionistID"_NLchar ' property='target.TranscriptionistID ' action='set' />
<assign value=' "TranscriptionistLastName "_NLchar ' property='target.TranscriptionistLastName ' action='set' />
<assign value=' "TranscriptionistFirstName="_NLchar ' property='target.TranscriptionistFirstName' action='set' />
<code>
<![CDATA[ 
  //  Loop thru the obx segments pick up Electronically Signed by info
  //  if the name of the signed by  is all the the name in the OBX:16 then use OBX 16 for the tag file
  //  if it doesn not match pull it from obx5.1
  //  Also concatinate the results 
]]></code>
<foreach property='source.{ORCgrp()}' key='k2' >
<foreach property='source.{ORCgrp(k2).OBXgrp()}' key='k1' >
<if condition='..Contains(source.{ORCgrp(k2).OBXgrp(k1).OBX:5(1).1(1)},"Signed by")' >
<true>
<code>
<![CDATA[ 
  //  ****************************************************
  //   True says Electronically  Sign by:  
  //  *****************************************************
]]></code>
<if condition='(..Contains(source.{ORCgrp(k2).OBXgrp(k1).OBX:5(1).1(1)},source.{ORCgrp(k2).OBXgrp(k1).OBX:16.2})&amp;&amp; ($LENGTH(source.{ORCgrp(k2).OBXgrp(k1).OBX:16.2})  &gt; 0 ) )' >
<true>
<code>
<![CDATA[ 
  //  ****************************************************
  //   OBX:16.2 is not blank 
  //  *****************************************************
]]></code>

<assign value=' "AuthorLastName="_source.{ORCgrp(k2).OBXgrp(k1).OBX:16.2}_NLchar ' property='target.AuthorLastName' action='set' />
<assign value=' "AuthorFirstName="_source.{ORCgrp(k2).OBXgrp(k1).OBX:16.3}_NLchar ' property='target.AuthorFirstName' action='set' />
</true>
<false><code>
<![CDATA[
 //  **************************************************************
  //   OBX:16.2 is   blank or OBX16.2 does not match name in signed
  //  *************************************************************
  ]]></code>
<code>
<![CDATA[
    //  does not match then pull name from Signed by text 
	//  Replace characters from OBX 5 Electronically Signed by: Jennifer Valiant 12/13/2016 14:49
	//  test2
	//  !-#$*:_?,/\;()with space also '"
	//  &and $C(38) %percent <less than >greater than =equal +plus @at
]]></code>
<assign value='""' property='Test' action='set' />
<assign value='$P(source.{ORCgrp(k2).OBXgrp(k1).OBX:5(1).1(1)},":",2)' property='Test' action='set' />
<assign value='$Translate(Test,"!-#$*:_?,/\;()"," ")' property='Test2' action='set' />
<assign value='..Strip(Test2,"=W")' property='Test2' action='set' />
<code>
<![CDATA[ 
  //  ****************************************************
  //    says Signed by: and garbage char are gone
  //  *****************************************************
]]></code>

<assign value='..Strip($P(Test2," ",2),"*WN")' property='tmpDictLast' action='set' />
<assign value='..Strip($P(Test2," ",1),"*WN")' property='tmpDictFirst' action='set' />
<code>
<![CDATA[ 
  //  ************************************************************
  //  if tmpDictFirst has no data Piece 1
  //  maybe there was a inexpected space try with piece 2 and 3
  //  ************************************************************
]]></code>
<if condition='$L(tmpDictFirst)&lt; 2 ' >
<true>
<assign value='..Strip($P(Test2," ",3),"*WN")' property='tmpDictLast' action='set' />
<assign value='..Strip($P(Test2," ",2),"*WN")' property='tmpDictFirst' action='set' />
</true>
</if>
  
 

<assign value=' "AuthorLastName="_tmpDictLast_NLchar ' property='target.AuthorLastName' action='set' />
<assign value=' "AuthorFirstName="_tmpDictLast_NLchar ' property='target.AuthorFirstName' action='set' />

</false> 

</if>
</true>
<false>
<code>
<![CDATA[ 
  //  ****************************************************
  //    default pick up OBX:16.2
  //  *****************************************************
]]></code>
<assign value=' "AuthorLastName="_source.{ORCgrp(k2).OBXgrp(k1).OBX:16.2}_NLchar ' property='target.AuthorLastName' action='set' />
<assign value=' "AuthorFirstName="_source.{ORCgrp(k2).OBXgrp(k1).OBX:16.3}_NLchar ' property='target.AuthorFirstName' action='set' />

</false>
</if>
</foreach>
</foreach>
<code>
<![CDATA[ 
	// Send status of result into  VersionComment and zAmmendedLabel by OBR_25 
	//  also if Addend is found in any OBX
	// code to cover various situations not sure if this will happen in PAC Cerner but will leave in. Ellen 04/18/2016
]]></code>
<assign value=' "" ' property='VersionComment' action='set' />
<assign value='" "' property='target.zAmmendedLabel' action='set' />
<if condition='source.{ORCgrp(1).OBR:25} = "P" ' >
<true>
<assign value='"PRELIMINARY REPORT"' property='VersionComment' action='set' />
</true>
</if>
<if condition='source.{ORCgrp(1).OBR:25} = "P" ' >
<true>
<assign value='"PRELIMINARY REPORT"' property='VersionComment' action='set' />
</true>
<false>
<assign value='"FINAL RESULT"' property='VersionComment' action='set' />
</false>
</if>
<if condition='..Contains(source.{ORCgrp(1).OBR:25},"C") ' >
<true>
<assign value='"AMENDED REPORT!"' property='target.zAmmendedLabel' action='set' />
<assign value='"AMENDED REPORT"' property='VersionComment' action='set' />
<assign value=' "RevisionCount= "_NLchar ' property='target.RevisionCount' action='set' />
</true>
</if>
<foreach property='source.{ORCgrp()}' key='k2' >
<foreach property='source.{ORCgrp(k2).OBXgrp()}' key='k1' >
<if condition='..Contains(source.{OBXgrp(k2):5(1)},"Addend") || ..Contains(source.{OBXi2(k2):5(1)},"Amend") || ..Contains(source.{OBXi2(k2):5(1)},"AMEND") ' >
<true>
<assign value='"AMENDED REPORT!"' property='target.zAmmendedLabel' action='set' />
<assign value='"AMENDED REPORT"' property='VersionComment' action='set' />
<assign value=' "RevisionCount= "_NLchar ' property='target.RevisionCount' action='set' />
</true>
</if>
</foreach>
</foreach>
<assign value=' "VersionComment="_VersionComment_NLchar ' property='target.VersionComment' action='set' />
<code>
<![CDATA[ 
    // <assign value=' ""_NLchar ' property='target.TransID' action='set' />
    //  Trans.ID send XSPRT if blank otherwise use Lookup Table T_eDOCS_TnscrptCode to send Intials

	//  <assign value='""' property='tmpTransID' action='set' />
	//  <assign value='..Lookup("T_eDOCS_TnscrptCode",source.{ORCgrp(1).OBR:35(1).1.1},source.{ORCgrp(1).OBR:35(1).1.1})' property='tmpTransID' action='set' />
	//  <if condition='$LENGTH(tmpTransID) &lt; 1  ' >
	//  <true>
	//  <assign value='"Trans.ID=XSPRT"_NLchar' property='target.TransID' action='set' />
	//  </true>
	//  <false>
	//  <assign value='"Trans.ID="_tmpTransID_NLchar' property='target.TransID' action='set' />
	//  </false>
	//  </if>
]]></code>
<assign value='"ExtSourceDocumentID="_..SubString(source.{ORCgrp(1).OBR:FillerOrderNumber.entityidentifier},1,20)_NLchar' property='target.ExtSourceDocumentID' action='set' />
<code>
<![CDATA[ 
	// transcriptionist date obr 20 - FillerField1
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
	// Send in worktype as first character of procedure code sent
	//  Use lookup table T_eDOCS_IMGtype for exceptions to rule
]]></code>
<assign value='""' property='WorkType' action='set' />
<assign value='""' property='Type' action='set' />

<assign value='..SubString(source.{ORCgrp(1).OBR:4.1},1,1)' property='Type' action='set' />

<if condition='..SubString(source.{ORCgrp(1).OBR:4.1},1,6) = "OS MRI" ' >
<true>
<assign value='"M"' property='Type' action='set' />
</true>
</if>
<if condition='..SubString(source.{ORCgrp(1).OBR:4.1},1,5) = "OS XR" ' >
<true>
<assign value='"X"' property='Type' action='set' />
</true>
</if>
<if condition='..SubString(source.{ORCgrp(1).OBR:4.1},1,5) = "OS US" ' >
<true>
<assign value='"U"' property='Type' action='set' />
</true>
</if>
<if condition='..SubString(source.{ORCgrp(1).OBR:4.1},1,5) = "OS CT" ' >
<true>
<assign value='"C"' property='Type' action='set' />
</true>
</if>

<assign value='..Lookup("T_eDOCS_IMGtype",source.{ORCgrp(1).OBR:4.1},Type)' property='WorkType' action='set' />
<if condition='$LENGTH(WorkType) &lt; 2  ' >
<true>
<assign value='..Lookup("T_eDOCS_IMGtype",Type)' property='WorkType' action='set' />
</true>
</if>
<assign value='"DocumentType="_WorkType_NLchar' property='target.DocumentType' action='set' />
<assign value='"0"' property='OBXFindings' action='set' />
<code>
<![CDATA[ 
	// Send in results found in OBX as Findings
	// Send only 1 blank OBX if more than one found in a row
	//  Remove OBX if equals "[ " or "]"
]]></code>
<foreach property='source.{ORCgrp()}' key='k2' >
<foreach property='source.{ORCgrp(k2).OBXgrp()}' key='k1' >
<if condition='OBXFindings = k1' >
<false>
<if condition='source.{ORCgrp(k2).OBXgrp(k1).OBX:5(1)} = source.{ORCgrp(k2).OBXgrp(k1-1).OBX:5(1)}' >
<false>
<if condition='..In(source.{ORCgrp(k2).OBXgrp(k1).OBX:5(1)},"] ,[ ")' >
<false>
<assign value='target.zFindings_source.{ORCgrp(k2).OBXgrp(k1).OBX:5(1)}_"{\par}"' property='target.zFindings' action='set' />
<assign value='OBXFindings+1' property='OBXFindings' action='set' />
</false>
</if>
</false>
</if>
</false>
</if>
</foreach>
</foreach>
<code>
<![CDATA[ 
	// test <assign value='source.{ORCgrp(1).OBR:FillerOrderNumber.entityidentifier}' property='target.zFindings' action='set' />
]]></code>
<assign value='source.{ORCgrp(1).OBR:OrderingProvider().familylastname}_", "_source.{ORCgrp(1).OBR:OrderingProvider(1).givenname}_" "_source.{ORCgrp(1).OBR:OrderingProvider(1).middleinitialorname}' property='target.zOrderingDoctorName' action='set' />
<assign value='source.{PID:PatientName().givenname}' property='target.zPatientNameFirst' action='set' />
<assign value='source.{PID:PatientName().middleinitialorname}' property='target.zPatientNameMI' action='set' />
<assign value='source.{PID:PatientName().familylastname.familyname}' property='target.zPatientNameLast' action='set' />
<assign value='source.{PID:PatientIdentifierList().ID}' property='target.zPatientMrn' action='set' />
<assign value='..Lookup("T_CS_PatLocationCodes",source.{PV1:AssignedPatientLocation.facilityHD},source.{PV1:AssignedPatientLocation.facilityHD})' property='target.zPatientHospSrvCode' action='set' />
<code>
<![CDATA[ 
	// Format Observation datetime as "DATE OF SERVICE:  OCTOBER 07, 2009 0702"
	//<assign value='$REPLACE(tmpOBX51,"}ZZZZ","")' property='target.zOBX51' action='set' />
]]></code>
<if condition='source.{ORCgrp(1).OBR:ObservationEndDateTime.timeofanevent}= "" ' >
<true>
<assign value='""' property='target.zObservationEndDate' action='set' />
</true>
<false>
<assign value='..SubString(source.{ORCgrp(1).OBR:ObservationEndDateTime.timeofanevent},1,4)_"-"_..SubString(source.{ORCgrp(1).OBR:ObservationEndDateTime.timeofanevent},5,6)_"-"_..SubString(source.{ORCgrp(1).OBR:ObservationEndDateTime.timeofanevent},7,8)' property='tmpMonth' action='set' />
<assign value='$SYSTEM.SQL.MONTHNAME(tmpMonth)_" "_..SubString(source.{ORCgrp(1).OBR:ObservationEndDateTime.timeofanevent},7,8)_", "_..SubString(source.{ORCgrp(1).OBR:ObservationEndDateTime.timeofanevent},1,4)_" "_..SubString(source.{ORCgrp(1).OBR:ObservationEndDateTime.timeofanevent},9,12)' property='target.zObservationEndDate' action='set' />
</false>
</if>
<code>
<![CDATA[ 
  /*  took this out 
	<assign value='""' property='tmpNote' action='set' />
	<assign value='""' property='combineNote' action='set' />
	<assign value='""' property='target.zNTESign' action='set' />
	<foreach property='source.{ORCgrp(1).OBXgrp(1).NTE()}' key='k3' >
	<if condition='source.{ORCgrp(1).OBXgrp(1).NTE(k3):SourceOfComment(1)}= "SIGN LINE"' >
	<true>
	<assign value='source.{ORCgrp(1).OBXgrp(1).NTE(k3):Comment(1)}' property='tmpNote' action='set' />
	<assign value='$REPLACE(tmpNote,"\.br\","\par ")' property='tmpNote' action='set' />
	<assign value='combineNote_tmpNote' property='combineNote' action='set' />
	</true>
	</if>
	</foreach>
 */		 
  ]]></code>
<assign value='source.{ORCgrp(1).OBXgrp(1).OBX:ObservationValue(1)}' property='target.zOBX51' action='set' />
<code>
<![CDATA[ 
   /*  // took this out 
	<if condition='target.zNTESign =  "" ' >
	<true>
	<assign value='source.{ORCgrp(1).OBXgrp(1).OBX:ObservationValue(1)}' property='target.zOBX51' action='set' />
	</true>
	<false>
	<assign value='source.{ORCgrp(1).OBXgrp(1).OBX:ObservationValue(1)}_"ZZZZ"_combineNote_"}"' property='tmpOBX51' action='set' />
	<assign value='$REPLACE(tmpOBX51,"}ZZZZ","")' property='target.zOBX51' action='set' />
	</false>
	</if>
	*/
  //Save the report to the ResultData property of the target object
  /* Try { 
         set sourceStream = ##class(%Stream.GlobalCharacter).%New()
         do sourceStream.%Save()
         set tSC2 = source.GetFieldStreamRaw(.sourceStream, "ORCgrp(1).OBXgrp(1).OBX:5")
         set streamSize = sourceStream.SizeGet()
         if (streamSize >= 1 ) {
             set target.zOBX51 = ##class(%Stream.GlobalCharacter).%New()
             do target.zOBX51.%Save()
             set tSC = target.zOBX51.CopyFrom(sourceStream)
             do target.zOBX51.%Save()
         }else {
             set tSC = target.zOBX51.Write(" ")
                }
} Catch errobj { 
             Set target.zOBX51= " " 
                                }  */		 
  ]]></code>
<assign value='source.{MSH:DateTimeOfMessage.timeofanevent}' property='tmpDateTime' action='set' />
<assign value='($REPLACE(source.{MSH:MessageControlID},".","_"))' property='tmpMSGCNTRL' action='set' />
<assign value='tmpMSGCNTRL_"_"_tmpDateTime' property='target.zTagfilename' action='set' />
</transform>
}

}
