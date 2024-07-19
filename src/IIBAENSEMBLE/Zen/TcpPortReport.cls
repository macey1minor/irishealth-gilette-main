/// Created using the page template: Title Page
Class IIBAENSEMBLE.Zen.TcpPortReport Extends %ZEN.Component.page [ DependsOn = IIBAENSEMBLE.Zen.ToolkitHeader ]
{

/// Class name of application this page belongs to.
Parameter APPLICATION = "IIBAENSEMBLE.Zen.Toolkit";

/// Displayed name of this page.
Parameter PAGENAME = "TcpPortReport";

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

// <page xmlns="http://www.intersystems.com/zen" title="">

// <html id="title">TCP Port Usage</html>

/// This XML block defines the contents of this page.
XData Contents [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<page xmlns:ZENToolKIT="http://www.intersystems.com/toolkitheader" title="IIBA Support" width="auto" id="maintitle">

<ZENToolKIT:ToolkitHeader id="title" title="TCP Port Usage"/>
<vgroup width="100%">
<!-- put page contents here -->
<tableNavigatorBar tablePaneId="PortTable"/>
<tablePane id='PortTable' 
	queryClass="IIBAENSEMBLE.Zen.TcpPortReport" 
	queryName="PortQuery"
	showZebra="true"
	useSnapshot="true"
	pageSize="25"
	maxRows="500"
	filtersDisabled="false"
	width="90%"
	nowrap="false"
	
>
<parameter name="NameSpace"/>
<parameter name="InterfaceName"/>
<parameter name="Type" id="Type" resource="Type"/>
<column colName="NameSpace" title="Namespace" width="15%" />
<column colName="InterfaceName" title="Interface Name" width="40%"  />
<column colName="Type" 
	title="Type" 
	 width="15%"
	 
/>
<column colName="IP" title="IP Address" width="20%" />
<column colName="PortNumber" title="Port" width="10%" />
</tablePane>
</vgroup>
</page>
}

Query PortQuery(qNamespace As %String = "", qInterfaceName As %String = "", qType As %String = "") As %Query(ROWSPEC = "Namespace:%String:Namespace,InterfaceName:%String:Interface Name,Type:%String:Type,IP:%String:IP Address,PortNumber:%Integer:Port")
{
}

ClassMethod PortQueryExecute(ByRef qHandle As %Binary, qNamespace As %String = "", qInterfaceName As %String = "", qType As %String = "") As %Status
{
	K NamespaceList
	K SystemInfo
	
	s qCurrentNamespace = $SYSTEM.SYS.NameSpace()
	
	If (qNamespace="") {
		d ##class(Ens.Director).GetSystemProductionSummary(.SystemInfo)
	} else {
		s SystemInfo(qNamespace)=""
	}
	
	s Namespace=""
	F  {
		s Namespace=$O(SystemInfo(Namespace))
		Q:Namespace=""
		Continue:$O(SystemInfo(Namespace,""))=""
		
		zn Namespace
		Set ProductionName=""
		Set ProductionStatus=""
		Set production = ""
		set status = ##class(Ens.Director).GetProductionStatus(.ProductionName,.ProductionStatus)
		Continue:ProductionName=""
		
		set production=##class(Ens.Config.Production).%OpenId(ProductionName)
		
		for i=1:1:production.Items.Count() {
		
			s item=production.Items.GetAt(i)
			s name=item.Name
		
			s port=""
			s ip=""
			for j=1:1:item.Settings.Count() {
				
				s st = item.Settings.GetAt(j)
				I (st.Name="Port") {
					s port=st.Value
					
				}
				I (st.Name="IPAddress") {
					s ip=st.Value
					
				}
				
			}
			if (port'="") {
				if ((qType="") || ($P("Service,,Operation",",",item.BusinessType())=qType)) {
					Set iRow=$I(qHandle("row")),qHandle("row",iRow)=$LB(Namespace,item.Name,$P("Service,,Operation",",",item.BusinessType()),ip,port)
				}
			}
		
		
		
		}
	}
	
	s qHandle("row")=0
	
	zn qCurrentNamespace
	
	Quit $$$OK
}

ClassMethod PortQueryClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = PortQueryExecute ]
{
	Kill qHandle
	Quit $$$OK
}

ClassMethod PortQueryFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = PortQueryExecute ]
{
	K Row s Row=""
	If ""=$G(qHandle("row")) Set AtEnd=1  Quit $$$OK
	
	s qHandle("row")=$O(qHandle("row",qHandle("row")))
	if (qHandle("row")="") {
		set AtEnd=1
	} else {
		s Row=qHandle("row",qHandle("row"))
	}
	
	Quit $$$OK
}

}
