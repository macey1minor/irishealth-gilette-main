Class GC.Utils.CustomEmailRegDftXML Extends Ens.BusinessOperation [ ProcedureBlock ]
{

//  Created by Al Johnson

//  Created 09/23/2016

//  Email XML fields on Regions Charge Credits

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

Method OnMessage(pRequest As GC.Regions.DFT.CreditDFT, Output pResponse As Ens.Response) As %Status
{
	Set $ZT="Trap",tSC=$$$OK

    // rawcontentget property does not exit
	// Set msg = pRequest.RawContentGet()

	Set msgBody = ""
	set productionName = $zu(5)_" "  //Per Andre returns the current namespace
			//Set tMailMessage.Subject=custSubject_"  "_$$$SystemName_":"_pRequest.SourceConfigName
			// _":"_pRequest.SourceConfigName
	Set NL = $char(13,10)
	Set custSubject = productionName_": "_..CustomSubject
	do {
		Set tMailMessage=##class(%Net.MailMessage).%New()

		Set keyword = "" 
	    //  alj-092216   Set keyword = keyword_..CheckforKeyWord(msg,..SearchKeywords) //*********************
	    //  Set custSubject = custSubject_": "_keyword
		Set tMailMessage.Subject= custSubject
		// $$$TRACE("custSubject ")
		Set tMailMessage.Charset="iso-8859-1"
		// --------- Send email             -----------------------
		// Set msgBody = msg
		// alj Set tMailMessage.TextData = "MRN="_pRequest.MRN
		Set tSC=tMailMessage.TextData.Clear(1)
		Set tMailMessage.Subject=custSubject            //_"  "_$$$SystemName   

	    Set tSC=tMailMessage.TextData.Write(productionName_NL_NL_"CDM Credit "_pRequest.CDM) Quit:$$$ISERR(tSC)
	    Set tSC=tMailMessage.TextData.Write(NL_"CPT "_pRequest.CPT_"     Modifiers "_pRequest.CPTModifiers) Quit:$$$ISERR(tSC)
	    Set tSC=tMailMessage.TextData.Write(NL_"MRN "_pRequest.MRN_"   "_pRequest.Name) Quit:$$$ISERR(tSC)
	    Set tSC=tMailMessage.TextData.Write(NL_"Account "_pRequest.Account) Quit:$$$ISERR(tSC)
	    Set tSC=tMailMessage.TextData.Write(NL_"HL7 Date of Credit "_pRequest.HL7MessageDate) Quit:$$$ISERR(tSC)
	    Set tSC=tMailMessage.TextData.Write(NL_"Date of Service "_pRequest.DateOfService) Quit:$$$ISERR(tSC)
	    Set tSC=tMailMessage.TextData.Write(NL_"Quantity "_pRequest.Quantity_"  Amount "_pRequest.Amount) Quit:$$$ISERR(tSC)
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
		    Set keyword= keyword_", "_searchText
	    }
      SET countup=countup+1
    } // end for
	
	Quit keyword
}

}
