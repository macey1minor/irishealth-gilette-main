Class GC.eDOCS.RadCreateTagDocBO Extends Ens.BusinessOperation [ ProcedureBlock ]
{

// Last Updated: 

// Moved to Prod - xx/xx/xxxx

// copied from Dev 02/16/2016 last update in Dev 02/09/2015

// Create: 07/28/2016 Ellen Leichtman

//    Description: Final signed Rafiology results for Edocs

//                 Covert Fields from the DTL into Doc and Tag file for eDOCS

//    using GC.eDOCS.RadTagDelimitedFile

//    Properties starting with z and COLNUM => 400 are not used in TAG file; used for the Word doc 

//    using Msg control id with date

Parameter ADAPTER = "GC.eDOCS.RadFileOutboundAdapter";

Parameter INVOCATION = "Queue";

// Path of template

Property eDocsTextOut As %FileCharacterStream;

Property eDocsTextTmp As %FileCharacterStream;

Property TmpString As %String;

Property Filename As %String;

// my custom BO properties

Property TemplateFilePath As %String(MAXLEN = 256);

Property TargetFilePath As %String(MAXLEN = 256);

Property ArchiveFilePath As %String(MAXLEN = 256);

// http://172.25.50.143:57773/csp/docbook/DocBook.UI.Page.cls?KEY=EGDV_prog#EGDV_prog_settings

Parameter SETTINGS As %String = "TemplateFilePath,TargetFilePath,ArchiveFilePath";

Method writeFlatMessage(pRequest As GC.eDOCS.RadTagDelimitedFile, Output pResponse As Ens.StringResponse) As %Status
{
  $$$TRACE("EJL called writeFlatMessag")
  Set $ZT="Trap",tSC=$$$OK
  // get acession for tag name img_1013114801_43638.tag
  set accession = pRequest.ExtSourceDocumentID
  set accession =$PIECE(accession,"=",*) ; returns  the last substring
  //set accession =$Replace(accession," ","")
  set accession =$Extract(accession,1,13)
  $$$TRACE("accession"_accession)
  // Create archive path and name
  // set accession ="EllenTest"  //10XR160000571
  set templateFilePath=(..TemplateFilePath)
  set targetFilePath=(..TargetFilePath)
  set archivePath=(..ArchiveFilePath)
  // Use YYMMDDHHMMmmm for counter see z_filename
  set filename = "img_"_accession_"_"_pRequest.zTagfilename
  set TagfileName = targetFilePath_filename_".tag"
  set TagfileNameArchive  = archivePath_filename_".tag"
  set DocfileName = targetFilePath_filename_".doc"
  set DocfileNameArchive  = archivePath_filename_".doc"
  //  create doc file by reading in template and replacing place holders with data.
  set streamin = ""
  set DocName = templateFilePath
  //set DocName = ^GCH.eDOCSPathTemplateIMG  // see Global for path "D:\Files\Dir_Dev\Resources\IMG_eDOCS_V2.template"
  set id=##class(%FileCharacterStream).GetStreamIdForFile(DocName ) 
  set streamin=##class(%FileCharacterStream).%Open(id) 
  //  create and open the output files
  //
  // Open a stream for Prod and Archive for final doc 
  //
  set streamout = ""
  set idOut=##class(%FileCharacterStream).GetStreamIdForFile(DocfileName) 
  set idOutArchive=##class(%FileCharacterStream).GetStreamIdForFile(DocfileNameArchive)  
  set streamout=##class(%FileCharacterStream).%Open(idOut) 
  set streamoutArchive=##class(%FileCharacterStream).%Open(idOutArchive) 
  Set finalDoc = ""
  // $$$LOGINFO("start read in eDOCS template")
  While 'streamin.AtEnd {
 	set tmpDoc = streamin.Read(5000)
 	 set finalDoc = tmpDoc
 	 set finalDoc = $Replace(finalDoc,"zPatientNameLast", pRequest.zPatientNameLast)
     set finalDoc = $Replace(finalDoc,"zPatientNameFirst", pRequest.zPatientNameFirst)
	 set finalDoc = $Replace(finalDoc,"zPatientNameMI", pRequest.zPatientNameMI)
	 set finalDoc = $Replace(finalDoc,"zPatientMrn", pRequest.zPatientMrn)
	 set finalDoc = $Replace(finalDoc,"zPatientDob", pRequest.zPatientDob)
	 set finalDoc = $Replace(finalDoc,"zPatientHospSrvCode", pRequest.zPatientHospSrvCode)
	 set finalDoc = $Replace(finalDoc,"zObservationEndDate", pRequest.zObservationEndDate)
	 set finalDoc = $Replace(finalDoc,"zAmmendedLabel", pRequest.zAmmendedLabel)
	 set finalDoc = $Replace(finalDoc,"zOrderingDoctorName", pRequest.zOrderingDoctorName)
	 set finalDoc = $Replace(finalDoc,"zFindings", pRequest.zFindings)
	//set finalDoc = ReplaceVars(tmpDoc, pRequest)
	DO streamout.Write(finalDoc)
	 // $$$LOGINFO("stream out fina ldoc")
	DO streamoutArchive.Write(finalDoc)
	// $$$LOGINFO("archive stream out final doc") 
  }
  DO streamout.%Save()
  DO streamoutArchive.%Save()
  //clear temp variables Do we need to do this?
  set streamout = ""
  set streamoutArchive = ""
  set streamin = ""
  set finalDoc = ""
  //$$$TRACE("EJL after streamout")
  // write the tag file with complete path and file name
  // using custome method that calls openCustom(
  set st=..Adapter.PutLineCustom(TagfileName,pRequest.OutputLine())
  set st=..Adapter.PutLineCustom(TagfileNameArchive,pRequest.OutputLine())
  //$$$TRACE("EJL After PutLineCustom")
  set eDocsTextOut = ""
Exit
	Quit tSC
Trap
 	Set $ZT=""
 	set streamout = ""
 	set streamoutArchive = ""
  	set streamin = ""
 	set finalDoc = ""
    set eDocsTextOut = ""
	Goto Exit
}

Method OnMessage(pRequest As GC.eDOCS.RadTagDelimitedFile, Output pResponse As %Persistent) As %Status
{
	Set tFilename=..Adapter.CreateTimestamp(##class(%File).GetFilename(pRequest.Stream.Attributes("Filename")),..Filename)
	Set tSC=..Adapter.PutStream(tFilename, pRequest.Stream)
	Do pRequest.%Save() ; re-save in case PutStream() optimization changed the Stream filename
	Quit tSC
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="GC.eDOCS.RadTagDelimitedFile"> 
		<Method>writeFlatMessage</Method>
	</MapItem>
</MapItems>
}

}
