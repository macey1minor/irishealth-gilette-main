/// 
Class IIBAENSEMBLE.csp.FileDownload Extends %CSP.Page
{

ClassMethod OnPreHTTP() As %Boolean
{
	set %response.ContentType = "application/force-download"
	d %response.SetHeader("Content-disposition", "attachment; filename="_%request.Get("filename"))
	Quit 1
}

/// Event handler for <b>PAGE</b> event: this is invoked in order to  
/// generate the content of a csp page.
ClassMethod OnPage() As %Status
{
	
	s EnsSysDir = ##class(%File).ParentDirectoryName(##class(%File).ManagerDirectory())
	
	set pFileStream = ##class(%FileCharacterStream).%New()
	Set pFileStream.Filename = EnsSysDir_"IIBAExports\"_%request.Get("filename")
	set pGlobalStream = ##class(%GlobalCharacterStream).%New()
	d pGlobalStream.CopyFrom(pFileStream)
	while 'pGlobalStream.AtEnd {
		w pGlobalStream.ReadLine(),!		
	}
	
	kill pFileStream
	kill pGlobalStream
	d ##class(%File).Delete(EnsSysDir_"IIBAExports\"_%request.Get("filename"))
	Quit $$$OK
}

}
