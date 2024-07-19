/// Created using the page template: Title Page
Class IIBAENSEMBLE.Zen.StatsConversion Extends %ZEN.Component.page [ DependsOn = IIBAENSEMBLE.Zen.ToolkitHeader ]
{

/// Class name of application this page belongs to.
Parameter APPLICATION = "IIBAENSEMBLE.Zen.Toolkit";

/// Displayed name of this page.
Parameter PAGENAME = "StatsConversion";

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
<html id="html1">Show stats and for each client conversion-percentage.</html>
<hgroup id="hgroup">
<spacer width="20px"/>
<html id="html" OnDrawContent="DrawHTML"></html>
<spacer width="10px"/>
<image id="refresh" src="images/reload.png" title="Refresh" onclick="zenPage.UpdatePage()"/>
</hgroup>
<expando caption="Conversion Records" framed="true" animate="true" expanded="false" width="250px">
<form id="patientForm" 
	width="100%" 
	layout="vertical"
	 labelPosition="top"
	cellStyle="padding: 3px;" 
	>

<hgroup>

<dataCombo label="Name:" id="PatientID" name="PatientID" size="24"
	dropdownWidth="450"
	editable="true"
	searchKeyLen="5"
	required="false"
	comboType="button"
	buttonCaption="Search"
	buttonTitle="Search for a record by Patient Name"
	onchange="zenPage.selectPatient(zenThis);"
	sql="SELECT TOP 25 ID,OrgCode,lName,fName,NewMRN,OldMRN FROM IIBAENSEMBLE_MRNConversion.Queue WHERE lName %STARTSWITH ? ORDER BY lName"
	unrestricted="true"
	displayColumns="2,3,4,5,6"
	choiceColumn="3"
	valueColumn="1"
	auxColumn="1"
	/>
	</hgroup>
<text label="Record ID:" id="RecordID" 
	name="RecordID" size="20" readOnly="true" />
<spacer width="20"/>
<text label="iSite Org:" id="iSite Org" 
	name="iSite Org" size="20" readOnly="true" />
<spacer width="20"/>
<text label="First Name:" id="First Name" 
	name="First Name" size="20" readOnly="true" />
<spacer width="20"/>
<text label="Last Name:" id="Last Name" 
	name="Last Name" size="20" readOnly="true" />
<spacer width="20"/>
<text label="New MRN:" id="New MRN" 
	name="New MRN" size="20" readOnly="true" />
<spacer width="20"/>
<text label="Old MRN:" id="Old MRN" 
	name="Old MRN" size="20" readOnly="true" />
<spacer width="20"/>
<text label="Processed Time:" id="Processed Time" 
	name="Processed Time" size="20" readOnly="true" />
<spacer width="20"/>
<text label="Last Service Date:" id="Last Service Date" 
	name="Last Service Date" size="20" readOnly="true" />
<spacer width="20"/>
	</form>
	</expando>
	<spacer width="20"/>
	
</page>
}

/// User has selected a new Patient from the list.
ClientMethod selectPatient(cb) [ Language = javascript ]
{
	var ctrl = zenPage.getComponentById('PatientID');
	var patid = ctrl.getValue();

	// get id of patient
	// this is in the "auxiliary" value of the dataCombo
	var id = cb.getAuxValue();
	// if user has selected a new id, load it
	//if (patid != id) {
		var form = zenPage.getComponentById('patientForm');
		
		// go to server; get patient data
		
		this.LoadPatient(form, id);

	//}
}

/// Load given patient data into the form.
ClassMethod LoadPatient(pForm As %ZEN.Component.form, pID As %ZEN.Datatype.string) [ ZenMethod ]
{
	#; open patient object from database
	Set tPatient = ##class(IIBAENSEMBLE.MRNConversion.Queue).%OpenId(pID)
	If $IsObject(tPatient) {
		Do %page.%SetValueById("RecordID",pID)
		Do %page.%SetValueById("iSite Org",tPatient.OrgCode)
		Do %page.%SetValueById("First Name",tPatient.fName)
		Do %page.%SetValueById("Last Name",tPatient.lName)
		Do %page.%SetValueById("New MRN",tPatient.NewMRN)
		Do %page.%SetValueById("Old MRN",tPatient.OldMRN)
		Do %page.%SetValueById("Processed Time",tPatient.ProcessedTimeLogicalToDisplay(tPatient.ProcessedTime))
		Do %page.%SetValueById("Last Service Date",tPatient.LastServiceDateLogicalToDisplay(tPatient.LastServiceDate))

	}
	Quit
}

ClassMethod DrawHTML(pSeed As %String) As %Status
{
	
	set RS = ##class(%ResultSet).%New()
	set sql = "select Distinct OrgCode From IIBAENSEMBLE_MRNConversion.Queue"
	set tSC = RS.Prepare(sql)
	set tSC = RS.Execute()
	set tValid = ""
	&sql(select Top 1 %ID into :tValid From IIBAENSEMBLE_MRNConversion.Queue)
				
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
				&html<<p>>
				&html<<table>>
				&html<<tr><td>Client:</td><td><span style="color: blue;">#(RS.Get("OrgCode"))#</span></td></tr>>
				&html<</table>>
			
				s tCount = 0
				s tRunning = 0
				s tProcessed = ""
				&sql(select Count("OrgCode") into :tCount from IIBAENSEMBLE_MRNConversion.Queue Where OrgCode = :RS.Get("OrgCode"))
				&sql(select Count("OrgCode") into :tRunning from IIBAENSEMBLE_MRNConversion.Queue Where ProcessedTime is NOT NULL and OrgCode = :RS.Get("OrgCode"))
				&sql(select TOP 1 ProcessedTime into :tProcessed from IIBAENSEMBLE_MRNConversion.Queue Where ProcessedTime is NOT NULL and OrgCode = :RS.Get("OrgCode") Order by ProcessedTime DESC)
			
				s tStatus = $P(tRunning/tCount*100,".",1)
			
			
				&html<<table>>
				if tStatus = 100 
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
				}
				&html<<td>Status:</td><td><span style="color: green;">#(tStatus)#% at #(tProcessed)#</span></td></tr>>
				&html<</table>>
				&html<</p>>
			}
		
		
			s tcTotal = 0
			s trTotal = 0
			&sql(select Count("OrgCode") into :tcTotal from IIBAENSEMBLE_MRNConversion.Queue)
			&sql(select Count("OrgCode") into :trTotal from IIBAENSEMBLE_MRNConversion.Queue Where ProcessedTime is NOT NULL)
			s tTotal = $P(trTotal/tcTotal*100,".",1)
		
			&html<<table>>
			&html<<tr><td>Total Status:</td><td><span style="color: red;">#(tTotal)#%</span></td></tr>>
			&html<</table>>
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
