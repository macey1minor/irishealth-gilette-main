Class IIBAENSEMBLE.EnsMsgTracePane Extends %CSP.Util.Pane
{

/// Use our own domain for localization
Parameter DOMAIN = "Ensemble";

Method DrawHEAD(pInstance As %CSP.Util.PageInstance) As %Status
{
	// override table style
	&html<
<style>
TABLE.LayoutMain TD.LayoutContentCol {
	background: #EEFFFF;
	padding-left: 0px;
	vertical-align: top;
}
</style>>

	&html<
	
<!-- detect svg -->
<script language="JavaScript" src="svgcheck.js"></script>
<script language="VBScript" src="svgcheck.vbs"></script>
	
<script language="javascript">

// display popup-legend window
function showLegend()
{
	var wid = 300;
	var hgt = 400;
	var top = 100;
	var left = 100;

  	var url = "enstracelegend.html";
	self.autopagePopupWindow = window.open(url,'autopagePopup','left='+left+',top='+top+',width='+wid+',height='+hgt+',resizable');
	self.autopagePopupWindow.focus();
}

</script>
	>
	
	Quit $$$OK
}

/// Draw the BODY of the detail pane
Method DrawBODY(pInstance As %CSP.Util.PageInstance) As %Status
{
	If (%request.UserAgent '[ "MSIE") {
		Write "<div style=""padding-left:20px;"">",$$$TextHTML("At this time, this page is only visible with Internet Explorer."),"</div>"
		Quit $$$OK
	}

	// get page ID values
	Merge tID = pInstance.IDValues

	// If this is a search submit,get request parms via object
	If ($G(%request.Data("$SUBMITBTN",1)) = "$AUTOFORM_SEARCH" ) {
		Set tRequest = ##class(CSPX.EnsMsgTraceFilterForm).ProcessSubmit(%request, .tID)
		Set sessionId = tRequest.SessionId
		Set startTime = tRequest.StartTime
		Set endTime = tRequest.EndTime
		Set startId = tRequest.StartId
		Set endId = tRequest.EndId
		Set query = "&$SUBMITBTN=$AUTOFORM_SEARCH&SessionId=" _ sessionId _ 
						"&StartTime=" _ startTime _
						"&EndTime=" _ endTime _
						"&StartId=" _ startId _
						"&EndId=" _ endId
		
	}
	Else {
		Set tMsgId=$G(tID(1)), sessionId=""
		If ""'=tMsgId {
			&sql(SELECT SessionId INTO :tSessionId FROM Ens.MessageHeader WHERE %ID = :tMsgId)
			Set:'SQLCODE sessionId=tSessionId
		}
		Set startTime = ""
		Set endTime = ""
		Set startId = ""
		Set endId = ""
		Set query = ""
	}
	Set showId=$G(tID(1))

	// if not a goto button, reset page
	If ('$D(%request.Data("$GOTO",1))) {
		Kill tID(2)
	}
	// find dimensions of canvas
	//Do ##class(EnsMsgTraceSVG).FindElementCount(sessionId, startTime, endTime, startId, endId, .rowCount, .colCount)
	Set rowCount = ##class(CSPX.EnsMsgTraceSVG).BuildTraceInfo(sessionId,startTime,endTime,startId,endId,.showId)
	Set msgCount = $p(rowCount, "#", 1)
	Set rowCount = $p(rowCount, "#", 2)
	&html<	
		<!-- detect svg -->
		<script language="JavaScript">
		checkAndGetSVGViewer();

function gotoMsgPage(n)
{
	self.top.location = '#(##class(%CSP.Page).Link("IIBAUtilEnsMsgTrace.csp",,1))#' + '$ID1=#($G(tID(1)))#&$ID2=' + n + '&$GOTO=1' + '#($ZCVT(query,"O","JS"))#';
}

function showDetails(msgId,type)
{
	// update the info pane
	if (msgId && msgId != '') {
		if (type=="ack") { 
			var msgClass = msgId[0];
			var msgOnlyId = msgId[1];
			self.top.frames['Info'].document.location = '#(##class(%CSP.Page).Link("IIBAUtilEnsMsgDetails.csp",,1))#' + '$FRAME=Info&$ID1=' + escape(msgClass) + '&ACKID=' + escape(msgOnlyId) + '&ACK=1' ;
		}
		else {
			self.top.frames['Info'].document.location = '#(##class(%CSP.Page).Link("IIBAUtilEnsMsgDetails.csp",,1))#' + '$FRAME=Info&$ID1=' + escape(msgId) + (('event'==type) ? '&EVENT=1' : '') + (('ioEntry'==type) ? '&IOENTRY=1' : '');
		}
	}
	else {
		// show search page
		self.top.frames['Info'].document.location = '#(##class(%CSP.Page).Link("IIBAUtilEnsMsgTrace.csp",,1))#' + '$FRAME=Info&$ID1=#($G(tID(1)))#' + '#($ZCVT(query,"O","JS"))#';
	}
}

function showContents(msgId,type)
{
	// update the info pane
	if (msgId && msgId != '') {
		if (type=='ack') {
			var msgClass = msgId[0];
			var msgOnlyId = msgId[1];
			self.top.frames['Info'].document.location = '#(##class(%CSP.Page).Link("CSPX.EnsMsgContentsPane.cls",,1))#' + '$FRAME=Info&$ID1=Body:' + escape(msgClass) + '&$ID2=' + escape(msgOnlyId);
		}
		else if (type=='ioEntry') {
			self.top.frames['Info'].document.location = '#(##class(%CSP.Page).Link("CSPX.EnsMsgContentsPane.cls",,1))#' + '$FRAME=Info&$ID1=Body:Ens.Util.IOLog' + '&$ID2=' + escape(msgId);
		}
		else {
			self.top.frames['Info'].document.location = '#(##class(%CSP.Page).Link("CSPX.EnsMsgContentsPane.cls",,1))#' + '$FRAME=Info&$ID1=' + escape(msgId) + (('ioEntry'==type) ? '&IOENTRY=1' : '');
		}
	}
}

		</script>
	>

	// find dimensions of canvas
	//Do ##class(EnsMsgTraceSVG).FindElementCount(sessionid, startTime, endTime, startId, endId, .rowCount, .colCount)
	
	Set rowCount = ##class(CSPX.EnsMsgTraceSVG).BuildTraceInfo(sessionId,startTime,endTime,startId,endId)
	
	If (rowCount = 0) {
		// No data to show
		Set svgWidth = 400
		Set svgHeight = 100
		
		&html<<div class="Text1">#(..LocalizeText("@Ensemble:NoMatch@No messages match the search criteria."))#</div>>
	}
	Else {
		// !!!
		If (msgCount > ##class(CSPX.EnsMsgTraceSVG).MessagesPerPage()) {
			Set msgCount = ##class(CSPX.EnsMsgTraceSVG).MessagesPerPage()
		}
		
		Set colCount = $G(^CacheTempMsgTrace(%session.SessionId,0,"columns"))
		
		Set hostWidth = 170 // must match value in MsgTraceSVG
		Set svgWidth = (colCount * hostWidth)
		Set svgHeight = ((rowCount * 40) + 70 + 50)

		Set zoom = 100
		Set embWidth = svgWidth * (zoom / 100)
		Set embHeight = svgHeight * (zoom / 100)
		
		Set currPage = $G(tID(2),1)
	
		// loading message
		&html<<div id='loading' style='background: white; color: blue; font-size: 14pt; font-family: courier new'>Generating Message Trace...</div>>

		&html<<embed id="SVGEmbed" name="SVGEmbed" type="image/svg-xml" 
			src="#(##class(%CSP.Page).Link("CSPX.EnsMsgTraceSVG.cls?SESSIONID="_sessionId_"&STARTID="_startId))#&ENDID=#(endId)#&STARTTIME=#(startTime)#&ENDTIME=#(endTime)#&PAGE=#(currPage)#&WIDTH=#(svgWidth)#&HEIGHT=#(svgHeight)#&SHOW=#(showId)#" 
			height="#(embHeight)#" width="#(embWidth)#">>
		
		//Write "<br>&nbsp;<span style='font-size:0.8em;'>",$$$TextHTML("Click on canvas to change search criteria"),"</span>"

	}
	
	Quit $$$OK
}

}
