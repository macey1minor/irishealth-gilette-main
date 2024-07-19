Class IIBAENSEMBLE.Zen.OnCallMonitor.ErrorStack Extends %ZEN.Component.page
{

/// Class name of application this page belongs to.
Parameter APPLICATION = "IIBAENSEMBLE.Zen.Toolkit";

/// Displayed name of this page.
Parameter PAGENAME = "OnCallError";

/// Domain used for localization.
Parameter DOMAIN = "ZENToolKIT";

/// This Style block contains page-specific CSS style definitions.
XData Style
{
<style type="text/css">
 
#ErrorPage {
	background: lightblue;
	
}
</style>
}

/// This XML block defines the contents of this page.
XData Contents [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<page xmlns="http://www.intersystems.com/zen" title="" id="ErrorPage">
 <html id="title">OnCall Error</html>
<html id="testHTML" OnDrawContent="UploadHTML" containerStyle="background: lightblue;" height="auto"> </html>
</page>
}

ClassMethod UploadHTML(pSeed As %String) As %Status [ ZenMethod ]
{
	s qNS = $ZNSpace
	s xNS = %request.Get("NS")
	s tID = %request.Get("ID")
	
	s tStack = ""
	s tText = ""
	s tMsgId = ""
	s tSId = ""
	zn xNS
	&sql(select Stack, Text, MessageId, SessionId into :tStack,:tText,:tMsgId,:tSId from Ens_Util.Log Where %ID = :tID)
	&html<<table>>
	&html<<tr><td>MessageId:</td><td><span style="color: black;">#($ZCVT(tMsgId,"O","HTML"))#</span></td></tr>>
	&html<<tr><td>SessionId:</td><td><span style="color: black;">#($ZCVT(tSId,"O","HTML"))#</span></td></tr>>
	&html<<tr><td>Error:</td><td><span style="color: red;">#($ZCVT(tText,"O","HTML"))#</span></td></tr>>
	&html<<tr><td>Stack:</td><td><span style="color: black;">#($ZCVT(tStack,"O","HTML"))#</span></td></tr>>
	//EnsPortal.VisualTrace.zen?$ZEN_POPUP=1&SESSIONID="_curSessionId
	s tSessionId = ""
	&sql(select SessionId into :tSessionId From Ens_Util.Log Where %ID = :tID)
	if tSessionId '=""{
		&html<<tr><a href = "http://enstest:57772/csp/#(xNS)#/EnsPortal.VisualTrace.zen?$ZEN_POPUP=1&SESSIONID=#(tSessionId)#">Trace</a></tr>>
	}
	&html<</table>>
	
	
	zn qNS
 	q $$$OK
}

}
