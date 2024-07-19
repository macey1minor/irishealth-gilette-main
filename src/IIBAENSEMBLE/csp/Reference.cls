/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.csp.Reference Extends %CSP.Page [ ProcedureBlock ]
{

ClassMethod CheckPermissions()
{
	set Allowed = 0
	// Req#1 - Phegel Changed to use the Reference resource so you don't need to have %All permissions to use.
	if ##class(%SYSTEM.Security).Check("Reference", "USE")
		{ 
			set Allowed = 1 
		}
	
	Quit Allowed
}

ClassMethod jsfunction()
{
  &html<
      	
	<script type="text/javascript" src="modalbox/modalbox.js"></script>
	<link rel="stylesheet" href="modalbox/modalbox.css" type="text/css" />
	<link rel="stylesheet" type="text/css" href="ext/resources/css/ext-all.css" />
	<link rel="stylesheet" type="text/css" href="ext/examples/form/file-upload.css"/>

	<script type="text/javascript" src="ext/adapter/ext/ext-base.js"></script>
	<script type="text/javascript" src="ext/ext-all.js"></script>
	
	<script type="text/javascript" src="ext/examples/grid-filtering/menu/EditableItem.js"></script>
	<script type="text/javascript" src="ext/examples/grid-filtering/menu/RangeMenu.js"></script>
	<script type="text/javascript" src="ext/examples/grid-filtering/grid/GridFilters.js"></script>
	<script type="text/javascript" src="ext/examples/grid-filtering/grid/filter/Filter.js"></script>
	<script type="text/javascript" src="ext/examples/grid-filtering/grid/filter/StringFilter.js"></script>
	<script type="text/javascript" src="ext/examples/grid-filtering/grid/filter/DateFilter.js"></script>
	<script type="text/javascript" src="ext/examples/grid-filtering/grid/filter/ListFilter.js"></script>
	<script type="text/javascript" src="ext/examples/grid-filtering/grid/filter/NumericFilter.js"></script>
	<script type="text/javascript" src="ext/examples/grid-filtering/grid/filter/BooleanFilter.js"></script>
	<script type="text/javascript" src="ext/examples/form/FileUploadField.js"></script>
	

   <script language=javascript>
	
	
	function Initialize()
	{
		initGridFilters()
	}
	
	window.onbeforeunload = clearSRS;
	
	function clearSRS() {
		
		var OK = #server(..clearSRS())#; 
		 
	}
	
	function testCall(){
		#call(..testCall())#;
	}
	function reloadEXT(Id) {
		var OK = #server(..gridXRef(Id))#; 
	}
	function reload(ID) {
		var M = document.getElementById('HideMultiples').checked;
		window.location = 'IIBASupport.csp?PageName=Reference&ID='+ID+'&HideMultiples='+M
	}
	function showRValues(sPVID,sRTID)
	{
		var cId = 'RVL^'+sPVID+'^'+sRTID
		
				
		if (document.getElementById(cId).innerHTML != '...')
		{
		
			while (document.getElementById(cId).hasChildNodes())
			{
				document.getElementById(cId).removeChild(document.getElementById(cId).childNodes[0]);
			}
			document.getElementById(cId).className='less'
			document.getElementById(cId).innerHTML = '...';
		}
		else
		{
			document.getElementById(cId).innerHTML = '';
			document.getElementById(cId).className='more'
			var done = #server(..showRValues(sPVID,sRTID))#;
		}
		
	}
	function columnFilter()
	{
		var rowFlt = document.getElementById('refTableHeader').rows[0].cells;
		var sFilters = '';
		for ( var i=0; i<rowFlt.length-1; ++i) {
			//alert(i+' '+rowFlt[i].childNodes[0].id);
			// SysType^ID^filter value
			var sSysType = rowFlt[i].childNodes[0].id.split('^')[1].toString()
			var sSysId = rowFlt[i].childNodes[0].id.split('^')[2].toString()
			var sFilter = rowFlt[i].childNodes[0].value;
			sFilters += sSysType+'^'+sSysId+'^'+sFilter+','
		}
		var done = #server(..getFilterPValues(sFilters))#;
		
		
	}
	

	function rowEdit(PVId) 
	{
		var row=document.getElementById('row'+PVId);
		//alert(row.cells.length);
		
		var sPTPrincipalRole = #server(..getPrincipalRole())#;
		
		for (var i=0; i<row.cells.length -2; ++i) {
			
			var cId = row.cells[i].id
			if ((cId.split("^")[0]=='RVL')&&(row.cells[i].innerHTML == '...'))
			{
				showRValues(cId.split("^")[1],cId.split("^")[2])
				row.cells[i].onclick = function () {};
				
				
			} else if (cId.split("^")[0]=='RVL') {
				row.cells[i].onclick = function () {};
				
			}
			
			if (row.cells[i].firstChild.nodeType==1)
			{
				
				var n=row.cells[i].childNodes;
				for (j=0; j<n.length; j++)
				{
					
					var nId=n[j].id
					if (nId.split("^")[0]=='RVD')
					{
						
						var tId = 'RVI^'+nId.split("^")[1]+'^'+nId.split("^")[2];
						var value = n[j].innerHTML;
						var newDiv = document.createElement('div');
						newDiv.className='blockdisplay';
						newDiv.id='layoutdiv';
						var newInput = document.createElement('input');
						newInput.type='text';
						newInput.id=tId;
						newInput.value=value.replace(/\&nbsp;/g,' ');
						newInput.className='edit'
						newDiv.appendChild(newInput);
						var newImg = document.createElement('img');
						newImg.src = 'customimages/trash.gif'
						newImg.id = 'trash^'+tId
						newImg.className = 'inlinedisplay'
						newImg.onclick = function () {removeRV(this.id)};
						newDiv.appendChild(newImg);
						row.cells[i].replaceChild(newDiv,n[j]);
						
					}
					if (nId.split("^")[0]=='PVD')
					{
						var tId = 'PVI^'+nId.split("^")[1];
						var value = n[j].innerHTML;
						var newInput = document.createElement('input');
						newInput.type='text';
						newInput.id=tId;
						newInput.value=value.replace(/\&nbsp;/g,' ');
						row.cells[i].replaceChild(newInput,n[j]);
					}
				}			
			
			} else {
				var value = row.cells[i].innerHTML;
				value = value.replace(/\&nbsp;$/,"");
				var tId = 'RVI^^'+cId.split("^")[2]
				row.cells[i].innerHTML='<input type="text" id="'+tId+'" value="'+value+'" class="edit">';
			}
			
			if ((cId.split("^")[0]!='PV')&&(sPTPrincipalRole=="target"))
			{

				var newImg = document.createElement('img');
				newImg.src = 'customimages/plus.gif'
				newImg.id = 'btn^'+cId.split("^")[0]+'^'+cId.split("^")[1]+'^'+cId.split("^")[2];
				newImg.onclick = function () {addEmptyInput(this.id)};
				row.cells[i].appendChild(newImg);
			}
			
			
			
		}
		
		row.cells[row.cells.length -2].innerHTML='<img title="Save" src="customimages/save.gif" id="save" onclick="rowEditSave(\''+PVId+'\');" >';
		row.cells[row.cells.length -1].innerHTML='<img title="Cancel" src="customimages/cancel.gif" id="cancel" onclick="rowEditCancel(\''+PVId+'\');" >';
		
		
	}
	
	function addEmptyInput(btnId) 
	{
		//alert(btnId);
		
		var c = document.getElementById(btnId.split("^")[1]+'^'+btnId.split("^")[2]+'^'+btnId.split("^")[3]);
		var b = document.getElementById(btnId);
		var newDiv = document.createElement('div');
		newDiv.className='blockdisplay';
		var newInput = document.createElement('input');
		newInput.type='text';
		newInput.className='edit'
		newInput.id='RVI^^'+btnId.split("^")[3];
		newDiv.appendChild(newInput)
		c.insertBefore(newDiv,b);		
	}
	
	function rowDelete(PVId)
	{
		var confMsg = #server(..rowDeleteConfMsg(PVId))#;
		
		var r=confirm(confMsg)
		if (r==true)
		{
			var done = #server(..rowDelete(PVId))#;
	
			var row=document.getElementById('row'+PVId);
			document.getElementById('refTable').deleteRow(row.rowIndex);

		}

	}
	function removeRV(RVIId)
	{
		
		var RVId = RVIId.split("^")[2]
		
		var RVCount = #server(..removeRVcheckatleastoneremains(RVId))#;
		if (RVCount < 2) {
			alert("At least one Related Value must remain.\n")
			return;
		}
		
		var confMsg = #server(..removeRVConfMsg(RVId))#;
		var r=confirm(confMsg)
		if (r==true)
		{
			var div=document.getElementById(RVIId).parentNode
			while (div.hasChildNodes())
			{
				div.removeChild(div.childNodes[0]);
			}
			var c = div.parentNode
			var PVId = c.id.split("^")[1]
			var done = #server(..removeRV(RVId,PVId))#;
			var row=document.getElementById('row'+PVId);
			//Req#1 - PHegel - Added permission check to Javascript for editing cells
			var bHasPermission = #server(..GetHasResourcePermission())#;
			if(bHasPermission){
				row.cells[row.cells.length -2].innerHTML='<img title="Edit" src="customimages/edit.gif" id="edit" onclick="rowEdit(\''+PVId+'\');" >';
				row.cells[row.cells.length -1].innerHTML='<img title="Delete" src="customimages/trash_bold.gif" id="delete" onclick="rowDelete(\''+PVId+'\');" >';
			}
		}
	}
	
	function rowSave() 
	{
		
		var row=document.getElementById('rowIns');
		
		var sPTPrincipalRole = #server(..getPrincipalRole())#;
		
		var sRValues = '';
		for ( var i=0; i<row.cells.length -1; ++i) {
			
			
			if ((sPTPrincipalRole=="target")&&(i==row.cells.length -2))
			{
				var sPValue = 'PVI^|'+document.getElementById('InsPV').value			
			}
			else if ((sPTPrincipalRole=="source")&&(i==0))
			{
				var sPValue = 'PVI^|'+document.getElementById('InsPV').value
			}
			else
			{
				var cId = row.cells[i].id
				var tRValue = row.cells[i].childNodes[0].value
				sRValues += String.fromCharCode(10)+'RVI^^'+cId.split("^")[1]+'|'+tRValue	
			}			
		}
		
		var alertstring = "";
		if (sPValue.split("|")[1]=="")
			alertstring = "The Principal Value must not be empty.\n\n";
		
		var RValueExists = 0;
		
		for ( var i=1; i<sRValues.split(String.fromCharCode(10)).length; ++i) {
			if (sRValues.split(String.fromCharCode(10))[i].split("|")[1]!="")
			{
				RValueExists = 1
			}
		}
		
		if ((!RValueExists)||(alertstring!=""))
		{
			if (!RValueExists)
				alertstring += "At least one Related Value must be entered.\n";
			alert(alertstring);
			return;
		}
			
		
		var sValues = sPValue+sRValues
		
		//alert(sValues);
		
		var done = #server(..rowEditSave('None',sValues))#;
		
		for ( var i=0; i<row.cells.length -1; ++i) {
			
			
			if ((sPTPrincipalRole=="target")&&(i==row.cells.length -2))
			{
				document.getElementById('InsPV').value = '';			
			}
			else if ((sPTPrincipalRole=="source")&&(i==0))
			{
				document.getElementById('InsPV').value = '';
			}
			else
			{
				row.cells[i].childNodes[0].value = '';
			}			
		}
		
		
		
	}
	
	function rowEditSave(PVId)
	{
		//alert('pt0');
		//DAP - internal server error issue when adding a related value-table is too large.
		var row=document.getElementById('row'+PVId);
		
		var sPTPrincipalRole = #server(..getPrincipalRole())#;
		
		var sRValues = '';
		
		for (var i=0; i<row.cells.length -2; ++i) {
				
			var n=row.cells[i].childNodes;
			for (j=0; j<n.length; j++)
			{
				var nId=n[j].id	
				//alert(nId)
				
				{
					var ln = n[j].childNodes;
					for (k=0; k<ln.length; k++)
					{
						var lnId=ln[k].id	
						if (lnId.split("^")[0]=='RVI')
						{
							sRValues += String.fromCharCode(10)+lnId+'|'+ln[k].value;
						}
					}
				}
				if (nId.split("^")[0]=='RVI')
				{
					sRValues += String.fromCharCode(10)+nId+'|'+n[j].value;
				}
				if (nId.split("^")[0]=='PVI')
				{
					var sPValue = nId+'|'+n[j].value;
				}
			}			
		}
		
		var alertstring = "";
		if (sPValue.split("|")[1]=="")
			alertstring = "The Principal Value must not be empty.\n\n";
		
		var RValueExists = 0;
		
		for ( var i=1; i<sRValues.split(String.fromCharCode(10)).length; ++i) {
			if (sRValues.split(String.fromCharCode(10))[i].split("|")[1]!="")
			{
				RValueExists = 1
			}
		}
		
		if ((!RValueExists)||(alertstring!=""))
		{
			if (!RValueExists)
				alertstring += "At least one Related Value must be entered.\n";
			alert(alertstring);
			return;
		}
		
		var sValues = sPValue+sRValues
		
		//alert(sValues.length);
		//alert('pt1');
		var done = #server(..rowEditSave(PVId,sValues))#;
		//alert('pt3');
		//Req#1 - PHegel - Added permission check to Javascript for editing cells
		var bHasPermission = #server(..GetHasResourcePermission())#;
		if(bHasPermission){
			row.cells[row.cells.length -2].innerHTML='<img title="Edit" src="customimages/edit.gif" id="edit" onclick="rowEdit(\''+PVId+'\');" >';
			row.cells[row.cells.length -1].innerHTML='<img title="Delete" src="customimages/trash_bold.gif" id="delete" onclick="rowDelete(\''+PVId+'\');" >';
		}
				
	}
	
	function rowEditCancel(PVId)
	{
		var done = #server(..rowEditCancel(PVId))#;
		
		var row=document.getElementById('row'+PVId);
		//Req#1 - PHegel - Added permission check to Javascript for editing cells
		var bHasPermission = #server(..GetHasResourcePermission())#;
		if(bHasPermission){
			row.cells[row.cells.length -2].innerHTML='<img title="Edit" src="customimages/edit.gif" id="edit" onclick="rowEdit(\''+PVId+'\');" >';
			row.cells[row.cells.length -1].innerHTML='<img title="Delete" src="customimages/trash_bold.gif" id="delete" onclick="rowDelete(\''+PVId+'\');" >';
		}
		
	}
	function defaultsEdit()
	{
		sm('modalDefaultsDiv',(#server(..getRTCount())#*155)+40,120)
	}
	function defaultsSaveChanges()
	{
		var table=$('defaultsTable');
		var defaultValues;
		
		for (i=0; i<table.rows[1].cells.length; i++){
			defaultValues += ","+table.rows[1].cells[i].firstChild.id+'|'+table.rows[1].cells[i].firstChild.value
		}
		var save = #server(..saveDefaultValues(defaultValues))#;
	}
	function editResource()
	{
		sm('modalEditResourceDiv',400,300)
	}
	function editResourceSave()
	{
		var editResource = $('editResourceValue').value;
		var save = #server(..saveEditResource(editResource))#;
	}
	function addRelated()
	{
		sm('modalAddRelatedDiv',400,300)
	}
	function addRelatedSave()
	{
		var addRTRTS = $('addRTRTS').value;
		
		if (addRTRTS=='')
		{
			alert('All fields are required');
			return;
		}
		
		var save = #server(..saveAddRelated(addRTRTS))#;
		if (save!="Not Saved")
			reload(save);
	}
	function newRef()
	{
		sm('modalNewRefDiv',400,400)
	}
	function newRefSave()
	{
		var newPTName = $('newPTName').value;
		var newPTS = $('newPTS').value;
		var newPTPR = $('newPTPR').value;
		var newRTRTS = $('newRTRTS').value;
		
		if (newPTName==''||newPTS==''||newPTPR==''||newRTRTS=='')
		{
			alert('All fields are required');
			return;
		}
		
		var save = #server(..saveNewRef(newPTName,newPTS,newPTPR,newRTRTS))#;
		if (save!="Not Saved")
			reload(save);
	}
	
	function importFormShow()
	{
		sm('modalImport',500,300)
	}
	
	var importparamsobj;
	
	function loadupdateImportProgress()
	{
		importparamsobj = eval('('+importparams+')');
		if (importparamsobj.validated)
		{
			sm('modalImportProgress',250,200);
			updateImportProgress();
		} else {
			alert("The import file could not be processed.\n\nPlease Ensure the Header Row is in the format of:\n\nPTName,PTSystem,PTRole,PValue,RTSystem,RValue");
		}
	}
	function updateImportProgress()
	{
		var importstatus = #server(..getImportStatus(importparamsobj.SessionId))#
		if (importstatus!='')
		{
			importstatusobj = eval('('+importstatus+')');
			$('importstatus').innerHTML = importstatusobj.status;
			$('importprogress').innerHTML = importstatusobj.rvcount.toString() + ' of ' +importstatusobj.totalcount.toString();
		} else {
			$('importstatus').innerHTML = 'Initializing, please wait...';
			$('importprogress').innerHTML = '';
		}
		
		if ($('importstatus').innerHTML!='Complete')
		{	
			importprogresstimer = setTimeout("updateImportProgress()", 500);
		} else {
			#server(..initImportData(importparamsobj.SessionId))#
		}
	}
	
	var exportRTList = new Array()
	function exportFormShow()
	{
		sm('modalExport',500,300)
	}
	function exportData(){
		
		var sRTSystems = ""
		var x = document.getElementsByName('exportRTs')
		for (var i = 0, len = x.length; i<len; i++)
		{
			if (x[i].checked == true)
			{
				sRTSystems += x[i].value + ","
			}
		}
		var sPTID = $('Name').value
		var filename = #server(..exportData(sPTID,sRTSystems))#
		window.location = 'IIBAENSEMBLE.csp.RefDownload.cls?filename='+filename
	}
	function removeRelatedFormShow()
	{
		sm('modalRemoveRelated',500,500)
	}
	function removeRelated(){
		
		var sRTSystems = ""
		var x = document.getElementsByName('removeRTs')
		for (var i = 0, len = x.length; i<len; i++)
		{
			if (x[i].checked == true)
			{
				sRTSystems += x[i].value + ","
			}
		}
		var sPTID = $('Name').value
		sPTID = #server(..removeRelated(sPTID,sRTSystems))#
		reload(sPTID);
		
	}
	var attrData = new Array();
	var attrFilters;
	var attrStore;
	var attrWin;
	var attrGridPanel;
	var xRefData = new Array();
	var xRefFilters;
	var xRefStore;
	var xRefWin;
	var xRefGridPanel;
	var eds;
	var fm = Ext.form;
	function attrEditGrid(sRTID){
		
		var AttributesPage = "IIBAENSEMBLE.Zen.xRefAttrPage.cls";
		var open = window.open(AttributesPage+"?ID="+sRTID,"_blank");
		//alert('in function atterEditGrid - sRTID is: '+sRTID);
		//#server(..attrEditGrid(sRTID))#
	}
	function attrSave(){
		attrStore.commitChanges();
	}
	function attrShowColumns() {
		var col = attrGridPanel.getColumnModel()
		for (i=0, len = col.getColumnCount(); i<len; i++)
		{
		    col.setHidden(i,false)
		}
		attrGridPanel.getTopToolbar().items.items[2].hide()
	}
	function attrUpdate(store, record, string){
		if (string=='commit')
		{
			var sRVID = record.get('id');
			var attrJSON = Ext.util.JSON.encode(record.data);
			#server(..attrUpSert(sRVID,attrJSON))#
		}
			
	}
	function attrBeforeClose(p){ 
	  if (attrStore.getModifiedRecords().length > 0) {
		Ext.Msg.show({
			title: 'Save Changes?',
			msg: 'There are unsaved edits on the attributes grid you are closing, should they be saved?',
			buttons: Ext.Msg.YESNO,
			fn: function (r) { if (r=='yes') { attrStore.commitChanges(); }	},
			icon: Ext.MessageBox.QUESTION
			})
	  }
	  return true;
	 }
	 function exportxRefAttrData(sRTID) {
		var filename = #server(..exportxRefAttrData(sRTID))#
		window.location = 'IIBAENSEMBLE.csp.RefDownload.cls?filename='+filename
	 }
	 var simpleImport;
	 function attrImport(sRTID)
	 {
		 var ok = #server(..attrImport(sRTID))#
	 }
	 function AttrDataReload(sRTID)
	 {
		 var ok = #server(..AttrDataReload(sRTID))#
	 }
	 function msg(title, msg){
        Ext.Msg.show({
            title: title, 
            msg: msg,
            minWidth: 200,
            modal: true,
            icon: Ext.Msg.INFO,
            buttons: Ext.Msg.OK
        });
    }
 
   </script>
  >
}

ClassMethod html()
{
	
    &html<
	
	<style type="text/css">
    /*Style classes for use on this page */
    .ico_save{ background-image: url("ext/examples/shared/icons/save.gif") !important; }
    .ico_export{ background-image: url("ext/examples/shared/icons/arrow-down.gif") !important; }
    .ico_import{ background-image: url("ext/examples/shared/icons/arrow-up.gif") !important; }
    .ico_col{ background-image: url("ext/resources/images/default/grid/columns.gif") !important; }
    th.clickme{
       cursor:pointer;
       cursor:hand;
     }
     .x-grid3-hd-row td.ux-filtered-column {   
        font-style: italic;  
        font-weight: bold;
    }
     td.less{
	   cursor:pointer;
       cursor:hand;
       text-align: center;
       font-weight: bolder;
       width: 155px;
     }
     td.more{
	   cursor:pointer;
       cursor:hand;
       text-align: left;
       font-weight: normal;
       width: 155px;
     }
     
     td.PTtv{
	     border-left: medium solid gray;
	     width: 155px;
     }
     td.PTsv{
	     border-right: medium solid gray;
	     width: 155px;
     }
     div.PTtv{
	     width: 155px;
     }
     div.PTsv{
	     width: 155px;
     }
     td.RT{
	     width: 155px;
     }
     div.RVD{
	     width: 155px;
	     overflow:hidden;
     }
     img{
	   cursor:pointer;
       cursor:hand;
       display: block ;
     
     }
     img.inlinedisplay{
	   cursor:pointer;
       cursor:hand;
       display: inline ;
     
     }

     input.filtercell{
	     background-color: Khaki;
	     width: 155px;
     }
     input.insertcell{
	     width: 155px;
     }
     input.btn1{
	     width: 45px;
	     height: 22px;
     }
     input.btn2{
	     width: 65px;
	     height: 22px;
     }
     input.btn3{
	     
	     height: 18px;
	     font-size: xx-small;
	      display: block ;

     }
     input.btn4{
	     
	     height: 18px;
	     font-size: xx-small;
	     display: inline ;

     }
     
     td{
	 	vertical-align: top;
	 	
	 	
	 }
	 div.blockdisplay{
		 display: block ;
	 }
	 input.edit{
		display: inline ;
		 width: 135px;
		
	 }
	 input.inlinedisplay{
		 display: inline ;
	 }
	 div.scroll {height: 600px; overflow: auto;}
	 .x-grid3-body .x-grid3-td-id{
		 background-color:#f1f2f4;

	 }
     </style>
    
    >
    
    
    w "<table><tr><td class=""LayoutContentCol"" width=""20%"" ><div class=""DetailCommand"">"
	w "&nbsp;"
        
    w "<select NAME='Name' ID='Name' onchange='reload(this.value)'>"

	// Req#1 - Phegel - initialize new variable for current resource in selected list.
	#DIM currentResource as %String = ""
	
	set rs = ##class(%ResultSet).%New()
	do rs.Prepare("select ID, Name, Resource from IIBAENSEMBLE_Reference.PrincipalType order by Name")
	set tSC = rs.Execute()
	
	if (tSC=1)
	w:tSC=1 "<option VALUE="""">Select Reference..."
	W:tSC'=1 "<option VALUE="""">ACCESS DENIED"
	While rs.Next() {
		set resource = rs.Data("Resource")
		// Req#1 - Phegel - Change to only check for Use permissioins on the resource (note: User Needs CRUD permissions on the table as well.)
		if (resource="")||(##class(%SYSTEM.Security).Check(resource,"USE")) {
			if rs.Data("ID") = %request.Get("ID"){
				w "<option VALUE="""_rs.Data("ID")_""" selected>"_rs.Data("Name")
				set currentResource = resource
			} else {
				w "<option VALUE="""_rs.Data("ID")_""">"_rs.Data("Name")
			}
		}	
	}

	w "</select>"
	w "&nbsp;|&nbsp;"
	set HideMultiples = %request.Get("HideMultiples")
	set %session.Data("HideMultiples") = %request.Get("HideMultiples")
	if HideMultiples = "false" {
	w "<Input class='inlinedisplay' Type=""checkbox"" Name=""HideMultiples"" ID=""HideMultiples"" onclick=""reload(document.getElementById('Name').value)"">"
	} else {
	w "<Input class='inlinedisplay' Type=""checkbox"" Name=""HideMultiples"" ID=""HideMultiples"" checked=true onclick=""reload(document.getElementById('Name').value)"">"
	}

	w "<nobr>&nbsp;Hide Multiples&nbsp;</nobr>"
	// Req#1 - Phegel - Changed Security Check for Create Ref and Attribute Definition.
	//
	if ( ##class(%SYSTEM.Security).Check("Reference","WRITE")) {
		w "|"
		w "<a class=""DetailCommand"" target=""_top"" href="""" onclick=""newRef();return false""><nobr>&nbsp;Create New Ref&nbsp;</nobr></A>"
		w "<a class=""DetailCommand"" target=""_top"" href=""IIBASupport.csp?PageName=RefAddAttr&ID="_%request.Get("ID")_"""><nobr>&nbsp;Attribute Definition&nbsp;</nobr></A>"
		w "|"
		w "<a class=""DetailCommand"" target=""_top"" href="""" onclick=""importFormShow();return false""><nobr>&nbsp;Import&nbsp;</nobr></A>"
		if (%request.Get("ID")'="" )&&(currentResource="" || ##class(%SYSTEM.Security).Check(currentResource,"WRITE")){
			w "<div id=""menuAddRelated"" style=""display: inline;""></div>"
			w "<div id=""menuRemoveRelated"" style=""display: inline;""></div>"
			w "|"
			w "<a class=""DetailCommand"" target=""_top"" href=""IIBAENSEMBLE.Zen.xRefAuditList.cls""><nobr>&nbsp;View xRef Audit&nbsp;</nobr></A>"
		}
	}
	if (%request.Get("ID")'="" )&&(currentResource="" || ##class(%SYSTEM.Security).Check(currentResource,"WRITE")){
		w "<div id=""menuExport"" style=""display: inline;""></div>"
		w "<div id=""menuEditDefaults"" style=""display: inline;""></div>"
		// Req#1 - Phegel - Changed Security Check 
		if ##class(%SYSTEM.Security).Check("%All","READ,WRITE,USE") {
			w "|"
			w "<a class=""DetailCommand"" target=""_top"" href="""" onclick=""editResource();return false""><nobr>&nbsp;Edit Resource&nbsp;</nobr></A>"
		}

	}
	// Req #2 - Phegel - Add the View Audit List button
	
	w "</div>"
	w "</td></tr></table>"
	&HTML<
 <div id="attrGrid" ></div>
 <div id="attrImportForm" ></div>
 >
	
 /*
	  &HTML<
 <div id="xRefGrid" ></div>
 <input type="button" name="click" id="click" value="click" onclick="#server(..gridXRef('14'))#">
 
 >
 w "//Temporary DDL for new Grid<br>"
 w "<select NAME='Name' ID='Name' onchange='reloadEXT(this.value)'>"
	w "<option VALUE="""">Select Reference..."

	set rs = ##class(%ResultSet).%New()
	do rs.Prepare("select ID, Name, Resource from IIBAENSEMBLE_Reference.PrincipalType order by Name")
	do rs.Execute()
	While rs.Next() {
		if (rs.Data("Resource")="")||(##class(%SYSTEM.Security).Check(rs.Data("Resource")) = "READ,WRITE,USE") {
			if rs.Data("ID") = %request.Get("ID"){
				w "<option VALUE="""_rs.Data("ID")_""" selected>"_rs.Data("Name")
			} else {
				w "<option VALUE="""_rs.Data("ID")_""">"_rs.Data("Name")
			}
		}	
	}

	w "</select>"
 */	
 
 	
 	
 	//// Create New Reference
 	w "<div class='dialog' id=""modalNewRefDiv"" >"
 	w ..buildmodalNewRefDiv()
 	w "</div>"
 	//// Import Data
 	w "<div class='dialog' id=""modalImport"" >"
 	w ..buildmodalImport()
 	w "</div>"
 	//// Import Data Progress
 	w "<div class='dialog' id=""modalImportProgress"" >"
 	w ..buildmodalImportProgress()
 	w "</div>"
 	
 	w "<div id='tablediv'>"
 	w "<div style=""display: none;""><br><input type=""button"" onclick=""attrImport()"" value=""click""><br></div>"
 	
 if %request.Get("Mode")="Import" {
	//w "Import file is being processed...<p>"
    s importstream = ##class(%GlobalCharacterStream).%New()
	d importstream.CopyFrom(%request.GetMimeData("importfile"))
	s importparams = ..importData(importstream,%request.Get("importType"),%session.SessionId)
	//w "<br>"_%session.SessionId
	&html<
    <script type="text/javascript" >
    #call(IIBAENSEMBLE.cls.xRefImport.ProcessNewFiles())#;
    var importparams = #(..QuoteJS(importparams))#
    var importprogresstimer = setTimeout("loadupdateImportProgress()", 200); 
	</script>
	>
	
 }

 if %request.Get("ID")'="" {
 	set sPTID = %request.Get("ID")
	set oPT = ##class(IIBAENSEMBLE.Reference.PrincipalType).%OpenId(sPTID)
	set currentResource = oPT.Resource
	if (currentResource="")||(##class(%SYSTEM.Security).Check("Reference","USE")) {
		// Bug-#5 PHegel- moved up so that variables are initialized earlier and are stored in session before other methods need them.
		merge %session.Data("oPT") = oPT
		
		set sPTName = oPT.Name
		set %session.Data("sPTName") = oPT.Name
		set %session.Data("sPTID") = sPTID
		set %session.Data("sPTSystem") = %session.Data("oPT").System
		set %session.Data("sPTPrincipalRole") = %session.Data("oPT").PrincipalRole
	
		set ^CacheTempMSimpson = sPTName_"^"_%session.Data("sPTSystem")_"^"_%session.Data("sPTPrincipalRole")_"^"_%session.SessionId	
		
		do ..getTblData(sPTName,%session.Data("sPTSystem"),%session.Data("sPTPrincipalRole"))

		&html<
	    <script type="text/javascript" >
	    document.getElementById("menuExport").innerHTML = "|<a class='DetailCommand' target='_top' href='' onclick='exportFormShow();return false'><nobr>&nbsp;Export&nbsp;</nobr></A>"
	  		</script>
		>
		if (currentResource="")||(##class(%SYSTEM.Security).Check(currentResource,"USE")) {
			&html<
		    <script type="text/javascript" >
		    document.getElementById("menuAddRelated").innerHTML = "|<a class='DetailCommand' target='_top' href='' onclick='addRelated();return false'><nobr>&nbsp;Add Related&nbsp;</nobr></A>"
		    document.getElementById("menuRemoveRelated").innerHTML = "|<a class='DetailCommand' target='_top' href='' onclick='removeRelatedFormShow();return false'><nobr>&nbsp;Remove Related&nbsp;</nobr></A>"
		    document.getElementById("menuEditDefaults").innerHTML = "|<a class='DetailCommand' target='_top' href='' onclick='defaultsEdit();return false'><nobr>&nbsp;Edit Defaults&nbsp;</nobr></A>"
			</script>
			>
	 	
		 	w "<div class='dialog' id=""modalRemoveRelated"" >"
		 	w ..buildmodalRemoveRelated()
		 	w "</div>"
	 			
	 	}
	
	
		w "<div class='dialog' id=""modalExport"" >"
	 	w ..buildmodalExport()
	 	w "</div>"
	 	
	 	w "<div class='dialog' id=""modalRemoveRelated"" >"
	 	w ..buildmodalRemoveRelated()
	 	w "</div>"

		set bHasPermission = ..GetHasResourcePermission()
		w ..buildTableHeader(bHasPermission)
	
		set divwidth = ((%session.Data("count")+1)*155)+125
	
		w "<div class=""scroll"" style=""width: "_divwidth_"px;"">"
		w "<table ID='refTable' class=""DetailTable"" border=""1"" cellpadding=""2"" cellspacing=""0"" >"
	
		set sUCPV="", sPValue="", i=2
		For  { Set sUCPV=$O(^CacheTempaRV(%session.SessionId_"UpperCase",sUCPV)) Q:sUCPV=""
		//For  { Set sPValue=$O(^CacheTempaRV(%session.SessionId,sPValue)) Q:sPValue=""
			set sPValue = ^CacheTempaRV(%session.SessionId_"UpperCase",sUCPV)
		 	set sPVID = ^CacheTempaRV(%session.SessionId,sPValue)
	 	
		 	if i#2=0 {
				w "<tr class=""EvenRow"" id=""row"_^CacheTempaRV(%session.SessionId,sPValue)_""">"
			} Else {
				w "<tr class=""OddRow"" id=""row"_^CacheTempaRV(%session.SessionId,sPValue)_""">"
			}	
	 	
			if %session.Data("sPTPrincipalRole") = "source" { w "<td class=""PTsv"" id=""PV^"_sPVID_"""><div class=""PTsv"" id=""PVD^"_sPVID_""">"_##class(IIBAENSEMBLE.Functions).StringReplace(sPValue," ","&nbsp;")_"</div></td>" }	
	  
			set sUCRT="",sRTSystem=""
			For  { Set sUCRT=$O(^CacheTempaRV(%session.SessionId_"UpperCase",sUCPV,sUCRT)) Q:sUCRT=""
			//For  { Set sRTSystem=$O(^CacheTempaRV(%session.SessionId,sPValue,sRTSystem)) Q:sRTSystem=""
				set sRTSystem = ^CacheTempaRV(%session.SessionId_"UpperCase",sUCPV,sUCRT)
				set sRVCount = $P(^CacheTempaRV(%session.SessionId,sPValue,sRTSystem),"^",1)
				set sRTID = $P(^CacheTempaRV(%session.SessionId,sPValue,sRTSystem),"^",2)
				if sRVCount=0{ 
					w "<td class=""RT"" id=""RV^"_sPVID_"^"_sRTID_""">&nbsp;</td>" 
				} 
			
				set sUCRV="", sRValue="", iRVCount = 0
				For  { Set sUCRV=$O(^CacheTempaRV(%session.SessionId_"UpperCase",sUCPV,sUCRT,sUCRV)) Q:sUCRV=""
				//For  { Set sRValue=$O(^CacheTempaRV(%session.SessionId,sPValue,sRTSystem,sRValue)) Q:sRValue=""
					set sRValue = ^CacheTempaRV(%session.SessionId_"UpperCase",sUCPV,sUCRT,sUCRV)
					set sRVID = ^CacheTempaRV(%session.SessionId,sPValue,sRTSystem,sRValue)
				
					if sRVCount=1{
						w "<td class=""RT"" id=""RV^"_sPVID_"^"_sRTID_""">"
						w "<div class=""RVD"" id=""RVD^"_sRVID_"^"_sRTID_""">"_##class(IIBAENSEMBLE.Functions).StringReplace(sRValue," ","&nbsp;")_"</div>"
					} elseif sRVCount>1  {
						if HideMultiples="true" {
							w "<td id=""RVL^"_sPVID_"^"_sRTID_""" class='less' onclick=""showRValues('"_sPVID_"','"_sRTID_"')"">...</td>"
						
							Quit
						} else {
							set iRVCount = iRVCount+1
							if iRVCount = 1 {
								w "<td class=""RT"" id=""RV^"_sPVID_"^"_sRTID_""">"
							}
							w "<div class=""RVD"" id=""RVD^"_sRVID_"^"_sRTID_""">"_##class(IIBAENSEMBLE.Functions).StringReplace(sRValue," ","&nbsp;")_"</div>"
							if iRVCount = sRVCount {
								w "</td>"
							}
						}
					}	
				}
			}
		  	if %session.Data("sPTPrincipalRole") = "target" { w "<td class=""PTtv"" id=""PV^"_sPVID_"""><div class=""PTtv"" id=""PVD^"_sPVID_""">"_##class(IIBAENSEMBLE.Functions).StringReplace(sPValue," ","&nbsp;")_"</div></td>" }
		  	//Req#1 - PHegel - Added permission check for editing cells
		  	set bHasPermission = ..GetHasResourcePermission()
			if (bHasPermission=1){
		  		w "<td><img Title='Edit' src='customimages/edit.gif' id='edit' onclick=""rowEdit('"_^CacheTempaRV(%session.SessionId,sPValue)_"');""></td>"
		  		w "<td><img Title='Delete' src='customimages/trash_bold.gif' id='delete' onclick=""rowDelete('"_^CacheTempaRV(%session.SessionId,sPValue)_"');""></td>"
			}
			else
			{
				w "<td colspan='2'/>"
			}
			
		  	w "</tr>",!
		  	set i=i+1	
		}
		w "</table>"
		w "</div>"
	
 	}	
 }
 w "</div>"
}

ClassMethod buildmodalDefaultsDiv() As %String [ Language = objectscript ]
{
	set sHTML=""
	set sHTML=sHTML_"<div style=""margin-bottom: 10px;text-align:center""><h3>Default Values for reference "_%session.Data("sPTName")_"</h3></div>"
 	set sHTML=sHTML_"<Table id=""defaultsTable"" class=""DetailTable"" border=""1"" cellpadding=""2"" cellspacing=""0"" ><tr>"
 	set sUCRT="",sRTSystem=""
	for  { Set sUCRT=$O(%session.Data("aRTSystemUpperCase",sUCRT)) Q:sUCRT=""	
	//for  { Set sRTSystem=$O(%session.Data("aRTSystem",sRTSystem)) Q:sRTSystem=""	
 		set sRTSystem = %session.Data("aRTSystemUpperCase",sUCRT)
		set sHTML=sHTML_"<th>"
 		set sHTML=sHTML_sRTSystem_"</th>" 
 	}
 	set sHTML=sHTML_"</tr><tr>"
 	set sUCRT="",sRTSystem=""
	for  { Set sUCRT=$O(%session.Data("aRTSystemUpperCase",sUCRT)) Q:sUCRT=""	
	//for  { Set sRTSystem=$O(%session.Data("aRTSystem",sRTSystem)) Q:sRTSystem=""	
 		set sRTSystem = %session.Data("aRTSystemUpperCase",sUCRT)
		set sHTML=sHTML_"<td><input type=""text"" name=""RTD"_%session.Data("aRTSystem",sRTSystem,"ID")_""" id=""RTD^"_%session.Data("aRTSystem",sRTSystem,"ID")_""" value="""
 		set sHTML=sHTML_##class(IIBAENSEMBLE.Reference.RelatedType).%OpenId(%session.Data("aRTSystem",sRTSystem,"ID")).DefaultValue_"""></td>" 
 	}
 	set sHTML=sHTML_"</tr></table>"
 	set sHTML=sHTML_"<div style=""margin-left: 20px;margin-top: 10px""><button onclick=""hm('modalDefaultsDiv');defaultsSaveChanges()"">Save Changes</button><button onclick=""hm('modalDefaultsDiv')"">Cancel</button></div>"
 	Quit sHTML
}

ClassMethod buildmodalEditResourceDiv() As %String [ Language = objectscript ]
{
	set sHTML=""
	set sHTML=sHTML_"<div style=""margin-bottom: 10px;text-align:center""><h3>Edit Resource Required for reference "_%session.Data("sPTName")_"</h3></div>"
	set sHTML=sHTML_"<div style=""margin-left: 20px;margin-right: 20px;"">"
	set sHTML=sHTML_"<fieldset>"
		set sHTML=sHTML_"<legend>Resource</legend>"
		set sHTML=sHTML_"<table>"
		set sHTML=sHTML_"<tr><td width=""200px"">Resource: </td>"
		set sHTML=sHTML_"<td><input type=""text"" id=""editResourceValue"" value="""_##class(IIBAENSEMBLE.Reference.PrincipalType).%OpenId(%session.Data("sPTID")).Resource_"""></td></tr>"
		set sHTML=sHTML_"</table>"
	set sHTML=sHTML_"</fieldset>"	
	set sHTML=sHTML_"</div>"
	set sHTML=sHTML_"<div style=""margin-left: 20px;margin-top: 10px""><button onclick=""hm('modalEditResourceDiv');editResourceSave()"">Save</button><button onclick=""hm('modalEditResourceDiv')"">Cancel</button></div>"
	Quit sHTML
}

ClassMethod buildmodalAddRelatedDiv() As %String [ Language = objectscript ]
{
	set sHTML=""
	set sHTML=sHTML_"<div style=""margin-bottom: 10px;text-align:center""><h3>Add Related System for reference "_%session.Data("sPTName")_"</h3></div>"
	set sHTML=sHTML_"<div style=""margin-left: 20px;margin-right: 20px;"">"
	set sHTML=sHTML_"<fieldset>"
		set sHTML=sHTML_"<legend>Principal</legend>"
		set sHTML=sHTML_"<table>"
		set sHTML=sHTML_"<tr><td width=""200px"">Principal System: </td>"
		set sHTML=sHTML_"<td>"_%session.Data("sPTSystem")_"</td></tr>"
		set sHTML=sHTML_"<tr><td width=""200px"">Principal Role: </td>"
		set sHTML=sHTML_"<td>"_%session.Data("sPTPrincipalRole")_"</td></tr>"
		set sHTML=sHTML_"</table>"
	set sHTML=sHTML_"</fieldset>"
	set sHTML=sHTML_"<fieldset>"
		set sHTML=sHTML_"<legend>Related</legend>"
		set sHTML=sHTML_"<table>"
		set sHTML=sHTML_"<tr><td width=""200px"">Related System: </td>"
		set sHTML=sHTML_"<td><input type=""text"" id=""addRTRTS"" value=""""></td></tr>"
		set sHTML=sHTML_"</table>"
	set sHTML=sHTML_"</fieldset>"	
	set sHTML=sHTML_"</div>"
	set sHTML=sHTML_"<div style=""margin-left: 20px;margin-top: 10px""><button onclick=""hm('modalAddRelatedDiv');addRelatedSave()"">Save</button><button onclick=""hm('modalAddRelatedDiv')"">Cancel</button></div>"
	Quit sHTML
}

ClassMethod buildmodalNewRefDiv() As %String [ Language = objectscript ]
{
	set sHTML=""
	set sHTML=sHTML_"<div style=""margin-bottom: 10px;text-align:center""><h3>Create New Reference</h3></div>"
	set sHTML=sHTML_"<div style=""margin-left: 20px;margin-right: 20px;"">"
	set sHTML=sHTML_"<fieldset>"
		set sHTML=sHTML_"<legend>Principal</legend>"
		set sHTML=sHTML_"<table>"
		set sHTML=sHTML_"<tr><td width=""200px"">Reference Name: </td>"
		set sHTML=sHTML_"<td><input type=""text"" id=""newPTName"" value=""""></td></tr>"
		set sHTML=sHTML_"<tr><td width=""200px"">Principal System: </td>"
		set sHTML=sHTML_"<td><input type=""text"" id=""newPTS"" value=""""></td></tr>"
		set sHTML=sHTML_"<tr><td width=""200px"">Principal Role: </td>"
		set sHTML=sHTML_"<td><select id=""newPTPR"" ><option value=""source"">source<option value=""target"">target</select></td></tr>"
		set sHTML=sHTML_"<tr><td width=""200px"">Principal Resource: </td>"
		set sHTML=sHTML_"<td><input type=""text"" id=""newResource"" value=""Reference""></td></tr>"
		set sHTML=sHTML_"</table>"
	set sHTML=sHTML_"</fieldset>"
	set sHTML=sHTML_"<fieldset>"
		set sHTML=sHTML_"<legend>Related</legend>"
		set sHTML=sHTML_"<table>"
		set sHTML=sHTML_"<tr><td width=""200px"">Related System: </td>"
		set sHTML=sHTML_"<td><input type=""text"" id=""newRTRTS"" value=""""></td></tr>"
		set sHTML=sHTML_"</table>"
	set sHTML=sHTML_"</fieldset>"	
	set sHTML=sHTML_"</div>"
	set sHTML=sHTML_"<div style=""margin-left: 20px;margin-top: 10px""><button onclick=""hm('modalNewRefDiv');newRefSave()"">Save</button><button onclick=""hm('modalNewRefDiv')"">Cancel</button></div>"
	Quit sHTML
}

ClassMethod buildmodalImport() As %String [ Language = objectscript ]
{
	set sHTML=""
	set sHTML=sHTML_"<form id=""import"" method=""post"" target="""" action=""IIBASupport.csp?PageName=Reference&Mode=Import"" enctype=""multipart/form-data"">"
	set sHTML=sHTML_"<div style=""margin-bottom: 10px;text-align:center""><h3>Import Reference Data</h3></div>"
	set sHTML=sHTML_"<div style=""margin-left: 20px;margin-right: 20px;"">"
	set sHTML=sHTML_"The import file must be a csv file and must have a header row with the following columns.<br><b>PTName,PTSystem,PTRole,PValue,RTSystem,RValue</b><p>"
	set sHTML=sHTML_"Enter the path and name of the import file:<br>"
	set sHTML=sHTML_"<input type=""file"" size=""50"" id=""importfile"" name=""importfile"" value=""""><p>"
	set sHTML=sHTML_"<input type=""radio"" name=""radioImportUpdate"" id=""radioImportUpdate"" value=""Update"" checked onclick=""$('importTypeText').value=this.value;"">Insert New <b>AND</b> Update Existing Mappings.<br>"
	set sHTML=sHTML_"<input type=""radio"" name=""radioImportReplace"" id=""radioImportReplace"" value=""Replace"" onclick=""$('importTypeText').value=this.value;"">Replace All Mappings for Related Types being imported.<br>"
	set sHTML=sHTML_"<input type=""hidden"" name=""importTypeText"" id=""importTypeText"" value="""">"
	set sHTML=sHTML_"</div>"
	set sHTML=sHTML_"<div style=""margin-left: 20px;margin-top: 10px""><input type=""submit"" value=""Import"" onclick=""hm('modalImport');return true;""><button onclick=""hm('modalImport');return false;"">Cancel</button></div>"
	set sHTML=sHTML_"</form>"
	Quit sHTML
}

ClassMethod buildmodalImportProgress() As %String [ Language = objectscript ]
{
	set sHTML=""
	//set sHTML=sHTML_"<div style=""margin-bottom: 10px;text-align:center""><h3>Import Progress</h3></div>"
	set sHTML=sHTML_"<div style=""margin-left: 0px;margin-right: 0px;text-align:center"">"
	set sHTML=sHTML_"<b>Import Status:</b> <div id=""importstatus""></div><p>"
	set sHTML=sHTML_"<b>Import progress:</b> <div id=""importprogress""></div><p>"
	set sHTML=sHTML_"</div>"
	set sHTML=sHTML_"<div style=""margin-left: 0px;margin-top: 10px;text-align:center""><button onclick=""clearTimeout(importprogresstimer);hm('modalImportProgress');window.location = 'IIBASupport.csp?PageName=Reference';"">Close</button></div>"
	Quit sHTML
}

ClassMethod buildmodalExport() As %String [ Language = objectscript ]
{
	set sHTML=""
	set sHTML=sHTML_"<div style=""margin-bottom: 10px;text-align:center""><h3>Export Reference Data</h3></div>"
	set sHTML=sHTML_"<div style=""margin-left: 20px;margin-right: 20px;"">"
	set sHTML=sHTML_"Select which Related Systems to include in the export.<p>"
	set sUCRT="",sRTSystem=""
	for  { Set sUCRT=$O(%session.Data("aRTSystemUpperCase",sUCRT)) Q:sUCRT=""	
	//for  { Set sRTSystem=$O(%session.Data("aRTSystem",sRTSystem)) Q:sRTSystem=""	
 		set sRTSystem = %session.Data("aRTSystemUpperCase",sUCRT)
		set sHTML=sHTML_"<input type=""checkbox"" name=""exportRTs"" id=""checkExport"_sRTSystem_""" value = """_sRTSystem_""" >"_sRTSystem_"<br>"
 	}
	//set sHTML=sHTML_"<br>Enter the path and name of the export file:<br>"
	//set sHTML=sHTML_"<input type=""file"" size=""50"" id=""exportfilename"" value=""""><p>"
	set sHTML=sHTML_"</div>"
	set sHTML=sHTML_"<div style=""margin-left: 20px;margin-top: 10px""><button onclick=""hm('modalExport');exportData()"">Export</button><button onclick=""hm('modalExport');"">Cancel</button></div>"
	Quit sHTML
}

ClassMethod buildmodalRemoveRelated() As %String [ Language = objectscript ]
{
	set sHTML=""
	set sHTML=sHTML_"<div style=""margin-bottom: 10px;text-align:center""><h3>Remove Related Systems</h3></div>"
	set sHTML=sHTML_"<div style=""margin-left: 20px;margin-right: 20px;"">"
	set sHTML=sHTML_"Select which Related Systems to remove.<p><br>"
	set sUCRT="",sRTSystem=""
	for  { Set sUCRT=$O(%session.Data("aRTSystemUpperCase",sUCRT)) Q:sUCRT=""	
	//for  { Set sRTSystem=$O(%session.Data("aRTSystem",sRTSystem)) Q:sRTSystem=""	
 		set sRTSystem = %session.Data("aRTSystemUpperCase",sUCRT)
 		set sRTId = %session.Data("aRTSystem",sRTSystem,"ID")
		set sHTML=sHTML_"<input type=""checkbox"" name=""removeRTs"" id=""checkRemove"_sRTSystem_""" value = """_sRTId_""" >"_sRTSystem_"<br>"
 	}
	set sHTML=sHTML_"<br><p style=""color: red;"">If all Related Systems are selected, the entire table will be removed!</p>"
	set sHTML=sHTML_"</div>"
	set sHTML=sHTML_"<div style=""margin-left: 20px;margin-top: 10px""><button onclick=""hm('modalRemoveRelated');removeRelated()"">Submit</button><button onclick=""hm('modalRemoveRelated');"">Cancel</button></div>"
	Quit sHTML
}

ClassMethod buildHiddenForms() As %String [ Language = objectscript ]
{
	set sHTML=""
	
	//// Edit Defaults
 	set sHTML=sHTML_"<div class='dialog' id=""modalDefaultsDiv"" >"
 	set sHTML=sHTML_..buildmodalDefaultsDiv()
 	set sHTML=sHTML_"</div>"
 	
 	//// Add Related System
 	set sHTML=sHTML_"<div class='dialog' id=""modalAddRelatedDiv"" >"
 	set sHTML=sHTML_..buildmodalAddRelatedDiv()
 	set sHTML=sHTML_"</div>"
 	
 	//// Edit Resource
 	set sHTML=sHTML_"<div class='dialog' id=""modalEditResourceDiv"" >"
 	set sHTML=sHTML_..buildmodalEditResourceDiv()
 	set sHTML=sHTML_"</div>"
 	
	
 	Quit sHTML
}

/// Req#1 - Phegel - Added to get resource from selected principal object
ClassMethod GetCurrentResource() As %String
{
	#DIM currentResource as %String = ""
	
	set sPTID = %session.Data("sPTID")
	
	if (sPTID'="")
	{
		set oPT = ##class(IIBAENSEMBLE.Reference.PrincipalType).%OpenId(sPTID)
		set currentResource = oPT.Resource	
	}
	
	QUIT currentResource
}

ClassMethod GetHasResourcePermission() As %Boolean
{
	#DIM currentResource as %String = ..GetCurrentResource()
	set hasPermssion = ##class(%SYSTEM.Security).Check(currentResource,"Write")
	if currentResource="" { set hasPermssion = 1}
	quit hasPermssion
}

ClassMethod buildHeaderRowhtml(Resource As %String = "") As %String [ Language = objectscript ]
{
	set sHTML=""
	
	//Header cell for Principal Type when source
 	if %session.Data("sPTPrincipalRole") = "source" {set sHTML=sHTML_"<th style=""background: gray none repeat scroll 0%"" id=""PT^"_%session.Data("sPTID")_""">"_%session.Data("sPTSystem")_"</th>" }
 	//Header cells for Related Types
 	set sUCRT="",sRTSystem=""
	for  { Set sUCRT=$O(%session.Data("aRTSystemUpperCase",sUCRT)) Q:sUCRT=""	
	//for  { Set sRTSystem=$O(%session.Data("aRTSystem",sRTSystem)) Q:sRTSystem=""	
 		set sRTSystem = %session.Data("aRTSystemUpperCase",sUCRT)
		set sHTML=sHTML_"<th id=""RT^"_%session.Data("aRTSystem",sRTSystem,"ID")_""" class=""clickme"" title=""Default: "_##class(IIBAENSEMBLE.Reference.RelatedType).%OpenId(%session.Data("aRTSystem",sRTSystem,"ID")).DefaultValue_""" >"
		
 		If ( ..attrClassExists(%session.Data("aRTSystem",sRTSystem,"ID")) ) {
			s sHTML=sHTML_"<img style='display:inline;float:right;padding-right:2px;padding-top:1px' alt='Attributes' Title='Attributes' src='customimages/categories-cropped.gif'  onclick=""attrEditGrid('"_%session.Data("aRTSystem",sRTSystem,"ID")_"')""/>"
		}
		set sHTML=sHTML_sRTSystem
 		s sHTML=sHTML_"</th>" 
 	}
 	//Header cell for Principal Type when target
 	if %session.Data("sPTPrincipalRole") = "target" {set sHTML=sHTML_"<th style=""background: gray none repeat scroll 0%"" id=""PT^"_%session.Data("sPTID")_""">"_%session.Data("sPTSystem")_"</th>" }
		
	Quit sHTML
}

ClassMethod buildTableHeader(hasPermission As %Boolean = 0) As %String [ Language = objectscript ]
{
 
 	set sHTML=""
 	
 	set sHTML=sHTML_..buildHiddenForms()
 	
 	set sHTML=sHTML_"<table ID='refTableHeader' class=""DetailTable"" border=""1"" cellpadding=""2"" cellspacing=""0"" >"
 	
 	set sHTML=sHTML_"<tr>"
 	
 	//Filter cell for Principal Type when source
 	if %session.Data("sPTPrincipalRole") = "source" {
 		set sHTML=sHTML_"<td class=""PTsv""><input type=""text"" name=""flt^PT^"_%session.Data("sPTSystem")_""" id=""flt^PT^"_%session.Data("sPTID")_""" class='filtercell' value='"
 		if $DATA(%session.Data("aFilters",%session.Data("sPTSystem")))'=0 {
 			set sHTML=sHTML_%session.Data("aFilters",%session.Data("sPTSystem"))
 		}
 		set sHTML=sHTML_"' onchange=""columnFilter('"_%session.Data("sPTSystem")_"','PT');""></td>"
 	}
 	//Filter cells for Related Types
 	set sUCRT="",sRTSystem=""
	for  { Set sUCRT=$O(%session.Data("aRTSystemUpperCase",sUCRT)) Q:sUCRT=""	
	//for  { Set sRTSystem=$O(%session.Data("aRTSystem",sRTSystem)) Q:sRTSystem=""	
 		set sRTSystem = %session.Data("aRTSystemUpperCase",sUCRT)
 		set sRTID = %session.Data("aRTSystem",sRTSystem,"ID")
		set sHTML=sHTML_"<td><input type=""text"" name=""flt^RT^"_sRTID_""" id=""flt^RT^"_sRTID_""" class='filtercell' value='"
 		if $DATA(%session.Data("aFilters",sRTSystem))'=0 {
 			set sHTML=sHTML_%session.Data("aFilters",sRTSystem)
 		}
 		set sHTML=sHTML_"' onchange=""columnFilter('"_sRTSystem_"','RT');""></td>"
 	}
 	//Filter cell for Principal Type when target
 	if %session.Data("sPTPrincipalRole") = "target" {
 		set sHTML=sHTML_"<td class=""PTsv""><input type=""text"" name=""flt^PT^"_%session.Data("sPTID")_""" id=""flt^PT^"_%session.Data("sPTID")_""" class='filtercell' value='"
 		if $DATA(%session.Data("aFilters",%session.Data("sPTSystem")))'=0 {
 			set sHTML=sHTML_%session.Data("aFilters",%session.Data("sPTSystem"))
 		}
 		set sHTML=sHTML_"' onchange=""columnFilter('"_%session.Data("sPTSystem")_"','PT');""></td>"
 	}
 	
 	set sHTML=sHTML_"<td><img alt='Filter' Title='Filter' src='customimages/filter.gif' id='filter' onclick=""return true;""></td>"
 	
 	set sHTML=sHTML_"</tr>"
 	
 	set sHTML=sHTML_"<tr>"
 	
 	set sHTML=sHTML_..buildHeaderRowhtml()
 	 	
 	set sHTML=sHTML_"</tr>"
 	
 	if (hasPermission=1){
	 	set sHTML=sHTML_"<tr ID=""rowIns"">"
	 	
	 	//Input boxes for Insert Row
	 	set i=1
	 	if %session.Data("sPTPrincipalRole") = "source" {set sHTML=sHTML_"<td class=""PTsv""><Input Type=""Text"" Name=""InsPV"" ID=""InsPV"" class='insertcell' Value=""""></td>" }
	 	set sUCRT="",sRTSystem=""
		for  { Set sUCRT=$O(%session.Data("aRTSystemUpperCase",sUCRT)) Q:sUCRT=""	
		//for  { Set sRTSystem=$O(%session.Data("aRTSystem",sRTSystem)) Q:sRTSystem=""	
	 		set sRTSystem = %session.Data("aRTSystemUpperCase",sUCRT)
			set sHTML=sHTML_"<td id='RVInsert^"_%session.Data("aRTSystem",sRTSystem,"ID")_"'><Input Type=""Text"" Name=""InsRV"" id=""InsRV"" class=""insertcell"" Value=""""></td>" 
	 	}
	 	if %session.Data("sPTPrincipalRole") = "target" {set sHTML=sHTML_"<td class=""PTtv""><Input Type=""Text"" Name=""InsPV"" ID=""InsPV"" class='insertcell' Value=""""></td>" }
	 	
	 	set sHTML=sHTML_"<td><img alt='Insert' Title='Insert' src='customimages/save.gif' id='save' onclick=""rowSave();""></td>"
	 	  	
	 	set sHTML=sHTML_"</tr>"
	}
 	set sHTML=sHTML_"</table>"
 	
 Quit sHTML
}

ClassMethod checkPValueExists(Value As %String, PTId As %String) As %Boolean [ Language = objectscript ]
{
 
 set Return = 0
 
 &sql(select CASE WHEN ID <> '' THEN 1 ELSE 0 END into :Return from IIBAENSEMBLE_Reference.PrincipalValue WHERE PValue = :Value and PrincipalType = :PTId)
 
 Quit Return
}

ClassMethod checkRValueExists(Value As %String, PTId As %String, RTId As %String) As %Boolean [ Language = objectscript ]
{
 
 //&js<alert('#(Value_" - "_PTId_" - "_RTId)#')>
 
 set Return = 0
 
 &sql(select CASE WHEN ID <> '' THEN 1 ELSE 0 END into :Return from IIBAENSEMBLE_Reference.RelatedValue WHERE RValue = :Value and PrincipalValue->PrincipalType = :PTId and RelatedType = :RTId)
 
 Quit Return
}

ClassMethod getFilterPValues(sFilters As %String) As %String [ Language = objectscript ]
{
 
 	set Filtered=0
 	
 	for i=1:1:$L(sFilters,",")-1 {
 		if $P($P(sFilters,",",i),"^",3)'=""{
 			set SystemType = $P($P(sFilters,",",i),"^",1)
 			set SystemId = $P($P(sFilters,",",i),"^",2)
 			if SystemType = "PT" {
 				set System = %session.Data("sPTSystem")
 			} else {
	 			set System = ##class(IIBAENSEMBLE.Reference.RelatedType).%OpenId(SystemId).System
 			}
 			set Filter = $P($P(sFilters,",",i),"^",3)
 			
 			set %session.Data("aFilters",System)=Filter
 			set %session.Data("aFilters",System,"Found")=0
 			
 			set Filtered=1
 		
 		}
 	}
 	
 
 	
 	
 if Filtered {
	 
	// build an array named aPValues that contain all the primary values for all rows where any principal or related value matches a filter
 	
 	set sPValue=""
 	For  { Set sPValue=$O(^CacheTempaRV(%session.SessionId,sPValue)) Q:sPValue=""
 		
 		// Loop through each system that is filtered
 		// if any filter matches any of its corresponding values, found is set to 1
 		set sFiltSystem=""
 		For  { Set sFiltSystem=$O(%session.Data("aFilters",sFiltSystem)) Q:sFiltSystem=""
 			//check to see if the principal system is filtered
 			//else handle as related system filter
 			if sFiltSystem = %session.Data("sPTSystem"){
	 			if $FIND($ZCVT(sPValue,"U"),$ZCVT(%session.Data("aFilters",sFiltSystem),"U"))>0 { 
	 				set %session.Data("aFilters",sFiltSystem,"Found") = 1
	 			}
 			} else {
				set RValue = ""
 				For  { set RValue = $O(^CacheTempaRV(%session.SessionId,sPValue,sFiltSystem,RValue)) Q:RValue=""
 					if ($FIND($ZCVT(RValue,"U"),$ZCVT(%session.Data("aFilters",sFiltSystem),"U"))>0) { 
 						set %session.Data("aFilters",sFiltSystem,"Found") = 1
 					}
 				}
 			}
 		}
 		
 		// loop through each system that is filtered and verify that all systems found a match befor adding this pvalue to the list
 		// this will enforce an AND condition so that if one system filter matches and another does not, that values is not added to the list
 		set bAND = 1
 		For  { Set sFiltSystem=$O(%session.Data("aFilters",sFiltSystem)) Q:sFiltSystem=""
 			//if any system that is filtered on didn't match its corresponding values, don't add it to the list
 			if %session.Data("aFilters",sFiltSystem,"Found") '= 1 {
	 			set bAND = 0
 			}
 		}
 		
 		if bAND { set aPValues(sPValue)="" }
 		
 		//reset all found to 0 for next pvalue
 		For  { Set sFiltSystem=$O(%session.Data("aFilters",sFiltSystem)) Q:sFiltSystem=""
 			set %session.Data("aFilters",sFiltSystem,"Found") = 0
 		}
 		
 		
 	}
 	
 	//Req#1 - PHegel - Added permission check for editing cells
	/*
	set PTID = %session.Data("sPTID")
	&js< alert("Has Permission = " + #(bHasPermission)# + " to PTID: " + "'#(PTID)#'" ) >
	*/
	
	set bHasPermission = ..GetHasResourcePermission()
 	set newHTML = ..buildTableHeader(bHasPermission)
 	set newHTML = newHTML_"</table>"
 	
 	set divwidth = ((%session.Data("count")+1)*155)+125
	
	set newHTML = newHTML_"<div class=""scroll"" style=""width: "_divwidth_"px;"">"
	set newHTML = newHTML_"<table ID='refTable' class=""DetailTable"" border=""1"" cellpadding=""2"" cellspacing=""0"" >"
	set newHTML = newHTML_"</table></div>"
 	
 	set newHTML = ##class(IIBAENSEMBLE.Functions).StringReplace(newHTML,"'","\'")
 	
 	
 	&js<document.getElementById('tablediv').innerHTML='';>
 	&js<document.getElementById('tablediv').innerHTML='#(newHTML)#';>
 	
 	for i=1:1:$L(sFilters,",")-1 {
 		if $P($P(sFilters,",",i),"^",3)'=""{
 			set SystemType = $P($P(sFilters,",",i),"^",1)
 			set SystemId = $P($P(sFilters,",",i),"^",2)
 			&js<document.getElementById('flt^'+'#(SystemType)#'+'^'+'#(SystemId)#').focus()>
 		}
 	}
 	
 	kill %session.Data("aFilters")
 		
 	set sUCPV="", sPValue="", i=0
 	For  { Set sUCPV=$O(^CacheTempaRV(%session.SessionId_"UpperCase",sUCPV)) Q:sUCPV=""
 	//For  { Set sPValue=$O(^CacheTempaRV(%session.SessionId,sPValue)) Q:sPValue=""
 		set sPValue = ^CacheTempaRV(%session.SessionId_"UpperCase",sUCPV)
 	 	set sPVID = ^CacheTempaRV(%session.SessionId,sPValue)
 	 	
 	   if $DATA(aPValues(sPValue))'=0 {
 		//&js<alert(document.getElementById('refTable').rows.length);>
 		//&js<document.getElementById('refTable').insertRow(0);>
 		&js<
 		document.getElementById('refTable').insertRow(#(i)#);
 		document.getElementById('refTable').rows[#(i)#].id = 'row#(sPVID)#';
 		>
 	 	
 	 	if i#2=0 {
 			&js<document.getElementById('refTable').rows[#(i)#].className = 'EvenRow';>
 		} Else {
 			&js<document.getElementById('refTable').rows[#(i)#].className = 'OddRow';>
 		}	
 	 	
 	 	set cellcount=0
 	 	
 		if %session.Data("sPTPrincipalRole") = "source" { 
 			&js<var r=document.getElementById('refTable').rows[#(i)#];
 			var c=r.insertCell(#(cellcount)#);
 			c.id='PV^#(sPVID)#';
 			c.className='PTsv';
 			var newdiv = document.createElement('div');
 			newdiv.id = 'PVD^#(sPVID)#';
 			newdiv.innerHTML="#(sPValue)#".replace(/ /g,'&nbsp;');
 			newdiv.className='PTsv';
 			c.appendChild(newdiv);>
 			set cellcount = cellcount+1
 		}	
 		
 		
 	  
 		set sUCRT="",sRTSystem=""
 		For  { Set sUCRT=$O(^CacheTempaRV(%session.SessionId_"UpperCase",sUCPV,sUCRT)) Q:sUCRT=""
 		//For  { Set sRTSystem=$O(^CacheTempaRV(%session.SessionId,sPValue,sRTSystem)) Q:sRTSystem=""
 			set sRTSystem = ^CacheTempaRV(%session.SessionId_"UpperCase",sUCPV,sUCRT)
 			set sRVCount = $P(^CacheTempaRV(%session.SessionId,sPValue,sRTSystem),"^",1)
 			set sRTID = $P(^CacheTempaRV(%session.SessionId,sPValue,sRTSystem),"^",2)
 			if sRVCount=0{ 
 				&js<var r=document.getElementById('refTable').rows[#(i)#];
 				var c=r.insertCell(#(cellcount)#);
 				c.id='RV^#(sPVID)#^#(sRTID)#';
 				c.className='RT';
 				c.innerHTML='&nbsp;';>
 				set cellcount = cellcount+1
 			}
 			
 			set sUCRV="", sRValue="", iRVCount = 0
			For  { Set sUCRV=$O(^CacheTempaRV(%session.SessionId_"UpperCase",sUCPV,sUCRT,sUCRV)) Q:sUCRV=""
			//For  { Set sRValue=$O(^CacheTempaRV(%session.SessionId,sPValue,sRTSystem,sRValue)) Q:sRValue=""
				set sRValue = ^CacheTempaRV(%session.SessionId_"UpperCase",sUCPV,sUCRT,sUCRV)
 				set sRVID = ^CacheTempaRV(%session.SessionId,sPValue,sRTSystem,sRValue)
 				
 				if sRVCount=1{
 					&js<var r=document.getElementById('refTable').rows[#(i)#];
 					var c=r.insertCell(#(cellcount)#);
 					c.id='RV^#(sPVID)#^#(sRTID)#';
 					c.className='RT';
 					var newdiv = document.createElement('div');
 					newdiv.className='RVD';
 					newdiv.id = 'RVD^#(sRVID)#^#(sRTID)#';
 					newdiv.innerHTML="#(sRValue)#".replace(/ /g,'&nbsp;');
 					c.appendChild(newdiv);
 					>
 					set cellcount = cellcount+1
 				} elseif sRVCount>1  {
 					if %session.Data("HideMultiples")="true" {
 						
 						&js<var r=document.getElementById('refTable').rows[#(i)#];
 						var c=r.insertCell(#(cellcount)#);
 						c.id='RVL^#(sPVID)#^#(sRTID)#';
 						c.innerHTML='...';
 						c.className='less';
 						c.onclick = function () {showRValues('#(sPVID)#','#(sRTID)#')};
 						>
 						
 						set cellcount = cellcount+1
 						
 						Quit
 					} else {
 						set iRVCount = iRVCount+1
 						if iRVCount = 1 {
 							&js<var r=document.getElementById('refTable').rows[#(i)#];
 							var c=r.insertCell(#(cellcount)#);
 							c.id='RV^#(sPVID)#^#(sRTID)#';
 							c.className='RT';
 							>
 							set cellcount = cellcount+1
 						}
 						&js<var c=document.getElementById('RV^#(sPVID)#^#(sRTID)#');
 							var newdiv = document.createElement('div');
 							newdiv.className='RVD';
 							newdiv.id = 'RVD^#(sRVID)#^#(sRTID)#';
 							newdiv.innerHTML="#(sRValue)#".replace(/ /g,'&nbsp;');
 							c.appendChild(newdiv);
 						>
 						
 					}
 				}	
 			}
 		}
 	  	if %session.Data("sPTPrincipalRole") = "target" {
 			&js<var r=document.getElementById('refTable').rows[#(i)#];
 			var c=r.insertCell(#(cellcount)#);
 			c.id='PV^#(sPVID)#';
 			c.className='PTtv';
 			var newdiv = document.createElement('div');
 			newdiv.id = 'PVD^#(sPVID)#';
 			newdiv.innerHTML="#(sPValue)#".replace(/ /g,'&nbsp;');
 			newdiv.className='PTtv'
 			c.appendChild(newdiv);>
 			set cellcount = cellcount+1
 		}
 		

 		//Req#1 - PHegel - Added permission check for editing cells
		if (bHasPermission=1){
	 		&js<var r=document.getElementById('refTable').rows[#(i)#];
	 			var c=r.insertCell(#(cellcount)#);
	 			c.innerHTML='<img title="Edit" src="customimages/edit.gif" id="edit" onclick="rowEdit(\'#(sPVID)#\');" >';
	 		>
	 		set cellcount = cellcount+1
	 		&js<var r=document.getElementById('refTable').rows[#(i)#];
	 			var c=r.insertCell(#(cellcount)#);
	 			c.innerHTML='<img title="Delete" src="customimages/trash_bold.gif" id="delete" onclick="rowDelete(\'#(sPVID)#\');" >';
	 		>
		}
 		set cellcount = cellcount+1
 		 
 	  	set i=i+1	
 	  	
 	   }
 	   
 	   	
 	}
 } else {
 	&js<reload('#(%session.Data("sPTID"))#');>
 }
 
 
 Quit "OK"
}

ClassMethod getPrincipalRole() As %String [ Language = objectscript ]
{
 
 Quit %session.Data("sPTPrincipalRole")
}

ClassMethod getRTCount() As %String [ Language = objectscript ]
{
 
 Quit %session.Data("count")
}

ClassMethod getPTID() As %String [ Language = objectscript ]
{
 
 Quit %session.Data("sPTID")
}

ClassMethod getTblData(sPTName As %String, sPTSystem As %String, sPTPrincipalRole As %String) As %String [ Language = objectscript ]
{
 
 
 if sPTName'="" {
 	
 	kill ^CacheTempaRV(%session.SessionId)
 	kill ^CacheTempaRV(%session.SessionId_"UpperCase")
 	
 	
 	set rs = ##class(%ResultSet).%New()
 	do rs.Prepare("select ID, System from IIBAENSEMBLE_Reference.RelatedType where PrincipalType = "_%session.Data("sPTID")_" order by System")
 	do rs.Execute()
 	kill aRTSystem
 	set count = 0
 	While rs.Next() {
	 		set count = count+1
	 		set aRTSystemUpperCase($ZCVT(rs.Data("System"),"U")) = rs.Data("System")
	 		set aRTSystem(rs.Data("System")) = ""
	 		set aRTSystem(rs.Data("System"),"ID") = rs.Data("ID")
 	}
 	
 	do rs.Close()
 	
 	kill %session.Data("aRTSystem")
 	kill %session.Data("aRTSystemUpperCase")
 	merge %session.Data("aRTSystem") = aRTSystem
 	merge %session.Data("aRTSystemUpperCase") = aRTSystemUpperCase
 	set %session.Data("count") = count
 	
 	set sUCRT="",sRTSystem=""
	for  { Set sUCRT=$O(%session.Data("aRTSystemUpperCase",sUCRT)) Q:sUCRT=""	
	//for  { Set sRTSystem=$O(%session.Data("aRTSystem",sRTSystem)) Q:sRTSystem=""	
 		set sRTSystem = %session.Data("aRTSystemUpperCase",sUCRT)
		
 		set SQL = "select PrincipalValue, PrincipalValue->PValue, RValue, ID from IIBAENSEMBLE_Reference.RelatedValue WHERE PrincipalValue->PrincipalType->Name = '"_sPTName_"' AND RelatedType = "_%session.Data("aRTSystem",sRTSystem,"ID")
 		
 		do rs.Prepare(SQL)
 		do rs.Execute()
 		While rs.Next() {
 			
 			set sPValue = rs.Data("PValue")
 			set sRValue = rs.Data("RValue")
 			
 			set sUCRT2="",sRTSystem2=""
			for  { Set sUCRT2=$O(%session.Data("aRTSystemUpperCase",sUCRT2)) Q:sUCRT2=""	
			//for  { Set sRTSystem2=$O(%session.Data("aRTSystem",sRTSystem2)) Q:sRTSystem2=""
 				set sRTSystem2 = %session.Data("aRTSystemUpperCase",sUCRT2)
	
 				if $DATA(^CacheTempaRV(%session.SessionId,sPValue,sRTSystem2))=0 {
	 				set ^CacheTempaRV(%session.SessionId_"UpperCase",$ZCVT(sPValue,"U"),$ZCVT(sRTSystem2,"U"))=sRTSystem2
 					set ^CacheTempaRV(%session.SessionId,sPValue,sRTSystem2)="0^"_%session.Data("aRTSystem",sRTSystem2,"ID")
 				}
 			}
 			
 			set ^CacheTempaRV(%session.SessionId_"UpperCase",$ZCVT(sPValue,"U"))=sPValue
 			set ^CacheTempaRV(%session.SessionId_"UpperCase",$ZCVT(sPValue,"U"),$ZCVT(sRTSystem,"U"))=sRTSystem
 			set ^CacheTempaRV(%session.SessionId_"UpperCase",$ZCVT(sPValue,"U"),$ZCVT(sRTSystem,"U"),$ZCVT(sRValue,"U"))=sRValue
 		
 			set ^CacheTempaRV(%session.SessionId,sPValue)=rs.Data("PrincipalValue")
 			
 			set ^CacheTempaRV(%session.SessionId,sPValue,sRTSystem) = $P(^CacheTempaRV(%session.SessionId,sPValue,sRTSystem),"^",1)+1_"^"_%session.Data("aRTSystem",sRTSystem,"ID")
 			
 			set ^CacheTempaRV(%session.SessionId,sPValue,sRTSystem,sRValue)=rs.Data("ID")
 			
 			
 			
 		}
 		do rs.Close()	
 		
 	}
 	
 	
 }
 
 
 Quit "OK"
}

ClassMethod removeRV(RVId As %String, PVId As %String) As %String [ Language = objectscript ]
{
 
 do ..AuditChanges("removeRV","remove RValue: "_##class(IIBAENSEMBLE.Reference.RelatedValue).%OpenId(RVId).RValue,%session.Data("sPTID"),,PVId,RVId)
 
 do ##class(IIBAENSEMBLE.Reference.RelatedValue).%OpenId(RVId).attrDelete()
 
 do ##class(IIBAENSEMBLE.Reference.RelatedValue).%DeleteId(RVId)
 
 do ..getTblData(%session.Data("sPTName"),%session.Data("sPTSystem"),%session.Data("sPTPrincipalRole"))
 
 do ..rowEditCancel(PVId)
 
 Quit "OK"
}

ClassMethod removeRVConfMsg(RVId As %String) As %String [ Language = objectscript ]
{
 set Results = ""
 set rs = ##class(%ResultSet).%New()
 set SQL = "select RValue, RelatedType->System "
 set SQL=SQL_" from IIBAENSEMBLE_Reference.RelatedValue WHERE ID = "_RVId
 do rs.Prepare(SQL)
 do rs.Execute()
 set tNext = rs.Next()
 if tNext = 1 {
 	set Results = "Do you wish to delete "_rs.Data("System")_" value: "_rs.Data("RValue")_"?"
 }
 Quit Results
}

ClassMethod removeRVcheckatleastoneremains(RVId As %String) As %String [ Language = objectscript ]
{
 set PVId = ""
 set RVCount = ""
 &sql(select PrincipalValue->ID into :PVId from IIBAENSEMBLE_Reference.RelatedValue WHERE ID = :RVId)
 &sql(select count(RValue) as RVcount into :RVCount from IIBAENSEMBLE_Reference.RelatedValue WHERE PrincipalValue->ID = :PVId)
 
 Quit RVCount
}

ClassMethod rowDelete(PVId As %String) As %String [ Language = objectscript ]
{
 set rs = ##class(%ResultSet).%New()
 do rs.Prepare("select ID from IIBAENSEMBLE_Reference.RelatedValue WHERE PrincipalValue->ID = "_PVId)
 do rs.Execute()
 While rs.Next() {
	do ..AuditChanges("rowDelete","remove RValue: "_##class(IIBAENSEMBLE.Reference.RelatedValue).%OpenId(rs.Data("ID")).RValue,%session.Data("sPTID"),##class(IIBAENSEMBLE.Reference.RelatedValue).%OpenId(rs.Data("ID")).RelatedType.%Id(),PVId,rs.Data("ID"))
	do ##class(IIBAENSEMBLE.Reference.RelatedValue).%OpenId(rs.Data("ID")).attrDelete() 
 	do ##class(IIBAENSEMBLE.Reference.RelatedValue).%DeleteId(rs.Data("ID"))
 }
 do rs.Close()
 //&sql(DELETE from IIBAENSEMBLE_Reference.RelatedValue WHERE PrincipalValue->ID = :PVId)
 do ..AuditChanges("rowDelete","remove PValue: "_##class(IIBAENSEMBLE.Reference.PrincipalValue).%OpenId(PVId).PValue,%session.Data("sPTID"),,PVId)
 do ##class(IIBAENSEMBLE.Reference.PrincipalValue).%DeleteId(PVId)
 
 do ..getTblData(%session.Data("sPTName"),%session.Data("sPTSystem"),%session.Data("sPTPrincipalRole"))
 
 Quit "OK"
}

ClassMethod rowDeleteConfMsg(PVId As %String) As %String [ Language = objectscript ]
{
 
 set Results = ""
 
 set rs = ##class(%ResultSet).%New()
 set SQL = "select RValue, RelatedType->System, PrincipalValue->PValue "
 set SQL=SQL_" from IIBAENSEMBLE_Reference.RelatedValue WHERE PrincipalValue->ID = "_PVId
 do rs.Prepare(SQL)
 do rs.Execute()
 set tNext = rs.Next()
 if tNext = 1 {
 	set Results = "Do you wish to delete "_%session.Data("sPTSystem")_" "_%session.Data("sPTPrincipalRole")_" value: "_rs.Data("PValue")_$C(13,10)_$C(13,10)_"AND the following related values?"_$C(13,10)_$C(13,10)
 	set Results=Results_rs.Data("System")_": "_rs.Data("RValue")_$C(13,10)
 
 }
 
 While rs.Next() {
 	set Results=Results_rs.Data("System")_": "_rs.Data("RValue")_$C(13,10)
 }
 do rs.Close()
 
 Quit Results
}

ClassMethod rowEditCancel(PVId As %String) As %String [ Language = objectscript ]
{
 
 	
 	&js<
 		var row=document.getElementById('row'+#(PVId)#);
 		for (var i=0; i &lt; row.cells.length -2; ++i) {
 			while (row.cells[i].hasChildNodes())
 			{
 				row.cells[i].removeChild(row.cells[i].childNodes[0]);
 			}
 				
 		}
 		
 				
 	>
 	
 	
 	
 	
 	set oPV = ##class(IIBAENSEMBLE.Reference.PrincipalValue).%OpenId(PVId)
 	
 	set sPValue = oPV.PValue
 	
 	
 	
 	&js<
 	var c=document.getElementById('PV^'+'#(^CacheTempaRV(%session.SessionId,sPValue))#');
 	var newdiv = document.createElement('div');
 	newdiv.id = 'PVD^#(PVId)#';
 	newdiv.innerHTML="#(sPValue)#".replace(/ /g,'&nbsp;');
 	newdiv.className = 'PTsv';
 	c.appendChild(newdiv);
 	>
 	
 	set i=0
 	set sUCRT="",sRTSystem=""
	For  { Set sUCRT=$O(^CacheTempaRV(%session.SessionId_"UpperCase",$ZCVT(sPValue,"U"),sUCRT)) Q:sUCRT=""
	//For  { Set sRTSystem=$O(^CacheTempaRV(%session.SessionId,sPValue,sRTSystem)) Q:sRTSystem=""
 		set sRTSystem = ^CacheTempaRV(%session.SessionId_"UpperCase",$ZCVT(sPValue,"U"),sUCRT)
 		set sRVCount = $P(^CacheTempaRV(%session.SessionId,sPValue,sRTSystem),"^",1)
 		set sRTID = $P(^CacheTempaRV(%session.SessionId,sPValue,sRTSystem),"^",2)
 		if sRVCount=0{ 
 			&js<
 			//var row=document.getElementById('row#(PVId)#');
 			//var c=row.cells[#(i)#]
 			var c=document.getElementById('RV^#(PVId)#^#(sRTID)#')
 			c.innerHTML='&nbsp;';
 			
 			>
 			
 		}
 		
 		
 		
 		set sUCRV="", sRValue=""
 		For  { Set sUCRV=$O(^CacheTempaRV(%session.SessionId_"UpperCase",$ZCVT(sPValue,"U"),sUCRT,sUCRV)) Q:sUCRV=""
 		//For  { Set sRValue=$O(^CacheTempaRV(%session.SessionId,sPValue,sRTSystem,sRValue)) Q:sRValue=""
 			set sRValue = ^CacheTempaRV(%session.SessionId_"UpperCase",$ZCVT(sPValue,"U"),sUCRT,sUCRV)
 			set sRVID = ^CacheTempaRV(%session.SessionId,sPValue,sRTSystem,sRValue)
 			
 			if sRVCount=1{
 					&js<
 					//var row=document.getElementById('row#(PVId)#');
 					//var c=row.cells[#(i)#]
 					var c=document.getElementById('RV^#(PVId)#^#(sRTID)#')
 					if (!c)
 					{
 						var c=document.getElementById('RVL^#(PVId)#^#(sRTID)#')
 						c.id = 'RV^#(PVId)#^#(sRTID)#'
 						c.className='RT';
 					}
 					var newdiv = document.createElement('div');
 					newdiv.className='RVD';
 					newdiv.id = 'RVD^#(sRVID)#^#(sRTID)#';
 					newdiv.innerHTML="#(sRValue)#".replace(/ /g,'&nbsp;');
 					c.appendChild(newdiv);
 					>
 			} elseif sRVCount>1  {
 				if %session.Data("HideMultiples")="true" {
 						
 					&js<
 					//var row=document.getElementById('row#(PVId)#');
 					//	var c=row.cells[#(i)#]
 						var c=document.getElementById('RVL^#(PVId)#^#(sRTID)#')
 						if (!c)
 						{
 							var c=document.getElementById('RV^#(PVId)#^#(sRTID)#')
 							c.id = 'RVL^#(PVId)#^#(sRTID)#'
 						}
 						c.className='less'
 						c.innerHTML='...';
 						c.onclick = function () {showRValues('#(PVId)#','#(sRTID)#')};
 					>
 						
 					Quit
 				} else {
 						
 					&js<
 					//var row=document.getElementById('row#(PVId)#');
 					//	var c=row.cells[#(i)#]
 						var c=document.getElementById('RV^#(PVId)#^#(sRTID)#')
 						var newdiv = document.createElement('div');
 						newdiv.className='RVD';
 						newdiv.id = 'RVD^#(sRVID)#^#(sRTID)#';
 						newdiv.innerHTML="#(sRValue)#".replace(/ /g,'&nbsp;');
 						c.appendChild(newdiv);
 					>
 						
 				}
 			}
 		}
 	set i=i+1
 	}
 	
 
 Quit "OK"
}

ClassMethod rowEditSave(PVId As %String, sValues As %CSP.CharacterStream) As %String [ Language = objectscript ]
{
 	
 	set newRV = "false"
 	
 	//failing on large strings 32656.
 	//fix-input 'sValues As %CSP.CharacterStream'
 	s tValidOBJ = $CLASSNAME(sValues)
 	
 	s tStream = ##class(%GlobalCharacterStream).%New()
 	do tStream.LineTerminatorSet($C(10))
		
	if tValidOBJ = "%CSP.CharacterStream"{
		//For larger files use CopyFrom
		//Larger files will be passed as %CSP.CharacterStream reference to the page.
		d tStream.CopyFrom(sValues)
	}else{
		//This is used with smaller files where the sValues passes the value as a Text %String and will need to write to %GlobalCharacterStream
		d tStream.Write(sValues)
	}
 	//&js<alert('test');>
 	while 'tStream.AtEnd {
	 	
	 	
	 	s ValueIDSet = tStream.ReadLine()
	 	//&js<alert('#(ValueIDSet)#');>
	 	set IDSet = $P(ValueIDSet,"|",1)
		set Value = $P(ValueIDSet,"|",2)
		set vType = $P(IDSet,"^",1)
		set vID = $P(IDSet,"^",2)
		set RTId = $P(IDSet,"^",3)
		
		//...
		
	/* 	
 	}
//OLD CODE 	
	for i=1:1:$L(sValues,$C(10)) {
		set ValueIDSet = $P(sValues,$C(10),i)
		set IDSet = $P(ValueIDSet,"|",1)
		set Value = $P(ValueIDSet,"|",2)
		set vType = $P(IDSet,"^",1)
		set vID = $P(IDSet,"^",2)
		set RTId = $P(IDSet,"^",3)
	*/
		
		//&js<alert('#(Value)#'+'-'+'#(vID)#'+'-'+'#(%session.Data("sPTID"))#')>
		if Value'=""{
			
			if vID="" {
				//create new
				if vType = "PVI" {
					set newPV = "true"
					
					
					if ..checkPValueExists(Value,%session.Data("sPTID"))=1 {
						//raise alert
						&js<alert('The value: '+'#(Value)#'+' for PrincipalType: '+'#(%session.Data("sPTSystem"))#'+' already exists.');>
						
					} else {
						set oPV = ##class(IIBAENSEMBLE.Reference.PrincipalValue).%New()
						set oPV.PValue = Value
						set oPV.PrincipalType = ##class(IIBAENSEMBLE.Reference.PrincipalType).%OpenId(%session.Data("sPTID"))
						do oPV.%Save()
						set PVId = oPV.%Id()
						do ..AuditChanges("rowEditSave","new PValue:"_Value,%session.Data("sPTID"),,PVId)
					}
					
				}
		
				if (vType = "RVI")&&(PVId'="None") {
					if ..checkRValueExists(Value,%session.Data("sPTID"),RTId) && (%session.Data("sPTPrincipalRole")="target") {
						//raise alert
						&js<alert('The value: '+'#(Value)#'+' for RelatedType: '+'#(##class(IIBAENSEMBLE.Reference.RelatedType).%OpenId(RTId).System)#'+' already exists.');>
					} else {
						set oRV = ##class(IIBAENSEMBLE.Reference.RelatedValue).%New()
						set oRV.RValue = Value
						set oRV.PrincipalValue = oPV
						set oRV.RelatedType = ##class(IIBAENSEMBLE.Reference.RelatedType).%OpenId(RTId)
						do oRV.%Save()
						do ..AuditChanges("rowEditSave","new RValue:"_Value,%session.Data("sPTID"),RTId,PVId,oRV.%Id())
						do oRV.%Close()
						set oRV = ""
						set newRV = "true"
						
					}
				}
			} else {
				if vType = "PVI" {
					set newPV = "false"
					//update Principal Value
					set oPV = ##class(IIBAENSEMBLE.Reference.PrincipalValue).%OpenId(vID)
					if oPV.PValue'=Value {
						//Check to see that the new value is unique
						if ..checkPValueExists(Value,oPV.PrincipalType.%Id())=1 {
							//raise alert
							&js<alert('The value: '+'#(Value)#'+' for PrincipalType: '+'#(%session.Data("sPTSystem"))#'+' already exists.');>
						} else {
							do ..AuditChanges("rowEditSave","old PValue:"_oPV.PValue_", new PValue:"_Value,%session.Data("sPTID"),,PVId)
							set oPV.PValue=Value
							do oPV.%Save()
						}
					}

				}
				if vType = "RVI" {
					//update Related Value
					set oRV = ##class(IIBAENSEMBLE.Reference.RelatedValue).%OpenId(vID)
					if oRV.RValue'=Value {
						//Check to see that the new value is unique
						if ..checkRValueExists(Value,oRV.PrincipalValue.PrincipalType.%Id(),oRV.RelatedType.%Id()) && (%session.Data("sPTPrincipalRole")="target"){
							//raise alert
							&js<alert('The value: '+'#(Value)#'+' for RelatedType: '+'#(##class(IIBAENSEMBLE.Reference.RelatedType).%OpenId(RTId).System)#'+' already exists.');>
						} else {
							do ..AuditChanges("rowEditSave","old RValue:"_oRV.RValue_", new RValue:"_Value,%session.Data("sPTID"),oRV.RelatedType.%Id(),oRV.PrincipalValue.%Id(),oRV.%Id())
							set oRV.RValue=Value
							do oRV.%Save()
						}
					}
					do oRV.%Close()
					set oRV = ""	
				}
			}
			
		} else {
			if (vID'="")&&(vType="RVI") {
				&js<alert('Existing related values cannot be removed by clearing the input box, please use the trash icon instead.');>
			}
		}
	}
	
	do ..getTblData(%session.Data("sPTName"),%session.Data("sPTSystem"),%session.Data("sPTPrincipalRole"))
	
	if newPV'="true" {
		do ..rowEditCancel(PVId)
	} else {
		if PVId '= "None" {
			if newRV = "false" {
				do ##class(IIBAENSEMBLE.Reference.PrincipalValue).%DeleteId(PVId)
				&js<alert('Principal Value not saved because no new Related Values were entered.');>
			} elseif newRV = "true" {
				do ..rowInsert(PVId)
			}
		}
	}
	set newPV=""
	
	if PVId '= "None" {
		do oPV.%Close()
	}
	set oPV = ""	
	

	Quit tStream
}

ClassMethod rowInsert(PVId As %String) As %String [ Language = objectscript ]
{
 	set oPV = ##class(IIBAENSEMBLE.Reference.PrincipalValue).%OpenId(PVId)
 	
 	set sPValue = oPV.PValue
 	
 	set sPVID = PVId
 
 	&js<
 	var row = document.getElementById('refTable').insertRow(0);
 	row.className = 'EvenRow';
 	row.id = 'row#(sPVID)#'
 	>
 	
 	set cellcount=0
 	
 	if %session.Data("sPTPrincipalRole") = "source" { 
 		&js<var r=document.getElementById('refTable').rows[0];
 		var c=r.insertCell(#(cellcount)#);
 			c.id='PV^#(sPVID)#';
 			c.className='PTsv';
 			var newdiv = document.createElement('div');
 			newdiv.id = 'PVD^#(sPVID)#';
 			newdiv.innerHTML="#(sPValue)#".replace(/ /g,'&nbsp;');
 			newdiv.className = 'PTsv';
 			c.appendChild(newdiv);>
 			set cellcount = cellcount+1
 		}
 	
 	
 	set sUCRT="",sRTSystem=""
	For  { Set sUCRT=$O(^CacheTempaRV(%session.SessionId_"UpperCase",$ZCVT(sPValue,"U"),sUCRT)) Q:sUCRT=""
	//For  { Set sRTSystem=$O(^CacheTempaRV(%session.SessionId,sPValue,sRTSystem)) Q:sRTSystem=""
 		set sRTSystem = ^CacheTempaRV(%session.SessionId_"UpperCase",$ZCVT(sPValue,"U"),sUCRT)
 		set sRVCount = $P(^CacheTempaRV(%session.SessionId,sPValue,sRTSystem),"^",1)
 		set sRTID = $P(^CacheTempaRV(%session.SessionId,sPValue,sRTSystem),"^",2)
 		if sRVCount=0{ 
 			&js<var r=document.getElementById('refTable').rows[0];
 			var c=r.insertCell(#(cellcount)#);
 			c.id='RV^#(sPVID)#^#(sRTID)#';
 			c.className='RT';
 			c.innerHTML='&nbsp;';>
 			set cellcount = cellcount+1
 		}	
 		
 		
 		set sUCRV="", sRValue="", iRVCount = 0
		For  { Set sUCRV=$O(^CacheTempaRV(%session.SessionId_"UpperCase",$ZCVT(sPValue,"U"),sUCRT,sUCRV)) Q:sUCRV=""
		//For  { Set sRValue=$O(^CacheTempaRV(%session.SessionId,sPValue,sRTSystem,sRValue)) Q:sRValue=""
 			set sRValue = ^CacheTempaRV(%session.SessionId_"UpperCase",$ZCVT(sPValue,"U"),sUCRT,sUCRV)
 			set sRVID = ^CacheTempaRV(%session.SessionId,sPValue,sRTSystem,sRValue)
 			
 			if sRVCount=1{
 				&js<var r=document.getElementById('refTable').rows[0];
 				var c=r.insertCell(#(cellcount)#);
 				c.id='RV^#(sPVID)#^#(sRTID)#';
 				c.className='RT';
 				var newdiv = document.createElement('div');
 				newdiv.className='RVD';
 				newdiv.id = 'RVD^#(sRVID)#^#(sRTID)#';
 				newdiv.innerHTML="#(sRValue)#".replace(/ /g,'&nbsp;');
 				c.appendChild(newdiv);
 				>
 				set cellcount = cellcount+1
 			
 			} elseif sRVCount>1  {
 				if %session.Data("HideMultiples")="true" {
 						
 					&js<var r=document.getElementById('refTable').rows[0];
 					var c=r.insertCell(#(cellcount)#);
 					c.id='RVL^#(sPVID)#^#(sRTID)#';
 					c.innerHTML='...';
 					c.className='less';
 					c.onclick = function () {showRValues('#(sPVID)#','#(sRTID)#')};
 					>
 						
 					set cellcount = cellcount+1
 						
 					Quit
 				} else {
 					set iRVCount = iRVCount+1
 					if iRVCount = 1 {
 						&js<var r=document.getElementById('refTable').rows[0];
 						var c=r.insertCell(#(cellcount)#);
 						c.id='RV^#(sPVID)#^#(sRTID)#';
 						c.className='RT';
 						>
 						set cellcount = cellcount+1
 					}
 					&js<var c=document.getElementById('RV^#(sPVID)#^#(sRTID)#');
 						var newdiv = document.createElement('div');
 						newdiv.className='RVD';
 						newdiv.id = 'RVD^#(sRVID)#^#(sRTID)#';
 						newdiv.innerHTML="#(sRValue)#".replace(/ /g,'&nbsp;');
 						c.appendChild(newdiv);
 					>
 						
 				}
 			}
 			
 		}
 	
 	}
 	if %session.Data("sPTPrincipalRole") = "target" {
 		&js<var r=document.getElementById('refTable').rows[0];
 		var c=r.insertCell(#(cellcount)#);
 		c.id='PV^#(^CacheTempaRV(%session.SessionId,sPValue))#';
 		c.className='PTtv';
 		var newdiv = document.createElement('div');
 		newdiv.id = 'PVD^#(sPVID)#';
 		newdiv.innerHTML="#(sPValue)#".replace(/ /g,'&nbsp;');
 		newdiv.className='PTtv';
 		c.appendChild(newdiv);>
 		set cellcount = cellcount+1
 	}
 	//Req#1 - PHegel - Added permission check for editing cells
 	set bHasPermission = ..GetHasResourcePermission()
	if (bHasPermission=1){
	 	&js<var r=document.getElementById('refTable').rows[0];
	 		var c=r.insertCell(#(cellcount)#);
	 		c.innerHTML='<img title="Edit" src="customimages/edit.gif" id="edit" onclick="rowEdit(\'#(sPVID)#\');" >';
	 	>
	 	set cellcount = cellcount+1
	 	&js<var r=document.getElementById('refTable').rows[0];
	 		var c=r.insertCell(#(cellcount)#);
	 		c.innerHTML='<img title="Delete" src="customimages/trash_bold.gif" id="delete" onclick="rowDelete(\'#(sPVID)#\');" >';
	 	>
 	}
 	set cellcount = cellcount+1
 
 Quit "OK"
}

ClassMethod showRValues(sPVID As %String, sRTID As %String) As %String [ Language = objectscript ]
{
 
 set cId = "RVL^"_sPVID_"^"_sRTID
 
 set rs = ##class(%ResultSet).%New()
 	
 do rs.Prepare("select ID, RValue from IIBAENSEMBLE_Reference.RelatedValue WHERE PrincipalValue = '"_sPVID_"' AND RelatedType = '"_sRTID_"' ORDER BY RValue")
 do rs.Execute()
 
 While rs.Next() {
 	
 	&js<
 	
 	var newdiv = document.createElement('div');
 	newdiv.className='RVD';
 	newdiv.id = 'RVD^#(rs.Data("ID"))#^#(sRTID)#';
 	newdiv.innerHTML = "#(rs.Data("RValue"))#".replace(/ /g,'&nbsp;');
 	document.getElementById('#(cId)#').appendChild(newdiv);
 	
 	
 	>
 	
 }
 do rs.Close()
 
 Quit "OK"
}

ClassMethod saveDefaultValues(DefaultValues As %String) As %String [ Language = objectscript ]
{
	for i=2:1:$L(DefaultValues,",") {
		set ValueIDSet = $P(DefaultValues,",",i)
		set IDSet = $P(ValueIDSet,"|",1)
		set Value = $P(ValueIDSet,"|",2)
		set RTId = $P(IDSet,"^",2)
	
		set oRT = ##class(IIBAENSEMBLE.Reference.RelatedType).%OpenId(RTId)
		if oRT.DefaultValue '= Value {
			set oldValue = oRT.DefaultValue
			set oRT.DefaultValue = Value
			do oRT.%Save()
			set auditDesc = "Change RT Value from: "_oldValue_" To: "_Value
			do ..AuditChanges("saveDefaultValues",auditDesc,"",oRT.%Id())
		}
		set oRT = ""
		&js<document.getElementById('RT^'+'#(RTId)#').title='Default: '+'#(Value)#'>
	}
	set sHTML=..buildmodalDefaultsDiv()
	&js<document.getElementById('modalDefaultsDiv').innerHTML=#(..QuoteJS(sHTML))#;>
}

ClassMethod saveEditResource(strResource As %String) As %String [ Language = objectscript ]
{
	set oPT = ##class(IIBAENSEMBLE.Reference.PrincipalType).%OpenId(%session.Data("sPTID"))
	set auditDesc = "Change Resource from: "_oPT.Resource _" To: "_strResource
	set oPT.Resource = strResource
	d oPT.%Save()
	d ..AuditChanges("saveEditResource", auditDesc,oPT.%Id())
	set sHTML=..buildmodalEditResourceDiv()
	&js<document.getElementById('modalEditResourceDiv').innerHTML=#(..QuoteJS(sHTML))#;>	
 	Quit "OK"
}

ClassMethod saveAddRelated(addRTRTS As %String) As %String [ Language = objectscript ]
{
	set PTId = %session.Data("sPTID")
	
	//Check to see of RT is truly new
	set RTExists = 0
 	&sql(select CASE WHEN ID <> '' THEN 1 ELSE 0 END into :RTExists from IIBAENSEMBLE_Reference.RelatedType WHERE System = :addRTRTS AND PrincipalType = :PTId)
 	if RTExists {
	 	&js<alert('The Related Type #(addRTRTS)# already exists.');>
	 	Quit "Not Saved"
 	}
 	
 	//Create the RT using the PT
 	set oRT = ##class(IIBAENSEMBLE.Reference.RelatedType).%New()
 	set oRT.System = addRTRTS
 	set oRT.PrincipalType = ##class(IIBAENSEMBLE.Reference.PrincipalType).%OpenId(%session.Data("sPTID"))
 	set tSC = oRT.%Save()
 	set auditDesc = "Create Related Type: "_addRTRTS
	d ..AuditChanges("saveAddRelated", auditDesc,oRT.PrincipalType.%Id(), oRT.%Id())

 	Quit %session.Data("sPTID")
}

ClassMethod saveNewRef(newPTName As %String, newPTS As %String, newPTPR As %String, newRTRTS As %String) As %String [ Language = objectscript ]
{
	//Check to see of PT is truly new
	set PTExists = 0
 	&sql(select CASE WHEN ID <> '' THEN 1 ELSE 0 END into :PTExists from IIBAENSEMBLE_Reference.PrincipalType WHERE Name = :newPTName)
 	if PTExists {
	 	&js<alert('The Reference Name #(newPTName)# already exists.');>
	 	Quit "Not Saved"
 	}
 	
 	//Create the PT
 	set oPT=##class(IIBAENSEMBLE.Reference.PrincipalType).%New()
 	set oPT.Name = newPTName
 	set oPT.System = newPTS
 	set oPT.PrincipalRole = newPTPR
 	set tSC = oPT.%Save()
 	
 	//Create the RT using the PT
 	set oRT = ##class(IIBAENSEMBLE.Reference.RelatedType).%New()
 	set oRT.System = newRTRTS
 	set oRT.PrincipalType = oPT
 	set tSC = oRT.%Save()
 	
 	set auditDesc = "PricipalType: "_newPTName_" RelatedType: "_newRTRTS
	d ..AuditChanges("saveNewRef", auditDesc,oPT.%Id(), oRT.%Id())

 		
	Quit oPT.%Id()
}

ClassMethod ValidateHeader(FileHeader As %String) As %String [ Language = objectscript ]
{
 
 
 set lHeader = $LB("PTName","PTSystem","PTRole","PValue","RTSystem","RValue")
 
 set lCSV = ##class(IIBAENSEMBLE.Functions).ParseCSV(FileHeader)
 
 Set ReturnVal=1
 
 for i=1:1:$LL(lHeader) { 
 	if ($LL(lCSV)'=$LL(lHeader))||($LI(lCSV,i)'=$LI(lHeader,i)){
 		Set ReturnVal=0
 	}
 }
 
 
 Quit ReturnVal
}

ClassMethod initImportData(SessionId As %String) [ Language = objectscript ]
{
	kill ^CacheTempaImport(SessionId)
	kill ^CacheTempaPTAttr(SessionId)
	kill ^CacheTempaRTAttr(SessionId)
	kill ^CacheTempImportErrors(SessionId)
	kill ^CacheTempImportStatus(SessionId)
}

ClassMethod collectImportData(line As %String, SessionId As %String) As %String [ Language = objectscript ]
{
	set lCSV = ##class(IIBAENSEMBLE.Functions).ParseCSV(line)
 
	set sPTName=$LI(lCSV,1)
	set sPTSystem = $LI(lCSV,2)
	set sPTPrincipalRole = $LI(lCSV,3)
	set sPV = $LI(lCSV,4)
	set sRTSystem = $LI(lCSV,5)
	set sRV = $LI(lCSV,6)

	set ^CacheTempaImport(SessionId,sPTName,sPV,sRTSystem,sRV)=""
	set ^CacheTempaPTAttr(SessionId,sPTName,"System")=sPTSystem
	set ^CacheTempaPTAttr(SessionId,sPTName,"PrincipalRole")=sPTPrincipalRole
	set ^CacheTempaRTAttr(SessionId,sRTSystem) = ""
}

ClassMethod removeExisting(SessionId As %String) [ Language = objectscript ]
{
	set sPTName=""
	For  { Set sPTName=$O(^CacheTempaImport(SessionId,sPTName)) Q:sPTName=""
		set sRTSystem=""
		For  { Set sRTSystem=$O(^CacheTempaRTAttr(SessionId,sRTSystem)) Q:sRTSystem=""
			s RTId="",PTId=""
			&sql(SELECT ID INTO :RTId
				FROM IIBAENSEMBLE_Reference.RelatedType 
				WHERE System = :sRTSystem AND PrincipalType->Name = :sPTName)
			if SQLCODE = 0 d ..removeRVsforRT(RTId)
		}				
	}
}

ClassMethod removeRVsforRT(RTId As %Integer) [ Language = objectscript ]
{
	set oRT = ##class(IIBAENSEMBLE.Reference.RelatedType).%OpenId(RTId)
	set oPT = oRT.PrincipalType
	
	set rs = ##class(%ResultSet).%New()
	set SQL = "select ID, PrincipalValue as PVID "
	set SQL=SQL_"from IIBAENSEMBLE_Reference.RelatedValue "
	set SQL=SQL_"WHERE RelatedType = "_RTId_" AND PrincipalValue->PrincipalType = "_oPT.%Id()_" "
	
	set auditDesc = "Remove for PrincipalType: "_oPT.Name _" RelatedType: "_oRT.System
	d ..AuditChanges("removeRVsforRT", auditDesc,oPT.%Id(), oRT.%Id())
	
	do rs.Prepare(SQL)
	do rs.Execute()	
	While rs.Next() {
		set oRV = ##class(IIBAENSEMBLE.Reference.RelatedValue).%OpenId(rs.Data("ID"))
		set oPV = ##class(IIBAENSEMBLE.Reference.PrincipalValue).%OpenId(rs.Data("PVID"))
		d oPV.RelatedValues.UnRelate(oRV)
		d oRT.RelatedValues.UnRelate(oRV)
		set RVID = rs.Data("ID")
		kill oRV
		&sql(DELETE FROM IIBAENSEMBLE_Reference.RelatedValue WHERE ID = :RVID)
		if oPV.RelatedValues.Count() = 0 {
			d oPT.PrincipalValues.UnRelate(oPV)
			set PVID = rs.Data("PVID")
			kill oPV
			&sql(DELETE FROM IIBAENSEMBLE_Reference.PrincipalValue WHERE ID = :PVID)
		}
	}
	do rs.Close()
}

ClassMethod removeRT(RTId As %Integer) [ Language = objectscript ]
{
	d ..removeRVsforRT(RTId)
	set oRT = ##class(IIBAENSEMBLE.Reference.RelatedType).%OpenId(RTId)
	set oPT = oRT.PrincipalType
	d oPT.RelatedTypes.UnRelate(oRT)
	set auditDescription="Remove RVs for: "_RTId
	do ..AuditChanges("removeRT",auditDescription,oPT.%Id(),RTId)
	kill oRT
	&sql(DELETE FROM IIBAENSEMBLE_Reference.RelatedType WHERE ID = :RTId)
}

ClassMethod removeRelated(sPTId As %String, RTSystems As %String) As %String
{
	set lRTSystems = $LFS(RTSystems)
	for i=1:1:$LL(lRTSystems)-1 {
		d ..removeRT($LI(lRTSystems,i))
	}
	s oPT = ##class(IIBAENSEMBLE.Reference.PrincipalType).%OpenId(sPTId)
	set auditDescription="Remove Related Systems: "_RTSystems_" PTId: "_sPTId
	do ..AuditChanges("removeRelated",auditDescription,sPTId)
	if oPT.RelatedTypes.Count() = 0 {
		kill oPT
		&sql(DELETE FROM IIBAENSEMBLE_Reference.PrincipalType WHERE ID = :sPTId)
		Quit ""
	} else { 
		Quit sPTId
	}
}

ClassMethod importData(importstream As %GlobalCharacterStream, importType As %String, SessionId As %String = "") As %String [ Language = objectscript ]
{
 	if SessionId = "" { set SessionId = %session.SessionId }
 	set result="{"
 	
 	if '..ValidateHeader(importstream.ReadLine()) {
		set result=result_"validated: false"
		set result=result_"}"
		Quit result
	} else {
		set result=result_"validated: true,"
	}
	
	
	s EnsSysDir = ##class(%File).ParentDirectoryName(##class(%File).ManagerDirectory())
	s filetimestamp = ##class(Ens.Util.Time).FormatDateTime("%Y%m%d%H%M%S")
	
	s xRefImportDir = ##class(%File).NormalizeDirectory(EnsSysDir_"xRefImports\new\")
	if '##class(%File).DirectoryExists(xRefImportDir) { 
		d ##class(%File).CreateDirectoryChain(xRefImportDir) 
	}
	
	s file = ##class(%File).%New(xRefImportDir_importType_"_"_%session.SessionId_"_"_filetimestamp_".csv")
	d file.Open("WSN")
	
	set count = 0
	
	while 'importstream.AtEnd { 
		d file.WriteLine(importstream.ReadLine()) 
		set count = count+1
	}
	
	d file.Close()
	
	do ..AuditChanges("importData","Import file name: "_xRefImportDir_importType_"_"_%session.SessionId_"_"_filetimestamp_".csv")
	
	set result=result_"EnsSysDir: "_..QuoteJS(EnsSysDir)_","
	set result=result_"filetimestamp: """_filetimestamp_""","
	set result=result_"count: "_count_","
	set result=result_"SessionId: """_SessionId_""""
	set result=result_"}"
	
	Quit result
}

ClassMethod getPTobj(sPTName As %String, sPTRole As %String, sPTSystem As %String, ByRef tSC As %Status = 1) As IIBAENSEMBLE.Reference.PrincipalType
{
	set sPTID=""
	&sql(select ID into :sPTID from IIBAENSEMBLE_Reference.PrincipalType where Name = :sPTName)
	if SQLCODE '= 0 s sPTID = ""
	if sPTID'="" {
		set oPT = ##class(IIBAENSEMBLE.Reference.PrincipalType).%OpenId(sPTID)
	} else {
		set oPT = ##class(IIBAENSEMBLE.Reference.PrincipalType).%New()
		set oPT.Name=sPTName
		set oPT.System=sPTSystem
		set oPT.PrincipalRole=$ZCVT(sPTRole,"L")
		set tSC = oPT.%Save()
		//if 'tSC { set ^CacheTempImportErrors(%session.SessionId,"PT",sPTName)=$System.OBJ.DisplayError(tSC) }
		set sPTID=oPT.%Id()
	}
	Quit oPT
}

ClassMethod getPVobj(sPV As %String, sPTID As %String, ByRef tSC As %Status = 1) As IIBAENSEMBLE.Reference.PrincipalValue
{
	set sPVID=""
	
	&sql(select ID into :sPVID from IIBAENSEMBLE_Reference.PrincipalValue where PValue = :sPV AND PrincipalType = :sPTID)
	if SQLCODE '= 0 s sPVID = ""
	
	if sPVID'=""{
		set oPV = ##class(IIBAENSEMBLE.Reference.PrincipalValue).%OpenId(sPVID)
	} else {
		set oPV = ##class(IIBAENSEMBLE.Reference.PrincipalValue).%New()
		set oPV.PValue=sPV
		set oPV.PrincipalType=##class(IIBAENSEMBLE.Reference.PrincipalType).%OpenId(sPTID)
		set tSC = oPV.%Save()
		//if 'tSC { set ^CacheTempImportErrors(%session.SessionId,"PV",sPV)=$System.OBJ.DisplayError(tSC) }
		set sPVID=oPV.%Id()
	}
	Quit oPV
}

ClassMethod getRTobj(sRTSystem As %String, sPTID As %String, ByRef tSC As %Status = 1) As IIBAENSEMBLE.Reference.RelatedType
{
	set sRTID=""
	&sql(select ID into :sRTID from IIBAENSEMBLE_Reference.RelatedType where System = :sRTSystem AND PrincipalType = :sPTID)
	if SQLCODE '= 0 s sRTID = ""
	if sRTID'="" {
		set oRT = ##class(IIBAENSEMBLE.Reference.RelatedType).%OpenId(sRTID)
	} else {
		set oRT = ##class(IIBAENSEMBLE.Reference.RelatedType).%New()
		set oRT.System=sRTSystem
		set oRT.PrincipalType=##class(IIBAENSEMBLE.Reference.PrincipalType).%OpenId(sPTID)
		set tSC = oRT.%Save()
		//if 'tSC { set ^CacheTempImportErrors(%session.SessionId,"RT",sRTSystem)=$System.OBJ.DisplayError(tSC) }
		set sRTID=oRT.%Id()
	}
	Quit oRT
}

ClassMethod getRVID(sRV As %String, sPVID As %String, sRTID As %String) As %String
{
	set sRVID=""
	&sql(select ID into :sRVID from IIBAENSEMBLE_Reference.RelatedValue where RValue = :sRV AND PrincipalValue = :sPVID AND RelatedType = :sRTID)
	if SQLCODE '= 0 s sRVID = ""
	
	Quit sRVID
}

ClassMethod doRVUpSert(oPT As IIBAENSEMBLE.Reference.PrincipalType, oRT As IIBAENSEMBLE.Reference.RelatedType, oPV As IIBAENSEMBLE.Reference.PrincipalValue, sRV As %String, ByRef tSC As %Status = 1) As %Status
{
	set sPTID = oPT.%Id()
	set sRTID = oRT.%Id()
	set sPVID = oPV.%Id()
	set sRVID = ""
	
	set AuditRVIDprev = ""
	set AuditRValueprev = ""
	set AuditRVIDnew = ""
	set AuditRValuenew = ""
	set AuditPVIDprev = ""
	
	set RVExists = ..checkRValueExists(sRV,sPTID,sRTID)
	set RVAlreadyMapped = 0 //This remains zero for Principal Role "target" because multiple RVs are allowed to be mapped to a target PV
	if oPT.PrincipalRole="source" {
		//this count reveals whether any other related value is already mapped to this principal value
		&sql(select COUNT(ID) as RVCount into :RVAlreadyMapped from IIBAENSEMBLE_Reference.RelatedValue WHERE PrincipalValue = :sPVID and RelatedType = :sRTID)
		
	}
	
	if RVAlreadyMapped>0 {
		//first, drop the existing mapped Related Value where the PT Role is source and a different RV is already mapped to this PV
		&sql(select ID into :sRVID from IIBAENSEMBLE_Reference.RelatedValue where PrincipalValue = :sPVID and RelatedType = :sRTID)
		if SQLCODE '= 0 s sRVID = "" 
		set oRV = ##class(IIBAENSEMBLE.Reference.RelatedValue).%OpenId(sRVID)
		set AuditRVIDprev = sRVID
		set AuditRValueprev = oRV.RValue
		d oPV.RelatedValues.UnRelate(oRV)
		d oRT.RelatedValues.UnRelate(oRV)
		kill oRV
		&sql(DELETE FROM IIBAENSEMBLE_Reference.RelatedValue WHERE ID = :sRVID)
		set sRVID = ""
	}
	
	if RVExists && (oPT.PrincipalRole="target") {
		&sql(select ID into :sRVID from IIBAENSEMBLE_Reference.RelatedValue where RValue = :sRV AND PrincipalValue->PrincipalType = :sPTID AND RelatedType = :sRTID)
		if SQLCODE '= 0 s sRVID = ""
		set oRV = ##class(IIBAENSEMBLE.Reference.RelatedValue).%OpenId(sRVID)
		set AuditRVIDprev = sRVID
		set AuditRValueprev = oRV.RValue
		set tPVID = oRV.PrincipalValue.%Id()
		set AuditPVIDprev = tPVID
		set oRV.PrincipalValue=oPV
		set tSC = oRV.%Save()
		//if 'tSC { set ^CacheTempImportErrors(%session.SessionId,"RV",sRV)=$System.OBJ.DisplayError(tSC) }
		set tPV = ##class(IIBAENSEMBLE.Reference.PrincipalValue).%OpenId(tPVID)
		if tPV.RelatedValues.Count() = 0 {
			d oPT.PrincipalValues.UnRelate(tPV)
			kill tPV
			&sql(DELETE FROM IIBAENSEMBLE_Reference.PrincipalValue WHERE ID = :tPVID)
		}
	} else {
		set oRV = ##class(IIBAENSEMBLE.Reference.RelatedValue).%New()
		set oRV.RValue=sRV
		set oRV.PrincipalValue=oPV
		set oRV.RelatedType=oRT
		set tSC = oRV.%Save()
		//if 'tSC { set ^CacheTempImportErrors(%session.SessionId,"RV",sRV)=$System.OBJ.DisplayError(tSC) }
		set sRVID=oRV.%Id()
	}
	set AuditRVIDnew = sRVID
	set AuditRValuenew = oRV.RValue
	
	//Audit the following details:
	//sPTID, sRTID, sPVID, AuditPVIDprev, AuditRVIDprev, AuditRValueprev, AuditRVIDnew, AuditRValuenew
	set auditDescription = ""
	if AuditPVIDprev '= "" set auditDescription = auditDescription_" previous PVID: "_AuditPVIDprev_","
	if AuditRVIDprev '= "" set auditDescription = auditDescription_" previous RVID: "_AuditRVIDprev_", previous RValue: "_AuditRValueprev_","
	set auditDescription = auditDescription_" new Rvalue:"_AuditRValuenew
	do ..AuditChanges("doRVUpSert",auditDescription,sPTID,sRTID,sPVID,sRVID)
	
	Quit tSC
}

ClassMethod testCall()
{
	//set result = ..importData()
	//d ..removeExisting()
	//&js<alert("#(result)#");>
}

ClassMethod AuditChanges(method As %String, Description As %String = "", PTId As %String = "", RTId As %String = "", PVId As %String = "", RVId As %String = "")
{
	set sPTName = ""
	set sRTSystem = ""
	set PValue = ""
	set RValue = ""
	set:PTId'="" sPTName = ##class(IIBAENSEMBLE.Reference.PrincipalType).%OpenId(PTId).Name
	if RTId '= "" set sRTSystem = ##class(IIBAENSEMBLE.Reference.RelatedType).%OpenId(RTId).System
	if PVId '= "" set PValue = ##class(IIBAENSEMBLE.Reference.PrincipalValue).%OpenId(PVId).PValue
	if RVId '= "" set RValue = ##class(IIBAENSEMBLE.Reference.RelatedValue).%OpenId(RVId).RValue	
	if $L(Description)>128
		set Description = $E(Description,1,128)
	set Source = "IIBAENSEMBLE.csp.Reference"
	set Type = "xRef"
	set Name = "Edit"
	set EventData = "{""method"":"""_method_""",""PTName"":"""_sPTName_""",""PTId"":"""_PTId_""",""RTSystem"":"""_sRTSystem_""",""RTId"":"""_RTId_""",""PValue"":"""_PValue_""",""PVId"":"""_PVId_""",""RValue"":"""_RValue_""",""RVId"":"""_RVId_"""}"
	d $SYSTEM.Security.Audit(Source,Type,Name,EventData,Description)
}

ClassMethod getImportStatus(SessionId As %String) As %String
{
	set result = ""
	
	if $D(^CacheTempImportStatus(SessionId,"rvcount"))'=0{
		set result="{"
		set result=result_"totalcount: "_^CacheTempImportStatus(SessionId,"totalcount")_","
		set result=result_"rvcount: "_^CacheTempImportStatus(SessionId,"rvcount")_","
		set result=result_"status: """_^CacheTempImportStatus(SessionId,"status")_""""
		set result=result_"}"
	}
	
	Quit result
}

ClassMethod exportData(sPTID As %String, RTSystems As %String) As %String
{
	set lRTSystems = $LFS(RTSystems)
	
	s EnsSysDir = ##class(%File).ParentDirectoryName(##class(%File).ManagerDirectory())
	s filetimestamp = ##class(Ens.Util.Time).FormatDateTime("%Y%m%d%H%M%S")
	s xRefExportsDir = ##class(%File).NormalizeDirectory(EnsSysDir_"xRefExports")
	
	if '##class(%File).DirectoryExists(xRefExportsDir) { 
		d ##class(%File).CreateDirectoryChain(xRefExportsDir) 
	}
		
	s file = ##class(%File).%New(xRefExportsDir_%session.SessionId_".csv")
	d file.Open("WSN")
	d file.WriteLine("PTName,PTSystem,PTRole,PValue,RTSystem,RValue")
	
	
	
	for i=1:1:$LL(lRTSystems)-1 {
		set SQL = "select PrincipalValue->PrincipalType->Name, "
		set SQL=SQL_"PrincipalValue->PrincipalType->System as PTSystem, "
		set SQL=SQL_"PrincipalValue->PrincipalType->PrincipalRole, "
		set SQL=SQL_"PrincipalValue->PValue, "
		set SQL=SQL_"RelatedType->System as RTSystem, "
		set SQL=SQL_"RValue "
		set SQL=SQL_"from IIBAENSEMBLE_Reference.RelatedValue "
		set SQL=SQL_"WHERE PrincipalValue->PrincipalType = "_sPTID_" AND RelatedType->System = '"_$LI(lRTSystems,i)_"'"
		
		s ^CacheTempSQL = SQL
 		
 		set rs = ##class(%ResultSet).%New()
 		do rs.Prepare(SQL)
 		do rs.Execute()
 		While rs.Next() {
 			
 			set strLine = ""
 			set strLine=strLine_$C(34)_##class(IIBAENSEMBLE.Functions).StringReplace(rs.Data("Name"),$C(34),$C(34,34))_$C(34)_","
 			set strLine=strLine_$C(34)_##class(IIBAENSEMBLE.Functions).StringReplace(rs.Data("PTSystem"),$C(34),$C(34,34))_$C(34)_","
 			set strLine=strLine_$C(34)_##class(IIBAENSEMBLE.Functions).StringReplace(rs.Data("PrincipalRole"),$C(34),$C(34,34))_$C(34)_","
 			set strLine=strLine_$C(34)_##class(IIBAENSEMBLE.Functions).StringReplace(rs.Data("PValue"),$C(34),$C(34,34))_$C(34)_","
 			set strLine=strLine_$C(34)_##class(IIBAENSEMBLE.Functions).StringReplace(rs.Data("RTSystem"),$C(34),$C(34,34))_$C(34)_","
 			set strLine=strLine_$C(34)_##class(IIBAENSEMBLE.Functions).StringReplace(rs.Data("RValue"),$C(34),$C(34,34))_$C(34)
 			
 			d file.WriteLine(strLine) 
 			
 		}
 		do rs.Close()	
	}
	d file.Close()
	kill file
 	Quit %session.SessionId_".csv"
}

ClassMethod exportxRefAttrData(sRTID As %String) As %String
{
	
	s EnsSysDir = ##class(%File).ParentDirectoryName(##class(%File).ManagerDirectory())
	s filetimestamp = ##class(Ens.Util.Time).FormatDateTime("%Y%m%d%H%M%S")
	
	if '##class(%File).DirectoryExists(EnsSysDir_"xRefExports") { 
		d ##class(%File).CreateDirectory(EnsSysDir_"xRefExports") 
	}
		
	s file = ##class(%File).%New(EnsSysDir_"xRefExports\"_%session.SessionId_".csv")
	d file.Open("WSN")
	
	set oRT = ##class(IIBAENSEMBLE.Reference.RelatedType).%OpenId(sRTID)
	
	set attrString = oRT.getAttrList()
		
	d file.WriteLine("PTName,RTSystem,PValue,RValue,"_attrString)
	
	//Create list from Class Name
	set MCL = $LFS(oRT.attrClass,".")
	//Create a new sublist of all parts of the name except the last part
	set MCLt = $LI(MCL,1,$LL(MCL)-1)
	//Join the parts of that name back into a string delimited by _ except the last part
	set sClassTable = $LTS(MCLt,"_")
	//Add the last part in, but delimited by . 
	set sClassTable = sClassTable_"."_$LI(MCL,$LL(MCL))

	set SQL=""
	set SQL=SQL_"Select PrincipalValue->PrincipalType->Name, RelatedType->System, PrincipalValue->PValue, RValue"_attrString_" from IIBAENSEMBLE_Reference.RelatedValue "
	set SQL=SQL_"LEFT OUTER JOIN "_sClassTable_" "
	set SQL=SQL_"ON attrId = "_$LI(MCL,$LL(MCL))_".id "
	set SQL=SQL_"WHERE RelatedType = "_sRTID_" "
	set SQL=SQL_"ORDER BY PrincipalValue->PValue"
	
		
	set rs = ##class(%ResultSet).%New()
	do rs.Prepare(SQL)
	do rs.Execute()
	set rsCount = rs.GetColumnCount()
	While rs.Next() {
		set strLine = ""
		for i=1:1:rsCount {
			set strLine=strLine_$C(34)_##class(IIBAENSEMBLE.Functions).StringReplace(rs.Data(arrColNames(i)),$C(34),$C(34,34))_$C(34)_","
		}	
		d file.WriteLine(strLine) 
		
	}
	do rs.Close()
	
	d file.Close()
	kill file
 	Quit %session.SessionId_".csv"
}

ClassMethod attrClassExists(sRTID As %String) As %String
{
	set oRT = ##class(IIBAENSEMBLE.Reference.RelatedType).%OpenId(sRTID)
	
	set attrClassExists = "", attrClass = oRT.attrClass
 	&sql(select ID into :attrClassExists from %Dictionary.ClassDefinition WHERE ID = :attrClass)
 	if SQLCODE '= 0 { s attrClassExists = 0 } else { s attrClassExists = 1 }
 	Quit attrClassExists
}

ClassMethod attrDataArray(sRTID As %String)
{
}

ClassMethod attrEditGrid(sRTID As %String)
{
	&js< attrData = []; >
	
	if '..attrClassExists(sRTID) {
		&js<alert('No Attribute Class exists for this System in this NameSpace.');>
		Quit
	}
	
	set oRT = ##class(IIBAENSEMBLE.Reference.RelatedType).%OpenId(sRTID)
		
	set rs = oRT.getAttrData()
	set rsCount = rs.GetColumnCount()
	for i=1:1:rsCount {
		set arrColNames(i)=rs.GetColumnName(i)
	}
	
	While rs.Next() {
			s arrAttr="["_rs.Data("ID")
			s arrAttr=arrAttr_",'"_rs.Data(oRT.PrincipalType.System)_"'"
			s arrAttr=arrAttr_",'"_rs.Data(oRT.System)_"'"
			for i=4:1:rsCount {
				s arrAttr=arrAttr_",'"_rs.Data(arrColNames(i))_"'"
			}
			s arrAttr=arrAttr_"]"
			//w arrAttr,!
			&js< attrData.push(#(arrAttr)#); >
	}
	
	/*
	//I think the following code was used to put the data in $Order rather than SQL order for consistency with the main grid 
	//I have replaced this with a SQL order, but could move this logic to the related type class if necessary
	While rs.Next() {
		
		set arrRS(rs.Data(oRT.PrincipalType.System)) = ""
		set arrRS(rs.Data(oRT.PrincipalType.System),rs.Data(oRT.System)) = rs.Data("ID")
				
		for i=4:1:rsCount {
			set arrRS(rs.Data(oRT.PrincipalType.System),rs.Data(oRT.System),arrColNames(i)) = rs.Data(arrColNames(i))
		}	

		
	}
	set PValue=""
	for  { Set PValue=$O(arrRS(PValue)) Q:PValue=""	
		set RValue=""
		for  { Set RValue=$O(arrRS(PValue,RValue)) Q:RValue=""	
			s arrAttr="["_arrRS(PValue,RValue)
			s arrAttr=arrAttr_",'"_PValue_"'"
			s arrAttr=arrAttr_",'"_RValue_"'"
			for i=4:1:rsCount {
				s arrAttr=arrAttr_",'"_arrRS(PValue,RValue,arrColNames(i))_"'"
			}
			s arrAttr=arrAttr_"]"
			//w arrAttr,!
			&js< attrData.push(#(arrAttr)#); >
		}		
	}
	
	*/
	set sFields = "[{name: 'id'}"
	for i=2:1:rsCount {
		set sFields=sFields_",{name: '"_arrColNames(i)_"'}"
	}
	set sFields=sFields_"]"
	
	s sColumns=""
	if %session.Data("sPTPrincipalRole") = "target" {
		set sColumns=sColumns_"[{id: 'id',header: '"_oRT.System_"', width: 100, dataIndex: '"_oRT.System_"', sortable: true}"
		set sColumns=sColumns_",{header: '"_oRT.PrincipalType.System_"', width: 100, dataIndex: '"_oRT.PrincipalType.System_"', sortable: true}"
	}
	if %session.Data("sPTPrincipalRole") = "source" {
		set sColumns=sColumns_"[{header: '"_oRT.PrincipalType.System_"', width: 100, dataIndex: '"_oRT.PrincipalType.System_"', sortable: true}"
		set sColumns=sColumns_",{id: 'id',header: '"_oRT.System_"', width: 100, dataIndex: '"_oRT.System_"', sortable: true}"
	}
	
	for i=4:1:rsCount {
		set sColumns=sColumns_",{header: '"_arrColNames(i)_"', width: 100, dataIndex: '"_arrColNames(i)_"', editor: new fm.TextField({selectOnFocus: true}), sortable: true}"
	}
	set sColumns=sColumns_"]"
	
	set sFilters="[{type: 'string',  dataIndex: '"_oRT.PrincipalType.System_"'}"
	set sFilters=sFilters_",{type: 'string',  dataIndex: '"_oRT.System_"'}"
	for i=4:1:rsCount {
		set sFilters=sFilters_",{type: 'string',  dataIndex: '"_arrColNames(i)_"'}"
	}
	set sFilters=sFilters_"]"
	
	
	&js<
	
	function callxRefExport() {
		exportxRefAttrData(#(sRTID)#);
	}
	function callxRefImport() {
		attrImport(#(sRTID)#);
	}
	
	var myReader = new Ext.data.ArrayReader({
		id: 0
		}, #(sFields)#);
	
	attrStore = new Ext.data.Store({
		reader: myReader,
		remoteSort: false
		//,
		//sortInfo: {field: 'RValue', direction: 'ASC'}
	});
	
	attrStore.loadData(attrData);
	Ext.grid.filter.StringFilter.prototype.icon = 'ext/examples/grid-filtering/img/find.png';
	
	//attrFilters = "({ local: true , filters: #(sFilters)# });	"
	
	attrFilters = new Ext.grid.GridFilters({
		local: true ,
	    filters: #(sFilters)#
	  });

	attrGridPanel = new Ext.grid.EditorGridPanel({
		store: attrStore,
	    columns: #(sColumns)#,
	    title:'#(%session.Data("sPTName"))#<br>#(oRT.System)# Attributes',
	    clicksToEdit:1,
	    tbar: [{
	    	text: 'Save',
	    	iconCls:'ico_save',
	    	handler : attrSave
	    },{
		    text: 'Export',
		    iconCls:'ico_export',
		    handler: callxRefExport
		},{
		    text: 'Import',
		    iconCls:'ico_import',
		    handler: callxRefImport
		}],
		plugins: attrFilters
	});
	


	
	$('attrGrid').innerHTML='';
	attrWin = new Ext.Window({
		el: 'attrGrid',
		layout: 'fit',
		width: #(((rsCount-1)*100)+37)#,
		height:400,
		closeAction:'hide',
		plain: true,
		draggable: false,
		modal: true,
		items: attrGridPanel
		});
	attrWin.on('beforehide', attrBeforeClose);
	attrWin.show('RT^#(sRTID)#');
	attrGridPanel.getColumnModel().on('hiddenchange', function (cm,i,hidden){ if (hidden) {attrGridPanel.getTopToolbar().items.items[4].show();}});
	attrStore.on('update',attrUpdate);
	
	attrGridPanel.getTopToolbar().addFill();
	
	attrGridPanel.getTopToolbar().addButton({ 
		text: 'Show', 
		iconCls: 'ico_col', 
		hidden: true,
		handler: attrShowColumns 
	});
	
	
	>
}

ClassMethod AttrDataReload(sRTID As %String)
{
	&js< attrData = []; >
	
	if '..attrClassExists(sRTID) {
		&js<alert('No Attribute Class exists for this System in this NameSpace.');>
		Quit
	}
	
	set oRT = ##class(IIBAENSEMBLE.Reference.RelatedType).%OpenId(sRTID)
		
	set rs = oRT.getAttrData()
	set rsCount = rs.GetColumnCount()
	for i=1:1:rsCount {
		set arrColNames(i)=rs.GetColumnName(i)
	}
	
	While rs.Next() {
			s arrAttr="["_rs.Data("ID")
			s arrAttr=arrAttr_",'"_rs.Data(oRT.PrincipalType.System)_"'"
			s arrAttr=arrAttr_",'"_rs.Data(oRT.System)_"'"
			for i=4:1:rsCount {
				s arrAttr=arrAttr_",'"_rs.Data(arrColNames(i))_"'"
			}
			s arrAttr=arrAttr_"]"
			//w arrAttr,!
			&js< attrData.push(#(arrAttr)#); >
	}
	&js< attrStore.loadData(attrData); >
}

ClassMethod attrImport(sRTID As %String)
{
	&js<
	
	function callAttrDataReload() {
		AttrDataReload(#(sRTID)#);
	}

    function ImportSuccess(simpleImport,o) {
	    attrImportWin.hide();
	    // attrWin.hide();
	    callAttrDataReload();
	    msg('Success',o.result.resultstring);	    
    }    
    
    function ImportFailure(simpleImport,o) {
	    msg('Failure',o.result.resultstring);
	    //console.log(simpleImport)
	    //console.log(o)
    }
    function ImportSubmit(){
	    simpleImport.getForm().submit({url: 'IIBAENSEMBLE.csp.FileUpload.cls?Class=IIBAENSEMBLE.Reference.RelatedValue&Method=attrImport&MethodParams=#(sRTID)#',waitMsg: 'Uploading...', success: ImportSuccess, failure: ImportFailure})
    }
    simpleImport = new Ext.FormPanel({
        labelWidth: 75, // label settings here cascade unless overridden
        fileUpload: true,
        frame:true,
        title: 'Import Attributes',
        bodyStyle:'padding:5px 5px 0',
        width: 400,
        defaults: {width: 230},
        defaultType: 'label',

        items: [{html:'The import file must be a csv file and must have a header row with the following columns.<br><br><b>PTName,RTSystem,PValue,RValue,#(##class(IIBAENSEMBLE.Reference.RelatedType).%OpenId(sRTID).getAttrList())#</b><br><br>'
        	},new Ext.form.FileUploadField({
                fieldLabel: 'File Name',
                name: 'uploadfilename'
            })
        ],

        buttons: [{
            text: 'Import',
            handler: ImportSubmit
        }]
    });

$('attrImportForm').innerHTML='';
	attrImportWin = new Ext.Window({
		el: 'attrImportForm',
		layout: 'fit',
		width: 400,
		height:200,
		closeAction:'hide',
		plain: true,
		draggable: false,
		modal: true,
		items: simpleImport
		});
attrImportWin.show('RT^#(sRTID)#');
	
	
	>
}

ClassMethod attrUpSert(sRVID As %String, attrJSON As %String)
{
	set oRV = ##class(IIBAENSEMBLE.Reference.RelatedValue).%OpenId(sRVID)
	d oRV.attrUpSertJSON(attrJSON)
}

ClassMethod clearSRS()
{
	if $G(%session.Data("SRSId"))'="" {
		set SRS = ##class(%ScrollableResultSet).%OpenId(%session.Data("SRSId"))
		If $ISOBJECT(SRS) d SRS.Close()
	}
	set %session.Data("SRSId") = ""
}

ClassMethod gridXRef(sPTId As %String)
{
	set %session.Data("sPTID") = sPTId
	
	// Clear any existing SRS prior to loading new table
	d ..clearSRS()
	
	// Get a de-normalized scrollable result set of the xRef data
	set oPT = ##class(IIBAENSEMBLE.Reference.PrincipalType).%OpenId(sPTId)
	
	//The following variables will be supplied with the necessary information to configure the Ext components
	s sFields = ""
	s sFilters = ""
	s sColumns = ""
		
	set countColumns = oPT.GetColumnCount()
	
	//Populate the sFields variable with the actual column names from the SRS
	//The display names will be specified in the sColumns variable
	s sFields = "[{name: 'id'}"
	s sFields=sFields_",{name: 'PValue'}"
	for i=3:1:countColumns {
		s sFields=sFields_",{name: '"_oPT.GetColumnName(i)_"'}"
	}		
	set sFields=sFields_"]"
	
	//Populate the sColumns variable with the column definitions with friendly names.
	//The PValue column goes first when PT is source, last when target
	set sColumns=sColumns_"["
	if oPT.PrincipalRole = "source" {
		set sColumns=sColumns_"{id: 'id',header: '"_oPT.System_"', width: 155, dataIndex: 'PValue', editor: new fm.TextField({selectOnFocus: true, allowBlank: false}), sortable: false},"
	}
	
	for i=3:1:countColumns {
		set RTSystem = ##class(IIBAENSEMBLE.Reference.RelatedType).%OpenId($P(oPT.GetColumnName(i),"_",2)).System
		set sColumns=sColumns_"{header: '"_RTSystem_"', width: 155, dataIndex: '"_oPT.GetColumnName(i)_"', editor: new EditRValueField, renderer: renderValue, sortable: false},"
	}
		
	if oPT.PrincipalRole = "target" {
		set sColumns=sColumns_"{id: 'id',header: '"_oPT.System_"', width: 155, dataIndex: 'PValue', editor: new fm.TextField({selectOnFocus: true, allowBlank: false}), sortable: false}"
	}
	if $E(sColumns,$L(sColumns))="," set sColumns = $E(sColumns,1,$L(sColumns)-1)
	set sColumns=sColumns_"]"
	
	//Populate the sFilters variable with the actual column names from the SRS
	set sFilters="[{type: 'string',  dataIndex: 'PValue'}"
	for i=3:1:countColumns {
		set sFilters=sFilters_",{type: 'string',  dataIndex: '"_oPT.GetColumnName(i)_"'}"
	}
	set sFilters=sFilters_"]"
	
	&js<
	
	function renderValue(v,m) {
		//console.log(v);
		//console.log(m);
		if (v.length == 1)
		{
			return v[0].split('|')[1];
		} else {
			return '...';
		}
	}
	function fieldShow(field) {
		if (field.value) {
			console.log(field)
			console.log(field.value);
			console.log(field.getRawValue());
			field.setValue(field.value[0].split('|')[1])
		}
	}
	var EditRValueField = function(config) {
    	// Call the superclass to preserve baseclass functionality
	    EditRValueField.superclass.constructor.call(this, Ext.apply({
    	    //Reusable config options here
        	selectOnFocus: true,
        	listeners: {'beforeshow' : {fn: fieldShow, scope: this}}
	    }, config));
 
    	// After superclass constructor add functionality that requires
	    // the object to exist (like event handling...listeners)
    	//this.on('beforeshow', fieldrender, this);
	};
	// Here you can add static variables for the class. variables that will have 
    // the same value for all object instances of this class.
    // If you are not sure put it in the constructor above. Dont put any abject
    // created with 'new' or 'xtype' here. You are safer putting it in the config
    // option in the constructor.
	Ext.extend(EditRValueField, fm.TextField)

	
	$('xRefGrid').innerHTML='';
	
	var xRefStore = new Ext.data.JsonStore({
		url:'IIBAENSEMBLE.csp.RefData.cls',
	    id: 'id',
	    totalProperty: 'total',
	    root: 'data',
	    fields: #(sFields)#
	});
	
	Ext.grid.filter.StringFilter.prototype.icon = 'ext/examples/grid-filtering/img/find.png';
	
	xRefFilters = new Ext.grid.GridFilters({
		filters: #(sFilters)#
	  });

	xRefGridPanel = new Ext.grid.EditorGridPanel({
		store: xRefStore,
	    columns: #(sColumns)#,
	    title:'#(oPT.Name)#',
	    clicksToEdit:1,
	    tbar: [{
	    	text: 'Save',
	    	iconCls:'ico_save',
	    	handler : attrSave
		}],
		plugins: xRefFilters,
		width: #(((countColumns-1)*155)+5)#,
		height:640,       
	    el: 'xRefGrid',
	    trackMouseOver: true,
	    bbar: new Ext.PagingToolbar({
		    store: xRefStore,
		    pageSize: 25,
		    plugins: xRefFilters
		})
	});
	xRefGridPanel.render();
	xRefStore.load({params:{start: 0, limit: 25}})

	
	
	>
}

}
