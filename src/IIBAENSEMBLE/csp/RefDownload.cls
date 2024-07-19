/// 
Class IIBAENSEMBLE.csp.RefDownload Extends %CSP.Page
{

ClassMethod OnPreHTTP() As %Boolean
{
	set %response.ContentType = "application/force-download"
	d %response.SetHeader("Content-disposition", "attachment; filename=xRefExport.csv")
	Quit 1
}

/// Event handler for <b>PAGE</b> event: this is invoked in order to  
/// generate the content of a csp page.
ClassMethod OnPage() As %Status
{
	
	s EnsSysDir = ##class(%File).ParentDirectoryName(##class(%File).ManagerDirectory())
	
	set pFileStream = ##class(%FileCharacterStream).%New()
	Set pFileStream.Filename = ##class(%File).NormalizeFilename(EnsSysDir_"xRefExports\"_%request.Get("filename"))
	
	while 'pFileStream.AtEnd {
		w pFileStream.ReadLine(),!		
	}
	
	kill pFileStream
	d ##class(%File).Delete(##class(%File).NormalizeFilename(EnsSysDir_"xRefExports\"_%request.Get("filename")))
	Quit $$$OK
}

}
