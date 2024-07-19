/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.csp.ReportAttachQueue Extends %CSP.Page
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
	
	function ProcessSelected()
	{
		alert('In process selected entries');
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
	
	Set Hday=$P($H,",",1)
	Set Htime=$P($H,",",2)
	
	Set NewTime=Htime-3600
	Set NewDay=Hday
	If (NewTime<0)  {
		
		Set DayCount=NewTime\86400-1
		Set NewTime=NewTime-(86400*DayCount)
		Set NewDay=NewDay+DayCount
	
	}

	
	s rs=##class(%ResultSet).%New()
	s Query="Select ID, Org, Accession, CreatedOn, ProcessedOn, ReportFileName, ReportFilePath from ICOrderResult_msg.ReportFileQueue "
	s Query=Query_" WHERE ProcessedOn IS NULL "
	s Query=Query_" AND CreatedOn < '"_$ZDT(NewDay_","_NewTime,3)_"' "
	s Query=Query_" AND ( (LastAlert is NULL) OR (LastAlert < '"_$ZDT(NewDay_","_NewTime,3)_"') ) "
	
	s tSC=rs.Prepare(Query)
	s tSC=rs.Execute()
	
	
	w "<form name='QueryBuilder' id='QueryBuilder' onsubmit='ProcessSelected()'>"
	

	w "<TABLE><TR><TD></TD><TD>ID</TD><TD>Org</TD><TD>Accession</TD><TD>Created On</TD><TD>ProcessedOn</TD><TD>Report File Name</TD><TD>Report File Path</TD></TR>"
	
	while (rs.Next()) {
		w "<tr>"
		w "<td><input type='checkbox' name='qb"_rs.Get(1)_"' id='qb"_rs.Get(1)_"' ></td>",!
		w "<td>"_rs.Get(2)_"</td>"
		w "<td>"_rs.Get(3)_"</td>"
		w "<td>"_rs.Get(4)_"</td>"
		w "<td>"_rs.Get(5)_"</td>"
		w "<td>"_##class(%File).GetFilename(rs.Get(6))_"</td>"
		w "<td>"_rs.Get(7)_"</td>"
		w "</tr>"
		
	}
	w "<tr><td span='2'><input type='submit' name='submit' id='submit' value='submit></td></tr>"
	w "</Table>"
	
	w "</form>"
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

ClassMethod UpdateQueueEntry(QueueEntryID As %Integer) As %String
{
	
	s QueueEntry=##class(ICOrderResult.msg.ReportFileQueue).%OpenId(QueueEntryID)
	
	If ($ISOBJECT(QueueEntry) ){
		s QueueEntry.ProcessedOn=$ZDT($H,3)
		s QueueEntry.Filename="Skipped"
		s tSC=QueueEntry.%Save()
	} else {
		s tSC="not found"
	}
	
	

	Quit tSC
}

}
