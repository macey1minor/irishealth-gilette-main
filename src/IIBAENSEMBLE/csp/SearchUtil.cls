/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.csp.SearchUtil Extends %CSP.Page [ ProcedureBlock ]
{

/// Use this flag to turn on the printing of the Search Query for both this page and the EMP msg browser
/// set ^Ens.Debug("UtilEnsMessages","sql")=1
ClassMethod CheckPermissions()
{
	set Allowed = 0
	//Req#5 - PHegel Tab Security Use for page name
	if ##class(%SYSTEM.Security).Check("SearchUtil","USE"){ 
		set Allowed = 1 
	}
	Quit Allowed
}

ClassMethod jsfunction()
{
  &html<
<script language="JavaScript" src="calendar2.js"></script>
<script language="JavaScript" src="date.js"></script><!-- Date only with year scrolling -->
<script language="javascript" src="xp_progress.js"></script> 
   <script language=javascript>
	var ddDisplay= "none";
	var search = 1;
	var cachedSelected = new Array();
	var cachedSearchString = new Array();
	
	function AddSearchCriteria() {
	    captureValues();
	    search++;
	    var objTo = document.getElementById('searchCriteria');
	    var divSearch = document.createElement("div");
		divSearch.id = "propertiesDiv"+ search;
		divSearch.name = "propertiesDiv"+ search; 
		divSearch.style.display = ddDisplay;
		
		var strObjName = "clearSearchString(this,'SearchString" + search +"')";
		//alert ('id="searchCriteria'+ search + '"<end>')
		
		if (search==1){
			divSearch.innerHTML = '<label for="propertySelect">Search Table Properties:</label><br/>';
		}
		divSearch.innerHTML += '<select name="propertySelect'+ search +'" id="propertySelect'+ search +'" style="width:200;" onchange="'+ strObjName +'">';
		//divSearch.innerHTML += '	<option value=""></option>';
		divSearch.innerHTML += '</select>';
		
		if (search>=2){
			objTo.innerHTML += '<br/>';
		}
		objTo.appendChild(divSearch);
		objTo.innerHTML += '<input type="Text" name="SearchString'+ search +'" ID="SearchString'+ search +'" value="All">';
		
		// additional variables to help decide if this class already has a host.
		/**/
		if (ddDisplay="inline"){
			var hostName = document.getElementById("ItemS").value;
			var type = ((hostName=="") ? "target":"source");
	    	loadSearchTableProperties(hostName, type);
		}
		//put back cleared values.
	    resetValues();
		
	}
	function captureValues(){
		for (var i = 1; i <= search; i++){
			s = i-1;
			cachedSelected[s] = document.getElementById("propertySelect"+i).value;
			cachedSearchString[s] = document.getElementById("SearchString"+i).value;
			//alert("CAPTUREVALUES: cachedSelected["+ s +"]: " + cachedSelected[s] + "  cachedSearchString["+ s +"]: " + cachedSearchString[s]);
		}
		
	}
	function resetValues(){
		for (var i = 1; i <= cachedSelected.length; i++){
			s = i-1
			//alert("RESETVALUES:  cachedSelected["+ s +"]: " + cachedSelected[s] + "  cachedSearchString["+ s +"]: " + cachedSearchString[s]);
			document.getElementById("SearchString"+i).value = cachedSearchString[s];
			var x = document.getElementById("propertySelect"+i);
			for (var j = 0; j < x.length; j++){
				//alert(x.options[j].value);
				if (cachedSelected[s] == x.options[j].value){
					x.options[j].selected = true;
				}
				else {
					x.options[j].selected = false;
				}
			}
		}	
	}

	function Hello() {
		alert('Hello');
	}
	
	function PreExecuteQuery() {
		document.getElementById('Results').style.display = 'none';
		document.getElementById('NoResults').style.display = 'none';

		document.getElementById('ResultsCell').align="center"

		document.getElementById('Searching').style.display = 'inline';
		
		setTimeout("ExecuteQuery()",5);
		
		
	}
	
	function ExecuteQuery() {
		
		
		var sSource = '';
		var sTarget = '';
		var sMsgClass = '';
		var sMsgField = '';
		var sStatus = '';
		var sDate1 = '';
		var sDate2 = '';
		var sTime1 = '';
		var sTime2 = '';
		var sSearchString = '';
		var sSTCClass = '';
		var sSTCProperty = '';
		
		if (document.QueryBuilder.ItemS.options[0].selected != 1) {
			sSource = document.QueryBuilder.ItemS.options[document.QueryBuilder.ItemS.options.selectedIndex].value;
			var radioObj = document.getElementsByName("SM")
			for(var i = 0; i < radioObj.length; i++) {
 				if(radioObj[i].checked)
  				sMsgClass=radioObj[i].value;
			}
		}
		
		if (document.QueryBuilder.ItemT.options[0].selected != 1) {
			sTarget = document.QueryBuilder.ItemT.options[document.QueryBuilder.ItemT.options.selectedIndex].value;
			var radioObj = document.getElementsByName("TM")
			for(var i = 0; i < radioObj.length; i++) {
 				if(radioObj[i].checked)
  				sMsgClass=radioObj[i].value;
			}
		}
		
		//alert(sSource+' - '+sMsgClass);
		
		sDate1 = document.QueryBuilder.Date1.value;
		sDate2 = document.QueryBuilder.Date2.value;
		
		sTime1 = (document.QueryBuilder.HourStart.selectedIndex == 0 ? '0' : document.QueryBuilder.HourStart.selectedIndex -1);
		sTime2 = (document.QueryBuilder.HourEnd.selectedIndex == 0 ? '0' : document.QueryBuilder.HourEnd.selectedIndex -1);
		
		sStatus = document.QueryBuilder.Status.value;
		
		sMsgField = document.QueryBuilder.MsgField.value;
		
		
		sSTCClass = document.getElementById("stcClass").value;
		
		var searchString = "";
		var sTCProperty = "";
		for (var i = 1; i <= search; i++){
			var ddobject = document.getElementById('propertiesDiv'+ i)
			ddobject.style.display = ddDisplay;
			searchString = document.getElementById('SearchString' + i).value;
			sTCProperty = document.getElementById('propertySelect' + i).value;
		
			if (sTCProperty != "" && searchString == "")
			{
				alert("You must enter a search value when using the Search Table Properties.");
				return;	
			}
			sSearchString += "," + searchString
			sSTCProperty += "," + sTCProperty
		}
		sSearchString = sSearchString.substring(1);
		sSTCProperty = sSTCProperty.substring(1);
		
		/*
		alert(" sSource=" + sSource + " sTarget=" + sTarget + " sMsgClass=" + sMsgClass + " sMsgField=" + sMsgField + " sStatus=" + sStatus);
		alert(" sDate1=" + sDate1 + " sDate2=" + sDate2 + " sTime1=" + sTime1 + " sTime2=" + sTime2);
		alert(" sSearchString=" + sSearchString + " sSTCClass=" + sSTCClass + " sTCProperty=" + sSTCProperty);
		*/
	try
	{
		var ExecuteQuery = #server(..ExecuteQuery(sSource,sTarget,sMsgClass,sMsgField,sStatus,sDate1,sDate2,sTime1,sTime2,sSearchString, sSTCClass, sSTCProperty))#;
	}
	catch(err)
	{
		alert('The query timed out or encountered an error.\n\nAdjust selections and try again.\n message:'+err.message + '\n file:'+ err.fileName + "\n line:"+ err.lineNumber);
		
	}
	/*
	alert("ExecuteQuery = " + ExecuteQuery );
	*/
	document.getElementById('Searching').style.display = 'none';
	
	document.getElementById('ResultsCell').align="left"
	
	if (ExecuteQuery != null)
	{
		if (ExecuteQuery==0)
		{
			document.getElementById('ResultsCell').align="center"
			document.getElementById('NoResults').style.display = 'inline';
		}
		else
		{	
			document.getElementById('Results').style.display = 'inline';
			FirstMsg();
		}
	}	
		
		
	}
	
	function Msgs(ItemName,ItemType) {
		//alert(ItemName);
		//alert(ItemType);
				
		if (ItemType==document.getElementById('MsgFieldSetBy').value)
		{
			document.getElementById('MsgField').value = '';
			document.getElementById('MsgFieldSetBy').value = '';
			document.getElementById('SearchField').innerHTML= '';
		}
				
		var MsgRadio = #server(..GetMsgs(ItemName,ItemType))#;
		document.getElementById(ItemType+'Msg').innerHTML=MsgRadio.substr(0,MsgRadio.length-1)
		if (MsgRadio.substr(MsgRadio.length-1,MsgRadio.length)==1)
			document.getElementById(ItemType+'M1').click()
			
		var radioObj = document.getElementsByName(ItemType+'M')
			for(var i = 0; i < radioObj.length; i++) {
 				if(radioObj[i].checked)
  				sMsgClass=radioObj[i].value;
			}
		/*
		if (sMsgClass == 'ENSLIB.HL7.MESSAGE'){
			setSearchStrings('MSH');
		} else {
			setSearchStrings('All');
		}
		*/
		setSearchStrings('All');
		
	}
	
	// Req#4 - PHegel - used to reset all values...
	function setSearchStrings(sValue){
		for (var i = 1; i <= search; i++){
			var ssobject = document.getElementById('SearchString'+ i)
			ssobject.value = sValue;
		}
			
	}
	
	function GetField(MsgClass,ItemType) {
		//alert(MsgClass);
		//alert(ItemType);
		var url ='IIBASupportDetail.csp?PageName=MsgFields&MsgClass='+MsgClass+'&ItemSpan='+ItemType
		var rValue = window.showModalDialog(url, window,'dialogHeight: 800px; dialogWidth: 500px; dialogTop: 100px; dialogRight: 100px; edge: Raised; center: Yes; help: No; resizable: No; status: No;');
	}
	
	function SetField(ItemType,Field) {
		//alert(Field);
		document.getElementById('MsgField').value = Field;
		
		document.getElementById('MsgFieldSetBy').value = ItemType;
		
		document.getElementById('SearchField').innerHTML='Field: '+Field
		
		if (Field=='')
		{
		  document.getElementById('SearchField').innerHTML=Field
		  document.getElementById('SearchString1').value='All'
		}
	}
	
	function TDate(strElement) {
		var tvalue = document.getElementById(strElement).value;
		var tvaluefirst = tvalue.substr(0,1)
		
		
		if (tvaluefirst.toUpperCase() == 'T')
		{
			var tdate = new Date();
			if (tvalue.length == 1)
			{
				document.getElementById(strElement).value = tdate.format('MM/dd/yyyy');
				
			} 
			else 
			{
				var tdays = tvalue.substr(1,tvalue.length)
				tdate.add('d',tdays);
				document.getElementById(strElement).value = tdate.format('MM/dd/yyyy');
			}
		} else if (tvalue !="") {
			
			var tdate=tvalue.split("/");
			var month=tdate[0];
			var day=tdate[1];
			var year=tdate[2];
						
			if ( (month != "" ) && (day != "" ) ) {
				if ( (tdate.length == 2) || (year.length == 0) ) {
					var d=new Date()
					year=d.getFullYear()
					document.getElementById(strElement).value=month+"/"+day+"/"+year;
					
				} else if (year.length == 2) {
					document.getElementById(strElement).value=month+"/"+day+"/20"+year;
				}
			}
						
		}		
	}

	function NextMsg() {
		
		var msgtext = #server(..ChangeText("Next"))#;
		
		if (msgtext!="End")
		{
			document.getElementById('mytextarea').value=msgtext;
		}

		
	}


	function PreviousMsg() {
		
		var msgtext = #server(..ChangeText("Previous"))#;
		
		if (msgtext!="Beginning")
		{
			document.getElementById('mytextarea').value=msgtext;
		}
		
	}

	function FirstMsg() {
		
		var msgtext = #server(..ChangeText("First"))#;
		
		document.getElementById('mytextarea').value=msgtext;
				
	}

	function LastMsg() {
		
		var msgtext = #server(..ChangeText("Last"))#;
		
		document.getElementById('mytextarea').value=msgtext;
			
	}

	function GoToMsg() {
		
		var jsGoTo = document.getElementById('myGoTo').value;
		
		var msgtext = #server(..ChangeTextGoTo(jsGoTo))#;
		
		document.getElementById('mytextarea').value=msgtext;
			
	}
	
	function ExportMsg(jsHowMany) {
		var filename = #server(..ExportData(jsHowMany))#;
		window.location = 'IIBAENSEMBLE.csp.FileDownload.cls?filename='+filename;		
	}
	
	
	function ResendMsg(jsHowMany) {
		var key = #server(..ResendData(jsHowMany))#;
	
		window.open('EnsPortal.MessageResend.zen?KEY='+key);
			
	}

	function ValidateSearch() {
		
		var errorMsg = "";
		var itemcount = 0;
		
			
		
		if (document.QueryBuilder.ItemS.options[0].selected != 1)
		{
			itemcount += 1
			if (!(document.getElementById('SMsg').innerHTML))
				errorMsg += "Missing Source Message Class.\n"
		}
		
		if (document.QueryBuilder.ItemT.options[0].selected != 1)
		{
			itemcount += 1
			
			if (!(document.getElementById('TMsg').innerHTML))
				errorMsg += "Missing Target Message Class.\n"				
				
		}
		
		if (itemcount == 0)
			errorMsg += "Either a Source or a Target must be selected.\n";
			
		if (!(document.QueryBuilder.Date1.value))
			errorMsg += "At least the 'From' date must be entered.\n";
		
		if (!(document.QueryBuilder.SearchString1.value))
			errorMsg += "You must enter a Search Term.\n";
			
		//if ((document.QueryBuilder.SearchString.value!='All') && (document.QueryBuilder.MsgField.value==''))
		//	errorMsg += "You must either select a field or enter 'All' as your Search Term.\n";
			
		if (document.QueryBuilder.Date2.value) {
			
			//if ((document.QueryBuilder.Date1.value) > (document.QueryBuilder.Date2.value))
			if ((Date.parse(document.QueryBuilder.Date1.value)) > (Date.parse(document.QueryBuilder.Date2.value)))
				errorMsg += "The 'To' date must be greater than the 'From' date.\n";
		
		}
		
		if ((document.QueryBuilder.HourStart.options[0].selected != 1) && (document.QueryBuilder.HourEnd.options[0].selected != 1)) {
			
			if  (document.QueryBuilder.Date2.value) {
				var startDate = new Date(document.QueryBuilder.Date1.value+' '+document.QueryBuilder.HourStart.selectedIndex+':00');
				var endDate = new Date(document.QueryBuilder.Date2.value+' '+document.QueryBuilder.HourEnd.selectedIndex+':00');
				if (endDate<startDate)
 					errorMsg += "The 'To' DateTime must be greater than the 'From' DateTime.\n";
			}
			else {
				if ((document.QueryBuilder.HourEnd.selectedIndex) < (document.QueryBuilder.HourStart.selectedIndex))
					errorMsg += "The 'End' Time must be greater than the 'Start' Time.\n";
			}
				
		}
		
		
			
		if (errorMsg)
        {
            alert(errorMsg);
        }
        else
        {
	        
	    	PreExecuteQuery();
	        			
        }
			
	}
	
	function InitStandard()
	{
				
		//Standard Initialization
		var TypeS = document.getElementById("TypeS");
		var TypeT = document.getElementById("TypeT");
		
		for (i=0;i<TypeS.length;i++) {
			if (TypeS.options[i].value=='Service')
				TypeS.options.selectedIndex=i
		}
		for (i=0;i<TypeT.length;i++) {
			if (TypeT.options[i].value=='Operation')
				TypeT.options.selectedIndex=i
		}
		
		UpdItemSelect('Service','S');
		UpdItemSelect('Operation','T');
		
		document.getElementById('ItemS').focus();
		
		var dt_datetime=new Date()
		document.getElementById('Date1').value=(dt_datetime.getMonth() < 9 ? '0' : '') + (dt_datetime.getMonth() + 1) + "/" + (dt_datetime.getDate() < 10 ? '0' : '') + dt_datetime.getDate() + "/" + dt_datetime.getFullYear()
	
	}
	//TODO: integrate with new method.
	function InitAuto()
	{
		//Auto Initialization from Interface list
		var TypeS = document.getElementById("TypeS");
		var TypeT = document.getElementById("TypeT");
		var ItemS = document.getElementById("ItemS");
		var ItemT = document.getElementById("ItemT");
		
		if (gup("direction")=="source"){
			for (i=0;i<TypeS.length;i++) {
				if (TypeS.options[i].value==gup("type"))
					TypeS.options.selectedIndex=i
			}
			for (i=0;i<TypeT.length;i++) {
				if (TypeT.options[i].value=='Operation')
					TypeT.options.selectedIndex=i
			}
			UpdItemSelect(gup("type"),'S');
			UpdItemSelect('Operation','T');
			var autoItemName = gup("item")		
			for (i=0;i<ItemS.length;i++) {
				if (ItemS.options[i].value==autoItemName)
					ItemS.options.selectedIndex=i
			}
			Msgs(autoItemName,'S')
		}
		if (gup("direction")=="target"){
			for (i=0;i<TypeS.length;i++) {
				if (TypeS.options[i].value=='Service')
					TypeS.options.selectedIndex=i
			}
			for (i=0;i<TypeT.length;i++) {
				if (TypeT.options[i].value==gup("type"))
					TypeT.options.selectedIndex=i
			}
			UpdItemSelect('Service','S');
			UpdItemSelect(gup("type"),'T');
			var autoItemName = gup("item")		
			for (i=0;i<ItemT.length;i++) {
				if (ItemT.options[i].value==autoItemName)
					ItemT.options.selectedIndex=i
			}				
			Msgs(autoItemName,'T')
		}
		
		if (gup("lastaction")!=""){
			var dt_datetime=new Date(gup("lastaction"))
		} else {
			var dt_datetime=new Date()
		}
		
		document.getElementById('Date1').value=(dt_datetime.getMonth() < 9 ? '0' : '') + (dt_datetime.getMonth() + 1) + "/" + (dt_datetime.getDate() < 10 ? '0' : '') + dt_datetime.getDate() + "/" + dt_datetime.getFullYear()
		
		resetAndLoadProperties();
	}

	function Initialize()
	{
	
		if (gup("auto")=="true") {
			InitAuto()
		} else {
			InitStandard()
		}
		
	}
	function UpdItemSelect(ItemType,SrcTgt) 
	{
		
		var ItemList=document.getElementById('Item'+SrcTgt);
		
		document.getElementById(SrcTgt+'Msg').innerHTML = ''
		
		while (ItemList.length>0)
		{
				ItemList.remove(ItemList.length-1);
		}
		
		
		var result = #server(..UpdItemSelect(ItemType,SrcTgt))#;
		
	}

	function gup( name )
	{  
	name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");  
	var regexS = "[\\?&]"+name+"=([^&#]*)";  
	var regex = new RegExp( regexS );  
	var results = regex.exec( window.location.href );  
	if( results == null )    
	    return "";  
	else
	    return results[1];
	}
	
	//Added to do reset of data before populating dropdownlist.
	function resetAndLoadProperties(hostName, type){
		loadSearchTableProperties(hostName, type);
		ResetSearch();
	}
	
	// Req#3 - Phegel - modified ..LoadProperties function to append search count to property element names
	function loadSearchTableProperties(hostName, type)
	{
		var sclass = document.getElementById("stcClass");
		var sprop = document.getElementById("propertySelect" + search);
		var properties = document.getElementById("propertiesDiv" + search);
		var searchString = document.getElementById("SearchString" + search);
		//alert("hostName: " + hostName + " type: " + type + " psObjectName: " + 'propertySelect'+ search );	

		if (type == "target")
		{
			if (document.getElementById("ItemS").value != "" && sclass.value != "")
			{
				// do not override a source's search table
				return;	
			}
		}
		
		if (hostName == "")
		{
			ddDisplay = "none";
			sclass.value = "";
			sprop.value = "";
			
			return;
		}
		
		var className = #server(..GetSearchTableClass(hostName))#;
		
		if (className != "")
		{
			ddDisplay="inline";
			sclass.value = className;
			#server(..LoadProperties(className, sprop.name))#;
		}
		else
		{
			ddDisplay = "none";
			sclass.value = "";
			sprop.value = "";
		}
		properties.style.display = ddDisplay;
		searchString.value = "All";
	}
	
	
	<!-- Req#3 - Phegel - Used to reset search criteria -->
	function ResetSearch(){
		//window.location.reload();
		
		//reset values
		ddDisplay= "none";
		search = 0;
		var objTo = document.getElementById('searchCriteria');
		//iterate through each node and remove.
		while (objTo.hasChildNodes()) {
			objTo.removeChild(objTo.firstChild);
		};
		//re-add first search criteria
		AddSearchCriteria();
		
	}
	
	<!-- Req#3 - Phegel - To test the toggle of drop down list -->
	function ToggleDropDown(){	
		if (ddDisplay=="none"){
			ddDisplay = "inline";
		} else {
			ddDisplay= "none";
		}
	
		for (var i = 1; i <= search; i++){
			var ddobject = document.getElementById('propertiesDiv'+ i)
			ddobject.style.display = ddDisplay;
		}
	}
	
	/*
	function clearSearchString()
	{
		var ps = document.getElementById("propertySelect");
		var ss = document.getElementById("SearchString");
		if (ps.value != "" && ss.value == "All")
		{
			ss.value = "";
		}
		else if (ps.value == "" && ss.value == "")
		{
			ss.value = "All";
		}
	}
	*/
	function clearSearchString(ps, strName){
		//alert ('SearchString Obj name: '+ strName + '"<end>')
		var ss = document.getElementById(strName)
		ss.value = '';
		if (ps.value != "" && ss.value == "All")
		{
			ss.value = "";
		}
		else if (ps.value == "" && ss.value == "")
		{
			ss.value = "All";
		}
	}
	

 
   </script>
  >
}

ClassMethod test()
{
	Quit "OK"
}

ClassMethod html()
{
    &html<
    
    <form name="QueryBuilder" id="QueryBuilder">
	<TABLE Border='0'><TR><TD>
	<fieldset>
	<TABLE><TR><TD Width="75"></TD><TD Width="100">Type</TD><TD Width="400">Item</TD></TR>
	<TR><TD><b>Source:</b></TD>
	<TD><select NAME="TypeS" ID="TypeS" onchange="UpdItemSelect(this.value,'S')">
	<option VALUE="Service">Service
	<option VALUE="Process">Process
	<option VALUE="Operation">Operation
	</select></TD>
	<TD><select NAME="ItemS" ID="ItemS" onchange="Msgs(this.value,'S'); resetAndLoadProperties(this.value,'source');">
	</select></TD></TR>
	<TR><TD/><TD/><TD><SPAN id="SMsg"></SPAN></TD></TR>
	<TR><TD><b>Target:</b></TD>
	<TD><select NAME="TypeT" ID="TypeT" onchange="UpdItemSelect(this.value,'T')">
	<option VALUE="Process">Process
	<option VALUE="Operation">Operation
	</select></TD>
	<TD><select NAME="ItemT" ID="ItemT" onchange="Msgs(this.value,'T'); loadSearchTableProperties(this.value,'target');" >
	</select></TD></TR>
	<TR><TD/><TD/><TD><SPAN id="TMsg"></SPAN></TD></TR>
	</TABLE>
	</fieldset>
	
	</TD><TD width="25"/><TD vAlign="top">
	
	<fieldset>	

			<TABLE border='0' cellpadding="0">
				<TR> <TD> <b>Date Range:</b> </TD> </TR>
				<TR>
					<TD valign="top">Date Time Start:&nbsp;&nbsp;</TD>
					<TD>
						<input type="Text" style="width: 100px" name="Date1" id="Date1" value="" onblur="TDate('Date1')">&nbsp;
						<a href="javascript:cal1.popup();"><img src="img/cal.gif" width="16" height="16" border="0" alt="From Date"></a>
					<TD valign="top">&nbsp;
						<select NAME="HourStart" id="HourStart">
						<option VALUE="">
						<script language="javascript">
							for(var i=0; i<25; i++) {
							document.write('<option VALUE='+i+'>'+i);
						}
						</script> 
						</select>
					</TD>
				</TR>
				<TR>
					<TD valign="top">Date Time End:&nbsp;&nbsp;</TD>
					<TD>
						<input type="Text" style="width: 100px" name="Date2" id="Date2" value="" onblur="TDate('Date2')">&nbsp;
						<a href="javascript:cal2.popup();"><img src="img/cal.gif" width="16" height="16" border="0" alt="To Date"></a>
					</TD>
					<TD valign="top">&nbsp;
						<select NAME="HourEnd" id="HourEnd">
						<option VALUE="">
						<script language="javascript">
							for(var i=0; i<25; i++) {
							document.write('<option VALUE='+i+'>'+i);
						}
						</script> 
						</select>
					</TD>
				</TR>
				<TR>
					<TD valign="top">Status:&nbsp;&nbsp;</TD>
					<TD>
						<select NAME="Status" id="Status">
						<option VALUE="All">All
						<option VALUE="1">Created
						<option VALUE="2">Queued
						<option VALUE="3">Delivered
						<option VALUE="4">Discarded
						<option VALUE="5">Suspended
						<option VALUE="6">Deferred
						<option VALUE="7">Aborted
						<option VALUE="8">Error
						<option VALUE="9">Completed
						</select>
					</TD>
				</TR>
			</TABLE>				

	</fieldset>
	
	</TD></TR></TABLE>
	
	
	<SPAN id="SearchField"></SPAN><br>
	<!-- Req#3 - Phegel - Setup to dynamically be able to add propertySelect drop down list and the SearchString input text box -->
	<div id="searchCriteria" style="display:inline;">
		<div id="propertiesDiv1" style="display:none;">
			<label for="propertySelect">Search Table Properties: </label><br/>
			<select name="propertySelect1" id="propertySelect1" style="width:200;" onchange="clearSearchString(this,'SearchString1')">
				<!--<option value=""></option>-->
			</select>
		</div>
		<input type="Text" name="SearchString1" ID="SearchString1" value="">
	</div>
	<input type="HIDDEN" name="stcClass" id="stcClass" value="">
	<Input TYPE="HIDDEN" NAME="Mode" id="Mode" VALUE="ExecuteQuery">
	<Input TYPE="HIDDEN" NAME="MsgField" ID="MsgField" VALUE="">
	<Input TYPE="HIDDEN" NAME="MsgFieldSetBy" ID="MsgFieldSetBy" VALUE="">

	<Input Type="button" Name="btnSearch" id="btnSearch" Value="Search" onClick="ValidateSearch()"> &nbsp&nbsp
	<a href="#" onclick="AddSearchCriteria();return false;">Add Search Criteria</a>&nbsp&nbsp
	<a href="#" onClick="ResetSearch();return false;">Reset</a>&nbsp&nbsp
	<a href="#" onClick="ToggleDropDown();return false;" style="display: none;">Toggle Drop Down List</a><br><br>

	<table bgcolor="LightSteelBlue" cellpadding="30"><TR><TD ID="ResultsCell" width="943" height="575">
	
	<SPAN ID="Searching" style='display: none'>Searching...</SPAN>
	
	<SPAN ID="NoResults" style='display: none'><BR>No data found, please try again.</SPAN>
	
	<span ID='Results' style='display: none'>
	
	<table >
		
	<tr><td>
		<table border=0 padding=5><tr>
			<td>Message id</td>
			<td><a href="" id="traceURL" target="_blank">Trace</a></td>
			</tr><tr>
			<td><input type="Text" id="myMessageBodyID" name="MsgID" SIZE="20" value=""></td>
			
			
			<td><a href="" id="editURL" target="_blank"></a></td>
		</tr></table>
		
	</td><td>
		<table frame="box"><tr>
		<td><table><tr>
			<td><a id="myMsgSrc"></a></td>
			<td nowrap> -- </td>
			<td><a id="myMsgTgt"></a></td>
			</tr><tr>
			<td>
			<a id="srcRuleLog" target="_blank" href=''></a>
			<a id="srcRuleSep">&nbsp</a>
			<a id="srcRuleList" target="_blank" href=''></a>
			</td>
			<td></td>
			<td>
			<a id="tgtRuleLog" target="_blank" href=''></a>
			<a id="tgtRuleSep">&nbsp</a>
			<a id="tgtRuleList" target="_blank" href=''></a>
			</td>
			</tr></table></td></tr>
		</table></td>
	
	</tr><tr>
		<td>
		<table border=0><tr><td>Status</td>
		</tr><tr><td><input type="Text" id="myMessageStatus" name="MsgStatus" SIZE="20" value=""></td>
		</tr></table>
		</td>
		<td><table border=0><tr><td>Time Created</td><td>Time Completed</td>
		</tr><tr>
		<td><input type="Text" id="myMessageTime" name="CreatedTime" SIZE="20" value=""></td>
		<td><input type="Text" id="myMsgProcessTm" name="ProcessTime" SIZE="20" value=""></td>
		</tr></table>
	</td></tr>



	</table>
	
	
	<table><TR><TD>
	<Input Type="Button" Style="width:75" Name="First" id="First" Value="First" onclick="FirstMsg()">
	<Input Type="Button" Style="width:75" Name="Previous" id="Previous" Value="Previous" onclick="PreviousMsg()">
	<Input Type="Button" Style="width:75" Name="Next" id="Next" Value="Next" onclick="NextMsg()">
	<Input Type="Button" Style="width:75" Name="Last" id="Last" Value="Last" onclick="LastMsg()">
	</TD><TD width="200" align="right">
	<b id="myCount">1</b><b id="totalCount"></b>
	&nbsp; <input type="Text" id="myGoTo" name="GoTo" SIZE="3" value="">
	<Input Type="Button" Name="GoTo" Value="GoTo" onclick="GoToMsg()">
	</td>
	<td width=10>&nbsp;</td>
	<td>
	<table><TR><TD width="120">
	<Input Type="Button" Style="background: rgb(53,107,141);color: #E0E0E0;text-decoration: none;padding: 3px;padding-left: 10px;padding-right: 10px;margin-top: 10px;-moz-border-radius: 5px;border-radius: 5px;border-top: 1px solid lightgray;border-left: 1px solid lightgray;border-right: 2px solid gray;border-bottom: 2px solid gray;" Name="ResendCurrent" id="ResendCurrent" Value="Resend Current" onclick="ResendMsg('1');">
	</TD>
	<TD width="120">
	<Input Type="Button" Style="background: rgb(53,107,141);color: #E0E0E0;text-decoration: none;padding: 3px;padding-left: 10px;padding-right: 10px;margin-top: 10px;-moz-border-radius: 5px;border-radius: 5px;border-top: 1px solid lightgray;border-left: 1px solid lightgray;border-right: 2px solid gray;border-bottom: 2px solid gray;" Name="ResendAll" id="ResendAll" Value="Resend All" onclick="ResendMsg('all');">
	</TD></TR></table>
	<table><TR><TD width="120">
	<Input Type="Button" Style="background: rgb(72,61,139);color: #E0E0E0;text-decoration: none;padding: 3px;padding-left: 10px;padding-right: 10px;margin-top: 10px;-moz-border-radius: 5px;border-radius: 5px;border-top: 1px solid lightgray;border-left: 1px solid lightgray;border-right: 2px solid gray;border-bottom: 2px solid gray;" Name="ExportCurrent" id="ExportCurrent" Value="Export Current" onclick="ExportMsg('1');">
	</TD>
	<TD width="120">
	<Input Type="Button" Style="background: rgb(72,61,139);color: #E0E0E0;text-decoration: none;padding: 3px;padding-left: 10px;padding-right: 10px;margin-top: 10px;-moz-border-radius: 5px;border-radius: 5px;border-top: 1px solid lightgray;border-left: 1px solid lightgray;border-right: 2px solid gray;border-bottom: 2px solid gray;" Name="ExportAll" id="ExportAll" Value="Export All" onclick="ExportMsg('all');">
	</TD></TR></table>
	
	</TD></TR></TABLE>
	<FORM Name="mytextareaform">
	<textarea id="mytextarea" rows="20" cols="100">
	</textarea></FORM>
	

	
	
	</SPAN>
	<br><SPAN ID="SQLDebugStatement" style='display: none'></SPAN>	
	</TD></TR></table>
	
	</form>
	
    
    
    >
}

ClassMethod jsCalfunction()
{
  &html<
   <script language=javascript>
 // create calendar object(s) just after form tag closed
 // specify form element as the only parameter (document.forms['formname'].elements['inputname']);
 // note: you can have as many calendar objects as you need for your application
var cal1 = new calendar2(document.forms['QueryBuilder'].elements['Date1']);
cal1.year_scroll = true;
cal1.time_comp = false;
var cal2 = new calendar2(document.forms['QueryBuilder'].elements['Date2']);
cal2.year_scroll = false;
cal2.time_comp = false;
document.QueryBuilder.SearchString1.onkeydown = enterKey;
document.QueryBuilder.Date1.onkeydown = enterKeyDate1;
document.QueryBuilder.Date2.onkeydown = enterKeyDate2;

function enterKey(e) {
	//check to see if the return key was pressed ...
	if ((event.keyCode == 13)||(event.keyCode == 9))
	{ 
		//call the ValidateSearch function ...
		document.QueryBuilder.btnSearch.focus();
		ValidateSearch();
		//prevent the page from reloading ...
		return false;
	}
}
function enterKeyDate1(e) {

	if ((event.keyCode == 13)||(event.keyCode == 9))
	{ 
		TDate('Date1');
		document.QueryBuilder.Date2.focus();
		return false;
	}
}
function enterKeyDate2(e) {
	if ((event.keyCode == 13)||(event.keyCode == 9))
	{ 
		TDate('Date2');
		document.QueryBuilder.SearchString1.focus();
		return false;
	}	
}
	

			//-->
   </script>
  >
}

ClassMethod GetItemList()
{
	
		set Servicerset = ##class(%ResultSet).%New()
	set Servicerset.ClassName = "Ens.Util.Statistics"
	set Servicerset.QueryName = "EnumerateHostStatus"
	Do Servicerset.Execute()
	
	set servcount = 0
	set proccount = 0
	set opcount = 0
		
	While (Servicerset.Next()) {
		
		IF (Servicerset.Data("Type") = "BusinessService") & 
		($PIECE(Servicerset.Data("Name"),".",1) '= "Ens") &
		($PIECE(Servicerset.Data("Name"),".",1) '= "EnsLib") {
			set arrServiceList(servcount) = Servicerset.Data("Name")
			set servcount = servcount + 1
		}
		
		IF (Servicerset.Data("Type") = "BusinessProcess") & 
		($PIECE(Servicerset.Data("Name"),".",1) '= "Ens") &
		($PIECE(Servicerset.Data("Name"),".",1) '= "EnsLib") {
			set arrProcessList(proccount) = Servicerset.Data("Name")
			set proccount = proccount + 1
		}

		IF (Servicerset.Data("Type") = "BusinessOperation") & 
		($PIECE(Servicerset.Data("Name"),".",1) '= "Ens") &
		($PIECE(Servicerset.Data("Name"),".",1) '= "EnsLib") {
			set arrOperationList(opcount) = Servicerset.Data("Name")
			set opcount = opcount + 1
		}
	
	}
	
	Merge %session.Data("ServiceList")=arrServiceList
	Merge %session.Data("ProcessList")=arrProcessList
	Merge %session.Data("OperationList")=arrOperationList
	Merge %session.Data("ServiceCount")=servcount
	Merge %session.Data("ProcessCount")=proccount
	Merge %session.Data("OperationCount")=opcount
}

ClassMethod BuildRuleLinks(Session As %String, itemname As %String, srctgt As %String) As %String [ Language = objectscript ]
{
 
 set RuleLink = ""
 
 set Rule=..GetBusinessRule(itemname)
 
 if Rule '= "" {
 	set RuleLink = RuleLink_"<a id="""_srctgt_"RuleLog"" target=""_blank"" href='"_..BuildURL(Session,Rule,"log")_"'>RuleLog</a>"
 	set RuleLink = RuleLink_"<a id="""_srctgt_"RuleSep""> | </a>"
 	set RuleLink = RuleLink_"<a id="""_srctgt_"RuleList"" target=""_blank"" href='"_..BuildURL(Session,Rule,"list")_"'>RuleList</a>"
 } else {
 	set RuleLink = RuleLink_"<a id="""_srctgt_"RuleLog"" target=""_blank"" href=''></a>"
 	set RuleLink = RuleLink_"<a id="""_srctgt_"RuleSep"">&nbsp</a>"
 	set RuleLink = RuleLink_"<a id="""_srctgt_"RuleList"" target=""_blank"" href=''></a>"
 }
 
 Quit RuleLink
}

ClassMethod BuildURL(Session As %String, Rule As %String, loglist As %String) As %String [ Language = objectscript ]
{
 
 set URL = ""
 
 if loglist = "log" {
	s:$Username'="" ^CacheTemp.EnsPortal($Username,"RuleLog","SearchCriteria")="Newest First^999^0,,,"_Session_","_Rule_"^500^0,1,0^None"
 	set URL = "EnsPortal.RuleLog.zen?RuleName="_Rule_"&SessionId="_Session
 } elseif loglist = "list" {
 	set RulePackage=""
 	for i=1:1:$L(Rule,".")-1 { set RulePackage = RulePackage_$P(Rule,".",i)_"." }
 	set RulePackage = $E(RulePackage,1,$L(RulePackage)-1)
 	//set URL = "EnsPortal.RuleEditor.zen?RULE="_$P(Rule,".",$L(Rule,"."))
 	set URL = "EnsPortal.RuleEditor.zen?RULE="_Rule
 }
 
 
 Quit URL
}

ClassMethod ChangeText(direction As %String) As %String [ Language = objectscript ]
{
 		
 	If direction = "Next" {
 		
 		If %session.Data("curPos") < (%session.Data("count")) {
 			set %session.Data("curPos") = (%session.Data("curPos") + 1)
 		} Else {
 			Quit "End"
 		}
 		
 		
 		set msgtext = ..ChangeTextAction()
 					
 	}
 		
 	If direction = "Previous" {
 	
 		If %session.Data("curPos") > 1 {
 			set %session.Data("curPos") = (%session.Data("curPos") - 1)
 		} Else {
 			Quit "Beginning"
 		}
 		
 		set msgtext = ..ChangeTextAction()
 					
 	}
 	
 	If direction = "First" {
 		
 		set %session.Data("curPos") = 1
 		
 		set msgtext = ..ChangeTextAction()
 		
 	}
 	
 	If direction = "Last" {
 		
 		set %session.Data("curPos") = %session.Data("count")
 		
 		set msgtext = ..ChangeTextAction()
 		
 	}
 	
 	If direction = "GoTo" {
 		
 		set %session.Data("curPos") = GoTo
 		
 		set msgtext = ..ChangeTextAction()
 		
 	}
 	
 	Quit msgtext
}

ClassMethod ChangeTextAction() As %String [ Language = objectscript ]
{
 
 		set DisplayedPos = %session.Data("curPos")
 		//&js<alert(#(%session.Data("curRSID"))#);>
 		set MessageIDrset=##class(%ScrollableResultSet).%OpenId(%session.Data("curRSID"))
 		Do MessageIDrset.CurrRowSet(DisplayedPos)
 		set curMsgContentID = MessageIDrset.Data("MessageBodyId")
 		set curMsgID = MessageIDrset.Data("ID")
 		set curSessionId = MessageIDrset.Data("SessionId")
 		set curMsgSrc = MessageIDrset.Data("SourceConfigName")
 		set curMsgTgt = MessageIDrset.Data("TargetConfigName")
 		set curMsgStatus = MessageIDrset.Data("Status")
 		Set curMsgStatus=$P("Created,Queued,Delivered,Discarded,Suspended,Deferred,Aborted,Error,Completed",",",curMsgStatus)
 		set curMsgTime = MessageIDrset.Data("TimeCreated")
 		set curMsgTmProc = MessageIDrset.Data("TimeProcessed")
 		set curMsgPath = curMsgSrc_"  -->  "_curMsgTgt
 		Do MessageIDrset.%Save()
 		KILL MessageIDrset
 		//		set DisplayedTrace = "IIBAUtilEnsMsgTrace.csp?$ID1="_curSessionId
 		set DisplayedTrace = "EnsPortal.VisualTrace.zen?$ZEN_POPUP=1&SESSIONID="_curSessionId
 		set DisplayedRule = "IIBAUtilEnsRuleLog.csp?SessionId="_curSessionId
 		
 		
 		// Moved the resend to a button above the message window
 		
 		
 		set DisplayedEdit = "IIBASupport.csp?PageName=MessageEdit&MsgHeaderID="_curMsgID_"&SessionId="_curSessionId
 		
 		set sMsgClass = %session.Data("sMsgClass")
 		//Create list from Message Class Name
 		set MCL = $LFS(sMsgClass,".")
 		//Create a new sublist of all parts of the name except the last part
 		set MCLt = $LI(MCL,1,$LL(MCL)-1)
 		//Join the parts of that name back into a string delimited by _ except the last part
 		set sMsgClassTable = $LTS(MCLt,"_")
 		//Add the last part in, but delimited by . 
 		set sMsgClassTable = sMsgClassTable_"."_$LI(MCL,$LL(MCL))
 		
 		Set MessageContentrset = ##class(%ResultSet).%New()
 		set curMsgText = ""
 		if sMsgClass = "ENSLIB.HL7.MESSAGE" {
	 		//The getSegsAsString method which is called by RawContent, throws a max string error even though the maxlen is supposed to be 10000 - so this is probably a bug in getSegsAsString
#; 			Do MessageContentrset.Prepare("SELECT TOP 1 RawContent, TimeCreated FROM EnsLib_HL7.Message WHERE ID = '"_curMsgContentID_"'")
#; 			Do MessageContentrset.Execute()
#; 			While (MessageContentrset.Next()) {
#; 				set curMsgText = MessageContentrset.Data("RawContent")
#; 			}
			set curMsgText = ##class(EnsLib.HL7.Message).%OpenId(curMsgContentID).OutputToString()
 		} else {
 			Do MessageContentrset.Prepare("SELECT TOP 1 * FROM "_sMsgClassTable_" WHERE ID = '"_curMsgContentID_"'")
 			Do MessageContentrset.Execute()
 			While (MessageContentrset.Next()) {
 				set curMsgText = ""
 				for i=1:1:MessageContentrset.GetColumnCount() {
 					set curMsgText = curMsgText_MessageContentrset.GetColumnName(i)_": "_MessageContentrset.Data(MessageContentrset.GetColumnName(i))_$C(13,10)	
 					set curMsgText = $TR(curMsgText,$C(0),$C(-1))
 				}
 			}
 		}
 	
 		set curMsgTime = $P(curMsgTime,".",1)
 		set curMsgTime = $ZDTH(curMsgTime,3,1)
 		set curMsgTime = $ZU(193,curMsgTime,0)
 		set curMsgTime = $ZDT(curMsgTime,3,1)
 		
 		// Message time processed
 		set curMsgTmProc = $P(curMsgTmProc,".",1)
 		set curMsgTmProc = $ZDTH(curMsgTmProc,3,1)
 		set curMsgTmProc = $ZU(193,curMsgTmProc,0)
 		set curMsgTmProc = $ZDT(curMsgTmProc,3,1)
 
 	
 		&js<document.getElementById('myMessageBodyID').value='#(curMsgContentID)#';>
 		&js<document.getElementById('traceURL').href='#(DisplayedTrace)#';>
 		//&js<document.getElementById('ruleURL').href='#(DisplayedRule)#';>
 		//&js<document.getElementById('resendURL').href='#(DisplayedResend)#';>
 		&js<document.getElementById('myMessageTime').value='#(curMsgTime)#';>
 		&js<document.getElementById('myCount').innerHTML='#(DisplayedPos)#';>
 		&js<document.getElementById('myGoTo').value='';>
 		&js<document.getElementById('myMsgSrc').innerHTML='#(curMsgSrc)#';>
 		&js<document.getElementById('myMsgTgt').innerHTML='#(curMsgTgt)#';>
 		&js<document.getElementById('myMessageStatus').value='#(curMsgStatus)#';>
 		&js<document.getElementById('myMsgProcessTm').value='#(curMsgTmProc)#';>
 
 		if ( ##class(%SYSTEM.Security).Check("IIBAMsgEdit","USE")  && (sMsgClass = "ENSLIB.HL7.MESSAGE") ) {
	 		&js<document.getElementById('editURL').href='#(DisplayedEdit)#';>
	 		&js<document.getElementById('editURL').innerHTML='Edit';>
	 		
 		} else {
	 		&js<document.getElementById('editURL').href='';>
	 		&js<document.getElementById('editURL').innerHTML='';>
 		}
 		
 		set SrcRule=..GetBusinessRule(curMsgSrc)
 		set TgtRule=..GetBusinessRule(curMsgTgt)
 		
 		if SrcRule'="" {
 			set SrcRuleLogURL = ..BuildURL(curSessionId,SrcRule,"log")
 			set SrcRuleListURL = ..BuildURL(curSessionId,SrcRule,"list")
 			&js<document.getElementById('srcRuleLog').innerHTML='RuleLog';>
 			&js<document.getElementById('srcRuleLog').href='#(SrcRuleLogURL)#';>
 			&js<document.getElementById('srcRuleSep').innerHTML=' | ';>
 			&js<document.getElementById('srcRuleList').innerHTML='RuleList';>
 			&js<document.getElementById('srcRuleList').href='#(SrcRuleListURL)#';>
 		} else {
 			&js<document.getElementById('srcRuleLog').innerHTML='';>
 			&js<document.getElementById('srcRuleLog').href='';>
 			&js<document.getElementById('srcRuleSep').innerHTML='&nbsp';>
 			&js<document.getElementById('srcRuleList').innerHTML='';>
 			&js<document.getElementById('srcRuleList').href='';>
 		
 		}
 		
 		if TgtRule'="" {
 			set TgtRuleLogURL = ..BuildURL(curSessionId,TgtRule,"log")
 			set TgtRuleListURL = ..BuildURL(curSessionId,TgtRule,"list")
 			&js<document.getElementById('tgtRuleLog').innerHTML='RuleLog';>
 			&js<document.getElementById('tgtRuleLog').href='#(TgtRuleLogURL)#';>
 			&js<document.getElementById('tgtRuleSep').innerHTML=' | ';>
 			&js<document.getElementById('tgtRuleList').innerHTML='RuleList';>
 			&js<document.getElementById('tgtRuleList').href='#(TgtRuleListURL)#';>
 		} else {
 			&js<document.getElementById('tgtRuleLog').innerHTML='';>
 			&js<document.getElementById('tgtRuleLog').href='';>
 			&js<document.getElementById('tgtRuleSep').innerHTML='&nbsp';>
 			&js<document.getElementById('tgtRuleList').innerHTML='';>
 			&js<document.getElementById('tgtRuleList').href='';>
 		
 		}	
 		
 
 	
 		Quit curMsgText
}

ClassMethod ChangeTextGoTo(GoTo As %String) As %String [ Language = objectscript ]
{
 
 	set %session.Data("curPos") = GoTo
 		
 	set msgtext = ..ChangeTextAction()
 	
 	Quit msgtext
}

ClassMethod ExecuteQuery(sSource As %String, sTarget As %String, sMsgClass As %String, sMsgField As %String, sStatus As %String, sDate1 As %String, sDate2 As %String, sTime1 As %String, sTime2 As %String, sSearchString As %String, sSTCClass As %String, sSTCProperty As %Integer) As %String [ Language = objectscript ]
{
 if ('$D(%session))
 {
	set sessionID = $SYSTEM.Util.CreateGUID()
	set sessionUsername = $USERNAME 
 }
 else 
 {
 	Merge %session.Data("sMsgClass")=sMsgClass
	set sessionID = %session.SessionId	 
	set sessionUsername = %session.Username
 }
 	
 
 //sSource   sTarget   sMsgClass   sMsgField   sStatus   sDate1   sDate2   sTime1   sTime2   sSearchString
 
 
 If sDate2 = "" { set sDate2 = sDate1 }
 	
 If sTime2 = 0 {set sTime2 = 24 }
 
 		
 //This data is logged for performance analysis
 	set SearchStart = $H
 	set ^CacheTempMattsTrace(sessionID,SearchStart,"Start") = SearchStart
 	set ^CacheTempMattsTrace(sessionID,SearchStart,"User") = sessionUsername
 	set ^CacheTempMattsTrace(sessionID,SearchStart,"Source") = sSource
 	set ^CacheTempMattsTrace(sessionID,SearchStart,"Target") = sTarget
 	set ^CacheTempMattsTrace(sessionID,SearchStart,"MsgClass") = sMsgClass
 	set ^CacheTempMattsTrace(sessionID,SearchStart,"String") = sSearchString
 
 
 set StartStamp = $PIECE($ZDTH(sDate1),",",1)_","_(sTime1*3600)
 set EndStamp = $PIECE($ZDTH(sDate2),",",1)_","_((sTime2*3600)-1)
 	
 set ^CacheTempMattsTrace(sessionID,SearchStart,"StartStamp") = StartStamp
 set ^CacheTempMattsTrace(sessionID,SearchStart,"EndStamp") = EndStamp	
 	
 set StartStamp = $ZU(193,StartStamp,1)
 set EndStamp = $ZU(193,EndStamp,1)
 set StartStamp = $ZDT(StartStamp,3,1)
 set EndStamp = $ZDT(EndStamp,3,1)
 	
 set SQLStatus = ""
 if sStatus '= "All" {
 	set SQLStatus = "AND mh.Status = '"_sStatus_"' "
 }
 
 set sSourceTarget = ""
 If (sSource '= "") & (sTarget '= "") {
	set sSourceTarget = "mh.SourceConfigName = '"_sSource_"' AND mh.TargetConfigName = '"_sTarget_"' "
 } ElseIf (sSource '= "") & (sTarget = "") {
	set sSourceTarget = "mh.SourceConfigName = '"_sSource_"' "
 } ElseIf (sSource = "") & (sTarget '= "") {
	set sSourceTarget = "mh.TargetConfigName = '"_sTarget_"' "
 }
  		
 set count = 0
 

 set SQLSelect = "SELECT top 10000000 mh.MessageBodyId, mh.ID, mh.SessionId, mh.SourceConfigName, mh.TargetConfigName, mh.Status, mh.TimeCreated, mh.TimeProcessed FROM %IGNOREINDICES ""SourceConfigName,MessageBodyClassName,Status,TargetConfigName"" Ens.MessageHeader mh "
 set SQLTimeCreated = "AND mh.TimeCreated > '"_StartStamp_"' AND mh.TimeCreated < '"_EndStamp_"' "
 set SQLOrderBy = "ORDER BY mh.TimeCreated Asc, MH.ID Asc "
 set SQLJoin=""

 Set MessageIDrset = ##class(%ScrollableResultSet).%New()
 set SQL = ""
 
 //Req#4 - PHegel - Add to parse out the values from each field.
 set listSearchString = $LFS(sSearchString,",")
 set searchString = ""
 set ssptr = 0
 set listSTCProperty = $LFS(sSTCProperty, ",")
 set count = 0
 set sSearchStringConcat = ""
 set stcptr = 0
 set stcProperty = "" 
 
 	if sMsgClass = "ENSLIB.HL7.MESSAGE" {
	 	if sSearchString '= "All" {
		 	//Req#4 - PHegel - Add to parse out the values from each field.

		 	if (sSTCProperty = "") {
		 		//Req#4 - PHegel - changed to use the search string list.
		 		WHILE $LISTNEXT(listSearchString,ssptr,searchString) {
					if searchString '= "All" {
						set count = count + 1
						if count > 1 s sSearchStringConcat=sSearchStringConcat_"AND "
						For i=1:1:$L(searchString,"/") {
						 	if i > 1 s sSearchStringConcat=sSearchStringConcat_"OR "			 	
						 	s sSearchStringConcat=sSearchStringConcat_"m.RawContent LIKE '%"_$P(searchString,"/",i)_"%' "
						}
				 	}				
				 }

		 	} else {

				
				WHILE $LISTNEXT(listSearchString, ssptr ,searchString) {
					set stcNotAtEnd = $LISTNEXT(listSTCProperty, stcptr, stcProperty)
					if searchString '= "All" {
						set count = count + 1
						if count > 1 s sSearchStringConcat=sSearchStringConcat_"AND "
						if ($L(stcProperty)>0){
							set sSearchStringConcat = sSearchStringConcat_"mh.MessageBodyId IN "
							set sSearchStringConcat = sSearchStringConcat_"( "
							set sSearchStringConcat = sSearchStringConcat_"SELECT SchTbl.DocID "
							set sSearchStringConcat = sSearchStringConcat_"FROM EnsLib_HL7.SearchTable SchTbl "					
							set sSearchStringConcat = sSearchStringConcat_"WHERE SchTbl.PropId = "_stcProperty_" "
							set sSearchStringConcat = sSearchStringConcat_"AND LOWER(SchTbl.PropValue) like '%"_$ZConvert(searchString,"l")_"%' "		 	
							set sSearchStringConcat = sSearchStringConcat_") "
						}else{
							For i=1:1:$L(searchString,"/") {
							 	if i > 1 s sSearchStringConcat=sSearchStringConcat_"OR "			 	
							 	s sSearchStringConcat=sSearchStringConcat_"m.RawContent LIKE '%"_$P(searchString,"/",i)_"%' "
							}
						}
					}
				}
		 	}

 	 		set SQLJoin = "INNER JOIN EnsLib_HL7.Message m ON mh.MessageBodyId = m.ID AND ("_sSearchStringConcat_") "
 		}
 	} else {
	
 		//Create list from Message Class Name
 		set MCL = $LFS(sMsgClass,".")
 		//Create a new sublist of all parts of the name except the last part
 		set MCLt = $LI(MCL,1,$LL(MCL)-1)
 		//Join the parts of that name back into a string delimited by _ except the last part
 		set sMsgClassTable = $LTS(MCLt,"_")
 		//Add the last part in, but delimited by . 
 		set sMsgClassTable = sMsgClassTable_"."_$LI(MCL,$LL(MCL))
	
 		if sMsgField '= "" {
		 	WHILE $LISTNEXT(listSearchString, ssptr ,searchString) {	
	 			set SQLJoin = "INNER JOIN "_sMsgClassTable_" m ON mh.MessageBodyId = m.ID AND m."_sMsgField_" LIKE '%"_$ZConvert(searchString,"l")_"%' "
		 	}
 		} 		
 	}
	
 set SQL = SQLSelect_SQLJoin_"WHERE "_sSourceTarget_SQLTimeCreated_"AND mh.MessageBodyClassName = '"_sMsgClass_"' "_SQLStatus_SQLOrderBy

 if $D(^Ens.Debug("UtilEnsMessages","sql")) {
 if ^Ens.Debug("UtilEnsMessages","sql") {
	 set ^CacheTempMattsTrace("SQL") = SQL
	 set tmpVariable = "hello"
	 &js<
	 	document.getElementById('SQLDebugStatement').innerHTML=#(..QuoteJS(SQL))#;
	 	document.getElementById('SQLDebugStatement').style.display = 'inline';
	 >
 
	 }
 }

 Do MessageIDrset.Prepare(SQL)
 Do MessageIDrset.Execute()

 
 set count = MessageIDrset.Count()
  	
 set ^CacheTempMattsTrace(sessionID,SearchStart,"count") = count
 	
 If count '= 0 {
 	Do MessageIDrset.%Save()
 	set curRSID = MessageIDrset.%Id()
 	KILL MessageIDrset
 	
 	Merge %session.Data("count")=count
 	Merge %session.Data("curPos")=curPos
 	Merge %session.Data("curRSID")=curRSID	
 	
 	&js<document.getElementById('totalCount').innerHTML = '&nbsp;of '+'#(count)#'; >
 	/*
 	&js<alert('count: #(count)# msgID: #(curRSID)# session.curRSID: #(%session.Data("curRSID"))#');>
 	*/
 	set ^CacheTempMattsTrace(sessionID,SearchStart,"End") = $H
 	}
 
 Quit count
}

ClassMethod ExportData(pHowMany As %String = "all") As %String [ Language = objectscript ]
{
	s EnsSysDir = ##class(%File).ParentDirectoryName(##class(%File).ManagerDirectory())
	s filetimestamp = ##class(Ens.Util.Time).FormatDateTime("%Y%m%d%H%M%S")
	
	if '##class(%File).DirectoryExists(EnsSysDir_"IIBAExports") { 
		d ##class(%File).CreateDirectory(EnsSysDir_"IIBAExports") 
	}
	
	s filename = "MsgExport_"_%session.SessionId_".txt"
	
	s file = ##class(%File).%New(EnsSysDir_"IIBAExports\"_filename)
	d file.Open("WSN")
	
 	set MessageIDrset=##class(%ScrollableResultSet).%OpenId(%session.Data("curRSID"))
 	set pCurrRow=MessageIDrset.CurrRow
 	
 	//Always start at the first row.
 	if (pHowMany="all") {
 		set MessageIDrset.CurrRow=1
 		set pCount=MessageIDrset.Count()
 	} else {
	 	s pCount=pHowMany+0
 	}
 	/*
 	&js<alert('pCount: #(pCount)# msgID: #(MessageIDrset.%Id())# session.curRSID: #(%session.Data("curRSID"))#'); >
 	*/
 	
 	set tSC = MessageIDrset.Previous()
 	if MessageIDrset.CurrRow = MessageIDrset.Count() do MessageIDrset.Next()
 	
 	set sMsgClass = %session.Data("sMsgClass")
	//Create list from Message Class Name
	set MCL = $LFS(sMsgClass,".")
	//Create a new sublist of all parts of the name except the last part
	set MCLt = $LI(MCL,1,$LL(MCL)-1)
	//Join the parts of that name back into a string delimited by _ except the last part
	set sMsgClassTable = $LTS(MCLt,"_")
	//Add the last part in, but delimited by . 
	set sMsgClassTable = sMsgClassTable_"."_$LI(MCL,$LL(MCL))
 	
 	if sMsgClass = "ENSLIB.HL7.MESSAGE" {
	 	While MessageIDrset.Next() {
	 		d file.WriteLine(##class(EnsLib.HL7.Message).%OpenId(MessageIDrset.Data("MessageBodyId")).OutputToString()) 		
	 		s pCount=pCount-1
	 		Q:pCount<1
	 	}
 	} else {
	 	 While MessageIDrset.Next() {
	 		Set MessageContentrset = ##class(%ResultSet).%New()
			Do MessageContentrset.Prepare("SELECT TOP 1 * FROM "_sMsgClassTable_" WHERE ID = '"_MessageIDrset.Data("MessageBodyId")_"'")
			Do MessageContentrset.Execute()
			Do MessageContentrset.Next()
			set curMsgText = ""
			for i=1:1:MessageContentrset.GetColumnCount() {
				set curMsgText = curMsgText_MessageContentrset.GetColumnName(i)_": "_MessageContentrset.Data(MessageContentrset.GetColumnName(i))_$C(13,10)	
				set curMsgText = $TR(curMsgText,$C(0),$C(-1))
			}			
			d file.WriteLine(curMsgText) 
			
			s pCount=pCount-1
	 		Q:pCount<1		
	 	}
 	}
 	s MessageIDrset.CurrRow=pCurrRow
 	Do MessageIDrset.%Save()
 	
 	KILL MessageIDrset
 	
 	d file.Close()
	kill file
 	Quit filename
}

ClassMethod ResendData(pHowMany As %String = "all") As %String [ Language = objectscript ]
{
	
	//
	
	Set tResendCount = 0
 	Set Key = $increment(^CacheTemp.ResendIDs)
 	
 	set MessageIDrset=##class(%ScrollableResultSet).%OpenId(%session.Data("curRSID"))
 	set pCurrRow=MessageIDrset.CurrRow
 	
 	
 	
 	//Always start at the first row.
 	if (pHowMany="all") {
 		set MessageIDrset.CurrRow=1
 		set pCount=MessageIDrset.Count()
 	} else {
	 	s pCount=pHowMany+0
 	}
 	
 	set tSC = MessageIDrset.Previous()
 	if MessageIDrset.CurrRow = MessageIDrset.Count() do MessageIDrset.Next()
 	
 	
 	
 	
 	//Queue the session for resend
 	While MessageIDrset.Next() {
	 	// Use the message header id rather then the session id
 		//set curSessionId = MessageIDrset.Data("SessionId")
 		//Set ^CacheTemp.ResendIDs(Key,curSessionId)=""
 		set curMsgHeaderId = MessageIDrset.Data("ID")
 		Set ^CacheTemp.ResendIDs(Key,curMsgHeaderId)=""
 		Set tResendCount = tResendCount + 1
 		Set ^CacheTemp.ResendIDs(Key) = tResendCount
 		//set DisplayedResend = "EnsPortal.MessageResend.zen?KEY="_Key
 		
 		s pCount=pCount-1
	 	Q:pCount<1
	 }
 	
 	/*
 	set sMsgClass = %session.Data("sMsgClass")
	//Create list from Message Class Name
	set MCL = $LFS(sMsgClass,".")
	//Create a new sublist of all parts of the name except the last part
	set MCLt = $LI(MCL,1,$LL(MCL)-1)
	//Join the parts of that name back into a string delimited by _ except the last part
	set sMsgClassTable = $LTS(MCLt,"_")
	//Add the last part in, but delimited by . 
	set sMsgClassTable = sMsgClassTable_"."_$LI(MCL,$LL(MCL))
 	
 	
 	if sMsgClass = "ENSLIB.HL7.MESSAGE" {
	 	While MessageIDrset.Next() {
	 		d file.WriteLine(##class(EnsLib.HL7.Message).%OpenId(MessageIDrset.Data("MessageBodyId")).OutputToString()) 		
	 		s pCount=pCount-1
	 		Q:pCount<1
	 	}
 	} else {
	 	 While MessageIDrset.Next() {
	 		Set MessageContentrset = ##class(%ResultSet).%New()
			Do MessageContentrset.Prepare("SELECT TOP 1 * FROM "_sMsgClassTable_" WHERE ID = '"_MessageIDrset.Data("MessageBodyId")_"'")
			Do MessageContentrset.Execute()
			Do MessageContentrset.Next()
			set curMsgText = ""
			for i=1:1:MessageContentrset.GetColumnCount() {
				set curMsgText = curMsgText_MessageContentrset.GetColumnName(i)_": "_MessageContentrset.Data(MessageContentrset.GetColumnName(i))_$C(13,10)	
				set curMsgText = $TR(curMsgText,$C(0),$C(-1))
			}			
			d file.WriteLine(curMsgText) 
			
			s pCount=pCount-1
	 		Q:pCount<1		
	 	}
 	}
 	*/
 	s MessageIDrset.CurrRow=pCurrRow
 	Do MessageIDrset.%Save()
 	
 	KILL MessageIDrset
 	
 	
 	Quit Key
}

ClassMethod GetBusinessRule(itemname As %String) As %String [ Language = objectscript ]
{
 
 	
 	kill production
 	Set ProductionName=""
 	Set ProductionStatus=""
 	set status = ##class(Ens.Director).GetProductionStatus(.ProductionName,.ProductionStatus)
 	set production=##class(Ens.Config.Production).%OpenId(ProductionName)
 	
 	set busrule=""
 	
 	for i=1:1:production.Items.Count() {
 		
 		// Get Item name and check for match
 		s item=production.Items.GetAt(i)
 		if item.Name = itemname {
 			// Get settings and find BusinessRuleName if it exists		
 			for j=1:1:item.Settings.Count() {
 				s st = item.Settings.GetAt(j)
 				If ( st.Name ="BusinessRuleName" ) { 
 					set busrule = st.Value
 						
 				}
 			}
 		}
 	}
 		
 Quit busrule
}

ClassMethod GetMsgs(itemname As %String, itemtype As %String) As %String [ Language = objectscript ]
{
 
 Set MessageClassrset = ##class(%ResultSet).%New()
 set msgcount = 0
 	
 set sItem = itemname
 
 Do MessageClassrset.Prepare("SELECT DISTINCT ItemValue as MessageBodyClassName FROM IIBAENSEMBLE_Task.TaskItemDefinition WHERE ItemType = 'MsgClassDef^"_itemtype_"' AND ItemName = '"_sItem_"'")	
 	Do MessageClassrset.Execute()
 	
 	set Radio = ""
 	While (MessageClassrset.Next()) {
 		//w MessageClassrset.Data("MessageBodyClassName"),!
 		set msgcount=msgcount+1
 		set MsgClass = MessageClassrset.Data("MessageBodyClassName")
 		if MsgClass="ENSLIB.HL7.MESSAGE" {
 			set Radio=Radio_"<input type=""radio"" id="""_itemtype_"M"_msgcount_""" checked=""checked"" name="""_itemtype_"M"" id="""_itemtype_"M"" value="""_MsgClass_"""><font size=""2"">"_MsgClass_"</font><br />"
 		} else {
 			set Radio=Radio_"<input type=""radio"" id="""_itemtype_"M"_msgcount_""" name="""_itemtype_"M"" id="""_itemtype_"M"" value="""_MsgClass_"""><font size=""2"">"_MsgClass_"</font>"
 			set Radio=Radio_"&nbsp;&nbsp;<input type=""button"" value=""..."" onclick=""GetField('"_MsgClass_"','"_itemtype_"')"" style=""height: 18px; font-size: xx-small; line-height: 5px"" title=""Select Field""><br />"
 		}
 			
 	}
 	
 
 Quit Radio_msgcount
}

ClassMethod UpdItemSelect(ItemType As %String, SrcTgt As %String) As %String
{
 
 &js<	var o=document.createElement('option');
 		o.text = ''
 		o.value = ''
 		//document.getElementById('Item'+'#(SrcTgt)#').add(o,null);
 		var x=document.getElementById('Item'+'#(SrcTgt)#');
	    try
	    {
	      x.add(o,null); // standards compliant
	    }
	    catch(ex)
	    {
	      x.add(o); // IE only
	    }
 >
 	For i = 0:1:%session.Data(ItemType_"Count")-1 {
 		s ItemName = %session.Data(ItemType_"List",i)
 		&js<
 		var o=document.createElement('option');
 		o.text = '#(ItemName)#'
 		o.value = '#(ItemName)#'
 		//document.getElementById('Item'+'#(SrcTgt)#').add(o,null)
 		var x=document.getElementById('Item'+'#(SrcTgt)#');
	    try
	    {
	      x.add(o,null); // standards compliant
	    }
	    catch(ex)
	    {
	      x.add(o); // IE only
	    }
	  
 		>
 		
 	}
 	&js<document.getElementById('Item'+'#(SrcTgt)#').style.width="400px";>
 	
 Quit "OK"
}

ClassMethod GetSearchTableClass(pHost As %String) As %String
{
	s tClass = ""
	s tId = ""
	&sql(select ID into :tId from Ens_Config.Item where Name=:pHost)
	
	s tItem = ##class(Ens.Config.Item).%OpenId(tId)
	
	if $ISOBJECT(tItem)
	{
		d tItem.PopulateVirtualSettings()
		
		for i=1:1:tItem.VirtualSettings.Count()
		{
			s tList = tItem.VirtualSettings.GetAt(i)
			if $LG(tList,2) = "SearchTableClass"
			{
				s tClass = $LG(tList,3)
				q
			}
		}
	}
	
	q tClass
}

// Req#4 - Phegel - Added pPropSelectName which is the currently selected property

ClassMethod LoadProperties(pSearchTableClass As %String, pPropSelectName As %String) As %String
{
	s results = ##class(%ResultSet).%New()
	
	s results.ClassName = "Ens.VDoc.SearchTableGenerator"
	s results.QueryName = "EnumerateSearchProps"
	d results.Execute(pSearchTableClass)
	
	while (results.Next())
	{
		s tOutput(results.Data("PropId")) = results.Data("Name")
	}
	
	s tIndex = $O(tOutput(""))
	
	&js<
		// clear all but the first (blank) option
		// Req#4 - Phegel - Added pPropSelectName so it's dynamic.
		var x=document.getElementById('#(pPropSelectName)#');
 		x.options.length = 1;
	>
	
	while (tIndex '= "")
	{
		s tPropName = tOutput(tIndex)
		
		&js<
		
		var o=new Option();
 		o.text = '#(tPropName)#';
 		o.value = '#(tIndex)#'
 		
 		var x=document.getElementById('#(pPropSelectName)#');
 		
	    try
	    {
	      x.add(o,null); // standards compliant
	    }
	    catch(ex)
	    {
	      x.add(o); // IE only
	    }

 		>
 		
 		s tIndex = $O(tOutput(tIndex))
	}
}

Query QSearchTable(STCName As %String = "", PropertyId As %Integer = 0, PropertyValue As %String = "", SourceName As %String = "", TargetName As %String = "", TimeStart As %Date, TimeEnd As %Date) As %Query(ROWSPEC = "MessageBodyId:%String,ID:%Integer,SessionId:%Integer,SourceConfigName:%String,TargetConfigName:%String,Status:Ens.DataType.MessageStatus,TimeCreated:Ens.DataType.UTC,TimeProcessed:Ens.DataType.UTC")
{
}

ClassMethod QSearchTableExecute(ByRef qHandle As %Binary, STCName As %String = "", PropertyId As %Integer = 0, PropertyValue As %String = "", SourceName As %String = "", TargetName As %String = "", TimeStart As %Date, TimeEnd As %Date) As %Status
{
	#dim tSessionId As %String = ""
	#dim tHeaderId As %String = ""
	#dim tMessageId As %String = ""
	
	s tSC = $CLASSMETHOD(STCName, "Search", .output, PropertyId, PropertyValue) Q:'tSC
	s tSessionId=$O(output(tSessionId))
	
	while (tSessionId '= "")
	{
		s tHeaderId = $O(output(tSessionId,tHeaderId))
		while (tHeaderId '= "")
		{
			s tMessageId = $O(output(tSessionId,tHeaderId,tMessageId))
			while (tMessageId '= "")
			{
				//$LB(tTimeCreated,tSourceConfigName,tTargetConfigName)
				s tValues = output(tSessionId,tHeaderId,tMessageId)
				s tTimeCreated = $LIST(tValues,1)
				s tSourceName = $LIST(tValues,2)
				s tTargetName = $LIST(tValues,3)
				

				// does the source or target match?
				if ((tSourceName = SourceName) || (tTargetName = TargetName))
				{
					// is the TimeCreated within the defined range?
					s tTimeCreatedH = $ZDTH(tTimeCreated,3,1)
					s tTimeCreatedDayH = $P(tTimeCreatedH,",",1)
					s tTimeStartDay = $P(TimeStart,",",1)
					s tTimeEndDay = $P(TimeEnd,",",1)
				
					if ((tTimeCreatedDayH >= tTimeStartDay) && (tTimeCreatedDayH <= tTimeEndDay ))
					{
						s tMatch = 1
						// only check seconds if it's the same day
						if ( (tTimeCreatedDayH = tTimeStartDay) || (tTimeCreatedDayH = tTimeEndDay) )
						{
							s tTimeCreatedSecondsH = $P(tTimeCreatedH,",",2)
					
							if ( (tTimeCreatedDayH = tTimeStartDay) && (tTimeCreatedDayH = tTimeEndDay) )
							{
								if ((tTimeCreatedSecondsH < $P(TimeStart,",",2)) || (tTimeCreatedSecondsH > $P(TimeEnd,",",2)))
								{
									s tMatch = 0
								}
							}
							elseif (tTimeCreatedDayH = tTimeStartDay)
							{
								if (tTimeCreatedSecondsH < $P(TimeStart,",",2))
								{
									s tMatch = 0
								}
							}
							else //tTimecreatedDayH = tTimeEndDay
							{
								if (tTimeCreatedSecondsH > $P(TimeEnd,",",2))
								{
									s tMatch = 0
								}
							}
						}
						
						if (tMatch)
						{
							s tRow = $I(qHandle)
							s tMH = ##class(Ens.MessageHeader).%OpenId(tHeaderId)
							s qHandle(tRow) = $LB(tMessageId, tHeaderId, tMH.SessionId, tMH.SourceConfigName, tMH.TargetConfigName, tMH.Status, tMH.TimeCreated, tMH.TimeProcessed)
						}
					}
				}
				
				s tMessageId = $O(output(tSessionId,tHeaderId,tMessageId))
			}
		
			s tHeaderId = $O(output(tSessionId,tHeaderId))
		}
		
		s tSessionId=$O(output(tSessionId))
	}
	
	s qHandle = 0
	
	Quit $$$OK
}

ClassMethod QSearchTableClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = QSearchTableExecute ]
{
	k qHandle
	Quit $$$OK
}

ClassMethod QSearchTableFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = QSearchTableExecute ]
{
	s tRow = $I(qHandle)
	if ($G(qHandle(tRow)) = "")
	{
		s AtEnd = 1
		k Row
		s Row = ""
		Q $$$OK
	}
	
	k Row
	s Row = qHandle(tRow)
	
	Quit $$$OK
}

}
