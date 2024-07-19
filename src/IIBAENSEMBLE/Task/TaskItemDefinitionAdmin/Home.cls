/// Copyright 2007 by Inland Imaging Business Associates
/// Created using the page template: Default
Class IIBAENSEMBLE.Task.TaskItemDefinitionAdmin.Home Extends %ZEN.Component.page [ DependsOn = IIBAENSEMBLE.Zen.ToolkitHeader ]
{

/// Class name of application this page belongs to.
Parameter APPLICATION = "IIBAENSEMBLE.Task.TaskItemDefinitionAdmin.Admin";

/// Displayed name of this page.
Parameter PAGENAME = "Home";

/// Domain used for localization.
Parameter DOMAIN = "ZENToolKIT";

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

// <page xmlns="http://www.intersystems.com/zen" title="">

/// This XML block defines the contents of this page.
XData Contents [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<page xmlns:ZENToolKIT="http://www.intersystems.com/toolkitheader" title="IIBA Support" width="auto" id="maintitle">

<ZENToolKIT:ToolkitHeader id="title" title="Task Items List"/>


  <hgroup width="100%"  valign="top">
    <vgroup width="5%"></vgroup>
  
    <vgroup width="90%"  valign="top">
   
    <tableNavigator id="TaskItemNav" tablePaneId="TaskItemTable"/>
 	
 	<hgroup valign="top">
 	
    <tablePane 
    id="TaskItemTable" 
    pageSize="10" 
    maxRows="100000"
    showRowNumbers="true" 
    showZebra="true" 
    useSnapshot="true"
    extraColumnWidth="25px"
    caption="Task Item Definitions"
	sortOrder="asc" 
    tableName="IIBAENSEMBLE_Task.TaskItemDefinition" 
    width="1200px"
    onselectrow="zenPage.fillForm('');"
    >
	<column colName="ID" hidden="true" />
   	<column header="NameSpace" width="100px" colName="NameSpace" filterType="text"/>
   	<column header="ItemType" width="150px" colName="ItemType" filterType="text"/>
   	<column header="ItemName" width="400px" colName="ItemName" filterType="text"/>
   	<column header="ItemValue" width="400px" colName="ItemValue" filterType="text"/>
   	<column header=""	width="40px" linkCaption="edit" link="javascript:zenPage.fillForm('#(%query.ID)#');"/>


    </tablePane>
    <spacer width=".5em"/>
  <dataController id="TaskItemData"  
    modelClass="IIBAENSEMBLE.Task.TaskItemDefinitionAdmin.Model" 
    modelId=""
/>
    
    <fieldSet id="TaskItemFormGroup" hidden="false" legend="Edit">
	<form id="TaskItemForm" 
         controllerId="TaskItemData" 
         layout="vertical"
         cellStyle="padding: 2px; padding-left: 5px; padding-right: 5px;">
         <text label="NameSpace:" dataBinding="NameSpace" id="NameSpace" name="NameSpace" size="25"/>
         <spacer height=".5em"/> 
		 <text label="ItemType:" dataBinding="ItemType" id="ItemType" name="ItemType" size="25"/>
		 <spacer height=".5em"/> 
		 <text label="ItemName:" dataBinding="ItemName" id="ItemName" name="ItemName" size="25"/>
		 <spacer height=".5em"/> 
		 <text label="ItemValue:" dataBinding="ItemValue" id="ItemValue" name="ItemValue" size="25"/>
		 <spacer height=".5em"/> 
		  <hgroup>
  		<button caption="Save" onclick="zenPage.saveTaskItem();" />
  		<spacer width="5"/>
  		<button caption="New" onclick="zenPage.newTaskItem();" />
  		<spacer width="5"/>
  		<button caption="Delete" onclick="zenPage.deleteTaskItem();" />
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
ClientMethod saveTaskItem() [ Language = javascript ]
{
  // validate and save form
  var form = zenPage.getComponentById('TaskItemForm');
  form.save();
  var table=zenPage.getComponentById('TaskItemTable');
  //refresh data in contact table
  table.executeQuery();
}

/// Create new object via dataModel
ClientMethod newTaskItem() [ Language = javascript ]
{
  var controller = zenPage.getComponentById('TaskItemData');
  controller.createNewObject();
}

/// Delete current item from database
ClientMethod deleteTaskItem() [ Language = javascript ]
{
  var controller = zenPage.getComponentById('TaskItemData');
  controller.deleteId(controller.getModelId());
  var table = zenPage.getComponentById('TaskItemTable');
   //refresh data in contact table
  table.executeQuery(true);
  controller.update();
}

ClientMethod fillForm(id) [ Language = javascript ]
{
  var controller = zenPage.getComponentById('TaskItemData');
  controller.setProperty('modelId',id);
}

}
