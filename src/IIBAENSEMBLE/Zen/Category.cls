/// Created using the page template: Default
Class IIBAENSEMBLE.Zen.Category Extends IIBAENSEMBLE.Zen.ToolkitTemplate
{

/// Class name of application this page belongs to.
Parameter APPLICATION = "IIBAENSEMBLE.Zen.Toolkit";

/// Displayed name of this page.
Parameter PAGENAME = "Business Item Categories";

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
<tableNavigatorBar tablePaneId="categoryTable" showPageSize="true" width="70%" />
<tablePane showQuery="false" id="categoryTable" OnCreateResultSet="CreateTableRS"  
useSnapshot="true"  
pageSize="25" 
maxRows="500"
filtersDisabled="false"
width="90%"
nowrap="false"
showZebra="true" >

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

ClassMethod CreateTableRS(Output tSC As %Status, pInfo As %ZEN.Auxiliary.QueryInfo) As %ResultSet
{
	s tSC = $$$OK
	s sql = "select Name,Category from ens_config.item"
	
	Set tRS = ##class(%ResultSet).%New()
    Set tSC = tRS.Prepare(sql)
    Set pInfo.queryText = sql
    
	Q tRS
}

}
