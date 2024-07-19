/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.csp.MobileAlert Extends %CSP.Page [ ProcedureBlock ]
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
  -->
   </script>
  >
}

ClassMethod html()
{
    Set ProductionName=""
	Set ProductionStatus=""
	set status = ##class(Ens.Director).GetProductionStatus(.ProductionName,.ProductionStatus)
	
	D ..GetStatus()
	
	W "<b>Alert Management: "_ProductionName_"</b><p>"
	
	s ifn=%request.Get("Interface")
	s action=%request.Get("Action")
	s AlertException=%request.Get("AlertException")
	
	If (ifn="") {
		W "<Form Name=""Get Interface"" id=""Get Interface"" action=""IIBASupportDetail.csp?PageName=MobileAlert"" method=""post"">"
		w "<table border=""0"" cellpadding=""3"" cellspacing=""0"">"
		w "<tr><td align=""left"" nowrap>Interface Name:&nbsp;&nbsp;"
		
		//W "<select Name=""Interface"" OnChange=#server(..GetAlertInfo())#>"
		W "</td><td><select Name=""Interface"" id=""Interface"">"
		D ..GetInterfaceOptionList()
		W "</select></td>"
		
		W "<tr><td><input type=""submit"" name=""Action"" id=""Action"" Value=""Get Alerts"">"
		W "</tr></td></table>"	
		W "</form>"
		
	} else {
		
		if (action="Toggle Alerts") {
			
			//S ^CacheTempBSG("Set Alert Exception","Toggle Alerts")=$H
			S parameter=%request.Get("Parameters")
			if (parameter '="" ) {
				S AlertID=$P($P(parameter,"_",1),"Alert",2)
				S Active=$P(parameter,"_",2)
				If ( Active = 0 ) {
					Set Active=1
				} else {
					Set Active=0
				}
			
				s rs=##class(%ResultSet).%New()
				d rs.Prepare("Update IIBAENSEMBLE_Monitor.ItemParameters set Active='"_Active_"' where ID='"_AlertID_"'")
				d rs.Execute()
			}
			
			W "<META HTTP-EQUIV=""refresh"" content=""2;URL=/csp/iibaris/IIBASupportDetail.csp?PageName=MobileAlert"">"


		} elseif  (AlertException="Set Alert Exception") {
			
			//AlertExceptionTime
			S ExceptionTime=%request.Get("AlertExceptionTime")*3600
			if (ExceptionTime>0 && (ifn'="")) {
				S ^CacheTempBSG("Set Alert Exception","Exceptions")=ExceptionTime
			
			
				&sql(select max(ExceptionId) into :ExceptionId from IIBAENSEMBLE_Monitor.AlertExceptions)
				s ExceptionId=ExceptionId+1
			
				s StartDttm=$ZDT($H,3)
				s EndDttm=($P($H,",",1)+( ($P($H,",",2)+ExceptionTime)\86400) )_","_(($P($H,",",2)+ExceptionTime)#86400)
				s EndDttm=$ZDT(EndDttm,3)
				S comment="Alert Temporarily disabled using Mobile Feature"
			
				//S ^CacheTempBSG("Set Alert Exception","Exceptions")=ExceptionId_";"_ifn_";"_StartDttm_";"_EndDttm_";"_comment
			
				
				&sql( Insert into IIBAENSEMBLE_Monitor.AlertExceptions 
	           	(ExceptionId,   itemname, startdttm, enddttm, comment)
					Values (:ExceptionId, :ifn,:StartDttm,:EndDttm,:comment)  )
		    	
			}
			
		} else {
		
			W "<Form Name=""Get Alert"" id=""Get Alert"" action=""IIBASupportDetail.csp?PageName=MobileAlert"" method=""post"">"
	
			w "<table border=""0"" cellpadding=""3"" cellspacing=""0"">"
			W "<tr><td>Interface Name</td><td><select Name=""Interface"" id=""Interface"">"
			w "<Option Value=",ifn,">",ifn,"</select></td></tr>"
		
			w "<td>Parameter (alert/threshold/status):&nbsp;&nbsp;</td>"
			w "<td><Select Name=""Parameters"" id=""Parameters"">"
			W "<Option Value="""">"
	
		
			set rs=##class(%ResultSet).%New()
			s MySql="SELECT i.ID,i.Active as Active,i.Parameter as Parameter,i.Threshold as Threshold ,t.itemdescription as Description"
			s MySql=MySql_" from IIBAENSEMBLE_Monitor.ItemParameters i join IIBAENSEMBLE_Monitor.tblItems t"
			s MySql=MySql_" on  i.Threshold=t.itemvalue where i.ItemName='"_ifn_"'"
			//Do rs.Prepare("SELECT ID,Active,Parameter,Threshold  from IIBAENSEMBLE_Monitor.ItemParameters where ItemName = '"_ifn_"'")
			Do rs.Prepare(MySql)
			Do rs.Execute()
		
	
			While(rs.Next()) {
			
			    
				Set AlertValue="Alert"_rs.Data("ID")_"_"_rs.Data("Active")
				W "<Option Value="""_AlertValue_""">"_rs.Data("Parameter")_"/"_##class(%CSP.Page).EscapeHTML(rs.Data("Description"))_"/"
				if (rs.Data("Active")=1) {
					W "Active"
				} else {
					W "Inactive"
				}
				
			}
		
			W "</Select></td>"
		 
			W "<tr><td><input type=""submit"" name=""Action"" id=""Action"" Value=""Toggle Alerts"">"
			W "</td></tr>"
			W "<tr><td>"
			W "<select name='AlertExceptionTime' id='AlertExceptionTime'><option Value=""""></option>"
			F i=1,2,4,8,12,24 W "<option value="""_i_""">"_i_"</option>"
			W "</select>"
			//W "</td>"
			W "&nbsp;&nbsp;<input type=""submit"" name=""AlertException"" id=""AlertException"" Value=""Set Alert Exception"">"
			W "</td></tr>"
	
	 	
			W "</table>"
			W "</Form>"
		}
	}
}

ClassMethod GetInterfaceOptionList() As %String [ Language = objectscript ]
{
 
     s ifn=%request.Get("Interface")
     
     
 
 	S ol= "<Option Value="""">"
 	
 	set rs=##class(%ResultSet).%New()
 	Do rs.Prepare("SELECT DISTINCT ItemName from IIBAENSEMBLE_Monitor.ItemParameters order by ItemName")
 	Do rs.Execute()
 	While(rs.Next()) {
 		s item=rs.Data("ItemName")
 		s ol=ol_"<Option Value="""_item_""""
 		
 		if (ifn=item) {
 			s ol=ol_" selected=""selected"" "
 		}
 		
 		s ol=ol_">"_item
 	}
 
 	w ol
 	
 	
 	Q 1
}

ClassMethod GetStatus() [ Language = objectscript ]
{
 	Kill SysList
 
 	Set ProductionName=""
 	Set ProductionStatus=""
 	set status = ##class(Ens.Director).GetProductionStatus(.ProductionName,.ProductionStatus)
 	set production=##class(Ens.Config.Production).%OpenId(ProductionName)
 
 	for i=1:1:production.Items.Count() {
 		
 		// collect item settings
 		s item=production.Items.GetAt(i)
 
 		s name=item.Name
 		s category=$P(item.Category,",",1)
 		s class=item.ClassName
 		s Type=item.BusinessType()
 		
 		s nl=$ListFromString(name,".")
 		s l=$ListLength(nl)
 		s package=$ListToString($List(nl,1,l-2),".")
 		
 		
 	
 		if ( category '= "" ) {
 			s SysList(name,"Enabled")=item.Enabled+0
 			S SysList(name,"ID")=i
 			s SysList(name,"Category")=category
 			s SysList(name,"Type")=item.BusinessType()
 			S SysList(name,"Comment")=item.Comment
 
 		}
 	}
 
 	Kill HostStatus
 	set rs=##class(%ResultSet).%New("Ens.Util.Statistics:EnumerateHostStatus")
 	Set r=rs.Execute()
 	
 	while rs.Next() {
 		Set name=rs.Get("Name")
 		Set HostStatus(name,"Status")=rs.Get("Status")
 		Set HostStatus(name,"AdapterState")=rs.Get("AdapterState")
 		Set HostStatus(name,"LastAction")=rs.Get("LastAction")
 		Set HostStatus(name,"ElapsedTime")=rs.Get("ElapsedTime")
 		set HostStatus(name,"Queue")=rs.Get("Queue")
 		Set HostStatus(name,"Count")=rs.Get("Count")
 	} 
 	
 	merge %session.Data("SysListArray")=SysList
 	merge %session.Data("HostStatusArray")=HostStatus
 	
 	Q 1
}

ClassMethod ToggleAlert(AlertID As %String) [ Language = objectscript ]
{
 		/*
 		if ( CurrentStatus=1) {
 			set status = ##class(Ens.Director).EnableConfigItem(InterfaceName,0)
 		} else {
 			set status = ##class(Ens.Director).EnableConfigItem(InterfaceName,1)
 		}
 		*/
 		Q 1
}

}
