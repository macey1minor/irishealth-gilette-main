/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.csp.AlertEdit Extends %CSP.Page [ ProcedureBlock ]
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
	
	function applyItemAlertNotes(itemName) {
		
		var EmailText=document.getElementById('EmailText').value.substr(0,250);
		alert("Apply notes to all alerts for "+itemName+": "+EmailText)
		
		
		var save=#server(..ApplyNotesToItemAlerts(itemName,EmailText))#;
		
		
	}
	
	function savechanges(paramID) {
		
		var val = validatesave();
		
		if (val==1) {
			//var selectedparam = document.InterfaceMonitorParameters.Parameters.selectedIndex;
			//var paramID = document.InterfaceMonitorParameters.Parameters.options[selectedparam].value;
			
			var ThresholdID = document.getElementById('ThresholdValue').value;
			var ThresholdDuration = document.getElementById('ThresholdDuration').value;
			var AlertInterval = document.getElementById('AlertInterval').value*60;
			var NotificationEmail = document.getElementById('NotificationEmail').value;
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
			var EmailText=document.getElementById('EmailText').value.substr(0,250);
			
			
			var HList=#server(..GetHolidayCount())#;
			var HItems=HList.split(",");
			var holidays='';

			if (HList=='') {
				alert("No holidays defined");
			}

			
			for (i=1; i<=HItems.length; i++) {
				
				if (document.getElementById('Holiday'+HItems[i-1]).checked ) {
					
					if ( holidays != '' ) {
						holidays=holidays+"^";
					}
					holidays=holidays+HItems[i-1];
				}
			}
				
			
			var save = #server(..SaveChanges(paramID,ThresholdID,ThresholdDuration,AlertInterval,NotificationEmail,EmailText,Active,hourstart,hourend,M,T,W,Th,F,Sa,Su,HolidayOnly,holidays))#;
			document.getElementById('SaveChanges').disabled=true;
			
			self.document.location="IIBASupport.csp?PageName=AlertAdmin"
		
			
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
		
		
		
		if (!(document.InterfaceMonitorParameters.ThresholdValue.value))
			errorMsg += "A Threshold Value must be entered.\n";
		
		if (!(document.InterfaceMonitorParameters.ThresholdDuration.value))
			errorMsg += "A Grace Period must be entered.\n";
		
		if (!(document.InterfaceMonitorParameters.AlertInterval.value))
			errorMsg += "An Alert Interval must be entered.\n";
			
		if (!(document.InterfaceMonitorParameters.NotificationEmail.value))
			errorMsg += "A Notification Email must be entered.\n";
			
		if ( document.InterfaceMonitorParameters.EmailText.value.length>250 )
			errorMsg += "Instructions must be 250 characters or less.\n";
		
		
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


  -->
   </script>
  >
}

ClassMethod html()
{
	w ##class(IIBAENSEMBLE.csp.AlertAdmin).SubMenu()
	Set Mode=%request.Get("Mode")
	Set paramID=%request.Get("paramID")


	if Mode = "Edit" { 
		w "<b>Edit Alert</b>"
	}
	w "<br>"
	

	Set rs=##class(%ResultSet).%New()
	set ParamSelect = ""
	set ParamSelect = ParamSelect_"Select "
	set ParamSelect = ParamSelect_"p.ID, p.Active, p.AlertDuration/60 as AlertDuration, p.ItemName, p.NotificationEmail, p.Parameter, p.Threshold, p.ThresholdDuration, p.Holidays, p.HolidayOnly, p.EmailText, "
	set ParamSelect = ParamSelect_"s.HourStart, s.HourEnd, s.M, s.T, s.W, s.Th, s.F, s.Sa, s.Su "
	set ParamSelect = ParamSelect_"from IIBAENSEMBLE_Monitor.ItemParameters P "	
	set ParamSelect = ParamSelect_"inner join IIBAENSEMBLE_Monitor.tblSchedules S "
	set ParamSelect = ParamSelect_"on P.ID = S.ParameterID "
	set ParamSelect = ParamSelect_"where p.ID = "_paramID
	Do rs.Prepare(ParamSelect)
	Do rs.Execute()
	Do rs.Next()
	//w ParamSelect

	set rsItemDesc=##class(%ResultSet).%New()
	do rsItemDesc.Prepare("select itemdescription from IIBAENSEMBLE_Monitor.tblItems where itemvalue = '"_rs.Data("Parameter")_"' and itemtype = 'Parameter'")
	do rsItemDesc.Execute()
	do rsItemDesc.Next()


	W "<Form Name=""InterfaceMonitorParameters"" Id=""InterfaceMonitorParameters"">"
	W "<Table cellpadding=10><TR><TD>"
	W "<Table><TR><TD>Interface Name</TD><TD>"
	if Mode = "Edit" { 
		W "<Select Name=""InterfaceS"" Id=""InterfaceS"" DISABLED>"
		W "<Option Value="""_rs.Data("ID")_""">"_rs.Data("ItemName")
		W "</Select></TD></TR>"	
	}

	W "<TR><TD>Parameter</TD><TD>"
	if Mode = "Edit" { 
		W "<Table><TR><TD>"
		W "<Select Name=""Parameters"" Id=""Parameters"" DISABLED >"
		W "<Option Value="""_rs.Data("Parameter")_""" >"_rs.Data("Parameter")
		W "</Select></TD><TD>&nbsp;</TD><TD style='font-size:70%;font-style=italic'>"_rsItemDesc.Data("itemdescription")_"</TD></Table></TD></TR>"
	}

	if Mode = "Edit" { 
		W "<TR><TD>Threshold Value</TD><TD><Select Name=""ThresholdValue"" Id=""ThresholdValue"" OnChange=""activatesave()"" >"
	
		set rsThresholdValues=##class(%ResultSet).%New()
		do rsThresholdValues.Prepare("select ID, itemdescription, itemvalue, itemtype from IIBAENSEMBLE_monitor.tblitems where itemtype = '"_rs.Data("Parameter")_"Value'")
		//w "select itemdescription, itemvalue, itemtype from IIBAENSEMBLE_monitor.tblitems where itemtype = '"_rs.Data("Parameter")_"Value'"
		do rsThresholdValues.Execute()
		while rsThresholdValues.Next() {
			if rsThresholdValues.Data("itemvalue") = rs.Data("Threshold") {
				W "<Option Value="""_rsThresholdValues.Data("ID")_""" SELECTED>"_rsThresholdValues.Data("itemdescription")
			} Else {
				W "<Option Value="""_rsThresholdValues.Data("ID")_""">"_rsThresholdValues.Data("itemdescription")
			}
		}
		W "</Select></TD></TR>"
	}

	if Mode = "Edit" { 
		W "<TR><TD>Grace Period</TD><TD><Input Type=""Text"" Name=""ThresholdDuration"" Id=""ThresholdDuration"" Value="""_rs.Data("ThresholdDuration")_""" title='Amount of time the alert condition should persist before triggering an alert' OnChange=""activatesave()"" > (seconds)</TD></TR>"
	}

	if Mode = "Edit" { 
		W "<TR><TD>Alert Interval</TD><TD><Input Type=""Text"" Name=""AlertInterval"" Id=""AlertInterval"" Value="""_rs.Data("AlertDuration")_""" title='How often the alert is re-reported' OnChange=""activatesave()"" > (minutes)</TD></TR>"
	}

  If Mode = "Edit" {
	W "<TR><TD>Schedule</TD><TD>"
	w "Hour Start:&nbsp;&nbsp;<select NAME=""HourStart"" Id=""HourStart"" OnChange=""activatesave()"">"
	For i = 0:1:24 {
		If i = rs.Data("HourStart") {
			w "<option VALUE="""_i_""" selected>"_i
		} Else {
			w "<option VALUE="""_i_""">"_i
		}
	}
	w "</select>&nbsp;&nbsp;"
	w "Hour End:&nbsp;&nbsp;<select NAME=""HourEnd"" Id=""HourEnd"" OnChange=""activatesave()"">"
	For i = 0:1:24 {
		If i = rs.Data("HourEnd") {
			w "<option VALUE="""_i_""" selected>"_i
		} Else {
			w "<option VALUE="""_i_""">"_i
		}
	}
	w "</select><br>"
	
	if rs.Data("M") = 1 {
		w "M: <Input Type=""checkbox"" Name=""M"" Id=""M"" checked=true OnClick=""activatesave()""> "
	} Else {
		w "M: <Input Type=""checkbox"" Name=""M"" Id=""M"" OnClick=""activatesave()""> "
	}
	if rs.Data("T") = 1 {
		w "T: <Input Type=""checkbox"" Name=""T"" Id=""T"" checked=true OnClick=""activatesave()""> "
	} Else {
		w "T: <Input Type=""checkbox"" Name=""T"" Id=""T"" OnClick=""activatesave()""> "
	}
	if rs.Data("W") = 1 {
		w "W: <Input Type=""checkbox"" Name=""W"" Id=""W"" checked=true OnClick=""activatesave()""> "
	} Else {
		w "W: <Input Type=""checkbox"" Name=""W"" Id=""W"" OnClick=""activatesave()""> "
	}
	if rs.Data("Th") = 1 {
		w "Th: <Input Type=""checkbox"" Name=""Th"" Id=""Th"" checked=true OnClick=""activatesave()""> "
	} Else {
		w "Th: <Input Type=""checkbox"" Name=""Th"" Id=""Th"" OnClick=""activatesave()""> "
	}
	if rs.Data("F") = 1 {
		w "F: <Input Type=""checkbox"" Name=""F"" Id=""F"" checked=true OnClick=""activatesave()""> "
	} Else {
		w "F: <Input Type=""checkbox"" Name=""F"" Id=""F"" OnClick=""activatesave()""> "
	}
	if rs.Data("Sa") = 1 {
		w "Sa: <Input Type=""checkbox"" Name=""Sa"" Id=""Sa"" checked=true OnClick=""activatesave()""> "
	} Else {
		w "Sa: <Input Type=""checkbox"" Name=""Sa"" Id=""Sa"" OnClick=""activatesave()""> "
	}
	if rs.Data("Su") = 1 {
		w "Su: <Input Type=""checkbox"" Name=""Su"" Id=""Su"" checked=true OnClick=""activatesave()""> "
	} Else {
		w "Su: <Input Type=""checkbox"" Name=""Su"" Id=""Su"" OnClick=""activatesave()""> "
	}
	
	
	w "</TD></TR>"
  }

	/*
			set tM = rs.Data("M")
			set tT = rs.Data("T")
			set tW = rs.Data("W")
			set tTh = rs.Data("Th")
			set tF = rs.Data("F")
			set tSa = rs.Data("Sa")
			set tSu = rs.Data("Su")

	*/

	if Mode = "Edit" { 
		W "<TR><TD>Notification Email</TD><TD><Input Type=""Text"" Style=""width:500"" Name=""NotificationEmail"" Id=""NotificationEmail"" Value="""_rs.Data("NotificationEmail")_""" OnChange=""activatesave()"" ></TD></TR>"
	}

	W "</TABLE>"
	W "</TD><TD>"
	W "<Table>"
	Set hrs=##class(%ResultSet).%New()
	Set HolidayList="Select * from IIBAENSEMBLE_Monitor.tblItems where itemtype='Holiday'"
	D hrs.Prepare(HolidayList)
	D hrs.Execute()

  If (hrs'="") {
	S AlertHolidays=$LFS(rs.Data("Holidays"),"^")
	// S AlertHolidays=$LFS("1^3^6","^")
	
	W "<TR><TD>&nbsp;</TD></TR>"
	W !,"<TR><TD>Holiday Alert Only</TD>"
	// W "<TD>*",rs.Data("HolidayOnly"),"*</TD>"
	W "<TD><Input Type=""checkbox"" Name=""OnHolidayOnly"" Id=""OnHolidayOnly"" OnClick=""activatesave()"""
	If ( rs.Data("HolidayOnly")="1") {
		W " checked=true "
	}
	W "></TD></TR>"
	W "<TR><TD></TD></TR><TR><TD>Holidays</TD></TR>"
	
	
	While ( hrs.Next() ) {
		Set HolidayName=hrs.Data("itemdescription")
		Set HolidayID=hrs.Data("itemvalue")
		//W HolidayName,!
		W !,"<TR><TD>&nbsp;&nbsp;&nbsp;&nbsp;",HolidayName,"</TD>"
		W "<TD><Input Type=""checkbox"" Name=""Holiday"_HolidayID,""" Id=""Holiday"_HolidayID,""" OnClick=""activatesave()"""
		If ( $LF(AlertHolidays,HolidayID) ) {
			W " checked=true "
		}
		W ">"
		W "</TD></TR>"
	} 
	W "</Table></TD></TR><TR><TD>"
	W "<Table>"
  }
  
  //Email Text
  w "<TR><TD colSpan=2><Table><TR><TD>Notes (optional)&nbsp;&nbsp;&nbsp;&nbsp;</TD></TR><TR><TD style='fontSize=""small"";font=""italic""'>(Max 250 characters)</TD></TR></Table></TD>"
  W "<TD><TextArea id='EmailText' rows='5' cols='45' title='Optional Email Text (250 chars max)' OnChange='activatesave()'>"_rs.Data("EmailText")_"</TextArea></TD></TR>"
  W "<TR><TD colspan=2>&nbsp;</TD><TD><Input type='button' value='Apply Notes to all alerts for this item' onclick='applyItemAlertNotes("""_rs.Data("ItemName")_""")'/></TD></TR>"
  
  if Mode = "Edit" { 
	if rs.Data("Active") = 1 {
		W "<TR><TD>Active</TD><TD><Input Type=""checkbox"" Name=""Active"" Id=""Active"" checked=true OnClick=""activatesave()""></TD></TR>"
	} Else {
		W "<TR><TD>Active</TD><TD><Input Type=""checkbox"" Name=""Active"" Id=""Active"" OnClick=""activatesave()""></TD></TR>"
	}
  }


	w "<TR><TD></TD><TD>"

	
	w "<Input DISABLED Type=""Button"" Style=""width:100"" Name=""SaveChanges"" Id=""SaveChanges"" Value=""Save Changes"" onclick=""savechanges('"_paramID_"')"">"
	w "<Input Type=""Button"" Style=""width:100"" Name=""Cancel"" Id=""Cancel"" Value=""Cancel"" onclick='self.document.location=""IIBASupport.csp?PageName=AlertAdmin""'>"

	W "</Table>"
	W "</Table>"
	W "</Form>"
	&html<
	<script language=javascript>
	
	document.getElementById('linkAlertAdmin').style.color = 'red';
	
	</script>	
	>
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
 	
 	/*		
 	// Get ThresholdValue using threshold ID
 	&sql(Select count (*) 
 		into :Count 
 		From IIBAENSEMBLE_Monitor.tblItems
 		Where itemtype='Holiday')
 	*/
 	
 	
 	Quit HList
}

ClassMethod SaveChanges(paramID As %String, ThresholdID As %String, ThresholdDuration As %String, AlertInterval As %String, NotificationEmail As %String, EmailText As %String, Active As %String, hourstart As %String, hourend As %String, M As %String, T As %String, W As %String, Th As %String, F As %String, Sa As %String, Su As %String, HolidayOnly As %String, holidays As %String) As %String [ Language = objectscript ]
{
 		
 	Set ThresholdValue=""
 			
 	// Get ThresholdValue using threshold ID
 	&sql(Select Top 1 itemvalue 
 		into :ThresholdValue 
 		From IIBAENSEMBLE_Monitor.tblItems
 		Where ID=:ThresholdID)
 	
 	set rs=##class(%ResultSet).%New()
 	Set UpdateString="UPDATE IIBAENSEMBLE_Monitor.ItemParameters set Threshold = '"_ThresholdValue_"'"
 	Set UpdateString=UpdateString_", ThresholdID = '"_ThresholdID_"', ThresholdDuration = '"_ThresholdDuration_"', AlertDuration = '"_AlertInterval_"'"
 	Set UpdateString=UpdateString_", NotificationEmail = '"_NotificationEmail_"', EmailText='"_EmailText_"', Active = "_Active_", HolidayOnly="_HolidayOnly_", Holidays='"_holidays_"'"
 	Set UpdateString=UpdateString_" where ID = "_paramID_""
 	Do rs.Prepare(UpdateString)
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
