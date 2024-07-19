Class GC.eDOCS.NuanceCreateTagDocBO Extends Ens.BusinessOperation [ ProcedureBlock ]
{

// Last Updated: 

// Moved to Prod - xx/xx/xxxx

// copied from Dev 02/16/2016 last update in Dev 02/09/2015

// Create: 07/29/2016 Al Johnson

//    Description: Final signed Nuance results for Edocs

//                 Covert Fields from the DTL into Doc and Tag file for eDOCS

//    using GCH.eDOCS.TAGDelimitedFileImaging

//    Properties starting with z and COLNUM => 400 are not used in TAG file; used for the Word doc 

//    using Global for counters

//    File name created in dtl.

Parameter ADAPTER = "GC.eDOCS.NuanceFileOutboundAdapter";

Parameter INVOCATION = "Queue";

// Path of template

Property eDocsTextOut As %FileCharacterStream;

Property eDocsTextTmp As %FileCharacterStream;

Property TmpString As %String;

Property Filename As %String;

// my custom BO properties

Property TargetFilePath As %String(MAXLEN = 256);

Property ArchiveFilePath As %String(MAXLEN = 256);

// http://172.25.50.143:57773/csp/docbook/DocBook.UI.Page.cls?KEY=EGDV_prog#EGDV_prog_settings

Parameter SETTINGS As %String = "TargetFilePath,ArchiveFilePath";

Method writeFlatMessage(pRequest As GC.eDOCS.TAGDelimitedFileNuance, Output pResponse As Ens.StringResponse) As %Status
{
  // $$$TRACE("ALJ called writeFlatMessag")
  Set $ZT="Trap",tSC=$$$OK
  // get acession for tag name img_1013114801_43638.tag
  // set accession = pRequest.DocumentInternalID
  // set accession =$PIECE(accession,"=",2)
  // set accession =$Extract(accession,1,10)
  // Create archive path and name
  //  11-21-2016 get filename from input created by concatenating msh10 uniqueid and msh7 datetime
  set filename = pRequest.zMSH10andMSH7
  set targetFilePath=(..TargetFilePath)
  set archivePath=(..ArchiveFilePath)
  // Use global for counter
  //set filename = "img_"_accession_"_"_$INCREMENT(^GCH.eDOCSCounterIMG,1)
  // set filename = pRequest.zTagfilename
  // set filename = "ALJTEST1"
  set TagfileName = targetFilePath_filename_".tag"
  set TagfileNameArchive  = archivePath_filename_".tag"
  set DocfileName = targetFilePath_filename_".doc"
  set DocfileNameArchive  = archivePath_filename_".doc"
  //
  // Open a stream for Prod and Archive for final doc 
  //
  set streamout = ""
  set idOut=##class(%FileCharacterStream).GetStreamIdForFile(DocfileName) 
  set idOutArchive=##class(%FileCharacterStream).GetStreamIdForFile(DocfileNameArchive)  
  set streamout=##class(%FileCharacterStream).%Open(idOut) 
  set streamoutArchive=##class(%FileCharacterStream).%Open(idOutArchive)
  
  // $$$TRACE("tagfile="_TagfileName)
  //
  //  Can only use this if zOBX51 is defined as a stream
  //  copy zOBX51 to output stream
  //  http://172.25.50.143:57773/csp/docbook/DocBook.UI.Page.cls?KEY=GOBJ_streams#GOBJ_streams_interface_readwrite
  //  Set tmpStream = ##class(%Stream.GlobalCharacter).%New()
  //  DO streamoutArchive.CopyFrom(tmpstream) // testing

  Set tmpOBX = pRequest.zFindingsComb
  Set tStatus = streamout.Write(pRequest.zFindingsComb)
  //  $$$TRACE("ALJ After tstatus")
  // Set tStatus = streamoutArchive.Write(pRequest.zFindingsComb)
  DO streamout.%Save()
  //   $$$TRACE("ALJ After streamout")
  // DO streamoutArchive.%Save()
  //clear temp variables Do we need to do this?
  set streamout = ""
  set streamoutArchive = ""
  set streamin = ""
  set finalDoc = ""

  // write the tag file out using global with complete path and file name
  // using custome method that calls openCustom(
  set st=..Adapter.PutLineCustom(TagfileName,pRequest.OutputLine())
  // set st=..Adapter.PutLineCustom(TagfileNameArchive,pRequest.OutputLine())
  //  $$$TRACE("ALJ After PutLineCustom")
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

Method OnMessage(pRequest As GC.eDOCS.TAGDelimitedFileNuance, Output pResponse As %Persistent) As %Status
{
	Set tFilename=..Adapter.CreateTimestamp(##class(%File).GetFilename(pRequest.Stream.Attributes("Filename")),..Filename)
	Set tSC=..Adapter.PutStream(tFilename, pRequest.Stream)
	Do pRequest.%Save() ; re-save in case PutStream() optimization changed the Stream filename
	Quit tSC
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="GC.eDOCS.TAGDelimitedFileNuance"> 
		<Method>writeFlatMessage</Method>
	</MapItem>
</MapItems>
}

}
