Class GC.Utils.CustomEmailAlert Extends EnsLib.EMail.AlertOperation
{

/* **********************************************************************
  Created by Ellen Leichtman
  Created 02/08/2013 EJL           
  	replacing gtwy.GCSH.Utils.CustomEmailAlert
	remove sending non PHI only send 1 email now
  Modified 08/01/2013 EJl
    Removed check for PHI in //if (($FIND(custSubject,"-PHI-") > 0) ) 
  Modified 03/13/2013 EJl
          Sent the non HL7 email. Switched code. 
  -- from original code
  Modified 04/26/2010 EJl
          Fixed email body not sending HL7message
  Modified 04/28/2010 EJl
  Modified 05/11/2010 EJl add text for testing
  Modified 05/12/2010 EJl add TextData.Clear
          Added code to search for message ID when in a different format.
  Modified 10/26/2010 EJl add Specific Setting called "SearchKeywords"
           and replaced individual searches with a method "CheckforKeyWord"
************************************************************************** */
///  Identicle to EnsLib.EMail.AlertOperation 
///         except we parse out the key word and put it into the message subject
///         and We look up the message and put it into the body.  
/// 
/// Enter keywords; delimit with pipe |
Property SearchKeywords As %String(MAXLEN = 1000, MINLEN = 0);

Parameter SETTINGS = "SearchKeywords";

Parameter emailSubject = "ZZZZ";

// not using this

Parameter ADAPTER = "EnsLib.EMail.OutboundAdapter";

Method OnMessage(pRequest As Ens.AlertRequest, Output pResponse As Ens.Response) As %Status
{
	Set $ZT="Trap",tSC=$$$OK

	Set ^a.GCSH.Debug1("LastStep")  = "CustomEmailAlert..OnMessage"
	Set hl7Content =""
	Set hl7MsgID =""
	Set hl7MsgID =  $piece(pRequest.AlertText,"message body Id=",2)
	Set hl7MsgID =  $piece(hl7MsgID,",",1)
	Set sessionID = $piece(pRequest.AlertText,"SessionId=",2)
	Set sessionID =  $piece(sessionID," ",1)
	// some messages come in a different format.
	if (hl7MsgID = "") {
	Set hl7MsgID =  $piece(pRequest.AlertText,"HL7.Message / ",2)
	Set hl7MsgID =  $piece(hl7MsgID," ",1)
	}
	Set msgBody = ""
	set productionName = $zu(5)_" "  //Per Andre returns the current namespace
	Set NL = $char(13,10)
	//Set custSubject = productionName_": "
	Set ^a.GCSH.Debug1("LastStep")  = "CustomEmailAlert..OnMessage2"
	//$$$TRACE("Before Do")
	do {
		Set tMailMessage=##class(%Net.MailMessage).%New()
		// set the email subject
		Set keyword = ""
	    Set keyword = $piece(pRequest.AlertText,"|",2) 	// key word
	    If (keyword = ""){
		    Set keyword = ": Alert: "
	    } 
	    Set msg = pRequest.AlertText  //$piece(pRequest.AlertText,"|",3)
	    Set keyword = keyword_..CheckforKeyWord(msg,..SearchKeywords) 
	   
	  
		    	
	    // Set custSubject = productionName_keyword
		// set the email body
		Set ^a.GCSH.Debug1("LastStep")  = "CustomEmailAlert..OnMessage3"
		//Set tMailMessage.Subject=custSubject_"  "_$$$SystemName_":"_pRequest.SourceConfigName
		//Set tMailMessage.Charset="iso-8859-1"
		Set hl7Content = "No HL7 message available"
		if (hl7MsgID '= "") {
			Set hl7 = ##class(EnsLib.HL7.Message).%OpenId(hl7MsgID)
			// check if it returned a referece. 
			If $ISOBJECT(hl7) = 1 { 
		    	Set ^a.GCSH.Debug1("LastStep")  = "CustomEmailAlert..OnMessage4"
				Set hl7Content = hl7.RawContent
				Set keyword= "HL7-PHI- "_keyword
			}
		}
		Set custSubject = productionName_keyword
		Set tMailMessage.Subject=custSubject_"  "_$$$SystemName_":"_pRequest.SourceConfigName
		Set tMailMessage.Charset="iso-8859-1"

		Set ^a.GCSH.Debug1("LastStep")  = "CustomEmailAlert..OnMessage5"
		//$$$TRACE("step2")	
		// --------- Send email             -----------------------
		Set msgBody = $translate(pRequest.AlertText,"|","") // remove pipes
		//$$$TRACE("step3")
		Set ^a.GCSH.Debug1("LastStep")  = "CustomEmailAlert..OnMessage6"
		//Removed 08/01/2013 EJL was stopping some messages.
		//if (($FIND(custSubject,"-PHI-") > 0) ){
			// Because of PHI send another copy without the message-for the cell phones
			Set tSC=tMailMessage.TextData.Clear(1)
			//$$$TRACE("Before send")
			Set tMailMessage.Subject=custSubject_"  "_$$$SystemName_":"_pRequest.SourceConfigName
			Set tSC=tMailMessage.TextData.Write(productionName_NL_NL_msgBody_NL_NL_"Session ID: "_sessionID_NL_NL_"Msg Body ID: "_hl7MsgID_NL_NL_hl7Content) Quit:$$$ISERR(tSC)
	        Set tSC=..Adapter.SendMail(tMailMessage)
	        Set hl7Content = ""  // clear because we will resend below
	        
		//}
		
		/* remove sending second email without HL7 Per Mary S. 02/07/2013
		Set custSubject =$REPLACE(custSubject,"-PHI-","*")
		Set tSC=tMailMessage.TextData.Clear(1)
		Set tMailMessage.Subject=custSubject_"  "_$$$SystemName_":"_pRequest.SourceConfigName
		Set tSC=tMailMessage.TextData.Write(productionName_NL_NL_msgBody_NL_NL_"Session ID: "_sessionID_NL_NL_"Msg Body ID: "_hl7MsgID) Quit:$$$ISERR(tSC)
		Set tSC=..Adapter.SendMail(tMailMessage)
		*/
	} while (0)
Exit
	Quit tSC
Trap
	Set $ZT="",tSC=$$$EnsSystemError
	Goto Exit
}

Method CheckforKeyWord(msg As %String, searchkeyWords As %String) As %String
{
	SET keyword = ""
	SET delim = "|"
	SET countdown=$LENGTH(searchkeyWords,delim)
    SET countup=1
    FOR reps=countdown:-1:1 {
      SET searchText=$PIECE(searchkeyWords,delim,countup)
	  if ($FIND(msg, searchText) > 0){
		    Set keyword= keyword_searchText
	    }
      SET countup=countup+1
    } // end for
	
	Quit keyword
}

}
