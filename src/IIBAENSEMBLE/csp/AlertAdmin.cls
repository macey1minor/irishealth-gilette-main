/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.csp.AlertAdmin Extends %CSP.Page [ ProcedureBlock ]
{

ClassMethod CheckPermissions()
{
	set Allowed = 0
	//Req#5 - PHegel Tab Security Use for page name
	if ##class(%SYSTEM.Security).Check("AlertAdmin","USE"){ 
		set Allowed = 1 
	}
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
	function SortTable(sortby1,sortby2) {
		//alert(sortby1);
		//alert(sortby2);
		
		alert('before calling the sort');
		var newtable = #server(..SortTable(sortby1,sortby2))#;
		document.getElementById('tablediv').innerHTML = newtable;
		alert('after sort');
			
	}
	
	function removeAlert(paramID) {
		
		var c=confirm('Are you sure you want to delete this alert?');
		if (c ) {
			var remove = #server(..Remove(paramID))#;
			location.reload(true);
		}
		
		//self.document.location="IIBASupport.csp?PageName=AlertAdmin"
		
	}
	
	function FilterTable() {
		
		var selecteditem = document.FilterForm.Items.selectedIndex;
		var itemname = document.FilterForm.Items.options[selecteditem].value;
		
		var selectedparam = document.FilterForm.Parameters.selectedIndex;
		var parameter = document.FilterForm.Parameters.options[selectedparam].value;
		//alert(itemname);
		//alert(parameter);
		var newtable = #server(..FilterTable(itemname,parameter))#;
		document.getElementById('tablediv').innerHTML = newtable;
	}
	
	
	function ModifyEmail() {
		
		var OldEmail=prompt("Old E-Mail address","");
		
		if ( OldEmail != null && OldEmail != "" ) {
		
			var NewEmail=prompt("New E-Mail Address","");
			if ( NewEmail == null ) {
				NewEmail=""
			}
			
			var Update=confirm("Replace '"+OldEmail+"' with '"+NewEmail+"'")
			if (Update==true) {
				a=#server(..EmailReplace(OldEmail,NewEmail))#;
			}

			
		}
		
		
	}
	

	
	
  -->
   </script>
  >
}

ClassMethod html()
{
	&html<

	<style type="text/css">
    /*Style classes for use on this page */

      img{
   cursor:pointer;
       cursor:hand;
       display: block ;
     
     } 

   </style>
    
    >
	Set Mode=%request.Get("Mode")


	if Mode = "Remove" { 

	Set paramID=%request.Get("paramID")
	
	set rs=##class(%ResultSet).%New()
	Do rs.Prepare("DELETE from IIBAENSEMBLE_Monitor.ItemParameters where ID = "_paramID_"")
	Do rs.Execute()
	
	set rs=##class(%ResultSet).%New()
	Do rs.Prepare("DELETE from IIBAENSEMBLE_Monitor.tblSchedules where ParameterID = "_paramID_"")
	Do rs.Execute()
		
	set %response.Redirect="IIBASupport.csp?PageName=AlertAdmin"
		
	}

	

	w ..SubMenu()

	W "<Form Name=""FilterForm"" id=""FilterForm"">"
	w "<table id=""FilterTable"" class=""FilterTable"" border=""0"" cellpadding=""3"" cellspacing=""0"">"
	w "<tr><td align=""left"" nowrap>Filter by Item Name:&nbsp;&nbsp;"
	w "<Select Name=""Items"" id=""Items"" OnChange=""FilterTable()"">"
	W "<Option Value="""">All"
	set rs=##class(%ResultSet).%New()
	Do rs.Prepare("SELECT DISTINCT ItemName from IIBAENSEMBLE_Monitor.ItemParameters order by ItemName")
	Do rs.Execute()
	While(rs.Next()) {
		W "<Option Value="""_rs.Data("ItemName")_""">"_rs.Data("ItemName")
	}
	W "</Select>"
	w "&nbsp;&nbsp;&nbsp;&nbsp;Filter by Parameter:&nbsp;&nbsp;"
	w "<Select Name=""Parameters"" id=""Parameters"" alt='test' OnChange=""FilterTable()"">"
	W "<Option Value="""">All"
	set rs=##class(%ResultSet).%New()
	Do rs.Prepare("SELECT DISTINCT itemvalue from IIBAENSEMBLE_Monitor.tblItems where itemtype = 'Parameter' order by itemvalue")
	Do rs.Execute()
	While(rs.Next()) {
		W "<Option Value="""_rs.Data("itemvalue")_""">"_rs.Data("itemvalue")
	}
	W "</Select>"

	//w "<span class=""FilterMsg"" style=""color: darkblue; font-weight: bold; width:150px;"" id=""found""><i>Loading...</i></span>"
	w "</td>"
	// W "</tr><tr><td><input type=""Button"" value=""Modify Email"" onclick=""ModifyEmail()""/></td>"
	W "</tr></table>"
	w "</Form>"
	w $C(13,10)
	w $C(13,10)



	w $C(13,10)
	w $C(13,10)

	w "<span id=""tablediv"">"

	//do ..BuildTable("p.ItemName","p.Parameter","pageload")

	set TableHTML = ..BuildHeaderHTML()

	Set rs=##class(%ResultSet).%New()
	set ParamSelect = ""
	set ParamSelect = ParamSelect_"Select "
	set ParamSelect = ParamSelect_"i.itemdescription as ThresholdDesc, "
	set ParamSelect = ParamSelect_"p.ID, p.Active, p.AlertDuration/60 as AlertDuration, p.ItemName, p.NotificationEmail, p.Parameter, p.Threshold, p.ThresholdDuration, "
	set ParamSelect = ParamSelect_"p.Holidays, p.HolidayOnly, "
	set ParamSelect = ParamSelect_"s.HourStart, s.HourEnd, s.M, s.T, s.W, s.Th, s.F, s.Sa, s.Su "
	set ParamSelect = ParamSelect_"from IIBAENSEMBLE_Monitor.ItemParameters P "
	set ParamSelect = ParamSelect_"inner join IIBAENSEMBLE_Monitor.tblSchedules S "
	set ParamSelect = ParamSelect_"on P.ID = S.ParameterID "
	set ParamSelect = ParamSelect_"inner join IIBAENSEMBLE_Monitor.tblItems I "
	set ParamSelect = ParamSelect_"on P.ThresholdID = I.ID "
	set ParamSelect = ParamSelect_"order by p.ItemName, p.Parameter"
	Do rs.Prepare(ParamSelect)
	Do rs.Execute()
	set i = 1
	//w ParamSelect
	While(rs.Next()) {
	
		if i#2=0 {
			set TableHTML = TableHTML_"<tr class=""EvenRow""  >"
		} Else {
			set TableHTML = TableHTML_"<tr class=""OddRow""  >"
		}
		set TableHTML = TableHTML_"<td nowrap align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;"" ><img src='customimages/edit.gif' alt='Edit' onclick='window.location=""IIBASupport.csp?PageName=AlertEdit&Mode=Edit&paramID="_rs.Data("ID")_"""'/></td>"
		set TableHTML = TableHTML_"<td nowrap align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;"" ><img src='customimages/trash_bold.gif' alt='Delete' onclick='removeAlert("""_rs.Data("ID")_""")'/></td>"
		set TableHTML = TableHTML_"<td nowrap>"_rs.Data("ItemName")_"</td>"
		set TableHTML = TableHTML_"<td nowrap>"_rs.Data("Parameter")_"</td>"
		set TableHTML = TableHTML_"<td nowrap>"_rs.Data("ThresholdDesc")_"</td>"
		set TableHTML = TableHTML_"<td nowrap>"_rs.Data("ThresholdDuration")_"</td>"
		set TableHTML = TableHTML_"<td nowrap>"_rs.Data("AlertDuration")_"</td>"
		set TableHTML = TableHTML_"<td nowrap>"_rs.Data("HourStart")_"</td>"
		set TableHTML = TableHTML_"<td nowrap>"_rs.Data("HourEnd")_"</td>"
		set TableHTML = TableHTML_"<td nowrap>"_$CASE(rs.Data("Active"),1:"Y",:"N")_"</td>"
		set TableHTML = TableHTML_"<td nowrap>"_rs.Data("M")_"</td>"
		set TableHTML = TableHTML_"<td nowrap>"_rs.Data("T")_"</td>"
		set TableHTML = TableHTML_"<td nowrap>"_rs.Data("W")_"</td>"
		set TableHTML = TableHTML_"<td nowrap>"_rs.Data("Th")_"</td>"
		set TableHTML = TableHTML_"<td nowrap>"_rs.Data("F")_"</td>"
		set TableHTML = TableHTML_"<td nowrap>"_rs.Data("Sa")_"</td>"
		set TableHTML = TableHTML_"<td nowrap>"_rs.Data("Su")_"</td>"
		set TableHTML = TableHTML_"<td nowrap>"
		If ($ASCII(rs.Data("Holidays"))>32) {
			Set TableHTML=TableHTML_"<center>yes</center>"
		}
		Set TableHTML=TableHTML_"</td>"
		set TableHTML = TableHTML_"<td nowrap>"
		If (rs.Data("HolidayOnly")="1") {
			Set TableHTML=TableHTML_"Y"
		} else {
			If (rs.Data("Holidays")'="") {
				Set TableHTML=TableHTML_"N"
			}
		}
		Set TableHTML=TableHTML_"</td>"
		set TableHTML = TableHTML_"<td nowrap>"_rs.Data("NotificationEmail")_"</td>"
		set TableHTML = TableHTML_"</tr>"
	
	
		set i = i+1
	
		if $LENGTH(TableHTML) > 30000 {
		    w TableHTML	
		    set TableHTML = ""
		}	
	 }		
 	set TableHTML = TableHTML_"</table>"
	w TableHTML_"</span>"


	//w "<table class=""DetailTable""  cellpadding=""2"" cellspacing=""0"" ><tr><td>"
	//w "<Input Type=""Button"" Style=""width:100"" Name=""Add"" id=""Add"" Value=""Add New"" onclick='self.document.location=""IIBASupport.csp?PageName=AlertNew&Mode=New""'>"
	//w "<Input Type=""Button"" Style=""width:100"" Name=""Refresh"" id=""Refresh"" Value=""Refresh"" onclick='self.document.location=""IIBASupport.csp?PageName=AlertAdmin""'>"
	//w "<Input Type=""Button"" Style=""width:100"" Name=""Test"" id=""Test"" Value=""Test"" onclick='FilterTable(""MattTest.svc.TCP"","""")'>"
	//w "</td></tr></table>"
}

ClassMethod BuildHeaderHTML() As %String [ Language = objectscript ]
{
 set TableHTML = ""
 
 set TableHTML = TableHTML_"<table class=""DetailTable"" border=""1"" cellpadding=""2"" cellspacing=""0"" >"
 
 set TableHTML = TableHTML_"<tr>"
 set TableHTML = TableHTML_"<th></th>"
 set TableHTML = TableHTML_"<th></th>"
 set TableHTML = TableHTML_"<th nowrap  align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;"" onclick=""SortTable('p.ItemName','p.Parameter');""><a title=""Click to sort by this column."">Item Name</a></th>"
 set TableHTML = TableHTML_"<th nowrap  align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;"" onclick=""SortTable('p.Parameter','p.ItemName');""><a title=""Click to sort by this column."">Parameter</a></th>"
 set TableHTML = TableHTML_"<th nowrap  align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;"" onclick=""SortTable('p.Threshold','p.ItemName');""><a title=""Click to sort by this column."">Threshold Value</a></th>"
 set TableHTML = TableHTML_"<th nowrap  align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;"" onclick=""SortTable('p.ThresholdDuration','p.ItemName');""><a title=""Click to sort by this column."">Grace Period</a></th>"
 set TableHTML = TableHTML_"<th nowrap  align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;"" onclick=""SortTable('p.AlertDuration','p.ItemName');""><a title=""Click to sort by this column."">Alert Interval</a></th>"
 set TableHTML = TableHTML_"<th nowrap  align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;"" onclick=""SortTable('s.HourStart','p.ItemName');""><a title=""Click to sort by this column."">HourStart</a></th>"
 set TableHTML = TableHTML_"<th nowrap  align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;"" onclick=""SortTable('s.HourEnd','p.ItemName');""><a title=""Click to sort by this column."">HourEnd</a></th>"
 set TableHTML = TableHTML_"<th nowrap  align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;"" onclick=""SortTable('p.Active','p.ItemName');""><a title=""Click to sort by this column."">Active</a></th>"
 set TableHTML = TableHTML_"<th nowrap  align=""left"" style=""text-align:center;cursor:pointer;cursor:hand;width=25;"" onclick=""SortTable('s.M','p.ItemName');""><a title=""Click to sort by this column."">M</a></th>"
 set TableHTML = TableHTML_"<th nowrap  align=""left"" style=""text-align:center;cursor:pointer;cursor:hand;width=25;"" onclick=""SortTable('s.T','p.ItemName');""><a title=""Click to sort by this column."">T</a></th>"
 set TableHTML = TableHTML_"<th nowrap  align=""left"" style=""text-align:center;cursor:pointer;cursor:hand;width=25;"" onclick=""SortTable('s.W','p.ItemName');""><a title=""Click to sort by this column."">W</a></th>"
 set TableHTML = TableHTML_"<th nowrap  align=""left"" style=""text-align:center;cursor:pointer;cursor:hand;width=25;"" onclick=""SortTable('s.Th','p.ItemName');""><a title=""Click to sort by this column."">Th</a></th>"
 set TableHTML = TableHTML_"<th nowrap  align=""left"" style=""text-align:center;cursor:pointer;cursor:hand;width=25;"" onclick=""SortTable('s.F','p.ItemName');""><a title=""Click to sort by this column."">F</a></th>"
 set TableHTML = TableHTML_"<th nowrap  align=""left"" style=""text-align:center;cursor:pointer;cursor:hand;width=25;"" onclick=""SortTable('s.Sa','p.ItemName');""><a title=""Click to sort by this column."">Sa</a></th>"
 set TableHTML = TableHTML_"<th nowrap  align=""left"" style=""text-align:center;cursor:pointer;cursor:hand;width=25;"" onclick=""SortTable('s.Su','p.ItemName');""><a title=""Click to sort by this column."">Su</a></th>"
 set TableHTML = TableHTML_"<th nowrap  align=""left"" style=""text-align:center;cursor:pointer;cursor:hand;width=25;"" onclick=""SortTable('s.Su','p.ItemName');""><a title=""Click to sort by this column."">Holiday</a></th>"
 set TableHTML = TableHTML_"<th nowrap  align=""left"" style=""text-align:center;cursor:pointer;cursor:hand;width=25;"" onclick=""SortTable('s.Su','p.ItemName');""><a title=""Click to sort by this column."">Hol Only</a></th>"
 set TableHTML = TableHTML_"<th nowrap  align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;"" onclick=""SortTable('p.NotificationEmail','p.ItemName');""><a title=""Click to sort by this column."">Notification&nbsp&nbsp</a><input type=""Button"" value=""Bulk Modify"" onclick=""ModifyEmail()""/></th>"
 /**/
 set TableHTML = TableHTML_"</tr>"
 
 Quit TableHTML
}

ClassMethod BuildTable(sortby1 As %String, sortby2 As %String, action As %String) As %String [ Language = objectscript ]
{
 
 
 set TableHTML = ..BuildHeaderHTML()
 
 Set rs=##class(%ResultSet).%New()
 set ParamSelect = ""
 set ParamSelect = ParamSelect_"Select "
 set ParamSelect = ParamSelect_"i.itemdescription as ThresholdDesc, "
 set ParamSelect = ParamSelect_"p.ID, p.Active, p.AlertDuration/60 as AlertDuration, p.ItemName, p.NotificationEmail, p.Parameter, p.Threshold, p.ThresholdDuration, "
 set ParamSelect = ParamSelect_"p.Holidays, p.HolidayOnly, "
 set ParamSelect = ParamSelect_"s.HourStart, s.HourEnd, s.M, s.T, s.W, s.Th, s.F, s.Sa, s.Su "
 set ParamSelect = ParamSelect_"from IIBAENSEMBLE_Monitor.ItemParameters P "
 set ParamSelect = ParamSelect_"inner join IIBAENSEMBLE_Monitor.tblSchedules S "
 set ParamSelect = ParamSelect_"on P.ID = S.ParameterID "
 set ParamSelect = ParamSelect_"inner join IIBAENSEMBLE_Monitor.tblItems I "
 set ParamSelect = ParamSelect_"on P.ThresholdID = I.ID "
 set ParamSelect = ParamSelect_"order by "_sortby1_", "_sortby2
 Do rs.Prepare(ParamSelect)
 Do rs.Execute()
 set i = 1
 //w ParamSelect
 While(rs.Next()) {
 	
 	if i#2=0 {
 		set TableHTML = TableHTML_"<tr class=""EvenRow""  >"
 	} Else {
 		set TableHTML = TableHTML_"<tr class=""OddRow""  >"
 	}
 	set TableHTML = TableHTML_"<td nowrap align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;"" ><img src='customimages/edit.gif' alt='Edit' onclick='window.location=""IIBASupport.csp?PageName=AlertEdit&Mode=Edit&paramID="_rs.Data("ID")_"""'/></td>"
	set TableHTML = TableHTML_"<td nowrap align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;"" ><img src='customimages/trash_bold.gif' alt='Delete' onclick='removeAlert("""_rs.Data("ID")_""")'/></td>"
	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("ItemName")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("Parameter")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("ThresholdDesc")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("ThresholdDuration")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("AlertDuration")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("HourStart")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("HourEnd")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_$CASE(rs.Data("Active"),1:"Y",:"N")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("M")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("T")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("W")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("Th")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("F")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("Sa")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("Su")_"</td>"
 		set TableHTML = TableHTML_"<td nowrap>"
 	If ($ASCII(rs.Data("Holidays"))>32) {
 		Set TableHTML=TableHTML_"<center>yes</center>"
 	}
 	Set TableHTML=TableHTML_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"
 	If (rs.Data("HolidayOnly")="1") {
 		Set TableHTML=TableHTML_"Y"
 	} else {
 		If (rs.Data("Holidays")'="") {
 			Set TableHTML=TableHTML_"N"
 		}
 	}
 	Set TableHTML=TableHTML_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("NotificationEmail")_"</td>"
 	set TableHTML = TableHTML_"</tr>"
 	
 	
 	set i = i+1
 }		
 set TableHTML = TableHTML_"</table>"
 if action = "pageload" {
 	w TableHTML_"</span>"
 } 
 
 Quit 1
}

ClassMethod EmailReplace(OldEmail As %String, NewEmail As %String) As %String [ Language = objectscript ]
{
 
 	set rs=##class(%ResultSet).%New()
 	do rs.Prepare("Select ID,NotificationEmail from IIBAENSEMBLE_Monitor.ItemParameters where NotificationEmail like '%"_OldEmail_"%'")
 	do rs.Execute()
 
 	while (rs.Next()) {
 		set id=rs.Get("ID")
 		set notify=rs.Get("NotificationEmail")
 		
 		set Elist=$LFS(notify,",")
 		set p=$LF(Elist,OldEmail)
 		if ( p>0) {	
 			Set NewNotify=""
 			Set ptr=0
 			Set ptr=0
 			While $LISTNEXT(Elist,ptr,email) {
 				if ( email '= OldEmail ) {
 					Set NewNotify=NewNotify_","_email
 				} else {
 					If (NewEmail '="" ) {
 						Set NewNotify=NewNotify_","_NewEmail
 					}
 				}
 			}
 			Set NewNotify=$E(NewNotify,2,$LENGTH(NewNotify))
 			
 			Set Urs=##class(%ResultSet).%New()
 			set UpdateStatement="Update IIBAENSEMBLE_Monitor.ItemParameters set NotificationEmail='"_NewNotify_"' where ID="_id
 			
 
 			If ( NewNotify '= "" ) {
 				set UpdateStatement="Update IIBAENSEMBLE_Monitor.ItemParameters set NotificationEmail='"_NewNotify_"' where ID="_id
 				do Urs.Prepare(UpdateStatement)
 				do Urs.Execute()
 			} else {
 				&js<(alert('Alert row must have at least on e-mail notification. Delete failed for row id: '+#(id)#))>
 			}
 
 			
 						
 			
 		}
 	}
}

ClassMethod FilterTable(itemname As %String, parameter As %String) As %String [ Language = objectscript ]
{
 
 
 set TableHTML = ..BuildHeaderHTML()
 
 set sortby1 = "p.ItemName"
 set sortby2 = "p.Parameter"
 
 Set rs=##class(%ResultSet).%New()
 set ParamSelect = ""
 set ParamSelect = ParamSelect_"Select "
 set ParamSelect = ParamSelect_"i.itemdescription as ThresholdDesc, "
 set ParamSelect = ParamSelect_"p.ID, p.Active, p.AlertDuration/60 as AlertDuration, p.ItemName, p.NotificationEmail, p.Parameter, p.Threshold, p.ThresholdDuration, "
 set ParamSelect = ParamSelect_"p.Holidays, p.HolidayOnly, "
 set ParamSelect = ParamSelect_"s.HourStart, s.HourEnd, s.M, s.T, s.W, s.Th, s.F, s.Sa, s.Su "
 set ParamSelect = ParamSelect_"from IIBAENSEMBLE_Monitor.ItemParameters P "
 set ParamSelect = ParamSelect_"inner join IIBAENSEMBLE_Monitor.tblSchedules S "
 set ParamSelect = ParamSelect_"on P.ID = S.ParameterID "
 set ParamSelect = ParamSelect_"inner join IIBAENSEMBLE_Monitor.tblItems I "
 set ParamSelect = ParamSelect_"on P.ThresholdID = I.ID "
 
 if (itemname'="")&(parameter'="") {
 	set ParamSelect = ParamSelect_"where p.ItemName = '"_itemname_"' "
 	set ParamSelect = ParamSelect_"AND p.Parameter = '"_parameter_"' "
 } Elseif (itemname'="")&(parameter="") {
 	set ParamSelect = ParamSelect_"where p.ItemName = '"_itemname_"' "
 } Elseif (itemname="")&(parameter'="") {
 	set ParamSelect = ParamSelect_"where p.Parameter = '"_parameter_"' "
 }
 
 set ParamSelect = ParamSelect_"order by "_sortby1_", "_sortby2
 
 //set TableHTML = TableHTML_ParamSelect
 
 Do rs.Prepare(ParamSelect)
 Do rs.Execute()
 set i = 1
 //w ParamSelect
 While(rs.Next()) {
 	
 		
 	if i#2=0 {
 		set TableHTML = TableHTML_"<tr class=""EvenRow""  >"
 	} Else {
 		set TableHTML = TableHTML_"<tr class=""OddRow""  >"
 	}
 	set TableHTML = TableHTML_"<td nowrap align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;"" ><img src='customimages/edit.gif' alt='Edit' onclick='window.location=""IIBASupport.csp?PageName=AlertEdit&Mode=Edit&paramID="_rs.Data("ID")_"""'/></td>"
	set TableHTML = TableHTML_"<td nowrap align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;"" ><img src='customimages/trash_bold.gif' alt='Delete' onclick='removeAlert("""_rs.Data("ID")_""")'/></td>"
	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("ItemName")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("Parameter")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("ThresholdDesc")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("ThresholdDuration")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("AlertDuration")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("HourStart")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("HourEnd")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_$CASE(rs.Data("Active"),1:"Y",:"N")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("M")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("T")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("W")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("Th")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("F")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("Sa")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("Su")_"</td>"
 		set TableHTML = TableHTML_"<td nowrap>"
 	If ($ASCII(rs.Data("Holidays"))>32) {
 		Set TableHTML=TableHTML_"<center>yes</center>"
 	}
 	Set TableHTML=TableHTML_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"
 	If (rs.Data("HolidayOnly")="1") {
 		Set TableHTML=TableHTML_"Y"
 	} else {
 		If (rs.Data("Holidays")'="") {
 			Set TableHTML=TableHTML_"N"
 		}
 	}
 	Set TableHTML=TableHTML_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("NotificationEmail")_"</td>"
 	set TableHTML = TableHTML_"</tr>"
 	
 	
 	set i = i+1
 }		
 set TableHTML = TableHTML_"</table>"
 
 Quit TableHTML
}

ClassMethod Remove(paramID As %String) As %String [ Language = objectscript ]
{
 		
 	set rs=##class(%ResultSet).%New()
 	Do rs.Prepare("DELETE from IIBAENSEMBLE_Monitor.ItemParameters where ID = "_paramID_"")
 	Do rs.Execute()
 	
 	set rs=##class(%ResultSet).%New()
 	Do rs.Prepare("DELETE from IIBAENSEMBLE_Monitor.tblSchedules where ParameterID = "_paramID_"")
 	Do rs.Execute()
}

ClassMethod SortTable(sortby1 As %String, sortby2 As %String) As %String [ Language = objectscript ]
{
 
 
 set TableHTML = ..BuildHeaderHTML()
 
 Set rs=##class(%ResultSet).%New()
 set ParamSelect = ""
 set ParamSelect = ParamSelect_"Select "
 set ParamSelect = ParamSelect_"i.itemdescription as ThresholdDesc, "
 set ParamSelect = ParamSelect_"p.ID, p.Active, p.AlertDuration/60 as AlertDuration, p.ItemName, p.NotificationEmail, p.Parameter, p.Threshold, p.ThresholdDuration, "
 set ParamSelect = ParamSelect_"p.Holidays, p.HolidayOnly, "
 set ParamSelect = ParamSelect_"s.HourStart, s.HourEnd, s.M, s.T, s.W, s.Th, s.F, s.Sa, s.Su "
 set ParamSelect = ParamSelect_"from IIBAENSEMBLE_Monitor.ItemParameters P "
 set ParamSelect = ParamSelect_"inner join IIBAENSEMBLE_Monitor.tblSchedules S "
 set ParamSelect = ParamSelect_"on P.ID = S.ParameterID "
 set ParamSelect = ParamSelect_"inner join IIBAENSEMBLE_Monitor.tblItems I "
 set ParamSelect = ParamSelect_"on P.ThresholdID = I.ID "
 set ParamSelect = ParamSelect_"order by "_sortby1_", "_sortby2
 Do rs.Prepare(ParamSelect)
 Do rs.Execute()
 set i = 1
 //w ParamSelect
 While(rs.Next()) {
 	
 	
 	
 	if i#2=0 {
 		set TableHTML = TableHTML_"<tr class=""EvenRow""  >"
 	} Else {
 		set TableHTML = TableHTML_"<tr class=""OddRow""  >"
 	}
	set TableHTML = TableHTML_"<td nowrap align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;"" ><img src='customimages/edit.gif' alt='Edit' onclick='window.location=""IIBASupport.csp?PageName=AlertEdit&Mode=Edit&paramID="_rs.Data("ID")_"""'/></td>"
	set TableHTML = TableHTML_"<td nowrap align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;"" ><img src='customimages/trash_bold.gif' alt='Delete' onclick='removeAlert("""_rs.Data("ID")_""")'/></td>"
	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("ItemName")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("Parameter")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("ThresholdDesc")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("ThresholdDuration")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("AlertDuration")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("HourStart")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("HourEnd")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_$CASE(rs.Data("Active"),1:"Y",:"N")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("M")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("T")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("W")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("Th")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("F")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("Sa")_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("Su")_"</td>"
 		set TableHTML = TableHTML_"<td nowrap>"
 	If ($ASCII(rs.Data("Holidays"))>32) {
 		Set TableHTML=TableHTML_"<center>yes</center>"
 	}
 	Set TableHTML=TableHTML_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"
 	If (rs.Data("HolidayOnly")="1") {
 		Set TableHTML=TableHTML_"Y"
 	} else {
 		If (rs.Data("Holidays")'="") {
 			Set TableHTML=TableHTML_"N"
 		}
 	}
 	Set TableHTML=TableHTML_"</td>"
 	set TableHTML = TableHTML_"<td nowrap>"_rs.Data("NotificationEmail")_"</td>"
 	set TableHTML = TableHTML_"</tr>"
 	
 	
 	set i = i+1
 	
 	
 }		
 set TableHTML = TableHTML_"</table>"
 
 Quit TableHTML
}

ClassMethod SubMenu() As %String [ Language = objectscript ]
{
	set sHTML = ""
	set sHTML=sHTML_"<table><tr><td class=""LayoutContentCol"" width=""20%"" ><div class=""DetailCommand"">"
	set sHTML=sHTML_"<a id=""linkAlertNew"" class=""DetailCommand"" target=""_top"" href='IIBASupport.csp?PageName=AlertNew&Mode=New'><nobr>&nbsp;Add New Alert&nbsp;</nobr></A>"
	set sHTML=sHTML_"|"
	set sHTML=sHTML_"<a id=""linkHolidayDefinition"" class=""DetailCommand"" target=""_top"" href='IIBASupport.csp?PageName=HolidayDefinition'><nobr>&nbsp;Add Holiday&nbsp;</nobr></A>"
	set sHTML=sHTML_"|"
	set sHTML=sHTML_"<a id=""linkAlertExceptionDefinition"" class=""DetailCommand"" target=""_top"" href='IIBASupport.csp?PageName=AlertExceptionDefinition'><nobr>&nbsp;Define Alert Exception&nbsp;</nobr></A>"
	set sHTML=sHTML_"|"
	set sHTML=sHTML_"<a id=""linkAlertExceptionView"" class=""DetailCommand"" target=""_top"" href='IIBASupport.csp?PageName=AlertExceptionView'><nobr>&nbsp;View Alert Exceptions&nbsp;</nobr></A>"
	set sHTML=sHTML_"</div></td></tr></table>"
	
	Quit sHTML
}

}
