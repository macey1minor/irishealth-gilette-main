/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.cspTask.MSGCLASSDEF Extends %CSP.Page
{

ClassMethod CheckPermissions()
{
	set Allowed = 0
	if ##class(%SYSTEM.Security).Check("%All") = "READ,WRITE,USE" { set Allowed = 1 }
	
	if ##class(%SYSTEM.Security).Check("IIBAMsgDef") = "READ,WRITE,USE" { set Allowed = 1 }
	
	Quit Allowed
}

ClassMethod jsfunction()
{
  &html<
   
  <!-- Tigra Calendar American format mm/dd/yyyy -->
<script language="JavaScript" src="calendar2.js"></script>
<script language="JavaScript" src="date.js"></script><!-- Date only with year scrolling -->
<script language="JavaScript">
			<!-- 
			
			function msgDefUpdate() {
				
				sDate=document.getElementById("UpdateDate").value;
				msg=#server(..MsgDefQuickupdate(sDate))#;
				alert(msg);
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

			 
			//-->
			
</script>

   
  >
}

ClassMethod html()
{
    w "<table width=800px><tr><td width=700px>"
    w "Message Search - Class Def Quick Update "
	w "</td>"
	W "<TD nowrap >"
	w "<input type='Text' id='UpdateDate' value='"_$ZDATE($H)_"' onblur=""TDate('UpdateDate');"" >&nbsp;"
	w "<a href=""javascript:cal1.popup();""><img src=""img/cal.gif"" width=""16"" height=""16"" border=""0"" alt=""Message Date""></a><br>"
	W "</TD>"
	W "<td>"
	w "<Input Type=""Button"" id='btnStartUpdate' Value='Start' onclick='msgDefUpdate();'>"
	w "</td></tr></table>"
}

ClassMethod MsgDefQuickupdate(UpdateDate As %String)
{
	
	s msg=##class(IIBAENSEMBLE.Task.MSGCLASSDEF).QuickUpdate(UpdateDate)
	Quit msg
}

ClassMethod jsCalfunction()
{
  &html<
   <script language=javascript>
			<!-- // create calendar object(s) just after form tag closed
				 // specify form element as the only parameter (document.forms['formname'].elements['inputname']);
				 // note: you can have as many calendar objects as you need for your application
				//var cal1 = new calendar2(document.forms['QueryBuilder'].elements['HolidayDate']);
				var cal1 = new calendar2(document.getElementById('UpdateDate'));
				cal1.year_scroll = true;
				cal1.time_comp = false;
//document.QueryBuilder.submit.onkeydown = enterKey;
//document.getElementById('UpdateDate').onkeydown = enterKeyUpdateDate(event);

function enterKey(e) {
	//check to see if the return key was pressed ...
	
	if ((event.keyCode == 13)||(event.keyCode == 9))
	{ 
		//call the ValidateSearch function ...
		document.getElementById('btnStartUpdate').focus();
		//ValidateSearch();
		//prevent the page from reloading ...
		return false;
	}
}
function enterKeyUpdateDate(e) {

	if ((event.keyCode == 13)||(event.keyCode == 9))
	{ 
		TDate(document.getElementById('UpdateDate'));
		document.getElementById("btnStartUpdate").focus();
		return false;
	}
	
}

	

			//-->
   </script>
  >
}

}
