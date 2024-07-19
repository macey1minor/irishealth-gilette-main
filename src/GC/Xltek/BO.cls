Class GC.Xltek.BO Extends Ens.BusinessOperation [ ProcedureBlock ]
{

Parameter ADAPTER = "GC.Shared.FileOutboundAdapter";

// "EnsLib.OutboundFileAdapter";

Parameter INVOCATION = "Queue";

// my custom BO properties

Property TargetFilePath As %String(MAXLEN = 256);

Property ArchiveFilePath As %String(MAXLEN = 256);

// http://172.25.50.144:57773/csp/docbook/DocBook.UI.Page.cls?KEY=EFIL_EnsLib.File.OutboundAdapter

Parameter SETTINGS As %String = "TargetFilePath,ArchiveFilePath";

Method OutPutXML(pRequest As GC.Xltek.ORMXML, Output pResponse As Ens.Response) As %Status
{
   $$$LOGINFO("OutPutXML")
   set tSC = $$$OK
   set writer=##class(%XML.Writer).%New()
   set writer.Indent=0 // for flattened file
   //set writer.Indent=0
   set writer.ReferencesInline = 1
   set targetFilePath=(..TargetFilePath)
   set archivePath=(..ArchiveFilePath)
   //if $$$ISERR(status) do $System.Status.DisplayError(status) quit $$$ERROR() 
   Do writer.OutputToString()
   Do writer.RootObject(pRequest)
   
   set xmlmsgOrig = writer.GetXMLString() 
  
   // added to flatten out file remove if you want it the other way.
   set xmlmsg = $Translate(xmlmsgOrig,$char(13,10),"") // take out nl
   set xmlmsg = xmlmsg_$char(10) // add back in the last nl
   //file name format XMLIn_0004.txt
   //..Pad(source.Code,8,"0")
   //set oFilename = "XMLIn_"_..Pad($PIECE($HOROLOG,",",2),4,"0")_".msg"
   set xmlCounter = "0000"_$INCREMENT(^GC.XltekCounter,1)
   set xmlCounter = $Extract( xmlCounter, $Length(xmlCounter)-3, $Length(xmlCounter))
   set ifilename = "XMLArchive_"_xmlCounter_".xml" 
   set oFilename = "XMLIn_"_xmlCounter_".txt"
   $$$TRACE("Target"_targetFilePath_oFilename)
   $$$TRACE("Archive"_targetFilePath_oFilename)
     set tSC=..Adapter.PutLineCustom(targetFilePath_oFilename,xmlmsg)
   set tSC=..Adapter.PutLineCustom(archivePath_oFilename,xmlmsg)
   set tSC=..Adapter.PutLineCustom(archivePath_ifilename,xmlmsgOrig)
   //set tSC=..Adapter.PutLineCustom(^GC.XltekBOPath_oFilename,xmlmsg)
   //set tSC=..Adapter.PutLineCustom(^GC.XltekBOPathArchive_oFilename,xmlmsg)
   //set tSC=..Adapter.PutLineCustom(^GC.XltekBOPathArchive_ifilename,xmlmsgOrig)

   Quit tSC
   //Quit:$$$ISERR(tSC) tSC
}

XData MessageMap
{
<MapItems>
  <MapItem MessageType="GC.Xltek.ORMXML">
    <Method>OutPutXML</Method>
  </MapItem>
</MapItems>
}

}
