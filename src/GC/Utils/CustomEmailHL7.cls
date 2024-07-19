Class GC.Utils.CustomEmailHL7 Extends Ens.BusinessOperation [ ProcedureBlock ]
{

//  Created by Ellen Leichtman

//  Created 05/15/2012

//  Email body  sending HL7message

///  Identicle to EnsLib.EMail.AlertOperation 
///         except we parse out the key word and put it into the message subject
///         and We look up the message and put it into the body.  
/// 
/// Enter keywords; delimit with pipe |
Property SearchKeywords As %String(MAXLEN = 1000, MINLEN = 0);

Property CustomSubject As %String(MAXLEN = 1000, MINLEN = 0);

Parameter SETTINGS = "SearchKeywords, CustomSubject";

Parameter emailSubject = "ZZZZ";

// not using this

Parameter ADAPTER = "EnsLib.EMail.OutboundAdapter";

//  EnsLib.HL7.Message

Method OnMessage(pRequest As EnsLib.HL7.Message, Output pResponse As Ens.Response) As %Status
{
	Set $ZT="Trap",tSC=$$$OK
     
	//Set ^a.GCSH.Debug1("LastStep")  = "CustomEmailHl7..OnMessage"
	//Set MsgSourceConfigName = EnsLib.HL7.Message
	//Set MsgTypeCat = pRequest.Message.MessageTypeCategory
	//Set MsgMSH10 = pRequest.Message.Identifier  //MSH:10
	//Set MsgName = pRequest.Message.Name //MSH:9
	//Set MsgVersion = pRequest.TypeVersion   //MSH:12
	//set hl7MsgID = ""
	//Set hl7Content = ""
	
	Set msg = pRequest.RawContentGet()  
	Set msgBody = ""
	set productionName = $zu(5)_" "  //Per Andre returns the current namespace
			//Set tMailMessage.Subject=custSubject_"  "_$$$SystemName_":"_pRequest.SourceConfigName
			// _":"_pRequest.SourceConfigName
	Set NL = $char(13,10)
	Set custSubject = productionName_": "_..CustomSubject
	do {
		Set tMailMessage=##class(%Net.MailMessage).%New()

		Set keyword = "" 
	    Set keyword = keyword_..CheckforKeyWord(msg,..SearchKeywords) //*********************
	    Set custSubject = custSubject_": "_keyword
		Set tMailMessage.Subject= custSubject
		$$$TRACE("custSubject ")
		Set tMailMessage.Charset="iso-8859-1"	
		// --------- Send email             -----------------------
		Set msgBody = msg
		Set tSC=tMailMessage.TextData.Clear(1)
		Set tMailMessage.Subject=custSubject            //_"  "_$$$SystemName   
		//Set tSC=tMailMessage.TextData.Write(productionName_NL_NL_msgBody_NL_NL_"Session ID: "_sessionID_NL_NL_"Msg Body ID: "_hl7MsgID) Quit:$$$ISERR(tSC)
	    Set tSC=tMailMessage.TextData.Write(productionName_NL_NL_msgBody) Quit:$$$ISERR(tSC)
	    Set tSC=..Adapter.SendMail(tMailMessage)
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
      SET searchText= $ZCONVERT(searchText,"U")
      SET msg= $ZCONVERT(msg,"U")
	  if ($FIND(msg, searchText) > 0){
		    Set keyword= keyword_searchText
	    }
      SET countup=countup+1
    } // end for
	
	Quit keyword
}

}
