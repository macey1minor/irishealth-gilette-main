/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.csp.ExceptionDef Extends %CSP.Page
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
  
  <!-- Tigra Calendar American format mm/dd/yyyy -->
<script language="JavaScript" src="calendar2.js"></script>
<script language="JavaScript" src="date.js"></script><!-- Date only with year scrolling -->
<script type="text/JavaScript">
<!--
	function Hello() {
		alert('Hello');
	}
	
	function Initialize()
	{
	
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
	
	
	function MoveRight(option) {
   
   
   f=document.getElementById("FromList");
   t=document.getElementById("ToList");
   var SelectionCount=f.options.length
   
   for (i=0;i<SelectionCount;i=i+1) {
     if (f.options[i].selected == 1 ) {
	var y=document.createElement('option');
	y.text=f.options[i].text;
	t.add(y);
     }
   }
   
   for (j=SelectionCount-1;j>=0;j=j-1) {
      
      if (f.options[j].selected == 1 ) {
      	f.options[j]=null;
      }
   }
}

function MoveLeft(option) {
   
   
   f=document.getElementById("FromList");
   t=document.getElementById("ToList");
   var SelectionCount=t.options.length
   
   for (i=0;i<SelectionCount;i=i+1) {
     if (t.options[i].selected == 1 ) {
		var y=document.createElement('option');
		y.text=t.options[i].text;
		f.add(y);
     }
   }
   
   for (j=SelectionCount-1;j>=0;j=j-1) {
      
      if (t.options[j].selected == 1 ) {
      	t.options[j]=null;
      }
   }
}


function AddExceptions(exceptionId) {
	

	
	var errMsg='';
	t=document.getElementById("ToList");
	SelectionCount=t.options.length;
	
	if ( SelectionCount == 0) {
		errMsg='Please select interface(s). ';
	}
	
	if (!document.getElementById("DateStart").value) {
		errMsg=errMsg+'Start Date is required. ';
	} else {
	
		if ( !document.getElementById("DateEnd").value ) {
		document.getElementById("DateEnd").value=document.getElementById("DateStart").value;
		
		}
		
		
		var tmp='';
		
		var startDttm=document.getElementById("DateStart").value+' '+document.getElementById("TimeStart").value+':00';
		tmp=new Date(startDttm);
		var OdbcStartDttm=tmp.format('yyyy-MM-dd HH:mm:ss');
		
		var endDttm=document.getElementById("DateEnd").value+' '+document.getElementById("TimeEnd").value+':00';
		tmp=new Date(endDttm);
		var OdbcEndDttm=tmp.format('yyyy-MM-dd HH:mm:ss');
		
		// Start date/time must be greater than the end date/time
		if ( (Date.parse(startDttm)) >= (Date.parse(endDttm)) ) {
			errMsg='The end Date/Time must be greater than the start Date/Time. ';
		}
		
		// End date/time must be in the future
		if ( (Date.parse(Date())>Date.parse(endDttm))) {
			errMsg=errMsg+'Please enter a future date for the end date/time. ';
			
		}
	}
	
	if ( errMsg ) {
		alert(errMsg);	
	
		
	} else {	
   		
   		if (exceptionId+0<1) {
			exceptionId=#server(..GetExceptionID())#;
			
			
		} else {
			var rv=#server(..DeleteException(exceptionId))#;
		}
		
		

   		
   		for (selection=0;selection<SelectionCount;selection=selection+1) {
			
			
			var ExportData = #server(..AddException(exceptionId,t.options[selection].text,OdbcStartDttm,OdbcEndDttm,document.getElementById("comment").value))#;
			
			
			location.replace('IIBASupport.csp?PageName=AlertExceptionView');
     		
   		}
	
		
	}
	
}




 //-->
</script>

  >
}

ClassMethod html()
{
	w ##class(IIBAENSEMBLE.csp.AlertAdmin).SubMenu()
	
	set Mode = %request.Get("Mode")
	set ExceptionId=%request.Get("id")
	If Mode = "edit" {
	
	
		set start="",end="",comment=""
		&sql(select distinct StartDttm,EndDttm,comment into :start,:end,:comment from IIBAENSEMBLE_Monitor.AlertExceptions where ExceptionID=:ExceptionId)
		s sDateStart=$P(start," ",1)
		s sDateStart=$P(sDateStart,"-",2)_"/"_$P(sDateStart,"-",3)_"/"_$P(sDateStart,"-",1)
		s sTimeStart=$P(start," ",2)
		s sTimeStart=($P(sTimeStart,":",1)+0)_":"_$P(sTimeStart,":",2)
		s sDateEnd=$P(end," ",1)
		s sDateEnd=$P(sDateEnd,"-",2)_"/"_$P(sDateEnd,"-",3)_"/"_$P(sDateEnd,"-",1)
		s sTimeEnd=$P(end," ",2)
		s sTimeEnd=($P(sTimeEnd,":",1)+0)_":"_$P(sTimeEnd,":",2)
	
	} else {

		set sDateStart = ""
		set sDateEnd = ""
		set sTimeSstart = ""
		set sTimeEnd = ""
		set direction = ""
		set comment=""
	
	}
	
	
	w "<form name=""QueryBuilder"" id=""QueryBuilder"">"
	

	w "<TABLE><TR><TD>Select Date Range:</TD><TD>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</TD><TD>Select Time Range:</TD><TD>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</TD></TR>"
	w "<TR><TD>"
	w "<input type=""Text"" id=""DateStart"" value="""_sDateStart_""" onblur=""TDate('DateStart')"">&nbsp;"
	w "<a href=""javascript:cal1.popup();""><img src=""img/cal.gif"" width=""16"" height=""16"" border=""0"" alt=""From Date""></a><br>"
	w "<input type=""Text"" id='DateEnd' value="""_sDateEnd_""" onblur=""TDate('DateEnd')"">&nbsp;"
	w "<a href=""javascript:cal2.popup();""><img src=""img/cal.gif"" width=""16"" height=""16"" border=""0"" alt=""To Date""></a>"
	w "</TD><TD></TD><TD>"
	w "<TABLE><TR><TD>Start Time:&nbsp;&nbsp;</TD><TD>"
	w "<select ID='TimeStart'>"
	For i = 0:1:23 {
		w "<option  VALUE="""_i_":00"""
		if ( (Mode="edit") && (sTimeStart=(i_":00"))) {
			w " selected=""1"" "
		}
		w ">"_i_":00"
		w "<option  VALUE="""_i_":30"""
				if ( (Mode="edit") && (sTimeStart=(i_":30"))) {
			w " selected=""1"" "
		}
		w ">"_i_":30"
	}
	w "<option VALUE=""24:00"""
	if ( (Mode="edit") && (sTimeStart=("24:00"))) {
			w " selected=""1"" "
		}
	w ">24:00"
	w "</select></TD></TR>"
	w "<TR><TD>End Time:&nbsp;&nbsp;</TD><TD>"
	w "<select ID='TimeEnd'>"
	For i = 0:1:24 {
		w "<option  VALUE="""_i_":00"""
		if ( (Mode="edit") && (sTimeEnd=(i_":00"))) {
			w " selected=""1"" "
		}
		w ">"_i_":00"
		w "<option  VALUE="""_i_":30"""
				if ( (Mode="edit") && (sTimeEnd=(i_":30"))) {
			w " selected=""1"" "
		}
		w ">"_i_":30"
	}
	w "<option VALUE=""24:00"""
	if ( (Mode="edit") && (sTimeEnd=("24:00"))) {
			w " selected=""1"" "
		}
	w ">24:00"
	w "</select></TD></TR></TABLE></TD><TD></TD>"

	// Get List of Exception Interfaces
	k Exceptions
	set rs=##class(%ResultSet).%New()
	Do rs.Prepare("Select distinct ItemName from IIBAENSEMBLE_Monitor.AlertExceptions where ExceptionId='"_ExceptionId_"'")
	Do rs.Execute()
	While(rs.Next()) {
		s Exceptions(rs.Data("ItemName"))=1
	}
	
	w "</TR></TABLE><BR>"
	W "<Table><TR><TD>&nbsp;&nbsp;Monitored Inerfaces</TD><TD>&nbsp;</TD><TD>&nbsp;&nbsp;Exception Interfaces</TD></TR>"
	W "<TR><TD>"
	W "<Select id='FromList' size='10' multiple='1' style='width:450px' >"
	set rs=##class(%ResultSet).%New()
	Do rs.Prepare("SELECT DISTINCT ItemName from IIBAENSEMBLE_Monitor.ItemParameters order by ItemName")
	Do rs.Execute()
	While(rs.Next()) {
		if '$DATA(Exceptions(rs.Data("ItemName"))) {
			W "<Option Value="""_rs.Data("ItemName")_""">"_rs.Data("ItemName")
		}
	}
	W "</Select></TD>"
	W "<TD><table><tr><td>&nbsp;"
	W "<input type='button' id='right' name='right' value='&nbsp;&gt;&nbsp;' onclick='MoveRight();'/>&nbsp;</td></tr>"
    W "<tr><td>&nbsp;<input type='button' id='left' value='&nbsp;&lt;&nbsp;' onclick='MoveLeft();' />&nbsp;</td></tr>"
    W "</table>"
	W "</td>"
	
	W "<TD><Select id='ToList' size='10' multiple='1' style='width:450px'>"
	S in=""
	for {
		set in=$O(Exceptions(in))
		Q:in=""
		W "<Option value="""_in_""">"_in
	}
	W "</Select>"
	W "</TD></TR></TABLE><BR>"
	W "Reason: <Input Type='text' id='comment' style='width:375px' value="""_comment_""">"
	W "<BR>"
	

	
	w "<Input Type=""button"" Name=""SubmitException"" id=""SubmitException"" Value=""Submit"" onclick='AddExceptions("""_ExceptionId_""")'>"
	w "</form>"
	&html<
	<script language=javascript>
	
	document.getElementById('linkAlertAdmin').style.color = 'red';
	document.getElementById('link'+'#(%request.Get("PageName"))#').style.color = 'red';

	</script>	
	>
}

ClassMethod jsCalfunction()
{
  &html<
  
  <script language="JavaScript">
			<!-- // create calendar object(s) just after form tag closed
				 // specify form element as the only parameter (document.forms['formname'].elements['inputname']);
				 // note: you can have as many calendar objects as you need for your application
				var cal1 = new calendar2(document.forms['QueryBuilder'].elements['DateStart']);
				cal1.year_scroll = true;
				cal1.time_comp = false;
				var cal2 = new calendar2(document.forms['QueryBuilder'].elements['DateEnd']);
				cal2.year_scroll = false;
				cal2.time_comp = false;
document.QueryBuilder.comment.onkeydown = enterKey;
document.QueryBuilder.DateStart.onkeydown = enterKeyDateStart;
document.QueryBuilder.DateEnd.onkeydown = enterKeyDateEnd;

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
function enterKeyDateStart(e) {

	if ((event.keyCode == 13)||(event.keyCode == 9))
	{ 
		TDate('DateStart');
		document.QueryBuilder.TimeStart.focus();
		return false;
	}
}
function enterKeyDateEnd(e) {
	if ((event.keyCode == 13)||(event.keyCode == 9))
	{ 
		TDate('DateEnd');
		document.QueryBuilder.TimeEnd.focus();
		return false;
	}	
}
	

//-->
			
</script>
  
  >
}

ClassMethod AddException(ExceptionID As %Integer, itemname As %String, StartDttm As %String, EndDttm As %String, comment As %String) As %String
{
	
	&sql( Insert into IIBAENSEMBLE_Monitor.AlertExceptions 
	           (ExceptionId,   itemname, startdttm, enddttm, comment)
		Values (:ExceptionID, :itemname,:StartDttm,:EndDttm,:comment)  )
	

	Quit SQLCODE
}

ClassMethod DeleteException(ExceptionID As %Integer) As %String
{
	&sql(Delete From IIBAENSEMBLE_Monitor.AlertExceptions
    	 where ExceptionID=:ExceptionID  )
     
	Quit SQLCODE
}

ClassMethod GetExceptionID() As %Integer
{
	&sql(select max(ExceptionId) into :ExceptionId from IIBAENSEMBLE_Monitor.AlertExceptions)
	s ExceptionId=ExceptionId+1



	Quit ExceptionId
}

}
