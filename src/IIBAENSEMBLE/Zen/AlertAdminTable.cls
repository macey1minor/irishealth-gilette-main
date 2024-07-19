/// Created using the page template: Default
Class IIBAENSEMBLE.Zen.AlertAdminTable Extends IIBAENSEMBLE.Zen.ToolkitTemplate
{

/// Class name of application this page belongs to.
Parameter APPLICATION = "IIBAENSEMBLE.Zen.Toolkit";

/// Displayed name of this page.
Parameter PAGENAME = "TableView";

/// Domain used for localization.
Parameter DOMAIN;

Property MyUser As %ZEN.Datatype.string [ InitialExpression = {$username} ];

Property MyServerName As %ZEN.Datatype.string [ InitialExpression = {$zu(110)} ];

Property MyNamespace As %ZEN.Datatype.string [ InitialExpression = {($ZNSPACE)} ];

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

/// This XML block defines the contents of this page.
XData tablePane [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<pane>
<tableNavigatorBar tablePaneId="alertTable" showPageSize="true" width="70%" />
<tablePane
    width="1500px"
    id="alertTable" 
    sql="select * from IIBAENSEMBLE_Monitor.ItemParameters param 
join IIBAENSEMBLE_Monitor.tblSchedules sch on param.ID=sch.ParameterID"
    maxRows="1000" 
    pageSize="25" 
    autoExecute="true"
    showZebra="true" 
    showRowSelector="false"
    useSnapshot="true"
    extraColumnWidth="5%"
    dataSource="columns">    
   <column width="3%" header=" " colName="ParameterID" OnDrawCell="DrawEditCell" link="javascript:zenPage.showEditPage('#(%query.ID)#');"/>
   <column width="3%" linkCaption="Delete" header=" " colName="ParameterID" OnDrawCell="DrawDeleteCell" link="javascript:zenPage.deleteAlert('#(%query.ID)#');"/>
   <column header="Item Name" width="20%" colName="ItemName" filterType="text"/>
   <column header="Parameter" width="9%" colName="Parameter" filterType="enum" filterOp="=" filterEnum="AdapterState,RunningStatus,Queue,CountChange,LastAction,Count,Status" />
   <column header="Threshold Value" width="8%" colName="ThresholdDuration"/>
   <column header="Grace Period" width="6%" colName="Threshold"/>
   <column header="Alert Interval" width="6%" colName="AlertDuration"/>
   <column header="Hour Start" width="5%" colName="HourStart"/>
   <column header="Hour End" width="5%" colName="HourEnd"/>
   <column header="Active" width="5%" colName="Active"/>
   <column header="M" width="3%" colName="M"/>
   <column header="T" width="3%" colName="T"/>
   <column header="W" width="3%" colName="W"/>
   <column header="Th" width="3%" colName="Th"/>
   <column header="F" width="3%" colName="F"/>
   <column header="Sa" width="3%" colName="Sa"/>
   <column header="Su" width="3%" colName="Su"/>
   <column header="Holiday" width="6%" colName="Holidays"/>
   <column header="Hol Only" width="4%" colName="HolidayOnly"/>
   <column header="Notification" width="20%" colName="NotificationEmail"/>
 </tablePane>
</pane>
}

Method DrawEditCell(pTable As %ZEN.Component.tablePane, pName As %String, pSeed As %String) As %Status
{
    #; Draw HTML to render table cell.
    s tLink = "IIBASupport.csp?PageName=AlertEdit&Mode=Edit&paramID="
    &html<
    	<a href='#(tLink)##(%query(pName))#'><img src='customimages/edit.gif'/></a>
    >
	Quit $$$OK
}

Method DrawDeleteCell(pTable As %ZEN.Component.tablePane, pName As %String, pSeed As %String) As %Status
{
            #; Draw HTML to render table cell.
            &html<
            	<a href='javascript:zenPage.deleteAlert(#(%query(pName))#);'><img src='customimages/trash_bold.gif'/>
            >   
            Quit $$$OK
}

ClassMethod CheckPermissions()
{
	set Allowed = 0
	//Req#5 - PHegel Tab Security Use for page name
	if ##class(%SYSTEM.Security).Check("AlertAdmin","USE"){ 
		set Allowed = 1 
	}
	Quit Allowed
}

ClassMethod deleteAlert(pName As %String) [ ZenMethod ]
{
	&javascript<
		var c=confirm('Are you sure you want to delete this alert?');
		if (c ) {
			var remove = #(..Remove(pName))#;
			location.reload(true);
		}
	>
	
	 /*
  	set rs=##class(%ResultSet).%New()
 	Do rs.Prepare("DELETE from IIBAENSEMBLE_Monitor.ItemParameters where ID = "pName"")
 	Do rs.Execute()
 	
 	set rs=##class(%ResultSet).%New()
 	Do rs.Prepare("DELETE from IIBAENSEMBLE_Monitor.tblSchedules where ParameterID = "pName"")
 	Do rs.Execute()
 	*/
}

ClassMethod Remove(paramID As %String) As %String [ Language = objectscript ]
{
 	set rs=##class(%ResultSet).%New()
 	Do rs.Prepare("DELETE from IIBAENSEMBLE_Monitor.ItemParameters where ID = "_paramID_"")
 	Do rs.Execute()
 	
 	set rs=##class(%ResultSet).%New()
 	Do rs.Prepare("DELETE from IIBAENSEMBLE_Monitor.tblSchedules where ParameterID = "_paramID_"")
 	Do rs.Execute()
 	Q 1
}

}
