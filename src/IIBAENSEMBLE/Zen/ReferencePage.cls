Class IIBAENSEMBLE.Zen.ReferencePage Extends %ZEN.Component.page [ DependsOn = IIBAENSEMBLE.Zen.ToolkitHeader, ProcedureBlock ]
{

/// Displayed name of this page.
Parameter PAGENAME = "Reference";

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
<page xmlns:ZENToolKIT="http://www.intersystems.com/toolkitheader" title="IIBA Support Reference" id="maintitle">

<ZENToolKIT:ToolkitHeader id="title" title="Reference Table"/>

<hgroup id="bbArea" align="center">
<form id="ImportForm" hidden="true" align="left">
<html id="fileUpload" OnDrawContent="UploadHTML" hidden="false"/>
</form>
  <buttonBar id="editStuff" >
    <buttonBarItem icon="CustomImages/plus_bold.gif" caption="Add Related"
                   onclick="zenPage.UpdatePage('AddRelated')"  />
               
    <buttonBarItem icon="CustomImages/trash_bold.gif" caption="Delete Related"
                   onclick="zenPage.UpdatePage('DeleteRelated')"  />
                   
    <buttonBarItem icon="ext/examples/shared/icons/arrow-down.gif" caption="Export"
                   onclick="zenPage.UpdatePage('Export')" />
                 
    <buttonBarItem icon="ext/examples/shared/icons/arrow-up.gif" caption="Import"
                   onclick="zenPage.UpdatePage('Import')"  />
                   
   <buttonBarItem icon="CustomImages/Cancel.gif" caption="Exit"
                   onclick="zenPage.UpdatePage('Close')"  />
  </buttonBar>
</hgroup>

<vgroup id="mainv" hidden="false" width="auto" height="auto">
<dataGrid id="DataGrid" 
controllerId="json"
readOnly="false"
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
</page>
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
		 	
		}else if (pAction == "Save"){
		
			alert(pAction);
		
		 	
	 	}else if (pAction == "AddRelated"){
		 	var cell = zenPage.getComponentById('DataGrid');
    		var Column = prompt("Related Value Name:", "Enter Related Name");
    		if (Column == null || Column ==""){
	    		return true;
    		}else if (/[^a-zA-Z0-9]/.test( Column )){
	    			alert("Input is not alphanumeric");
	    			return false;
	    		}else{
       				zenPage.cell = this.AddRelated(Column);
					return true;
    				}
	
	 	}else if (pAction == "DeleteRelated"){
	 		var cell = zenPage.getComponentById('DataGrid');
    		var Column = prompt("Related Value Name:", "Enter Related Name");
    		if (Column == null || Column ==""){
	    		return true;   				
    		}else if (/[^a-zA-Z0-9]/.test( Column )){
	    			alert("Input is not alphanumeric");
	    			return false;
	    		}else{
		    		zenPage.cell = this.DeleteRelated(Column);
					return true;
    				}
    		
	 	}else if (pAction == "Export"){
		 	var value = location.href;
			var cell = zenPage.getComponentById('DataGrid');
			zenPage.cell = this.xRefExport(value);
			
	 	}else if (pAction == "Import"){
		  	if (window.File && window.FileReader && window.FileList && window.Blob) {
					var form = this.getComponentById('ImportForm');
  					form.setProperty('hidden',false);
  				} else {
  					alert('The File APIs are not fully supported by your browser.');
				}
					
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

ClassMethod Save() As %Status [ ZenMethod ]
{
	//Declare variables
	#dim tSC = $$$OK 
	
	Quit tSC
}

ClassMethod AddRelated(RValue As %String) [ ZenMethod ]
{
	&js<alert('#(RValue)#');>
}

ClassMethod DeleteRelated(RValue As %String) [ ZenMethod ]
{
	&js<alert('#(RValue)#');>
}

ClassMethod ImportData(pFileName As %CSP.CharacterStream, pFileType As %String, pFileSize As %Integer) As %Status [ ZenMethod ]
{
	quit $$$OK
	//Write to audit log.
	do ..AuditChanges("ImportData","User Import: "_pFileType,$Get(%session.Data("tTable")),pFileSize)
	
	#dim tSC As %Status = $$$OK
	s tValidOBJ = $CLASSNAME(pFileName)

	if $P(pFileType,".",2) = "csv"{
	
		s tStream = ##class(%GlobalCharacterStream).%New()
		
		if tValidOBJ = "%CSP.CharacterStream"{
			//For larger files use CopyFrom
			//Larger files will be passed as %CSP.CharacterStream reference to the page.
			d tStream.CopyFrom(pFileName)
		}else{
			//This is used with smaller files where the pFileName passes the value as a Text %String and will need to write to %GlobalCharacterStream
			d tStream.Write(pFileName)
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
		&js<alert("Not in csv format");>
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
	
	set rs = ..BuildReferenceTable(,"PValue")
	set rsCount = rs.GetColumnCount()
	set ColLines = ""
	for i=1:1:rsCount {
		set arrColNames(i)=rs.GetColumnName(i)
		set ColValues = rs.GetColumnName(i)
		set ColLines = ColLines_$C(34)_##class(IIBAENSEMBLE.Functions).StringReplace(ColValues,$C(34),$C(34,34))_$C(34)_","
		
	}
	d file.WriteLine(ColLines)
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
	
	Quit xRefTable_".csv"
}

ClassMethod BuildReferenceTable(Output pSC As %Status) As %ResultSet [ ZenMethod ]
{
 	set tRefId = %request.Get("ID")
  	if tRefId = ""{s tRefId = $Get(%session.Data("tRefId"))}
  	
  	set rs = ""
  	set pSC = $$$OK
  	
	  
	set sql = ""
 
	set rs = ##class(%ResultSet).%New("%DynamicQuery:SQL")   
	set pSC = rs.Prepare(sql)
	set pSC = rs.Execute()
	
	set %session.Data("tRefId") = tRefId
	  	
  Quit rs
}

Method GetGridData(ByRef pParameters, Output pMetaData, Output pData) As %Status
{
 #dim tSC As %Status = $$$OK
 
 set rs = ..BuildReferenceTable()
 set tSC = ..ParseHeaderString(rs,.pMetaData)
 set tSC = ..ParseDataString(rs,.pData)
 
 
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
