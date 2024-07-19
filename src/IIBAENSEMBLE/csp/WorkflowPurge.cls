/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.csp.WorkflowPurge Extends %CSP.Page [ ProcedureBlock ]
{

ClassMethod CheckPermissions()
{
	set Allowed = 0
	if ##class(%SYSTEM.Security).Check("%All") = "READ,WRITE,USE" { set Allowed = 1 }
	
	Quit Allowed
}

ClassMethod calfunction()
{
  &html<
   <script language=javascript>
	<!--
	// create calendar object(s) just after form tag closed
	// specify form element as the only parameter (document.forms['formname'].elements['inputname']);
	// note: you can have as many calendar objects as you need for your application
	var cal1 = new calendar2(document.forms['QueryBuilder'].elements['Age']);
	cal1.year_scroll = true;
	cal1.time_comp = false;
	document.QueryBuilder.Age.onkeydown = enterKeyAge;

  -->
   </script>
  >
}

ClassMethod jsfunction()
{
  &html<
<script language="JavaScript" src="calendar2.js"></script>
<script language="JavaScript" src="date.js"></script><!-- Date only with year scrolling -->

   <script language=javascript>
	<!--
	function Initialize()
	{

	}
	function Hello() {
		alert('Hello');
	}
	
	function enterKeyAge(e) {

		if ((event.keyCode == 13)||(event.keyCode == 9))
		{ 
			TDate('Age');
			return false;
		}
	}
	
	function TDate(strElement) {
		var tvalue = document.getElementById(strElement).value;
		var tvaluefirst = tvalue.substr(0,1);
		
		if (tvaluefirst.toUpperCase() == 'T')
		{
			var tdate = new Date();
			if (tvalue.length == 1)
			{
				document.getElementById(strElement).value = tdate.format('MM/dd/yyyy');
			} 
			else 
			{
				var tdays = tvalue.substr(1,tvalue.length);
				tdate.add('d',tdays);
				document.getElementById(strElement).value = tdate.format('MM/dd/yyyy');
			}
		}		
	}
	
	function purge() {
		var jsAge=document.getElementById('Age').value;
		var jsRole=document.getElementById('RoleName').value;
		
		if (  jsAge == '' ) {
			alert('Please enter a date ');
			
		} else if ( jsRole == '' ) {
			alert('Please select a Worfklow');
		
		} else {
		
			var d=#server(..PurgeWorklistTasks(jsRole,jsAge))#;
			
		
			alert(' Tasks purged for Workflow='+jsRole+' Prior to='+jsAge);
			location.href='IIBASupport.csp?PageName=WorkflowPurge';
		}
	}
	
	function DisplayRoleInfo() {
		
		var jsRole=document.getElementById('RoleName').value;
		if (jsRole != "" ) {
			jsRoleInfo=#server(..GetRoleInfo(jsRole))#
		} else {
			jsRoleInfo=""
		}
		document.getElementById('RoleInfo').innerHTML=jsRoleInfo;
	}


  -->
   </script>
  >
}

ClassMethod html()
{
	k RoleList
		k RoleCount
	 	S rs=##class(%ResultSet).%New("EnsLib.Workflow.Engine:Worklist")
	 	s tsc=rs.Execute()
	 	
	 	while (rs.Next(.sc) ) {
		 	
		 	// get list of role names and ages (in days)
		 			 	
		 	S ptr=0,age=0
		 
			while $LISTNEXT($LFS(rs.Data("Age")," "),ptr,value) {
			 
			 				 
			 	s l=$LENGTH(value)
			 	s n=$E(value,1,l-1)
			 	s t=$E(value,l)
			 	
			 
				if (t="w") {
				 	s age=age+n*7
				 
			 	} Elseif (t="d") {
				 	s age=age+n
				 }
			 
		 	} 
		 	
		 	//W rs.Data("RoleName"),"<BR>"
		 	s RoleList(rs.Data("RoleName"),rs.Data("TaskId"))=age
		 	
		 	s TimeCreated=rs.Data("TimeCreated")
		 	if ( $DATA(RoleCount(rs.Data("RoleName"))) > 9 ) {
			 	S RoleCount(rs.Data("RoleName"),"Count")=RoleCount(rs.Data("RoleName"),"Count")+1
			 	S Min=$P(RoleCount(rs.Data("RoleName"),"Min"),";",1)
			 	S Max=$P(RoleCount(rs.Data("RoleName"),"Max"),";",1)
			 	if ( Min > age ) {
				 	s RoleCount(rs.Data("RoleName"),"Min")=age_";"_TimeCreated
			 	}
			 	
			 	if ( Max < age ) {
				 	s RoleCount(rs.Data("RoleName"),"Max")=age_";"_TimeCreated
			 	}
		 	} else {
			 	s RoleCount(rs.Data("RoleName"),"Count")=1
			 	s RoleCount(rs.Data("RoleName"),"Min")=age_";"_TimeCreated
			 	s RoleCount(rs.Data("RoleName"),"Max")=age_";"_TimeCreated
		 	}
		 	
	 	}
		
		// Get List of roles for user
		k UserRoles
		S rs=##class(%ResultSet).%New("EnsLib.Workflow.Engine:ListRolesForUser")
	 	s tsc=rs.Execute(%session.Username)
	 	
	 	while (rs.Next(.sc) ) {
		 	s UserRoles(rs.Data("RoleName"))=%session.Username
		 	// W rs.Data("RoleName")_"<BR>"
	 	}

		
		
		w "<form name=""QueryBuilder"" id=""QueryBuilder"">"
		w "<Table padding=25><TR>"
		w "<TD>Workflow: </TD><TD>&nbsp;&nbsp;&nbsp;&nbsp;</TD>"
		W "<TD><Select Name=""RoleName"" id=""RoleName"" onchange=""DisplayRoleInfo()"">"
		w "<option VALUE="""">"
		
		s n=""
		for {
			s n=$O(RoleList(n))
			q:n=""
			
			// Only include roles to which the user is assigned
			If ( $G(UserRoles(n)) '= "" ) {
				w "<option Value=""",n,""">",n
			}
		}
		
		w "</TD></TR>"
		
		W "<TR><TD></TD><TD></TD><TD><SPAN id=""RoleInfo""></SPAN></TD></TR>"
		
		W "<TR><TD>Before:</TD><TD>&nbsp;&nbsp;&nbsp;&nbsp;</TD>"
		w "<TD>"
		w "<input type=""Text"" name=""Age"" id=""Age"" value="""" onblur=""TDate('Age')"">&nbsp;"
		w "<a href=""javascript:cal1.popup();""><img src=""img/cal.gif"" width=""16"" height=""16"" border=""0"" alt=""Before Date""></a><br>"
		w "</TD></TR>"
		w "<TR><TD>&nbsp;&nbsp;&nbsp;&nbsp;</TD><TD></TD>"
		w "<TD><input Type=""Button"" Name=""btnPurge"" id=""btnPurge"" Value=""Purge"" OnClick=""purge()"">"
		w "</TD></TR>"
		w "</FORM>"
}

ClassMethod GetRoleInfo(Role As %String) As %String [ Language = objectscript ]
{
 
 	s info=""
 	s Count=0
 	S From=""
 	s To=""
 	
 	S rs=##class(%ResultSet).%New("EnsLib.Workflow.Engine:Worklist")
 	s tsc=rs.Execute()
 	 	
 	while (rs.Next(.sc) ) {
 		if ( rs.Data("RoleName")=Role ) {
 			S Count=Count+1
 			s Age=rs.Data("Age")
 			If ( (To = "" ) || ( $P( To,";",1) > Age ) ) {
 				S To=Age_";"_$P(rs.Data("TimeCreated")," ",1)
 			}
 			
 			If ( (From = "" ) || ( $P( From,";",1) < Age) ) {
 				S From=Age_";"_$P(rs.Data("TimeCreated")," ",1)
 			}
 			
 		}
 					
 	}
 	
 	if (Count > 0 ) {
 		
 		s info="<Table>"
 		S info=info_"<TR><TD>Count:</TD><TD>"_Count_"</TD></TR>"
 		S info=info_"<TR><TD>From:</TD><TD>"_$P(From,";",2)_"</TD></TR>"
 		S info=info_"<TR><TD>To:</TD><TD>"_$P(To,";",2)_"</TD></TR>"
 		s info=info_"</Table>"
 		
 		
 	}
 	
 	Q info
}

ClassMethod PurgeWorklistTasks(Role As %String, Date As %String) As %String [ Language = objectscript ]
{
 
 		S days=$P($H,",",1)-$P($ZDTH(Date),",",1)
 		
 		// Quit days
 		
 		k RoleList
 	 	S rs=##class(%ResultSet).%New("EnsLib.Workflow.Engine:Worklist")
 	 	s tsc=rs.Execute()
 	 	
 	 	while (rs.Next(.sc) ) {
 		 	
 		 			 	
 		 	if ( rs.Data("RoleName")=Role ) {
 		 		// get list of role names and ages (in days)
 		 				 	
 		 		S ptr=0,age=0
 		 		
 		 
 				while $LISTNEXT($LFS(rs.Data("Age")," "),ptr,value) {
 			 
 			 				 
 			 		s l=$LENGTH(value)
 			 		s n=$E(value,1,l-1)
 			 		s t=$E(value,l)
 			 	
 			 
 					if (t="w") {
 				 		s age=age+n*7
 				 
 			 		} Elseif (t="d") {
 				 		s age=age+n
 				 	}
 			 
 		 		} 
 		 		
 		 		 
 		 	
 		 		if ( age > days ) {
 			 		//w "purge ",tid
 			 		
 			 		d ##class(IIBAENSEMBLE.WorkflowFunctions).TaskActionFunct(Role,"Ignore",rs.Data("TaskId"))
 		 		}
 		 	
 	 		}
 	 	}
 
 
 Quit age
}

}
