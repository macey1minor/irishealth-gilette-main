/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Bop.FileToFTP Extends Ens.BusinessOperation [ ProcedureBlock ]
{

Parameter ADAPTER = "EnsLib.FTP.OutboundAdapter";

Parameter INVOCATION = "Queue";

XData MessageMap
{
<MapItem MessageType="IIBAENSEMBLE.msg.FileToFTP">
<Method>SendFTP</Method>
</MapItem>
}

Method SendFTP(pRequest As IIBAENSEMBLE.msg.FileToFTP, Output pResponse As Ens.Response) As %Status
{
	
	$$$TRACE("Files to FTP: "_pRequest.FilePath_" "_pRequest.FileSpec)
	// Get a list of files
	Set rset=##class(%ResultSet).%New()
	Set rset.ClassName="%File"
	Set rset.QueryName="FileSet"
	Do rset.Execute(pRequest.FilePath,pRequest.FileSpec)
	While(rset.Next()) {
		
		$$$TRACE("getting ready to handle: "_rset.Data("Name"))
		if ($ZB(##class(%File).Attributes(rset.Data("Name")),16,1)=0) {
			// s tSC=""
			set Filename = ##class(%File).GetFilename(rset.Data("Name"))

			set fstream = ##class(%FileCharacterStream).%New()
			Set fstream.Filename=rset.Data("Name")
			do ..Adapter.FTP.Status(.tSC)
			$$$TRACE("ftp connected: "_..Adapter.Connected_"|Status: "_tSC)
			
			Set tSC=..Adapter.PutStream(Filename, fstream) Quit:$$$ISERR(tSC)
			$$$TRACE("FTP Operation Complete: "_##class(%SYSTEM.OBJ).DisplayError(tSC)_"Last Error: "_##class(%SYSTEM.OBJ).DisplayError()_"|ReturnCode: "_..Adapter.FTP.ReturnCode)
			
			// Archive the file after the FTP is successful
			If tSC = 1 {
				Set NewFileName=pRequest.ArchivePath_"\"_Filename
				set FileRename = ##class(%File).Rename(rset.Data("Name"),NewFileName)
				$$$TRACE("FTP Operation Complete: "_##class(%SYSTEM.OBJ).DisplayError(tSC)_"Last Error: "_##class(%SYSTEM.OBJ).DisplayError()_"|ReturnCode: "_..Adapter.FTP.ReturnCode)
			}
	
			
	
		}
	}
	Quit tSC
}

}
