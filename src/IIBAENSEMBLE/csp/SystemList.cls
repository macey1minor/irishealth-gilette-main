/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.csp.SystemList Extends %CSP.Page [ ProcedureBlock ]
{

ClassMethod CheckPermissions()
{
	set Allowed = 0
	//Req#5 - PHegel Tab Security Use for page name
	if ##class(%SYSTEM.Security).Check("SystemList","USE"){ 
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

self.setInterval(refreshStats,15000);



function popup(mylink, windowname)
{
if (! window.focus)return true;
var href;
if (typeof(mylink) == 'string')
   href=mylink;
else
   href=mylink.href;
window.open(href, windowname, 'width=700,height=900,scrollbars=yes');
return false;
}

function refreshStats() {
		
	var r=#server(..UpdateStats())#;
	
}



//function columnFilter(column) {
function columnFilter() {
		
	//alert('In filter function: '+column);
	var filterName=document.getElementById('filterName').value;
	//alert('filter Name:'+filterName);
	var filterComment=document.getElementById('filterComment').value;
	//alert('filter Comment:'+filterComment);
	var filterType=document.getElementById('filterType').value;
	//alert('filter Type:'+filterType);
	var interfaceTable=document.getElementById('interfaceTable');
	
	var lastPackageRow=2;
		
		

	if ( (filterName+filterComment+filterType) == ""  ) {
		window.location.reload();
	} else {
		for (r=2;r<document.getElementById('interfaceTable').rows.length;r++) {
		//for (r=2;r<15;r++) {
			row=document.getElementById('interfaceTable').rows[r];
			rowType=row.id.split(":")[0];
			rowName=row.id.split(":")[1];
			columns=row.cells;
			
			
			if (rowType=='PackageRow' ) {
				lastPackageRow=r;
				lastPackageId=columns[0].id;
				
			}
			
	    	if ( columns[1].id.toLowerCase().match(filterName.toLowerCase()) && 
	    	     columns[4].innerHTML.toLowerCase().match(filterType.toLowerCase()) && 
	    	     columns[3].innerHTML.toLowerCase().match(filterComment.toLowerCase()) ) {
	    		document.getElementById('interfaceTable').rows[r].style.display='table-row';
	    		
	    		//document.getElementById('interfaceTable').rows[lastPackageRow].style.display='table-row';
	    		p=rowName.split(",")[0];
	    		document.getElementById("PackageRow:"+p+"Button").value='-';
	    		
    		} else {
	    		if ( (rowType == 'ItemRow') || ( rowName.split(".").length > 1 )) {
	    			document.getElementById('interfaceTable').rows[r].style.display='none';
	    		}
    		}
		}

		
	}
		
}

function changePackageView(package) {
	
	//alert('change view: '+package);
	
	
	
	if (document.getElementById("PackageRow:"+package+"Button").value == '+') {
		newDisplay='table-row';
		document.getElementById("PackageRow:"+package+"Button").value='-';
	} else {
		newDisplay='none';
		document.getElementById("PackageRow:"+package+"Button").value='+';
	}
	
	if (package == 'changeAll') {
		rowIndex=1;
		package='';
		
	} else {
		var rowIndex=document.getElementById("PackageRow:"+package).rowIndex;
	}

		
	var i=rowIndex;
	do {
		i=i+1;
		rowId=document.getElementById('interfaceTable').rows[i];
		
		

		rowType=rowId.id.split(":")[0];
		rowName=rowId.id.split(":")[1];
		nameComponents=rowName.split(".");
		//alert('rowName: '+rowName+' length: '+nameComponents.length)
		if ( rowName.match(package) ) {
			//alert('change display value');
			if ( (newDisplay=='none') && (rowType=='PackageRow') && (nameComponents.length<2)) {
				//alert('do nothing');
				
			} else {
				//alert('setting style.display');
				document.getElementById('interfaceTable').rows[i].style.display=newDisplay;
			}
			
			if (rowType=='PackageRow') {
				//alert('package row');
				if (newDisplay=='none') {
					document.getElementById("PackageRow:"+rowName+"Button").value='+';
				} else {
					document.getElementById("PackageRow:"+rowName+"Button").value='-';
				}
			}
		}
		
		
		
		
	} while (  rowName.match(package) && (document.getElementById('interfaceTable').rows.length>i+1) )
	
}
function SearchFor() 
{
	var SearchForString = document.getElementById("SearchForString").value;
	document.getElementById("foundInString").innerHTML = #server(..SearchFor(SearchForString))#;
}
//-->
  
   </script>
  >
}

ClassMethod html()
{
	
	w "<table  class=""DetailTable"" cellpadding=""0"">"
	w "<tr><td><input type=""text"" name=""SearchForString"" id=""SearchForString"" size=""25""></td>"
	w "<td><input type=""image"" src=""customimages/searchblue.gif"" onclick=""SearchFor()"" alt=""Search""></td>"
	w "<td><div id=""foundInString""></td>"				
	w "</tr></table>"

	SET IfCnt=0

	W "<SPAN id='InterfaceList'>"
	
	D ..BuildTable(%request.Get("NameFilter"))
	
	W "</SPAN>"
}

ClassMethod BuildTable(NameFilter As %String) As %String [ Language = objectscript ]
{
 	
 	set status = ##class(Ens.Director).GetProductionStatus(.ProductionName,.ProductionStatus)
 
 	D ..CollectStats()
 
 	// Render the Table
 	
 	s rowNum=0
 	//Set NameFilter=%request.Get("NameFilter")
 	
 	W "<table class=""DetailTable"" id='interfaceTable' border=""1"" cellpadding=""2"" cellspacing=""0"" style='tableLayout:fixed' >"
 	W "<tr>"
 	W "<td style='width=20' ><input id='PackageRow:changeAllButton' type='button' value='+' onclick='changePackageView(""changeAll"");'></td>"
 	W "<td><input type='text' name='filterName' id='filterName' style='background-color: Khaki;width=420' value='"
 	if ( NameFilter '="" ) {
 		W NameFilter
 	}
 	W "' onchange=""columnFilter('filterName');""></td>"
 	W "<td width=20>&nbsp;</td>"
 	W "<td><input type='text' name='filterComment' id='filterComment' style='background-color: Khaki;width=250' value='' onchange=""columnFilter('filterComment');""></td>"
 	//W "<td><input type='text' name='filterType' id='filterType' style='background-color: Khaki;width=80' value='' onchange=""columnFilter('filterType');""></td>"
 	W "<td><select name='filterType' id='filterType' style='background-color: Khaki;width=80' onchange=""columnFilter('filterType');"">"
 	W "<Option Value="""">"
 	W "<Option Value=""Service"">Service"
 	W "<Option Value=""Process"">Process"
 	W "<Option Value=""Operation"">Operation"
 	W "</td>"
 	W "<td style='width=15' >&nbsp;</td>"
 	W "<td style='width=15'>&nbsp;</td>"
 	W "<td style='width=80'>&nbsp;</td>"
 	W "</tr>"
 	W "<tr>"
 	// W "<th nowrap align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;width=190"" >Category</th>"
 	W "<th nowrap align=""left"" style=""width=20"" ></th>"
 	W "<th nowrap align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;width=420"" >Name</th>"
 	W "<th width=20>&nbsp;</th>"
 	//W "<th nowrap align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;width=250"" >Comment</th>"
 	W "<th nowrap align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;width=250"" >Category</th>"
 	W "<th nowrap align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;width=80;"" >Type</th>"
 	W "<th nowrap align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;width=15;"" >Status</th>"
 	W "<th nowrap align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;width=15;"" >Queue Size</th>"
 	W "<th nowrap align=""left"" style=""text-align:left;cursor:pointer;cursor:hand;width=80;"" >LastAction</th>"
 	W "</tr>"
 	Set package=""
 	Set PrevPackage=""
 	
 	
 	
 	For {
 		//Set package=$O(SysList(package))
 		Set package=$O(%session.Data("SysListArray",package))
 		Q:package=""
 		
 		
 		
 		Set InterfaceName=""
 		Set QueueTotal=0
 		Set Status=""
 		Set LastAction=""
 		
 		
 		
 		w "<tr id='PackageRow:"_package_"' "
 		If ( ( $P(package,".",2)="" ) || ( (NameFilter'="") &&($ZCVT(package,"U")[$ZCVT(NameFilter,"U"))) ) {
 			W " style='display: table-row' "
 			
 		} else {
 			W " style='display: none' "
 			
 		}
 		
 		W ">"
 		w "<td><input id='PackageRow:"_package_"Button' type='button' value='+' onclick='changePackageView("""_package_""");'</td>"
 		
 		w "<td nowrap id='"_package_"' >"_package_"</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>"
 		w "<td width=40>&nbsp;</td>"
 		W "<td id='"_package_":Queue' nowrap >"_$G(%session.Data("PackageSummaryArray",package,"Queue"))_"&nbsp;</td>"
 		W "<td id='"_package_":LastAction' nowrap>"
 		if ( $G(%session.Data("PackageSummaryArray",package,"LastAction")) = "" ) {
 			w "&nbsp;"
 		} else {
 			Set LaDt=$P(%session.Data("PackageSummaryArray",package,"LastAction")," ",1)
 			Set LaTm=$P(%session.Data("PackageSummaryArray",package,"LastAction")," ",2)
 			Set LaH=$ZDTH($P(LaDt,"-",2)_"/"_$P(LaDt,"-",3)_"/"_$P(LaDt,"-",1)_" "_LaTm)
 			Set LastAction=$ZD(LaH,11)_" "_$P($ZD(LaH,1),"/",1,2)_" "_$ZT($P(LaH,",",2),4)
 			W LastAction
 		}
 		W "</td>"
 		W "</tr>"
 			
 		For  {
 		
 			Set InterfaceName=$O(%session.Data("SysListArray",package,InterfaceName))
 			Q:InterfaceName=""
 		
 			S Category=$G(%session.Data("SysListArray",package,InterfaceName,"Category"))
 		
 			If ($FIND(Category,"DontMonitor")=0 ) {
 				
 				Set rowNum=rowNum+1
 				
 				W "<TR id='ItemRow:"_package_","_rowNum_"' style='display: "
 				if ( (NameFilter'="") && ($ZCVT(InterfaceName,"U")[$ZCVT(NameFilter,"U"))) {
 					w "table-row"
 				} else {
 					w "none"
 				}
 				w "' "
 				if rowNum#2=0 {
 					W " class=""EvenRow"" "
 				} Else {
 					W " class=""OddRow"" "
 				}
 				w ">"
 
 			
 				W "<TD style='width=5'>"
 				W "&nbsp;"
 				W "</TD>"
 				
 				W "<TD nowrap width=420 id='"_InterfaceName_"'><A HREF='IIBASupportDetail.csp?PageName=InterfaceStatus&InterfaceName="_InterfaceName
 				W "&InterfaceId="_%session.Data("SysListArray",package,InterfaceName,"ID")
 				W "&Mode=ShowStatus "
 				W "' Target='_blank' "
 				W "OnClick=""return popup(this,'Interface')"" "
 				If ( $G(%session.Data("SysListArray",package,InterfaceName,"Comment"))'="") {
 					W " title='"_%session.Data("SysListArray",package,InterfaceName,"Comment")_"' "
 				}
 				W ">"_InterfaceName_"</A></TD>"
 				set TypeName = $P("Service,Process,Operation",",",%session.Data("SysListArray",package,InterfaceName,"Type"))
 				W "<td><a href='IIBASupport.csp?PageName=SearchUtil&auto=true"
 				if ((TypeName = "Service")||(TypeName="Process")) {
 					w "&direction=source"
 				} elseif TypeName="Operation" {
 					w "&direction=target"
 				}
 				w "&type="_TypeName
 				w "&item="_InterfaceName
 				if ( $G(%session.Data("HostStatusArray",InterfaceName,"LastAction"))'="") {
 					w "&lastaction="_$ZD($ZDH($P($G(%session.Data("HostStatusArray",InterfaceName,"LastAction"))," ",1),3),1)
 				}
 				w "'>"
 				w "<img src='customimages/searchblue.gif' align='center' border='0' alt='Search'></a></td>"
 				
 				S:Category="" Category="&nbsp;"
 				W "<TD nowrap width=220>"_Category
 				if $FIND(InterfaceName,"metric")'=0 {
 					W "<input type='button' value='metric' OnClick=""window.open('_DeepSee.UserPortal.DashboardViewer.zen?DASHBOARD="_$P(InterfaceName,".",1)_"/"_InterfaceName_".dashboard');"" >"
 				}
 				W "</TD>"
 			
 	
 				If (ProductionStatus = 1) {
 			
 					Set InterfaceQueue=$Get(%session.Data("HostStatusArray",InterfaceName,"Queue"),0)+0
 					Set Enabled=$Get(%session.Data("SysListArray",package,InterfaceName,"Enabled"),0)
 					Set Type=%session.Data("SysListArray",package,InterfaceName,"Type")
 					W "<TD>"_$P("Service,Process,Operation",",",Type)_"</TD>"
 					//w "<TD>"
 					//W "<TD nowrap width=420 id='"_InterfaceName_"'><A HREF='IIBASupportDetail.csp?PageName=InterfaceStatus&InterfaceName="_InterfaceName
 					//W "<A HREF='EnsPortal.EventLog.zen?SOURCE="_Name_"' target='_blank'>Enabled</A>"
 					
 					W "<TD id='ItemRow:"_InterfaceName_":Status' "
 					If ($G(%session.Data("SysListArray",package,InterfaceName,"Enabled"))=1 ) {
 						
 						If ( $G(%session.Data("HostStatusArray",InterfaceName,"Status"))="Error" ) {
 							W " style='background-color:red'>"
 							//w "Error"
 							W "<A HREF='EnsPortal.EventLog.zen?SOURCE="_InterfaceName_"' target='_blank'>Error</A>"
 						} Else {
 			
 							If ( (Type=3) && 
 					 			($G(%session.Data("HostStatusArray",InterfaceName,"Status"))="Retry")  ||
 			    	 			(( Type=1) && 
 			      	 			( $G(%session.Data("HostStatusArray",InterfaceName,"AdapterState"))="1 job listening") )  ) {
 				      	 
 									W " style='background-color:yellow'/>"
 									//W $G(%session.Data("HostStatusArray",InterfaceName,"AdapterState"))
 									W "<A HREF='EnsPortal.EventLog.zen?SOURCE="_InterfaceName_"' target='_blank'>"_$G(%session.Data("HostStatusArray",InterfaceName,"AdapterState"))_"</A>"
 									
 							} Else {
 			
 									W "&nbsp;"
 							}
 						}
 						
 					} ELSE {
 
 						W " style='background-color:red'>"
 						//W "Disabled"
 						W "<A HREF='EnsPortal.EventLog.zen?SOURCE="_InterfaceName_"' target='_blank'>Disabled</A>"
 					}
 					w "</TD>"
 					
 							
 
 					W "<TD id='ItemRow:"_InterfaceName_":Queue' nowrap>"
 					W InterfaceQueue
 					W "</TD>"
 					Set LastAction="&nbsp;"
 					If ($G(%session.Data("HostStatusArray",InterfaceName,"LastAction")) '= "") {
 						Set LaDt=$P(%session.Data("HostStatusArray",InterfaceName,"LastAction")," ",1)
 						Set LaTm=$P(%session.Data("HostStatusArray",InterfaceName,"LastAction")," ",2)
 						Set LaH=$ZDTH($P(LaDt,"-",2)_"/"_$P(LaDt,"-",3)_"/"_$P(LaDt,"-",1)_" "_LaTm)
 						Set LastAction=$ZD(LaH,11)_" "_$P($ZD(LaH,1),"/",1,2)_" "_$ZT($P(LaH,",",2),4)
 					}
 					
 					W "<TD id='ItemRow:"_InterfaceName_":LastAction' nowrap>"_LastAction
 
 
 				} ELSE {
 
 					W "<TD style='background-color:red'>???</TD>"
 				}
 			
 
 				
 			}
 		
 			W "</TR>"
 		}
 			
 			
 			
 		
 	}
 	W "</TABLE>"
 	
 	Quit $$$OK
}

ClassMethod CollectStats() As %String [ Language = objectscript ]
{
 
 //S ^CacheTempBenTrace("SystemList",$H)=1
 
 Set ProductionName=""
 Set ProductionStatus=""
 set status = ##class(Ens.Director).GetProductionStatus(.ProductionName,.ProductionStatus)
 

 
 //Collect interface status information

 Kill SysList
 Kill pkgIndex
 set production=##class(Ens.Config.Production).%OpenId(ProductionName)
 
 for i=1:1:production.Items.Count() {
 		
 	// collect item settings
 	s item=production.Items.GetAt(i)
 
 	s name=item.Name
 	s category=item.Category
 	s class=item.ClassName
 	s Type=item.BusinessType()
 		
 	s %session.Data("name")=name
 	
 	s package=..GetPackageName(name,category)
 	
 	
 	if ( package '= "" ) {
 		s SysList(package,name,"Enabled")=item.Enabled+0
 		S SysList(package,name,"ID")=item.%Id()
 		s SysList(package,name,"Category")=category
 		s SysList(package,name,"Type")=item.BusinessType()
 		s pkgIndex(name)=package
 		S comment=item.Comment
 		//If (comment="") {
 		//	S comment="&nbsp;"
 		//}
 		S SysList(package,name,"Comment")=comment
 		
 	}
 }
 
 Kill HostStatus
 Kill PacakgeSummary
 set rs=##class(%ResultSet).%New("Ens.Util.Statistics:EnumerateHostStatus")
 Set r=rs.Execute()
 	
 while rs.Next() {
 	Set name=rs.Get("Name")
 	Set HostStatus(name,"Status")=rs.Get("Status")
 	Set HostStatus(name,"AdapterState")=rs.Get("AdapterState")
 	Set HostStatus(name,"LastAction")=rs.Get("LastActivity")
 	Set HostStatus(name,"ElapsedTime")=rs.Get("ElapsedTime")
 	set HostStatus(name,"Queue")=rs.Get("Queue")
 	Set HostStatus(name,"Count")=rs.Get("Count")
 		
 	
 	s package=..GetPackageName(name)
 	s package=$G(pkgIndex(name))
 	
 	if ( package '= "" ) {
 		Set PackageSummary(package,"Queue")=$G(PackageSummary(package,"Queue"))+HostStatus(name,"Queue")
 		
 		//S ^CacheTempBenTrace("LastAction")=HostStatus(name,"LastAction")
 		//S ^CacheTempBenTrace(package,"Queue")=PackageSummary(package,"Queue")
 			
 		if (  $G(PackageSummary(package,"LastAction")) = ""  ) {
 			   
 			S PackageSummary(package,"LastAction")=HostStatus(name,"LastAction")
 				
 		} else {
 			S PkgLastAction=$ZDTH(PackageSummary(package,"LastAction"),3,1)
 			s HostLastAction=$ZDTH(HostStatus(name,"LastAction"),3,1)
 			
 			if ( $P(PkgLastAction,",",1)<$P(HostLastAction,",",1) ) {
 				
 				S PackageSummary(package,"LastAction")=HostStatus(name,"LastAction")
 				
 			} elseif (($P(PkgLastAction,",",1)=$P(HostLastAction,",",1)) && ($P(PkgLastAction,",",2)<$P(HostLastAction,",",2))) {
 				S PackageSummary(package,"LastAction")=HostStatus(name,"LastAction")
 			}
 		}
 	}
 } 
 
 //Store the information in the session
 K %session.Data("SysListArray")
 K %session.Data("HostStatusArray")
 K %session.Data("PackageSummaryArray")
 K %session.Data("ProductionStatus")

 merge %session.Data("SysListArray")=SysList
 merge %session.Data("HostStatusArray")=HostStatus
 merge %session.Data("PackageSummaryArray")=PackageSummary
 merge %session.Data("ProductionStatus")=ProductionStatus
 
 Quit $$$OK
}

ClassMethod GetSessionData(vPackage As %String) As %String [ Language = objectscript ]
{
 
 Quit $G(%session.Data(vPackage))
}

ClassMethod SearchFor(SearchForString As %String) As %String [ Language = objectscript ]
{
 
 set Result="&nbsp;&nbsp;Found in Namespaces: |"
 set rs=##class(%ResultSet).%New()
 do rs.Prepare("SELECT DISTINCT NameSpace from IIBAENSEMBLE_Task.TaskItemDefinition WHERE ItemType = 'ProdItems' AND ItemName LIKE '%"_SearchForString_"%'")
 do rs.Execute()
 While rs.Next() {
 	set Result = Result_" <a HREF=""../"_rs.Data("NameSpace")_"/IIBASupport.csp?PageName=SystemList&NameFilter="_SearchForString_""">"_rs.Data("NameSpace")_"</a> |"
 }
 
 Quit Result
}

ClassMethod SetSessionData(vPackage As %String, value As %String) As %String [ Language = objectscript ]
{
 
 s x="All"
 
 s %session.Data(vPackage)=value
 
 Set %session.Data("Category")="All"
 
 
 Quit $$$OK
}

ClassMethod UpdateStats() As %String [ Language = objectscript ]
{
 
 //Q $$$OK
 
 K SysList
 K HostStatus
 K PackageSummary
 
 //S ^CacheTempBenTrace("SystemList","UpdateStats")=$G(^CacheTempBenTrace("SystemList","UpdateStats"))+1
 Do ..CollectStats()
 
 Set package=""
 Set PrevPackage=""
 	
 //&js<alert('updating stats');>	
 	
 For {
 	//Set package=$O(SysList(package))
 	Set package=$O(%session.Data("SysListArray",package))
 	Q:package=""
 				
 		Set InterfaceName=""
 		Set QueueTotal=0
 		Set Status=""
 		Set LastAction=""
 		
 		Set RowId="PackageRow:"_package
 		Set QueueId=package_":Queue"
 		Set QueueSize=$G(%session.Data("PackageSummaryArray",package,"Queue"))_"&nbsp;"
 		&js<document.getElementById('#(QueueId)#').innerHTML='#(QueueSize)#';>
 		//&js<alert('#(QueueId)#'+'/'+'#(QueueSize)#');>
 
 		if ( $G(%session.Data("PackageSummaryArray",package,"LastAction")) = "" ) {
 			S LastAction="&nbsp;"
 		} else {
 			Set LaDt=$P(%session.Data("PackageSummaryArray",package,"LastAction")," ",1)
 			Set LaTm=$P(%session.Data("PackageSummaryArray",package,"LastAction")," ",2)
 			Set LaH=$ZDTH($P(LaDt,"-",2)_"/"_$P(LaDt,"-",3)_"/"_$P(LaDt,"-",1)_" "_LaTm)
 			Set LastAction=$ZD(LaH,11)_" "_$P($ZD(LaH,1),"/",1,2)_" "_$ZT($P(LaH,",",2),4)
 		}
 		set LastActionId=package_":LastAction"
 		&js<document.getElementById('#(LastActionId)#').innerHTML='#(LastAction)#';>
 		//&js<alert('#LastActionId#');>
 			
 		For  {
 		
 			Set InterfaceName=$O(%session.Data("SysListArray",package,InterfaceName))
 			Q:InterfaceName=""
 		
 			S Category=%session.Data("SysListArray",package,InterfaceName,"Category")
 		
 			If ($FIND(Category,"DontMonitor")=0 ) {
 				
 				S Status="&nbsp;"
 				S StatusBG=""
 				S Queue=""
 				S LastAction=""		
 			
 				If (%session.Data("ProductionStatus") = 1) {
 			
 					Set InterfaceQueue=$Get(%session.Data("HostStatusArray",InterfaceName,"Queue"),0)+0
 					Set Enabled=$Get(%session.Data("SysListArray",package,InterfaceName,"Enabled"),0)
 					Set Type=%session.Data("SysListArray",package,InterfaceName,"Type")
 					
 					If (%session.Data("SysListArray",package,InterfaceName,"Enabled")=1 ) {
 						
 					
 						If ( $G(%session.Data("HostStatusArray",InterfaceName,"Status"))="Error" ) {
 						
 							S Status="<TD style='background-color:red'>Error</TD>"
 							s Status="Error"
 							s StatusBG="red"
 						} Else {
 			
 							If ( (Type=3) && 
 				 				(%session.Data("HostStatusArray",InterfaceName,"Status")="Retry")  ||
 		    	 				(( Type=1) && 
 		      	 				( %session.Data("HostStatusArray",InterfaceName,"AdapterState")="1 job listening") )  ) {
 				      	 
 									// S Status= "<TD style='background-color:yellow'/>"_HostStatus(InterfaceName,"AdapterState")_"</TD>"
 									S Status= %session.Data("HostStatusArray",InterfaceName,"AdapterState")
 									s StatusBG="yellow"
 								
 							} Else {
 			
 									S Status="<TD>&nbsp;</TD>"
 									s Status="&nbsp;"
 									//s StatusBG="background-color:"
 							}
 						}
 						
 					} ELSE {
 
 						// W "<A HREF='EnsPortal.EventLog.zen?SOURCE="_InterfaceName_"' target='_blank'>Disabled</A>"
 						S Status="<TD style='background-color:red'>Disabled</TD>"
 						s Status="Disabled"
 						//s Status = "<A HREF='EnsPortal.EventLog.zen?SOURCE="_InterfaceName_"' target='_blank'>Disabled</A>"
 						s StatusBG="red"
 					}
 					
 					Set StatusHREF = "EnsPortal.EventLog.zen?SOURCE="_InterfaceName
 					set StatusId="ItemRow:"_InterfaceName_":Status"
 					//s ^CacheTempBenTrace("StatusId")=StatusId_"|"_Status
 					// to check in terminal: s a="" f  s a=$O( ^CacheTempBenTrace(a),1,b) q:a=""  w a,"  ",b,!
 					//&js<alert('#(StatusId)#');>
 					//&js<document.getElementById('#(StatusId)#').innerHTML='#(..EscapeHTML(Status))#';>
 					&js<document.getElementById('#(StatusId)#').href='#(StatusHREF)#';>
 					&js<document.getElementById('#(StatusId)#').innerHTML='#(Status)#';>
 					&js<document.getElementById('#(StatusId)#').style.backgroundColor='#(StatusBG)#';>
					

 
 							
 				
 		
 					set QueueId="ItemRow:"_InterfaceName_":Queue"
 					&js<document.getElementById('#(QueueId)#').innerHTML='#(InterfaceQueue)#';> 
 				
 					Set LastAction=" "
 					If ($G(%session.Data("HostStatusArray",InterfaceName,"LastAction")) '= "") {
 						Set LaDt=$P(%session.Data("HostStatusArray",InterfaceName,"LastAction")," ",1)
 						Set LaTm=$P(%session.Data("HostStatusArray",InterfaceName,"LastAction")," ",2)
 						Set LaH=$ZDTH($P(LaDt,"-",2)_"/"_$P(LaDt,"-",3)_"/"_$P(LaDt,"-",1)_" "_LaTm)
 						Set LastAction=$ZD(LaH,11)_" "_$P($ZD(LaH,1),"/",1,2)_" "_$ZT($P(LaH,",",2),4)
 					}
 					set LastActionId="ItemRow:"_InterfaceName_":LastAction"
 					//s ^CacheTempBenTrace("LastActionId")=LastActionId_"|"_LasAction
 					&js<document.getElementById('#(LastActionId)#').innerHTML='#(..EscapeHTML(LastAction))#';> 
 	
 
 
 				} 
 			
 
 				
 			}
 		
 			
 		}
 			
 			
 	}
 
 Quit $$$OK
}

ClassMethod GetPackageName(itemName As %String, category As %String = "") As %String [ Language = objectscript ]
{
	s packageName=""
	if ($P(category,",",1)'="" ) {
		s packageName=$P(category,",",1)
	} else {
		s nl=$ListFromString(itemName,".")
 		s l=$ListLength(nl)
 		if (l>1) {
 			s packageName=$ListToString($List(nl,1,l-2),".")
 		}
	}
	
 	if (packageName="") {
	 	// the default package name can be most anything except a period '.'
	 	s packageName="_default"
 	}
 	
 	Q packageName
}

}
