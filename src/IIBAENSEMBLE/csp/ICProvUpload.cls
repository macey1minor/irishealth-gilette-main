/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.csp.ICProvUpload Extends %CSP.Page [ ProcedureBlock ]
{

ClassMethod CheckPermissions()
{
	set Allowed = 0
	if ##class(%SYSTEM.Security).Check("%All") = "READ,WRITE,USE" { set Allowed = 1 }
	
	Quit Allowed
}

ClassMethod jsfunction()
{
  &html<
   <script language=javascript>
	<!--
	function Initialize()
	{
		CheckAccess()
	}
	function Hello() {
		alert('Hello');
	}

	
	function GetProviderFile() {
		
		var line,i,v;
		
		
		document.getElementById('StatusMessage').innerHTML=':  Load File....';
		
		var cdl=new ActiveXObject("UserAccounts.CommonDialog");

  		cdl.Filter="CSV Files (*.csv)|*.csv|All Files|*.*";
  		cdl.ShowOpen();
  		
  		if (cdl.Filename != "") {
			

			var jsFileName = cdl.Filename;

			document.getElementById('ProviderFileName').value=jsFileName;
			
			PreviewProviderFile();
		
		    // alert('File: '+jsFileName)
  		}
	}
	
function PreviewProviderFile() {
		
	var line,i,v;
		
	document.getElementById('StatusMessage').innerHTML=':  Load File....';
			
  	var jsFileName = document.getElementById("ProviderFileName").value;
  	
  	// alert('File: '+jsFileName);
  	
  	if (jsFileName != "" ) {
  		var fso = new ActiveXObject("Scripting.FileSystemObject");
  		
  		if ( fso.FileExists(jsFileName) ) {
	  		
	  		var PreviewText='<BR>File Preview  <i>(first 10 rows)</i><BR><Table Border=1 NOWRAP>';

	  		
  			var ObjTextFile=fso.OpenTextFile(jsFileName,1);
  		
  			// alert("opened the file");
  		
  			var BadLineCount=0;
  			var RecordCount=0;
  			var ProviderHeader="";
  			var reg=/^\s*$/;
  			while ( ! ObjTextFile.AtEndOfStream  ) {
				line=ObjTextFile.ReadLine();
	 			if (! reg.exec(line)) {
	  				RecordCount++;
	  				
	  				if ( RecordCount > 11 ) {
		  				break;
	  				}
	  				
	  				if ( RecordCount == 1 ) {
						// alert("first line: "+line);
						
						IsValid=#server(..ValidateHeader(line))#;
		  				if ( IsValid != 0 ) {
			  			
		  					alert("The Provider Upload file could not be processed.\nThe following header(s) are not valid: "+IsValid.replace(/0;/,""));
			  				break;
		  				}
		  				ProviderHeader=#server(..FormatHeader(line))#;
		  				PreviewText=PreviewText+ #server(..PreviewHTML(line))#;
		  				
	  				} else {
  						// alert("line "+RecordCount+": "+line);
  						x=#server(..ValidateData(ProviderHeader,line,"N"))#;
  						PreviewText=PreviewText+ #server(..PreviewHTML(line))#;
	  				}
	  			}
  			}
  		
  		
  			// document.getElementById('StatusMessage').innerHTML=CompleteMsg;
  			PreviewText=PreviewText+"</Table>";
  			// alert("Preview Text: ");
  			document.getElementById('Preview').innerHTML=PreviewText;
  			// document.getElementById('Preview').innerHTML="Test";
  		
  			fso.close;
  		
  		} else {
	  		alert("File does not exist");
  		}
  	}
  		
  		
  				
}
	
	function ProcessProviderFile() {
		
	var line,i,v;
		
	document.getElementById('StatusMessage').innerHTML=':  Load File....';
			
  	var jsFileName = document.getElementById("ProviderFileName").value;
  	
  	// alert('File: '+jsFileName);
  	
  	if (jsFileName != "" ) {
  		var fso = new ActiveXObject("Scripting.FileSystemObject");
  		
  		if ( fso.FileExists(jsFileName) ) {
  			var ObjTextFile=fso.OpenTextFile(jsFileName,1);
 		
  			// alert("opened the file");
  		
  			var BadLineCount=0;
  			var RecordCount=0;
  			var ProviderHeader="";
  			var reg=/^\s*$/;
  			while ( ! ObjTextFile.AtEndOfStream  ) {
				line=ObjTextFile.ReadLine();
	 			if (! reg.exec(line)) {
	  				RecordCount++;
	  				if ( RecordCount == 1 ) {
						// alert("first line: "+line);
						
						IsValid=#server(..ValidateHeader(line))#;
		  				if ( IsValid != 0 ) {
			  			
		  					alert("The Provider Upload file could not be processed.\nThe following header(s) are not valid: "+IsValid.replace(/0;/,""));
			  				break;
		  				}
		  				ProviderHeader=#server(..FormatHeader(line))#;
	  				} else {
  						// alert("line "+RecordCount+": "+line);
  						
  						x=#server(..ValidateData(ProviderHeader,line,"Y"))#;
  						
  						if (x == "") {

  						} else {
	  						BadLineCount++;
  						}
	  				}
	  			}
  			}
  		
  			RecordCount--;
  			var CompleteMsg="<BR><BR><B>Processing Complete</B><BR>File: "+jsFileName+"<BR>  Records Processed: "+RecordCount;
  			var AlertMessage='Processing Complete '+jsFileName+'\nRecords Processed: '+RecordCount;
  			if (BadLineCount > 0 ) {
	 			CompleteMsg=CompleteMsg+"<BR>  Records Missing Data: "+BadLineCount;
	  			CompleteMsg=CompleteMsg+'<BR> <a href="/csp/iibasupport/IIBAWFTasks.csp" >Error Workflow</a>';
	  			AlertMessage=AlertMessage+'\nRecords Missing Data: '+BadLineCount
  			}
  			alert(AlertMessage);
  		
  			document.getElementById('StatusMessage').innerHTML=CompleteMsg;
  		
  			fso.close;
  		
  		} else {
	  		alert("File does not exist");
  		}
  	}
  		
  		
  				
}

function CheckAccess(flag) {
	
	flag=#server(..GetAccessInfo())#;
	
	// alert('Testing access');
	if (flag==0) {
		alert("You do not have access");
		location.href='IIBATaskMgmt.csp';
	}
	
}


function downloadheaders() {
	
	var line=#server(..GetHeaders())#;
	
	var cdl=new ActiveXObject("UserAccounts.CommonDialog");

  	cdl.Filter="Text Files (*.csv)|*.csv|All Files|*.*";
  	cdl.ShowOpen();
  		
  	if (cdl.Filename != "") {
	  	
	  	if ( cdl.FileName.match(".")!=null ) {
		  	cdl.FileName=cdl.FileName+".csv";
	  	}
	  	
	  	
	  	var fso = new ActiveXObject("Scripting.FileSystemObject");
	  	var newFileObject = fso.OpenTextFile(cdl.Filename, 8, true);
	  	newFileObject.WriteLine(line);
	  	newFileObject.Close();
  	}
	
	//location.href='IIBASupport.csp?PageName=ICProvUpload';
}	
  -->
   </script>
  >
}

ClassMethod html()
{
    // <a class="DetailCommand" target="_top" href='IIBASupport.csp?PageName=ICProvUpload&Mode="DownloadHeaders"'><nobr>&nbsp;Download&nbsp;Headers&nbsp;</nobr></A>
    &html<
    <table><tr><td class="LayoutContentCol" width="5%" ><br><div class="DetailCommand">
	
	<a class="DetailCommand" target="_top" onclick='downloadheaders()'><nobr>&nbsp;Download&nbsp;Headers&nbsp;</nobr></A>
	</div></td></tr></table><BR>
    >
    Set Mode=%request.Get("Mode")
	Set ColumnHeaders=""
	
	If (%request.Get("Mode")="DownloadHeaders") {
		w "<HR>Test<HR></BR>"
		Set rs = ##class(%ResultSet).%New()
		Do rs.Prepare("Select Name from %Dictionary.PropertyDefinition where parent = 'ICOrderResult.ProviderUpload.Msg.NonHL7'")
		set tSC = rs.Execute() 
	
		S ColumnHeaders=""
		While (rs.Next()) {
			if ( ColumnHeaders="" ) {
				S ColumnHeaders=rs.Get("Name")
			} else{
				S ColumnHeaders=ColumnHeaders_$CHAR(9)_rs.Get("Name")
			}
		}
		w "<span id=headers>"_ColumnHeaders_"</span>"
		&js<downloadheaders(ColumnHeaders)>
	}
	&html<
	<Center>
	<Input Type="Text" Name="ProviderFileName" id="ProviderFileName" size="60" Value="">
	<Input Type="Button" Style="width:100" Name="GetProviderFile" id="GetProviderFile" Value="Select File" onclick="GetProviderFile()">
	<Input Type="Button" Style="width:100" Name="ProcessProviderFile" id="ProcessProviderFile" Value="Process File" onclick="ProcessProviderFile()">
	<Input Type="Button" Style="width:100" Name="PreviewProviderFile" id="PreviewProviderFile" Value="Preview File" onclick="PreviewProviderFile()">
	</Center><BR><BR><HR><B>Status</B>
	<Span id=StatusMessage>
	:  Load File....
	</script>
	</Span>

	<BR><BR><HR>
	<span id=Preview>
	</span>

	>
}

ClassMethod FormatHeader(ProvHeader As %String) As %String [ Language = objectscript ]
{
 		Set NewTitles="", NewTitleList = ""
 		
 		set lCSV = ##class(IIBAENSEMBLE.Functions).ParseCSV(ProvHeader)
 				
 		for j=1:1:$LL(lCSV) { 
 			Set $LI(NewTitleList,j)=$ZCONVERT($ZSTRIP($LI(lCSV,j),"*E'A'N"),"U") 
 		}
 		
 		set NewTitles = $LTS(NewTitleList,$C(9))
 		
         Quit NewTitles
}

ClassMethod GetHeaders() As %String [ Language = objectscript ]
{
	//&js<alert('Getting Header');>
		Set rs = ##class(%ResultSet).%New()
		Do rs.Prepare("Select Name from %Dictionary.PropertyDefinition where parent = 'ICOrderResult.ProviderUpload.Msg.NonHL7' order by SequenceNumber")
		set tSC = rs.Execute() 
	
		S ColumnHeaders=""
		While (rs.Next()) {
			if ( ColumnHeaders="" ) {
				S ColumnHeaders=$C(34)_rs.Get("Name")_$C(34)
			} else{
				S ColumnHeaders=ColumnHeaders_","_$CHAR(34)_rs.Get("Name")_$C(34)
			}
		}
		
		//S ColumnHeaders=..FormatHeader(ColumnHeaders)
		//W "Headers: "_ColumnHeaders
		
		
			
		
		Quit ColumnHeaders
}

ClassMethod GetAccessInfo() As %String [ Language = objectscript ]
{
 		
 		Set ReturnVal=$SYSTEM.Security.Check("IIBAImagecastUpdate", "USE")
 		// &js<alert('#("Retrun Value: "_ReturnVal)#')>
 			
 		
 		Quit ReturnVal
}

ClassMethod PreviewHTML(line As %String) As %String [ Language = objectscript ]
{
 		set lCSV = ##class(IIBAENSEMBLE.Functions).ParseCSV(line)
 		
 		set ReturnVal = "<TR>"
 		
 		for j=1:1:$LL(lCSV) {
 			set ReturnVal = ReturnVal_"<TD NOWRAP>"
 			if $LI(lCSV,j) '= "" { 
 				set ReturnVal = ReturnVal_$LI(lCSV,j) 
 			} else {
 				set ReturnVal = ReturnVal_"&nbsp;"
 			}
 			set ReturnVal = ReturnVal_"</TD>"
 		}	
 		
 		
 		set ReturnVal = ReturnVal_"</TR>"
 		
 		Quit ReturnVal
}

ClassMethod ValidateData(ProvHeader As %String, ProvData As %String, InvokeServiceFlag As %String) As %String [ Language = objectscript ]
{
 		If ( ProvData="" ) {
 			Set ReturnVal="NoData"
 			
 		} else {
 			
 			// &js<alert('#(ProvHeader)#')>
 			// &js<alert('#(ProvData)#')>
 			Set sep=$CHAR(9)
 			Set ColumnTitles=$LISTFROMSTRING(ProvHeader,sep)
 			Set pRequest=##class(ICOrderResult.ProviderUpload.Msg.NonHL7).%New()
 			Set DataList=##class(IIBAENSEMBLE.Functions).ParseCSV(ProvData)
 			Set DataLength=$LISTLENGTH(DataList)
 			IF ($LISTLENGTH(DataList)>$LISTLENGTH(ColumnTitles)) {
 				Set Message="The number of data fields is greater than the number of column headers ! \n("_$E(ProvData,1,40)_")"
 				//&js<alert('The number of data fields does not match the number of column headers !')>
 				&js<alert('#(Message)#')>
 			}
 			For j=1:1:$LISTLENGTH(ColumnTitles) {	
 				if ( j <= DataLength ) {
 					set $ZOBJPROPERTY(pRequest,$LIST(ColumnTitles,j))=$LIST(DataList,j)
 				}
 			}
 
 			
 			Set ReturnVal=##class(ICOrderResult.ProviderUpload.Functions).ValidateProviderDataExpr(pRequest)
 		
 			 //&js<alert('#("Retrun Value: "_ReturnVal)#')>
 			
 			if (InvokeServiceFlag="Y") {
 				do ##class(IIBAENSEMBLE.Utilities).InvokeService("ICOrderResult.ProviderUpload.Bsvc.CspInbound",pRequest)
 			}
 			
 		}
 		
 		Quit ReturnVal
}

ClassMethod ValidateHeader(ProvHeader As %String) As %String [ Language = objectscript ]
{
 		If ( ProvHeader="" ) {
 			Set ReturnVal="NoData"
 			
 		} else {
 			Set ReturnVal=##class(ICOrderResult.ProviderUpload.Functions).ValidateProviderFileHeaderExpr(ProvHeader)
 		}
 		
 		Quit ReturnVal
}

}
