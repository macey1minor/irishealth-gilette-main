/// xRef Audit List View.
Class IIBAENSEMBLE.Zen.xRefAttrAuditList Extends IIBAENSEMBLE.Zen.ToolkitTemplate
{

/// Class name of application this page belongs to.
Parameter APPLICATION = "IIBAENSEMBLE.Zen.Toolkit";

/// Displayed name of this page.
Parameter PAGENAME = "xRefAttr Audit List";

/// Domain used for localization.
Parameter DOMAIN;

/// This Style block contains page-specific CSS style definitions.
XData Style
{
<style type="text/css">

table.tpTable {
    background: none repeat scroll 0 0 #FFFFFF;
    border: 1px solid #000000;
    empty-cells: show;
    font-family: Verdana;
	font-size: .6em;
    table-layout: fixed;
    width: 100%;
}
.tpEven {
    color: #0C202A;
    background: #A6DBF9;
}
.tpOdd {
    color: #0C202A;
}
</style>
}

/// This XML block defines the contents of this pane.
XData tablePane [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<pane>
<tableNavigatorBar tablePaneId="auditTable" showPageSize="true" width="70%" />
<tablePane showQuery="false" id="auditTable" tableName="%SYS.Audit"  orderByClause="UTCTimeStamp DESC"
useSnapshot="true"  
pageSize="25" 
maxRows="500"
filtersDisabled="true"
width="90%"
nowrap="false"
showZebra="true" >
    <column colName="ID" hidden="true"/>
    <column colName="AuditIndex" hidden="true"/>
	<column colName="UTCTimeStamp"/>
	<column colName="Username" 
	cellTitle="Ensemle User Login" 
	style="font-weight:bold;" 
	/>
	<column colName="OSUsername" cellTitle="OS User Login" hidden="true"/>
	<column colName="UserInfo"  hidden="true"/>	
	<column colName="CSPSessionID"/>
	<column colName="ClientExecutableName" hidden="true"/>
	<column colName="ClientIPAddress"/>
	<column colName="Description"/>
	<column colName="Event"/>
	<column colName="EventData"/>
	<column colName="EventSource" hidden="true"/>
	<column colName="EventType" hidden="false" filterValue="TablexRefAttr" />
	<column colName="GroupName" hidden="true"/>
	<column colName="Namespace" />
	<column colName="Roles"/>
	<column colName="RoutineSpec" hidden="true"/>
	<column colName="Status"/>
	<column colName="SystemID"/>
	<column colName="x__classname" hidden="true"/>
</tablePane>
</pane>
}

/// This XML block defines the contents of this pane.
XData detailPane [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<pane xmlns="http://www.intersystems.com/zen">
<html></html>
</pane>
}

Method GetUsers() As %String
{
	set rs = ##class(%ResultSet).%New("Security.Users:Detail")
	do rs.Execute("*","*","*")
	set sNames=""
	set counter=1
	While rs.Next() {
		set sName = rs.Data("Name")
		set $P(sNames,counter,",")=sName
		set counter=counter+1		
	}
	
	quit sNames
}

/*
	Method onfilterChange(FilterValue as %String) as %Status
	{
		Set obj=%page.%GetComponentById("auditTable")
	}*/
}
