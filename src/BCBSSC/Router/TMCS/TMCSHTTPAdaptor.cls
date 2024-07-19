Class BCBSSC.Router.TMCS.TMCSHTTPAdaptor Extends EnsLib.HTTP.OutboundAdapter
{

/// Send a POST to the configured Server, Port and URL, sending form data to the named form variables.
Method SendMessage(pURL As %String, Output pResponse As %Net.HttpResponse, pData) As %Status
{
     Try {
          Set tSC = $$$OK
          Set tSC = ..PostURL(pURL, .pResponse, , pData)
        
     } Catch ex {
        // Handle any exceptions here
        Set tSC = ex.AsStatus()
        $$$LOGERROR(tSC)
    }
     quit tSC
}

ClassMethod GetRequest() As %Net.HttpRequest
{
     set request = ##class(%Net.HttpRequest).%New()
     set request.ContentType = "application/json"
     quit request
}

/// Revision number of this class
Parameter SrcVer = 11;

}
