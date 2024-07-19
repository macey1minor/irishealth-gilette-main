/// Copyright 2007 by Inland Imaging Business Associates
/// Created using the page template: Default
Class IIBAENSEMBLE.csp.SupportPageDefinition.Home Extends %ZEN.Component.page
{

/// Class name of application this page belongs to.
Parameter APPLICATION = "IIBAENSEMBLE.csp.SupportPageDefinition.Admin";

/// Displayed name of this page.
Parameter PAGENAME = "Home";

/// Domain used for localization.
Parameter DOMAIN;

/// This Style block contains page-specific CSS style definitions.
XData Style
{
<style type="text/css">
    /*Style classes for use on this page */
   
     body { font-family: arial; }
     table.tpTable caption{
       background: transparent;
       font-size: 1.4em;
       font-weight: bold;
       text-align: left;
       border: none;
     }
    /* even rows */
     .tpEven { color: black; background: #ebf3ff; }
    
    /* odd rows */
     .tpOdd { color: black; background: white; }
    /* this is a selected row */
     table.tpTable tr.tpSelected { background: #3d80df; color: white; }
   
    /* hover for odd and even rows */
     tr.tpOdd:hover,tr.tpEven:hover { 
        background-color: #3d80df; 
        color: #ffffff; }
  
    /* table header style */
    table.tpTable th {
        border-right: 1px solid gray;
        border-bottom: 1px solid gray;
        background: #C5D6D6;
        color: black;
        font-weight: bold;
        text-align: left;
        padding: 2px;
        overflow: hidden;
     }
     /* table header style */
    table.tpTable tr {
	    font-size: .8em;
    }
    /* selected column header (th) */
     table.tpTable th.tpHdrSelected { background: #3d80df; }
    /* filter layour */
     table.tpFilterLayout td { border: none; background: #C5D6D6; }

</style>
}

/// This XML block defines the contents of this page.
XData Contents [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<page xmlns="http://www.intersystems.com/zen" title="">

  <hgroup width="100%"  valign="top">
    <vgroup width="5%"></vgroup>
  
    <vgroup width="90%"  valign="top">
   
    <tableNavigator id="PageNav" tablePaneId="PageTable"/>
 	
 	<hgroup valign="top">
 	
    <tablePane 
    id="PageTable" 
    pageSize="10" 
    maxRows="100000"
    showRowNumbers="true" 
    showZebra="true" 
    useSnapshot="true"
    extraColumnWidth="25px"
    caption="Page Definitions"
    orderByClause="PageName Asc, MethodOrder Asc"
	tableName="IIBAENSEMBLE_csp.SupportPageDefinition" 
    width="1200px"
    onselectrow="zenPage.fillForm('');"
    >
	<column colName="ID" hidden="true" />
   	<column header="PageName" width="100px" colName="PageName" filterType="text"/>
   	<column header="PageTitle" width="200px" colName="PageTitle" filterType="text"/>
   	<column header="PageClass" width="300px" colName="PageClass" filterType="text"/>
   	<column header="Order" width="50px" colName="MethodOrder" filterType="text"/>
   	<column header="MethodName" width="200px" colName="MethodName" filterType="text"/>
   	<column header=""	width="40px" linkCaption="edit" link="javascript:zenPage.fillForm('#(%query.ID)#');"/>


    </tablePane>
    <spacer width=".5em"/>
  <dataController id="PageData"  
    modelClass="IIBAENSEMBLE.csp.SupportPageDefinition.Model" 
    modelId=""
/>
    
    <fieldSet id="PageFormGroup" hidden="false" legend="Edit">
	<form id="PageForm" 
         controllerId="PageData" 
         layout="vertical"
         cellStyle="padding: 2px; padding-left: 5px; padding-right: 5px;">
         <text label="PageName:" dataBinding="PageName" id="PageName" name="PageName" size="25"/>
         <spacer height=".5em"/> 
		 <text label="PageTitle:" dataBinding="PageTitle" id="PageTitle" name="PageTitle" size="25"/>
         <spacer height=".5em"/> 
		 <text label="PageClass:" dataBinding="PageClass" id="PageClass" name="PageClass" size="25"/>
		 <spacer height=".5em"/> 
		 <text label="MethodOrder:" dataBinding="MethodOrder" id="MethodOrder" name="MethodOrder" size="25"/>
		 <spacer height=".5em"/> 
		 <text label="MethodName:" dataBinding="MethodName" id="MethodName" name="MethodName" size="25"/>
		 <spacer height=".5em"/> 
		  <hgroup>
  		<button caption="Save" onclick="zenPage.savePage();" />
  		<spacer width="5"/>
  		<button caption="New" onclick="zenPage.newPage();" />
  		<spacer width="5"/>
  		<button caption="Delete" onclick="zenPage.deletePage();" />
		 </hgroup>  
	</form>	
	</fieldSet>
	
	</hgroup>
    </vgroup>
  
    <vgroup width="5%"></vgroup>
  
 </hgroup>

</page>
}

/// save contact model to database
ClientMethod savePage() [ Language = javascript ]
{
  // validate and save form
  var form = zenPage.getComponentById('PageForm');
  form.save();
  var table=zenPage.getComponentById('PageTable');
  //refresh data in contact table
  table.executeQuery();
}

/// Create new object via dataModel
ClientMethod newPage() [ Language = javascript ]
{
  var controller = zenPage.getComponentById('PageData');
  controller.createNewObject();
}

/// Delete current item from database
ClientMethod deletePage() [ Language = javascript ]
{
  var controller = zenPage.getComponentById('PageData');
  controller.deleteId(controller.getModelId());
  var table = zenPage.getComponentById('PageTable');
   //refresh data in contact table
  table.executeQuery(true);
  controller.update();
}

ClientMethod fillForm(id) [ Language = javascript ]
{
  var controller = zenPage.getComponentById('PageData');
  controller.setProperty('modelId',id);
}

}
