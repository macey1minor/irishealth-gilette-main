/// 
Class IIBAENSEMBLE.Bop.FileCopy Extends Ens.BusinessOperation [ ProcedureBlock ]
{

Property FilePath As %String(MAXLEN = 1000);

/// Overwrite file if it exists
Property Overwrite As %Boolean [ InitialExpression = 0 ];

/// If no archive path is specified in the file delivery message, the original file remains in place, use this setting to remove it.
Property RemoveOriginalNoArchive As %Boolean [ InitialExpression = 1 ];

Parameter ADAPTER;

Parameter INVOCATION = "Queue";

Parameter SETTINGS = "FilePath,Overwrite,RemoveOriginalNoArchive";

XData MessageMap
{
<MapItem MessageType="IIBAENSEMBLE.msg.FileDelivery">
<Method>FileCopy</Method>
</MapItem>
}

Method FileCopy(pRequest As IIBAENSEMBLE.msg.FileDelivery, Output pResponse As Ens.Response) As %Status
{
	
	$$$TRACE("Files to Copy: "_pRequest.FilePath_" "_pRequest.FileSpec)
	set tSC = $$$OK
	// Get a list of files
	Set rset=##class(%ResultSet).%New()
	Set rset.ClassName="%File"
	Set rset.QueryName="FileSet"
	Do rset.Execute(pRequest.FilePath,pRequest.FileSpec)
	While(rset.Next()) {
		
		$$$TRACE("getting ready to handle: "_rset.Data("Name"))
		if ($ZB(##class(%File).Attributes(rset.Data("Name")),16,1)=0) {
			// Copy the File to a new folder
			s Filename=##class(%File).GetFilename(rset.Data("Name"))
			set NewFilename = ..FilePath_"\"_Filename
			$$$TRACE("New File: "_NewFilename)
			s tSC=##class(%File).CopyFile(rset.Data("Name"),NewFilename)
			if $$$ISERR(tSC) Quit
			$$$TRACE("File Copy return code: "_tSC)
			// Archive the file after the Copy is successful
			If ( tSC = 1 && (pRequest.ArchivePath'="")) {
				Set ArchiveFileName=pRequest.ArchivePath_"\"_Filename
				$$$TRACE("Archive File Name: "_ArchiveFileName)
				set tSC = ##class(%File).Rename(rset.Data("Name"),ArchiveFileName)
				$$$TRACE("Archive return code: "_tSC)
				If ( 'tSC ) {
					Set tSC = ##class(%File).Rename(rset.Data("Name"),rset.Data("Name")_".ArchiveFailed")
					$$$LOGWARNING("File In working folder that could not be archived: "_rset.Data("Name")_".ArchiveFailed")
				}
				if 'tSC Quit
			} else {
				
				$$$LOGERROR("File Copy ( "_rset.Data("Name")_" to "_NewFilename_" ) failed. Return code: "_tSC)
			}
	
			If (..RemoveOriginalNoArchive &&  (pRequest.ArchivePath="")){
				s tSC = ##class(%File).Delete(rset.Data("Name"))
				if $$$ISERR(tSC) Quit
			}
	
		}
	}
	Quit tSC
}

}
