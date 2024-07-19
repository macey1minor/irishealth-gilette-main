Class IIBAENSEMBLE.Zen.xRefAttrPage Extends %ZEN.Component.page [ DependsOn = IIBAENSEMBLE.Zen.ToolkitHeader, ProcedureBlock ]
{

/// Displayed name of this page.
Parameter PAGENAME = "Attributes";

Parameter DOMAIN = "ZENToolKIT";

Property Table As %String;

XData Style
{
<style type="text/css">


	

#bbArea {
  background:	lightgray;
  background-image: url(images/grad-halfblue-10x30.png);
  background-repeat:repeat-x;
}


#DataGrid
 {
 	width: auto;
    height: 660px;
    
      
 }



</style>
}

XData Contents [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<page xmlns:ZENToolKIT="http://www.intersystems.com/toolkitheader" title="IIBA Support Attributes" id="maintitle">

<ZENToolKIT:ToolkitHeader id="title" title="Attributes Table"/>

<hgroup id="bbArea" align="center">
<form id="ImportForm" hidden="true" align="left">
<html id="fileUpload" OnDrawContent="UploadHTML" hidden="false"/>
</form>
  
  <buttonBar id="editStuff" >
    <buttonBarItem icon="CustomImages/plus_bold.gif" caption="Add Column" resource="xRefAttrUpdate"
                   onclick="zenPage.UpdatePage('AddColumn')"  />
               
    <buttonBarItem icon="CustomImages/trash_bold.gif" caption="Delete Column" resource="xRefAttrUpdate"
                   onclick="zenPage.UpdatePage('DeleteColumn')"  />
                   
    <buttonBarItem icon="ext/examples/shared/icons/arrow-down.gif" caption="Export"
                   onclick="zenPage.UpdatePage('Export')" />
                 
    <buttonBarItem icon="ext/examples/shared/icons/arrow-up.gif" caption="Import"
                   onclick="zenPage.UpdatePage('Import')"  />
                   
   <buttonBarItem icon="CustomImages/Cancel.gif" caption="Exit"
                   onclick="zenPage.UpdatePage('Close')"  />
  </buttonBar>
  <spacer width="5px"/>
  <checkbox caption="Read Only" value="1" align="left" onclick="zenPage.SwitchEdit(zenThis);"/>
  
</hgroup>

<vgroup id="mainv" hidden="false" width="auto" height="auto">
<dataGrid id="DataGrid" 
controllerId="json"
readOnly="true"
selectMode="cells"
currRow=""
currColumn=""
style="text-align: left;"
onchange="zenPage.UpdatePage('Save',zenThis)"
pageSize="30"
multiSelect="true"
currPage="1"
onnotifyView=""
filterKey=""
valueColumn="1"

>

</dataGrid>
<jsonProvider id="json" OnGetArray="GetGridData">
</jsonProvider>
</vgroup>

<hgroup id="utils" hidden="false">
<spacer width="1px"/>
<text id="getPageSiz" value="30" />
<button id="pagerBtn" caption="Ok" onclick="zenPage.UpdatePage('ChgPageSiz',zenThis)"/>
</hgroup>
<html id="edtMode" containerStyle="color: red;" align="center" hidden="true">***Edit Mode***</html>
</page>
}

ClientMethod SwitchEdit(id) [ Language = javascript ]
{
	var trigger = id.value;
	
	zenPage.getComponentById('edtMode').setProperty('hidden',trigger);
	zenPage.getComponentById('DataGrid').setProperty('readOnly',trigger);
}

ClientMethod Alert(message As %String) [ Language = javascript ]
{
	alert(message);
}

ClientMethod UpdatePage(pAction As %String, grid) [ Language = javascript ]
{
	 if (pAction == "Refresh"){
	 		location.reload();
	 		
	 	}else if (pAction == "Close"){
		  	window.close();
		 	
		}else if (pAction == "readOnly"){
			//using this function will disable the dbl click sort on header columns
			var c = grid.getCurrColumn();
		 	var readOnly = grid.getProperty('readOnly');
		 	var currPage = grid.getProperty('currPage');
		 	if (c <=2){
			 	grid.setProperty('id',true);
		 	}else{
			 	grid.setProperty('readOnly',false);
		 	}
	 	}else if (pAction == "Save"){
		
		 	//valueColumn property is maintained between filtering and paging.
		 	var row = grid.getCurrRow();
		 	var col = grid.getCurrColumn();
		 	grid.setProperty('valueColumn',1);
			var PValue = grid.getRowValue(row);
			grid.setProperty('valueColumn',col);
			var value = grid.getRowValue(row);
			grid.setProperty('valueColumn',2)
			var RValue = grid.getRowValue(row);
			
			
			if (col <= 2){
				alert("Cannot edit Principal or Related Values.");
				location.reload();
			}else{
				this.Save(col-2,value,RValue,PValue);
			}
		}else if (pAction == "ChgPageSiz"){
		 	
		 	var bttn = zenPage.getComponentById('getPageSiz');
		 	var dataGrid = zenPage.getComponentById('DataGrid');
		 	var value = bttn.getValue();
		 	if (/[^0-9]/.test( value )){
			 	alert("Numeric Values Only");
			 	return false;
		 	}else{
		 		dataGrid.setProperty('pageSize',value);
				dataGrid.setProperty('currPage',1);
				return true;
		 	}
		
		 	
	 	}else if (pAction == "AddColumn"){
		 	var cell = zenPage.getComponentById('DataGrid');
    		var Column = prompt("Column Name:", "Enter Column Name");
    		if (Column == null || Column ==""){
	    		return true;
    		}else if (/[^a-zA-Z0-9]/.test( Column )){
	    			alert("Input is not alphanumeric");
	    			return false;
	    		}else{
       				zenPage.cell = this.AddColumnCLS(Column);
					return true;
    				}
	
	 	}else if (pAction == "DeleteColumn"){
	 		var cell = zenPage.getComponentById('DataGrid');
    		var Column = prompt("Column Name:", "Enter Column Name");
    		if (Column == null || Column ==""){
	    		return true;   				
    		}else if (/[^a-zA-Z0-9]/.test( Column )){
	    			alert("Input is not alphanumeric");
	    			return false;
	    		}else{
		    		zenPage.cell = this.DeleteColumnCLS(Column);
					return true;
    				}
    		
	 	}else if (pAction == "Export"){
		 	var value = location.href;
			var cell = zenPage.getComponentById('DataGrid');
			zenPage.cell = this.attrExport(value);
			
	 	}else if (pAction == "Import"){
		  	if (window.File && window.FileReader && window.FileList && window.Blob) {
					var form = this.getComponentById('ImportForm');
  					form.setProperty('hidden',false);
  				} else {
  					alert('The File APIs are not fully supported by your browser.');
				}
					
	 	}else if (pAction == "Filter"){
		 	cell = zenPage.getComponentById('DataGrid');
			value = cell.getProperty('currColumn');
			zenPage.cell = this.SetFilter(value);
						 		
	 	}else{
		 	alert("Function Does Not Exist!");
		 	window.close();
	 }
}

ClassMethod UploadHTML(pSeed As %String) As %Status [ ZenMethod ]
{
	//built in csp, not sure if/where zen stores mime data for the file reader. 
	&html<
	<input type="file" id="fileinput" accept="application/csv" />
	<script type="text/javascript">
 	 function readSingleFile(evt) {
    //Retrieve the first (and only!) File from the FileList object
    	var f = evt.target.files[0]; 

    	if (f) {
     	 var r = new FileReader();
     	 r.onload = function(e) {
	     	var contents = e.target.result;
	      	#server(..ImportData(contents,f.name,f.size))#;
             
      }
      //AsText CSP will automatically place in a stream if needed. 
      //BinaryString does not seem to work.
      r.readAsText(f);
   
    } else { 
      alert("Failed to load file");
    }
  }

    document.getElementById('fileinput').addEventListener('change', readSingleFile, false);
	</script>>
 	q $$$OK
}

ClassMethod Save(pHeader As %Integer, pValue As %String, pRValue As %String, pPValue As %String) As %Status [ ZenMethod ]
{
	//Declare variables
	#dim tSC = $$$OK 
	#dim tTable As %String = $Get(%session.Data("tTable"))
	#dim tResource as %String = $Get(%session.Data("tResource"))
	
	//&js<document.getElementById('DataGrid').rows['1'].cells['1'].setAttribute('bgColor', 'red');>
	
		 	          	      	
	if ((##class(%SYSTEM.Security).Check(tResource, "WRITE"))||(tResource = ""))
	{
		
		//Write to audit log.
		if pValue = ""{do ..AuditChanges("Save","User Delete",$Get(%session.Data("tTable")),,pRValue,pPValue)}else{do ..AuditChanges("Save","User Save: "_pValue,$Get(%session.Data("tTable")),,pRValue,pPValue)}
		

		#dim tRow As %ResultSet
		#dim tHeader As %String	= ""
		#dim tId As %Integer = 0
		#dim tAId As %Integer = 0
		#dim tRefId As %Integer = 0
		#dim tRId As %Integer = 0
		
		s tRefId = $Get(%session.Data("tRefId"))
		
		s tPosition = $L(tTable,".")-2
		s tTableSQL = $REPLACE(tTable,".","_",1,tPosition)
			
		&sql(SELECT %ID into :tRId FROM IIBAENSEMBLE_Reference.RelatedType WHERE %ID = :tRefId AND attrClass = :tTable)
		&sql(SELECT attrId, IIBAENSEMBLE_Reference.RelatedValue.%ID into :tAId, :tId FROM IIBAENSEMBLE_Reference.RelatedValue JOIN IIBAENSEMBLE_Reference.PrincipalValue ON IIBAENSEMBLE_Reference.RelatedValue.PrincipalValue = IIBAENSEMBLE_Reference.PrincipalValue.%ID AND PValue = :pPValue AND RValue = :pRValue  AND RelatedType = :tRId)
			
		//Build objects and save values.
		s rs = ##class(%ResultSet).%New()
		s tHeader = rs.Prepare("SELECT * FROM "_tTableSQL_"")
		s tHeader = rs.Execute()
		s tHeader = rs.GetColumnHeader(pHeader)
			
		if $CLASSMETHOD(tTable,"%ExistsId",tAId) '=0 {
			
			//&js<alert("#(pHeader_"|"_pValue_"|"_pRValue_"|"_pPValue_"|"_tAId_"|"_tId)#");>
			s tRow = $CLASSMETHOD(tTable,"%OpenId",tAId)
			s $PROPERTY(tRow,tHeader) = pValue
			s tSC = tRow.%Save()		
			
		}else{
			
			//&js<alert("new"+"#(pHeader_"|"_pValue_"|"_pRValue_"|"_pPValue_"|"_tAId_"|"_tId)#");>
			s tRow = $CLASSMETHOD(tTable,"%New")
			s $PROPERTY(tRow,tHeader) = pValue
			s tSC = tRow.%Save()
			
			s tRelSys = ##class(IIBAENSEMBLE.Reference.RelatedValue).%OpenId(tId)
			
			s tRelSys.attrId = tRow.%Id()
			s tSC = tRelSys.%Save()
							
		}
		
		k %session.Data("tAId")
	}
	else
	{
		&js<
		alert("Sorry, you are not allowed to edit this xRef Attribute {#(tTable)#} table");
		location.reload();>
	}
	q tSC
}

ClassMethod AddColumnCLS(cName As %String) [ ZenMethod ]
{
	//Write to audit log.
	do ..AuditChanges("AddColumnCLS","User Add Column: "_cName,$Get(%session.Data("tTable")))
	
	s tTable = $Get(%session.Data("tTable"))
	s tPosition = $L(tTable,".")-2
	s tTable = $REPLACE(tTable,".","_",1,tPosition)
	s sql = "ALTER TABLE "_tTable_" ADD "_cName_" %String"
	s rs = $CLASSMETHOD("%SQL.Statement","%ExecDirect",,sql)
	
	&js<location.reload();>
	q
}

ClassMethod DeleteColumnCLS(cName As %String) [ ZenMethod ]
{
	//Write to audit log.
	do ..AuditChanges("DeleteColumnCLS","User Delete Column: "_cName,$Get(%session.Data("tTable")))
	
	s tTable = $Get(%session.Data("tTable"))
	s tPosition = $L(tTable,".")-2
	s tTable = $REPLACE(tTable,".","_",1,tPosition)
	s sql = "ALTER TABLE "_tTable_" DROP COLUMN "_cName_""
	s rs = $CLASSMETHOD("%SQL.Statement","%ExecDirect",,sql)
	
	&js<location.reload();>
	q
}

ClassMethod ValidateAttrHeader(pHeader As %String) As %String [ ZenMethod ]
{
	#dim tTable As %String = ""
	#dim rsCount As %Integer = 0
	#dim tReturn As %Boolean = 1
	#dim tProp As %String = ""
	#dim c As %Integer = 0
	#dim tHeader As %String = ""
	#dim tError As %String = ""
	
	s tTable = $Get(%session.Data("tTable"))
	s rs = ##class(%ResultSet).%New()
	s tPosition = $L(tTable,".")-2
	s tTable = $REPLACE(tTable,".","_",1,tPosition)
	s tHeader = rs.Prepare("SELECT * FROM "_tTable_"")
	s tHeader = rs.Execute()  	
	s rsCount = rs.GetColumnCount()
	s pHeader = $Replace(pHeader,$CHAR(34),"")
	
    if $L(pHeader,",")-2 '= rsCount {
		s tReturn = 0
		if $P(pHeader,",",rsCount+3) '= ""{
			s tError = " on: "_$P(pHeader,",",rsCount+3)
		}else{
			s tError = " after: "_$P(pHeader,",",rsCount+2)
		}
	}else{
	
	for c=1:1:rsCount{
		
		s tProp = $P(pHeader,",",c+2)
		s tHeader = rs.GetColumnHeader(c)
		
		if tProp'=tHeader{
			s tReturn = 0
			s tError = " on: "_tProp_"/"_tHeader
			q
			}
	}
	}
	return tReturn_","_tError
	q
}

ClassMethod ImportData(pFileName As %CSP.CharacterStream, pFileType As %String, pFileSize As %Integer) As %Status [ ZenMethod ]
{
	//Write to audit log.
	do ..AuditChanges("ImportData","User Import: "_pFileType,$Get(%session.Data("tTable")),pFileSize)
	
	#dim tSC As %Status = $$$OK
	s tValidOBJ = $CLASSNAME(pFileName)

	if $P(pFileType,".",$L(pFileType,".")) = "csv"{
	
		s tStream = ##class(%GlobalCharacterStream).%New()
		
		if tValidOBJ = "%CSP.CharacterStream"{
			//For larger files use CopyFrom
			//Larger files will be passed as %CSP.CharacterStream reference to the page.
			d tStream.CopyFrom(pFileName)
		}else{
			//This is used with smaller files where the pFileName passes the value as a Text %String and will need to write to %GlobalCharacterStream
			d tStream.Write(pFileName)
		}
	
	//validate header before the data is processed.
	s tValidate = ..ValidateAttrHeader(tStream.ReadLine())
		
	if $P(tValidate,",",1)'=1{
		&js<alert("Header validation failed"+"#($P(tValidate,",",2))#");> q
		}
	
	
	//start data processing	
	s count = 0
	
	While 'tStream.AtEnd{
		s tLine = tStream.ReadLine()
		s tList = ##class(IIBAENSEMBLE.Functions).ParseCSV(tLine)
		s count = count +1
			
		if (count=1)
			{
			s colName = tList
			s colCount = $LL(tList)
			
			}
		
		for c=3:1:colCount {
	  
	 	       s pValue = $LG(tList,1)
	 	       s rValue = $LG(tList,2)
	 	       	 	         	    
	 	       		if (count >=1){
	 	          	     		
		          	    	s cellVal = $LG(tList,c)
	 	          	    	s colNum = c - 2
	 	          	      	if ((rValue '= "") && (pValue '= "")){
		 	          	      	//&js<alert("#(colNum)#"+","+"#(cellVal)#"+","+"#(rValue)#"+","+"#(pValue)#");>
		 	          	      	do ..Save(colNum,cellVal,rValue,pValue)
		 	          	      	
		 	          	      	}else{
			 	          	      	q
			 	          	      	}
	 	          	     	         	    
	 	          	    		}
							
							}
  	
					
								
	}
	
		
		&js<alert("Complete"); location.reload();>
			
			q $$$OK
	}else{
		&js<alert("Not in csv format: #($P(pFileType,".",$L(pFileType,".")))#");>
		q $$$OK
		
	}
}

ClassMethod attrExport(sRTID As %String) As %String [ ZenMethod ]
{
	//Write to audit log.
	do ..AuditChanges("attrExport","User Export: "_$Get(%session.Data("tTable")))
	
	#dim rs As %ResultSet
	s xRefTable = $Get(%session.Data("tTable"))
	
	//Use RefDownload to build download file with table name
	&js<
	var filename = "#(xRefTable)#"+".csv";
	//alert(filename);
	window.location = 'IIBAENSEMBLE.csp.RefDownload.cls?filename='+filename;
	>
	
	//Build file in manager directory
	s EnsSysDir = ##class(%File).ParentDirectoryName(##class(%File).ManagerDirectory())
	s filetimestamp = ##class(Ens.Util.Time).FormatDateTime("%Y%m%d%H%M%S")
	//s xRefExportsDir = ##class(%File).NormalizeDirectory(EnsSysDir_"xRefExports")
	
	
	if '##class(%File).DirectoryExists(EnsSysDir_"xRefExports") { 
		
		d ##class(%File).CreateDirectory(EnsSysDir_"xRefExports")
		 
	}

	s file = ##class(%File).%New(EnsSysDir_"xRefExports\"_xRefTable_".csv")
	d file.Open("WSN")
	
	set rs = ..BuildAttrTable(,"PValue")
	set rsCount = rs.GetColumnCount()
	set ColLines = ""
	for i=1:1:rsCount {
		
		set arrColNames(i)=rs.GetColumnName(i)
		set ColValues = rs.GetColumnName(i)
		set ColLines = ColLines_$C(34)_##class(IIBAENSEMBLE.Functions).StringReplace(ColValues,$C(34),$C(34,34))_$C(34)_","
		
	}
	if $P(ColLines,",",$L(ColLines,","))=""{s ColLines = $EXTRACT(ColLines,0,*-1)}
	d file.WriteLine(ColLines)
	While rs.Next() {
		set strLine = ""
		
		for i=1:1:rsCount {
			
			set strLine=strLine_$C(34)_##class(IIBAENSEMBLE.Functions).StringReplace(rs.Data(arrColNames(i)),$C(34),$C(34,34))_$C(34)_","
		
		}
		
		if $P(strLine,",",$L(strLine,","))=""{s strLine = $EXTRACT(strLine,0,*-1)}
		
		d file.WriteLine(strLine)
	
	}
	
	
	do rs.Close()
	d file.Close()
	
	kill file
	
	Quit xRefTable_".csv"
}

ClassMethod SetFilter(sel As %String) [ ZenMethod ]
{
	set %session.Data("tFilter") = sel
}

ClassMethod BuildAttrTable(Output pSC As %Status, ID As %String) As %ResultSet [ ZenMethod ]
{
	
	//dynamic sql is the preferred method for building tables. 
	
	#dim tAcls As %String = "" 
	#dim tPId As %String = ""
	#dim tPsys As %String = ""
	#dim tRsys As %String = ""
	#dim tTable As %String = ""
	#dim tResource as %String = ""
			
  	set tRefId = %request.Get("ID")
  	if tRefId = ""{s tRefId = $Get(%session.Data("tRefId"))}
  	
  	set rs = ""
  	set pSC = $$$OK
  
  	&sql(select attrClass into :tAcls from IIBAENSEMBLE_Reference.RelatedType where %ID = :tRefId)
	&sql(select PrincipalType into :tPId from IIBAENSEMBLE_Reference.RelatedType where %ID = :tRefId)
	&sql(select System, Resource into :tPsys, :tResource from IIBAENSEMBLE_Reference.PrincipalType where %ID = :tPId)
	&sql(select System into :tRsys from IIBAENSEMBLE_Reference.RelatedType where attrClass != "" and %ID = :tRefId)
	
	//search and replace to allow correct sql naming.
	s tPosition = $L(tAcls,".")-2
	s tTable = $REPLACE(tAcls,".","_",1,tPosition)
	
	
	  
	set sql = "SELECT PValue As "_tPsys_", RValue As "_tRsys_","_tTable_".*"
	set sql = sql_"FROM IIBAENSEMBLE_Reference.PrincipalValue "
	set sql = sql_"JOIN IIBAENSEMBLE_Reference.RelatedValue ON IIBAENSEMBLE_Reference.PrincipalValue.%ID = IIBAENSEMBLE_Reference.RelatedValue.PrincipalValue "
	set sql = sql_"JOIN IIBAENSEMBLE_Reference.RelatedType ON IIBAENSEMBLE_Reference.RelatedValue.RelatedType = IIBAENSEMBLE_Reference.RelatedType.%ID "
	set sql = sql_"AND attrClass = '"_tAcls_"' LEFT JOIN "_tTable_" ON IIBAENSEMBLE_Reference.RelatedValue.attrID = "_tTable_".%ID order by PValue"
 
	set rs = ##class(%ResultSet).%New("%DynamicQuery:SQL")   
	set pSC = rs.Prepare(sql)
	set pSC = rs.Execute()
	
	
	set %session.Data("tTable") = tAcls
	set %session.Data("tResource") = tResource
	set %session.Data("tRefId") = tRefId
	  	
  Quit rs
}

Method GetGridData(ByRef pParameters, Output pMetaData, Output pData) As %Status
{
 #dim tSC As %Status = $$$OK
 
 set rs = ..BuildAttrTable(,"PValue")
 set tSC = ..ParseHeaderString(rs,.pMetaData)
 set tSC = ..ParseDataString(rs,.pData)
 set ..Table = $Get(%session.Data("tTable"))
 
 Quit tSC
}

ClassMethod ParseHeaderString(pResultSet As %ResultSet, Output pHeader) As %Status
{
	#dim tSC as %Status = $$$OK
	set cnt = 1
	set cnt1 = pResultSet.GetColumnCount()
	set tCol = ""
	
	for c=1:1:cnt1
	{
		set tCol = tCol_pResultSet.GetColumnHeader(c)
		if c'=cnt1
		{
			set tCol = tCol_$CHAR(2)
		}
							
	}
			
	set pHeader = $LFS(tCol,$CHAR(2))					
	Quit tSC
}

ClassMethod ParseDataString(pResultSet As %ResultSet, Output pData) As %Status
{
	#dim tSC as %Status = $$$OK
	set cnt = 1
	set cnt1 = pResultSet.GetColumnCount()
	set tCol = ""
	
	While pResultSet.Next()
	{
		
		s tList = ""
		for c=1:1:cnt1
		{
			//get each line of the resultset
			set tList = tList_pResultSet.GetData(c)
			if c'=cnt1
			{
				set tList = tList_$CHAR(3)
			}
							
		}
		set pData(cnt) = $LFS(tList,$CHAR(3))
		set cnt = cnt +1	
	}	
	
	Quit tSC
}

ClassMethod AuditChanges(method As %String, Description As %String = "", pTable As %String = "", pfilesize As %String = "", pValue As %String = "", rValue As %String = "")
{
		
	if $L(Description)>128
		set Description = $E(Description,1,128)
	set Source = "IIBAENSEMBLE.Zen.xRefAttrPage"
	set Type = "TablexRefAttr"
	set Name = "Edit"
	set EventData = "{""method"":"""_method_""",""PValue"":"""_pValue_""",""RValue"":"""_rValue_""",""Table"":"""_pTable_""",""FileSize"":"""_pfilesize_"""}"
	d $SYSTEM.Security.Audit(Source,Type,Name,EventData,Description)
	//JSON---{"method":"rowEditSave","PTName":"MyRefTable","PTId":"1","RTSystem":"","RTId":"","PValue":"dtest","PVId":"50","RValue":"","RVId":""}
}

}
