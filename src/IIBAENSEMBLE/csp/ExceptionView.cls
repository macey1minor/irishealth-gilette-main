/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.csp.ExceptionView Extends %CSP.Page
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
  
<script language="JavaScript" src="calendar2.js"></script>
<script language="JavaScript" src="date.js"></script><!-- Date only with year scrolling -->

<script type="text/JavaScript">
<!--

	function Initialize()
	{
		//alert('init view');
	}
	
	function remove(objectId) {
		
		var x=objectId.split(".");
		exceptionId=x[0];
		childIndex=x[1];
		itemName="";
		
		if ( childIndex ) {
			var rs=document.getElementById('childRow'+objectId);
			var cs=rs.cells[1];
			itemName=cs.innerHTML;
			
		}
		
		//alert('Exception id: '+exceptionId);
		//alert('item Name: '+itemName);
		
		var remove=#server(..Remove(exceptionId,itemName))#;
		
		//now remove the row from the table
		var rowIndex="";
		if (childIndex) {
			rowIndex=document.getElementById('childRow'+objectId).rowIndex;
		} else {
			var r=document.getElementById('exceptionRow'+objectId);
			rowIndex=r.rowIndex;
			
			
			//colapse the exceptions
			if ( document.getElementById('rowAction'+objectId).value == "-" ) {
				changeRow(objectId);
			}
		}
		
		if (rowIndex) {
			document.getElementById('Detailview').deleteRow(rowIndex);
		}
			
		
		
	}
	
	function editComment(exceptionId) {
		
		var comment=document.getElementById('Comment'+exceptionId).innerHTML
		var newComment=prompt('Edit Comment',comment);
		
		if ( newComment!=null && newComment!="" ) {
			var rv=#server(..EditComment(exceptionId,newComment))#
			document.getElementById('Comment'+exceptionId).innerHTML=newComment;
			
		}
		
		
	}
	
	function editException(exceptionId) {
		
		document.location='IIBASupport.csp?PageName=AlertExceptionDefinition&Mode=edit&id='+exceptionId;
		
		
		
	}
	
	
	function changeRow(rowId) {
		
		//alert('row: '+rowId);
		var rowIndex=document.getElementById("exceptionRow"+rowId).rowIndex;
		if ( document.getElementById('rowAction'+rowId).value == "+" ) {
			
			// expand this exception - displaying items...
			document.getElementById('rowAction'+rowId).value="-";
			var start=document.getElementById('StartDttm'+rowId).innerHTML
			var end=document.getElementById('EndDttm'+rowId).innerHTML
			var comment=document.getElementById('Comment'+rowId).innerHTML
			var itemList=#server(..GetItemList(start,end,comment))#;
			
			//alert('rowIndex: '+rowIndex);
			var itemArray=itemList.split(",");
			for (i=0; i<itemArray.length; i++) {
				
				//insert a row with the item information
				var x=document.getElementById('DetailView').insertRow(rowIndex+1);
				x.id='childRow'+rowId+'.'+i;
				var y=x.insertCell(0);
				y.innerHTML='&nbsp;';
				y.width='4%';
				y.id='exceptionChild'+rowId+'.'+i;
				var z=x.insertCell(1);
				z.colSpan=4;
				z.width='94%';
				z.id='childName'+rowId+'.'+i;
				z.innerHTML=itemArray[i];
				var w=x.insertCell(2);
				w.innerHTML='<img Title="Delete" src="customimages/trash_bold.gif" id="removeChild'+rowId+'.'+i+'" onclick="remove(\''+rowId+'.'+i+'\');">'
			}
			
		} else {
			//colapse items into exception row.
			document.getElementById('rowAction'+rowId).value="+";
			i=rowIndex+1;
			do {
				//get the row id
				rs=document.getElementById('DetailView').rows[i];
				cs=rs.cells[0];
				r=cs.id;
				if ( r.match('exceptionChild'+rowId+".") ) {
					document.getElementById('DetailView').deleteRow(i);
				} 
			}
			while ( r.match('exceptionChild'+rowId+".") && (document.getElementById('DetailView').rows.length>i) )
			
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
		//alert('calling view page with new after'+document.getElementById(strElement).value);
		document.location='IIBASupport.csp?PageName=AlertExceptionView&after='+document.getElementById(strElement).value;		
	}
	



//-->
</script>
  
  >
}

ClassMethod html()
{
	
	Set Mode=%request.Get("Mode")
	set after=%request.Get("after")

	if ( after '= "") {
		s a=$ZDTH(after)
		s after=$ZDT(a,3)
		s afterDisplay=$ZDATE(a)
	} else {
		s after=$ZDT($P($H,",",1)-3,3)
		s afterDisplay=$ZDT($P($H,",",1)-3)
	}



	w ##class(IIBAENSEMBLE.csp.AlertAdmin).SubMenu()


	w "<form id='DisplayExceptions'>"
	w "<table border=0>"
	w "<tr ><td width='40' >&nbsp;</td><td width='250' align='Right' >Exceptions After (MM/DD/YYYY):&nbsp;</td><td width='50'>"
	w "<input type='text' name='after' id='after' style='width: 75px; '"
	w "Value='"_afterDisplay_"' onblur='TDate(""after"");' onchange='TDate(""after"");return false;'>"
	//w "Value='"_afterDisplay_"' onblur='TDate(""after"");' ></td>"
	w "<td><input type='image' src='customimages/searchblue.gif' onclick='TDate(""after"");return false;' alt='Search'>"
	w "</td></tr>"
	w "</table>"


	w "<table id='DetailView' class=""DetailTable"" border=""1"" cellpadding=""2"" cellspacing=""0"" >"
	w "<tr>"
	w "<th width='40'>&nbsp;</th>"
	w "<th nowrap align='left' style='text-align:left;cursor:pointer;cursor:hand;' width='150'>Start</th>"
	w "<th nowrap align='left' style='text-align:left;cursor:pointer;cursor:hand;' width='150'>End</th>"
	w "<th nowrap align='left' style='text-align:left;cursor:pointer;cursor:hand;' width='550'>Reason</th>"
	w "<th width='25'>&nbsp;</th>"
	w "<th width='25'>&nbsp;</th>"
	w "</tr>"

	Set rs=##class(%ResultSet).%New()
	Do rs.Prepare("select distinct ExceptionId, StartDttm, EndDttm, Comment from IIBAENSEMBLE_Monitor.AlertExceptions  where EndDttm >'"_after_"' Order By StartDttm,EndDttm")
	Do rs.Execute()
	set i = 1
	While(rs.Next()) {
	
		if i#2=0 {
			w "<tr id=""exceptionRow"_rs.Data("ExceptionId")_""" class=""EvenRow""  >"
		} Else {
			w "<tr id=""exceptionRow"_rs.Data("ExceptionId")_""" class=""OddRow""  >"
		}
		w "<td><input id=""rowAction"_rs.Data("ExceptionId")_""" type=""button"" value=""+"" onclick='changeRow("""_rs.Data("ExceptionId")_""");'></td>"
		w "<td><div id='startDttm"_rs.Data("ExceptionId")_"'>"_$ZDT($ZDTH(rs.Data("StartDttm"),3))_"</div></td>"
		w "<td><div id='EndDttm"_rs.Data("ExceptionId")_"' >"_$ZDT($ZDTH(rs.Data("EndDttm"),3))_"</div></td>"
		w "<td><div id='Comment"_rs.Data("ExceptionId")_"'  >"
		w rs.Data("Comment")
		w "</div></td>"
		w "<td><img Title='Edit' src='customimages/edit.gif' onclick='editException("""_rs.Data("ExceptionId")_""");'></td>"
		w "<td><img Title='Delete' src='customimages/trash_bold.gif' input id=""remove"_rs.Data("ExceptionId")_""" onclick=""remove('"_rs.Data("ExceptionId")_"');""></td>"
	
		w "</tr>"
		w "<div id='child"_rs.Data("ExceptionId")_"'></div>"
		s i=i+1


	}		
	w "</table>"
	w "</form>"
	&html<
	<script language=javascript>
	
	document.getElementById('linkAlertAdmin').style.color = 'red';
	document.getElementById('link'+'#(%request.Get("PageName"))#').style.color = 'red';

	</script>	
	>
}

ClassMethod Remove(ExceptionID As %String, ItemName As %String) As %String
{
	set rs=##class(%ResultSet).%New()
	
	s sql="Delete from IIBAENSEMBLE_Monitor.AlertExceptions where Exceptionid='"_ExceptionID_"'"
	if ( ItemName '= "" ) {
		s sql=sql_" and ItemName='"_ItemName_"'"
	}
	
	Do rs.Prepare(sql)
	Do rs.Execute()
	
	Q $$$OK
}

ClassMethod EditComment(ExceptionID As %String, NewComment As %String) As %String
{
		
	set rs=##class(%ResultSet).%New()
	
	s sql="Update IIBAENSEMBLE_Monitor.AlertExceptions "
	s sql=sql_"set Comment='"_NewComment_"' "
	s sql=sql_"where Exceptionid='"_ExceptionID_"'"
	
	Do rs.Prepare(sql)
	Do rs.Execute()
	
	Q $$$OK
}

ClassMethod GetItemList(StartDttm As %TimeStamp, EndDttm As %TimeStamp, Comment As %String) As %String
{
	set rs=##class(%ResultSet).%New()
	Do rs.Prepare("Select Distinct ItemName from IIBAENSEMBLE_Monitor.AlertExceptions where StartDttm = '"_$ZDT($ZDTH(StartDttm),3)_"' and EndDttm='"_$ZDT($ZDTH(EndDttm),3)_"' and Comment='"_Comment_"'")
	Do rs.Execute()
	s items=""
	while (rs.Next()) {
		if (items'="") {
			s items=items_","
		}
		s items=items_rs.Data("ItemName")
		
	}
	
	Quit items
}

}
