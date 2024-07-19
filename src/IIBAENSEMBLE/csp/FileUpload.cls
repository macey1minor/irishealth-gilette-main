/// 
Class IIBAENSEMBLE.csp.FileUpload Extends %CSP.Page
{

ClassMethod OnPreHTTP() As %Boolean
{
	set %response.ContentType = "text/html; charset=UTF-8"
	//d %response.SetHeader("Content-disposition", "attachment; filename="_%request.Get("filename"))
	Quit 1
}

/// Event handler for <b>PAGE</b> event: this is invoked in order to  
/// generate the content of a csp page.
ClassMethod OnPage() As %Status
{
	//Posts to the FileUpload class must include the following parameters
		//Class - the name of a class containing a class method that will receive the character stream as a parameter
		//Method - the name of the class method
	//Posts to this class must use the text "uploadfilename" as the name of the field that containes the file data
	
	s importstream = ##class(%GlobalCharacterStream).%New()
	d importstream.CopyFrom(%request.GetMimeData("uploadfilename"))
	s response = $ZOBJCLASSMETHOD(%request.Get("Class"),%request.Get("Method"),%request.Get("MethodParams"),importstream)
	w response
 	
		
	Quit $$$OK
}

}
