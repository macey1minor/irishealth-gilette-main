Class GC.Utils.CustomEmailRegDfAttachment Extends Ens.BusinessOperation [ ProcedureBlock ]
{

//  Created by Al Johnson

//  Created 03/29/2017

//  Email Regions Charge File as Attachment

///  Identicle to EnsLib.EMail.AlertOperation 
///         except we parse out the key word and put it into the message subject
///         and We look up the message and put it into the body.  
/// 
/// Enter keywords; delimit with pipe |
Property SearchKeywords As %String(MAXLEN = 1000, MINLEN = 0);

Property CustomSubject As %String(MAXLEN = 1000, MINLEN = 0);

Parameter SETTINGS = "SearchKeywords, CustomSubject";

Parameter emailSubject = "ZZZZ";

// Parameter ADAPTER = "EnsLib.EMail.OutboundAdapter";

Parameter ADAPTER = "EnsLib.EMail.OutboundAdapter";

//  EnsLib.HL7.Message

// Method OnMessage(pRequest As GC.Regions.DFT.ChargeDFT, Output pResponse As Ens.Response) As %Status

// Method OnMessage(pRequest As Ens.StreamContainer, Output pResponse As %Persistent) As %Status

Method OnMessage(pRequest As Ens.StreamContainer, Output pResponse As Ens.Response) As %Status
{
	
    Quit:'$IsObject(pRequest.Stream) $$$ERROR($$$EnsErrGeneral,"No Stream contained in StreamContainer Request")

	//Set tFilename=pRequest.OriginalFilename

	Set $ZT="Trap",tSC=$$$OK

    // rawcontentget property does not exit
	// Set msg = pRequest.RawContentGet()

	Set msgBody = ""
	//set productionName = $zu(5)_" "  //Per Andre returns the current namespace
			//Set tMailMessage.Subject=custSubject_"  "_$$$SystemName_":"_pRequest.SourceConfigName
			// _":"_pRequest.SourceConfigName
	//Set NL = $char(13,10)
	//Set custSubject = productionName_": "_..CustomSubject
	set zWorkdate=$ZDATE($HOROLOG)
	
	Set custSubject = ..CustomSubject_" "_zWorkdate
	//do {
		// create the email message %Net.MailMessage (class extends %Net.MailMessagePart)
		Set tMailMessage=##class(%Net.MailMessage).%New()

		Set keyword = "" 
	    //  alj-092216   Set keyword = keyword_..CheckforKeyWord(msg,..SearchKeywords) //*********************
	    //  Set custSubject = custSubject_": "_keyword
		Set tMailMessage.Subject= custSubject
		// $$$TRACE("custSubject ")
	    //$$$LOGINFO("filename="_..Filename)
		Set tMailMessage.Charset="iso-8859-1"
		// --------- Send email             -----------------------

		Set tSC=tMailMessage.TextData.Clear(1)
		Set tMailMessage.Subject=custSubject            //_"  "_$$$SystemName   

	    Set zAttachedName = "Live Charges - "_zWorkdate_".csv"
	    Set tMailMessage.IsBinary=1
	    Set tMailMessage.IsHTML=0
	    //AttachFile vs AttachStream needs directory and file name
	    //Set status=tMailMessage.AttachFile("\\hlthshrdv01\Files\Dir_Cert\Working\", zAttachedName)
	    // zAttached is the name on the email but it is leaving the working directory file
	    //  if the attachment is the working directory file, then it removes it
	    Set status=tMailMessage.AttachStream(pRequest.StreamGet(), zAttachedName)

	    Set tSC=..Adapter.SendMail(tMailMessage)

	//} while (0)
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
		    Set keyword= keyword_", "_searchText
	    }
      SET countup=countup+1
    } // end for
	
	Quit keyword
}

}
