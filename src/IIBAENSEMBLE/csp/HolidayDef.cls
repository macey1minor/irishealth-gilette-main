/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.csp.HolidayDef Extends %CSP.Page
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
<script language="JavaScript">
			<!-- 

function Initialize(){
	
}

function AddHolidayDate() {
	
	
	var hd=document.getElementById('HolidayDate').value;
	var selectObj=document.getElementById('HolidayName');
	var hn=selectObj.options[selectObj.selectedIndex].value;
	
	//alert("hn= "+hn+" / hd "+hd);
	
	if (hn == "NewName") {
		
		NewHoliday();
		hn=selectObj.options[selectObj.selectedIndex].text;
		
	}
	
	
	hn=selectObj.options[selectObj.selectedIndex].text;
	

	if ( (hn != "") && (hd != "") ) {
		//alert("setting Holiday: "+hd+"/ code: "+hn);
		var check=#server(..GetHolidayId(hn))#;
		//alert('the id is: '+check);
		var a = #server(..SaveHoliday(hn,hd))#;
		
		
		// Add the row to the table
		if ( a != "" ) {
			d=a.split('|');
			hn=d[1];
			hd=d[0];
			rowAdded=-1;
		
			tableObj=document.getElementById('HolidayDateTable');
			tableLength=tableObj.rows.length;
		
			for (r=0;r<tableObj.rows.length;r++) {
			
				row=tableObj.rows;
				columns=row[r].cells;
				cd=columns[1].innerHTML;
				cn=columns[0].innerHTML;
				cda=cd.split('/');
				cds=cda[2]+cda[1]+cda[0];
				if ( ( rowAdded < 0 ) && (cds>hd) ) {
					rowAdded=r;
				}
			
			}
			if (rowAdded < 0 ) {
				rowAdded=tableLength;
			}
			tableObj.insertRow(rowAdded);
		
			row=tableObj.rows[rowAdded];
			row.insertCell(0);
			row.insertCell(1);
			row.insertCell(2);
			row.cells[0].innerHTML=hn;
			row.cells[1].innerHTML=hd.substr(4,2)+'/'+hd.substr(6,2)+'/'+hd.substr(0,4);
			row.cells[2].innerHTML='<img Title="Delete" src="customimages/trash_bold.gif" id="Delete"  onclick=\'RemoveHoliday("'+hd+'")\'>';
		
			ZebraHolidayTable();
		
		}
		
		
		
	} else {
		alert("Holiday Date and Name are required");
		
	}
	
	
	
}

function RemoveHoliday(Holiday) {
	
	//alert("Need to delete: "+Holiday);
	var a=#server(..DeleteHoliday(Holiday))#;
	window.location.reload();
	
}

function ZebraHolidayTable() {
	
	
	var tableObj=document.getElementById('HolidayDateTable');
	var tableLength=tableObj.rows.length;
		
	for (r=0;r<tableLength;r++) {
		
		
		
		if ( (r%2)== 0) {
			tableObj.rows[r].className='EvenRow';	
		} else {
			tableObj.rows[r].className='OddRow';
				
		}
	}	
	
}

function NewHoliday() {
	
	//alert('adding a new holiday');
	var selectObj=document.getElementById('HolidayName');
	var hn=selectObj.options[selectObj.selectedIndex].value;
	
	
	if (hn == "NewName") {
		
		hn=prompt("Please Enter the Holiday Name: ");
		
		if ( hn !=null && hn != ''  ) {
			//hn=#server(..GetHolidayId(hn))#;
			//alert("New Value: "+hn);
			for (i=0;i<selectObj.length;i++) {
				var index=-1;
				
				if ( selectObj[i].text.toUpperCase() == hn.toUpperCase() ) {
					index=i;
				}
			}
			//alert('index='+index);
			if (index < 0 ) {
				
				no=document.createElement('option');
				no.text=hn;
				no.value=hn;
				
				try {
					selectObj.add(no,null);
					
				} catch (ex) {
					selectObj.add(no);
					
				}
				index=selectObj.length-1;
			}
				
			selectObj.selectedIndex=index;
			
			
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
}
	

			//-->
			
</script>
  
  
  
  >
}

ClassMethod html()
{
    w ##class(IIBAENSEMBLE.csp.AlertAdmin).SubMenu()
	K HolidayList
	S rowNum=0
	set rs=##class(%ResultSet).%New()
	Do rs.Prepare("Select itemdescription,itemvalue from IIBAENSEMBLE_Monitor.tblItems where itemtype='Holiday'")
	Do rs.Execute()
	
	while rs.Next() {
		Set HolidayList(rs.Data("itemvalue"))=rs.Data("itemdescription")
		
	}
	
	
	w "<form name='QueryBuilder' id='QueryBuilder'>"

	w "<TABLE><TR><TD>Select Holiday Date</TD>"
	w "<TD>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</TD>"
	w "<TD>Select Holiday Name</TD></TR>"
	w "<TR><TD>"
	w "<input type='Text' name='HolidayDate' id='HolidayDate' value='' onblur=""TDate('HolidayDate')"" >&nbsp;"
	w "<a href=""javascript:cal1.popup();""><img src=""img/cal.gif"" width=""16"" height=""16"" border=""0"" alt=""Holiday Date""></a><br>"
	w "</TD><TD></TD><TD>"
	w "<select NAME='HolidayName' id='HolidayName' onchange='NewHoliday()'>"
	w "<option value='empty' >"
	w "<option VALUE='NewName'>&lt;New Holiday&gt;"
	

	Set h=""
	For {
		Set h=$O(HolidayList(h))
		Q:h=""
		
		W "<option value='"_h_"'>"_HolidayList(h)
		//W "<option >"_HolidayList(h)
	}
	W "</TD>"
			

	w "</TR>"
	w "<TR></TR><TR><TD><input type='button' name='AddHoliday' id='AddHoliday' value='Add Holiday' onclick='AddHolidayDate()'/></TD></TR>"
	
	w "</TABLE>"
	w "</form>"
	
	W "<Table class='DetailTable' id='HolidayDateTable' padding=5 border=1>"
	S date=""
	s rowNum=0
	For {
		Set date=$O(^ZAlert.Holiday(date))
		Q:date=""
		
		s dd=$E(date,5,6)_"/"_$E(date,7,8)_"/"_$E(date,1,4)
		s rowNum=rowNum+1
		W "<TR "
		if rowNum#2=0 {
 			W " class=""EvenRow"" "
 		} Else {
 			W " class=""OddRow"" "
 		}
		W "><TD>",HolidayList(^ZAlert.Holiday(date)),"</TD><TD>",dd,"</TD>"
		//W "<TD><input type='button' name='",date,"' value='Delete' onclick='RemoveHoliday(",date,")'/></TD></TR>"
		W "<TD><img Title='Delete' src='customimages/trash_bold.gif' id='Delete' onclick='RemoveHoliday("""_date_""")'/></TD></TR>"
		
	}
	
	w "</TABLE>"
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
   <script language=javascript>
			<!-- // create calendar object(s) just after form tag closed
				 // specify form element as the only parameter (document.forms['formname'].elements['inputname']);
				 // note: you can have as many calendar objects as you need for your application
				//var cal1 = new calendar2(document.forms['QueryBuilder'].elements['HolidayDate']);
				var cal1 = new calendar2(document.getElementById('HolidayDate'));
				cal1.year_scroll = true;
				cal1.time_comp = false;
document.QueryBuilder.HolidayDate.onkeydown = enterKeyHolidayDate;

function enterKeyHolidayDate(e) {

	if ((event.keyCode == 13)||(event.keyCode == 9))
	{ 
		TDate('Date1');
		document.HolidayName.focus();
		return false;
	}
}

	

			//-->
   </script>
  >
}

ClassMethod SaveHoliday(HolidayName As %String, HolidayDate As %String) As %String
{

		S HolidayValue=..GetHolidayId(HolidayName)
		
		
		S year="20"_$P(HolidayDate,"/",3)
		s year=$E(year,$L(year)-3,$L(year))
		s month="0"_$P(HolidayDate,"/",1)
		s month=$E(month,$L(month)-1,$L(month))
		s day="0"_$P(HolidayDate,"/",2)
		s day=$E(day,$L(day)-1,$L(day))
		
		S d=year_month_day
		Set v=""
		If ( d?8N && ($G(^ZAlert.Holiday(d))="") ) {
			
			s ^ZAlert.Holiday(d)=HolidayValue
			s v=d_"|"_HolidayName
		}
		
		Q v
}

ClassMethod DeleteHoliday(HolidayDate As %String) As %String
{
	if (HolidayDate?8N) {
		K ^ZAlert.Holiday(HolidayDate)
	}
	
	Q 1
}

ClassMethod GetHolidayId(HolidayName As %String) As %String
{
	
	set rs=##class(%ResultSet).%New()
	Do rs.Prepare("Select itemdescription,itemvalue from IIBAENSEMBLE_Monitor.tblItems where itemtype='Holiday' order by itemvalue desc")
	Do rs.Execute()
	
	s NameUpper=$ZCONVERT($TR(HolidayName," ",""),"U")
	S ItemValue=""
	S LastItemValue=""
	while rs.Next() {
		
		if ( (LastItemValue="" ) || ( rs.Get("itemvalue") > LastItemValue ) ) {
			set LastItemValue=rs.Get("itemvalue")
		}
		
		S name=rs.Get("itemdescription")
		if ( $ZCONVERT($TR(name," ",""),"U")=NameUpper ) {
			S ItemValue=rs.Get("itemvalue")
			
			QUIT
		}
			
	}
			

	If ( ItemValue = "" ) {
		S ItemValue=LastItemValue+1
		s rs=##class(%ResultSet).%New()
		Do rs.Prepare("Insert into IIBAENSEMBLE_Monitor.tblItems (itemvalue,itemdescription,itemtype) values ('"_ItemValue_"','"_HolidayName_"','Holiday')")
		D rs.Execute()
	}

	Q ItemValue
}

}
