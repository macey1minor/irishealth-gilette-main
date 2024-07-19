/// Created using the page template: Title Page
Class IIBAENSEMBLE.Zen.ExceptionsCleanup Extends %ZEN.Component.page [ DependsOn = IIBAENSEMBLE.Zen.ToolkitHeader ]
{

/// Class name of application this page belongs to.
Parameter APPLICATION = "IIBAENSEMBLE.Zen.Toolkit";

/// Displayed name of this page.
Parameter PAGENAME = "Exceptions Statistics";

/// Domain used for localization.
Parameter DOMAIN = "ZENToolKIT";

Property ItemType As %String;

Property ItemNameFilter As %String;

/// This Style block contains page-specific CSS style definitions.
XData Style
{
<style type="text/css">
/* style for title bar */
#title {
	background: #C5D6D6;
	color: black;
	font-family: Verdana;
	font-size: 1.5em;
	font-weight: bold;
	padding: 5px;
	border-bottom: 1px solid black;
	text-align: center;
}
</style>
}

/// This XML block defines the contents of this page.
XData Contents [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<page xmlns:ZENToolKIT="http://www.intersystems.com/toolkitheader" title="Conversion Monitor" width="auto" id="maintitle" onshow="zenPage.HTMLUpdate()">

<ZENToolKIT:ToolkitHeader id="title" title="Conversion Monitor"/>
<html id="html1">Show unprocessed exception cleanup orders left to send per client.</html>
<hgroup id="hgroup">
<spacer width="20px"/>
<html id="html" OnDrawContent="DrawHTML"></html>
<spacer width="10px"/>
</hgroup>
</page>
}

ClassMethod DrawHTML(pSeed As %String) As %Status
{
	
	set RS = ##class(%ResultSet).%New()
	set sql = "select Distinct SourceIdentifier From IIBAENSEMBLE_HistoricUpload.Queue  "
	set tSC = RS.Prepare(sql)
	set tSC = RS.Execute()
	set tValid = ""
	&sql(select Top 1 %ID into :tValid From IIBAENSEMBLE_HistoricUpload.Queue)
				
	if tValid = ""
		{
			&html<<p>>
			&html<<table>>
			&html<<tr><td>Client:</td><td><span style="color: blue;">None</span></td></tr>>
			&html<</table>>
				
		}
		else
		{
			while RS.Next()
			{
				s tCount = 0
				&sql(select Count("SourceIdentifier") into :tCount from IIBAENSEMBLE_HistoricUpload.Queue Where SourceIdentifier = :RS.Get("SourceIdentifier") and Processed = 0)
				
				if tCount '= 0
				{
					&html<<p>>
					&html<<table>>
					&html<<tr><td>Client:</td><td><span style="color: blue;">#(RS.Get("SourceIdentifier"))#</span></td></tr>>
					&html<</table>>
				}

				s tRunning = 0
				s tProcessed = ""

				&html<<table>>
				if tCount = 0 
				{
					//set btnId = RS.Get("OrgCode")
					//&html<<tr><button id="#(btnId)#" onclick="CleanUp()">#(RS.Get("OrgCode"))#</button>
					//<script language=javascript>
					//function CleanUp() {
					//	document.getElementById("#(btnId)#").innerHTML = "Hello World";}
					//</script>
					//>
					&html<<tr>>
				}
				else
				{
					&html<<tr>>
					&html<<td>Status:</td><td><span style="color: green;"> #(tCount)#</span></td></tr>>
				}
				
				&html<</table>>
				&html<</p>>
			}
		}
		Quit $$$OK
}

ClientMethod HTMLUpdate() [ Language = javascript ]
{
	var proxy = new zenProxy();
	var current = location.href;
	var last = current.lastIndexOf(".");
	var first = current.lastIndexOf("/");
	var path = current.substring(first,last);
	proxy.production = path;
	
	var html = zenPage.getComponentById('html');
	html.seed = proxy;
	html.refreshContents();
}

ClientMethod UpdatePage() [ Language = javascript ]
{
location.reload();
}

}
