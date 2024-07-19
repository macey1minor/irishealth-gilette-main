/// This is a specialized title pane used by the Ensemble Portal.
Class IIBAENSEMBLE.EnsTitlePane Extends %CSP.Util.Pane
{

/// Use our own domain for localization
Parameter DOMAIN = "Ensemble";

/// A collection of Links used to draw the locator within the title pane.
Property Locator As list Of Link;

/// Control whether or not User/Namespace is displayed or not.
Property ShowUsrNsp As %Boolean [ InitialExpression = 1 ];

/// Draw the HTML to display a title pane for this object.
Method DrawBODY(pInstance As PageInstance) As %Status
{
	Set tColSpan = 2

	&html<<tr><td colspan="#(tColSpan)#" class="Title" width="100%">>

	Write "<div class=""TitleText"">&nbsp;" , ..LocalizeText(..Text), "</div>"
	
	&html<<table width="100%" border="0" cellpadding="0" cellspacing="0"><tr>>

	Set tCount = ..Locator.Count()
	Merge tID =  pInstance.IDValues
	
	
	If (tCount > 0) {
		&html<<td align="LEFT" ><div align="LEFT" class="Locator">>
		For i = 1:1:tCount {
			/*
			If (i > 1) {
				&html<&nbsp;&gt;&nbsp;>
			}
			*/

			Set tLink = ..Locator.GetAt(i)
			//Merge tID =  tLink.IDValues
			//&html<[<a target="_top" href="#(pInstance.MakeLink(tLink.HREF,.tID))#">#(..LocalizeText(tLink.Caption))#</A>]>
			Write "&nbsp;&lt;&nbsp;"
			Write ..LocalizeText(tLink.Caption)
			Write "&nbsp;&gt;&nbsp;"

		} 
		&html<&nbsp[<a target="_top" href="/default.htm">IIBA Ensemble Home</A>]&nbsp>
		&html<</div></td>>
	}
	
	
	
	&html<<td align="RIGHT"><div class="Locator" align="RIGHT">>
	//Set defaultNS = $G(%session.Data("$NAMESPACE"))
	//If defaultNS = "" Set defaultNS = ..GetDefaultNamespace()
	
	Set nsHelp = ..LocalizeText("Name of current Ensemble namespace")
	Set usrHelp = ..LocalizeText("Name of current user")

	&html<&nbsp;<span title="#(nsHelp)#">#(..LocalizeText("Namespace"))#:</span>>
	Set tCurrNS = $ZU(5)
	W "<B>",tCurrNS,"</B>"
	&html<&nbsp;<span title="#(usrHelp)#">#(..LocalizeText("User"))#:</span> <B>#($UserName)#</B>&nbsp;>


	/*
	if (..ShowUsrNsp) {

		#; show combo box for namespaces
		// Set nsHelp = ..LocalizeText("Use this to switch to a different Ensemble namespace")
		// Set usrHelp = ..LocalizeText("Name of current user")

		&html<&nbsp;<span title="#(nsHelp)#">#(..LocalizeText("Namespace"))#:</span>>
		Set tCurrNS = $ZU(5)
		W "<B>",tCurrNS,"</B>"
		/*
		&html<<select id="nscombo" style="font-size: 0.8em; color: darkblue; font-weight: bold;" onchange="self.document.location=this.value;">>
		Set tNS = $O(^%SYS("Ensemble","InstalledNamespace",""))
		While (tNS '= "") {
			Set tSel = $S(tNS=tCurrNS:"selected",1:"")
			Set tURL = ##class(%CSP.Page).Link("/csp/" _ $ZCVT(tNS,"L") _ "/UtilEnsHome.csp")_"&CSPCHD="_%session.CSPSessionCookie_"&CSPSHARE=1"
			&html<<option value="#(tURL)#" #(tSel)#>#($ZCVT(tNS,"O","HTML"))#>
			Set tNS = $O(^%SYS("Ensemble","InstalledNamespace",tNS))
		}
		&html<</select>>
		*  /

		//If (defaultNS '= "") {
		//	&html<&nbsp;#(..LocalizeText("Namespace"))#: <B>#(defaultNS)#</B>&nbsp;>
		//}

		//Set %session.Data("$NAMESPACE") = defaultNS
		&html<&nbsp;<span title="#(usrHelp)#">#(..LocalizeText("User"))#:</span> <B>#($UserName)#</B>&nbsp;>
	}
	else {
		// Use SERVER and Instance otherwise
		set defaultServer = $G(%session.Data("SERVER"))
		// set:defaultServer="" defaultServer = $System.Server.HostName(),%session.Data("SERVER") = defaultServer 
		&html<&nbsp;#(..LocalizeText("Server"))#: <B>#(defaultServer)#</B>&nbsp;>

		set defaultCfg = $G(%session.Data("CONFIG"))
		set:defaultCfg="" defaultCfg = $p($zu(86),"*",2),%session.Data("CONFIG") = defaultCfg
		&html<&nbsp;#(..LocalizeText("Instance"))#: <B>#(defaultCfg)#</B>&nbsp;>

	}
	*/
	
	&html<</div></td></tr>>
	&html<<tr><td colspan=2>>
	//w %request.URL
	if $F(%request.URL,"IIBAUtilEnsQList.csp") {
		s Name=%request.Get("$ID1")
		
		&sql(Select Enabled
			into :Enabled
			from Ens_config.Item
			where Name=:Name)
			
		I (Enabled=1) {
			&html<<tr><td colspan=2 >>
			W "<Table border=0 style='color:red;font-size:15'><tr><td>Note:</td>"
			W "<td>The first transaction is in memory and will not appear on this page.</td>"
			W "</tr>"
			W "<tr><td></td><td>To view this transaction, disable the interface</td>"
			W "</tr></table>"
			&html<</td></tr>>
		}
	}
	
	
	&html<</td></tr>>		
	&html<</table>>

	&html<</td></tr>>
	
	
	
	Quit $$$OK
}

/// Handle ShowUsrNsp
Method OnGenerateCode() As %String
{
	Set code = ""

	// ShowUsrNsp
	If (..ShowUsrNsp '= "") {
		Set code = code _ " Set tPane.ShowUsrNsp = " _ +..ShowUsrNsp _ $$$EOL
	}

	Quit code
}

/// Get default namespace for this session:<br>
/// <ul>
/// <li> If NAMESPACE is passed in that means user has changed namespace from
/// the drop-down. Update the session data $NAMESPACE.</li>
/// <li> Else If this is not a new session, then use the previous saved session NAMESPACE</li>
/// <li>      Else this is a new new session, but it is Ensemble, then use the current namespace</li>
/// <li>      Else this is a new new session, and it is CSP GUI Utility, then return the first available namespace from namespace list. </li>
/// </ul>
ClassMethod GetDefaultNamespace() As %String
{
	Set defaultNS = $G(%request.Data("$NAMESPACE",1))
	If defaultNS '= "" {
		Set %session.Data("$NAMESPACE") = defaultNS
	} Else {
		Set defaultNS = $G(%session.Data("$NAMESPACE"))
		If defaultNS = "" {
			If $zu(5) '= "%SYS" Set defaultNS = $zu(5)  // for Ensemble
			//Load the first available local namespace
			If defaultNS = "" {
				Do List^%SYS.NAMESPACE(.NspList,0)
				Set defaultNS = $O(NspList(""))	
			}
			Set %session.Data("$NAMESPACE") = defaultNS
		}
	}
	Quit defaultNS
}

}
