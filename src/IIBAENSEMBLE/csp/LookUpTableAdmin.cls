/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.csp.LookUpTableAdmin Extends %CSP.Page [ ProcedureBlock ]
{

ClassMethod CheckPermissions()
{
	set Allowed = 0
	// Req#1 - Phegel Changed to use the LookupTable resource so you don't need to have %All permissions to use.
	if ##class(%SYSTEM.Security).Check("LookUpTableAdmin","USE")
	{ 
	 	set Allowed = 1 
	}
	
	Quit Allowed
}

ClassMethod jsfunction()
{
  &html<
  <script type="text/javascript" src="modalbox/modalbox.js"></script>
  <script type="text/javascript" src="ext/adapter/ext/ext-base.js"></script>
  <script type="text/javascript" src="ext/ext-all.js"></script>
  <link rel="stylesheet" href="modalbox/modalbox.css" type="text/css" />
  <link rel="stylesheet" href="ext/resources/css/ext-all.css" />
	
   <script language=javascript>
	
	function Initialize()
	{

	}
		
	function SortTable(table,sortby1,sortby2) {
		//alert(sortby1);
		//alert(sortby2);
		//document.getElementById('tablediv').innerHTML='';
		
			
		var newtable = #server(..SortTable(table,sortby1,sortby2))#;
		document.getElementById('tablediv').innerHTML = newtable;
		
		if (newtable == '</TABLE>') {
			self.document.location="IIBASupport.csp?PageName=LookUp&Mode=Display&LookupTable="+table;
		}
		
		
			
	}

	
	function Display() {
		
		
		var LookupTable = document.getElementById('LookupTable').options[document.getElementById('LookupTable').selectedIndex].value;
		
		
		
		self.document.location="IIBASupport.csp?PageName=LookUp&Mode=Display&LookupTable="+LookupTable;
		
			
	}
	
	function InsertSave(table) {
		
		var leftid1 = '';
		var leftid2 = '';
		var leftid3 = '';
		var rightid = '';
		
		leftid1 = document.getElementById('InsLeftID1').value;
		leftid2 = document.getElementById('InsLeftID2').value;
		leftid3 = document.getElementById('InsLeftID3').value;
		rightid = document.getElementById('RightID').value;
		
		if ( (rightid == '') || (leftid1=='') ) {
			alert('LeftId1 and RightID are required...');
		
		} else {
		
			//alert('left id1 is >'+leftid1+'<');		
			var newRowId = #server(..InsertSaveAction(table,leftid1,leftid2,leftid3,rightid))#;
		
			if (newRowId=='exists'){
				alert('A translation for this combination of Left ID\'s already exist.');
			} else {
			
				// Add a row to the web page
				tableObj=document.getElementById('TableValues');
			
				row=tableObj.insertRow(3);
			
			
				tableObj.rows[3].id='Tablevalues.Id'+newRowId;
			
			
			
			
				row.insertCell(0);
				row.insertCell(1);
				row.insertCell(2);
				row.insertCell(3);
				row.insertCell(4);
				row.insertCell(5);
				
				row.cells[0].innerHTML=leftid1.replace(/ /g,'&nbsp;');
				if (leftid2 == '' ) {
					leftid2='&nbsp';
				} else {
					leftid2=leftid2.replace(/ /g,'&nbsp;');
				}
				row.cells[1].innerHTML=leftid2;
				if (leftid3 == '' ) {
					leftid3='&nbsp';
				} else {
					leftid3=leftid3.replace(/ /g,'&nbsp;');
				}
				row.cells[2].innerHTML=leftid3;
				if (rightid == '' ) {
					rightid='&nbsp';
				} else {
					rightid=rightid.replace(/ /g,'&nbsp;');
				}
				
				row.cells[3].innerHTML=rightid;
				row.cells[4].innerHTML='<a id="edit'+newRowId+'" value="Edit" onclick="rowEdit(\''+table+'\',\''+newRowId+'\');" ><img src=\'customimages/edit.gif\' alt=\'edit\' /></a>';
				row.cells[5].innerHTML='<a id="del'+newRowId+'" value="Delete" onclick=\'RemoveRow("'+table+'","'+newRowId+'");\' ><img src=\'customimages/trash_bold.gif\' alt=\'Delete\' /></a> ';
			
				document.getElementById('InsLeftID1').value=''
				document.getElementById('InsLeftID2').value=''
				document.getElementById('InsLeftID3').value=''
				document.getElementById('RightID').value=''
			}
		}
			
	}
	
	function EditSave(itemid,table) {
		
		var leftid1 = '';
		var leftid2 = '';
		var leftid3 = '';
		var rightid = '';
		
		leftid1 = document.getElementById('InsLeftID1').value;
		leftid2 = document.getElementById('InsLeftID2').value;
		leftid3 = document.getElementById('InsLeftID3').value;
		rightid = document.getElementById('RightID').value;
		
		//alert(table+itemid+leftid1+leftid2+leftid3+rightid);
		
		var editrow = #server(..EditSaveAction(table,itemid,leftid1,leftid2,leftid3,rightid))#;
		
		if (editrow=='exists'){
			alert('This translation appears to already exist.');
		}
		
	}
	// Req#4 - PHegel - delete table method.
	function Delete(table) {
		var delOK = confirm("Delete " + table + " Lookup Table? \n Click OK to delete.");
		if (delOK){
			var deleted = #server(..DeleteTable(table))#;	
			//alert(deleted);
			self.document.location="IIBASupport.csp?PageName=LookUp";
		}
		else {
			alert( table + " Lookup Table, not deleted.");
		}
		
	}
	
	function DefValueSave(table) {
		
		defvalue = document.getElementById('defaultvalue').value;
		
		var insertdefvalue = #server(..DefValueAction(table,defvalue))#;
		
		alert('Default Value Saved');
		
		
		
	}
	function deleteDefault(table) {
		
		var defvalue = document.getElementById('defaultvalue').value;
		
		Ext.MessageBox.confirm(table,'Delete Default value for this table? ',defValueDelete);
		
		var table=document.getElementById('LookupTable').options[document.getElementById('LookupTable').selectedIndex].text;
		
		//var confirmDel=confirm('Delete default Value "'+defvalue+'" for table '+table)
		
		//if (confirmDel==true) {
			//var insertdefvalue = #server(..DefValueAction(table,''))#;
			//document.getElementById('defaultvalue').value='';
			//alert('Default Value Saved');
		//}
		
		//alert('Default Value Saved');
		
		
		
	}
	function defValueDelete(btn) {
		
		var table=document.getElementById('LookupTable').options[document.getElementById('LookupTable').selectedIndex].text;
		
		if (btn=='yes') {
			var insertdefvalue = #server(..DefValueAction(table,''))#;
			document.getElementById('defaultvalue').value='';
			//alert('Default Value Saved');
		}
		
		//alert('Default Value Saved');
		
		
		
	}
	function editDefault(table) {
		
		defvalue = document.getElementById('defaultvalue').value;
		
		Ext.MessageBox.prompt(table,'Please Enter Default value: ',saveDefault,'',false,defvalue);
		
		
		
	}
	function saveDefault(btn,newDef) {
		
		
		
		var table=document.getElementById('LookupTable').options[document.getElementById('LookupTable').selectedIndex].text;
		
		
		if ( btn=='ok') {
			var insertdefvalue = #server(..DefValueAction(table,newDef))#;
			document.getElementById('defaultvalue').value=newDef;
		}
		
		
		
	}
	function importFormShow()
	{
		sm('modalImport',500,300)
	}
	function Export(Table) {
		var filename = #server(..ExportData(Table))#
		window.location = 'IIBAENSEMBLE.csp.FileDownload.cls?filename='+filename
	}
		
	function RemoveRow(table,itemId) {
		
		var leftId1=document.getElementById('Tablevalues.Id'+itemId).cells[0].innerHTML;
		leftId1=leftId1.replace(/\&nbsp;/g,'');
		var leftId2=document.getElementById('Tablevalues.Id'+itemId).cells[1].innerHTML;
		leftId2=leftId2.replace(/\&nbsp;/g,'');
		var leftId3=document.getElementById('Tablevalues.Id'+itemId).cells[2].innerHTML;
		leftId3=leftId3.replace(/\&nbsp;/g,'');
		var rightId=document.getElementById('Tablevalues.Id'+itemId).cells[3].innerHTML;
		rightId=rightId.replace(/\&nbsp;/,'');
		
		
		var check=confirm('Delete translation: '+leftId1+'_'+leftId2+'_'+leftId3+'->'+rightId+'?');
		
		if ( check== true ) {
			
			var del=#server(..DeleteTranslation(table,itemId))#;
		
			var tableObj=document.getElementById('TableValues');
			
			//alert('ItemId: '+itemId);
			for (r=0;r<tableObj.rows.length;r++) {
				//alert('row: '+r+' id: '+tableObj.rows[r].id);
				if ( tableObj.rows[r].id == 'Tablevalues.Id'+itemId ) {
					//alert("delete row: "+r);
					tableObj.deleteRow(r);
					
				}
			}
		}
		
		
	}
	
	function rowEdit(table,itemId) {
		
		//alert('In rowEdit, table='+table+', itemId='+itemId);

		
		row=document.getElementById('Tablevalues.Id'+itemId);
		leftId1=row.cells[0].innerHTML;
		if (leftId1=='&nbsp;') {
			leftId1=''
		}
		row.cells[0].innerHTML='<input type="text" id="leftid1Edit.'+itemId+'" value="'+leftId1+'" >';
		
		leftId2=row.cells[1].innerHTML;
		if (leftId2=='&nbsp;') {
			leftId2=''
		}
		row.cells[1].innerHTML='<input type="text" id="leftid2Edit.'+itemId+'" value="'+leftId2+'" >';
		
		leftId3=row.cells[2].innerHTML;
		if (leftId3=='&nbsp;') {
			leftId3=''
		}
		row.cells[2].innerHTML='<input type="text" id="leftid3Edit.'+itemId+'" value="'+leftId3+'" >';
		
		rightId=row.cells[3].innerHTML;
		if (rightId=='&nbsp;') {
			rightId=''
		}
		row.cells[3].innerHTML='<input type="text" id="rightIdEdit.'+itemId+'" value="'+rightId+'" >';
				
		row.cells[4].innerHTML='<a id="Tablevalues.save.'+itemId+'" value="save" onclick="rowSaveEdit(\''+table+'\',\''+itemId+'\');" ><img src=\'customimages/save.gif\' alt=\'Save\' /></a> ';
		row.cells[5].innerHTML='<a id="Tablevalues.cancel.'+itemId+'" value="Cancel" onclick="rowCancelEdit(\''+table+'\',\''+itemId+'\');" ><img src=\'customimages/cancel.gif\' alt=\'Cancel\' /></a>';
		
	
		
	}
	
	function rowSaveEdit(table,itemId) {
		
		//alert('Save Edit for Item: '+itemId);
		var row=document.getElementById('Tablevalues.Id'+itemId);
		var leftid1=document.getElementById('leftid1Edit.'+itemId).value;
		var leftid2=document.getElementById('leftid2Edit.'+itemId).value;
		var leftid3=document.getElementById('leftid3Edit.'+itemId).value;
		var rightid=document.getElementById('rightIdEdit.'+itemId).value;
		
		//alert('calling EditSaveAction with: >'+itemId+'<,>'+leftid1+'<,>'+leftid2+'<,>'+leftid3+'<,>'+rightid+'<');
		var r=#server(..EditSaveAction(table,itemId,leftid1,leftid2,leftid3,rightid))#;
		
		if (r=='exists' ) {
			alert('This row appears to exist. Cannot save this edit');
		} else {
			if ( leftid1 == "" ) {
				leftid1="&nbsp;"
			} else {
				leftid1=leftid1.replace(/ /g,'&nbsp;');
			}
			row.cells[0].innerHTML=leftid1;
			if ( leftid2 == "" ) {
				leftid2="&nbsp;"
			} else {
				leftid2=leftid2.replace(/ /g,'&nbsp;');
			}
			row.cells[1].innerHTML=leftid2;
		
			if ( leftid3 == "" ) {
				leftid3="&nbsp;"
			} else {
				leftid3=leftid3.replace(/ /g,'&nbsp;');
			}
			row.cells[2].innerHTML=leftid3;
		
			if ( rightid == "" ) {
				rightid="&nbsp;"
			} else {
				rightid=rightid.replace(/ /g,'&nbsp;');
			}
			row.cells[3].innerHTML=rightid;
		
			row.cells[4].innerHTML='<a id="edit'+itemId+'" value="Edit" onclick="rowEdit(\''+table+'\',\''+itemId+'\');" ><img src=\'customimages/edit.gif\' alt=\'edit\' /></a>';
		
			row.cells[5].innerHTML='<a id="del'+itemId+'" value="Delete" onclick=\'RemoveRow("'+table+'","'+itemId+'");\' ><img src=\'customimages/trash_bold.gif\' alt=\'Delete\' /></a>';
		}
		
		//alert('saving >'+leftid1+'< >'+rightid+'<');
		
	}
	
	
	function rowCancelEdit(table,itemId) {
		//alert('Cancel Edit for Item: '+itemId);
		
		// get old values
		var y=#server(..ReloadRowData(table,itemId))#;
		
		
		
		// update buttons
		var row=document.getElementById('Tablevalues.Id'+itemId);
		row.cells[4].innerHTML='<a id="edit'+itemId+'" value="Edit" onclick="rowEdit(\''+table+'\',\''+itemId+'\');" ><img src=\'customimages/edit.gif\' alt=\'edit\' /></a>'
		row.cells[5].innerHTML='<a id="del'+itemId+'" value="Delete" onclick=\'RemoveRow("'+table+'","'+itemId+'");\' ><img src=\'customimages/trash_bold.gif\' alt=\'Delete\' /></a>';
		
	}
	
	function columnFilter(table,column) {
		
		// alert('In filter function: '+table);
		var filterId1=document.getElementById('filterLeftID1').value;
		// alert('filter LeftID1:'+filterId1);
		var filterId2=document.getElementById('filterLeftID2').value;
		// alert('filter LeftID2:'+filterId2);
		var filterId3=document.getElementById('filterLeftID3').value;
		// alert('filter LeftID3:'+filterId3);
		var filterIdR=document.getElementById('filterRightID').value;
		// alert('filter RightID:'+filterIdR);
		
		

		if ( (filterId1+filterId2+filterId3+filterIdR) == ""  ) {
			window.location.reload();
		} else {
			var newtable = #server(..FilterByColumn(table,filterId1,filterId2,filterId3,filterIdR))#;
			// alert(newtable);
			document.getElementById('tablediv').innerHTML = newtable;
		
			if (newtable == '</TABLE>') {
				self.document.location="IIBASupport.csp?PageName=LookUp&Mode=Display&LookupTable="+table;
			}
		
			//alert('filter LeftID1:'+filterId1);
			document.getElementById('filterLeftID1').value=filterId1;
			document.getElementById('filterLeftID2').value=filterId2;
			document.getElementById('filterLeftID3').value=filterId3;
			document.getElementById('filterRightID').value=filterIdR;
			//alert('column: '+column);
			if ( column != "" ) {
				document.getElementById(column).select();
			}
		}
	}
	

  
   </script>
  >
}

ClassMethod html()
{
	Quit:'..CheckPermissions() $$$OK
	
    set Mode = %request.Get("Mode")
	
	w "<div class='dialog' id=""modalImport"" >"
 	w ..buildmodalImport()
 	w "</div>"
 	
 	//Reg #1 - Phegel - Define objects used for table header.
	#DIM headers as %ListOfObjects
	#DIM header as IIBAENSEMBLE.LookupTableHeader
	#DIM currentHeader as IIBAENSEMBLE.LookupTableHeader
	
	If Mode = "" {
		// Req #1 - PHegel - Only show commands to create new tables or delete existing if they have Write access to the LookUpTableAdmin resource.
		if ( ##class(%SYSTEM.Security).Check("LookUpTableAdmin","WRITE"))
		{
			w "<table><tr><td class=""LayoutContentCol"" width=""20%"" ><div class=""DetailCommand"">"		
			w "<a class=""DetailCommand"" target=""_top"" href=""#"" onclick=""importFormShow(); return false;""><nobr>&nbsp;Import Table&nbsp;</nobr></A>"
			w "|"
			w "<a class=""DetailCommand"" target=""_top"" href=""IIBASupport.csp?PageName=LookUp&Mode=SetTable""><nobr>&nbsp;Create New Table&nbsp;</nobr></A>"
			// Req #2 - Phegel - Add the View Audit List button
			w "|"
			w "<a class=""DetailCommand"" target=""_top"" href=""IIBAENSEMBLE.Zen.TableAuditList.cls""><nobr>&nbsp;View Audit List&nbsp;</nobr></A>"
			w "</div></td></tr></table>"
		}
		w "<table id=""TableName"" class=""FilterTable"" border=""0"" cellpadding=""3"" cellspacing=""0"">"
		w "<tr><td align=""left"" nowrap>Select Table:&nbsp;&nbsp;"
		
		w "<select NAME=""LookupTable"" id=""LookupTable"" onchange='Display()'>"
		
		
		// Req #1 - PHegel - Change to get %ListOfObjects from Header object based on permisisons.
		set sc = ##class(IIBAENSEMBLE.LookupTableHeader).GetListByPermissions(.headers)
		quit:$$$ISERR(sc) sc
		
		w:sc=1 "<option VALUE=''>Select a Lookup Table...</option>"
		For i=1:1:headers.Count() {
      		Set header = headers.GetAt(i)
			set tablename = header.LookupTableName
			set tableID = header.%Id()
			w "<option VALUE="""_tablename_""">"_tablename_"</option>"
		}
	
		w "</select>"
		w "</td></tr></table>"



		
	} ElseIf Mode = "Display" {
		set Table = %request.Get("LookupTable")
		
		// Req #1 - PHegel - Only show commands to create new tables or delete existing if they have Write access to the LookUpTableAdmin resource.
		w "<table><tr><td class=""LayoutContentCol"" width=""20%"" ><div class=""DetailCommand"">"		
		if ( ##class(%SYSTEM.Security).Check("LookUpTableAdmin","WRITE"))
		{		
			w "<a class=""DetailCommand"" target=""_top"" href=""#"" onclick=""importFormShow(); return false;""><nobr>&nbsp;Import Table&nbsp;</nobr></A>"
			w "|"
			w "<a class=""DetailCommand"" target=""_top"" href=""#"" onclick=""Export('"_Table_"'); return false;""><nobr>&nbsp;Export Table&nbsp;</nobr></A>"
			w "|"
			w "<a class=""DetailCommand"" target=""_top"" href=""IIBASupport.csp?PageName=LookUp&Mode=SetTable""><nobr>&nbsp;Create New Table&nbsp;</nobr></A>"
			// Req #1 - Phegel - Add the Edit Table Detail Command
			w "|"
			w "<a class=""DetailCommand"" target=""_top"" href=""IIBASupport.csp?PageName=LookUp&Mode=SetTable&Table="_Table_"""><nobr>&nbsp;Edit Table Header&nbsp;</nobr></A>"
			// Req #4 - Phegel - Add Delete Table Command
			w "|"
			w "<a class=""DetailCommand"" target=""_top"" href=""#"" onclick=""Delete('"_Table_"'); return false;""><nobr>&nbsp;Delete Table&nbsp;</nobr></A>"
		}
		w "|&nbsp; Select Table:&nbsp;&nbsp;"
		
		w "<select NAME=""LookupTable"" id=""LookupTable"" onchange='Display()'>"
		
		// Req #1 - PHegel - Change to get %ListOfObjects from Header object based on permisisons.		
		set sc = ##class(IIBAENSEMBLE.LookupTableHeader).GetListByPermissions(.headers)
		quit:$$$ISERR(sc) sc
		
		For i=1:1:headers.Count() {
      		Set header = headers.GetAt(i)
			set tablename = header.LookupTableName
    	    if tablename = %request.Get("LookupTable") {
        	    w "<option VALUE="""_tablename_""" selected>"_tablename
        	    s currentHeader = header
    	    } else {
    	    	w "<option VALUE="""_tablename_""">"_tablename
    	    }

		}
	
		w "</select>"
		// Req #2 - Phegel - Add the View Audit List button
		w "|"
		w "<a class=""DetailCommand"" target=""_top"" href=""IIBAENSEMBLE.Zen.TableAuditList.cls""><nobr>&nbsp;View Audit List&nbsp;</nobr></A>"
		w "</div></td></tr></table>"
				
		w "<H3 id='tablename' title=''>"_Table_"</H3>"
		if (currentHeader.LookupTableDescription'="")
		{
			w "&nbsp&nbsp&nbsp-&nbsp<i>"_ currentHeader.LookupTableDescription _ " </i><br/>"	
		}
			
		set DefValueHTML = ""
		set TableHTML = ""
		
		
		set DefValueHTML = DefValueHTML_"<table id=""TableName"" class=""FilterTable"" border=""0"" cellpadding=""3"" cellspacing=""0"">"
		set DefValueHTML = DefValueHTML_"<tr><td align=""left"" nowrap>Default Value:&nbsp;&nbsp;"
		;set DefValueHTML = DefValueHTML_"<Input Type=""Text"" Name=""defaultvalue"" id=""defaultvalue"" OnChange=""DefValueSave('"_Table_"')"" Value="""
		set DefValueHTML = DefValueHTML_"<Input Type=""Text"" id='defaultvalue' Name=""defaultvalue"" readOnly='true' Value="""
		
		// Req#1 - Phegel - Set to currentHeader's DefaultValue
		set DefValueHTML = DefValueHTML_$ZCVT(currentHeader.DefaultValue,"O","HTML")
		
		set DefValueHTML = DefValueHTML_""">"
		set DefValueHTML = DefValueHTML_"</td>"
		
		// Reg#1 - Phegel - Check write permisions to render edit and delete buttons.
		// Bug#3 - Fix Default button visible to copath test user (change to current resource rather than page resource LookUpTableAdmin)
		if ( ##class(%SYSTEM.Security).Check(currentHeader.Resource,"WRITE"))
		{
			//set DefValueHTML = DefValueHTML_"<td colspan='2'/>"	
			set DefValueHTML = DefValueHTML_"<td nowrap align='left' style='text-align:left;cursor:pointer;cursor:hand;' ><A id='EditDefVal' value='Edit' onclick=""editDefault("_..QuoteJS(Table)_");""><img src='customimages/edit.gif' alt='Edit' /></a>  </td>"
			set DefValueHTML = DefValueHTML_"<td nowrap align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;"" ><A id='DelDefVal' value='Delete' onclick=""deleteDefault("_..QuoteJS(Table)_");""><img src='customimages/trash_bold.gif' alt='Delete' /></a>  </td>"
		}
		else
		{
			set DefValueHTML = DefValueHTML_"<td colspan='2'/>"	
		}
		set DefValueHTML = DefValueHTML_"</tr></table>"		

		w DefValueHTML		
		
		set TableHTML = TableHTML_"<span id=""tablediv"">"

		set TableHTML = TableHTML_..BuildHeaderHTML(currentHeader)
		// Reg#1 - Phegel - Check write permisions to render edit and delete buttons.
		if ( ##class(%SYSTEM.Security).Check(currentHeader.Resource,"WRITE"))
		{
			set TableHTML = TableHTML_"<tr class=""OddRow"" >"
			set TableHTML = TableHTML_"<TD nowrap><Input Type=""Text"" Name=""InsLeftID1"" id=""InsLeftID1"" Value=""""></TD>"
			set TableHTML = TableHTML_"<TD nowrap><Input Type=""Text"" Name=""InsLeftID2"" id=""InsLeftID2"" Value=""""></TD>"
			set TableHTML = TableHTML_"<TD nowrap><Input Type=""Text"" Name=""InsLeftID3"" id=""InsLeftID3"" Value=""""></TD>"
			set TableHTML = TableHTML_"<TD nowrap><Input Type=""Text"" Name=""RightID"" id=""RightID"" Value=""""></TD>"
			set TableHTML = TableHTML_"<td nowrap align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;"" ><a id='SaveNewRow' value='save' onclick=""InsertSave('"_Table_"');""/><img src='customimages/save.gif' alt='Save' /></a></td>"
			set TableHTML = TableHTML_"<td>&nbsp;</td>"
			set TableHTML = TableHTML_"</TR>"
		}
		w TableHTML
		
		set TableHTML = ""
		
		//set rset.CurrRow = 0
		
		set i=2
		
		Set rset = ##class(%ResultSet).%New()
		Do rset.Prepare("SELECT ID, LeftID1, LeftID2, LeftID3, RightID FROM IIBAENSEMBLE.LookupTable WHERE LookupID = '"_Table_"' ORDER BY LeftID1, LeftID2, LeftID3")
		Do rset.Execute()
		
		While (rset.Next()) {
			
			
			if '(($ZCVT(rset.Data("LeftID1"),"U")="DEFAULTVALUE")&&($ZCVT(rset.Data("LeftID2"),"U")="DEFAULTVALUE")&&($ZCVT(rset.Data("LeftID3"),"U")="DEFAULTVALUE")) {
			
		  		if i#2=0 {
				set TableHTML = TableHTML_"<tr class=""EvenRow"" id='Tablevalues.Id"_rset.Data("ID")_"' >"
				} Else {
				set TableHTML = TableHTML_"<tr class=""OddRow"" id='Tablevalues.Id"_rset.Data("ID")_"' >"
				}		

				s LeftId1=##class(IIBAENSEMBLE.Functions).StringReplace(rset.Data("LeftID1")," ","&nbsp;") s:LeftId1="" LeftId1="&nbsp;"
				s LeftId2=##class(IIBAENSEMBLE.Functions).StringReplace(rset.Data("LeftID2")," ","&nbsp;") s:LeftId2="" LeftId2="&nbsp;"
				s LeftId3=##class(IIBAENSEMBLE.Functions).StringReplace(rset.Data("LeftID3")," ","&nbsp;") s:LeftId3="" LeftId3="&nbsp;"
				s RightId=##class(IIBAENSEMBLE.Functions).StringReplace(rset.Data("RightID")," ","&nbsp;") s:RightId="" RightId="&nbsp;"
				
				
				set TableHTML = TableHTML_"<TD nowrap>"_LeftId1_"</TD>"
	        	set TableHTML = TableHTML_"<TD nowrap>"_LeftId2_"</TD>"
	        	set TableHTML = TableHTML_"<TD nowrap>"_LeftId3_"</TD>"
	        	set TableHTML = TableHTML_"<TD nowrap>"_RightId_"</TD>"
				
				// Reg#1 - Phegel - Check write permisions to render edit and delete buttons.
				if ( ##class(%SYSTEM.Security).Check(currentHeader.Resource,"WRITE"))
				{
						set TableHTML = TableHTML_"<td nowrap align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;"" ><A id=edit"_rset.Data("ID")_" value='Edit' onclick=""rowEdit("_..QuoteJS(Table)_","_..QuoteJS(rset.Data("ID"))_");""><img src='customimages/edit.gif' alt='Edit' /></a>  </td>"
						set TableHTML = TableHTML_"<td nowrap align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;"" ><a id='del"_rset.Data("ID")_"' value='Delete' onclick=""RemoveRow("_..QuoteJS(Table)_","_..QuoteJS(rset.Data("ID"))_");"" ><img src='customimages/trash_bold.gif' alt='Delete' /></a></td>"
				}
				else
				{
					set TableHTML = TableHTML_"<td colspan='2'/>"	
				}    	        	
				set TableHTML = TableHTML_"</TR>"
	        	set i=i+1
	        
	        //set %session.Data("tablelength") = $LENGTH(TableHTML)
			}
	        
	        if $LENGTH(TableHTML) > 30000 {
		        w TableHTML	
		        set TableHTML = ""
	        }
			
		}	
		
		w TableHTML
          
		w "</TABLE>"
		w "</span>"
		
		
	} ElseIf Mode = "Edit" {
		
		
		set Table = %request.Get("Table")
		Set EditItemID = %request.Get("transID")
		
		Set currentHeader = ##class(IIBAENSEMBLE.LookupTableHeader).GetObjectByName(Table)
				
		w "<H3>"_Table_"</H3>" 
		
		set TableHTML = ""
		
		set TableHTML = TableHTML_"<span id=""tablediv"">"
		
		set TableHTML = TableHTML_..BuildHeaderHTML(currentHeader)
		
		Set rset = ##class(%ResultSet).%New()
		Do rset.Prepare("SELECT ID, LeftID1, LeftID2, LeftID3, RightID FROM IIBAENSEMBLE.LookupTable WHERE ID = "_EditItemID_"")
		Do rset.Execute()
		Do rset.Next()
			
		set TableHTML = TableHTML_"<tr class=""OddRow"" >"
		set TableHTML = TableHTML_"<TD nowrap><Input Type=""Text"" Name=""InsLeftID1"" id=""InsLeftID1"" Value='"_$ZCVT(rset.Data("LeftID1"),"O","HTML")_"'></TD>"
		set TableHTML = TableHTML_"<TD nowrap><Input Type=""Text"" Name=""InsLeftID2"" id=""InsLeftID2"" Value='"_$ZCVT(rset.Data("LeftID2"),"O","HTML")_"'></TD>"
		set TableHTML = TableHTML_"<TD nowrap><Input Type=""Text"" Name=""InsLeftID3"" id=""InsLeftID3"" Value='"_$ZCVT(rset.Data("LeftID3"),"O","HTML")_"'></TD>"
		set TableHTML = TableHTML_"<TD nowrap><Input Type=""Text"" Name=""RightID"" id=""RightID"" Value='"_$ZCVT(rset.Data("RightID"),"O","HTML")_"'></TD>"
		// Reg#1 - Phegel - Check write permisions to render edit and delete buttons.
		if ( ##class(%SYSTEM.Security).Check(currentHeader.Resource,"WRITE"))
		{
			set TableHTML = TableHTML_"<td nowrap align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;"" ><a href=""IIBASupport.csp?PageName=LookUp&Mode=Display&LookupTable="_Table_""" target=""_top"" onclick=""EditSave('"_EditItemID_"','"_Table_"');"">save</a></td>"
			set TableHTML = TableHTML_"<td nowrap align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;"" ><a href=""IIBASupport.csp?PageName=LookUp&Mode=Display&LookupTable="_Table_""" target=""_top"" >cancel</a></td>"
		}
		else
		{
			set TableHTML = TableHTML_"<td colspan='2'/>"	
		}    	        	

		set TableHTML = TableHTML_"</TR>"
		
		set TableHTML = TableHTML_"</TABLE>"
		set TableHTML = TableHTML_"</span>"
		
		w TableHTML
		
	} ElseIf Mode = "Import" {

		s importstream = ##class(%GlobalCharacterStream).%New()
		d importstream.CopyFrom(%request.GetMimeData("importfile"))
		s tSC = ..InsertData(importstream)
		if tSC = "OK" {
			d ..ImportData(%request.Get("overwrite"),%request.Get("overwritetrans"))
			w "<META HTTP-EQUIV=""Refresh"" CONTENT=""0; URL=IIBASupport.csp?PageName=LookUp"">"
		} else {
			w tSC
		}
		
	} ElseIf Mode = "Remove" {
		
		set Table = %request.Get("Table")
		Set RemoveItemID = %request.Get("transID")
		
		Set rset = ##class(%ResultSet).%New()
		Do rset.Prepare("DELETE FROM IIBAENSEMBLE.LookupTable WHERE ID = "_RemoveItemID_"")
		Do rset.Execute()
		
		w "<META HTTP-EQUIV=""Refresh"" CONTENT=""0; URL=IIBASupport.csp?PageName=LookUp&Mode=Display&LookupTable="_Table_""">"
		w "This page should auto redirect to the table you have edited. If it doesn't, please click here: "_"<a href=""IIBASupport.csp?PageName=LookUp"">Home</a>"

		
	} ElseIf Mode = "InsertSave" {
		
		set Table = %request.Get("Table")
		&js<InsertSave('#(Table)#');>
			
	// Req #1 - Phegel changed from Insert Table to Set Table (so it can insert or update a table).  Also, changed to capture properties for LookupTableHeader
	//  		Note that the Table name cannot be updated.
	} ElseIf (Mode="SetTable") {
		
		// Req #1 - Phegel - Change to insert Lookup Table Header values
		
		w "<table><tr><td class=""LayoutContentCol"" width=""20%"" ><div class=""DetailCommand"">"		
		w "<a class=""DetailCommand"" target=""_top"" href=""#"" onclick=""importFormShow(); return false;""><nobr>&nbsp;Import Table&nbsp;</nobr></A>"
		w "|"
		w "<a class=""DetailCommand"" id=""linkSetTable"" target=""_top"" href=""IIBASupport.csp?PageName=LookUp&Mode=SetTable""><nobr>&nbsp;Create New Table&nbsp;</nobr></A>"
		w "</div></td></tr></table>"
		
		s Table = %request.Get("Table")	
		
		if (Table '="")
		{
			set currentHeader = ##class(IIBAENSEMBLE.LookupTableHeader).GetObjectByName(Table, .tSC)
			set LookupTableDescription = currentHeader.LookupTableDescription 
			set ColumnNameLeftID1 = currentHeader.ColumnNameLeftID1 
			set ColumnNameLeftID2 = currentHeader.ColumnNameLeftID2
			set ColumnNameLeftID3 = currentHeader.ColumnNameLeftID3
			set ColumnNameRightID = currentHeader.ColumnNameRightID 
			set Resource = currentHeader.Resource
		}
		set:'$Data(LookupTableDescription) LookupTableDescription = " "
		set:'$Data(ColumnNameLeftID1) ColumnNameLeftID1 = "Left ID 1"
		set:'$Data(ColumnNameLeftID2) ColumnNameLeftID2 = "Left ID 2"
		set:'$Data(ColumnNameLeftID3) ColumnNameLeftID3 = "Left ID 3"
		set:'$Data(ColumnNameRightID) ColumnNameRightID = "Right ID"
		set:'$Data(Resource) Resource = "LookUpTableAdmin"
		
					
		w "<br/><h3>"
		w:Table'="" "<i>Edit</i> "_ Table _" - "
		w "Lookup Table Header</h3><br/><Form name=""LookupTableAdminForm"" id=""LookupTableAdminForm"" METHOD=POST ACTION=""IIBASupport.csp?PageName=LookUp"">"
		w "<TABLE class=""DetailTable"">"
		if (Table '= "")
			{w "<tr><td>Edit Table Name:&nbsp;</td><td>"
			w Table_" <INPUT TYPE='HIDDEN' NAME=""LookupTableName"" id=""LookupTableName"" SIZE=""30"" VALUE="""_Table_"""></td></tr>"}
		else
			{w "<tr><td>Create New Table Name:&nbsp;</td><td>"
			w "<INPUT NAME=""LookupTableName"" id=""LookupTableName"" SIZE=""30"" VALUE=""""></td></tr>"}
		w "<tr><td>Table Description:&nbsp;</td><td><INPUT NAME=""LookupTableDescription"" id=""LookupTableDescription"" SIZE=""100"" VALUE='"_LookupTableDescription_"'></td></tr>"
		w "<tr><td>Column Name Left ID1:&nbsp;</td><td><INPUT NAME=""ColumnNameLeftID1"" id=""ColumnNameLeftID1"" SIZE=""30"" VALUE='"_ColumnNameLeftID1_"'></td></tr>"
		w "<tr><td>Column Name Left ID2:&nbsp;</td><td><INPUT NAME=""ColumnNameLeftID2"" id=""ColumnNameLeftID2"" SIZE=""30"" VALUE='"_ColumnNameLeftID2_"'></td></tr>"
		w "<tr><td>Colum nName Left ID3:&nbsp;</td><td><INPUT NAME=""ColumnNameLeftID3"" id=""ColumnNameLeftID3"" SIZE=""30"" VALUE='"_ColumnNameLeftID3_"'></td></tr>"
		w "<tr><td>ColumnName Right ID:&nbsp;</td><td><INPUT NAME=""ColumnNameRightID"" id=""ColumnNameRightID"" SIZE=""30"" VALUE='"_ColumnNameRightID_"'></td></tr>"
		if ##class(%SYSTEM.Security).Check("%All","READ,WRITE,USE")
		{
			w "<tr><td>Resource:&nbsp;</td><td><INPUT NAME=""Resource"" id=""Resource"" SIZE=""30"" VALUE='"_Resource_"'></td></tr>"
		}
		w "</TABLE>"
		w "<Input TYPE=""HIDDEN"" NAME=""Mode"" id=""Mode"" VALUE='SetTableAction'>"
		w "<br/><Input Type=""Submit"" Name=""btnInsert"" id=""btnInsert"" Value=""Save"">"
		w "</Form>"
		
		
		&html<
		<script language=javascript>
	
			document.getElementById('linkSetTable').style.color = 'red';
	
		</script>	
		>
		
	} ElseIf (Mode = "SetTableAction") {
		// Req #1 - Phegel - Change to insert Lookup Table Header first.
		set Table = %request.Get("LookupTableName")

		// Req #1 - Phegel - Change to use GetIdByName to see if Lookup Table Header exist
		s tableId = ##class(IIBAENSEMBLE.LookupTableHeader).GetIdByName(Table)
		s tSC = 1
		if (($LENGTH(Table)<=3))
			{
				&js<alert('Lookup Table Name cannot be less than 3 characters long!');>
				set tSC = 0
				QUIT
			}
		QUIT:tSC=0
				
		// Req#1 - Phegel - Change to use Object methods to create.
		If tableId = "" 
		{
			//Create new table
			s newHeader = ##class(IIBAENSEMBLE.LookupTableHeader).%New()
			s newHeader.LookupTableName = Table
		}
		else
		{
			//Load existing table to save edits
			s newHeader = ##class(IIBAENSEMBLE.LookupTableHeader).GetObjectByName(Table)
		}
		if 
		set newHeader.LookupTableDescription = %request.Get("LookupTableDescription")
		set newHeader.ColumnNameLeftID1 = %request.Get("ColumnNameLeftID1")
		set newHeader.ColumnNameLeftID2 = %request.Get("ColumnNameLeftID2")
		set newHeader.ColumnNameLeftID3 = %request.Get("ColumnNameLeftID3")
		set newHeader.ColumnNameRightID = %request.Get("ColumnNameRightID")
		set newHeader.Resource = %request.Get("Resource")
		set tSC = newHeader.%Save()
		
		Q:$$$ISERR(tSC) tSC
		
		// Req#1 - Phegel - Add one child object if this is a new table.
		If tableId = "" 
		{
			set newLookup = ##class(IIBAENSEMBLE.LookupTable).%New()
			set newLookup.LookupID = Table
			set tSC = newLookup.%Save()
			Q:$$$ISERR(tSC) tSC
		}
		w "<META HTTP-EQUIV=""Refresh"" CONTENT=""0; URL=IIBASupport.csp?PageName=LookUp&Mode=Display&LookupTable="_Table_""">"
		w "This page should auto redirect to the table you have edited.  If it doesn't, please click here: "_"<a href=""IIBASupport.csp?PageName=LookUp&Mode=Display&LookupTable="_Table_""">Back to Table</a>"
	
	
	}
}

// Reg #1 - Phegel - Changed to take whole header as parameter to build column names as well

ClassMethod BuildHeaderHTML(pHeader As IIBAENSEMBLE.LookupTableHeader) As %String [ Language = objectscript ]
{
 set TableHTML = ""
 set Table = pHeader.LookupTableName
 
 set TableHTML = TableHTML_"<table id='TableValues' class=""DetailTable"" border=""1"" cellpadding=""2"" cellspacing=""0"" >"
 set TableHTML = TableHTML_"<tr><td><input type=""text"" name=""filterLeftID1"" id=""filterLeftID1"" style=""background-color: Khaki"" value="""" onchange=""columnFilter('"_Table_"','filterLeftID1');""></td>"
 set TableHTML = TableHTML_"<td><input type=""text"" name=""filterLeftID2"" id=""filterLeftID2"" style=""background-color: Khaki"" value="""" onchange=""columnFilter('"_Table_"','filterLeftID2');""></td>"
 set TableHTML = TableHTML_"<td><input type=""text"" name=""filterLeftID3"" id=""filterLeftID3"" style=""background-color: Khaki"" value="""" onchange=""columnFilter('"_Table_"','filterLeftID3');""></td>"
 set TableHTML = TableHTML_"<td><input type=""text"" name=""filterRightID"" id=""filterRightID"" style=""background-color: Khaki"" value="""" onchange=""columnFilter('"_Table_"','filterRightID');""></td>"
 set TableHTML = TableHTML_"<td onclick=""columnFilter('"_Table_"','')"" ><img src='customimages/filter.gif' alt='Filter' /></a>"
 set TableHTML = TableHTML_"</td><td>&nbsp;</td></tr>"
 set TableHTML = TableHTML_"<tr>"
 set TableHTML = TableHTML_"<th nowrap align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;"" onclick=""SortTable('"_Table_"','LeftID1','RightID');""><a title=""Click to sort by this column."">"_pHeader.ColumnNameLeftID1_"</a></th>"
 set TableHTML = TableHTML_"<th nowrap align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;"" onclick=""SortTable('"_Table_"','LeftID2','RightID');""><a title=""Click to sort by this column."">"_pHeader.ColumnNameLeftID2_"</a></th>"
 set TableHTML = TableHTML_"<th nowrap align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;"" onclick=""SortTable('"_Table_"','LeftID3','RightID');""><a title=""Click to sort by this column."">"_pHeader.ColumnNameLeftID3_"</a></th>"
 set TableHTML = TableHTML_"<th nowrap align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;"" onclick=""SortTable('"_Table_"','RightID','LeftID1');""><a title=""Click to sort by this column."">"_pHeader.ColumnNameRightID_"</a></th>"
 set TableHTML = TableHTML_"<th></th>"
 set TableHTML = TableHTML_"<th></th>"
 /**/
 set TableHTML = TableHTML_"</tr>"
 
 Quit TableHTML
}

/// This method is used to set the default value from within the web page.
ClassMethod DefValueAction(Table As %String, DefValue As %String) As %String [ Language = objectscript ]
{
	// Set the Default value based on Table Name
	#DIM obj as IIBAENSEMBLE.LookupTableHeader
	set obj = ##class(IIBAENSEMBLE.LookupTableHeader).GetObjectByName(Table)
	set oldDefValue = obj.DefaultValue
	set quitvalue= ##class(IIBAENSEMBLE.LookupTableHeader).SetDefaultValue(Table,DefValue)
	set eventData = ..GetHeaderEventData("DefValueAction",obj)
	do ..AuditHeaderChanges("DefaultValue Old:"_oldDefValue_" New:"_DefValue, eventData)
	
	quit quitvalue
}

/// Reg#2 - Phegel - Rework EditSaveAction to use object making it more efficient to do auditing.
ClassMethod EditSaveAction(Table As %String, ItemID As %String, LeftID1 As %String, LeftID2 As %String, LeftID3 As %String, RightID As %String) As %String [ Language = objectscript ]
{
 
 set exists = 0

 // Replace &nbsp; with normal space.
 set LeftID1 = ##class(IIBAENSEMBLE.Functions).StringReplace(LeftID1,$C(160)," ")
 set LeftID2 = ##class(IIBAENSEMBLE.Functions).StringReplace(LeftID2,$C(160)," ")
 set LeftID3 = ##class(IIBAENSEMBLE.Functions).StringReplace(LeftID3,$C(160)," ")
 set RightID = ##class(IIBAENSEMBLE.Functions).StringReplace(RightID,$C(160)," ")
 
 // Use new method to check for existing.	
 set tSC = ##class(IIBAENSEMBLE.LookupTable).CheckExisting(Table, ItemID, LeftID1, LeftID2, LeftID3, RightID, .exists, .foundId)
 		
 If exists = 1 {
 	set quitvalue = "exists"
 	set obj = ##class(IIBAENSEMBLE.LookupTable).%OpenId(foundId)
 	set event = ..GetRowEventData("EditSaveAction", obj, 1)
 } Else {
	
 	set obj = ##class(IIBAENSEMBLE.LookupTable).%OpenId(ItemID)
	set event = ..GetRowEventData("EditSaveAction", obj, 1)
 	Set obj.LeftID1 = LeftID1
 	set obj.LeftID2 = LeftID2
 	set obj.LeftID3 = LeftID3
 	set obj.RightID = RightID
 	
 	s tSC = obj.%Save()
 	
 	set:'$$$ISERR(tSC) event = event_..GetRowEventData("EditSaveAction", obj)
 	
 	set:'$$$ISERR(tSC) quitvalue = "saved"
 	
 }
 set desc = "QuitValue: "_quitvalue_ " - "_ Table_":("_ItemID_"),"_LeftID1_","_LeftID2_","_LeftID3_"->"_RightID
 do ..AuditRowChanges(desc,event)
 
 Quit quitvalue
}

ClassMethod ExportData(TableName As %String) As %String [ Language = objectscript ]
{
 	
 	s EnsSysDir = ##class(%File).ParentDirectoryName(##class(%File).ManagerDirectory())
	s filetimestamp = ##class(Ens.Util.Time).FormatDateTime("%Y%m%d%H%M%S")
	
	if '##class(%File).DirectoryExists(EnsSysDir_"IIBAExports") { 
		d ##class(%File).CreateDirectory(EnsSysDir_"IIBAExports") 
	}
	s filename = $TR(TableName_"_"_%session.SessionId_".csv"," ","_")
	s file = ##class(%File).%New(EnsSysDir_"IIBAExports\"_filename)
	d file.Open("WSN")
	d file.WriteLine("TableName,LeftID1,LeftID2,LeftID3,RightID")
	
 	set Tablerset=##class(%ResultSet).%New()
 	do Tablerset.Prepare("Select LookupID, LeftID1, LeftID2, LeftID3, RightID from IIBAENSEMBLE.LookupTable WHERE LookupID = '"_TableName_"'")
 	do Tablerset.Execute()
 	While Tablerset.Next() {
 		
 		set strFileText = ""
 		set strFileText = strFileText_$C(34)_##class(IIBAENSEMBLE.Functions).StringReplace(Tablerset.Data("LookupID"),$C(34),$C(34,34))_$C(34)_","
 		set strFileText = strFileText_$C(34)_##class(IIBAENSEMBLE.Functions).StringReplace(Tablerset.Data("LeftID1"),$C(34),$C(34,34))_$C(34)_","
 		set strFileText = strFileText_$C(34)_##class(IIBAENSEMBLE.Functions).StringReplace(Tablerset.Data("LeftID2"),$C(34),$C(34,34))_$C(34)_","
 		set strFileText = strFileText_$C(34)_##class(IIBAENSEMBLE.Functions).StringReplace(Tablerset.Data("LeftID3"),$C(34),$C(34,34))_$C(34)_","
 		set strFileText = strFileText_$C(34)_##class(IIBAENSEMBLE.Functions).StringReplace(Tablerset.Data("RightID"),$C(34),$C(34,34))_$C(34)
 		
 		//&js<newFileObject.WriteLine(#(..QuoteJS(strFileText))#);>
 		d file.WriteLine(strFileText) 
 		
 	}
 	do ..AuditHeaderChanges("Exported: "_TableName,"{LookupTableName:"_TableName_",RowCount:"_Tablerset.%ROWCOUNT_"}")
 	do Tablerset.Close()
 	do file.Close()
 	kill file
 		
 	Quit filename
}

ClassMethod FilterByColumn(Table As %String, LeftId1 As %String, LeftId2 As %String, LeftId3 As %String, RightId As %String) As %String [ Language = objectscript ]
{
 	
 
 		set TableHTML = ""
 		Set currentHeader = ##class(IIBAENSEMBLE.LookupTableHeader).GetObjectByName(Table)
 		set TableHTML = TableHTML_..BuildHeaderHTML(currentHeader)
 		if ( ##class(%SYSTEM.Security).Check(currentHeader.Resource,"WRITE")){
	 		set TableHTML = TableHTML_"<tr class=""OddRow"" >"
	 		set TableHTML = TableHTML_"<TD nowrap><Input Type=""Text"" Name=""InsLeftID1"" id=""InsLeftID1"" Value=""""></TD>"
	 		set TableHTML = TableHTML_"<TD nowrap><Input Type=""Text"" Name=""InsLeftID2"" id=""InsLeftID2"" Value=""""></TD>"
	 		set TableHTML = TableHTML_"<TD nowrap><Input Type=""Text"" Name=""InsLeftID3"" id=""InsLeftID3"" Value=""""></TD>"
	 		set TableHTML = TableHTML_"<TD nowrap><Input Type=""Text"" Name=""RightID"" id=""RightID"" Value=""""></TD>"
	 		//set TableHTML = TableHTML_"<td nowrap align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;"" ><a href=""IIBASupport.csp?PageName=LookUp&Mode=Display&LookupTable="_Table_""" target=""_top"" onclick=""InsertSave('"_Table_"');"">save</a></td>"
	 		set TableHTML = TableHTML_"<td nowrap align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;"" ><a id='SaveNewRow' value='save' onclick=""InsertSave('"_Table_"');""/><img src='customimages/save.gif' alt='Save' /></a></td>"
	 		set TableHTML = TableHTML_"<td>&nbsp;</td>"
	 		set TableHTML = TableHTML_"</TR>"
 		}
 		
 		set sqlQuery="SELECT ID, LeftID1, LeftID2, LeftID3, RightID FROM IIBAENSEMBLE.LookupTable WHERE LookupID = '"_Table_"' "	
 		if (LeftId1 '= "" ){
 			set sqlQuery=sqlQuery_" AND UPPER(LeftID1) LIKE '%"_$ZCONVERT(LeftId1,"U")_"%'"
 		}
 		if (LeftId2 '= "" ){
 			set sqlQuery=sqlQuery_" AND UPPER(LeftID2) LIKE '%"_$ZCONVERT(LeftId2,"U")_"%'"
 		}
 		if (LeftId3 '= "" ){
 			set sqlQuery=sqlQuery_" AND UPPER(LeftID3) LIKE'%"_$ZCONVERT(LeftId3,"U")_"%'"
 		}
 		if (RightId '= "" ){
 			set sqlQuery=sqlQuery_" AND UPPER(RightID) LIKE'%"_$ZCONVERT(RightId,"U")_"%'"
 		}	
 		set sqlQuery=sqlQuery_" ORDER BY LeftID2, LeftID3, RightID"
 		
 		// Q sqlQuery
 		
 		Set rset = ##class(%ResultSet).%New()
 		Do rset.Prepare(sqlQuery)
 		Do rset.Execute()
 		set i=2
 		While (rset.Next()) {
 		  	if i#2=0 {
 			set TableHTML = TableHTML_"<tr class=""EvenRow"" id='Tablevalues.Id"_rset.Data("ID")_"' >"
 			} Else {
 			set TableHTML = TableHTML_"<tr class=""OddRow"" id='Tablevalues.Id"_rset.Data("ID")_"' >"
 			}
 
             if ((rset.Data("LeftID1")="DefaultValue")&&(rset.Data("LeftID2")="DefaultValue")&&(rset.Data("LeftID3")="DefaultValue")) {
 	            //set DefValueHTML = DefValueHTML_rset.Data("RightID")
             } Else {
	             
	             
	            s LeftId1=##class(IIBAENSEMBLE.Functions).StringReplace(rset.Data("LeftID1")," ","&nbsp;") s:LeftId1="" LeftId1="&nbsp;"
				s LeftId2=##class(IIBAENSEMBLE.Functions).StringReplace(rset.Data("LeftID2")," ","&nbsp;") s:LeftId2="" LeftId2="&nbsp;"
				s LeftId3=##class(IIBAENSEMBLE.Functions).StringReplace(rset.Data("LeftID3")," ","&nbsp;") s:LeftId3="" LeftId3="&nbsp;"
				s RightId=##class(IIBAENSEMBLE.Functions).StringReplace(rset.Data("RightID")," ","&nbsp;") s:RightId="" RightId="&nbsp;"
				 
 	            set TableHTML = TableHTML_"<TD nowrap>"_LeftId1_"</TD>"
 	            set TableHTML = TableHTML_"<TD nowrap>"_LeftId2_"</TD>"
 	            set TableHTML = TableHTML_"<TD nowrap>"_LeftId3_"</TD>"
 	            set TableHTML = TableHTML_"<TD nowrap>"_RightId_"</TD>"
 	            if ( ##class(%SYSTEM.Security).Check(currentHeader.Resource,"WRITE"))
 	            {
 					set TableHTML = TableHTML_"<td nowrap align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;"" ><a id=edit"_rset.Data("ID")_" value='Edit' onclick=""rowEdit("_..QuoteJS(Table)_","_..QuoteJS(rset.Data("ID"))_");""><img src='customimages/edit.gif' alt='Edit' /></a> </td>"
 					set TableHTML = TableHTML_"<td nowrap align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;"" ><a id='del"_rset.Data("ID")_"' value='Delete' onclick=""RemoveRow("_..QuoteJS(Table)_","_..QuoteJS(rset.Data("ID"))_" );"" ><img src='customimages/trash_bold.gif' alt='Delete' /></a></td>"
 	            }
 	            else
 	            {
	 	         	set TableHTML = TableHTML_"<td colspan='2' />" 
 	            }
 	            
 	            
 	            set TableHTML = TableHTML_"</TR>"
 	            set i=i+1
             }
             
             if $LENGTH(TableHTML) > 30000 {
 		        &js<alert('This table is to big to filter - sorry!');>
 		        set TableHTML = ""
 		        Quit
 	        }
         
 		}
 		
 		set TableHTML = TableHTML_"</TABLE>"
 		
 		
 		//&js<document.getElementById('tablediv').innerHTML = document.getElementById('tablediv').innerHTML;>
 		
 Quit TableHTML
}

ClassMethod ImportData(overwriteTables As %String, overwriteValues As %String) As %String [ Language = objectscript ]
{
	quit ..ImportDataBySession(%session.SessionId, overwriteTables, overwriteValues)
}

ClassMethod ImportDataBySession(sessionID As %String, overwriteTables As %String, overwriteValues As %String) As %String [ Language = objectscript ]
{
  
 //if overwriteTables is true
 	//select distinct table name and remove all rows from lookuptable with those table names
 	//insert all rows into lookuptable
 //&js<alert('#(overwriteValues)#')>
 
 do ..AuditRowChanges("OverwriteTables:"_overwriteTables_" Overwrite Values:"_overwriteValues,"ImportData()")
 if overwriteTables="true" {
 	Set rstblnames = ##class(%ResultSet).%New()
 	Do rstblnames.Prepare("SELECT DISTINCT LookupID from IIBAENSEMBLE.LookupTableImport where SessionID = '"_sessionID_"'")
 	Do rstblnames.Execute()
 	While rstblnames.Next() {
 		&html< table: #(rstblnames.Data("LookupID"))# session: #(sessionID)# <br/> >
 		Set rsdeltbl = ##class(%ResultSet).%New()
 		Do rsdeltbl.Prepare("DELETE FROM IIBAENSEMBLE.LookupTable WHERE LookupID = '"_rstblnames.Data("LookupID")_"'")
 		Do rsdeltbl.Execute()
 		Do rsdeltbl.Close()
 		//Req#2 - Phegel Audit deleting table
 		do ..AuditRowChanges("Deleted LookupTableName: "_rstblnames.Data("LookupID"),"ImportData()")
 	}
 	Do rstblnames.Close()
 	
 	Set rstblvalues = ##class(%ResultSet).%New()
 	Do rstblvalues.Prepare("SELECT * from IIBAENSEMBLE.LookupTableImport where SessionID = '"_sessionID_"'")
 	Do rstblvalues.Execute()
 	While rstblvalues.Next() {
	 	//Req#2 - Phegel Change to use new insert and Audit insert into table
 		set tSC = ##class(IIBAENSEMBLE.LookupTable).Insert(rstblvalues.Data("LookupID"),rstblvalues.Data("LeftID1"),rstblvalues.Data("LeftID2"),rstblvalues.Data("LeftID3"),rstblvalues.Data("RightID"),.Exists,.ItemId)
 		//&html< #(rstblvalues.Data("RightID"))# - #(tSC)# Item: #(ItemId)#<br/> >
 		&html<#(Exists)#>
 		set EventData = ..GetRowEventDataById("ImportData()",ItemId)
 		do ..AuditRowChanges("Insert row into: "_rstblvalues.Data("LookupID")_"("_ItemId_") Status:"_tSC_" Exists:"_Exists, EventData)
 	}
 	Do rstblvalues.Close()
 }
 	
 //if overwriteTables is false
 	//if overwriteValues is true
 		//perform an insert/update on all rows
 	//if overwriteValues is false
 		//perform an insert on all rows, skipping pre-existing rows
 
 if overwriteTables="false" {
 	if overwriteValues="on" {
 		Set rstblvalues = ##class(%ResultSet).%New()
 		Do rstblvalues.Prepare("SELECT * from IIBAENSEMBLE.LookupTableImport where SessionID = '"_sessionID_"'")
 		Do rstblvalues.Execute()
 		While rstblvalues.Next() {
 			//&js<alert('#(rstblvalues.Data("RightID"))#')>
 			//&html<#(rstblvalues.Data("LeftID1"))# -&gt #(rstblvalues.Data("RightID"))# = >
 			//do ##class(IIBAENSEMBLE.Functions).TableUpdateOrInsertExpr(rstblvalues.Data("LeftID1"),rstblvalues.Data("LeftID2"),rstblvalues.Data("LeftID3"),rstblvalues.Data("RightID"),rstblvalues.Data("LookupID"))
 			//Req#2 - Phegel Change to use new SetRow (Update/Insert) and Audit SetRow on table
 			set tSC = ##class(IIBAENSEMBLE.LookupTable).SetRow(rstblvalues.Data("LookupID"),rstblvalues.Data("LeftID1"),rstblvalues.Data("LeftID2"),rstblvalues.Data("LeftID3"),rstblvalues.Data("RightID"), .Exists,.ItemId)
 			&html<#(Exists)#>
 			set EventData = ..GetRowEventDataById("ImportData()",ItemId)
 			do ..AuditRowChanges("Update/Insert row into: "_rstblvalues.Data("LookupID")_"("_ItemId_") Status:"_tSC_" Exists:"_Exists, EventData)
 		}
 		Do rstblvalues.Close()	
 	} elseif overwriteValues="" {
 		Set rstblvalues = ##class(%ResultSet).%New()
 		Do rstblvalues.Prepare("SELECT * from IIBAENSEMBLE.LookupTableImport where SessionID = '"_sessionID_"'")
 		Do rstblvalues.Execute()
 		While rstblvalues.Next() {
 			//&js< alert('#(rstblvalues.Data("RightID"))#'); >
 			set tSC = ##class(IIBAENSEMBLE.LookupTable).Insert(rstblvalues.Data("LookupID"),rstblvalues.Data("LeftID1"),rstblvalues.Data("LeftID2"),rstblvalues.Data("LeftID3"),rstblvalues.Data("RightID"), .Exists,.ItemId)
 			// Req#2 - Phegel - Audit Insert Event
 			&html<#(Exists)#>
 			set EventData = ..GetRowEventDataById("ImportData()",ItemId)
 			do ..AuditRowChanges("Insert row into: "_rstblvalues.Data("LookupID")_"("_ItemId_") Status:"_tSC_" Exists:"_Exists, EventData)
 		}
 		Do rstblvalues.Close()
 	}
 }
 // Req#2 - Phegel
 #DIM HeaderIDs as %ListOfDataTypes
 
 // Req#1  Phegel - Added function in LookupTableHeader to add the Header Values based on import.
 do ##class(IIBAENSEMBLE.LookupTableHeader).CreateLookupTableHeaderFromImport(sessionID, .HeaderIDs)
 
 // Req#2 - Phegel - Audit adding the new headers.
 for counter=1:1:HeaderIDs.Count()
 {
	set headerID = HeaderIDs.GetAt(counter)
	set audit = ..GetHeaderEventDataById("ImportData()",headerID)
	set desc = "CreateLookupTableHeaderFromImport() ID created: "_headerID
	do ..AuditHeaderChanges(desc,audit)
 }		
 
 Set rsdeltbl = ##class(%ResultSet).%New()
 Do rsdeltbl.Prepare("DELETE FROM IIBAENSEMBLE.LookupTableImport WHERE SessionID = '"_sessionID_"'")
 Do rsdeltbl.Execute()
 Do rsdeltbl.Close()
 	
 Quit "OK"
}

ClassMethod InsertData(importstream As %GlobalCharacterStream) As %String [ Language = objectscript ]
{
 
 if '..ValidateHeader(importstream.ReadLine()) {
 	Quit "File Header failed validation.  Please correct the format and try again."	
 }
 
 while 'importstream.AtEnd { 

	 set lCSV = ##class(IIBAENSEMBLE.Functions).ParseCSV(importstream.ReadLine())
 
	 set Table = $LI(lCSV,1)
	 set LeftID1 = $LI(lCSV,2)
	 set LeftID2 = $LI(lCSV,3)
	 set LeftID3 = $LI(lCSV,4)
	 set RightID = $LI(lCSV,5)
 
	 Set rset = ##class(%ResultSet).%New()
 			
	 If (LeftID2 '= "") & (LeftID3 '= "") {
	 	Do rset.Prepare("INSERT INTO IIBAENSEMBLE.LookupTableImport (SessionID, LeftID1, LeftID2, LeftID3, RightID, LookupID) VALUES ('"_%session.SessionId_"', '"_LeftID1_"', '"_LeftID2_"', '"_LeftID3_"', '"_RightID_"', '"_Table_"')")
	 } ElseIf LeftID2 '= "" {
	 	Do rset.Prepare("INSERT INTO IIBAENSEMBLE.LookupTableImport (SessionID, LeftID1, LeftID2, RightID, LookupID) VALUES ('"_%session.SessionId_"', '"_LeftID1_"', '"_LeftID2_"', '"_RightID_"', '"_Table_"')")
	 } Else {
	 	Do rset.Prepare("INSERT INTO IIBAENSEMBLE.LookupTableImport (SessionID, LeftID1, RightID, LookupID) VALUES ('"_%session.SessionId_"', '"_LeftID1_"', '"_RightID_"', '"_Table_"')")
	 }
 		
	 Do rset.Execute()
	 d rset.Close()
	 
 }
 
 Quit "OK"
}

/// Req#2 - Phegel Re-Write method to capture audit data and simplify code.
ClassMethod InsertSaveAction(Table As %String, LeftID1 As %String, LeftID2 As %String, LeftID3 As %String, RightID As %String) As %String [ Language = objectscript ]
{
 
 set exists = 0
 
 // Replace &nbsp; with normal space.
 set LeftID1 = ##class(IIBAENSEMBLE.Functions).StringReplace(LeftID1,$C(160)," ")
 set LeftID2 = ##class(IIBAENSEMBLE.Functions).StringReplace(LeftID2,$C(160)," ")
 set LeftID3 = ##class(IIBAENSEMBLE.Functions).StringReplace(LeftID3,$C(160)," ")
 set RightID = ##class(IIBAENSEMBLE.Functions).StringReplace(RightID,$C(160)," ")
 		
 set quitvalue = ##class(IIBAENSEMBLE.LookupTable).Insert(Table,LeftID1,LeftID2,LeftID3,RightID,.exists,.ItemID)
 
 /// Req#2 - PHegel - record Audit Event for InsertSaveAction

 set EventData = ..GetRowEventDataById("InsertSaveAction",ItemID)
  if (exists){
 	set quitvalue="exists"}
 else {
 	set quitvalue=ItemID}
 	
 set EventDesc = "Table: "_Table_" Inserted Item ID: "_ItemID_" Quit Value:"_quitvalue
 set tSC = ..AuditRowChanges(EventDesc,EventData)

 Quit quitvalue
}

// Req#4 - PHegel - delete lookup table method.

ClassMethod DeleteTable(Table As %String) As %String [ Language = objectscript ]
{
	#dim retVal as %String = ""
	set headerId = ##class(IIBAENSEMBLE.LookupTableHeader).GetIdByName(Table)
	set EventData = ..GetHeaderEventDataById("DeleteTable", headerId, 1)
	set tSC = ##class(IIBAENSEMBLE.LookupTableHeader).DeleteLookupTableHeaderByName(Table, 1)
	if ($$$ISERR(tSC)){
		set retVal = "Failed to delete '"_Table_"' lookup table."
	}else {
		set retVal = "Lookup table, '"_Table_"', deleted successfully."
	}
	set EventDesc = "Table: "_Table_" Quit Value:"_retVal
 	set tSC = ..AuditHeaderChanges(EventDesc, EventData)
	
	quit retVal
}

ClassMethod SortTable(Table As %String, sortby1 As %String, sortby2 As %String) As %String [ Language = objectscript ]
{
 	
 
 		set TableHTML = ""
 		set currentHeader = ##class(IIBAENSEMBLE.LookupTableHeader).GetObjectByName(Table, .tSC)
 		if ($$$ISERR(tSC))
 		{
	 		set TableHTML = TableHTML_"Error: "_$$$GETERRORCODE(tSC)_" - "_tsc
 		}
 		else {
	 		set TableHTML = TableHTML_..BuildHeaderHTML(currentHeader)
 		
	 		set TableHTML = TableHTML_"<tr class=""OddRow"" >"
	 		set TableHTML = TableHTML_"<TD nowrap><Input Type=""Text"" Name=""InsLeftID1"" id=""InsLeftID1"" Value=""""></TD>"
	 		set TableHTML = TableHTML_"<TD nowrap><Input Type=""Text"" Name=""InsLeftID2"" id=""InsLeftID2"" Value=""""></TD>"
	 		set TableHTML = TableHTML_"<TD nowrap><Input Type=""Text"" Name=""InsLeftID3"" id=""InsLeftID3"" Value=""""></TD>"
	 		set TableHTML = TableHTML_"<TD nowrap><Input Type=""Text"" Name=""RightID"" id=""RightID"" Value=""""></TD>"
	 		set TableHTML = TableHTML_"<td nowrap align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;"" ><a id='SaveNewRow' value='save' onclick=""InsertSave('"_Table_"');""/><img src='customimages/save.gif' alt='Save' /></a></td>"
	 		set TableHTML = TableHTML_"<td>&nbsp;</td>"
	 		set TableHTML = TableHTML_"</TR>"
 		
 				
	 		Set rset = ##class(%ResultSet).%New()
	 		Do rset.Prepare("SELECT ID, LeftID1, LeftID2, LeftID3, RightID FROM IIBAENSEMBLE.LookupTable WHERE LookupID = '"_Table_"' ORDER BY "_sortby1_", "_sortby2_"")
	 		Do rset.Execute()
	 		set i=2
	 		While (rset.Next()) {
	 		  	if i#2=0 {
	 			set TableHTML = TableHTML_"<tr class=""EvenRow"" id='Tablevalues.Id"_rset.Data("ID")_"' >"
	 			} Else {
	 			set TableHTML = TableHTML_"<tr class=""OddRow"" id='Tablevalues.Id"_rset.Data("ID")_"' >"
	 			}
 
	             if ((rset.Data("LeftID1")="DefaultValue")&&(rset.Data("LeftID2")="DefaultValue")&&(rset.Data("LeftID3")="DefaultValue")) {
	 	            //set DefValueHTML = DefValueHTML_rset.Data("RightID")
	             } Else {
	             
		            s LeftId1=##class(IIBAENSEMBLE.Functions).StringReplace(rset.Data("LeftID1")," ","&nbsp;") s:LeftId1="" LeftId1="&nbsp;"
					s LeftId2=##class(IIBAENSEMBLE.Functions).StringReplace(rset.Data("LeftID2")," ","&nbsp;") s:LeftId2="" LeftId2="&nbsp;"
					s LeftId3=##class(IIBAENSEMBLE.Functions).StringReplace(rset.Data("LeftID3")," ","&nbsp;") s:LeftId3="" LeftId3="&nbsp;"
					s RightId=##class(IIBAENSEMBLE.Functions).StringReplace(rset.Data("RightID")," ","&nbsp;") s:RightId="" RightId="&nbsp;"
				 
	 	            set TableHTML = TableHTML_"<TD nowrap>"_LeftId1_"</TD>"
	 	            set TableHTML = TableHTML_"<TD nowrap>"_LeftId2_"</TD>"
	 	            set TableHTML = TableHTML_"<TD nowrap>"_LeftId3_"</TD>"
	 	            set TableHTML = TableHTML_"<TD nowrap>"_RightId_"</TD>"
 	            
	 				set TableHTML = TableHTML_"<td nowrap align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;"" ><a id=edit"_rset.Data("ID")_" value='Edit' onclick=""rowEdit("_..QuoteJS(Table)_","_..QuoteJS(rset.Data("ID"))_");""><img src='customimages/edit.gif' alt='Edit' /></a>  </td>"
	 				set TableHTML = TableHTML_"<td nowrap align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;"" ><a id='del"_rset.Data("ID")_"' value='Delete' onclick=""RemoveRow("_..QuoteJS(Table)_","_..QuoteJS(rset.Data("ID"))_" );"" ><img src='customimages/trash_bold.gif' alt='Delete' /></a></td>"
	 	            set TableHTML = TableHTML_"</TR>"
	 	            set i=i+1
	             }
             
	             if $LENGTH(TableHTML) > 30000 {
	 		        &js<alert('This table is to big to sort - sorry!');>
	 		        set TableHTML = ""
	 		        Quit
	 	        }
         
	 		}
 		
	 		set TableHTML = TableHTML_"</TABLE>"
 		
 		
	 		//&js<document.getElementById('tablediv').innerHTML = document.getElementById('tablediv').innerHTML;>
 		}
 Quit TableHTML
}

ClassMethod ValidateHeader(FileHeader As %String) As %String [ Language = objectscript ]
{
 
 
 set lHeader = $LB("TableName","LeftID1","LeftID2","LeftID3","RightID")
 
 set lCSV = ##class(IIBAENSEMBLE.Functions).ParseCSV(FileHeader)
 
 Set ReturnVal=1
 
 for i=1:1:$LL(lHeader) { 
 	if ($LL(lCSV)'=$LL(lHeader))||($LI(lCSV,i)'=$LI(lHeader,i)){
 		Set ReturnVal=0
 	}
 }
 
 
 Quit ReturnVal
}

/// Delete Translation from LookupTableName = Table, ItemID to delete is RemoveItemID
ClassMethod DeleteTranslation(Table As %String, RemoveItemID As %String) As %String [ Language = objectscript ]
{
	set tSC = $$$OK		
	// Req#2 - Phegel - before action capture audit event data.
	set EventData = ..GetRowEventDataById("DeleteTranslation",RemoveItemID, 1)
	// Req#2 - Phegel - changed to use object item delete rather than SQL Delete.
	set tSC = ##class(IIBAENSEMBLE.LookupTable).%DeleteId(RemoveItemID)
	Q:$$$ISERR(tSC) tSC
	
	// Req#2 - Phegel - record audit event data.
	set EventDesc = "Table: "_Table_" Deleted Item ID: "_RemoveItemID
	set tSC = ..AuditRowChanges(EventDesc,EventData)
	Q tSC
}

ClassMethod ReloadRowData(Table As %String, ItemId As %String) As %String [ Language = objectscript ]
{
	
	
	
	set rs=##class(%ResultSet).%New()
	Do rs.Prepare("Select LeftID1, LeftID2, LeftID3, RightID from IIBAENSEMBLE.LookupTable Where ID="_ItemId_"")
	Do rs.Execute()
	Do rs.Next()
	
	s LeftId1=rs.Data("LeftID1")
	s:LeftId1="" LeftId1="&nbsp;"
	&js<document.getElementById('Tablevalues.Id'+#(ItemId)#).cells[0].innerHTML="#(LeftId1)#";>
	
	s LeftId2=rs.Data("LeftID2")
	s:LeftId2="" LeftId2="&nbsp;"
	&js<document.getElementById('Tablevalues.Id'+#(ItemId)#).cells[1].innerHTML="#(LeftId2)#";>
	
	s LeftId3=rs.Data("LeftID3")
	s:LeftId3="" LeftId3="&nbsp;"
	&js<document.getElementById('Tablevalues.Id'+#(ItemId)#).cells[2].innerHTML="#(LeftId3)#";>
	
	s RidhtId=rs.Data("RightID")
	s:RidhtId="" RidhtId="&nbsp;"
	&js<document.getElementById('Tablevalues.Id'+#(ItemId)#).cells[3].innerHTML="#(RidhtId)#";>
}

ClassMethod buildmodalImport() As %String [ Language = objectscript ]
{
	set sHTML=""
	set sHTML=sHTML_"<form id=""import"" method=""post"" target="""" action=""IIBASupport.csp?PageName=LookUp&Mode=Import"" enctype=""multipart/form-data"">"
	set sHTML=sHTML_"<div style=""margin-bottom: 10px;text-align:center""><h3>Import Lookup Table Data</h3></div>"
	set sHTML=sHTML_"<div style=""margin-left: 20px;margin-right: 20px;"">"
	set sHTML=sHTML_"The import file must be a csv file and must have a header row with the following columns.<br><b>TableName,LeftID1,LeftID2,LeftID3,RightID</b><p>"
	set sHTML=sHTML_"Enter the path and name of the import file:<br>"
	set sHTML=sHTML_"<input type=""file"" size=""50"" id=""importfile"" name=""importfile"" value=""""><p>"
	set sHTML=sHTML_"<input type=""radio"" name=""overwrite"" id=""overwritetrue"" value=""true"" OnClick=""$('overwritetrans').disabled=true;"" checked=true>Overwrite existing tables."
	set sHTML=sHTML_"<br><input type=""radio"" name=""overwrite"" id=""overwritefalse"" value=""false"" OnClick=""$('overwritetrans').disabled=false;"">Update existing tables."
	set sHTML=sHTML_"<br><Input Type=""checkbox"" Name=""overwritetrans"" ID=""overwritetrans"" DISABLED checked=true >Overwrite existing translation values."
	set sHTML=sHTML_"</div>"
	set sHTML=sHTML_"<div style=""margin-left: 20px;margin-top: 10px""><input type=""submit"" value=""Import"" onclick=""hm('modalImport');return true;""><button onclick=""hm('modalImport');return false;"">Cancel</button></div>"
	set sHTML=sHTML_"</form>"
	Quit sHTML
}

/// Req#2 - PHegel - New Method to Audit Row Changes
ClassMethod AuditRowChanges(Description As %String = "", EventData As %String = "") As %String
{
	set Source = "IIBAENSEMBLE.csp.LookupTableAdmin"
	set Type = "LookupTable"
	set Name = "Edit"
	set EventData = ..CleanupJson(EventData)
	if $L(Description)>128
		set Description = $E(Description,1,128)
	set tSC = $SYSTEM.Security.Audit(Source,Type,Name,EventData,Description)
	Quit tSC
}

/// Req#2 - PHegel - New Method to Get Event Data for Row Changes by ID.
ClassMethod GetRowEventDataById(pMethod As %String, ItemID As %String, isBefore As %Boolean = 0) As %String
{
	set obj = ##class(IIBAENSEMBLE.LookupTable).%OpenId(ItemID)
	if (obj'=""){
		set EventData = ..GetRowEventData(pMethod, obj, isBefore)	}
	else{
		Set EventData = "LookupTable Object ID: "_ItemID_" doesn't exist."}
	quit EventData
}

/// Req#2 - PHegel - New Method to Get Event Data for Row Changes with Obj.
ClassMethod GetRowEventData(pMethod As %String, ItemObj As IIBAENSEMBLE.LookupTable, isBefore As %Boolean = 0) As %String
{
	// Bug #4 - Fix JSON formating
	set valueType = $CASE(isBefore,0:"After",1:"Before")
	set EventData = $CASE(isBefore,0:",",1:"{")  
	set EventData = EventData_""""_valueType_"-changes"": {""method"":"""_pMethod_""","
	set EventData = EventData_"""LookupID"":"""_ItemObj.LookupID_""",""ID"":"""_ItemObj.%Id()_""","
	set EventData = EventData_"""LeftID1"":"""_ItemObj.LeftID1_""","
	set EventData = EventData_"""LeftID2"":"""_ItemObj.LeftID2_""","
	set EventData = EventData_"""LeftID3"":"""_ItemObj.LeftID3_""","
	set EventData = EventData_"""RightID"":"""_ItemObj.RightID_"""}"
	
	quit EventData
}

/// Req#2 - PHegel - New Method to Audit header changes
/// 06-02-2015 - NPellegrino - Audit table description is limited to 128 characters
ClassMethod AuditHeaderChanges(Description As %String = "", EventData As %String = "") As %String
{
	set Source = "IIBAENSEMBLE.csp.LookupTableAdmin"
	set Type = "LookupTableHeader"
	set Name = "Edit"
	set EventData = ..CleanupJson(EventData)
	// Limit description to 128 characters
	if $L(Description)>128
		set Description = $E(Description,1,128)
	set tSC = $SYSTEM.Security.Audit(Source,Type,Name,EventData,Description)
	Quit tSC
}

ClassMethod CleanupJson(EventData As %String) As %String
{
	if ($P(EventData,",",1)=""){
		set edList = $LFS(EventData,",")
		set edLen = $LL(edList)
		set newEdList = $LI(edList,2,edLen)
		set EventData = "{"_$LTS(newEdList)	
	}
	set EventData = EventData_"}"	
	QUIT EventData
}

/// Req#2 - PHegel - New Method to get Event data for header changes by Id
ClassMethod GetHeaderEventDataById(pMethod As %String, HeaderId As %String, isBefore As %Boolean = 0) As %String
{
	set obj = ##class(IIBAENSEMBLE.LookupTableHeader).%OpenId(HeaderId)
	set EventData = ..GetHeaderEventData(pMethod, obj, isBefore)	
	quit EventData
}

/// Req#2 - PHegel - New Method to get Event data for header changes
ClassMethod GetHeaderEventData(pMethod As %String, HeaderObj As IIBAENSEMBLE.LookupTableHeader, isBefore As %Boolean = 0) As %String
{
	// Bug #4 - Fix JSON formating
	set valueType = $CASE(isBefore,0:"After",1:"Before")
	set EventData = $CASE(isBefore,0:",",1:"{")  
	set EventData = EventData_""""_valueType_"-changes"": {""method"":"""_pMethod_""","
	set EventData = EventData_"""LookupTableName"":"""_HeaderObj.LookupTableName_""",""ID"":"""_HeaderObj.%Id()_""","
	set EventData = EventData_"""LookupTableDescription"":"""_HeaderObj.LookupTableDescription_""","
	set EventData = EventData_"""ColumnNameLeftID1"":"""_HeaderObj.ColumnNameLeftID1_""","
	set EventData = EventData_"""ColumnNameLeftID2"":"""_HeaderObj.ColumnNameLeftID2_""","
	set EventData = EventData_"""ColumnNameLeftID3"":"""_HeaderObj.ColumnNameLeftID3_""","
	set EventData = EventData_"""ColumnNameRightID"":"""_HeaderObj.ColumnNameRightID_""","
	set EventData = EventData_"""DefaultValue"":"""_HeaderObj.DefaultValue_""","
	set EventData = EventData_"""Resource"":"""_HeaderObj.Resource_"""}"
	
	quit EventData
}

}
