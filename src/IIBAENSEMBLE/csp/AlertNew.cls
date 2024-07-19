/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.csp.AlertNew Extends %CSP.Page [ ProcedureBlock ]
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

	}
	function Hello() {
		alert('Hello');
	}
	
	function activatesave() {
		
		document.getElementById('SaveChanges').disabled=false;
		
	}
	
	function applyItemAlertNotes() {
		
		var selecteditem = document.InterfaceMonitorParameters.InterfaceS.selectedIndex;
		var itemName = document.InterfaceMonitorParameters.InterfaceS.options[selecteditem].value;
		var EmailText=document.getElementById('EmailText').value.substr(0,250);
		alert("Apply notes to all alerts for "+itemName+": "+EmailText)
		
		
		var save=#server(..ApplyNotesToItemAlerts(itemName,EmailText))#;
		
		
	}

	function loadparamters() {
		
		var selecteditem = document.InterfaceMonitorParameters.InterfaceS.selectedIndex;
		var itemname = document.InterfaceMonitorParameters.InterfaceS.options[selecteditem].value;
		var s=document.getElementById("Parameters");
		s.disabled = true;
		while (s.length>0)
		{
				s.remove(s.length-1);
		}
		var s=document.getElementById("ThresholdValue");
		s.disabled = true;
		while (s.length>0)
		{
				s.remove(s.length-1);
		}
		document.getElementById('ThresholdValue').disabled=true;
		document.getElementById('ThresholdDuration').disabled=true;
		document.getElementById('AlertInterval').disabled=true;
		document.getElementById('NotificationEmail').disabled=true;
		document.getElementById('EmailText').disabled=true;
		document.getElementById('Active').disabled=true;
		document.getElementById('SaveChanges').disabled=true;
		document.getElementById('Remove').disabled=true;
		
		document.getElementById('HourStart').disabled=true;
		document.getElementById('HourEnd').disabled=true;
		document.getElementById('M').disabled=true;
		document.getElementById('T').disabled=true;
		document.getElementById('W').disabled=true;
		document.getElementById('Th').disabled=true;
		document.getElementById('F').disabled=true;
		document.getElementById('Sa').disabled=true;
		document.getElementById('Su').disabled=true;
		
		document.getElementById('HourStart').selectedIndex=0;
		document.getElementById('HourEnd').selectedIndex=0;
		document.getElementById('M').checked=false;
		document.getElementById('T').checked=false;
		document.getElementById('W').checked=false;
		document.getElementById('Th').checked=false;
		document.getElementById('F').checked=false;
		document.getElementById('Sa').checked=false;
		document.getElementById('Su').checked=false;	
				
				
		//document.getElementById('ThresholdValue').selectedIndex=0;
		document.getElementById('ThresholdDuration').value='';
		document.getElementById('AlertInterval').value='';
		document.getElementById('NotificationEmail').value='';
		document.getElementById('Active').checked=false;


		var paramlistbuild = #server(..LoadParameters(itemname))#;
	
	//alert(paramlistbuild);	
			
	}
	
	function loadthreshvalues(element) {
		
		
		var selectedparam = document.getElementById('Parameters'+element).selectedIndex;
		var paramname = document.getElementById('Parameters'+element).options[selectedparam].text;

		var s=document.getElementById('ThresholdValue'+element);
		
		s.disabled = true;
		while (s.length>0)
		{
				s.remove(s.length-1);
		}
		
		document.getElementById('ThresholdValue'+element).disabled=true;
		
		var settinglistbuild = #server(..LoadThresholdValues(paramname,element))#;
		
		document.getElementById('RemoveParam'+element).disabled=false;
		
	}
	
	function loadsettings() {
		
		var selecteditem = document.InterfaceMonitorParameters.InterfaceS.selectedIndex;
		var itemname = document.InterfaceMonitorParameters.InterfaceS.options[selecteditem].value;
		
		var selectedparam = document.InterfaceMonitorParameters.Parameters.selectedIndex;
		var paramID = document.InterfaceMonitorParameters.Parameters.options[selectedparam].value;
		
		document.getElementById('ThresholdValue').disabled=true;
		document.getElementById('ThresholdDuration').disabled=true;
		document.getElementById('AlertInterval').disabled=true;
		document.getElementById('NotificationEmail').disabled=true;
		document.getElementById('EmailText').disabled=true;
		document.getElementById('Active').disabled=true;
		document.getElementById('SaveChanges').disabled=true;
		document.getElementById('Remove').disabled=true;
		
		document.getElementById('HourStart').disabled=true;
		document.getElementById('HourEnd').disabled=true;
		document.getElementById('M').disabled=true;
		document.getElementById('T').disabled=true;
		document.getElementById('W').disabled=true;
		document.getElementById('Th').disabled=true;
		document.getElementById('F').disabled=true;
		document.getElementById('Sa').disabled=true;
		document.getElementById('Su').disabled=true;
		
		document.getElementById('HourStart').selectedIndex=0;
		document.getElementById('HourEnd').selectedIndex=0;
		document.getElementById('M').checked=false;
		document.getElementById('T').checked=false;
		document.getElementById('W').checked=false;
		document.getElementById('Th').checked=false;
		document.getElementById('F').checked=false;
		document.getElementById('Sa').checked=false;
		document.getElementById('Su').checked=false;	
		
		//document.getElementById('ThresholdValue').selectedIndex=0;
		document.getElementById('ThresholdDuration').value='';
		document.getElementById('AlertInterval').value='';
		document.getElementById('NotificationEmail').value='';
		document.getElementById('Active').checked=false;


		var settinglistbuild = #server(..LoadSettings(paramID))#;
	
	//alert(settinglistbuild);	
	
	}
	
	function selectthresh(thresholdvalue) {
		
		var s=document.getElementById("ThresholdValue");
		s.disabled = false;
		var i = 0;
		while (i<s.length)
		{
			if (s.options[i].value == thresholdvalue)
			{
				s.selectedIndex=i;
			}
			i += 1
			
		}
	
	}
	
	
	function remove() {
		var selectedparam = document.InterfaceMonitorParameters.Parameters.selectedIndex;
		var paramID = document.InterfaceMonitorParameters.Parameters.options[selectedparam].value;
		
		var remove = #server(..Remove(paramID))#;
		
		self.document.location="IIBASupport.csp?PageName=AlertNew"
		
	}
	
	function savechanges() {
		
		
		var val = validatesave()
		
		if (val==1) {
			var selectedparam = document.InterfaceMonitorParameters.Parameters.selectedIndex;
			var paramID = document.InterfaceMonitorParameters.Parameters.options[selectedparam].value;
			
			var ThresholdValue = document.getElementById('ThresholdValue').value;
			var ThresholdDuration = document.getElementById('ThresholdDuration').value;
			var AlertInterval = document.getElementById('AlertInterval').value*60;
			var NotificationEmail = document.getElementById('NotificationEmail').value;
			var EmailText = document.getElementById('EmailText').value;
			var Active = document.getElementById('Active').checked;
			var hourstart = document.getElementById('HourStart').selectedIndex;
			var hourend = document.getElementById('HourEnd').selectedIndex;
			var M = document.getElementById('M').checked;
			var T = document.getElementById('T').checked;
			var W = document.getElementById('W').checked;
			var Th = document.getElementById('Th').checked;
			var F = document.getElementById('F').checked;
			var Sa = document.getElementById('Sa').checked;
			var Su = document.getElementById('Su').checked;
			var HolidayOnly=document.getElementById('OnHolidayOnly').checked;
			
			var HList=#server(..GetHolidayCount())#;
			var HItems=HList.split(",");
			var holidays='';
			
			for (i=1; i<=HItems.length; i++) {
				if (document.getElementById('Holiday'+HItems[i-1]).checked ) {
					
					if ( holidays != '' ) {
						holidays=holidays+"^";
					}
					holidays=holidays+HItems[i-1];
				}
			}
				
			
			
			
			
			var save = #server(..SaveChanges(paramID,ThresholdValue,ThresholdDuration,AlertInterval,NotificationEmail,EmailText,Active,hourstart,hourend,M,T,W,Th,F,Sa,Su,HolidayOnly,holidays))#;
			document.getElementById('SaveChanges').disabled=true;
		
			
		}
					
	}
	
	function savenew() {
		var val = validatenewsave()
		
		if (val==1) {
			
			var selecteditem = document.InterfaceMonitorParameters.InterfaceS.selectedIndex;
			var itemname = document.InterfaceMonitorParameters.InterfaceS.options[selecteditem].value;
			
			//var selectedparam = document.InterfaceMonitorParameters.Parameters.selectedIndex;
			//var paramname = document.InterfaceMonitorParameters.Parameters.options[selectedparam].value;
			
			//var selectedThreshold = document.InterfaceMonitorParameters.ThresholdValue.selectedIndex;
			//var ThresholdID = document.InterfaceMonitorParameters.ThresholdValue.options[selectedThreshold].value;
			
			var ThresholdDuration = document.getElementById('ThresholdDuration').value;
			var AlertInterval = document.getElementById('AlertInterval').value*60;
			var NotificationEmail = document.getElementById('NotificationEmail').value;
			var EmailText = document.getElementById('EmailText').value;
			var Active = document.getElementById('Active').checked;
			var hourstart = document.getElementById('HourStart').selectedIndex;
			var hourend = document.getElementById('HourEnd').selectedIndex;
			var M = document.getElementById('M').checked;
			var T = document.getElementById('T').checked;
			var W = document.getElementById('W').checked;
			var Th = document.getElementById('Th').checked;
			var F = document.getElementById('F').checked;
			var Sa = document.getElementById('Sa').checked;
			var Su = document.getElementById('Su').checked;
			var HolidayOnly=document.getElementById('OnHolidayOnly').checked;
			
			var HolCount=#server(..GetHolidayCount())#;
			var holidays='';
			
			for (i=1; i<=HolCount; i++) {
				
				if (document.getElementById('Holiday'+i).checked ) {
					
					if ( holidays != '' ) {
						holidays=holidays+"^";
					}
					holidays=holidays+i;
				}
			}
			
			
			paramTable=document.getElementById('MonitoredParams');
			rowCount=paramTable.rows.length;
			for (i=0; i<rowCount; i++) {
				
				var r=paramTable.rows[i].id;
				r=r.substr(8,r.length);
				
				selectedparam = document.getElementById('Parameters'+r).selectedIndex;
				if (selectedparam>0) {
					paramname = document.getElementById('Parameters'+r).options[selectedparam].value;
					selectedThreshold = document.getElementById('ThresholdValue'+r).selectedIndex;
					ThresholdID = document.getElementById('ThresholdValue'+r).options[selectedThreshold].value;
			
					//alert(selectedparam+', '+paramname+', '+selectedThreshold+', '+ThresholdID);
					var save = #server(..InsertNew(itemname,paramname,ThresholdID,ThresholdDuration,AlertInterval,NotificationEmail,EmailText,Active,hourstart,hourend,M,T,W,Th,F,Sa,Su,HolidayOnly,holidays))#;
				}
			}
		
			self.document.location="IIBASupport.csp?PageName=AlertAdmin";
		
		}
		
		
	}
	
	function addnew() {
		var buildparms = #server(..BuildParameters())#;
	}

	function validatenewsave() {
		
		var errorMsg = "";
			
		
		if (!(document.InterfaceMonitorParameters.InterfaceS.selectedIndex > 0))
			errorMsg += "An Interface Name must be selected.\n";
		
		var k=document.getElementById('MonitoredParams').rows[0].id;
		var firstCount=parseInt(k.substr(8,k.length));
		if (!(document.getElementById('Parameters'+firstCount).selectedIndex > 0))
			errorMsg += "A Parameter must be selected.\n";
	
		var daycount = 0;
				
		if (document.getElementById('M').checked==true)
			daycount += 1
			
		if (document.getElementById('T').checked==true)
			daycount += 1
			
		if (document.getElementById('W').checked==true)
			daycount += 1
			
		if (document.getElementById('Th').checked==true)
			daycount += 1
			
		if (document.getElementById('F').checked==true)
			daycount += 1
			
		if (document.getElementById('Sa').checked==true)
			daycount += 1
			
		if (document.getElementById('Su').checked==true)
			daycount += 1
			
		if (daycount == 0)
			errorMsg += "At least one day must be selected.\n";
			
		if (!((document.getElementById('HourEnd').selectedIndex) > (document.getElementById('HourStart').selectedIndex)))
				errorMsg += "The 'Start Time' must be greater than the 'End Time.'\n";	
		
	
		for (i=0;i<document.getElementById('MonitoredParams').rows.length;i++) {
			k=document.getElementById('MonitoredParams').rows[i].id;
			firstCount=parseInt(k.substr(8,k.length));
			if (!(document.getElementById('ThresholdValue'+firstCount).selectedIndex >= 0))
				errorMsg += "A Threshold must be selected.\n";
		}
		
		if (!(document.InterfaceMonitorParameters.AlertInterval.value))
			errorMsg += "An Alert Interval must be entered.\n";
			
		if (!(document.InterfaceMonitorParameters.NotificationEmail.value))
			errorMsg += "A Notification Email must be entered.\n";
		
		if (errorMsg)
        {
            alert(errorMsg);
            return(0);
        }
        else
        {
	        
	        return(1);
	        			
        }
			
	}
		
	function validatesave() {
		
		var errorMsg = "";
		
		var daycount = 0;
				
		if (document.getElementById('M').checked==true)
			daycount += 1
			
		if (document.getElementById('T').checked==true)
			daycount += 1
			
		if (document.getElementById('W').checked==true)
			daycount += 1
			
		if (document.getElementById('Th').checked==true)
			daycount += 1
			
		if (document.getElementById('F').checked==true)
			daycount += 1
			
		if (document.getElementById('Sa').checked==true)
			daycount += 1
			
		if (document.getElementById('Su').checked==true)
			daycount += 1
			
		if (daycount == 0)
			errorMsg += "At least one day must be selected.\n";
			
		if (!((document.getElementById('HourEnd').selectedIndex) > (document.getElementById('HourStart').selectedIndex)))
				errorMsg += "The 'Start Time' must be greater than the 'End Time.'\n";	
		
		for (i=0;i<document.getElementById('MonitoredParams').rows.length;i++) {
			k=document.getElementById('MonitoredParams').rows[i].id;
			firstCount=parseInt(k.substr(8,k.length));
			if (!(document.getElementById('ThresholdValue'+firstCount).selectedIndex >= 0))
				errorMsg += "A Threshold must be selected.\n";
		}
		
		if (!(document.InterfaceMonitorParameters.ThresholdValue.value))
			errorMsg += "A Threshold Value must be entered.\n";
		
		if (!(document.InterfaceMonitorParameters.ThresholdDuration.value))
			errorMsg += "A Grace Period must be entered.\n";
		
		if (!(document.InterfaceMonitorParameters.AlertInterval.value))
			errorMsg += "An Alert Interval must be entered.\n";
			
		if (!(document.InterfaceMonitorParameters.NotificationEmail.value))
			errorMsg += "A Notification Email must be entered.\n";
		
		if (errorMsg)
        {
            alert(errorMsg);
            return(0);
        }
        else
        {
	        
	        return(1);
	        			
        }
			
	}
	
	
	function addParameter(count) {
		
		var paramTable=document.getElementById('MonitoredParams');
		var rowCount=paramTable.rows.length;
		
		
		var k=document.getElementById('MonitoredParams').rows[rowCount-1].id;
		var nextCount=parseInt(k.substr(8,k.length));
		nextCount=nextCount+1;
		
		
		if (document.getElementById('Parameters'+(nextCount-1)).selectedIndex > 0 ) {
		
			
			var newRow=paramTable.insertRow(rowCount);
			newRow.id='ParamRow'+nextCount;	
			var ps=document.getElementById('Parameters'+(nextCount-1))
			id='Parameters'+nextCount;
			newRow.insertCell(0);
			
		
			newRow.insertCell(1);
	
			select='<SELECT id="'+id+'" OnChange="loadthreshvalues('+nextCount+')">';
			for (i=0;i<ps.length;i++) {
				select=select+'<option value="'+ps.options[i].value+'" title="'+ps.options[i].text+'"> '+ps.options[i].text+'</OPTION>';
			}
			select=select+'</select>';
			newRow.cells[1].innerHTML=select;
		
			newRow.insertCell(2);
			newRow.insertCell(3);
			newRow.insertCell(4);
			newRow.cells[4].innerHTML='<Select Name="ThresholdValue'+nextCount+'" id="ThresholdValue'+nextCount+'" DISABLED></Select></TD>'
			newRow.insertCell(5);
			newRow.insertCell(6);
			newRow.cells[6].innerHTML='<IMG id="RemoveParam'+nextCount+'" src="CustomImages/trash.gif" alt="Remove Parameter" onclick="removeParameter('+nextCount+')" />'
			newRow.insertCell(7);
			newRow.insertCell(8);
			
		} else {
			
			alert('Please select a parameter');
		}
		
	}
	
	function removeParameter(element) {
		
		var mp=document.getElementById('MonitoredParams');
		var row=document.getElementById('ParamRow'+element).rowIndex;
		
		if ( mp.rows.length > 1 ) {
			mp.deleteRow(row);
			
			
			if (row == 0) {
								
				document.getElementById('MonitoredParams').rows[0].cells[0].innerHTML='Parameter';
				document.getElementById('MonitoredParams').rows[0].cells[3].innerHTML='Grace Period';
				document.getElementById('MonitoredParams').rows[0].cells[8].innerHTML='<IMG  src="CustomImages/plus.gif" alt="add Parameter" onclick="addParameter(0)" />';
			}
		
				
		} else {
			alert('At least one parameter must be defined');
		}
	
	
	}




	
  -->
   </script>
  >
}

ClassMethod html()
{
    Set Mode=%request.Get("Mode")
	
	w ##class(IIBAENSEMBLE.csp.AlertAdmin).SubMenu()

	if Mode = "" { 
		//w "Review and Edit Alerts<"
		s Mode="New"
	
	}
	w "<BR>"

	

	Set ProductionName=""
	Set ProductionStatus=""
	set status = ##class(Ens.Director).GetProductionStatus(.ProductionName,.ProductionStatus)

	set ParamString = ""
	set paramstringrs=##class(%ResultSet).%New()
	Do paramstringrs.Prepare("SELECT DISTINCT ItemName from IIBAENSEMBLE_Monitor.ItemParameters")
	Do paramstringrs.Execute()
		while paramstringrs.Next() {
			set ParamString = ParamString_paramstringrs.Data("ItemName")_","
		}
	Do paramstringrs.Close()

	W "<Form Name=""InterfaceMonitorParameters"" id=""InterfaceMonitorParameters"">"
	W "<Table cellpadding=10><TR><TD>"
	W "<Table><TR><TD>Interface Name</TD><TD>"
	if Mode = "" { 
		W "<Select Name=""InterfaceS"" id=""InterfaceS"" OnChange=""loadparamters()"">"
	} ElseIf Mode = "New" {
		W "<Select Name=""InterfaceS"" id=""InterfaceS"" >"
	}
	W "<Option Value="""">"

	set production=##class(Ens.Config.Production).%OpenId(ProductionName)
	K ^||ItemNames
	for i=1:1:production.Items.Count() {	
	  	s item=production.Items.GetAt(i)
	  	s ^||ItemNames(item.Name) = item.Name
	}
	Set key = $Order(^||ItemNames(""))
	While (key '= "") {
	   	if Mode = "" { 
			if $FIND(ParamString,$ZCONVERT(^||ItemNames(key),"U"))'=0 {
				W "<Option Value="""_^||ItemNames(key)_""">"_^||ItemNames(key)
			}
		} Elseif Mode = "New" { 
	   		W "<Option Value="""_^||ItemNames(key)_""">"_^||ItemNames(key)
		}
	   	Set key = $Order(^||ItemNames(key))
	}
	K ^||ItemNames
	W "</Select></TD></TR>"	
	W "<TR>"
	
	//  ### one row per parameter / threshold
	W "<TABLE id='MonitoredParams' name='MonitoredParams'><TR id='ParamRow0'>"
	W "<TD width=110>Parameter</TD><TD><Select Name='Parameters0' id='Parameters0' "
	if Mode = "" { 
		W " DISABLED OnChange='loadsettings(0)'>"
	} Elseif Mode = "New" { 
		W " OnChange='loadthreshvalues(0)'>"
		W "<Option Value=''>"
		set rs=##class(%ResultSet).%New()
		Do rs.Prepare("SELECT itemvalue, itemdescription from IIBAENSEMBLE_Monitor.tblItems where itemtype = 'Parameter' order by itemdescription")
		Do rs.Execute()
		while rs.Next() {
			set tParam = rs.Data("itemvalue")
			set tParamdesc = rs.Data("itemdescription")
			W "<Option Value="""_tParam_""" "
			W " title='"_tParamdesc_"'"
			//W ">"_tParamdesc
			W ">"_tParam
		}
	}
	W "</Select></TD>"
	
	W "<TD width=5>&nbsp;</TD><TD>Threshold Value</TD><TD><Select Name='ThresholdValue0' id='ThresholdValue0' "
	if Mode = "" { 
		W " OnChange=""activatesave()"" DISABLED>"
	} ElseIf Mode = "New" {
		W " DISABLED></Select></TD>"
	}
	
	w "</TD><TD length=5>&nbsp;</TD><TD><IMG id='RemoveParam0' src='CustomImages/trash.gif' alt='Remove Parameter' onclick='removeParameter(0)' DISABLED />"

	w "</TD><TD length=5>&nbsp;</TD><TD><IMG src='CustomImages/plus.gif' alt='Add Parameter' onclick='addParameter(0)' />"
	
	w "</TR><Table>"

	W "<TR><TD>Grace Period</TD><TD><Input Type='Text' Name='ThresholdDuration' id='ThresholdDuration' Value='' title='Number of seconds the alert condition must persist before sending an alert' "
	if Mode = "" { 
		W " OnChange=""activatesave()"" DISABLED"

	}
	W " >(seconds)</TD></TR>"

	W "<TR><TD>Alert Interval</TD><TD><Input Type=""Text"" Name='AlertInterval' id='AlertInterval' Value='' title='When the alert condition persists, how long to wait between alert notifications' "
	if Mode = "" { 
		W " OnChange=""activatesave()"" DISABLED> "
	} 
	W "> (minutes)</TD></TR>"
	
	W "<TR><TD>Cycle Interface</TD><TD><Input type='checkbox' name='CycleIf' id='CycleIf' OnClick='activatesave()' title='if not disabled, stop and start the interface when an alert is sent' disabled></TD></TR>"

	if Mode = "" { 
		W "<TR><TD>Schedule</TD><TD>"
		w "Hour Start:&nbsp;&nbsp;<select NAME=""HourStart"" ID=""HourStart"" OnChange=""activatesave()"" DISABLED>"
		For i = 0:1:24 {
			w "<option VALUE="""_i_""">"_i
		}
		w "</select>&nbsp;&nbsp;"
		w "Hour End:&nbsp;&nbsp;<select NAME=""HourEnd"" ID=""HourEnd"" OnChange=""activatesave()"" DISABLED>"
		For i = 0:1:24 {
			w "<option VALUE="""_i_""">"_i
		}
		w "</select><br>"
		w "M: <Input Type=""checkbox"" Name=""M"" id='M' OnClick=""activatesave()"" DISABLED> "
		w "T: <Input Type=""checkbox"" Name=""T"" id='T' OnClick=""activatesave()"" DISABLED> "
		w "W: <Input Type=""checkbox"" Name=""W"" id='W' OnClick=""activatesave()"" DISABLED> "
		w "Th: <Input Type=""checkbox"" Name=""Th"" id='Th'OnClick=""activatesave()"" DISABLED> "
		w "F: <Input Type=""checkbox"" Name=""F"" id='F' OnClick=""activatesave()"" DISABLED> "
		w "Sa: <Input Type=""checkbox"" Name=""Sa"" id='Sa' OnClick=""activatesave()"" DISABLED> "
		w "Su: <Input Type=""checkbox"" Name=""Su"" id='Su' OnClick=""activatesave()"" DISABLED> "
		w "</TD></TR>"
	} ElseIf Mode = "New" {
		W "<TR><TD>Schedule</TD><TD>"
		w "Hour Start:&nbsp;&nbsp;<select NAME=""HourStart"" id='HourStart'>"
		For i = 0:1:24 {
			If i = 0 {
				w "<option VALUE="""_i_""" selected>"_i
			} Else {
				w "<option VALUE="""_i_""">"_i
			}
		}
		w "</select>&nbsp;&nbsp;"
		w "Hour End:&nbsp;&nbsp;<select NAME=""HourEnd"" id='HourEnd'>"
		For i = 0:1:24 {
			If i = 24 {
				w "<option VALUE="""_i_""" selected>"_i
			} Else {
				w "<option VALUE="""_i_""">"_i
			}
		}
		w "</select><br>"
		w "M: <Input Type=""checkbox"" Name=""M"" id='M' checked=true> "
		w "T: <Input Type=""checkbox"" Name=""T"" id='T' checked=true> "
		w "W: <Input Type=""checkbox"" Name=""W"" id='W' checked=true> "
		w "Th: <Input Type=""checkbox"" Name=""Th"" id='Th' checked=true> "
		w "F: <Input Type=""checkbox"" Name=""F"" id='F' checked=true> "
		w "Sa: <Input Type=""checkbox"" Name=""Sa"" id='Sa'checked=true> "
		w "Su: <Input Type=""checkbox"" Name=""Su"" id='Su' checked=true> "
		w "</TD></TR>"
	}


	if Mode = "" { 
		W "<TR><TD>Notification Email</TD><TD><Input Type=""Text"" Style=""width:500"" Name=""NotificationEmail"" id='NotificationEmail' Value="""" OnChange=""activatesave()"" DISABLED></TD></TR>"
	} ElseIf Mode = "New" {
		W "<TR><TD>Notification Email</TD><TD><Input Type=""Text"" Style=""width:500"" Name=""NotificationEmail"" id='NotificationEmail' Value=""""></TD></TR>"
	}

	W "</TABLE>"
	W "</TD><TD>"
	W "<Table>"
	Set hrs=##class(%ResultSet).%New()
	Set hrs=##class(%ResultSet).%New()
	Set HolidayList="Select * from IIBAENSEMBLE_Monitor.tblItems where itemtype='Holiday'"
	D hrs.Prepare(HolidayList)
	D hrs.Execute()

	If (hrs'="") {
	
		// S AlertHolidays=$LFS("1^3^6","^")
		
		W "<TR><TD>&nbsp;</TD></TR>"
		W !,"<TR><TD>Holiday Alert Only</TD>"
		// W "<TD>*",rs.Data("HolidayOnly"),"*</TD>"
		W "<TD><Input Type=""checkbox"" Name=""OnHolidayOnly"" id=""OnHolidayOnly"" OnClick=""activatesave()"""
	
		W "></TD></TR>"
		W "<TR><TD></TD></TR><TR><TD>Holidays</TD></TR>"
	
	
		While ( hrs.Next() ) {
			Set HolidayName=hrs.Data("itemdescription")
			Set HolidayID=hrs.Data("itemvalue")
			//W HolidayName,!
			W !,"<TR><TD>&nbsp;&nbsp;&nbsp;&nbsp;",HolidayName,"</TD>"
			W "<TD><Input Type=""checkbox"" Name='Holiday"_HolidayID_"' id='Holiday"_HolidayID_"' OnClick=""activatesave()"">"
			W "</TD></TR>"
		} 
		W "</Table></TD></TR><TR><TD>"
		W "<Table>"
	}
	
  	//Email Text
  	w "<TR><TD colSpan=2><Table><TR><TD>Notes (optional)&nbsp;&nbsp;&nbsp;&nbsp;</TD></TR><TR><TD style='fontSize=""small"";font=""italic""'>(Max 250 characters)</TD></TR></Table></TD>"
  	W "<TD><TextArea id='EmailText' rows='5' cols='45' title='Optional Email Text (250 chars max)' OnChange='activatesave()'></TextArea></TD></TR>"
 	W "<TR><TD colspan=2>&nbsp;</TD><TD><Input type='button' value='Apply Notes to all alerts for this item' onclick='applyItemAlertNotes()'/></TD></TR>"

	if Mode = "" { 
		W "<TR><TD>Active</TD><TD><Input Type=""checkbox"" Name=""Active"" id=""Active"" OnClick=""activatesave()"" DISABLED></TD></TR>"
	} ElseIf Mode = "New" {
		W "<TR><TD>Active</TD><TD><Input Type=""checkbox"" Name=""Active"" id='Active'></TD></TR>"
	}

	w "<TR><TD></TD><TD>"
	
	if Mode = "" { 
		w "<Input DISABLED Type=""Button"" Style=""width:100"" Name=""SaveChanges"" id='SaveChanges' Value=""Save Changes"" onclick=""savechanges()"">"
	} ElseIf Mode = "New" {
	}

	if Mode = "" { 
		w "<Input DISABLED Type=""Button"" Style=""width:100"" Name=""Remove"" id='Remove' Value=""Remove"" onclick=""remove()"">"
	} ElseIf Mode = "New" {
	}

	if Mode = "" { 
		w "<Input Type=""Button"" Style=""width:100"" Name=""Add"" id=""Add"" Value=""Add New"" onclick='self.document.location=""IIBASupport.csp?PageName=AlertNew&Mode=New""'>"
	} ElseIf Mode = "New" {
		w "<Input Type=""Button"" Style=""width:100"" Name=""Save"" id=""Save"" Value=""Save New"" onclick=""savenew()"">"
	}

	if Mode = "" { 
		w "<Input Type=""Button"" Style=""width:100"" Name=""Home"" id=""Home"" Value=""Home"" onclick='self.document.location=""IIBASupport.csp?PageName=AlertNew""'></TD></TR>"
	} ElseIf Mode = "New" {
	}


	W "</Table>"
	W "</Table>"
	W "</Form>"
	&html<
	<script language=javascript>
	
	document.getElementById('linkAlertAdmin').style.color = 'red';
	document.getElementById('link'+'#(%request.Get("PageName"))#').style.color = 'red';

	</script>	
	>
}

ClassMethod BuildParameters() As %String [ Language = objectscript ]
{
 	&js<
 	var s=document.getElementById("Parameters");
 	var o=document.createElement('option');
 	o.text = ' '
 	o.value = ' '
 	s.add(o);	
 	s.disabled = false;
 	>
 	//&js<document.getElementById('ThresholdValue').disabled=false;>
 	&js<document.getElementById('ThresholdDuration').disabled=false;>
 	&js<document.getElementById('AlertInterval').disabled=false;>
 	&js<document.getElementById('NotificationEmail').disabled=false;>
 	&js<document.getElementById('EmailText').disabled=false;>
 	&js<document.getElementById('Active').disabled=false;>
 	&js<document.getElementById('Save').disabled=false;>
 	&js<document.getElementById('Add').disabled=true;>
 			
 	
 	set rs=##class(%ResultSet).%New()
 	Do rs.Prepare("SELECT itemvalue from IIBAENSEMBLE_Monitor.tblItems where itemtype = 'Parameter' order by itemdescription")
 	Do rs.Execute()
 	while rs.Next() {
 		set tParam = rs.Data("itemvalue")
 		&js<
 		var s=document.getElementById("Parameters");
 		var o=document.createElement('option');
 		o.text = '#(tParam)#'
 		o.value = '#(tParam)#'
 		s.add(o);	
 		>
 		
 	}
 	Do rs.Close()
}

ClassMethod GetHolidayCount() As %String [ Language = objectscript ]
{
 		
 	Set HList=""
 	
 	Set rs=##class(%ResultSet).%New()
 	Do rs.Prepare("select itemvalue From IIBAENSEMBLE_Monitor.tblItems where itemtype='Holiday'")
 	Do rs.Execute()
 	
 	While rs.Next() {
 		If (HList="") {
 			S HList=rs.Get("itemvalue")
 		} else {
 			S HList=HList_","_rs.Get("itemvalue")
 		}
 	}
 	
 	
 	
 	Quit HList
}

ClassMethod InsertNew(itemname As %String, paramname As %String, ThresholdID As %String, ThresholdDuration As %String, AlertInterval As %String, NotificationEmail As %String, EmailText As %String, Active As %String, hourstart As %String, hourend As %String, M As %String, T As %String, W As %String, Th As %String, F As %String, Sa As %String, Su As %String, HolidayOnly As %String, holidays As %String) As %String [ Language = objectscript ]
{
 		
 	Set ThresholdValue=""
 			
 	// Get ThresholdValue using threshold ID
 	&sql(Select Top 1 itemvalue 
 		into :ThresholdValue 
 		From IIBAENSEMBLE_Monitor.tblItems
 		Where ID=:ThresholdID)
 	
 	set rs=##class(%ResultSet).%New()
 	Do rs.Prepare("INSERT INTO IIBAENSEMBLE_Monitor.ItemParameters (ItemName,Parameter,Threshold,ThresholdID,ThresholdDuration,AlertDuration,NotificationEmail,EmailText,Active,HolidayOnly,Holidays) VALUES ('"_itemname_"','"_paramname_"','"_ThresholdValue_"','"_ThresholdID_"','"_ThresholdDuration_"','"_AlertInterval_"','"_NotificationEmail_"','"_EmailText_"',"_Active_","_HolidayOnly_",'"_holidays_"')")
 	Do rs.Execute()
 	
 	set rs=##class(%ResultSet).%New()
 	Do rs.Prepare("SELECT MAX(ID) as ID from IIBAENSEMBLE_Monitor.ItemParameters where ItemName = '"_itemname_"' and Parameter = '"_paramname_"'")
 	Do rs.Execute()
 	while rs.Next() {
 			set paramID = rs.Data("ID")
 	}
 	
 	set rs=##class(%ResultSet).%New()
 	Do rs.Prepare("INSERT INTO IIBAENSEMBLE_Monitor.tblSchedules (ParameterID,HourStart,HourEnd,M,T,W,Th,F,Sa,Su) VALUES ("_paramID_","_hourstart_","_hourend_","_M_","_T_","_W_","_Th_","_F_","_Sa_","_Su_")")
 	Do rs.Execute()
 	
 	set updatestatus = "ok"
 	
 	Quit updatestatus
}

ClassMethod LoadParameters(itemname As %String) As %String [ Language = objectscript ]
{
 		
 	set rs=##class(%ResultSet).%New()
 	Do rs.Prepare("SELECT ID, Parameter from IIBAENSEMBLE_Monitor.ItemParameters where ItemName = '"_itemname_"' order by Parameter")
 	Do rs.Execute()
 	set i = 0
 	while rs.Next() {
 		set tParam = rs.Data("Parameter")
 		set tPID = rs.Data("ID")
 		if i=0 { set paramID = tPID }
 		set i = i+1
 	//&js<alert('#(tParam)#');>	
 		&js<
 		var s=document.getElementById("Parameters");
 		var o=document.createElement('option');
 		o.text = '#(tParam)#'
 		o.value = '#(tPID)#'
 		s.add(o);	
 		s.disabled = false;
 		>
 		
 	}
 	Do rs.Close()
 	
 	if i > 0 {
 		
 		&js<loadthreshvalues();>
 		
 		set rs=##class(%ResultSet).%New()
 		Do rs.Prepare("SELECT Threshold, ThresholdDuration, AlertDuration, NotificationEmail, Active from IIBAENSEMBLE_Monitor.ItemParameters where ID = '"_paramID_"'")
 		Do rs.Execute()
 		while rs.Next() {
 			set tThreshold = rs.Data("Threshold")
 			set tThresholdDuration = rs.Data("ThresholdDuration")
 			set tAlertDuration = rs.Data("AlertDuration")/60
 			set tNotificationEmail = rs.Data("NotificationEmail")
 			set tActive = rs.Data("Active")
 			&js<document.getElementById('ThresholdValue').disabled=false;>
 			&js<document.getElementById('ThresholdDuration').disabled=false;>
 			&js<document.getElementById('AlertInterval').disabled=false;>
 			&js<document.getElementById('NotificationEmail').disabled=false;>
 			&js<document.getElementById('EmailText').disabled=false;>
 			&js<document.getElementById('Active').disabled=false;>
 			//&js<document.getElementById('SaveChanges').disabled=false;>
 			&js<document.getElementById('Remove').disabled=false;>
 			&js<selectthresh('#(tThreshold)#');>
 			&js<document.getElementById('ThresholdDuration').value='#(tThresholdDuration)#';>
 			&js<document.getElementById('AlertInterval').value='#(tAlertDuration)#';>
 			&js<document.getElementById('NotificationEmail').value='#(tNotificationEmail)#';>
 			&js<document.getElementById('Active').checked=#(tActive)#;>
 		}
 		do rs.Close()
 		
 		&js<document.getElementById('HourStart').selectedIndex=0;>
 		&js<document.getElementById('HourEnd').selectedIndex=24;>
 		&js<document.getElementById('HourStart').disabled=false;>
 		&js<document.getElementById('HourEnd').disabled=false;>
 		&js<document.getElementById('M').disabled=false;>
 		&js<document.getElementById('T').disabled=false;>
 		&js<document.getElementById('W').disabled=false;>
 		&js<document.getElementById('Th').disabled=false;>
 		&js<document.getElementById('F').disabled=false;>
 		&js<document.getElementById('Sa').disabled=false;>
 		&js<document.getElementById('Su').disabled=false;>
 
 		set rs=##class(%ResultSet).%New()
 		Do rs.Prepare("SELECT s.HourStart, s.HourEnd, s.M, s.T, s.W, s.Th, s.F, s.Sa, s.Su from IIBAENSEMBLE_Monitor.ItemParameters P inner join IIBAENSEMBLE_Monitor.tblSchedules S on P.ID = S.ParameterID where P.ID = "_paramID_"")
 		Do rs.Execute()
 		
 		while rs.Next() {
 			set tHourStart = rs.Data("HourStart")
 			set tHourEnd = rs.Data("HourEnd")
 			set tM = rs.Data("M")
 			set tT = rs.Data("T")
 			set tW = rs.Data("W")
 			set tTh = rs.Data("Th")
 			set tF = rs.Data("F")
 			set tSa = rs.Data("Sa")
 			set tSu = rs.Data("Su")
 			&js<document.getElementById('HourStart').selectedIndex=#(tHourStart)#;>
 			&js<document.getElementById('HourEnd').selectedIndex=#(tHourEnd)#;>
 			&js<document.getElementById('M').checked=#(tM)#;>
 			&js<document.getElementById('T').checked=#(tT)#;>
 			&js<document.getElementById('W').checked=#(tW)#;>
 			&js<document.getElementById('Th').checked=#(tTh)#;>
 			&js<document.getElementById('F').checked=#(tF)#;>
 			&js<document.getElementById('Sa').checked=#(tSa)#;>
 			&js<document.getElementById('Su').checked=#(tSu)#;>	
 		}
 		do rs.Close()
 		
 	}
 	
 	
 	set paramlistbuild = "ok"
 	
 	Quit paramlistbuild
}

ClassMethod LoadSettings(paramID As %String) As %String [ Language = objectscript ]
{
 		
 	&js<loadthreshvalues();>
 	
 	set rs=##class(%ResultSet).%New()
 	Do rs.Prepare("SELECT Threshold, ThresholdDuration, AlertDuration, NotificationEmail, EmailText, Active from IIBAENSEMBLE_Monitor.ItemParameters where ID = "_paramID_"")
 	Do rs.Execute()
 	while rs.Next() {
 		set tThreshold = rs.Data("Threshold")
 		set tThresholdDuration = rs.Data("ThresholdDuration")
 		set tAlertDuration = rs.Data("AlertDuration")/60
 		set tNotificationEmail = rs.Data("NotificationEmail")
 		set tEmailText = rs.Data("EmailText")
 		set tActive = rs.Data("Active")
 		&js<document.getElementById('ThresholdValue').disabled=false;>
 		&js<document.getElementById('ThresholdDuration').disabled=false;>
 		&js<document.getElementById('AlertInterval').disabled=false;>
 		&js<document.getElementById('NotificationEmail').disabled=false;>
 		&js<document.getElementById('EmailText').disabled=false;>
 		&js<document.getElementById('Active').disabled=false;>
 		//&js<document.getElementById('SaveChanges').disabled=false;>
 		&js<document.getElementById('Remove').disabled=false;>
 		&js<selectthresh('#(tThreshold)#');>
 		&js<document.getElementById('ThresholdDuration').value='#(tThresholdDuration)#';>
 		&js<document.getElementById('AlertInterval').value='#(tAlertDuration)#';>
 		&js<document.getElementById('NotificationEmail').value='#(tNotificationEmail)#';>
 		&js<document.getElementById('EmailText').value='#(tEmailText)#';>
 		&js<document.getElementById('Active').checked=#(tActive)#;>
 	}
 	
 	do rs.Close()
 	
 	
 		&js<document.getElementById('HourStart').selectedIndex=0;>
 		&js<document.getElementById('HourEnd').selectedIndex=24;>
 		&js<document.getElementById('HourStart').disabled=false;>
 		&js<document.getElementById('HourEnd').disabled=false;>
 		&js<document.getElementById('M').disabled=false;>
 		&js<document.getElementById('T').disabled=false;>
 		&js<document.getElementById('W').disabled=false;>
 		&js<document.getElementById('Th').disabled=false;>
 		&js<document.getElementById('F').disabled=false;>
 		&js<document.getElementById('Sa').disabled=false;>
 		&js<document.getElementById('Su').disabled=false;>
 	
 		set rs=##class(%ResultSet).%New()
 		Do rs.Prepare("SELECT s.HourStart, s.HourEnd, s.M, s.T, s.W, s.Th, s.F, s.Sa, s.Su from IIBAENSEMBLE_Monitor.ItemParameters P left outer join IIBAENSEMBLE_Monitor.tblSchedules S on P.ID = S.ParameterID where P.ID = "_paramID_"")
 		Do rs.Execute()
 		
 		while rs.Next() {
 			set tHourStart = rs.Data("HourStart")
 			set tHourEnd = rs.Data("HourEnd")
 			set tM = rs.Data("M")
 			set tT = rs.Data("T")
 			set tW = rs.Data("W")
 			set tTh = rs.Data("Th")
 			set tF = rs.Data("F")
 			set tSa = rs.Data("Sa")
 			set tSu = rs.Data("Su")
 			&js<document.getElementById('HourStart').selectedIndex=#(tHourStart)#;>
 			&js<document.getElementById('HourEnd').selectedIndex=#(tHourEnd)#;>
 			&js<document.getElementById('M').checked=#(tM)#;>
 			&js<document.getElementById('T').checked=#(tT)#;>
 			&js<document.getElementById('W').checked=#(tW)#;>
 			&js<document.getElementById('Th').checked=#(tTh)#;>
 			&js<document.getElementById('F').checked=#(tF)#;>
 			&js<document.getElementById('Sa').checked=#(tSa)#;>
 			&js<document.getElementById('Su').checked=#(tSu)#;>	
 		}
 		do rs.Close()
 	
 	set settinglistbuild = "ok"
 	
 	Quit settinglistbuild
}

ClassMethod LoadThresholdValues(paramname As %String, element As %String) As %String [ Language = objectscript ]
{
 	set rs=##class(%ResultSet).%New()
 	Do rs.Prepare("SELECT ID, itemvalue, itemdescription from IIBAENSEMBLE_Monitor.tblItems where itemtype = '"_paramname_"Value' order by itemdescription")
 	Do rs.Execute()
 	while rs.Next() {
 		set tID = rs.Data("ID")
 		set tDesc = rs.Data("itemdescription")
 		set elmentId="ThresholdValue"_element
 		
 	//&js<alert('#(tParam)#');>	
 		&js<
 		var s=document.getElementById('#(elmentId)#');
 		var o=document.createElement('option');
 		o.text = '#(tDesc)#';
 		o.value = '#(tID)#';
 		try {
 			s.add(o,null);
 		} catch(ex) {
	 		s.add(o);
 		}	
 		s.disabled = false;
 		>
 		
 		
 	}
}

ClassMethod Remove(paramID As %String) As %String [ Language = objectscript ]
{
 		
 	set rs=##class(%ResultSet).%New()
 	Do rs.Prepare("DELETE from IIBAENSEMBLE_Monitor.ItemParameters where ID = "_paramID_"")
 	Do rs.Execute()
 	
 	set rs=##class(%ResultSet).%New()
 	Do rs.Prepare("DELETE from IIBAENSEMBLE_Monitor.tblSchedules where ParameterID = "_paramID_"")
 	Do rs.Execute()
 		
 	set removestatus = "ok"
 	
 	Quit removestatus
}

ClassMethod SaveChanges(paramID As %String, ThresholdValue As %String, ThresholdDuration As %String, AlertInterval As %String, NotificationEmail As %String, EmailText As %String, Active As %String, hourstart As %String, hourend As %String, M As %String, T As %String, W As %String, Th As %String, F As %String, Sa As %String, Su As %String) As %String [ Language = objectscript ]
{
 		
 	set rs=##class(%ResultSet).%New()
 	Do rs.Prepare("UPDATE IIBAENSEMBLE_Monitor.ItemParameters set Threshold = '"_ThresholdValue_"', ThresholdDuration = '"_ThresholdDuration_"', AlertDuration = '"_AlertInterval_"', NotificationEmail = '"_NotificationEmail_"', EmailText='"_EmailText_"', Active = "_Active_" where ID = "_paramID_"")
 	Do rs.Execute()
 	
 	set rs=##class(%ResultSet).%New()
 	Do rs.Prepare("UPDATE IIBAENSEMBLE_Monitor.tblSchedules set HourStart="_hourstart_", HourEnd="_hourend_",M="_M_",T="_T_",W="_W_",Th="_Th_",F="_F_",Sa="_Sa_",Su="_Su_" where ParameterID="_paramID_"")
 	Do rs.Execute()
 	
 	
 	set updatestatus = "ok"
 	
 	Quit updatestatus
}

ClassMethod ApplyNotesToItemAlerts(itemName As %String, emailText As %String) As %String
{
	if (itemName'="") {
		s rs=##class(%ResultSet).%New()
		Set UpdateString="UPDATE IIBAENSEMBLE_Monitor.ItemParameters set EmailText='"_emailText_"' "
		set UpdateString=UpdateString_" Where ItemName='"_itemName_"'"
		Do rs.Prepare(UpdateString)
 		Do rs.Execute()
	}
	
	Quit $$$OK
}

}
