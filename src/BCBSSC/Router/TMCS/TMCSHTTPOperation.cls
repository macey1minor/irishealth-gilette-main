Class BCBSSC.Router.TMCS.TMCSHTTPOperation Extends Ens.BusinessOperation
{

Parameter ADAPTER = "BCBSSC.Router.TMCS.TMCSHTTPAdaptor";

Method OnMessage(pRequest As BCBSSC.EG.TMCS.REST.Model.Discharge, Output pResponse As %Library.Persistent) As %Status
{
    Try {
        Set tSC = $$$OK
        
        Set tRequest = ##class(%DynamicObject).%New()  
        set tRequest.subscriberId = pRequest.subscriberId 
        set tRequest.patientId = pRequest.patientId 
        set tRequest.authorizationNumber = pRequest.authorizationNumber 
        set tRequest.admitDate = pRequest.admitDate 
        set tRequest.dischargeDate = pRequest.dischargeDate
        set tRequest.dischargeStatus = pRequest.dischargeStatus 
        set tRequest.source = pRequest.source 
        set tPayload = tRequest.%ToJSON()

        Set tSC = ..Adapter.SendMessage(..Adapter.URL, .tHTTPResponse, tPayload)
        
        //NH Error handling for Http. Don't delete when cleaning comments
        if tHTTPResponse.StatusCode '= 200 {
	        $$$LOGINFO("Error code: "_tHTTPResponse.StatusCode)
	        $$$LOGINFO("Reason: "_tHTTPResponse.ReasonPhrase)
	        $$$LOGINFO("DATA: "_tHTTPResponse.Data.Read())
	        }
        
    } Catch ex {
        // Handle any exceptions here
        Set tSC = ex.AsStatus()
        $$$LOGERROR(tSC)
    }
    quit tSC
}

/// Revision number of this class
Parameter SrcVer = 18;

}
